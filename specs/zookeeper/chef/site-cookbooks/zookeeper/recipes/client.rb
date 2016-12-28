#
# Cookbook Name:: zookeeper
# Recipe:: client
#
# Copyright (C) 2013 Cycle Computing LLC
# 
# All rights reserved - Do Not Redistribute
#
include_recipe 'zookeeper::default'


Chef::Log.info "Searching for ZooKeeper ensemble members..."
if node['zookeeper']['client'].nil? or node['zookeeper']['client']['cluster_name'].nil?
  cluster_UID = :all
else
  cluster_UID = node['zookeeper']['client']['cluster_name']
end
Chef::Log.info "Searching for ZooKeeper ensemble in cluster: #{cluster_UID}"
if node['zookeeper']['members'].empty?
  ZooKeeper::Helpers.wait_for_quorum(node['zookeeper']['quorum'], 30) do
    cluster.search(:clusterUID => cluster_UID).select {|n| not n['zookeeper'].nil? and n['zookeeper']['ready'] == true }
  end
  members = cluster.search(:clusterUID => cluster_UID).select {|n| not n['zookeeper'].nil? and n['zookeeper']['ready'] == true }.map  do |n|
    n[:cyclecloud][:instance][:ipv4]
  end
  members.sort!
  Chef::Log.info "ZooKeeper ensemble: #{members.inspect}"
end

node.set['zookeeper']['members'] = members
if node['zookeeper']['members'].empty?
  Chef::Log.info "No zookeeper ensemble members found!"
end


file '/etc/profile.d/zookeeper.sh' do
  content <<-EOH
  #!/bin/bash
  export ZOOKEEPER_HOSTS="#{members.join(',')}"
  export ZOOKEEPER_PORT=2181
  EOH
  mode 00755
end

