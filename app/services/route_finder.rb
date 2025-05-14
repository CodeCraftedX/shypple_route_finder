require 'date'
require 'json'

class RouteFinder
  def initialize(sailings, rates, exchange_rates)
    @sailings = sailings
    @rates = rates
    @exchange_rates = exchange_rates
    @sailing_map = build_sailing_map
    @rate_map = build_rate_map
  end

  def cheapest_direct(origin, destination)
    candidates = @sailings.select do |s|
      s['origin_port'] == origin && s['destination_port'] == destination
    end

    cheapest = candidates.min_by { |s| convert_to_eur(s) }

    cheapest ? [enrich_sailing(cheapest)] : []
  end

  def cheapest(origin, destination)
    puts "Running cheapest method..."
    paths = find_all_paths(origin, destination)
    cheapest_path = paths.min_by { |path| path.map { |s| convert_to_eur(s) }.sum }

    cheapest_path ? cheapest_path.map { |s| enrich_sailing(s) } : []
  end

def fastest(origin, destination)
  paths = find_all_paths(origin, destination)

  fastest_path = paths.min_by do |path|
    departure = Date.parse(path.first['departure_date'])
    arrival = Date.parse(path.last['arrival_date'])
    (arrival - departure).to_i
  end

  fastest_path ? fastest_path.map { |s| enrich_sailing(s) } : []
end

  private

  def build_sailing_map
    map = Hash.new { |h, k| h[k] = [] }
    @sailings.each do |s|
      map[s['origin_port']] << s
    end
    map
  end

  def build_rate_map
    @rates.each_with_object({}) do |r, h|
      h[r['sailing_code']] = r
    end
  end

  def convert_to_eur(sailing)
    rate = @rate_map[sailing['sailing_code']]
    return Float::INFINITY unless rate

    departure_str = Date.parse(sailing['departure_date']).strftime('%Y-%m-%d')
    currency = rate['rate_currency'].downcase
    exchange_rate = @exchange_rates.dig(departure_str, currency)

    return Float::INFINITY unless exchange_rate

    (rate['rate'].to_f / exchange_rate).round(2)
  end

  def enrich_sailing(sailing)
    rate = @rate_map[sailing['sailing_code']]
    {
      origin_port: sailing['origin_port'],
      destination_port: sailing['destination_port'],
      departure_date: sailing['departure_date'].to_s,
      arrival_date: sailing['arrival_date'].to_s,
      sailing_code: sailing['sailing_code'],
      rate: rate ? rate['rate'] : nil,
      rate_currency: rate ? rate['rate_currency'] : nil
    }
  end

  def find_all_paths(origin, destination, visited = {}, current_path = [], all_paths = [])
    return all_paths if visited[origin]

    visited[origin] = true

    @sailing_map[origin].each do |sailing|
      next if visited[sailing['destination_port']]
      next if !current_path.empty? && sailing['departure_date'] < current_path.last['arrival_date']

      new_path = current_path + [sailing]
      if sailing['destination_port'] == destination
        all_paths << new_path
      else
        find_all_paths(sailing['destination_port'], destination, visited.dup, new_path, all_paths)
      end
    end

    all_paths
  end
end
