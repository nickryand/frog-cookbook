#
# Cookbook Name:: frog
# Recipe:: _packages.rb
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
include_recipe 'chef-sugar::default'

#
# Arch specific packages
#
if rhel?
  yum_repository 'dag' do
    description 'DAG rpm repository'
    baseurl lazy { node['frog']['yum']['dag']['url'] }
    gpgkey lazy { node['frog']['yum']['dag']['gpgkey'] }
    enabled false
    action :create
  end

  yum_repository 'centos' do
    description 'Centos upstream rpm repository'
    baseurl lazy { node['frog']['yum']['centos']['url'] }
    gpgkey lazy { node['frog']['yum']['centos']['gpgkey'] }
    enabled false
    action :create
    only_if { amazon? }
  end

  package 'ffmpeg' do
    if amazon?
      options '--enablerepo=dag --enablerepo=centos'
    else
      options '--enablerepo=dag'
    end
  end
  package 'libjpeg-turbo-devel'
  package 'libtiff-devel'
  package 'libpng-devel'
elsif debian?
  apt_repository 'ffmpeg' do
    uri node['frog']['apt']['ffmpeg']['url']
    distribution node['lsb']['codename']
    components ['main']
    keyserver 'keyserver.ubuntu.com'
    key node['frog']['apt']['ffmpeg']['key']
    only_if { ubuntu_after_precise? }
  end

  package 'ffmpeg'
  package 'libjpeg-dev'
  package 'libtiff4-dev'
  package 'libpng12-dev'
else
  fail "`#{node['platform_family']}' is not supported!"
end
