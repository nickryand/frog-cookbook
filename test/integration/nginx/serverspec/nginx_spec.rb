require_relative '../../../kitchen/data/spec_helper'

describe package('nginx') do
  it { should be_installed }
end

describe process("nginx") do
  it { should be_running }
end

describe port(8080) do
  it { should be_listening.with('tcp') }
end

describe file('/etc/nginx/sites-enabled/frog') do
  it { should be_linked_to '/etc/nginx/sites-available/frog' }
  its(:content) { should match(/listen.*8080;/) }
  its(:content) { should match(/server_name\s+localhost/) }
  its(:content) { should match(%r{access_log.*/var/log/nginx/frog-access.log}) }
  its(:content) { should match(%r{alias /srv/frog/media;}) }
  its(:content) { should match(%r{alias /srv/frog/static;}) }
  its(:content) { should match(%r{proxy_pass http://localhost:8000}) }
end

describe command('ls /etc/nginx/sites-enabled/default') do
  its(:stdout) { should match(/No such file or directory/) }
end
