# frozen_string_literal: true

module Petrolex
  class Report
    attr_accessor :station_name
    attr_reader :name, :document

    def initialize(name:)
      @name = name
      @lock = Mutex.new
      @document = {}
    end

    def for(station_name:)
      tap do |report|
        report.station_name = station_name
      end
    end

    def sheet
      document[station_name] ||= {
        full: [],
        partial: [],
        none: [],
        waiting: [],
        being_served: []
      }
    end

    def update_reserve(count:)
      sheet[:reserve] = count
    end

    def add_record(record:)
      lock.synchronize do
        status = record.delete(:status)
        sheet[status] << record
      end
    end

    def remove_record(record:)
      lock.synchronize do
        status = record.delete(:status)
        sheet[status].delete_if { |entry| entry[:car] == record[:car] }
      end
    end

    def full = sheet[:full]
    def partial = sheet[:partial]
    def none = sheet[:none]
    def waiting = sheet[:waiting]
    def being_served = sheet[:being_served]
    def reserve = sheet[:reserve]

    def full_count = full.size
    def partial_count = partial.size
    def none_count = none.size
    def waiting_count = waiting.size
    def being_served_count = being_served.size
    def visitors_count = [full_count, partial_count, none_count].sum

    def served
      [full, partial].flatten
    end

    def all
      served + none
    end

    def fuel_given
      served.sum { |record| record[:units_given] }
    end

    def total_fueling_time
      served.sum { |record| record[:fueling_time] }
    end

    def total_waiting_time
      served.sum { |record| record[:waiting_time] }
    end

    def avg_fueling_time
      (total_fueling_time.to_f / served.size).round(2)
    end

    def avg_fueling_speed
      (total_fueling_time.to_f / fuel_given).round(2)
    end

    def avg_waiting_time
      (total_waiting_time.to_f / all.size).round(2)
    end

    private

    attr_reader :lock
  end
end
