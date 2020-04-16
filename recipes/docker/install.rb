%w(
  apt-transport-https
  ca-certificates
  curl
  software-properties-common
).each do |pkg|
  package pkg
end

linux_arch    = case node[:kernel][:machine]
when 'aarch64'
  'arm64'
when 'x86_64'
  'amd64'
end
execute "add-apt-repository -y 'deb [arch=#{linux_arch}] https://download.docker.com/linux/ubuntu bionic stable'" do
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
