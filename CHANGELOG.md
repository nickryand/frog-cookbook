## 1.0.3 /2014-08-24

Added an int cast to the port argument for the generate_url() function unless
the port argument is nil.

## 1.0.2 /2014-08-23

Updates to allow running the database on another server. ([@nickryand[])

* Added libmysqlclient packages for each supported OS to the server
  recipe. This allows MySQL-python to properly build when the frog
  database is running on a remote server.
* Reverse proxy fixes which allow you to properly setup Frog to run
  the entire application behind a reverse proxy. Previously it was not
  easy to configure Frog to hand out URL's that pointed to the proxy
  endpoint. That has been resolved.

## 1.0.1 /2014-08-19

Seperated out nginx frog attributes into it's own file.

* Disabled the nginx default site
* Increased Nginx proxy timeouts
* Added an Nginx reload notification to catch config file updates

## 1.0.0 / 2014-07-14

Initial release ([@nickryand][])

<!--- The following link definition list is generated by PimpMyChangelog --->
[@nickryand]: https://github.com/nickryand
