# frozen_string_literal: true

require_relative 'ascii_board'

module Petrolex
  # Draws the simulation in console
  class AsciiArt
    attr_accessor :grid
    attr_reader :columns, :rows,
                :street_top, :street_bottom, :middle_line,
                :simulations

    def initialize(simulations:, rows: 43, columns: 84)
      @simulations = simulations
      @columns = columns
      @rows = rows
      @street_top = (rows / 2) + 2
      @street_bottom = (rows / 2) - 2
      @middle_line = (rows / 2)
      @grid = create_grid
    end

    def call
      Async do |task|
        task.async { animate }
        task.async { refresh }
      end
    end

    private

    def animate
      loop do
        self.grid = create_grid

        simulations.each do |sim|
          sim.roadies.each do |roadie|
            update_grid(roadie.row, roadie.column, roadie.emoji)
          end
        end

        sleep(0.3)

        break if all_finished?
      end
    end

    def update_grid(row, column, value)
      grid[row][column] = value
    end

    def refresh
      loop do
        $stdout.clear_screen
        print_board
        sleep(0.3)

        break if all_finished?
      end
    end

    def create_grid
      board = BOARD.dup
      board.tr!('.', ' ')

      simulations.each do |sim|
        sim.station.mounted_pumps.each do
          if sim.lane == :top
            board.sub!(/XX/, "PB")
          elsif sim.lane == :bottom
            board.sub!(/YY/, "ON")
          end
        end

        fill_lane(board, sim)
      end

      board.gsub!(/(XX|YY)/, '  ')

      board.split("\n")[1..].map do |x|
        x.scan(/.{2}/)
      end
    end

    def fill_lane(board, sim)
      stats = sim.report.for(station_name: sim.station.name)
      prefix = sim.lane == :top ? 'top' : 'btm'
      queue_full = stats.waiting_count >= 20

      if sim.lane == :top
        board.sub!(/TTTTTT/, queue_full ? colorize('------', 31) : colorize("\\    \\", 32))
        board.sub!(/QQQQQ/, sim.station.open? ? colorize("    /", 32) : colorize("-----", 31))
      else
        board.sub!(/BBBBBB/, queue_full ? colorize('------', 31) : colorize('/    /', 32))
        board.sub!(/WWWWW/, sim.station.open? ? colorize("    \\", 32) : colorize("-----", 31))
      end

      board.sub!(/#{prefix}_name/, pad(sim.name))
      board.sub!(/#{prefix}_curr/, pad(sim.timer.current_tick))
      board.sub!(/#{prefix}_wait/, pad(stats.waiting_count))
      board.sub!(/#{prefix}_bein/, pad(stats.being_served_count))
      board.sub!(/#{prefix}_full/, pad(stats.full_count))
      board.sub!(/#{prefix}_cars/, pad(stats.visitors_count))
      board.sub!(/#{prefix}_rese/, pad(stats.reserve))
      board.sub!(/#{prefix}_fuel/, pad(stats.fuel_given))
      board.sub!(/#{prefix}_ttfu/, pad(stats.total_fueling_time))
      board.sub!(/#{prefix}_ttwa/, pad(stats.total_waiting_time))
      board.sub!(/#{prefix}_avfu/, pad(stats.avg_fueling_time))
      board.sub!(/#{prefix}_avwa/, pad(stats.avg_waiting_time))
      board.sub!(/#{prefix}_avpm/, pad(sim.station.avg_pumps_speed, 4) + ' s/l')
      board.sub!(/#{prefix}_part/, pad(stats.partial_count))
      board.sub!(/#{prefix}_notf/, pad(stats.none_count))
      board.sub!(/#{prefix}_\$/, pad(sim.fuel_price, 5))
      board.sub!(/#{prefix}_income/, pad('$' + stats.total_income.to_s, 10))
      board.sub!(/#{prefix}_ttcost/, pad('$' + stats.total_cost.to_s, 10))
      board.sub!(/#{prefix}_ttreve/, pad('$' + stats.total_revenue.to_s, 10))
      board.sub!(/#{prefix}_spee/, pad(sim.timer.speed))
      board.sub!(/#{prefix}_clos/, sim.station_closing_tick.to_s.ljust(8, ' '))
      board.sub!(/#{prefix}_fuco/, pad(stats.initial_fuel_cost))
      board.sub!(/#{prefix}_puco/, pad(stats.initial_pumps_cost))
    end

    def all_finished?
      simulations.all?(&:finished?)
    end

    def pad(value, width = 8)
      value.to_s.rjust(width, ' ')
    end

    def colorize(message, color)
      "\e[#{color}m#{message}\e[0m"
    end

    def print_board
      puts(grid.map { |row| row.join }.join("\r\n"))
    end
  end
end
