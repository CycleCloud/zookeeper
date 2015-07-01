#
# Cookbook Name:: zookeeper
# Recipe:: server
#
# Copyright (C) 2013 Cycle Computing LLC
# 
# All rights reserved - Do Not Redistribute
#
include_recipe 'zookeeper::default'

directory '/mnt/zk_data' do
  owner 'zookeeper'
  group 'zookeeper'
end

if node['zookeeper'].nil?
  node.set['zookeeper'] = Mash.new()
  node.set['zookeeper']['services'] = []
  node.set['zookeeper']['quorum'] = 3
end



link '/opt/zookeeper/current/data' do
  to '/mnt/zk_data'
  owner 'zookeeper'
end

node.set['zookeeper']['ready'] = true
node.set['cyclecloud']['discoverable'] = true

if node['zookeeper']['members'].empty?
  cluster = Chef::Recipe.class_variable_get("@@cluster".to_sym)
  ZooKeeper::Helpers.wait_for_quorum(node[:zookeeper][:quorum], 30) do
    cluster.search.select {|n| not n['zookeeper'].nil? and n['zookeeper']['ready'] == true }
  end
  members = cluster.search.map  do |n|
    n['hostname']
  end
  members.sort!
end

node.set['zookeeper']['members'] = members
node.set['zookeeper']['id'] = "#{node['zookeeper']['members'].index(node['hostname']) + 1}"


file '/opt/zookeeper/current/data/myid' do
  content node[:zookeeper][:id]
  owner 'zookeeper'
end

service 'zookeeper' do
  action [:enable, :start]
end
