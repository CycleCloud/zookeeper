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
  ZooKeeper::Helpers.wait_for_ensemble(node['zookeeper']['ensemble_size'], 30) do
    cluster.search(:clusterUID => cluster_UID).select {|n| not n['zookeeper'].nil? and n['zookeeper']['ready'] == true }
  end
  members = cluster.search(:clusterUID => cluster_UID).select {|n| not n['zookeeper'].nil? and n['zookeeper']['ready'] == true }.map  do |n|
    [n['zookeeper']['id'], n['cyclecloud']['instance']['ipv4']]
  end
  members.sort {|a,b| a[1] <=> b[1]}.reverse
  Chef::Log.info "ZooKeeper ensemble: #{members.inspect}"
end

node.set['zookeeper']['members'] = members
if node['zookeeper']['members'].empty?
  Chef::Log.info "No zookeeper ensemble members found!"
end

template '/etc/zookeeper/zoo.cfg' do
  source 'zoo.cfg.erb'
  owner 'zookeeper'
end

link '/opt/zookeeper/current/conf/zoo.cfg' do
  to '/etc/zookeeper/zoo.cfg'
  owner 'zookeeper'
  not_if { ::File.exists?('/opt/zookeeper/current/conf/zoo.cfg') }
end


file '/etc/profile.d/zookeeper.sh' do
  content <<-EOH
  #!/bin/bash
  export ZOOKEEPER_HOSTS="#{members.map{ |n| n[1] }.join(',')}"
  export ZOOKEEPER_PORT=#{node['zookeeper']['client_port']}
  EOH
  mode 00755
end

