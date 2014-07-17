require 'serverspec'
require 'net/http'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.os = backend(Serverspec::Commands::Base).check_os
    c.path = '/sbin:/usr/sbin'
  end
end

describe process('nginx') do
  it { should be_running }
end

describe port(80) do
  it { should be_listening.with('tcp') }
end

describe port(8000) do
  it { should be_listening.with('tcp') }
end

describe Net::HTTP.get_response(URI('http://localhost/frog/')) do
  its(:code) { should eq '200' }
end
