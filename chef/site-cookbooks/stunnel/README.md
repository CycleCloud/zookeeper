# stunnel

Chef cookbook to install and configure stunnel

## LWRP

An LWRP is provided for defining stunnel connections. As a client:
```ruby
include_recipe 'stunnel'

stunnel_connection 'random_service' do
  connect "#{rnd_srv_node[:ipaddress]}:#{rnd_srv_node[:random_service][:port]}"
  accept node[:random_service][:local_accept_port]
  notifies :restart, 'service[stunnel]'
end
```

As a server:
```ruby
include_recipe 'stunnel::server'

stunnel_connection 'random_service' do
  accept node[:random_service][:tunnel_port]
  connect node[:random_service][:port]
  notifies :restart, 'service[stunnel]'
end
```

You can pass a single connect string to the `connect` attribute or an array for
multiple connections. The following is an example specifying multiple connections to 
the nodes in a zookeeper cluster

```ruby
stunnel_connection 'zookeeper' do
  accept '2181'
  connect [ 'zk1:2181', 'zk2:2181', 'zk3:2181' ]
  notifies :restart, 'service[stunnel]'
end
```

## Attributes

Lots of configurable attributes:

```ruby

default[:stunnel][:install_method] = 'package'  # the other valid option is 'source'

default[:stunnel][:packages] = %w(stunnel4)
default[:stunnel][:service_name] = 'stunnel4'

default[:stunnel][:ssl_dir] = '/etc/ssl'
default[:stunnel][:server_ssl_req]  = "/C=US/ST=Several/L=Locality/O=Example/OU=Operations/CN=#{node[:fqdn]}/emailAddress=root@#{node[:fqdn]}"
default[:stunnel][:cert_fqdn] = node[:fqdn]

default[:stunnel][:use_chroot] = false
default[:stunnel][:chroot_path] = "/usr/var/lib/stunnel"
default[:stunnel][:pidfile] = "/var/run/stunnel/stunnel.pid"
default[:stunnel][:user] = "root"
default[:stunnel][:group] = "root"

default[:stunnel][:https][:enabled] = false
default[:stunnel][:https][:accept_port] = "443"
default[:stunnel][:https][:connect_port] = "81"

default[:stunnel][:client_mode] = true
default[:stunnel][:failover] = 'rr'

default[:stunnel][:ssl_version] = 'all'
default[:stunnel][:ssl_options] = 'NO_SSLv2'
default[:stunnel][:fips] = nil
default[:stunnel][:socket_tunings] = %w(l:TCP_NODELAY=1 r:TCP_NODELAY=1)
default[:stunnel][:compression] = nil # zlib
default[:stunnel][:debug] = nil # 3
default[:stunnel][:output] = '/var/log/stunnel/stunnel.log'
default[:stunnel][:delay] = nil

# key value pair mapping for default var file
default[:stunnel][:default][:enabled] = 1
default[:stunnel][:default][:files] = '/etc/stunnel/*.conf'
default[:stunnel][:default][:options] = ''

# ssl verification options
default[:stunnel][:verify] = nil
default[:stunnel][:ca_path] = nil
default[:stunnel][:ca_file] = nil
default[:stunnel][:crl_path] = nil
default[:stunnel][:crl_file] = nil

# timeouts
default[:stunnel][:timeout_connect] = nil
default[:stunnel][:session_cache_timeout] = nil
default[:stunnel][:session_cache_size] = nil

```

## Infos
* Repository: https://github.com/hw-cookbooks/stunnel
* IRC: Freenode @ #heavywater