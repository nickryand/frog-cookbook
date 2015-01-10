require_relative '../spec_helper'

describe 'frog::database' do
  context 'using mysql' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04') do |node|
        node.set['frog']['db']['dbms'] = 'mysql'
      end.converge(described_recipe)
    end

    it 'requires the mysql database private recipe' do
      expect(chef_run).to include_recipe('frog::_mysql')
    end
  end
end
