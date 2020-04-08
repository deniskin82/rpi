node_type = node[:role] || 'aio'
ubuntu_ver = node[:versions][:ubuntu]
ubuntu_img = "ubuntu-#{ubuntu_ver}-preinstalled-server-arm64+raspi3.img".chomp
ubuntu_url = "http://cdimage.ubuntu.com/releases/#{ubuntu_ver}/release/#{ubuntu_img}.xz".chomp
local_image = "#{ENV['HOME']}/Downloads/#{ubuntu_img}"
local_archive = "#{ENV['HOME']}/Downloads/#{ubuntu_img}.xz"
loop_dev = '/tmp/loop_dev'

package 'xz-utils'
package 'kpartx'
package 'curl'

http_request "#{local_archive}" do
  url "#{ubuntu_url}"
  not_if "test -f #{local_archive}"
end

execute 'decompress image' do
  command "xz -T0 -k -d #{local_archive}"
  not_if "test -f #{local_image}"
end

local_ruby_block 'mount image' do
  block do
    run_command("set -euf -o pipefail; kpartx -a -v #{local_image} | egrep 'p1 ' | cut -d ' ' -f3 | sed 's/p1$//' | tee #{loop_dev}")
  end
end

execute 'mount boot' do
  command "LOOPDEV=$(cat #{loop_dev}); udisksctl mount -b /dev/mapper/${LOOPDEV}p1"
end

execute 'mount root' do
  command "LOOPDEV=$(cat #{loop_dev}); udisksctl mount -b /dev/mapper/${LOOPDEV}p2"
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
  command "LOOPDEV=$(cat #{loop_dev}); udisksctl unmount -b /dev/mapper/${LOOPDEV}p1"
  only_if "LOOPDEV=$(cat #{loop_dev}); udisksctl info -b /dev/mapper/${LOOPDEV}p1"
end

execute 'unmount root' do
  command "LOOPDEV=$(cat #{loop_dev}); udisksctl unmount -b /dev/mapper/${LOOPDEV}p2"
  only_if "LOOPDEV=$(cat #{loop_dev}); udisksctl info -b /dev/mapper/${LOOPDEV}p2"
end

execute 'delete loop device' do
  command "LOOPDEV=$(cat #{loop_dev}); kpartx -d -v /dev/${LOOPDEV}; rm -f #{loop_dev}"
end
