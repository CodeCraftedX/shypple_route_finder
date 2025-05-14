require 'json'

# Models imports
require_relative 'models/sailing'
require_relative 'models/rate'
# Services imports
require_relative 'services/route_finder'

puts "Enter Origin :"
origin = gets.strip
puts "Enter Destination :"
destination = gets.strip
puts "Enter Criteria :"
criteria = gets.strip



json_file = File.read('../data/response.json')
data = JSON.parse(json_file)

finder = RouteFinder.new(data['sailings'],data['rates'],data['exchange_rates'])
if criteria == "cheapest-direct"
    result = finder.cheapest_direct(origin,destination)
elsif criteria == "cheapest"
    result = finder.cheapest(origin,destination)    
elsif criteria == "fastest"
    result = finder.fastest(origin,destination)
else
    puts "The criteria does not exist...!"
end

if result
    puts JSON.pretty_generate(result)
else
    puts "Ooops! Invalid input...!"
end
