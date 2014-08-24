#
# Cookbook Name:: frog
# Recipe:: server
#
# Copyright (C) 2014 Nick Downs
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
include_recipe 'python'
include_recipe 'chef-sugar'

package 'git'
include_recipe 'frog::_packages'

group node['frog']['group'] do
  system true
  action :create
end

user node['frog']['user'] do
  system true
  group node['frog']['group']
  home node['frog']['rootdir']
  shell '/bin/none'
  action :create
end

directory node['frog']['rootdir'] do
  owner node['frog']['user']
  group node['frog']['group']
  mode 0755
  recursive true
end

install_dir = "#{node['frog']['rootdir']}/env"
directory install_dir do
  owner node['frog']['user']
  group node['frog']['group']
  mode 0755
  recursive true
end

python_virtualenv install_dir do
  action :create
end

python_pip 'django-frog' do
  version lazy { node['frog']['version'] }
  package_name lazy { node['frog']['package_name'] }
  virtualenv install_dir
end

python_pip 'MySQL-python' do
  virtualenv install_dir
end

python_pip 'pillow' do
  virtualenv install_dir
end

execute "bootstrap_django_app" do
  command "#{node['frog']['rootdir']}/env/bin/django-admin.py startproject webapp"
  cwd node['frog']['rootdir']
  not_if { ::File.exist?("#{node['frog']['rootdir']}/webapp/manage.py") }
end

directory node['frog']['gunicorn']['log_dir'] do
  owner node['frog']['user']
  group node['frog']['group']
  mode 0755
  recursive true
end

# Control where gunicorn gets installed
node.set['gunicorn']['virtualenv'] = install_dir
include_recipe 'gunicorn'

gunicorn_config "#{node['frog']['rootdir']}/webapp/gunicorn_frog.py" do
  worker_processes node['frog']['gunicorn']['workers']
  owner node['frog']['user']
  group node['frog']['group']
  accesslog "#{node['frog']['gunicorn']['log_dir']}/access.log"
  errorlog "#{node['frog']['gunicorn']['log_dir']}/error.log"
end

directory node['frog']['settings']['media_root'] do
  owner node['frog']['user']
  group node['frog']['group']
  mode 0755
  recursive true
end

directory node['frog']['settings']['static_root'] do
  owner node['frog']['user']
  group node['frog']['group']
  mode 0755
  recursive true
end

# Frog serves some of the static files from MEDIA_ROOT
link "#{node['frog']['settings']['media_root']}/frog" do
  to lazy { ::File.join(Dir.glob("#{install_dir}/lib/python*").first, 'site-packages/frog/static') }
end

link "#{node['frog']['settings']['static_root']}/frog" do
  to lazy { ::File.join(Dir.glob("#{install_dir}/lib/python*").first, 'site-packages/frog/static') }
end

# Django admin CSS
link "#{node['frog']['settings']['static_root']}/admin" do
  to lazy { ::File.join(Dir.glob("#{install_dir}/lib/python*").first,  'site-packages/django/contrib/admin/static/admin') }
end

node.set_unless['frog']['settings']['secret_key'] = secure_password(50)

template "#{node['frog']['rootdir']}/webapp/webapp/settings.py" do
  owner node['frog']['user']
  group node['frog']['group']
  mode 0600
  variables(
    :db_adapter => node['frog']['db']['adapter'],
    :db_name => node['frog']['db']['name'],
    :db_user => node['frog']['db']['user'],
    :db_password => node['frog']['db']['password'],
    :db_host => node['frog']['db']['host'],
    :db_port => node['frog']['db']['port'],
    :allowed_hosts => node['frog']['settings']['allowed_hosts'],
    :ffmpeg_exe => node['frog']['settings']['ffmpeg_exe'],
    :url => generate_url(node['frog']['settings']['url'], node['frog']['settings']['port']),
    :media_path => generate_url(
      node['frog']['settings']['url'],
      node['frog']['settings']['port'],
      node['frog']['settings']['media_path']
    ),
    :media_root => node['frog']['settings']['media_root'],
    :static_path => generate_url(
      node['frog']['settings']['url'],
      node['frog']['settings']['port'],
      node['frog']['settings']['static_path']
    ),
    :static_root => node['frog']['settings']['static_root'],
    :session_age => node['frog']['settings']['session_age'],
    :secret_key => node['frog']['settings']['secret_key'],
    :debug => node['frog']['settings']['debug']
  )
  notifies :restart, 'runit_service[gunicorn]', :delayed
end

template "#{node['frog']['rootdir']}/webapp/webapp/urls.py" do
  owner node['frog']['user']
  group node['frog']['group']
  mode 0644
  notifies :restart, 'runit_service[gunicorn]', :delayed
end

execute 'frog_initial_syncdb' do
  command "#{node['frog']['rootdir']}/env/bin/python manage.py syncdb --noinput --no-initial-data && touch .initial"
  creates "#{node['frog']['rootdir']}/webapp/.initial"
  cwd "#{node['frog']['rootdir']}/webapp"
  action :run
end

execute 'frog_initial_setup' do
  command <<-EOF
    $PYBIN manage.py createsuperuser --noinput \
      --username #{node['frog']['admin']['user']} \
      --email #{node['frog']['admin']['email']} && \
    $PYBIN manage.py set_password #{node['frog']['admin']['user']} #{node['frog']['admin']['password']} && \
    $PYBIN manage.py syncdb --noinput && \
    $PYBIN manage.py migrate
  EOF
  cwd "#{node['frog']['rootdir']}/webapp"
  action :run
  environment('PYBIN' => "#{node['frog']['rootdir']}/env/bin/python")
  not_if "#{node['frog']['rootdir']}/env/bin/python manage.py list_users | grep #{node['frog']['admin']['user']}", :cwd => "#{node['frog']['rootdir']}/webapp"
end

include_recipe 'runit'
runit_service 'gunicorn' do
  default_logger true
end
