require_relative '../spec_helper'

describe 'frog::_mysql' do
  context 'no dbms install' do
    cached(:chef_run) do
      ChefSpec::Runner.new do |node|
        node.set['frog']['db']['install_dbms'] = false
      end.converge(described_recipe)
    end

    it 'should not attempt to install mysql server' do
      expect(chef_run).not_to include_recipe('mysql::server')
    end
  end

  context 'dbms install' do
    cached(:chef_run) do
      ChefSpec::Runner.new do |node|
        node.set['frog']['db']['install_dbms'] = true
      end.converge(described_recipe)
    end

    it 'should not attempt to install mysql server' do
      expect(chef_run).to include_recipe('mysql::server')
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
      ChefSpec::Runner.new do |node|
        node.set['frog']['db']['host'] = host
        node.set['frog']['db']['name'] = db_name
        node.set['frog']['db']['user'] = username
        node.set['frog']['db']['password'] = password
        node.set['frog']['db']['from_host'] = from_host
        node.set['mysql']['server_root_password'] = mysql_password
      end.converge(described_recipe)
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
