require_relative '../app/petrolex'

number_of_cars = 10
fuel_reserve = 30_000
tank_range = (35..70)
level_range = (1...35)
car_delay_range = (1..100)
simulation_speed = 100

Timer.setup(simulation_speed: simulation_speed)

station = Station.new(fuel_reserve: fuel_reserve)
cars = []
car_threads = []

number_of_cars.times do
  cars << Car.new(tank_volume: rand(tank_range),
                  tank_level: rand(level_range))
end

cars.each do |car|
  car_threads << Thread.new do
    Timer.instance.wait(rand(car_delay_range))
    car.try_to_fuel(station)
  end
end

puts "Petrolex Station Simulator has started."
puts "Simulation speed: x#{simulation_speed}"
puts "Fuel reserve: #{station.fuel_reserve}"
puts "Cars to arrive: #{number_of_cars}"
puts

station.open
sleep(1)

Timer.instance.start
car_threads.each(&:join)

total_cars_waiting_seconds = cars.sum(&:seconds_waited)
puts "Results:"
puts "Avg car wait: #{total_cars_waiting_seconds/number_of_cars.to_f} seconds"
puts "Litres left: #{station.fuel_reserve} litres"
puts
puts "Petrolex Station Simulator has ended."
