# frozen_string_literal: true

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

        simulations.each do |simulation|
          simulation.roadies.each do |roadie|
            update_grid(roadie.row, roadie.column, roadie.emoji)
          end
        end

        sleep(0.3)

        break if simulations.all? { |sim| sim.finished? }
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

        break if simulations.all? { |sim| sim.finished? }
      end
    end

    def create_grid
      board = BOARD.dup
      board.tr!('.', ' ')

      simulations.each do |simulation|
        simulation.station.mounted_pumps.each do |pump|
          if simulation.lane == :top
            board.sub!(/XX/, "PB")
          elsif simulation.lane == :bottom
            board.sub!(/YY/, "ON") if simulation.lane == :bottom
          end
        end

        if simulation.lane == :top
          if report(simulation).waiting_count < 20
            board.sub!(/TTTTTT/, colorize("\\    \\", 32))
          else
            board.sub!(/TTTTTT/, colorize('------', 31))
          end
          if simulation.station.open?
            board.sub!(/QQQQQ/, colorize("    /", 32))
          else
            board.sub!(/QQQQQ/, colorize("-----", 31))
          end
          board.sub!(/top_name/, simulation.name.rjust(8, ' '))
          board.sub!(/top_curr/, simulation.timer.current_tick.to_s.rjust(8, ' '))
          board.sub!(/top_wait/, report(simulation).waiting_count.to_s.rjust(8, ' '))
          board.sub!(/top_bein/, report(simulation).being_served_count.to_s.rjust(8, ' '))
          board.sub!(/top_full/, report(simulation).full_count.to_s.rjust(8, ' '))
          board.sub!(/top_cars/, report(simulation).visitors_count.to_s.rjust(8, ' '))
          board.sub!(/top_rese/, report(simulation).reserve.to_s.rjust(8, ' '))
          board.sub!(/top_fuel/, report(simulation).fuel_given.to_s.rjust(8, ' '))
          board.sub!(/top_ttfu/, report(simulation).total_fueling_time.to_s.rjust(8, ' '))
          board.sub!(/top_ttwa/, report(simulation).total_waiting_time.to_s.rjust(8, ' '))
          board.sub!(/top_avfu/, report(simulation).avg_fueling_time.to_s.rjust(8, ' '))
          board.sub!(/top_avwa/, report(simulation).avg_waiting_time.to_s.rjust(8, ' '))
          board.sub!(/top_avpm/, simulation.station.avg_pumps_speed.to_s.rjust(4, ' ') + ' s/l')
          board.sub!(/top_part/, report(simulation).partial_count.to_s.rjust(8, ' '))
          board.sub!(/top_notf/, report(simulation).none_count.to_s.rjust(8, ' '))
          board.sub!(/top_\$/, simulation.fuel_price.to_s.rjust(5, ' '))
          board.sub!(/top_income/, ('$' + report(simulation).total_income.to_s).rjust(10, ' '))
          board.sub!(/top_ttcost/, ('$' + report(simulation).total_cost.to_s).rjust(10, ' '))
          board.sub!(/top_ttreve/, ('$' + report(simulation).total_revenue.to_s).rjust(10, ' '))
          board.sub!(/top_spee/, simulation.timer.speed.to_s.rjust(8, ' '))
          board.sub!(/top_clos/, simulation.station_closing_tick.to_s.ljust(8, ' '))
          board.sub!(/top_fuco/, report(simulation).initial_fuel_cost.to_s.rjust(8, ' '))
          board.sub!(/top_puco/, report(simulation).initial_pumps_cost.to_s.rjust(8, ' '))
        elsif simulation.lane == :bottom
          if report(simulation).waiting_count < 20
            board.sub!(/BBBBBB/, colorize('/    /', 32))
          else
            board.sub!(/BBBBBB/, colorize('------', 31))
          end
          if simulation.station.open?
            board.sub!(/WWWWW/, colorize("    \\", 32))
          else
            board.sub!(/WWWWW/, colorize("-----", 31))
          end
          board.sub!(/btm_name/, simulation.name.rjust(8, ' '))
          board.sub!(/btm_curr/, simulation.timer.current_tick.to_s.rjust(8, ' '))
          board.sub!(/btm_wait/, report(simulation).waiting_count.to_s.rjust(8, ' '))
          board.sub!(/btm_bein/, report(simulation).being_served_count.to_s.rjust(8, ' '))
          board.sub!(/btm_full/, report(simulation).full_count.to_s.rjust(8, ' '))
          board.sub!(/btm_cars/, report(simulation).visitors_count.to_s.rjust(8, ' '))
          board.sub!(/btm_rese/, report(simulation).reserve.to_s.rjust(8, ' '))
          board.sub!(/btm_fuel/, report(simulation).fuel_given.to_s.rjust(8, ' '))
          board.sub!(/btm_ttfu/, report(simulation).total_fueling_time.to_s.rjust(8, ' '))
          board.sub!(/btm_ttwa/, report(simulation).total_waiting_time.to_s.rjust(8, ' '))
          board.sub!(/btm_avfu/, report(simulation).avg_fueling_time.to_s.rjust(8, ' '))
          board.sub!(/btm_avwa/, report(simulation).avg_waiting_time.to_s.rjust(8, ' '))
          board.sub!(/btm_avpm/, simulation.station.avg_pumps_speed.to_s.rjust(4, ' ') + ' s/l')
          board.sub!(/btm_part/, report(simulation).partial_count.to_s.rjust(8, ' '))
          board.sub!(/btm_notf/, report(simulation).none_count.to_s.rjust(8, ' '))
          board.sub!(/btm_\$/, simulation.fuel_price.to_s.rjust(5, ' '))
          board.sub!(/btm_income/, ('$' + report(simulation).total_income.to_s).rjust(10, ' '))
          board.sub!(/btm_ttcost/, ('$' + report(simulation).total_cost.to_s).rjust(10, ' '))
          board.sub!(/btm_ttreve/, ('$' + report(simulation).total_revenue.to_s).rjust(10, ' '))
          board.sub!(/btm_spee/, simulation.timer.speed.to_s.rjust(8, ' '))
          board.sub!(/btm_clos/, simulation.station_closing_tick.to_s.ljust(8, ' '))
          board.sub!(/btm_fuco/, report(simulation).initial_fuel_cost.to_s.rjust(8, ' '))
          board.sub!(/btm_puco/, report(simulation).initial_pumps_cost.to_s.rjust(8, ' '))
        end
      end

      board.gsub!(/(XX|YY)/, '  ')

      board.split("\n")[1..].map do |x|
        x.scan(/.{2}/)
      end
    end

    def report(simulation)
      simulation.report.for(station_name: simulation.station.name)
    end

    def colorize(message, color)
      "\e[#{color}m#{message}\e[0m"
    end

    def print_board
      puts(grid.map { |row| row.join }.join("\r\n"))
    end
  end

BOARD = %q(
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                                                                                                                                     .
|QQQQQ--------------------------------------------------------------------------------------------------\    \--------------------------------------------------------
|                                                                                                       |    |  Current tick: top_curr/top_clos           top_name   |
|                                                                                                       |    |                                                       |
|                                                                                                       |    |       Waiting: top_wait         Sim speed: top_spee   |
|                                                                                                       |    |  Being served: top_bein         Fuel cost: top_fuco   |
                                                                                                        |    |  Fully served: top_full        Pumps cost: top_puco   |
                                                                                            _________   |    |       Reserve: top_rese                               |
    XX      XX      XX      XX      XX      XX      XX      XX      XX      XX      XX      |       |   |    |    Fuel given: top_fuel                               |
                                                                                            | PB-95 |   |    |  TT Fuel time: top_ttfu                               |
                                                                                            |       |   |    |  TT Wait time: top_ttwa                               |
    XX      XX      XX      XX      XX      XX      XX      XX      XX      XX      XX      | top_$ |   |    |  AV Fuel time: top_avfu                               |
                                                                                            |       |   |    |  AV Wait time: top_avwa                               |
                                                                                            | $ / l |   |    |  AV Pmp speed: top_avpm                               |
    XX      XX      XX      XX      XX      XX      XX      XX      XX      XX      XX      |       |   |    |     Partially: top_part             Cost: top_ttcost  |
                                                                                            |       |   |    |    Not fueled: top_notf           Income: top_income  |
                                                                                            |_______|   |    |    Cars visit: top_cars          Revenue: top_ttreve  |
    XX      XX      XX      XX      XX      XX      XX      XX      XX      XX      XX     /_________\  |    |                                                       |
--------------------------------------------------------------------------------------------------------TTTTTT--------------------------------------------------------
                                                                                                                                                                     .
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -.
                                                                                                                                                                     .
--------------------------------------------------------------------------------------------------------BBBBBB--------------------------------------------------------
    YY      YY      YY      YY      YY      YY      YY      YY      YY      YY      YY      _________   |    |  Current tick: btm_curr/btm_clos           btm_name   |
                                                                                            |       |   |    |                                                       |
                                                                                            |  O-N  |   |    |       Waiting: btm_wait         Sim speed: btm_spee   |
    YY      YY      YY      YY      YY      YY      YY      YY      YY      YY      YY      |       |   |    |  Being served: btm_bein         Fuel cost: btm_fuco   |
                                                                                            | btm_$ |   |    |  Fully served: btm_full        Pumps cost: btm_puco   |
                                                                                            |       |   |    |       Reserve: btm_rese                               |
    YY      YY      YY      YY      YY      YY      YY      YY      YY      YY      YY      | $ / l |   |    |    Fuel given: btm_fuel                               |
                                                                                            |       |   |    |  TT Fuel time: btm_ttfu                               |
                                                                                            |       |   |    |  TT Wait time: btm_ttwa                               |
    YY      YY      YY      YY      YY      YY      YY      YY      YY      YY      YY      |_______|   |    |  AV Fuel time: btm_avfu                               |
                                                                                           /_________\  |    |  AV Wait time: btm_avwa                               |
                                                                                                        |    |  AV Pmp speed: btm_avpm                               |
|                                                                                                       |    |     Partially: btm_part            Cost: btm_ttcost   |
|                                                                                                       |    |    Not fueled: btm_notf          Income: btm_income   |
|                                                                                                       |    |    Cars visit: btm_cars         Revenue: btm_ttreve   |
|                                                                                                       |    |                                                       |
|                                                                                                       |    |                                                       |
|WWWWW--------------------------------------------------------------------------------------------------/    /--------------------------------------------------------
                                                                                                                                                                     .
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
)
end
