# frozen_string_literal: true

require_relative '../app/petrolex'

SIMULATION_SPEED = 1000

# CARS
NUMBER_OF_CARS = 10
TANK_VOLUME_RANGE = (35..70)
TANK_LEVEL_RANGE = (1...35)
CAR_DELAY_RANGE = (10..100)

# STATION
FUEL_RESERVE = 30_000
CLOSING_TICK = 2_000

Timer.configure do |timer|
  timer.simulation_speed = SIMULATION_SPEED
end

cars, car_threads = [], []
station = Station.new(
  closing_tick: CLOSING_TICK,
  fuel_reserve: FUEL_RESERVE
)

NUMBER_OF_CARS.times do
  cars << Car.new(
    tank_volume: rand(TANK_VOLUME_RANGE),
    tank_level: rand(TANK_LEVEL_RANGE)
  )
end

cars.each do |car|
  car_threads << Thread.new do
    Timer.instance.pause_until(rand(CAR_DELAY_RANGE))
    car.queue_up(station)
  end
end

puts 'Petrolex Station Simulator has started.'
puts "Simulation speed: x#{SIMULATION_SPEED}"
puts "Fuel reserve: #{station.fuel_reserve}"
puts "Cars to arrive: #{NUMBER_OF_CARS}\n\n"

Timer.instance.start

station.open
car_threads.each(&:join)

total_cars_waiting_time = station.waiting_times.sum
number_of_cars_fueled = NUMBER_OF_CARS - station.queue.size
avg_time = total_cars_waiting_time / number_of_cars_fueled.to_f

puts 'Results:'
puts "Cars served: #{station.waiting_times.size}"
puts "Cars left: #{station.queue.size}"
puts "Avg car wait: #{avg_time.round(3)} seconds"
puts "Litres left: #{station.fuel_reserve} litres\n"
puts 'Petrolex Station Simulator has ended.'
