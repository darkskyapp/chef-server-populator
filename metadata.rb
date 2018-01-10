name 'ds_chef_server_populator'
description 'Populate chef server with stuff you want'
maintainer 'Dark Sky'
maintainer_email 'jeff@darksky.net'
version '1.3.0'

source_url 'https://github.com/darkskyapp/ds_chef_server_populator-cookbook' if respond_to?(:source_url)
issues_url 'https://github.com/darkskyapp/ds_chef_server_populator-cookbook/issues' if respond_to?(:issues_url)

depends 'chef-server', '~> 5.0'
depends 'ds_cronner', '~> 1.0'
