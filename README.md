frog Cookbook
=============
[![Build Status](http://img.shields.io/travis/nickryand/frog-cookbook.svg)][travis]


[travis]: http://travis-ci.org/nickryand/frog-cookbook
Installs and configures the open source Frog Media Server.

Frog Media Server is an open source project designed to make sharing and maintaining large collections of images and video simple. It exposes an API that allows for easy integration with other applications. The built-in web frontend allows you to manage your media from any platform that supports JavaScript and HTML5.

Documentation: <http://frog.readthedocs.org>

GitHub: <https://github.com/theiviaxx/Frog>

Requirements
------------

* Chef 11.6 or higher

Supported Platforms
-------------------

* Ubuntu 12.04, 14.04
* CentOS 6.4
* Amazon 2014.03

Pull requests for additional platform support are welcome!

Attributes
----------

Attributes are documented in-line. Please see the attributes source files for detailed information about the attributes that are available.

Recipes
-------

### default

Installs the full stack of services needed to run frog on a single machine. This is done by including all 3 of the other recipes provided by this cookbook.

### server

Installs and configures the Frog application and Gunicorn application server.

Frog is a Django application. This cookbook creates a Django project and configures it to run the django-frog app. The Gunicorn server is used to run the Django application managed by runit.

### database

Creates and configures the Frog database.

You can optionally use this cookbook to install the DBMS server binaries for your chosen database by setting `node['frog']['db']['install_dbms']` to true. The `node['frog']['db']['dbms']` attribute is used to control which DBMS system is installed and/or configured. Currently `mysql` is the only valid option.

If you would like to add additional database support, we would welcome the pull request!

*Note:* The community [mysql cookbook](https://github.com/opscode-cookbooks/mysql) is used to install the MySQL server software. Please read that recipes documentation for more information about customizing the MySQL server installation.

### nginx

Installs and configures nginx as a reverse proxy to the Gunicorn application server.

Usage
-----

This cookbook is designed to allow you to run each of the components on a single server, or across multiple servers. You may want to run only the web front end on one node and the database server on another node.  By using a combination of the recipe's you can configure your Frog stack however you like.

If you plan to not run the entire software stack on a single host, be sure to change the applicable attributes so the software can find the required services.

### Single Server

To run the entire Frog stack on a single node, include `recipe[frog::default]` in your run_list.

### Front End App Server and Nginx Reverse Proxy

Include `recipe[frog::server]` and `recipe[frog::nginx]` in your run_list.

**Applicable attributes:**

* `default['frog']['db']['host']`
* `default['frog']['db']['port']`

### Front End App Server Only

Include `recipe[frog::server]` in your run_list.

**Applicable attributes:**

* `default['frog']['db']['host']`
* `default['frog']['db']['port']`

### Reverse Proxy Server Only
Include `recipe[frog::nginx]` to your run_list.

**Applicable attributes:**

* `default['frog']['settings']['media_root']`
* `default['frog']['settings']['static_root']`
* `default['frog']['settings']['url']`

### Database Server Only

Include `recipe[frog::database]` to your run_list.

**Applicable Attributes:**

* `default['frog']['db']['from_host']`
* `default['frog']['db']['install_dbms']`
* `default['frog']['db']['dbms']`

Contributing
------------

1. Fork the repository on Github: <https://help.github.com/articles/fork-a-repo>
2. Clone the repository locally:

    $ git clone http://github.com/nickryand/frog-cookbook.git

3. Create a named feature branch:

    $ cd frog-cookbook
    $ git checkout -b [new feature branch]

4. Add your change(s)
5. Write tests for your change(s):

  You can provide spec and/or integration tests for your changes. Pull requests without changes will sit until someone is able to write tests the verify the changes. This has the added benefit of possibly preventing regressions in the future.

6. Install the gem dependencies:

    bundle install

7. Run the integration and spec tests to ensure they all pass:

    bundle exec rake integration

8. Run the style tests to ensure they all pass:

    bundle exec rake style

9. Update the README.md with new information if applicable.
10. Commit and push your changes up to your feature branch
11. Submit a Pull Request

License and Authors
-------------------
- Author:: Nick Downs (<nickryand@gmail.com>)

```text
Copyright (C) 2014 Nick Downs

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
