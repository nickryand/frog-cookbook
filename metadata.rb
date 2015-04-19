name 'frog'
maintainer 'Nick Downs'
maintainer_email 'nickryand@gmail.com'
license 'MIT'
description 'Installs and configures the Frog Media Server'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0.4'

depends 'database', '~> 4.0.5'
depends 'mysql2_chef_gem', '~> 1.0.1'
depends 'python', '~> 1.4.6'
depends 'openssl', '~> 1.1.0'
depends 'runit', '~> 1.6.0'
depends 'mysql', '~> 6.0.21'
depends 'gunicorn', '~> 1.2.0'
depends 'nginx', '~> 2.7.4'
depends 'chef-sugar', '~> 3.1.0'
depends 'yum', '~> 3.2.2'
depends 'build-essential', '~> 2.0.4'
depends 'apt', '~> 2.4.0'
