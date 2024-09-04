# frozen_string_literal: true

module Petrolex
  class Graph
    attr_accessor :station_sheet
    attr_reader :report

    def initialize(report:)
      @report = report
    end

    def elements
      {
        name: report.name,
        children:
      }
    end

    def columns
      hash = {}
      %i[reserve full_count partial_count none_count waiting_count being_served_count
         visitors_count fuel_given total_fueling_time total_waiting_time
         avg_fueling_speed avg_fueling_time avg_waiting_time].each do |field|
        hash[field] = []
        report.document.dup.each do |station_name, _station_sheet|
          hash[field] << { name: station_name, value: report.for(station_name:).send(field).to_s || 0 }
        end
      end
      hash
    end

    private

    def children
      report.document.map do |station_name, station_sheet|
        self.station_sheet = station_sheet

        {
          name: station_name,
          children: [
            *waiting,
            {
              name: 'Being served',
              children: being_served
            },
            {
              name: 'Full',
              children: full
            },
            {
              name: 'Partial',
              children: partial
            },
            {
              name: 'None',
              children: none
            }
          ]
        }
      end
    end

    def waiting
      station_sheet[:waiting].map do |entry|
        car = entry[:car]
        { name: car.plate, value: car.want }
      end
    end

    def being_served
      station_sheet[:being_served].map do |entry|
        car = entry[:car]
        { name: car.plate, value: car.want }
      end
    end

    def full
      station_sheet[:full].map do |entry|
        car = entry[:car]
        { name: car.plate, value: entry[:units_given] }
      end
    end

    def partial
      station_sheet[:partial].map do |entry|
        car = entry[:car]
        { name: car.plate, value: entry[:units_given] }
      end
    end

    def none
      station_sheet[:none].map do |entry|
        car = entry[:car]
        { name: car.plate, value: car.want }
      end
    end
  end
end
