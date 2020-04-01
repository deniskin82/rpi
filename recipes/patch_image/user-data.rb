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

execute 'mount mapped_dev' do
  command "udisksctl mount -b /dev/mapper/#{dm}"
end

remote_file "/media/#{ENV['USER']}/system-boot/user-data" do
  source 'files/user-data'
  mode '0644'
end

execute 'unmount mapped_dev' do
  command "udisksctl unmount -b /dev/mapper/#{dm}"
  only_if "udisksctl info -b /dev/mapper/#{dm}"
end

execute "kpartx -d -v /dev/#{dm.sub(/p1$/,'')}"
