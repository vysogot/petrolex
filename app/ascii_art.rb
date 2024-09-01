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

    def create_grid
      Array.new(rows) do |row_index|
        if border_row?(row_index)
          create_border_row
        elsif middle_line?(row_index)
          create_middle_line_row
        else
          create_regular_row(row_index)
        end
      end
    end

    def border_row?(row_index)
      [0, street_top, street_bottom, rows - 1].include?(row_index)
    end

    def middle_line?(row_index)
      row_index == middle_line
    end

    def create_border_row
      Array.new(columns - 1) { '--' }
    end

    def create_middle_line_row
      Array.new(columns - 1) { '- ' }
    end

    def create_regular_row(row_index)
      Array.new(columns - 1) { '  ' }.tap do |row|
        unless inside_street?(row_index)
          row[0] = '|'
          row[columns - 1] = '|'
        end
      end
    end

    def inside_street?(row_index)
      (street_bottom..street_top).include?(row_index)
    end

    def animate
      loop do
        self.grid = create_grid

        simulation.roadies.each do |roadie|
          update_grid(roadie.row + 20, roadie.column, "\u{1F695}")
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

    def print_board
      puts(grid.map { |row| row.join }.join("\r\n"))
    end
  end
end
