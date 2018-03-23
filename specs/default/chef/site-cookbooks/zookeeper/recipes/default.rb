#
# Cookbook Name:: zookeeper
# Recipe:: default
#
# Copyright (C) 2013 Cycle Computing LLC
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'cyclecloud'
include_recipe 'ark'

heap_size = ZooKeeper::Helpers.heap_size(node['memory']['total'])

node.override['zookeeper']['xmx'] = "#{heap_size}K"
node.override['zookeeper']['xms'] = "#{heap_size}K"

user 'zookeeper' do
  shell '/bin/bash'
end

mirror = "http://apache.mirrors.tds.net/zookeeper/"
version = '3.4.11'
checksum = 'f6bd68a1c8f7c13ea4c2c99f13082d0d71ac464ffaf3bf7a365879ab6ad10e84'
zk_url = "#{mirror}/zookeeper-#{version}/zookeeper-#{version}.tar.gz"

%w{ /opt/zookeeper /opt/zookeeper/logs }.each do |dir|
  directory dir do
    owner 'zookeeper'
    mode 0775
    not_if { ::File.exists?(dir) }
  end
end

ark 'zookeeper' do
  url zk_url
  version version
  prefix_root '/opt/zookeeper'
  home_dir '/opt/zookeeper/current'
  checksum checksum
  owner 'zookeeper'
  group 'zookeeper'
end

link '/opt/zookeeper/current' do
  to "/opt/zookeeper/zookeeper-#{version}"
  owner 'zookeeper'
  not_if { ::File.exists?('/opt/zookeeper/current') }
end

link '/opt/zookeeper/current/logs' do
  to '/opt/zookeeper/logs'
  owner 'zookeeper'
  not_if { ::File.exists?('/opt/zookeeper/current/logs') }
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
