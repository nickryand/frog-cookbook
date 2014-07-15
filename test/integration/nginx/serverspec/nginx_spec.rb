require 'serverspec'
require 'socket'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.os = backend(Serverspec::Commands::Base).check_os
    c.path = '/sbin:/usr/sbin'
  end
end

describe package('nginx') do
  it { should be_installed }
end

describe process("nginx") do
  it { should be_running }
end

describe port(80) do
  it { should be_listening.with('tcp') }
end

describe file('/etc/nginx/sites-enabled/frog') do
  it { should be_linked_to '/etc/nginx/sites-available/frog' }
  its(:content) { should match(/listen.*80;/) }
  its(:content) { should match(/server_name\s+localhost/) }
  its(:content) { should match(%r{access_log.*/var/log/nginx/frog-access.log}) }
  its(:content) { should match(%r{alias /srv/frog/media;}) }
  its(:content) { should match(%r{alias /srv/frog/static;}) }
  its(:content) { should match(%r{proxy_pass http://127.0.0.1:8000}) }
end
