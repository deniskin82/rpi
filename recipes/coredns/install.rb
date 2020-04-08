define :install_coredns do
  cwd = File.dirname(__FILE__)
  package 'facter'
  linux_arch      = case node[:kernel][:machine]
  when 'aarch64'
    'arm64'
  when 'x86_64'
    'amd64'
  end
  coredns_version = ENV['COREDNS_VERSION'] || params[:version] || node[:versions][:coredns] || '1.6.9'
  coredns_path    = node[:coredns][:homedir] || '/opt/coredns'
  coredns_user    = node[:coredns][:user] || 'coredns'
  coredns_url     = "https://github.com/coredns/coredns/releases/download/v#{coredns_version}/coredns_#{coredns_version}_linux_#{linux_arch}.tgz"
  coredns_tar     = '/tmp/coredns.tgz'
  coredns_confdir = node[:coredns][:confdir] || "#{coredns_path}/config"

  user "create coredns user" do
    system_user true
    username    "#{coredns_user}"
    home        "#{coredns_path}"
    shell       "/bin/false"
  end

  directory "#{coredns_path}/bin" do
    owner coredns_user
    group coredns_user
    action :create
  end

  directory "#{coredns_confdir}" do
    owner coredns_user
    group coredns_user
    action :create
  end

  http_request "#{coredns_tar}" do
    url "#{coredns_url}"
    not_if "test -e #{coredns_tar}"
  end

  execute 'extract_coredns' do
    command "tar -C #{coredns_path}/bin -zxf #{coredns_tar}"
    not_if "test -e #{coredns_path}/bin/coredns"
  end

  link '/usr/local/sbin/coredns' do
    to "#{coredns_path}/bin/coredns"
  end
end

install_coredns 'dns'
