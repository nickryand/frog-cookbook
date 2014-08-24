#
# Cookbook Name:: frog-cookbook
# Attributes:: settings
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
# Base URL for the Frog application
#
default['frog']['settings']['url'] = "http://#{node['fqdn']}"

#
# Frog site url port
#
# The url and port settings are used to generate URL's throughout
# the Frog site. If you are using a reverse proxy for the entire
# Frog application, this should be the listening port of that proxy
#
default['frog']['settings']['port'] = 8000

#
# Media URL used to serve dynamic content. Uploaded pictures are
# served from this path. Currently some static content is served
# from this path as well.
#
default['frog']['settings']['media_path'] = "/media/"

#
# Directory for on-disk media storage. Picture and video uploads
# are written under this location on disk.
#
default['frog']['settings']['media_root'] = '/srv/frog/media'

#
# URL path for serving static assets
#
default['frog']['settings']['static_path'] = "/static/"

#
# Directory location for static content
#
default['frog']['settings']['static_root'] = '/srv/frog/static'

#
# Session Cookie Expiration in seconds
#
default['frog']['settings']['session_age'] = 86400

#
# Location of the ffmpeg binary. FFMPEG is used for video
# playback support.
#
default['frog']['settings']['ffmpeg_exe'] = '/usr/bin/ffmpeg'

#
# Django Secret Key used to cryptographically sign. If this
# value is nil or unset, the cookbook will use the OpenSSL
# secure_password LWRP to generate a 50 character string.
#
# https://docs.djangoproject.com/en/dev/ref/settings/#std:setting-SECRET_KEY
#
default['frog']['settings']['secret_key'] = nil

#
# Controls DEBUG mode for the Django site
#
default['frog']['settings']['debug'] = 'False'

#
# Sets the allowed hosts list for the Django site
#
# https://docs.djangoproject.com/en/dev/ref/settings/#std:setting-ALLOWED_HOSTS
#
default['frog']['settings']['allowed_hosts'] = ['*']
