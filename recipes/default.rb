require 'open-uri'
require 'openssl'

if Chef::Config[:solo]
  include_recipe 'chef-server-populator::solo'
else
  include_recipe 'chef-server-populator::client'
end

# Used when specifying a remote file to restore from backup
if !node['chef_server_populator']['restore']['file'].empty? &&
   node['chef_server_populator']['restore']['file'] != 'none'
  include_recipe 'chef-server-populator::restore'
end
