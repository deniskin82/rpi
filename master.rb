node[:role] = 'master'
include_recipe('recipes/ntpd/default.rb')
include_recipe('recipes/motd/limited.rb')
include_recipe('recipes/monit/install.rb')
include_recipe('recipes/coredns/install.rb')
include_recipe('recipes/coredns/run.rb')
include_recipe('recipes/monit/run.rb')
