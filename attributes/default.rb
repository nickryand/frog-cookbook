#
# Cookbook Name:: frog-cookbook
# Attributes:: default
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
# The version of django-frog to install. Check the pypi django-frog
# page for the list of versions available.
#
# https://pypi.python.org/pypi/django-frog
#
default['frog']['version'] = '1.0.3'

#
# Directory in which to create the Django project and virtual
# environment. The entire installation will be rooted to this
# directory.
#
default['frog']['rootdir'] = '/srv/frog'

#
# The frog pypi package name or location of the django-frog python
# package. This could also be a URL if you need to install the
# django-frog application from another source.
#
# Example: git+https://github.com/theiviaxx/Frog.git
#
default['frog']['package_name'] = 'django-frog'

#
# Username and Group for the Frog installation and Gunicorn process
#
default['frog']['user'] = 'frog'
default['frog']['group'] = 'frog'

#
# Number of Gunicorn worker processes
#
# http://gunicorn-docs.readthedocs.org/en/latest/design.html#how-many-workers
#
default['frog']['gunicorn']['workers'] = 3

#
# The directory to use for Gunicorn log files
#
default['frog']['gunicorn']['log_dir'] = '/var/log/gunicorn'

#
# The initial admin user for the Frog admin portal
#
default['frog']['admin']['user'] = 'root'

#
# The initial admin's password for the Frog admin portal
#
default['frog']['admin']['password'] = 'thisshouldbechanged'

#
# Email address for the initial admin user
#
default['frog']['admin']['email'] = 'root@localhost'
