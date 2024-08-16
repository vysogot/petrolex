# frozen_string_literal: true

module Petrolex
  # Draws the simulation in console
  class AsciiArt
    attr_reader :width, :height, :grid,
                :street_top, :street_bottom, :middle_line

    def initialize(width: 84, height: 42)
      @width = width
      @height = height
      @street_top = (height / 2) + 2
      @street_bottom = (height / 2) - 2
      @middle_line = (height / 2)
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
      Array.new(height) do |row_index|
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
      [0, street_top, street_bottom, height - 1].include?(row_index)
    end

    def middle_line?(row_index)
      row_index == middle_line
    end

    def create_border_row
      Array.new(width - 1) { '--' }
    end

    def create_middle_line_row
      Array.new(width - 1) { '- ' }
    end

    def create_regular_row(row_index)
      Array.new(width - 1) { '  ' }.tap do |row|
        unless inside_street?(row_index)
          row[0] = '|'
          row[width - 1] = '|'
        end
      end
    end

    def inside_street?(row_index)
      (street_bottom..street_top).include?(row_index)
    end

    def animate
      x = street_top - 1
      y = width - 2

      loop do
        update_grid(x, y, "\u{1F695}")
        sleep(rand(0.1..0.1))
        update_grid(x, y, '  ')
        x, y = update_coordinates(x, y)
        update_grid(x, y, "\u{1F695}")
      end
    end

    def update_grid(x, y, value)
      grid[x][y] = value
    end

    def update_coordinates(x, y)
      y -= 1

      y = width - 2 if y < 1

      [x, y]
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
