require_relative 'app'

number_of_cars = 10
fuel_reserve = 30_000
tank_range = (35..70)
level_range = (1...35)
simulation_speed = 1000

station = Station.new(fuel_reserve: fuel_reserve,
                      simulation_speed: simulation_speed)
threads = []
cars = []

number_of_cars.times do
  cars << Car.new(tank_volume: rand(tank_range),
                  tank_level: rand(level_range),
                  simulation_speed: simulation_speed)
end

cars.each do |car|
  threads << Thread.new { sleep(1); car.try_to_fuel(station) }
end

puts "Petrolex Station Simulator has started."
puts "Simulation speed: x#{simulation_speed}"
puts "Fuel reserve: #{station.fuel_reserve}"
puts "Cars in queue: #{number_of_cars}"
puts

threads.each(&:join)
total_cars_waiting_seconds = cars.sum(&:seconds_waited)

puts "Results:"
puts "Avg car wait: #{total_cars_waiting_seconds/number_of_cars.to_f} seconds"
puts "Litres left: #{station.fuel_reserve} litres"
puts
puts "Petrolex Station Simulator has ended."
