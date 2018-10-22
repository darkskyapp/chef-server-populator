default['chef-server']['accept_license'] = true

override['set_fqdn'] = 'chef.darksky.net'

default['chef_server_populator']['configuration_directory'] = '/etc/chef-server/populator'
default['chef_server_populator']['base_path'] = '/tmp/chef-server-populator'
default['chef_server_populator']['clients'] = {}
default['chef_server_populator']['knife_exec'] = '/usr/bin/knife'
default['chef_server_populator']['user'] = 'admin'
default['chef_server_populator']['pem'] = '/etc/chef-server/admin.pem'
default['chef_server_populator']['databag'] = nil

default['chef_server_populator']['endpoint'] = nil

# Deprecated in favor of endpoint
default['chef_server_populator']['servername_override'] = nil

# The :chef_server attribute is passed to chef-server cookbook
# Default the ttl since it kills runs with 403s on templates with
# annoying frequency
default['chef_server_populator']['chef_server']['configuration']['opscode_erchef']['s3_url_ttl'] = 3600

# This setting allows the Chef Server to be fronted by an ELB terminating SSL
# This allows the ELB to communicate via HTTP to the Chef Server
default['chef_server_populator']['chef_server']['configuration']['nginx']['enable_non_ssl'] = true

default['chef_server_populator']['cookbook_auto_install'] = true

default['chef_server_populator']['restore']['file'] = ''
default['chef_server_populator']['restore']['data'] = ''
default['chef_server_populator']['restore']['local_path'] = '/tmp/'

default['chef_server_populator']['backup']['dir'] = '/tmp/chef-server/backup'
default['chef_server_populator']['backup']['filename'] = 'chef-server-full'
default['chef_server_populator']['backup']['remote']['connection'] = nil
default['chef_server_populator']['backup']['remote']['bucket'] = nil
default['chef_server_populator']['backup']['remote']['file_prefix'] = nil

# Example remote backup:
# default['chef_server_populator']['backup']['remote']['connection']['region'] = 'us-east-1'
# default['chef_server_populator']['backup']['remote']['bucket'] = 'my-ops'
# default['chef_server_populator']['backup']['remote']['file_prefix'] = 'chef/backups'

default['chef_server_populator']['backup']['schedule'] = {
  minute: '33',
  hour: '3',
}

# The following attributes are provided as examples. In almost every
# imaginable case you will want to replace some or all of these with
# your own values.

default['chef_server_populator']['solo_org'] = {
  # 'inception_llc' => {
  #   'org_name'          => 'inception_llc',
  #   'full_name'         => 'Inception',
  #   'validator_pub_key' => 'validator_pub.pem',
  # }
}

default['chef_server_populator']['solo_org_user'] = {
  'name'    => 'populator',
  'first'   => 'Populator',
  'last'    => 'User',
  'email'   => 'pop@example.com',
  'pub_key' => 'user_pub.pem',
}

default['chef_server_populator']['server_org'] = 'inception_llc'
# If this is set to nil, the configurator recipe will set it to the server_org.
default['chef_server_populator']['default_org'] = nil
