define :run_coredns do
  cwd = File.dirname(__FILE__)

  template "#{node[:coredns][:confdir]}/Corefile" do
    action :create
    mode '0444'
    source "#{cwd}/Corefile.erb"
    # variables(
    #   consul_domain: consul_domain,
    #   consul_recursors: consul_recursors.join(' ')
    # )
  end

  template '/lib/systemd/system/coredns.service' do
    action :create
    mode '0444'
    source "#{cwd}/coredns.service.erb"
  end

  service 'coredns' do
    action [:enable, :start]
  end
end

run_coredns 'dns'
