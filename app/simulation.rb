module Petrolex
  class Simulation
    attr_accessor :cars_number, :cars_volume_range, :cars_level_range,
                  :cars_delay_interval_range, :station_fuel_reserve,
                  :station_closing_tick, :pumps_number_range, :pumps_speed_range

    def initialize
      @cars_number = 100_000
      @cars_volume_range = (35..70)
      @cars_level_range = (1...35)
      @cars_delay_interval_range = (0..1)
      @station_fuel_reserve = 10_000_000
      @station_closing_tick = 100_000
      @pumps_number_range = (40..50)
      @pumps_speed_range = (1..5)
    end

    def configure
      yield(self)
    end

    def station
      @station ||= Station.new(reserve: station_fuel_reserve, pumps:)
    end

    def pumps
      @pumps ||= rand(pumps_number_range).times.map do
        Pump.new(speed: rand(pumps_speed_range))
      end
    end

    def queue
      @queue ||= Queue.new(station:)
    end

    def cars
      @cars ||= cars_number.times.map do
        plate = Plater.instance.request_plate
        volume = rand(cars_volume_range)
        level = rand(cars_level_range)

        Car.new(plate:, volume:, level:)
      end
    end

    def station_thread
      Thread.new do
        station.open
        Timer.instance.pause_until(station_closing_tick)
        station.close

        Timer.instance.pause_for(1) until station.done?
      end
    end

    def queue_thread
      Thread.new { queue.consume }
    end

    def threads
      [
        station_thread,
        queue_thread,
        spawner_thread
      ].flatten
    end

    def spawner_thread
      Thread.new do
        lazy_random_interval_enumerator.each do |car|
          queue.push(car)
        end
      end
    end

    def lazy_random_interval_enumerator
      Enumerator.new do |yielder|
        cars.each do |car|
          break if station.done?

          delay = SecureRandom.random_number(cars_delay_interval_range)
          Timer.instance.pause_for(delay)
          yielder.yield(car)
        end
      end.lazy
    end

    def intro
      <<~INTRO
        Petrolex Station Simulator has started.\n
        Simulation speed: x#{Timer.instance.speed}
        Closing tick: #{station_closing_tick}
        Cars to arrive: #{cars_number}
        Station fuel reserve: #{station.reserve}
        Pumps fueling speeds: #{pumps_print}
        \nTick | Message
        --------------
      INTRO
    end

    def pumps_print
      pumps.map(&:speed).sort.join(', ')
    end

    def report
      # avg_wait_time = station.waiting_times.sum / queue.fueled.size.to_f
      # avg_fuel_time = station.fueling_times.sum / queue.fueled.size.to_f
      # puts "Cars left in queue: #{queue.waiting.size}"
      # puts "Cars left the station unserved: #{queue.unserved.size}\n\n"
      # puts "Avg wait time: #{avg_wait_time.round(3)} seconds"
      # puts "Avg fueling time: #{avg_fuel_time.round(3)} seconds"
      <<~REPORT
        \nResults:
        Cars fully fueled: #{queue.report.fully_fueled}
        Cars partialy fueled: #{queue.report.partially_fueled}
        Cars not fueled due to lack of fuel: #{queue.report.not_fueled}
        Cars not served at all: #{queue.report.unserved}\n
        Fuel left in station: #{queue.report.reserve} litres
        Fuel pumped in cars: #{queue.report.fuel_given} litres\n
        Petrolex Station Simulator has ended.
      REPORT
    end
  end
end
