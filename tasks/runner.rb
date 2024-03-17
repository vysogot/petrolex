# frozen_string_literal: true

require_relative '../app/petrolex'

SIMULATION_SPEED = 1000

# CARS
NUMBER_OF_CARS = 5
TANK_VOLUME_RANGE = (35..70)
TANK_LEVEL_RANGE = (1...35)
CAR_DELAY_RANGE = (10..100)

# STATION
FUEL_RESERVE = 1000
CLOSING_TICK = 1000

# DISPENSER
FUELING_SPEED = 0.5 # seconds per litre

Petrolex::Timer.configure do |timer|
  timer.simulation_speed = SIMULATION_SPEED
end

cars, car_threads = [], []
dispenser = Petrolex::Dispenser.new(
  fueling_speed: FUELING_SPEED
)
station = Petrolex::Station.new(
  fuel_reserve: FUEL_RESERVE,
  dispenser: dispenser
)
queue = Petrolex::Queue.new(station:)

station_thread = Thread.new do
  station.open
  Petrolex::Timer.instance.pause_until(CLOSING_TICK)
  station.close
end

queue_consumer_thread = Thread.new do
  loop do
    queue.consume
    Petrolex::Timer.instance.wait
    break if station.closed?
  end
end

NUMBER_OF_CARS.times do
  cars << Petrolex::Car.new(
    tank_volume: rand(TANK_VOLUME_RANGE),
    tank_level: rand(TANK_LEVEL_RANGE)
  )
end

cars.each do |car|
  car_threads << Thread.new do
    Petrolex::Timer.instance.pause_until(rand(CAR_DELAY_RANGE))
    queue.push(car)
  end
end

puts "Petrolex Station Simulator has started.\n\n"
puts "Simulation speed: x#{SIMULATION_SPEED}"
puts "Closing tick: #{CLOSING_TICK}\n\n"
puts "Cars to arrive: #{NUMBER_OF_CARS}"
puts "Station fuel reserve: #{station.fuel_reserve}"
puts "Dispenser fueling speed: #{FUELING_SPEED} litre/second\n\n"
puts "Tick | Message"
puts "--------------"

Petrolex::Timer.instance.start

station_thread.join
queue_consumer_thread.join
car_threads.each(&:join)

avg_wait_time = station.waiting_times.sum / queue.fueled.size.to_f
avg_fuel_time = station.fueling_times.sum / queue.fueled.size.to_f

puts "\nResults:"
puts "Cars served: #{queue.fueled.size}"
puts "Cars left in line: #{queue.line.size}"
puts "Cars left the station unserved: #{queue.unserved.size}\n\n"
puts "Avg wait time: #{avg_wait_time.round(3)} seconds"
puts "Avg fueling time: #{avg_fuel_time.round(3)} seconds"
puts "Fuel left in station: #{station.fuel_reserve} litres\n\n"
puts 'Petrolex Station Simulator has ended.'
