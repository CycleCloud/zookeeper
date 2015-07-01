# if node[:platform_family] == "rhel"
#     node.set[:jdk][:package]     = "jdk-7u40-linux-x64.rpm"
#     node.set[:jdk][:version]     = "jdk1.7.0_40"
# else
#     node.set[:jdk][:version] = "jdk1.7.0_21"
#     node.set[:jdk][:package] = "jdk-7u21-linux-x64.gz"
# end
# node.set[:jdk][:scratch_dir] = "/mnt/scratch"


include_recipe 'jdk'

ruby_block 'symlink java commands into place' do
  block do
    require 'fileutils'
    FileUtils.ln_s(::Dir.glob('/usr/java/default/bin/*', '/usr/bin'))
  end
  not_if { ::File.exists? '/usr/bin/java' }
end

file '/etc/profile.d/jdk.sh' do
  content 'export JAVA_HOME=/usr/java/default'
  mode 0755
end
