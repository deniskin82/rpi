node[:role] = 'master'
cwd = File.dirname(__FILE__)
include_recipe("#{cwd}/user-data.rb")
