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
      station.mounted_pumps.each do |pump|
        Thread.new do
          loop do
            break unless continue_consuming?

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
      report.increase_waiting
    end

    def continue_consuming?
      return true if station.open?

      report.update_unserved(count: waiting.size)
      false
    end

    def fetch_next_car_from_queue
      queue_lock.synchronize do
        cond_var.wait(queue_lock) while waiting.empty?

        car, waiting_since = waiting.shift
        report.decrease_waiting
        waiting_time = timer.current_tick - waiting_since

        [car, waiting_time]
      end
    end

    def process_fueling(pump, car, waiting_time)
      record = pump.fuel(car)
      record[:waiting_time] = waiting_time
      report.add_pumping(record:)
      report.update_reserve(count: station.reserve_reading)
    end
  end
end
