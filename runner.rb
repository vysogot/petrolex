require_relative 'app'

station = Station.new(fuel_reserve: 30_000)
threads = []
cars = []

10.times do
  cars << Car.new(tank_volume: rand(35..70),
                  tank_level: rand(1...35))
end

cars.each do |car|
  threads << Thread.new { car.try_to_fuel(station) }
end

puts "Petrolex Station Simulator has started."
puts "Fuel reserve: 30'000"
puts "Cars in queue: 10"
puts

threads.each(&:join)
total_cars_waiting_seconds = cars.sum(&:seconds_waited)

puts "Result: car waits #{total_cars_waiting_seconds/10.0} seconds on avarage."
puts "#{station.fuel_reserve} litres left in station reserve."
puts "Petrolex Station Simulator has ended."
