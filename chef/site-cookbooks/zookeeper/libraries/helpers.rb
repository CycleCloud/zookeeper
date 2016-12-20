module ZooKeeper
  class Helpers

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
        n[:cyclecloud][:instance][:ipv4]
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
