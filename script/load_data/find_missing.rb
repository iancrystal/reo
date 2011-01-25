#require 'yaml'

File.open("missing.log","w") do |missing|

  for i in 15544..953145
    puts i
    begin
      a = Agent.find(i)
    rescue
      puts "#{i} is missing"
      missing.puts "#{i} is missing"
    end
  end
end
