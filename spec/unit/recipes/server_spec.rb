require_relative '../spec_helper'

describe 'frog::server' do

  let(:frog_group)       { 'testgroup' }
  let(:frog_user)        { 'testuser' }
  let(:frog_home)        { '/opt/frog' }
  let(:frog_virtenv)     { "#{frog_home}/env" }
  let(:frog_package)     { 'django-frog-test' }
  let(:frog_version)     { '2.0.0' }
  let(:gunicorn_logdir)  { '/log/gunicorn' }
  let(:gunicorn_workers) { 2 }
  let(:frog_media)       { "#{frog_home}/media" }
  let(:frog_static)      { "#{frog_home}/static" }
  let(:frog_url)         { 'http://127.0.0.1:8000' }
  let(:frog_media_url)   { "#{frog_url}/media" }
  let(:frog_static_url)   { "#{frog_url}/static" }

  cached(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.set['frog']['group'] = frog_group
      node.set['frog']['user'] = frog_user
      node.set['frog']['rootdir'] = frog_home
      node.set['frog']['package_name'] = frog_package
      node.set['frog']['version'] = frog_version
      node.set['frog']['gunicorn']['log_dir'] = gunicorn_logdir
      node.set['frog']['gunicorn']['workers'] = gunicorn_workers
      node.set['frog']['settings']['media_root'] = frog_media
      node.set['frog']['settings']['static_root'] = frog_static
      node.set['frog']['settings']['url'] = frog_url
      node.set['frog']['settings']['media_url'] = frog_media_url
      node.set['frog']['settings']['static_url'] = frog_static_url

      # Workaround until https://github.com/hw-cookbooks/runit/pull/57 is merged.
      node.set[:runit][:sv_bin] = '/usr/bin/sv'
    end.converge(described_recipe)
  end

  before do
    stub_command("#{frog_home}/env/bin/python manage.py list_users | grep root").and_return(false)
    stub_command("which nginx").and_return('/usr/bin/nginx')
    stub_command("Dir.glob(#{frog_home}/lib/python*).first").and_return('python2.7')
    allow_any_instance_of(Chef::Recipe).to receive(:include_recipe)
  end

  it 'installs the git package' do
    expect(chef_run).to install_package('git')
  end

  it 'creates the frog group' do
    expect(chef_run).to create_group(frog_group)
      .with_system(true)
  end

  it 'creates the frog user' do
    expect(chef_run).to create_user(frog_user)
      .with_system(true)
      .with_home(frog_home)
      .with_group(frog_group)
      .with_shell('/bin/none')
  end

  it 'creates the frog root directory' do
    expect(chef_run).to create_directory(frog_home)
      .with_owner(frog_user)
      .with_group(frog_group)
      .with_mode(0755)
      .with_recursive(true)
  end

  it 'sets up the proper python virtualenv' do
    expect(chef_run).to create_directory(frog_virtenv)
      .with_owner(frog_user)
      .with_group(frog_group)
      .with_mode(0755)
      .with_recursive(true)

    expect(chef_run).to create_python_virtualenv(frog_virtenv)
  end

  it 'installs the proper python packages' do
    expect(chef_run).to install_python_pip('django-frog')
      .with_version(frog_version)
      .with_virtualenv(frog_virtenv)
      .with_package_name(frog_package)

    expect(chef_run).to install_python_pip('MySQL-python')
    expect(chef_run).to install_python_pip('pillow')
  end

  it 'bootstraps the initial django project' do
    expect(chef_run).to run_execute('bootstrap_django_app')
      .with_command("#{frog_virtenv}/bin/django-admin.py startproject webapp")
      .with_cwd(frog_home)
  end

  it 'creates the gunicorn log directory' do
    expect(chef_run).to create_directory(gunicorn_logdir)
      .with_owner(frog_user)
      .with_group(frog_group)
      .with_mode(0755)
      .with_recursive(true)
  end

  it 'should set the gunicorn virtual env to the proper directory' do
    expect(chef_run.node['gunicorn']['virtualenv']).to eq(frog_virtenv)
  end

  it 'should setup the proper gunicorn config file' do
    expect(chef_run).to create_gunicorn_config("#{frog_home}/webapp/gunicorn_frog.py")
      .with_worker_processes(gunicorn_workers)
      .with_owner(frog_user)
      .with_group(frog_group)
      .with_accesslog("#{gunicorn_logdir}/access.log")
      .with_errorlog("#{gunicorn_logdir}/error.log")
  end

  it 'creates the media_root directory properly' do
    expect(chef_run).to create_directory(frog_media)
      .with_owner(frog_user)
      .with_group(frog_group)
      .with_mode(0755)
      .with_recursive(true)
  end

  it 'creates the static_root directory properly' do
    expect(chef_run).to create_directory(frog_static)
      .with_owner(frog_user)
      .with_group(frog_group)
      .with_mode(0755)
      .with_recursive(true)
  end

  # TODO: Figure out how to mock the Dir.glob command
  it 'properly links the media_root into the frog directory' do
    expect(chef_run).to create_link("#{frog_media}/frog")
  end

  # TODO: Figure out how to mock the Dir.glob command
  it 'properly links the static_root into the frog directory' do
    expect(chef_run).to create_link("#{frog_static}/frog")
  end

  # TODO: Figure out how to mock the Dir.glob command
  it 'properly links the django admin static assets into static_root' do
    expect(chef_run).to create_link("#{frog_static}/admin")
  end

  it 'sets a string for secret_key' do
    expect(chef_run.node['frog']['settings']['secret_key']).to_not be_nil
  end

  it 'should generate the proper python settings.py file' do
    expect(chef_run).to create_template("#{frog_home}/webapp/webapp/settings.py")
      .with_owner(frog_user)
      .with_group(frog_group)
      .with_mode(0600)
      .with_variables(
        :db_adapter => 'mysql',
        :db_name => 'frog',
        :db_user => 'frog',
        :db_password => 'thisshouldbechanged',
        :db_host => 'localhost',
        :db_port => 3306,
        :allowed_hosts => ['*'],
        :ffmpeg_exe => '/usr/bin/ffmpeg',
        :url => frog_url,
        :media_url => frog_media_url,
        :media_root => frog_media,
        :static_url => frog_static_url,
        :static_root => frog_static,
        :session_age => 86400,
        :secret_key => chef_run.node['frog']['settings']['secret_key'],
        :debug => 'False'
      )
  end

  it 'should notify restart on the gunicorn runit service if settings.py is updated' do
    resource = chef_run.template("#{frog_home}/webapp/webapp/settings.py")
    expect(resource).to notify('runit_service[gunicorn]').to(:restart).delayed
  end

  it 'creates the urls.py file for the django project' do
    expect(chef_run).to create_template("#{frog_home}/webapp/webapp/urls.py")
      .with_owner(frog_user)
      .with_group(frog_group)
      .with_mode(0644)
  end

  it 'should notify restart on the gunicorn runit service if urls.py is updated' do
    resource = chef_run.template("#{frog_home}/webapp/webapp/urls.py")
    expect(resource).to notify('runit_service[gunicorn]').to(:restart).delayed
  end

  it 'executes the initial syncdb command and touches the .initial file' do
    cmd = "#{frog_virtenv}/bin/python manage.py "
    cmd << "syncdb --noinput --no-initial-data && touch .initial"
    expect(chef_run).to run_execute('frog_initial_syncdb')
      .with_command(cmd)
      .with_creates("#{frog_home}/webapp/.initial")
      .with_cwd("#{frog_home}/webapp")
  end

  init_command = <<-EOF
    $PYBIN manage.py createsuperuser --noinput \
      --username root \
      --email root@localhost && \
    $PYBIN manage.py set_password root thisshouldbechanged && \
    $PYBIN manage.py syncdb --noinput && \
    $PYBIN manage.py migrate
  EOF

  it 'executes the initial user and database setup command' do
    expect(chef_run).to run_execute('frog_initial_setup')
      .with_command(init_command)
      .with_cwd("#{frog_home}/webapp")
      .with_environment('PYBIN' => "#{frog_home}/env/bin/python")
  end

  it 'enables the gunicorn runit service and enables the default_logger' do
    expect(chef_run).to enable_runit_service('gunicorn')
      .with_default_logger(true)
  end
end
