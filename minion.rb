node[:role] = 'minion'
include_recipe('recipes/ntpd/default.rb')
include_recipe('recipes/motd/limited.rb')
include_recipe('recipes/monit/install.rb')
