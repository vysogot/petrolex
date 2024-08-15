# frozen_string_literal: true

module Petrolex
  class Simulation
    Timer.configure do |timer|
      timer.speed = 1000
      timer.tick_step = 1
    end

    def initialize
      @cars_number = 10
      @cars_volume_range = (35..70)
      @cars_level_range = (1...35)
      @cars_delay_interval_range = (0..2)
      @station_fuel_reserve = 2_000
      @station_closing_tick = 300
      @pumps_number_range = (1..3)
      @pumps_speed_range = (1..5)
    end

    def configure
      yield(self)
    end

    def run
      Timer.instance.start
      threads.each(&:join)
      Timer.instance.stop
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

    def outro
      <<~REPORT
        \nResults:
        Cars fully fueled: #{report.full_count}
        Cars partialy fueled: #{report.partial_count}
        Cars not fueled due to lack of fuel: #{report.none_count}
        Cars not served at all: #{report.unserved_count}\n
        Fuel left in station: #{report.reserve} litres
        Fuel pumped in cars: #{report.fuel_given} litres\n
        Avg waiting time: #{report.avg_waiting_time} seconds
        Avg fueling time: #{report.avg_fueling_time} seconds
        Avg fueling speed: #{report.avg_fueling_speed} litres per second\n
        Petrolex Station Simulator has ended.
      REPORT
    end

    private

    attr_accessor :cars_number, :cars_volume_range, :cars_level_range,
                  :cars_delay_interval_range, :station_fuel_reserve,
                  :station_closing_tick, :pumps_number_range, :pumps_speed_range

    def threads
      [
        station_thread,
        queue_thread,
        spawner_thread,
        report_saver_thread
      ].flatten
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

    def spawner_thread
      Thread.new do
        random_interval_enumerator.each do |car|
          queue.push(car)
        end
      end
    end

    def report_saver_thread
      Thread.new do
        report_saver = ReportSaver.new
        graph = Graph.new(report:)

        loop do
          stats = graph.columns
          elements = graph.elements

          report_saver.call(stats:, elements:)
          break if station.done?

          sleep(1)
        end
      end
    end

    def station
      @station ||= Station.new(name: 'Station1', reserve: station_fuel_reserve, pumps:)
    end

    def pumps
      @pumps ||= rand(pumps_number_range).times.map do
        Pump.new(speed: rand(pumps_speed_range))
      end
    end

    def queue
      @queue ||= Queue.new(station:, report:)
    end

    def report
      @report ||= Report.new
    end

    def build_car
      plate = Plater.instance.request_plate
      volume = rand(cars_volume_range)
      level = rand(cars_level_range)

      Car.new(plate:, volume:, level:)
    end

    def random_interval_enumerator
      Enumerator.new do |yielder|
        cars_number.times do
          break if station.done?

          delay = SecureRandom.random_number(cars_delay_interval_range)
          Timer.instance.pause_for(delay)
          yielder.yield(build_car)
        end
      end
    end

    def pumps_print
      pumps.map(&:speed).sort.join(', ')
    end
  end
end
