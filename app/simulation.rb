# frozen_string_literal: true

module Petrolex
  class Simulation
    attr_reader :logger, :timer
    attr_accessor :cars_number, :cars_volume_range, :cars_level_range,
                  :cars_delay_interval_range, :station_fuel_reserve, :station_closing_tick,
                  :pumps_number_range, :pumps_speed_range, :lane, :fuel_price,
                  :ascii_art, :finished, :name, :fuel_cost, :pump_base_cost

    def initialize(name:, timer:, logger:, report: nil)
      @name = name
      @timer = timer
      @logger = logger
      @report = report
    end

    def configure
      yield(self)
      self
    end

    def run
      start_time = clock_monotonic
      logger.print intro
      timer.start

      barrier = Async::Barrier.new
      spawn_tasks(barrier:)
      barrier.wait

      timer.stop
      logger.print outro
      finish_time = clock_monotonic

      logger.print "Simulation took #{(finish_time - start_time).round(6)} seconds"
      barrier.stop
      self.finished = true
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
      stats = station_sheet

      <<~REPORT
        \nResults:
        Cars fully fueled: #{stats.full_count}
        Cars partialy fueled: #{stats.partial_count}
        Cars not fueled due to lack of fuel: #{stats.none_count}
        Cars left in queue: #{stats.waiting_count}\n
        Fuel left in station: #{stats.reserve} litres
        Fuel pumped in cars: #{stats.fuel_given} litres\n
        Avg waiting time: #{stats.avg_waiting_time} seconds
        Avg fueling time: #{stats.avg_fueling_time} seconds
        Avg fueling speed: #{stats.avg_fueling_speed} litres per second\n
        #{name} has ended.
      REPORT
    end

    def finished? = finished

    def roadies = road.roadies

    def report
      @report ||= Report.new(name:)
    end

    def station
      @station ||= Station.new(
        simulation: self,
        reserve: station_fuel_reserve,
        name:,
        pumps:,
        fuel_price:,
        fuel_cost:,
        pump_base_cost:
      )
    end

    private

    def station_sheet
      report.for(station_name: station.name)
    end

    def spawn_tasks(barrier:)
      [
        station_task(barrier:),
        queue_task(barrier:),
        car_spawner_task(barrier:),
        road_task(barrier:),
        report_saver_task(barrier:)
      ].compact
    end

    def station_task(barrier:)
      barrier.async do
        station.open
        timer.pause_until(station_closing_tick)
        station.close
        queue.signal_close

        timer.pause_for(1) until station.done?
      end
    end

    def queue_task(barrier:)
      barrier.async { queue.consume }
    end

    def road
      @road ||= Road.new(queue:, lane:)
    end

    def road_task(barrier:)
      return unless ascii_art?

      barrier.async do
        loop do
          break if station.done?

          road.refresh
          timer.pause_for(1)
        end
      end
    end

    def car_spawner_task(barrier:)
      barrier.async do
        cars_enumerator.each do |car|
          ascii_art? ? road.push(car) : queue.push(car)
        end
      end
    end

    def report_saver_task(barrier:)
      barrier.async do
        report_saver = ReportSaver.new
        graph = Graph.new(report:)

        loop do
          report_saver.call(stats: graph.columns, elements: graph.elements)
          break if station.done?

          sleep(1)
        end
      end
    end

    def pumps
      @pumps ||= rand(pumps_number_range).times.map do
        Pump.new(speed: rand(pumps_speed_range))
      end
    end

    def queue
      @queue ||= Queue.new(station:, report:)
    end

    def build_car
      Car.new(
        plate: Plater.instance.request_plate,
        volume: rand(cars_volume_range),
        level: rand(cars_level_range)
      )
    end

    def cars_enumerator
      Enumerator.new do |enum|
        cars_number.times do
          break if station.done?

          timer.pause_for(SecureRandom.random_number(cars_delay_interval_range))
          enum.yield(build_car)
        end
      end
    end

    def pumps_print = pumps.map(&:speed).sort.join(', ')

    def ascii_art? = ascii_art

    def clock_monotonic = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end
end
