#
# Cookbook Name:: zookeeper
# Recipe:: default
#
# Copyright (C) 2013 Cycle Computing LLC
# 
# All rights reserved - Do Not Redistribute
#

include_recipe 'cyclecloud'
heap_size = ZooKeeper::Helpers.heap_size(node[:memory][:total])

node.set[:zookeeper][:xmx] = "#{heap_size}K"
node.set[:zookeeper][:xms] = "#{heap_size}K"

jvm_flags = ["-Xmx#{node[:zookeeper][:xmx]}", "-Xms#{node[:zookeeper][:xmx]}"]

package 'nc'

include_recipe 'thunderball'

thunderball_config 'default' do
  base "s3://com.cyclecomputing.yumrepo.us-east-1"
  username 'AKIAIT77JVICJIOK7EFA'
  password 'buldB+V8GzbcY6tp8o++PGWmrAZnWLPFSH5krnAf'
end

include_recipe 'zookeeper::jdk'

group 'zookeeper' do
  gid 2001
end
  
user 'zookeeper' do
  uid 2001
  gid 2001
  shell '/bin/bash'
end  

thunderball 'zookeeper' do
  url 'cycle/zookeeper-3.4.5.tar.gz'
end

%w{ /opt/zookeeper /opt/zookeeper/logs }.each do |dir|
  directory dir do
    owner 'zookeeper'
    mode 0775
  end
end

bash 'untar zookeeper' do
  code "tar xvzf #{node[:thunderball][:storedir]}/cycle/zookeeper-3.4.5.tar.gz -C /opt/zookeeper"
  not_if { ::File.exists?('/opt/zookeeper/zookeeper-3.4.5') }
end

link '/opt/zookeeper/current' do
  to '/opt/zookeeper/zookeeper-3.4.5'
  owner 'zookeeper'
end

link '/opt/zookeeper/current/logs' do
  to '/opt/zookeeper/logs'
  owner 'zookeeper'
end

unless node[:ec2].nil?
  include_recipe 'zookeeper::ec2'
else
  directory '/opt/zookeeper/current/data' do
    owner 'zookeeper'
    mode 0775
  end
end

bash 'set perms on zookeeper' do
  code "chown -R zookeeper:zookeeper /opt/zookeeper"
end

template '/opt/zookeeper/current/conf/zoo.cfg' do
  source 'zoo.cfg.erb'
  owner 'zookeeper'
end

template '/opt/zookeeper/current/conf/log4j.properties' do
  source 'log4j.properties.erb'
  owner 'zookeeper'
end

template '/etc/init.d/zookeeper' do
  source 'zookeeper.init.erb'
  variables({:jvm_flags => jvm_flags})
  mode 0775
end

file '/opt/zookeeper/current/data/myid' do
  content node[:zookeeper][:id]
  owner 'zookeeper'
end

service 'zookeeper' do
  action [:enable, :start]
end

include_recipe 'cycle-stunnel::server'

stunnel_connection 'zookeeper' do
  accept '2181'
  connect "127.0.0.1:#{node[:zookeeper][:client_port]}"
  notifies :restart, 'service[stunnel]'
end

