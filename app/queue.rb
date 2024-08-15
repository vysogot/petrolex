# frozen_string_literal: true

module Petrolex
  # Manages cars in a station
  class Queue
    attr_reader :station, :queue_lock, :waiting, :cond_var, :report

    def initialize(station:)
      @station = station
      @queue_lock = Mutex.new
      @cond_var = ConditionVariable.new
      @report = Report.new
      @waiting = []
    end

    def push(car)
      return unless station.open?

      queue_lock.synchronize do
        waiting << [car, Timer.instance.current_tick]
        report.increase_waiting
        Logger.info("#{car} is #{waiting.size} in queue")
        cond_var.signal
      end
    end

    def consume
      station.mounted_pumps.each do |pump|
        Thread.new do
          loop do
            unless station.open?
              report.update_unserved(count: waiting.size)

              break
            end

            car = nil
            waiting_size = nil
            waiting_since = nil
            waiting_time = nil

            queue_lock.synchronize do
              cond_var.wait(queue_lock) while waiting.empty?

              car, waiting_since = waiting.shift
              waiting_time = Timer.instance.current_tick - waiting_since
              report.decrease_waiting
              waiting_size = waiting.size
            end

            record = pump.fuel(car)
            record[:waiting_time] = waiting_time
            report.add_pumping(record:)
            report.update_reserve(count: station.reserve_reading)
          end
        end
      end
    end
  end
end
