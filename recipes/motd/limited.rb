motd_path = '/etc/update-motd.d'

execute 'limit motd' do
  command "chmod -x #{motd_path}/*"
  only_if "test -x #{motd_path}/97-overlayroot"
end

file "#{motd_path}/00-header" do
  action :edit
  mode '0755'
  block do |content|
    # no change
  end
end
