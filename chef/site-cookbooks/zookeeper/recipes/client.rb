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
if node['zookeeper']['members'].empty?
  ZooKeeper::Helpers.wait_for_quorum(node[:zookeeper][:quorum], 30) do
    cluster.search.select {|n| not n['zookeeper'].nil? and n['zookeeper']['ready'] == true }
  end
  members = cluster.search.map  do |n|
    n['hostname']
  end
  members.sort!
end

node.set['zookeeper']['members'] = members
if node[:zookeeper][:members].empty?
  Chef::Log.info("No zookeeper ensemble members found!")
end


file '/etc/profile.d/zookeeper.sh' do
  content <<-EOH
  #!/bin/bash
  export ZOOKEEPER_HOSTS="#{members.join(',')}"
  export ZOOKEEPER_PORT=2181
  EOH
  mode 00755
end

