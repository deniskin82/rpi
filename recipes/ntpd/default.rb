package 'ntp'

template '/etc/ntp.conf' do
  action :create
  mode '0644'
  source "#{cwd}/templates/ntp.conf.erb"
  notifies :restart, 'service[ntp]'
end

service 'ntp' do
  action :nothing
end
