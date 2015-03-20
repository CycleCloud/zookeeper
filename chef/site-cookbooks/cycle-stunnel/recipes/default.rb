# we require version 4.56, only available from source
node.set[:stunnel][:install_method] = 'source'
node.set[:stunnel][:source_download] = 'https://s3.amazonaws.com/com.cyclecomputing.yumrepo.us-east-1/public/stunnel-4.56.tar.gz'

node.set[:stunnel][:user] = "stunnel"
node.set[:stunnel][:group] = "stunnel"

directory '/etc/stunnel'

group 'stunnel4' do
  gid 5001
end

user 'stunnel4' do
  uid 5001
  gid 5001
end

node.set[:stunnel][:user] = "stunnel4"
node.set[:stunnel][:group] = "stunnel4"
node.set[:stunnel][:fips] = 'no'
node.set[:stunnel][:delay] = 'no'
node.set[:stunnel][:verify] = '2'
node.set[:stunnel][:certificate_path] = '/etc/stunnel/cycle.pem'
node.set[:stunnel][:ca_file] = '/etc/stunnel/cycle.pem'
node.set[:stunnel][:ca_path] = '/etc/stunnel'
node.set[:stunnel][:timeout_connect] = '2'
node.set[:stunnel][:session_cache_timeout] = '1024'
node.set[:stunnel][:session_cache_size] = '3600'
node.set[:stunnel][:ssl_version] = 'SSLv3'

cookbook_file 'cycle.pem' do
  path "/etc/stunnel/cycle.pem"
  mode 0600
  owner 'root'
end

include_recipe 'stunnel::default'
