module Petrolex
  class Simulation
    attr_accessor :ticks, :cars_number, :cars_volume_range,
                  :cars_level_range, :cars_delay_range, :station_fuel_reserve,
                  :station_closing_tick, :pumps_number_range, :pumps_speed_range

    def initialize
      @ticks = 200
      @cars_number = 10
      @cars_volume_range = (35..70)
      @cars_level_range = (1...35)
      @cars_delay_range = (1..300)
      @station_fuel_reserve = 100
      @station_closing_tick = 200
      @pumps_number_range = (1..5)
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
      end
    end

    def queue_thread
      Thread.new { queue.consume }
    end

    def cars_threads
      cars.map do |car|
        Thread.new do
          Timer.instance.pause_until(rand(cars_delay_range))
          queue.push(car)
        end
      end
    end

    def threads
      [
        station_thread,
        queue_thread,
        cars_threads
      ].flatten
    end

    def intro
      <<~INTRO
        Petrolex Station Simulator has started.\n
        Simulation speed: x#{Timer.instance.speed}
        Closing tick: #{station_closing_tick}
        Cars to arrive: #{cars_number}
        Station fuel reserve: #{station.reserve}
        #{pumps_print}
        \nTick | Message
        --------------
      INTRO
    end

    def pumps_print
      pumps.map do |pump|
        "#{pump.id} fueling speed: #{pump.speed} seconds per litre"
      end.join("\n")
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
        Cars served: #{queue.report.sheet[:full]&.size || 0}
        Fuel left in station: #{station.reserve} litres\n
        Report: #{queue.report.sheet.inspect}
        Petrolex Station Simulator has ended.
      REPORT
    end
  end
end
