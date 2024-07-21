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
      @waiting = []
      @report = {}
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
      report
    end

    def consume
      station.pumps.each do |pump|
        Thread.new do
          loop do
            break unless station.open?

            car = nil

            queue_lock.synchronize do
              while waiting.empty?
                cond_var.wait(queue_lock)
              end

              car = waiting.shift
            end

            result = pump.fuel(car)

            report_lock.synchronize do
              status = result.delete(:status)

              report[status] ||= []
              report[status] << result
            end
          end
        end
      end
    end
  end
end
