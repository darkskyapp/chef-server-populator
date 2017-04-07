require 'open-uri'
require 'openssl'

if Chef::Config[:solo]
  include_recipe 'ds_chef_server_populator::solo'
else
  include_recipe 'ds_chef_server_populator::client'
end

# Used when specifying a remote file to restore from backup
if !node['chef_server_populator']['restore']['file'].empty? &&
   node['chef_server_populator']['restore']['file'] != 'none'
  include_recipe 'ds_chef_server_populator::restore'
end
