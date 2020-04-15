define :install_monit do
  cwd = File.dirname(__FILE__)
  package 'facter'
  linux_arch    = case node[:kernel][:machine]
  when 'aarch64'
    'arm64'
  when 'x86_64'
    'x64'
  end
  monit_version = ENV['monit_VERSION'] || params[:version] || node[:versions][:monit] || '5.26.0'
  monit_path    = node[:monit][:homedir] || '/opt/monit'
  monit_url     = "https://mmonit.com/monit/dist/binary/#{monit_version}/monit-#{monit_version}-linux-#{linux_arch}.tar.gz"
  monit_tar     = '/tmp/monit.tgz'
  monit_confdir = node[:monit][:confdir] || "#{monit_path}/config"

  directory "#{monit_path}/bin"

  http_request "#{monit_tar}" do
    url "#{monit_url}"
    not_if "test -e #{monit_tar}"
  end

  execute 'extract_monit' do
    command "tar --strip 1 -C #{monit_path} --wildcards -zxf #{monit_tar} */bin/monit"
    not_if "test -e #{monit_path}/bin/monit"
  end

  link '/usr/local/sbin/monit' do
    to "#{monit_path}/bin/monit"
  end
end

install_monit 'monit'
