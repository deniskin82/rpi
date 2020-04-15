define :run_monit do
  cwd = File.dirname(__FILE__)
  monit_datadir = node[:monit][:datadir]
  monit_confdir = node[:monit][:confdir]
  monit_homedir = node[:monit][:homedir]
  monit_eventsdir = node[:monit][:eventsdir]
  templates_dir = "#{cwd}/templates"

  directory "#{monit_confdir}"

  directory "#{monit_datadir}"

  directory "#{monit_eventsdir}"

  template '/etc/monitrc' do
    action :create
    source "#{templates_dir}/monitrc.erb"
  end

  template '/lib/systemd/system/monit.service' do
    action :create
    mode '0444'
    source "#{templates_dir}/monit.service.erb"
  end

  file "#{monit_confdir}/sshd.conf" do
    content ::File.read("#{templates_dir}/sshd.conf.erb")
    only_if 'systemctl --type=service | grep -q ssh.'
    notifies :reload, 'service[monit]', :delayed
  end

  file "#{monit_confdir}/coredns.conf" do
    content ::File.read("#{templates_dir}/coredns.conf.erb")
    only_if 'systemctl --type=service | grep -q coredns.'
    notifies :reload, 'service[monit]', :delayed
  end

  service 'monit' do
    action [:enable, :start]
  end
end

run_monit 'monit'
