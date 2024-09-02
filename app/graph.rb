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
      report.document.map do |station_name, station_sheet|
        [
          { name: 'reserve', value: station_sheet[:reserve] },
          { name: 'fuel given', value: station_sheet[:fuel_given] },
          { name: 'cars in queue', value: station_sheet[:waiting_count] },
          { name: 'cars fueled', value: station_sheet[:full_count] },
          { name: 'cars partial', value: station_sheet[:partial_count] },
          { name: 'cars none', value: station_sheet[:none_count] }
        ]
      end.flatten
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
