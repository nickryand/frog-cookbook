require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.os = backend(Serverspec::Commands::Base).check_os
    c.path = '/sbin:/usr/sbin'
  end
end

describe file('/srv/frog/webapp/webapp/settings.py') do
  it { should be_owned_by 'frog' }
  it { should be_grouped_into 'frog' }
  it { should be_mode 600 }
  its(:content) { should match(/'ENGINE': 'django.db.backends.mysql'/) }
  its(:content) { should match(/'NAME': 'frog'/) }
  its(:content) { should match(/'USER': 'frog'/) }
  its(:content) { should match(/'PASSWORD': 'frogadmin'/) }
  its(:content) { should match(/'HOST': '.*rds.amazonaws.com'/) }
  its(:content) { should match(/'PORT': [0-9]*/) }
end
