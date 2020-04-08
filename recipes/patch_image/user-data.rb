ubuntu_ver = '18.04.4'
ubuntu_img = "ubuntu-#{ubuntu_ver}-preinstalled-server-arm64+raspi3.img"
ubuntu_url = "http://cdimage.ubuntu.com/releases/#{ubuntu_ver}/release/#{ubuntu_img}.xz"

package 'xz-utils'
package 'kpartx'

execute 'decompress image' do
  command "xz -k -d #{ENV['HOME']}/Downloads/#{ubuntu_img}.xz"
  not_if "test -f #{ENV['HOME']}/Downloads/#{ubuntu_img}"
end

mapped_dev = run_command("kpartx -a -v #{ENV['HOME']}/Downloads/#{ubuntu_img} | egrep 'p1 ' | cut -d ' ' -f3")
dm = mapped_dev.stdout.chomp
loop_dev = dm.sub(/p1$/,'')

execute 'mount boot' do
  command "udisksctl mount -b /dev/mapper/#{loop_dev}p1"
end

execute 'mount root' do
  command "udisksctl mount -b /dev/mapper/#{loop_dev}p2"
end

local_ruby_block 'sleep for a few' do
  block do
    sleep(3)
  end
end

remote_file "/media/#{ENV['USER']}/system-boot/user-data" do
  source 'files/user-data'
  mode '0644'
end

file "/media/#{ENV['USER']}/writable/etc/cloud/cloud.cfg" do
  action :edit
  block do |content|
    content.gsub!(/^.*scripts-user.*$/, ' - [ scripts-user, always ]')
  end
end

local_ruby_block 'sleep for a few' do
  block do
    sleep(2)
  end
end

execute 'unmount boot' do
  command "udisksctl unmount -b /dev/mapper/#{loop_dev}p1"
  only_if "udisksctl info -b /dev/mapper/#{loop_dev}p1"
end

execute 'unmount root' do
  command "udisksctl unmount -b /dev/mapper/#{loop_dev}p2"
  only_if "udisksctl info -b /dev/mapper/#{loop_dev}p2"
end

execute "kpartx -d -v /dev/#{loop_dev}"
