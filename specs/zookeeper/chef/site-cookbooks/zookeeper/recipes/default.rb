#
# Cookbook Name:: zookeeper
# Recipe:: default
#
# Copyright (C) 2013 Cycle Computing LLC
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'cyclecloud'
include_recipe 'thunderball'

heap_size = ZooKeeper::Helpers.heap_size(node['memory']['total'])

node.set['zookeeper']['xmx'] = "#{heap_size}K"
node.set['zookeeper']['xms'] = "#{heap_size}K"


user 'zookeeper' do
  shell '/bin/bash'
end

thunderball 'zookeeper' do
  url 'cycle/zookeeper-3.4.6.tar.gz'
end

%w{ /opt/zookeeper /opt/zookeeper/logs }.each do |dir|
  directory dir do
    owner 'zookeeper'
    mode 0775
    not_if { ::File.exists?(dir) }
  end
end

bash 'untar zookeeper' do
  code "tar xvzf #{node['thunderball']['storedir']}/cycle/zookeeper-3.4.6.tar.gz -C /opt/zookeeper"
  not_if { ::File.exists?('/opt/zookeeper/zookeeper-3.4.6') }
end

link '/opt/zookeeper/current' do
  to '/opt/zookeeper/zookeeper-3.4.6'
  owner 'zookeeper'
  not_if { ::File.exists?('/opt/zookeeper/current') }
end

link '/opt/zookeeper/current/logs' do
  to '/opt/zookeeper/logs'
  owner 'zookeeper'
  not_if { ::File.exists?('/opt/zookeeper/current/logs') }
end

bash 'set perms on zookeeper' do
  code "chown -R zookeeper:zookeeper /opt/zookeeper"
end

directory '/etc/zookeeper' do
  owner 'zookeeper'
  group 'zookeeper'
end

template '/etc/zookeeper/log4j.properties' do
  source 'log4j.properties.erb'
  owner 'zookeeper'
end

link '/opt/zookeeper/current/conf/log4j.properties' do
  to '/etc/zookeeper/log4j.properties'
  owner 'zookeeper'
  not_if { ::File.exists?('/opt/zookeeper/current/conf/log4j.properties') }
end
