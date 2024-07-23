# frozen_string_literal: true

module Petrolex
  # Manages cars in a station
  class Queue
    attr_reader :station, :queue_lock, :waiting, :cond_var, :report_lock, :report

    def initialize(station:)
      @station = station
      @queue_lock = Mutex.new
      @report_lock = Mutex.new
      @cond_var = ConditionVariable.new
      @report = Report.new
      @waiting = []
    end

    def push(car)
      return unless station.open?

      queue_lock.synchronize do
        waiting << car
        Logger.info("#{car} is #{waiting.size} in queue")
        cond_var.signal
      end
    end

    def print_report
      report.data
    end

    def consume
      station.mounted_pumps.each do |pump|
        Thread.new do
          loop do
            unless station.open?
              report.call(record: { status: :unserved, value: waiting.size })
              break
            end

            car = nil
            reserve = nil
            waiting_size = nil

            queue_lock.synchronize do
              while waiting.empty?
                cond_var.wait(queue_lock)
              end

              car = waiting.shift
              reserve = station.reserve
              waiting_size = waiting.size
            end

            state = { reserve:, waiting: waiting_size }
            record = pump.fuel(car)
            report.call(state:, record:)
          end
        end
      end
    end
  end
end
