require_relative '../spec_helper'

describe 'frog::default' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04').converge(described_recipe)
  end

  before do
    stub_command("/srv/frog/env/bin/python manage.py list_users | grep root").and_return(true)
    stub_command("which nginx").and_return('/usr/bin/nginx')
  end

  it 'requires proper recipes to build a single box stack' do
    expect(chef_run).to include_recipe('frog::database')
    expect(chef_run).to include_recipe('frog::server')
    expect(chef_run).to include_recipe('frog::nginx')
  end
end
