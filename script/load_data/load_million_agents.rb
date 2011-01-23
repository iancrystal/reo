#require 'yaml'

File.open('yml-list.txt', 'r') do |yl|
  while li = yl.gets
    li.chomp!
    puts li

    yml = File.open("/tmp/yml/zim_realtor_#{li}.yml")
    yp = YAML::load_documents( yml ) { |doc|
    
      #puts "#{doc['id']} #{doc['first_name']} #{doc['last_name']}"
      
      a = Agent.new
    
      a.id = doc['id']
      a.company = doc['company']
      a.email1 = doc['email1']
      a.email2 = doc['email2']
      a.phone1 = doc['phone1']
      a.phone2 = doc['phone2']
      a.fax = doc['fax']
      a.first_name = doc['first_name']
      a.middle_name = doc['middle_name']
      a.last_name = doc['last_name']
      a.suffix = doc['suffix']
      a.physical_address1 = doc['physical_address1']
      a.physical_address2 = doc['physical_address2']
      a.physical_address_city = doc['physical_address_city']
      a.physical_address_state = doc['physical_address_state']
      a.physical_address_zip = doc['physical_address_zip']
    
      a.save!
    }
  end
end
