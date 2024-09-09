# frozen_string_literal: true

module Petrolex
  # Fuels at the Station
  class Road
    START_COLUMN = 82
    LANES = { top: 20, bottom: 22 }

    attr_reader :queue, :roadies, :lane

    def initialize(queue:, lane: :top)
      @queue = queue
      @lane = LANES[lane]
      @roadies = []
    end

    def push(car)
      row = lane
      column = START_COLUMN

      roadies << Roadie.new(car:, row:, column:)
    end

    def refresh
      remove_old_roadies
      refresh_moving_roadies
      refresh_roadies_in_queue
      refresh_roadies_at_pumps
    end

    def remove_old_roadies
      roadies.reject! { |r| r.column < 1 }
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

        if at_upper_station?(roadie_by_pump)
          row = 8
          roadie_by_pump.row = row + ((index / 11) * 3)
          roadie_by_pump.column = 2 + ((index % 11) * 4)
        else
          row = 25
          roadie_by_pump.row = row + ((index / 11) * 3)
          roadie_by_pump.column = 2 + ((index % 11) * 4)
        end

        if roadie_by_pump.car.want == 0
          if at_upper_station?(roadie_by_pump)
            roadie_by_pump.row -= 1
          else
            roadie_by_pump.row += 1
          end
        end
      end
    end

    def update_moving_position(roadie)
      roadie.tap do |r|
        cant_move = false
        if r.going_left?
          if roadies.none? { |x| x.row == r.row && x.column == r.column - 1}
            r.column -= 1
          else
            cant_move = true
          end
        elsif r.going_up?
          r.row -= 1 unless roadies.any? { |x| x.row == r.row - 1 && x.column == r.column}
          r.turn_left if r.row == 1
        elsif r.going_down?
          r.row += 1 unless roadies.any? { |x| x.row == r.row + 1 && x.column == r.column}
          r.turn_left if r.row == 42
        end

        if ((r.row == 1 || r.row == 42) && r.column < 2) ||
          (((r.row == 1 || r.row == 42)) && cant_move && not_in_queue?(r.car)) &&
          !(queue.station.reserve_reading <= 0 || queue.station.done?)
          put_in_queue(r)
        end
      end
    end

    def not_in_queue?(car)
      !queue.waiting.any? {|x| x[0] == car}
    end

    def update_position_in_queue(roadie)
      if roadie.car.want == 0 || queue.station.reserve_reading <= 0 || queue.station.done?
        roadie.start_moving
      else
        position_in_queue = queue.waiting.map {|x| x[0] }&.index(roadie.car)
        column = position_in_queue.nil? ? 1 : position_in_queue + 1 * 2
        roadie.column = column * 2
        roadie.column = 82 if roadie.column > 82
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
      queue.station.open? && roadie.at?(given_row: roadie.row, given_column: 53) && roadie.wants_fuel? && (queue.waiting.size < 20)
    end
  end
end
