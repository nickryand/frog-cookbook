#
# Cookbook Name:: frog-cookbook
# Attributes:: database
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
# The DBMS to install and/or configure.
#
# Note: 'mysql' is the only valid option at this time
#
default['frog']['db']['dbms'] = 'mysql'

#
# Value used to control the installation of DBMS software.
# Set this value to true in order to use Chef to install
# the DMBS software.
#
#  node.set['frog']['db']['install_dbms'] = true
#
default['frog']['db']['install_dbms'] = false

#
# Database Server root account password
#
default['frog']['db']['server_root_password'] = 'MustCh@ng3M3'

#
# The Django database adapter to configure
#
default['frog']['db']['adapter'] = 'mysql'

#
# Database name for the Frog application
#
default['frog']['db']['name'] = 'frog'

#
# Username Frog will use to connect to the database server
#
default['frog']['db']['user'] = 'frog'

#
# Password Frog will use to connect to the database server
#
default['frog']['db']['password'] = 'thisshouldbechanged'

#
# Hostname or IP that is hosting the Frog database
#
default['frog']['db']['host'] = 'localhost'

#
# Port the database server is listening on
#
default['frog']['db']['port'] = 3306

#
# Host identifier used to restrict the Frog account database connection
#
default['frog']['db']['from_host'] = '%'
