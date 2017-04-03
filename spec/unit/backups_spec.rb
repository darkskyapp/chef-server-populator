require 'spec_helper'

describe 'chef-server-populator::backups' do
  let(:data_dir) { '/tmp/chef-backups' }
  let(:config_dir) { '/etc/populator/config' }
  let(:backup_script) { '/usr/local/bin/chef-server-backup' }
  let(:backup_schedule) { Mash.new(hour: '0', minute: '20') }
  let(:apt_packages) { %w(gcc libxml2 libxml2-dev libxslt-dev) }
  let(:yum_packages) { %w(gcc libxml2 libxml2-devel libxslt libxslt-devel patch) }

  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |node|
      node.override['chef_server_populator']['backup']['dir'] = data_dir
      node.override['chef_server_populator']['configuration_directory'] = config_dir
      node.override['chef_server_populator']['backup_gems'] = gems
      node.override['chef_server_populator']['backup']['remote']['connection'] = {}
    end.converge(described_recipe)
  end

  it 'creates a directory for storing backup data' do
    expect(chef_run).to create_directory(data_dir)
  end

  it 'creates a directory for storing backup script configuration' do
    expect(chef_run).to create_directory(config_dir)
  end

  it 'installs platform-specific build dependencies for transmitting backup data to a remote service' do
    centos_chef_run = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.5') do |node|
      node.override['chef_server_populator']['backup']['remote']['connection'] = {}
    end.converge(described_recipe)

    apt_packages.each do |pkg|
      expect(chef_run).to install_package(pkg)
    end

    yum_packages.each do |pkg|
      expect(centos_chef_run).to install_package(pkg)
    end
  end

  it 'creates the backup script configuration' do
    expect(chef_run).to render_file(File.join(config_dir, 'backup.json'))
  end

  it 'creates the backup script' do
    expect(chef_run).to render_file(backup_script)
  end

  it 'creates a crontab entry for the backup script' do
    expect(chef_run).to create_cron('Chef Server Backups').with(
      command: 'bundle install --path /etc/opscode/.vendor && bundle exec /usr/local/bin/chef-server-backup',
      minute: backup_schedule[:minute],
      hour: backup_schedule[:hour],
      path: '/opt/chef/embedded/bin/:/usr/bin:/usr/local/bin:/bin'
    )
  end
end
