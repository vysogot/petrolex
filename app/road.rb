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
      roadies << Roadie.new(car:, row: [0, 2].sample, column: columns)
    end

    def refresh
      roadies.each do |r|
        update_position(r)

        if fuel?(r)
          queue.push(r.car)
          if r.row == 2
            r.turn_down
          elsif r.row == 0
            r.turn_up
          end
        end
      end
    end

    def update_position(roadie)
      roadie.tap do |r|
        if r.going_left?
          r.column -= 1
          r.column = columns - 1 if r.column < 1
        elsif r.going_up?
          r.row -= 1
          r.turn_left if r.row == -14
        elsif r.going_down?
          r.row += 1
          r.turn_left if r.row == 15
        end
      end
    end

    def fuel?(roadie)
      roadie.at?(given_row: roadie.row, given_column: 53)# && roadie.wants_fuel?
    end

    class Roadie
      attr_accessor :car, :row, :column, :direction

      def initialize(car:, row:, column:, direction: :left)
        @car = car
        @row = row
        @column = column
        @direction = direction
      end

      def at?(given_row:, given_column:)
        row == given_row && column == given_column
      end

      def wants_fuel?
        rand(0..1).odd?
      end

      def going_left?
        direction == :left
      end

      def going_down?
        direction == :down
      end

      def going_up?
        direction == :up
      end

      def turn_left
        self.direction = :left
      end

      def turn_down
        self.direction = :down
      end

      def turn_up
        self.direction = :up
      end

      def emoji
        "\u{1F695}"
      end
    end
  end
end
