require_relative '../spec_helper'

describe 'frog::_packages' do
  let(:dag_url)    { 'http://fake/dag/url' }
  let(:dag_gpg)    { 'http://fake/dag/gpg' }
  let(:centos_url) { 'http://fake/centos/url' }
  let(:centos_gpg) { 'http://fake/centos/gpg' }
  let(:ffmpeg_url) { 'http://fake/ffmpeg/ppa' }
  let(:ffmpeg_key) { 'http://fake/ffmpeg/key' }

  context 'using redhat' do
    cached(:chef_run) do
      ChefSpec::Runner.new(platform: 'redhat', version: '6.4') do |node|
        node.set['frog']['yum']['dag']['url'] = dag_url
        node.set['frog']['yum']['dag']['gpgkey'] = dag_gpg
      end.converge(described_recipe)
    end

    it 'configs the dag repository' do
      expect(chef_run).to create_yum_repository('dag')
        .with_baseurl(dag_url)
        .with_gpgkey(dag_gpg)
        .with_enabled(false)
    end

    it 'does not create the centos repository' do
      expect(chef_run).to_not create_yum_repository('centos')
    end

    it 'installs the proper packages' do
      expect(chef_run).to install_package('ffmpeg')
        .with_options('--enablerepo=dag')
      expect(chef_run).to install_package('libjpeg-turbo-devel')
      expect(chef_run).to install_package('libtiff-devel')
      expect(chef_run).to install_package('libpng-devel')
    end
  end

  context 'using amazon linux' do
    cached(:chef_run) do
      ChefSpec::Runner.new(platform: 'amazon', version: '2014.03') do |node|
        node.set['frog']['yum']['dag']['url'] = dag_url
        node.set['frog']['yum']['dag']['gpgkey'] = dag_gpg
        node.set['frog']['yum']['centos']['url'] = centos_url
        node.set['frog']['yum']['centos']['gpgkey'] = centos_gpg
      end.converge(described_recipe)
    end

    it 'configs the dag repository' do
      expect(chef_run).to create_yum_repository('dag')
        .with_baseurl(dag_url)
        .with_gpgkey(dag_gpg)
        .with_enabled(false)
    end

    it 'configs the centos repository' do
      expect(chef_run).to create_yum_repository('centos')
        .with_baseurl(centos_url)
        .with_gpgkey(centos_gpg)
        .with_enabled(false)
    end

    it 'installs the proper packages' do
      expect(chef_run).to install_package('ffmpeg')
        .with_options('--enablerepo=dag --enablerepo=centos')
      expect(chef_run).to install_package('libjpeg-turbo-devel')
      expect(chef_run).to install_package('libtiff-devel')
      expect(chef_run).to install_package('libpng-devel')
    end
  end

  context 'using ubuntu after precise' do
    cached(:chef_run) do
      ChefSpec::Runner.new(platform: 'ubuntu', version: '14.04') do |node|
        node.set['frog']['apt']['ffmpeg']['url'] = ffmpeg_url
        node.set['frog']['apt']['ffmpeg']['key'] = ffmpeg_key
      end.converge(described_recipe)
    end

    it 'add apt ffmpeg ppa' do
      expect(chef_run).to add_apt_repository('ffmpeg')
        .with_uri(ffmpeg_url)
        .with_distribution('trusty')
        .with_components(['main'])
        .with_keyserver('keyserver.ubuntu.com')
        .with_key(ffmpeg_key)
    end

    it 'installs the proper packages' do
      expect(chef_run).to install_package('ffmpeg')
      expect(chef_run).to install_package('libjpeg-dev')
      expect(chef_run).to install_package('libtiff4-dev')
      expect(chef_run).to install_package('libpng12-dev')
    end
  end

  context 'using ubuntu precise' do
    cached(:chef_run) do
      ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04')
        .converge(described_recipe)
    end

    it 'add apt ffmpeg ppa' do
      expect(chef_run).to_not add_apt_repository('ffmpeg')
    end

    it 'installs the proper packages' do
      expect(chef_run).to install_package('ffmpeg')
      expect(chef_run).to install_package('libjpeg-dev')
      expect(chef_run).to install_package('libtiff4-dev')
      expect(chef_run).to install_package('libpng12-dev')
    end
  end

  context 'using unsupported platform' do
    cached(:chef_run) do
      ChefSpec::Runner.new(platform: 'mac_os_x', version: '10.8.2')
        .converge(described_recipe)
    end

    it 'raises an exception' do
      expect { chef_run }
        .to raise_error(RuntimeError, "`mac_os_x' is not supported!")
    end
  end
end
