# frozen_string_literal: true

module Petrolex
  # Fuels at the Station
  class Road
    attr_reader :rows, :columns, :queue, :roadies

    def initialize(queue:, rows: 3, columns: 82)
      @rows = rows
      @columns = columns
      @queue = queue
      @roadies = []
    end

    def push(car)
      roadies << Roadie.new(car:, row: 0, column: columns)
    end

    def refresh
      roadies.each do |roadie|
        update_position(roadie)

        if fuel?(roadie)
          queue.push(roadie.car)
          roadie.row = 5
        end
      end
    end

    def update_position(roadie)
      roadie.tap do |r|
        r.column -= 1
        r.column = columns - 1 if r.column < 1
      end
    end

    def fuel?(roadie)
      roadie.at?(given_row: 0, given_column: 75) && roadie.wants_fuel?
    end

    class Roadie
      attr_accessor :car, :row, :column

      def initialize(car:, row:, column:)
        @car = car
        @row = row
        @column = column
      end

      def at?(given_row:, given_column:)
        row == given_row && column == given_column
      end

      def wants_fuel?
        rand(0..1).odd?
      end
    end
  end
end
