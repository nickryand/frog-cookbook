require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.os = backend(Serverspec::Commands::Base).check_os
    c.path = '/sbin:/usr/sbin'
  end
end

describe process("mysqld") do
  it { should be_running }
end

describe command("mysql -u root -pfrog -e 'show databases'") do
  it { should return_stdout(/^frog/) }
end
