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
      #row = [TOP_LANE, BOTTOM_LANE].sample
      row = TOP_LANE
      column = START_COLUMN

      roadies << Roadie.new(car:, row:, column:)
    end

    def refresh
      roadies.reject! { |r| r.column < 1 }

      refresh_moving_roadies
      refresh_roadies_in_queue
      refresh_roadies_at_pumps
    end

    def refresh_moving_roadies
      roadies.each do |r|
        next unless r.moving?

        update_moving_position(r)

        if fuel?(r)
          if r.row == 22
            r.turn_down
          elsif r.row == 20
            r.turn_up
          end
        end
      end
    end

    def refresh_roadies_in_queue
      queue.lock.synchronize do
        roadies.each do |r|
          next if r.moving?

          update_position_in_queue(r)
        end
      end
    end

    def refresh_roadies_at_pumps
      queue.station.mounted_pumps.each_with_index do |pump, index|
        next if pump.car.nil?

        roadie_by_pump = roadies.detect { |r| r.car == pump.car }
        next if roadie_by_pump.nil?

        row = at_upper_station?(roadie_by_pump) ? 8 : 34
        roadie_by_pump.row = row + ((index / 9) * 3)
        roadie_by_pump.column = 2 + ((index % 9) * 4)
      end
    end

    def update_moving_position(roadie)
      roadie.tap do |r|
        if r.going_left?
          r.column -= 1
          #r.column = columns - 1 if r.column < 1
        elsif r.going_up?
          r.row -= 1
          r.turn_left if r.row == 6
        elsif r.going_down?
          r.row += 1
          r.turn_left if r.row == 36
        end

        if (r.row == 6 || r.row == 36) && r.column < 35
          put_in_queue(r)
        end
      end
    end

    def update_position_in_queue(roadie)
      position_in_queue = queue.waiting.map {|x| x[0] }&.index(roadie.car)
      if roadie.car.want == 0 || queue.station.reserve_reading <= 0
        roadie.start_moving
      else
        column = position_in_queue.nil? ? 1 : position_in_queue + 1 * 2
        roadie.column = column
      end
    end

    def put_in_queue(roadie)
      roadie.stop_moving
      roadie.row = at_upper_station?(roadie) ? 1 : 42
      roadie.column = queue.waiting.size * 2

      queue.push(roadie.car)
    end

    def at_upper_station?(roadie)
      roadie.row < 20
    end

    def fuel?(roadie)
      roadie.at?(given_row: roadie.row, given_column: 53) && roadie.wants_fuel?
    end
  end
end
