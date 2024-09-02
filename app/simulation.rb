# frozen_string_literal: true

module Petrolex
  class Simulation
    attr_reader :logger, :timer

    def initialize(name:, timer:, logger:, report: nil)
      @name = name
      @timer = timer
      @logger = logger
      @report = report

      @cars_number = 100
      @cars_volume_range = (35..70)
      @cars_level_range = (1...35)
      @cars_delay_interval_range = (0..2)
      @station_fuel_reserve = 1_700
      @station_closing_tick = 3000
      @pumps_number_range = (10..30)
      @pumps_speed_range = (30..50)
    end

    def configure
      yield(self)
    end

    def run
      start_time = clock_monotonic
      logger.print intro
      timer.start
      threads.each(&:join)
      timer.stop
      logger.print outro
      finish_time = clock_monotonic

      logger.print "Simulation took #{(finish_time - start_time).round(6)} seconds"
    end

    def intro
      <<~INTRO
        #{name} has started.\n
        Simulation speed: x#{timer.speed}
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
        Cars left in queue: #{report.waiting_count}\n
        Fuel left in station: #{report.reserve} litres
        Fuel pumped in cars: #{report.fuel_given} litres\n
        Avg waiting time: #{report.avg_waiting_time} seconds
        Avg fueling time: #{report.avg_fueling_time} seconds
        Avg fueling speed: #{report.avg_fueling_speed} litres per second\n
        #{name} has ended.
      REPORT
    end

    def roadies
      road.roadies
    end

    private

    attr_accessor :cars_number, :cars_volume_range, :cars_level_range,
                  :cars_delay_interval_range, :station_fuel_reserve,
                  :station_closing_tick, :pumps_number_range, :pumps_speed_range
    attr_reader :name

    def threads
      [
        station_thread,
        queue_thread,
        car_spawner_thread,
        road_thread,
        report_saver_thread
      ].compact
    end

    def station_thread
      Thread.new do
        station.open
        timer.pause_until(station_closing_tick)
        station.close

        timer.pause_for(1) until station.done?
      end
    end

    def queue_thread
      Thread.new { queue.consume }
    end

    def road
      @road ||= Road.new(queue:)
    end

    def road_thread
      return if true

      Thread.new do
        loop do
          road.refresh
          timer.pause_for(1)
        end
      end
    end

    def car_spawner_thread
      Thread.new do
        random_interval_enumerator.each do |car|
          road.push(car)
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
      @station ||= Station.new(
        simulation: self,
        name: "#{name}-station",
        reserve: station_fuel_reserve,
        pumps:
      )
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
      @report ||= Report.new(name:)
    end

    def build_car
      plate = Plater.instance.request_plate
      volume = rand(cars_volume_range)
      level = rand(cars_level_range)

      Car.new(plate:, volume:, level:)
    end

    def random_interval_enumerator
      Enumerator.new do |enum|
        cars_number.times do
          break if station.done?

          delay = SecureRandom.random_number(cars_delay_interval_range)
          timer.pause_for(delay)
          enum.yield(build_car)
        end
      end
    end

    def pumps_print
      pumps.map(&:speed).sort.join(', ')
    end

    def clock_monotonic
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end
