# frozen_string_literal: true

require_relative '../app/petrolex'

number_of_cars = 10
fuel_reserve = 30_000
tank_range = (35..70)
level_range = (1...35)
car_delay_range = (10..100)
simulation_speed = 1000
closing_tick = 2000

Timer.configure do |timer|
  timer.simulation_speed = simulation_speed
end

# TODO: problem with starting with a closed station
station = Station.new(closing_tick:, fuel_reserve:, is_open: true)
cars = []
car_threads = []

number_of_cars.times do
  cars << Car.new(tank_volume: rand(tank_range),
                  tank_level: rand(level_range))
end

cars.each do |car|
  car_threads << Thread.new do
    Timer.instance.pause_until(rand(car_delay_range))
    car.queue_up(station)
  end
end

puts 'Petrolex Station Simulator has started.'
puts "Simulation speed: x#{simulation_speed}"
puts "Fuel reserve: #{station.fuel_reserve}"
puts "Cars to arrive: #{number_of_cars}"
puts

Timer.instance.start

station.open
car_threads.each(&:join)

total_cars_waiting_time = station.waiting_times.sum
number_of_cars_fueled = number_of_cars - station.queue.size
avg_time = total_cars_waiting_time / number_of_cars_fueled.to_f

puts
puts 'Results:'
puts "Cars served: #{station.waiting_times.size}"
puts "Cars left: #{station.queue.size}"
puts "Avg car wait: #{avg_time.round(3)} seconds"
puts "Litres left: #{station.fuel_reserve} litres"
puts
puts 'Petrolex Station Simulator has ended.'
