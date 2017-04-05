if node['chef_server_populator']['default_org'].nil?
  node.default['chef_server_populator']['default_org'] = node['chef_server_populator']['server_org']
end

include_recipe 'chef-server-populator::configurator'

# if backup pull files include restore

remote_conf = node['chef_server_populator']['backup']['remote']

if remote_conf['connection']
  chef_gem 'aws-sdk-s3' do
    compile_time true
    version      '1.0.0.rc3'
  end

  require 'aws-sdk-s3'

  s3         = Aws::S3::Resource.new region: remote_conf['connection']['region']
  bucket     = s3.bucket(remote_conf['bucket'])
  gz_file    = bucket.object "#{remote_conf['file_prefix']}/latest.tgz"
  dump_file  = bucket.object "#{remote_conf['file_prefix']}/latest.dump"
  local_gz   = '/tmp/latest.tgz'
  local_dump = '/tmp/latest.dump'

  begin
    gz_file.get response_target: local_gz
    dump_file.get response_target: local_dump

    node.default['chef_server_populator']['restore']['file'] = local_dump
    node.default['chef_server_populator']['restore']['data'] = local_gz
  rescue Aws::S3::Errors::NoSuchBucket => e
    Chef::Log.fatal e.message
  rescue Aws::S3::Errors::NoSuchKey => e
    Chef::Log.info "One of the backup files is missing from S3: " \
                   "#{remote_conf['file_prefix']}/latest.tgz " \
                   "or #{remote_conf['file_prefix']}/latest.dump"

    local_gz   = nil
    local_dump = nil
  rescue Aws::Errors::ServiceError => e
    Chef::Log.error e.message
  end
end

if local_gz && local_dump
  include_recipe 'chef-server-populator::restore'
else
  include_recipe 'chef-server-populator::org'
  orgs = node['chef_server_populator']['solo_org']

  orgs.each do |k, org|
    knife_cmd = node['chef_server_populator']['knife_exec']
    knife_opts = "-s https://127.0.0.1/organizations/#{org['org_name']} -c /etc/opscode/pivotal.rb"

    node['chef_server_populator']['clients'].each do |client, pub_key|
      execute "#{k} - create client: #{client}" do
        command "#{knife_cmd} client create #{client} --admin -d #{knife_opts} > /dev/null 2>&1"
        not_if "#{knife_cmd} client list #{knife_opts}| tr -d ' ' | grep '^#{client}$'"
        retries 5
      end

      next unless pub_key && node['chef_server_populator']['base_path']

      pub_key_path = File.join(node['chef_server_populator']['base_path'], pub_key)

      execute "#{k} - remove default public key for #{client}" do
        command "chef-server-ctl delete-client-key #{org['org_name']} #{client} default"
        only_if "chef-server-ctl list-client-keys #{org['org_name']} #{client} | grep 'name: default$'"
      end

      execute "#{k} - set public key for: #{client}" do
        if node['chef-server']['version'].to_f >= 12.1 || node['chef-server']['version'].to_f == 0.0
          command "chef-server-ctl add-client-key #{org['org_name']} #{client} --public-key-path #{pub_key_path} --key-name populator"
        else
          command "chef-server-ctl add-client-key #{org['org_name']} #{client} #{pub_key_path} --key-name populator"
        end
        not_if "chef-server-ctl list-client-keys #{org['org_name']} #{client} | grep 'name: populator$'"
      end
    end

    # Because the cookbook_path can be either a String or an Array,
    # we need to validate it before using it in the execute command below
    cookbook_path = if Chef::Config[:cookbook_path].is_a? Array
                      Chef::Config[:cookbook_path].join ':'
                    elsif Chef::Config[:cookbook_path].is_a? String
                      Chef::Config[:cookbook_path]
                    else
                      raise 'The Chef::Config[:cookbook_path] is an invalid value'
                    end

    execute "#{k} - install chef-server-populator cookbook" do
      command "#{knife_cmd} cookbook upload chef-server-populator #{knife_opts} -o #{cookbook_path} --include-dependencies"
      only_if do
        node['chef_server_populator']['cookbook_auto_install']
      end
      retries 5
    end
  end
end
