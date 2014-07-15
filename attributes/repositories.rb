#
# Cookbook Name:: frog-cookbook
# Attributes:: repositories
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

#
# DAG repository URL
#
# The upstream CentOS and Amazon Linux repositories do not have ffmpeg
# available. The DAG repository does and works on both Amazon Linux
# and CentOS.
#
# Note: This repository is only enabled for ffmpeg installation.
#
default['frog']['yum']['dag']['url'] = 'http://mirror.us.leaseweb.net/dag/redhat/el6/en/x86_64/dag/'

#
# DAG RPM gpgkey location
#
default['frog']['yum']['dag']['gpgkey'] = 'http://apt.sw.be/RPM-GPG-KEY.dag.txt'

#
# CentOS repository URL
#
# The Amazon Linux repository does not contain some of the dependency
# packages needed by ffmpeg. The CentOS repository does so we add the
# repository on Amazon Linux hosts.
#
# Note: This repository is only enabled for the ffmpeg installation.
#
default['frog']['yum']['centos']['url'] = 'http://mirror.centos.org/centos/6/os/x86_64/'

#
# CentOS RPM gpgkey location
#
default['frog']['yum']['centos']['gpgkey'] = 'http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6'

#
# PPA URL for ffmpeg apt repository
#
# Ubuntu versions newer than 12.04 have moved to libav from ffmpeg.
# Frog currently only supports ffmpeg so we add an ffmpeg apt
# repository.
#
default['frog']['apt']['ffmpeg']['url'] = 'http://ppa.launchpad.net/jon-severinsson/ffmpeg/ubuntu'

#
# URL or Fingerprint for the repository GPG key
#
default['frog']['apt']['ffmpeg']['key'] = 'CFCA9579'
