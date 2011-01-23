# utility to fill in the addr_latlng table
  def fill_in_addr_latlng
    agents = Agent.find(:all, :conditions => "id > 14528")
    #agents = Agent.find(15,17,18)
    agents.each do |agent|
      if ! agent.latlng_good?
        agent.set_latlng!
        if agent.latlng_good?
          puts "#{agent.id} geocode succeeded"
          logger.info("#{agent.id} geocode succeeded")
        else
          puts "#{agent.id} geocode failed"
          logger.info("#{agent.id} geocode failed")
        end
      else
        puts "#{agent.id} geocode already done"
        logger.info("#{agent.id} geocode already done")
      end
    end
  end


# creates a yaml file for migration to production (e.g. heroku)
  def dump_addr_latlng
    File.open("addr_latlng.yml", 'w') do |f|
      geo = AddrLatlng.find(:all)
      geo.each do |g|
        f.puts "#{g.id}:"
        f.puts "  id: #{g.id}"
        f.puts "  agent_id: #{g.agent_id}"
        f.puts "  lat: #{g.lat}"
        f.puts "  lng: #{g.lng}"
      end
    end
  end
