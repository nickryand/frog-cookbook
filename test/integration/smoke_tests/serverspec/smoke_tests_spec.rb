require 'serverspec'
require 'net/http'

require_relative '../../../kitchen/data/spec_helper'

describe process('nginx') do
  it { should be_running }
end

describe port(8080) do
  it { should be_listening.with('tcp') }
end

describe port(8000) do
  it { should be_listening.with('tcp') }
end

describe Net::HTTP.get_response(URI('http://localhost:8080/frog/')) do
  its(:code) { should eq '200' }
end
