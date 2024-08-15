# frozen_string_literal: true

module Petrolex
  class Report
    attr_reader :sheet, :nodes, :links

    def initialize
      @lock = Mutex.new
      @sheet = { full: [], partial: [], none: [], waiting: 0, unserved: 0}
    end

    def increase_waiting
      sheet[:waiting] += 1
    end

    def decrease_waiting
      sheet[:waiting] -= 1
    end

    def update_unserved(count:)
      sheet[:unserved] = count
    end

    def update_reserve(count:)
      sheet[:reserve] = count
    end

    def add_pumping(record:)
      lock.synchronize do
        status = record.delete(:status)
        sheet[status] << record
      end
    end

    def full = sheet[:full]
    def partial = sheet[:partial]
    def none = sheet[:none]
    def unserved_count = sheet[:unserved]
    def waiting_count = sheet[:waiting]
    def reserve = sheet[:reserve]

    def full_count = full.size
    def partial_count = partial.size
    def none_count = none.size
    def visitors_count = [full_count, partial_count, none_count].sum

    def served
      [full, partial].flatten
    end

    def fuel_given
      served.sum { |record| record[:units_given] }
    end

    def total_fueling_time
      served.sum { |record| record[:fueling_time] }
    end

    def avg_fueling_time
      (total_fueling_time.to_f / served.size).round(2)
    end

    def avg_fueling_speed
      (total_fueling_time.to_f / fuel_given).round(2)
    end

    private

    attr_reader :lock
  end
end
