# frozen_string_literal: true

module Petrolex
  # Draws the simulation in console
  class AsciiArt
    attr_accessor :grid
    attr_reader :columns, :rows,
                :street_top, :street_bottom, :middle_line,
                :simulation

    def initialize(simulation:, rows: 42, columns: 84)
      @simulation = simulation
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

        simulation.roadies.each do |roadie|
          update_grid(roadie.row, roadie.column, roadie.emoji)
        end

        sleep(0.3)
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
      end
    end

    def create_grid
      BOARD.split("\n")[1..].map do |x|
        x.tr!('.', ' ')
        x.scan(/.{2}/)
      end
    end

    def print_board
      puts(grid.map { |row| row.join }.join("\r\n"))
    end
  end

BOARD = %q(
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
|                                                                       |                                                                                            |
|                                                                       |                                                                                            |
|                                                                       |                                                                                            |
|                                                                       |                                                                                            |
|                                                                       \------------------------------------\                                                       |
|                                                                                                            |                                                       |
|                                                                       /-------------------------------\    |                                                       |
|                                                                       |                               |    |                                                       |
|                                                                       |                               |    |                                                       |
|                                                                       |                               |    |                                                       |
|                                                                       |                               |    |                                                       |
|                                                                       |                               |    |                                                       |
|                                                                       |                               |    |                                                       |
|                                                                       |                               |    |                                                       |
|                                                                       |                               |    |                                                       |
|                                                                       |                               |    |                                                       |
|                                                                       |                               |    |                                                       |
|                                                                       |                               |    |                                                       |
--------------------------------------------------------------------------------------------------------/    \--------------------------------------------------------
.                                                                                                                                                                    .
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -.
.                                                                                                                                                                    .
--------------------------------------------------------------------------------------------------------\    /--------------------------------------------------------
|                                                                       |                               |    |                                                       |
|                                                                       |                               |    |                                                       |
|                                                                       |                               |    |                                                       |
|                                                                       |                               |    |                                                       |
|                                                                       |                               |    |                                                       |
|                                                                       |                               |    |                                                       |
|                                                                       |                               |    |                                                       |
|                                                                       |                               |    |                                                       |
|                                                                       |                               |    |                                                       |
|                                                                       |                               |    |                                                       |
|                                                                       \-------------------------------/    |                                                       |
|                                                                                                            |                                                       |
|                                                                       /------------------------------------/                                                       |
|                                                                       |                                                                                            |
|                                                                       |                                                                                            |
|                                                                       |                                                                                            |
|                                                                       |                                                                                            |
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
)
end
