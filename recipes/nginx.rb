#
# Cookbook Name:: frog
# Recipe:: nginx
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
include_recipe 'nginx::default'

template node['nginx']['dir'] + '/sites-available/frog' do
  source 'frog.nginx.erb'
  owner 'root'
  group 'root'
  mode 00644
  variables lazy {
    {
      :listen_port => node['frog']['settings']['port'],
      :server_name => node['frog']['nginx']['server_name'],
      :access_log => node['nginx']['log_dir'] + '/frog-access.log',
      :media_root => node['frog']['settings']['media_root'],
      :static_root => node['frog']['settings']['static_root'],
      :url => generate_url(node['frog']['settings']['url'], 8000)
    }
  }
  notifies :reload, 'service[nginx]', :delayed
end

link node['nginx']['dir'] + '/sites-enabled/frog' do
  to node['nginx']['dir'] + '/sites-available/frog'
  notifies :reload, 'service[nginx]', :delayed
end
