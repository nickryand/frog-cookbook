require_relative '../spec_helper'

describe 'frog::nginx' do
  let(:nginx_home)   { '/etc/nginx' }
  let(:frog_site)    { "#{nginx_home}/sites-available/frog" }
  let(:server_name)  { 'test.local' }
  let(:nginx_log)    { '/var/log/nginx' }
  let(:frog_url)     { 'http://localhost' }
  let(:frog_port)    { 8080 }

  cached(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |node|
      node.set['nginx']['dir'] = nginx_home
      node.set['frog']['nginx']['server_name'] = server_name
      node.set['frog']['settings']['url'] = frog_url
      node.set['frog']['settings']['port'] = frog_port
    end.converge(described_recipe)
  end

  before do
    stub_command("which nginx").and_return('/usr/bin/nginx')
  end

  it 'includes the nginx default recipe' do
    expect(chef_run).to include_recipe('nginx::default')
  end

  it 'sets up the proper nginx site template' do
    expect(chef_run).to create_template(frog_site)
      .with_owner('root')
      .with_group('root')
      .with_mode(00644)
      .with_variables(
        :listen_port => frog_port,
        :server_name => server_name,
        :access_log => '/var/log/nginx/frog-access.log',
        :media_root => '/srv/frog/media',
        :static_root => '/srv/frog/static',
        :url => "#{frog_url}:8000"
      )
  end

  it 'enable the frog site by linking the config to sites-enabled' do
    expect(chef_run).to create_link(nginx_home + '/sites-enabled/frog')
  end
end
