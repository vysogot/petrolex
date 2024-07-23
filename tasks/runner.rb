# frozen_string_literal: true

require_relative '../app/petrolex'

SIMULATION_SPEED = 100
SIMULATION_TICKS = 5000
SIMULATION_TICK_STEP = 1

CARS_NUMBER = 290
CARS_VOLUME_RANGE = (35..70)
CARS_LEVEL_RANGE = (1...35)
CARS_DELAY_RANGE = (1..300)

STATION_FUEL_RESERVE = 10000
STATION_CLOSING_TICK = SIMULATION_TICKS

PUMP_SLOW_FUELING_SPEED = 1 # seconds per litre
PUMP_FAST_FUELING_SPEED = 3

Petrolex::Timer.configure do |timer|
  timer.simulation_speed = SIMULATION_SPEED
  timer.tick_step = SIMULATION_TICK_STEP
end

pump1 = Petrolex::Pump.new(speed: PUMP_SLOW_FUELING_SPEED)
pump2 = Petrolex::Pump.new(speed: PUMP_FAST_FUELING_SPEED)
pump3 = Petrolex::Pump.new(speed: PUMP_FAST_FUELING_SPEED)
pump4 = Petrolex::Pump.new(speed: PUMP_FAST_FUELING_SPEED)
pump5 = Petrolex::Pump.new(speed: PUMP_FAST_FUELING_SPEED)
station = Petrolex::Station.new(reserve: STATION_FUEL_RESERVE)
queue = Petrolex::Queue.new(station:)

cars = []
car_threads = []
station.add_pump(pump1)
station.add_pump(pump2)
station.add_pump(pump3)
station.add_pump(pump4)
station.add_pump(pump5)

File.open("/Users/jgodawa/Downloads/new/data.json", "w") do |f|
  f.write [
    { "name": "start reserve", "value": 5000 },
    { "name": "reserve", "value": station.reserve },
    { "name": "cars in queue", "value": 0 },
    { "name": "cars fueled", "value": 0 },
].to_json
end

station_thread = Thread.new do
  station.open
  Petrolex::Timer.instance.pause_until(STATION_CLOSING_TICK)
  station.close
end

queue_consumer_thread = Thread.new { queue.consume }

CARS_NUMBER.times do
  plate = Petrolex::Plater.instance.request_plate
  volume = rand(CARS_VOLUME_RANGE)
  level = rand(CARS_LEVEL_RANGE)

  cars << Petrolex::Car.new(plate:, volume:, level:)
end

cars.each do |car|
  car_threads << Thread.new do
    Petrolex::Timer.instance.pause_until(rand(CARS_DELAY_RANGE))
    queue.push(car)
  end
end

puts "Petrolex Station Simulator has started.\n\n"
puts "Simulation speed: x#{SIMULATION_SPEED}"
puts "Closing tick: #{STATION_CLOSING_TICK}\n\n"
puts "Cars to arrive: #{CARS_NUMBER}"
puts "Station fuel reserve: #{station.reserve}"
station.pumps.each do |pump|
  puts "#{pump.id} fueling speed: #{pump.speed} seconds per litre"
end
puts "\nTick | Message"
puts '--------------'

Petrolex::Timer.instance.start

station_thread.join
queue_consumer_thread.join
car_threads.each(&:join)

Petrolex::Timer.instance.stop

# avg_wait_time = station.waiting_times.sum / queue.fueled.size.to_f
# avg_fuel_time = station.fueling_times.sum / queue.fueled.size.to_f
#
puts "\nResults:"
puts "Cars served: #{queue.report[:full].size}"
# puts "Cars left in queue: #{queue.waiting.size}"
# puts "Cars left the station unserved: #{queue.unserved.size}\n\n"
# puts "Avg wait time: #{avg_wait_time.round(3)} seconds"
# puts "Avg fueling time: #{avg_fuel_time.round(3)} seconds"
puts "Fuel left in station: #{station.reserve} litres\n\n"
puts "Report"
pp queue.report
puts 'Petrolex Station Simulator has ended.'
