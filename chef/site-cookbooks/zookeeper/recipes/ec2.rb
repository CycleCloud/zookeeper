
# this will format the ephemeral volumes for us

directory '/mnt/zk_data' do
  owner 'zookeeper'
  group 'zookeeper'
end

link '/opt/zookeeper/current/data' do
  to '/mnt/zk_data'
  owner 'zookeeper'
end

node.set[:zookeeper][:ready] = true
node.set[:cyclecloud][:discoverable] = true

if node[:zookeeper][:members].empty?
  cluster = Chef::Recipe.class_variable_get("@@cluster".to_sym)
  ZooKeeper::Helpers.wait_for_quorum(node[:zookeeper][:quorum], 30) do
    cluster.search.select {|n| not n[:zookeeper].nil? and n[:zookeeper][:ready] == true }
  end
  members = cluster.search.map  do |n|
    n[:ec2][:public_hostname]
  end
  members.sort!
end

node.set[:zookeeper][:members] = members
node.set[:zookeeper][:id] = "#{node[:zookeeper][:members].index(node[:ec2][:public_hostname]) + 1}"
