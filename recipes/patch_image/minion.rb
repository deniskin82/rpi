node[:role] = 'minion'
cwd = File.dirname(__FILE__)
include_recipe("#{cwd}/user-data.rb")
