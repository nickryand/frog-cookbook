require_relative '../../../kitchen/data/spec_helper'

describe process("mysqld") do
  it { should be_running }
end

describe command("mysql -u root -pfrog -e 'show databases'") do
  it { should return_stdout(/^frog/) }
end
