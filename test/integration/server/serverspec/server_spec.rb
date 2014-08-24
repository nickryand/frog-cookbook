require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.os = backend(Serverspec::Commands::Base).check_os
    c.path = '/sbin:/usr/sbin'
  end
end

# Arch specific packages
dev_packages = case os[:family]
               when 'RedHat'
                 %w(libjpeg-turbo-devel libtiff-devel libpng-devel)
               else
                 %w(libjpeg-dev libtiff4-dev libpng12-dev)
               end

describe package('ffmpeg') do
  it { should be_installed }
end

describe file('/usr/bin/ffmpeg') do
  it { should be_executable }
end

dev_packages.each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

describe group('frog') do
  it { should exist }
end

describe user('frog') do
  it { should exist }
  it { should belong_to_group 'frog' }
  it { should have_home_directory '/srv/frog' }
  it { should have_login_shell '/bin/none' }
end

%w(/srv/frog /srv/frog/env).each do |dir|
  describe file(dir) do
    it { should be_directory }
    it { should be_owned_by 'frog' }
    it { should be_grouped_into 'frog' }
  end
end

describe file('/srv/frog/static/frog') do
  it { should be_linked_to File.join(Dir.glob('/srv/frog/env/lib/python*').first, 'site-packages/frog/static') }
end

describe file('/srv/frog/media/frog') do
  it { should be_linked_to File.join(Dir.glob('/srv/frog/env/lib/python*').first, 'site-packages/frog/static') }
end

describe file('/srv/frog/static/admin') do
  it { should be_linked_to File.join(Dir.glob('/srv/frog/env/lib/python*').first, 'site-packages/django/contrib/admin/static/admin') }
end

describe command('/srv/frog/env/bin/pip freeze') do
  it { should return_stdout(/django-frog==/) }
  it { should return_stdout(/gunicorn==/) }
end

describe file('/var/log/gunicorn') do
  it { should be_directory }
  it { should be_owned_by 'frog' }
  it { should be_grouped_into 'frog' }
  it { should be_mode 755 }
end

describe file('/srv/frog/webapp/gunicorn_frog.py') do
  it { should be_owned_by 'frog' }
  it { should be_grouped_into 'frog' }
  its(:content) { should match(%r{accesslog = "/var/log/gunicorn/access.log"}) }
  its(:content) { should match(%r{errorlog = "/var/log/gunicorn/error.log"}) }
  its(:content) { should match(/workers = 3/) }
end

describe file('/srv/frog/media') do
  it { should be_directory }
  it { should be_owned_by 'frog' }
  it { should be_grouped_into 'frog' }
  it { should be_mode 755 }
end

describe file('/srv/frog/webapp/webapp/settings.py') do
  it { should be_owned_by 'frog' }
  it { should be_grouped_into 'frog' }
  it { should be_mode 600 }
  its(:content) { should match(/'ENGINE': 'django.db.backends.mysql'/) }
  its(:content) { should match(/'NAME': 'frog'/) }
  its(:content) { should match(/'USER': 'frog'/) }
  its(:content) { should match(/'PASSWORD': 'frog'/) }
  its(:content) { should match(/'HOST': 'localhost'/) }
  its(:content) { should match(/'PORT': [0-9]*/) }
  its(:content) { should match(%r{FROG_FFMPEG = '/usr/bin/ffmpeg'}) }
  its(:content) { should match(%r{FROG_SITE_URL = 'http://localhost:8000'}) }
  its(:content) { should match(%r{MEDIA_ROOT = '/srv/frog/media'}) }
  its(:content) { should match(%r{MEDIA_URL = 'http://localhost:8000/media/'}) }
  its(:content) { should match(%r{STATIC_ROOT = '/srv/frog/static'}) }
  its(:content) { should match(%r{STATIC_URL = 'http://localhost:8000/static/'}) }
  its(:content) { should match(/SESSION_COOKIE_AGE = [0-9]+/) }
end

describe file('/srv/frog/webapp/webapp/urls.py') do
  it { should be_owned_by 'frog' }
  it { should be_grouped_into 'frog' }
  it { should be_mode 644 }
  its(:content) { should match(/url\(r'\^frog\/', include\('frog.urls'\)\),/) }
end

describe file('/srv/frog/webapp/manage.py') do
  it { should be_file }
end

describe process('gunicorn') do
  its(:args) { should match(%r{-c /srv/frog/webapp/gunicorn_frog.py --chdir /srv/frog/webapp webapp.wsgi:application}) }
  it { should be_running }
end

describe port(8000) do
  it { should be_listening.with('tcp') }
end
