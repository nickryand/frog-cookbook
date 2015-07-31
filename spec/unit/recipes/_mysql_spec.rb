require_relative '../spec_helper'

describe 'frog::_mysql' do
  context 'no dbms install' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |node|
        node.set['frog']['db']['install_dbms'] = false
      end.converge(described_recipe)
    end

    it 'should not attempt to install mysql server' do
      expect(chef_run).not_to create_mysql_service('default')
    end
  end

  context 'dbms install' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |node|
        node.set['frog']['db']['install_dbms'] = true
      end.converge(described_recipe)
    end

    it 'should not attempt to install mysql server' do
      expect(chef_run).to create_mysql_service('default')
    end
  end

  context 'rhel' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['frog']['db']['install_dbms'] = true
      end.converge(described_recipe)
    end

    it 'disable selinux so mysql daemon can run' do
      expect(chef_run).to include_recipe('selinux::disabled')
    end

    it 'does not disable selinux when no server is being installed' do
      chef_run.node.set['frog']['db']['install_dbms'] = false
      chef_run.converge(described_recipe)
      expect(chef_run).to_not include_recipe('selinux::disabled')
    end
  end

  context 'default run' do
    let(:host)           { '192.168.1.1' }
    let(:from_host)      { '192.168.1.2' }
    let(:username)       { 'tester' }
    let(:password)       { 'testpass' }
    let(:db_name)        { 'test' }
    let(:mysql_password) { 'tester' }

    let(:conn_hash) { { host: host, username: 'root', password: mysql_password } }

    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |node|
        node.set['frog']['db']['host'] = host
        node.set['frog']['db']['name'] = db_name
        node.set['frog']['db']['user'] = username
        node.set['frog']['db']['password'] = password
        node.set['frog']['db']['from_host'] = from_host
        node.set['frog']['db']['server_root_password'] = mysql_password
        node.set['frog']['db']['install_dbms'] = true
      end.converge(described_recipe)
    end

    it 'should create the mysql service' do
      expect(chef_run).to create_mysql_service('default')
        .with_port('3306')
        .with_version('5.6')
        .with_initial_root_password(mysql_password)
    end

    it 'should install the mysql2 chef gem' do
      expect(chef_run).to install_mysql2_chef_gem('default')
    end

    it 'should setup the proper database' do
      expect(chef_run).to create_mysql_database(db_name)
        .with_connection(conn_hash)
    end

    it 'should create the proper database user with proper permissions' do
      expect(chef_run).to create_mysql_database_user(username)
        .with_password(password)
        .with_database_name(db_name)
        .with_host(from_host)
    end

    it 'should grant the user proper permissions' do
      expect(chef_run).to grant_mysql_database_user(username)
        .with_privileges([:select, :update, :insert, :delete, :alter, :create, :index])
    end
  end
end
