# frozen_string_literal: true

require 'yaml'

module Petrolex
  # Loads simulation configuration from a YAML file and builds Simulation objects
  class ScenarioLoader
    YAML_OPTIONS = { aliases: true, permitted_classes: [Range, Symbol], symbolize_names: true }.freeze

    def initialize(path:, scenario:, silent:, ascii_art:)
      @path = path
      @scenario = scenario
      @silent = silent
      @ascii_art = ascii_art
    end

    def load
      report = Report.new(name: scenario)
      simulations = sim_configs.map { |config| build_simulation(config, report) }
      { simulations:, report: }
    end

    private

    attr_reader :path, :scenario, :silent, :ascii_art

    def sim_configs
      yaml = YAML.load_file(path, **YAML_OPTIONS)
      yaml[:scenarios][scenario][:simulations]
    end

    def build_simulation(config, report)
      timer = timer_for(config[:speed])
      logger = Logger.new(timer:, silent:, color: config[:color])

      Simulation.new(name: config[:name], timer:, logger:, report:).configure do |sim|
        sim.ascii_art                  = ascii_art
        sim.lane                       = config[:lane].to_sym
        sim.fuel_price                 = config[:fuel_price]
        sim.fuel_cost                  = config[:fuel_cost]
        sim.pump_base_cost             = config[:pump_base_cost]
        sim.cars_number                = config[:cars_number]
        sim.cars_volume_range          = config[:cars_volume_range]
        sim.cars_level_range           = config[:cars_level_range]
        sim.cars_delay_interval_range  = config[:cars_delay_interval_range]
        sim.station_fuel_reserve       = config[:station_fuel_reserve]
        sim.station_closing_tick       = config[:station_closing_tick]
        sim.pumps_number_range         = config[:pumps_number_range]
        sim.pumps_speed_range          = config[:pumps_speed_range]
      end
    end

    def timer_for(speed)
      @timers ||= {}
      @timers[speed] ||= Timer.new(speed:)
    end
  end
end
