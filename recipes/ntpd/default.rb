package 'ntp'
cwd = File.dirname(__FILE__)

template '/etc/ntp.conf' do
  action :create
  mode '0644'
  source "#{cwd}/templates/ntp.conf.erb"
  notifies :restart, 'service[ntp]'
end

service 'ntp' do
  action :nothing
end
