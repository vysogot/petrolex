# frozen_string_literal: true

require_relative '../app/petrolex'

SIMULATION_SPEED = 100

# CARS
NUMBER_OF_CARS = 5
TANK_VOLUME_RANGE = (35..70)
TANK_LEVEL_RANGE = (1...35)
CAR_DELAY_RANGE = (10..100)

# STATION
FUEL_RESERVE = 100
CLOSING_TICK = 1000

# DISPENSER
FUELING_SPEED = 0.5 # seconds per litre

Timer.configure do |timer|
  timer.simulation_speed = SIMULATION_SPEED
end

cars, car_threads = [], []
dispenser = Dispenser.new(
  fueling_speed: FUELING_SPEED
)
station = Station.new(
  fuel_reserve: FUEL_RESERVE,
  dispenser: dispenser
)
queue = Queue.new(station:)

station_thread = Thread.new do
  station.open
  Timer.instance.pause_until(CLOSING_TICK)
  station.close
end

queue_consumer_thread = Thread.new do
  loop do
    queue.consume
    Timer.instance.wait
    break if station.closed?
  end
end

NUMBER_OF_CARS.times do
  cars << Car.new(
    tank_volume: rand(TANK_VOLUME_RANGE),
    tank_level: rand(TANK_LEVEL_RANGE)
  )
end

cars.each do |car|
  car_threads << Thread.new do
    Timer.instance.pause_until(rand(CAR_DELAY_RANGE))
    queue.push(car)
  end
end

puts "Petrolex Station Simulator has started.\n\n"
puts "Simulation speed: x#{SIMULATION_SPEED}"
puts "Fueling speed: #{FUELING_SPEED} litre/second"
puts "Fuel reserve: #{station.fuel_reserve}"
puts "Cars to arrive: #{NUMBER_OF_CARS}"
puts "Closing tick: #{CLOSING_TICK}\n\n"

Timer.instance.start

station_thread.join
queue_consumer_thread.join
car_threads.each(&:join)

total_cars_waiting_time = station.waiting_times.sum
number_of_cars_fueled = NUMBER_OF_CARS - station.queue.size
avg_time = total_cars_waiting_time / number_of_cars_fueled.to_f

puts "\nResults:"
puts "Cars served: #{station.waiting_times.size}"
puts "Cars left: #{station.queue.size}"
puts "Avg car wait: #{avg_time.round(3)} seconds"
puts "Litres left in station: #{station.fuel_reserve} litres\n\n"
puts 'Petrolex Station Simulator has ended.'
