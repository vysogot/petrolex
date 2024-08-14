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

      report.add_node(station, 1)
    end

    def push(car)
      return unless station.open?

      queue_lock.synchronize do
        waiting << car
        report.add_node(car, 2)
        Logger.info("#{car} is #{waiting.size} in queue")
        cond_var.signal
      end
    end

    def consume
      final_record_given = false

      station.mounted_pumps.each do |pump|
        Thread.new do
          loop do
            unless station.open?
              report.call(record: { status: :unserved, value: waiting.size }) unless final_record_given

              break
            end

            car = nil
            waiting_size = nil

            queue_lock.synchronize do
              cond_var.wait(queue_lock) while waiting.empty?

              car = waiting.shift
              report.add_link(car, station)
              waiting_size = waiting.size
            end

            record = pump.fuel(car)
            state = { reserve: station.reserve_reading, waiting: waiting_size }
            report.call(state:, record:)
            report.remove_node(car)
            report.remove_link(car, station)
          end
        end
      end
    end
  end
end
