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
      station.mounted_pumps.each do |pump|
        Thread.new do
          loop do
            break unless station.open?

            car = nil

            queue_lock.synchronize do
              cond_var.wait(queue_lock) while waiting.empty?

              car = waiting.shift
            end

            result = pump.fuel(car)

            report_lock.synchronize do
              status = result.delete(:status)

              report[status] ||= []
              report[status] << result
            end

            File.open('/Users/jgodawa/Downloads/new/data.json', 'w') do |f|
              f.write [
                { "name": 'reserve', "value": station.reserve },
                { "name": 'cars in queue', "value": waiting.size },
                { "name": 'cars fueled', "value": report[:full]&.size || 0 },
                { "name": 'cars partial', "value": report[:partial]&.size || 0 },
                { "name": 'cars none', "value": report[:none]&.size || 0 }
              ].to_json
            end
          end
        end
      end
    end
  end
end
