%w(
  Gemfile
  Gemfile.lock
).each do |f|
  cookbook_file "/etc/opscode/#{f}" do
    action :create
  end
end

directory node['chef_server_populator']['backup']['dir'] do
  recursive true
  owner 'opscode-pgsql'
  mode  '0755'
end

# Upload to Remote Storage
# Include fog
case node['platform_family']
when 'debian'
  packages = %w(gcc libxml2 libxml2-dev libxslt-dev)
when 'rhel'
  packages = %w(gcc libxml2 libxml2-devel libxslt libxslt-devel patch)
end
packages.each do |fog_dep|
  package fog_dep
end

directory node['chef_server_populator']['configuration_directory'] do
  recursive true
  owner 'root'
  mode 0700
end

file File.join(node['chef_server_populator']['configuration_directory'], 'backup.json') do
  content Chef::JSONCompat.to_json_pretty(
    node['chef_server_populator']['backup'].merge(
      cookbook_version: node.run_context.cookbook_collection['chef-server-populator'].version
    )
  )
  owner 'root'
  mode 0600
end

template '/usr/local/bin/chef-server-backup' do
  source 'chef-server-backup.rb.erb'
  mode '0700'
  retries 3
end

cron 'Chef Server Backups' do
  command 'bundle install --path /etc/opscode/.vendor && '\
          'bundle exec /usr/local/bin/chef-server-backup'
  node['chef_server_populator']['backup']['schedule'].each do |k, v|
    send(k, v)
  end
  environment BUNDLE_GEMFILE: '/etc/opscode/Gemfile'
  path '/opt/chef/embedded/bin:/usr/bin:/usr/local/bin:/bin'
end
