name 'chef-server-populator'
description 'Populate chef server with stuff you want'
maintainer 'Heavywater'
maintainer_email 'support@hw-ops.com'
version '2.0.2'

source_url 'https://github.com/hw-cookbooks/chef-server-populator' if respond_to?(:source_url)
issues_url 'https://github.com/hw-cookbooks/chef-server-populator/issues' if respond_to?(:issues_url)

depends 'chef-server', '~> 5.0'
