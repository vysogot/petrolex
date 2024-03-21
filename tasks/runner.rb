# frozen_string_literal: true

require_relative '../app/petrolex'
# require 'rubygems'
require 'pry'

SIMULATION_SPEED = 100
SIMULATION_TICKS = 300
SIMULATION_TICK_STEP = 1

CARS_NUMBER = 10
CARS_TANK_VOLUME_RANGE = (35..70)
CARS_TANK_LEVEL_RANGE = (1...35)
CARS_DELAY_RANGE = (1..10)

QUEUES_NUMBER = 3

STATION_FUEL_RESERVE = 300
STATION_CLOSING_TICK = SIMULATION_TICKS

DISPENSERS_NUMBER = 3
DISPENSER_FUELING_SPEED = 0.5 # seconds per litre

Petrolex::Timer.configure do |timer|
  timer.simulation_speed = SIMULATION_SPEED
  timer.tick_step = SIMULATION_TICK_STEP
end

cars = []
car_threads = []
queues = []
queue_consumer_threads = []
dispensers = []
(1..DISPENSERS_NUMBER).each do |id|
  dispensers << Petrolex::Dispenser.new(
    id:,
    fueling_speed: DISPENSER_FUELING_SPEED
  )
end

station = Petrolex::Station.new(
  fuel_reserve: STATION_FUEL_RESERVE,
  dispensers:
)

station_thread = Thread.new do
  station.open
  Petrolex::Timer.instance.pause_until(STATION_CLOSING_TICK)
  station.close
end

(1..QUEUES_NUMBER).each do |id|
  queues << Petrolex::Queue.new(
    id:,
    station:
  )
end

queues.each do |queue|
  queue_consumer_threads << Thread.new do
    loop do
      queue.consume
      Petrolex::Timer.instance.wait
      break if Petrolex::Timer.instance.over?(SIMULATION_TICKS)
    end
  end
end

CARS_NUMBER.times do
  cars << Petrolex::Car.new(
    plate: Petrolex::CarsAuthority.instance.request_plate,
    tank_volume: rand(CARS_TANK_VOLUME_RANGE),
    tank_level: rand(CARS_TANK_LEVEL_RANGE)
  )
end

queueing_mutex = Mutex.new
cars.each do |car|
  car_threads << Thread.new do
    Petrolex::Timer.instance.pause_until(rand(CARS_DELAY_RANGE))
    queueing_mutex.synchronize { queues.sample.push(car) }
  end
end

puts "Petrolex Station Simulator has started.\n\n"
puts "Simulation speed: x#{SIMULATION_SPEED}"
puts "Closing tick: #{STATION_CLOSING_TICK}\n\n"
puts "Cars to arrive: #{CARS_NUMBER}"
puts "Station fuel reserve: #{station.fuel_reserve}"
puts "Dispenser fueling speed: #{DISPENSER_FUELING_SPEED} litre/second\n\n"
puts 'Tick | Message'
puts '--------------'

Petrolex::Timer.instance.start

station_thread.join
queue_consumer_threads.each(&:join)
car_threads.each(&:join)

Petrolex::Timer.instance.stop

fueled = queues.map(&:fueled).flatten.size
waiting = queues.map(&:waiting).flatten.size
unserved = queues.map(&:unserved).flatten.size

avg_wait_time = station.waiting_times.sum / fueled.to_f
avg_fuel_time = station.fueling_times.sum / fueled.to_f

puts "\nResults:"
puts "Cars served: #{fueled}"
puts "Cars left in queue: #{waiting}"
puts "Cars left the station unserved: #{unserved}\n\n"
puts "Avg wait time: #{avg_wait_time.round(3)} seconds"
puts "Avg fueling time: #{avg_fuel_time.round(3)} seconds"
puts "Fuel left in station: #{station.fuel_reserve} litres\n\n"

puts "\nQueues details:"
queues.each do |queue|
  puts "Queue #{queue.name}"
  puts "Cars served: #{queue.fueled.size}"
  puts "Cars left in queue: #{queue.waiting.size}"
  puts "Cars left the station unserved: #{queue.unserved.size}\n\n"
end

puts 'Petrolex Station Simulator has ended.'
