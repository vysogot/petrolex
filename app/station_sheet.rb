# frozen_string_literal: true

module Petrolex
  # Holds and computes metrics for one station within a Report
  class StationSheet
    def initialize(document:, station_name:)
      @document = document
      @station_name = station_name
    end

    def update_costs(initial_fuel_cost:, initial_pumps_cost:)
      sheet[:initial_fuel_cost] = initial_fuel_cost
      sheet[:initial_pumps_cost] = initial_pumps_cost
    end

    def update_reserve(count:)
      sheet[:reserve] = count
    end

    def add_record(record:)
      status = record.delete(:status)
      sheet[status] << record
    end

    def remove_record(record:)
      status = record.delete(:status)
      sheet[status].delete_if { |entry| entry[:car] == record[:car] }
    end

    def full          = sheet[:full]
    def partial       = sheet[:partial]
    def none          = sheet[:none]
    def waiting       = sheet[:waiting]
    def being_served  = sheet[:being_served]
    def reserve       = sheet[:reserve] || 0
    def initial_fuel_cost  = sheet[:initial_fuel_cost].round(2)
    def initial_pumps_cost = sheet[:initial_pumps_cost].round(2)

    def full_count         = full.size
    def partial_count      = partial.size
    def none_count         = none.size
    def waiting_count      = waiting.size
    def being_served_count = being_served.size
    def visitors_count     = [waiting_count, full_count, partial_count, none_count].sum

    def served = [full, partial].flatten
    def all    = served + none

    def fuel_given         = served.sum { |r| r[:units_given] }
    def total_fueling_time = served.sum { |r| r[:fueling_time] }
    def total_waiting_time = served.sum { |r| r[:waiting_time] }

    def avg_fueling_time
      return 0 if served.empty?

      (total_fueling_time.to_f / served.size).round(2)
    end

    def avg_fueling_speed
      return 0 if fuel_given.zero?

      (total_fueling_time.to_f / fuel_given).round(2)
    end

    def avg_waiting_time
      return 0 if all.empty?

      (total_waiting_time.to_f / all.size).round(2)
    end

    def total_income  = served.sum { |r| r[:bill] }.round(2)
    def initial_costs = initial_fuel_cost + initial_pumps_cost
    def serving_costs = served.sum { |r| r[:cost] }
    def total_cost    = (initial_costs + serving_costs).round(2)
    def total_revenue = (total_income - total_cost).round(2)

    private

    attr_reader :document, :station_name

    def sheet
      document[station_name] ||= {
        full: [],
        partial: [],
        none: [],
        waiting: [],
        being_served: []
      }
    end
  end
end
