module ZooKeeper
  class Helpers

    def self.http_get_xml_response(url, username, passwd)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth(username, passwd)
      http.use_ssl = true if url =~ /https/
      http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
      response = http.request(request)
      xml_doc = REXML::Document.new(response.body)
    end

    def self.query_adstore(host, username, passwd)
      require 'net/http'
      require 'uri'
      require 'rexml/document'

      filter = URI.encode('Template==="ensemble"&&State==="Started"', '&"')
      node_url = %Q{#{host}/ads/Cloud.Node?f=(#{filter})&format=xml}
      xml_doc = http_get_xml_response(node_url, username, passwd)

      zk_instance_ids = []
      xml_doc.elements.each("classads/c") do |e|
        zk_instance_ids << e.elements["a[@n='InstanceId']"].elements['s'].text
      end

      instance_stmt = []

      zk_instance_ids.each do |i|
        instance_stmt << %Q{InstanceId==="#{i}"}
      end

      instance_filter = URI.encode(instance_stmt.join("||"), '&"|')
      
      aws_url = %Q{#{node[:ec2][:userdata][:user_data][:config][:webServer]}/ads/AWS.Instance?f=(#{instance_filter})&format=xml}
      xml_doc = http_get_xml_response(aws_url, username, passwd)

      zk_fqdns = []
      xml_doc.elements.each("classads/c") do |e|
        zk_fqdns << e.elements["a[@n='PublicHostname']"].elements['s'].text
      end

      if zk_fqdns.empty?
        Chef::Log.debug('No zookeeper instances found in the adstore')
      end

      zk_fqdns
    end

    def self.wait_for_quorum(quorum, sleep_time=10, retries=6, &block)
      results = block.call
      retries = 0
      while results.length < quorum and retries < 6
        sleep sleep_time
        retries += 1
        results = block.call
      end
      if retries >= 6
        raise Exception, "Timed out waiting for quorum"
      end
    
    end

    def self.ensemble_members(opts={})
      cluster = Chef::Recipe.class_variable_get("@@cluster".to_sym)
      ensemble_members = cluster.search(opts) do |n|
        n[:zookeeper][:mode] == 'ensemble'
      end
      ensemble_ips = ensemble_members.map do |n|
        n[:ec2][:public_hostname]
      end
      ensemble_ips
    end
    
    def self.heap_size(total_memory)
      # calculate heap_size, which should never be larger than 50% of available RAM
      # should not be > 6 GB
      total_ram = total_memory.to_i
      heap_size = (total_ram * 0.4).to_i
      
      if heap_size > 6000000
        heap_size = 6000000
      end
      heap_size
    end

    def self.new_size(cpu_count)
      # calculate new_size, 50MB per cpu
      new_size = cpu_count.to_i * 50
    end
    
    def self.is_vpc?
      require 'net/http'
      my_mac = Net::HTTP.start('169.254.169.254').get('/latest/meta-data/network/interfaces/macs/').body.split[0]
      interface_details = Net::HTTP.start('169.254.169.254').get("/latest/meta-data/network/interfaces/macs/#{my_mac}").body
      if interface_details.split.include? 'vpc-id'
        true
      else
        false
      end
    end

  end
end
