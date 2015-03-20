
thunderball "jdk" do
  url "cycle/jdk-7u40-linux-x64.rpm"
end

package "jdk" do
  source node[:thunderball][:storedir] + '/cycle/' + 'jdk-7u40-linux-x64.rpm'
  provider Chef::Provider::Package::Rpm
  action :install
end

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
