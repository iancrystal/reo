require 'rubygems'
require 'geokit'

class FixZipcodesLatlng < ActiveRecord::Migration

  def self.up

    #File.delete("zipcodes.log") if File::exists?("zipcodes.log")
    
    #File.open("zipcodes.log","w") do |log|
    
      fail_count = 0
      prev_fail = false

      #for i in 1..41329
      for i in 10960..41329
        puts i
        #log.puts i
        begin
          z = Zipcode.find(i)
        rescue
          puts "#{i} is missing"
          #log.puts "#{i} is missing"
        end
        g = Geokit::Geocoders::YahooGeocoder.geocode z.zipcode.to_s 
      
        if g
          if (z.lat && z.lng && g.lat && g.lng)
            fail_count = 0
            prev_fail = false

            latdiff = (z.lat - g.lat).abs
            lngdiff = (z.lng - g.lng).abs
            if ( latdiff > 0.0001 || lngdiff > 0.0001 )
              puts "#{z.zipcode} diff: #{latdiff.to_s}, #{lngdiff.to_s}"
              #log.puts "#{z.zipcode} diff: #{latdiff.to_s}, #{lngdiff.to_s}"
              z.lat = g.lat
              z.lng = g.lng
              z.save
            end
          else
            if prev_fail
              fail_count += 1
            else
              prev_fail = true
            end
            exit if fail_count == 5
            puts "z.lat=#{z.lat.to_s}, z.lng=#{z.lng.to_s}, g.lat=#{g.lat.to_s}, g.lng=#{g.lng.to_s}"
            #log.puts "z.lat=#{z.lat.to_s}, z.lng=#{z.lng.to_s}, g.lat=#{g.lat.to_s}, g.lng=#{g.lng.to_s}"
          end
        else
          puts "cannot get geocode for #{z.zipcode.to_s}"
          #log.puts "cannot get geocode for #{z.zipcode.to_s}"
        end
      end
      
    #end

  end

  def self.down
  end
end

