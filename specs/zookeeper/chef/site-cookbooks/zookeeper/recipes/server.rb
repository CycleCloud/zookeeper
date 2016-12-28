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
  not_if { ::File.exists?('/opt/zookeeper/current/data') }
end

node.set['zookeeper']['ready'] = true
node.set['cyclecloud']['discoverable'] = true

if node['zookeeper']['members'].empty?
  cluster = Chef::Recipe.class_variable_get("@@cluster".to_sym)
  ZooKeeper::Helpers.wait_for_quorum(node['zookeeper']['quorum'], 30) do
    cluster.search.select {|n| not n['zookeeper'].nil? and n['zookeeper']['ready'] == true }
  end
  members = cluster.search.select {|n| not n['zookeeper'].nil? and n['zookeeper']['ready'] == true }.map  do |n|
    n[:cyclecloud][:instance][:ipv4]
  end
  members.sort!
  Chef::Log.info "ZooKeeper ensemble: [ #{members.inspect} ]"
end

node.set['zookeeper']['members'] = members
node.set['zookeeper']['id'] = "#{node['zookeeper']['members'].index(node['cyclecloud']['instance']['ipv4']) + 1}"


file '/opt/zookeeper/current/data/myid' do
  content node['zookeeper']['id']
  owner 'zookeeper'
end


jvm_flags = ["-Xmx#{node['zookeeper']['xmx']}", "-Xms#{node['zookeeper']['xmx']}"]

template '/etc/init.d/zookeeper' do
  source 'zookeeper.init.erb'
  variables( :jvm_flags => jvm_flags )
  mode 0775
end

service 'zookeeper' do
  action [:enable, :start]
end

# Pull in the Jetpack LWRP
include_recipe 'jetpack'

monitoring_config = "#{node['cyclecloud']['home']}/config/service.d/zookeeper.json"
file monitoring_config do
  content <<-EOH
  {
    "system": "zookeeper",
    "cluster_name": "#{node['cyclecloud']['cluster']['name']}",
    "hostname": "#{node['cyclecloud']['instance']['public_hostname']}",
    "ports": {"ssh": 22, "zookeeper": 2181}
  }
  EOH
  mode "750"
  not_if { ::File.exist?(monitoring_config) }
end

jetpack_send "Registering ZooKeeper server for monitoring." do
  file monitoring_config
  routing_key "#{node['cyclecloud']['service_status']['routing_key']}.zookeeper"
end
