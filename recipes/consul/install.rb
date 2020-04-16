define :install_consul do
  cwd = File.dirname(__FILE__)
  package 'facter'
  linux_arch      = case node[:kernel][:machine]
  when 'aarch64'
    'arm64'
  when 'x86_64'
    'amd64'
  end
  consul_version = ENV['CONSUL_VERSION'] || params[:version] || node[:versions][:consul] || '1.7.2'
  consul_path    = node[:consul][:homedir] || '/opt/consul'
  consul_user    = node[:consul][:user] || 'consul'
  consul_group   = node[:consul][:group] || 'consul'
  consul_url     = "https://releases.hashicorp.com/consul/#{consul_version}/consul_#{consul_version}_linux_#{linux_arch}.zip"
  consul_zip     = '/tmp/consul.zip'
  consul_confdir = node[:consul][:confdir] || "#{consul_path}/config"
  consul_datadir = node[:consul][:datadir] || "#{consul_path}/data"

  user "create consul user" do
    system_user true
    username    consul_user
    home        "#{consul_path}"
    shell       "/bin/false"
  end

  directory "#{consul_path}/bin" do
    action :create
    owner consul_user
    group consul_group
  end

  directory "#{coredns_confdir}" do
    owner coredns_user
    group consul_group
    action :create
  end

  directory "#{consul_datadir}" do
    action :create
    owner consul_user
    group consul_group
  end

  http_request "#{consul_zip}" do
    url "#{consul_url}"
    not_if "test -e #{consul_zip}"
  end

  execute 'extract_consul' do
    command "unzip -d #{consul_path}/bin #{consul_zip}"
    not_if  "test -e #{consul_path}/bin/consul"
  end

  link '/usr/local/bin/consul' do
    to "#{consul_path}/bin/consul"
  end
end

install_consul 'consul'
