#
# Cookbook Name:: frog
# Recipe:: _mysql.rb
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
#
include_recipe 'chef-sugar::default'
include_recipe 'build-essential'
include_recipe 'selinux::disabled' if (rhel? && node['frog']['db']['install_dbms'])

mysql_service 'default' do
  port '3306'
  version '5.6'
  initial_root_password node['frog']['db']['server_root_password']
  action [:create, :start]
  only_if { node['frog']['db']['install_dbms'] }
end

# Install the mysql client
mysql2_chef_gem 'default' do
  action :install
end

conn = {
  :host => node['frog']['db']['host'],
  :username => 'root',
  :password => node['frog']['db']['server_root_password']
}

mysql_database node['frog']['db']['name'] do
  connection conn
  action :create
end

mysql_database_user node['frog']['db']['user'] do
  connection conn
  password node['frog']['db']['password']
  database_name node['frog']['db']['name']
  host node['frog']['db']['from_host']
  privileges [:select, :update, :insert, :delete, :alter, :create, :index]
  action [:create, :grant]
end
