# frozen_string_literal: true

module Petrolex
  # Manages cars in a station
  class Queue
    attr_reader :station, :condition, :waiting, :report

    def initialize(station:, report:)
      @station = station
      @report = report
      @condition = Async::Condition.new
      @waiting = []
    end

    def push(car)
      return unless station.open?

      add_car_to_queue(car)
      logger.info("#{car} is #{waiting.size} in queue")
      condition.signal
    end

    def signal_close
      station.mounted_pumps.size.times { condition.signal }
    end

    def consume
      barrier = Async::Barrier.new
      station.mounted_pumps.each do |pump|
        barrier.async do
          loop do
            car, waiting_time = fetch_next_car_from_queue
            break if car.nil?

            process_fueling(pump, car, waiting_time)
          end
        end
      end
      barrier.wait
    ensure
      barrier.stop
    end

    private

    def timer = station.timer
    def logger = station.logger

    def add_car_to_queue(car)
      waiting << [car, timer.current_tick]
      record = { status: :waiting, car: }
      report.for(station_name: station.name).add_record(record:)
    end

    def fetch_next_car_from_queue
      while waiting.empty?
        return nil unless station.open?

        condition.wait
      end

      car, waiting_since = waiting.shift
      record = { status: :waiting, car: }
      report.for(station_name: station.name).remove_record(record:)
      waiting_time = timer.current_tick - waiting_since

      [car, waiting_time]
    end

    def process_fueling(pump, car, waiting_time)
      pre_record = { status: :being_served, car: }
      report.for(station_name: station.name).add_record(record: pre_record.dup)

      record = pump.fuel(car)

      record[:waiting_time] = waiting_time
      report.for(station_name: station.name).add_record(record:)
      report.for(station_name: station.name).remove_record(record: pre_record)
      report.for(station_name: station.name).update_reserve(count: station.reserve_reading)
    end
  end
end
