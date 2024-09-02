# frozen_string_literal: true

module Petrolex
  # Manages cars in a station
  class Queue
    attr_reader :station, :queue_lock, :waiting, :cond_var, :report

    def initialize(station:, report:)
      @station = station
      @report = report
      @queue_lock = Mutex.new
      @cond_var = ConditionVariable.new
      @waiting = []
    end

    def push(car)
      return unless station.open?

      queue_lock.synchronize do
        add_car_to_queue(car)
        logger.info("#{car} is #{waiting.size} in queue")
        cond_var.signal
      end
    end

    def consume
      station.mounted_pumps.map do |pump|
        Thread.new do
          loop do
            break unless station.open?

            car, waiting_time = fetch_next_car_from_queue
            process_fueling(pump, car, waiting_time)
          end
        end
      end
    end

    private

    def timer = station.timer
    def logger = station.logger

    def add_car_to_queue(car)
      waiting << [car, timer.current_tick]
      record = { status: :waiting, car: }
      report.for(station:).add_record(record:)
    end

    def fetch_next_car_from_queue
      queue_lock.synchronize do
        cond_var.wait(queue_lock) while waiting.empty?

        car, waiting_since = waiting.shift
        record = { status: :waiting, car: }
        report.for(station:).remove_record(record:)
        waiting_time = timer.current_tick - waiting_since

        [car, waiting_time]
      end
    end

    def process_fueling(pump, car, waiting_time)
      pre_record = { status: :being_served, car: }
      report.for(station:).add_record(record: pre_record.dup)

      record = pump.fuel(car)

      record[:waiting_time] = waiting_time
      report.for(station:).add_record(record:)
      report.for(station:).remove_record(record: pre_record)
      report.for(station:).update_reserve(count: station.reserve_reading)
    end
  end
end
