
if node[:zookeeper][:client][:discovery_mechanism] == 'blackboard'
  ensemble_members = ZooKeeper::Helpers.ensemble_members({:clusterUID => :all})
elsif node[:zookeeper][:client][:discovery_mechanism] == 'adstore'
  if node[:zookeeper][:client][:adstore_url]
    adstore_host = node[:zookeeper][:client][:adstore_url]
  else
    adstore_host = node[:ec2][:userdata][:user_data][:config][:webServer]
  end
  ensemble_members = ZooKeeper::Helpers.query_adstore(adstore_host, node[:cycle_server][:admin][:name], node[:cycle_server][:admin][:pass])
elsif node[:zookeeper][:members].empty?
  Chef::Log.info("No zookeeper ensemble members found!")
end

connections = ensemble_members.map {|m| "#{m}:2181" }
connections = connections.shuffle

include_recipe 'cycle-stunnel' unless connections.empty?

connections.each_with_index do |connection,index|
  stunnel_connection "zookeeper#{index}" do
    accept "#{2181 + index}"
    connect connection
    notifies :restart, 'service[stunnel]'
  end
end
