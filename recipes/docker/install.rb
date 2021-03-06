family_name = case node[:platform_version]
when '20.04'
  'focal'
when '18.04'
  'bionic'
when '16.04'
  'xenial'
end

linux_arch    = case node[:kernel][:machine]
when 'aarch64'
  'arm64'
when 'x86_64'
  'amd64'
end

%w(
  apt-transport-https
  ca-certificates
  curl
  software-properties-common
).each do |pkg|
  package pkg
end

execute "add-apt-repository -y 'deb [arch=#{linux_arch}] https://download.docker.com/linux/ubuntu #{family_name} stable'" do
  not_if 'grep -q docker /etc/apt/sources.list'
  notifies :run, 'execute[apt-get update]', :immediately
end

execute 'apt-get update' do
  action :nothing
end

%w(
  docker-ce
).each do |pkg|
  package pkg
end
