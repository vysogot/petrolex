# frozen_string_literal: true

module Petrolex
  # Fuels at the Station
  class Road
    START_COLUMN = 82
    TOP_LANE = 20
    BOTTOM_LANE = 22

    attr_reader :queue, :roadies

    def initialize(queue:)
      @queue = queue
      @roadies = []
    end

    def push(car)
      row = [TOP_LANE, BOTTOM_LANE].sample
      column = START_COLUMN

      roadies << Roadie.new(car:, row:, column:)
    end

    def refresh
      roadies.reject! { |r| r.column < 1 }

      roadies.each do |r|
        update_position(r)

        if fuel?(r)
          if r.row == 22
            r.turn_down
          elsif r.row == 20
            r.turn_up
          elsif r.column == 35
            queue.push(r.car)
          end
        end
      end
    end

    def update_position(roadie)
      roadie.tap do |r|
        if r.going_left?
          r.column -= 1
          #r.column = columns - 1 if r.column < 1
        elsif r.going_up?
          r.row -= 1
          r.turn_left if r.row == 6
        elsif r.going_down?
          r.row += 1
          r.turn_left if r.row == 35
        end
      end
    end

    def fuel?(roadie)
      roadie.at?(given_row: roadie.row, given_column: 53) && roadie.wants_fuel?
    end
  end
end
