# frozen_string_literal: true

require_relative '../app/petrolex'
require 'optparse'
require 'yaml'

params = {}
OptionParser.new do |opts|
  opts.on('--aa')
  opts.on('--silent')
  opts.on('--scenario STRING')
end.parse!(into: params)
silent = params[:silent] || !!params[:aa]
ascii_art = !!params[:aa]
config = params[:scenario]&.to_sym || :alpha

yaml_options = { aliases: true, permitted_classes: [Range, Symbol], symbolize_names: true }
scenarios = YAML.load_file('./config/simulations.yml', **yaml_options)[:scenarios]

timer = nil
report = Petrolex::Report.new(name: config)
simulations = scenarios[config][:simulations].map do |sim|
  timer = Petrolex::Timer.new(speed: sim[:speed]) unless timer && timer.speed == sim[:speed]
  logger = Petrolex::Logger.new(timer:, silent:, color: sim[:color])

  Petrolex::Simulation.new(name: sim[:name], timer:, logger:, report:).configure do |config|
    config.ascii_art = ascii_art
    config.lane = sim[:lane].to_sym
    config.fuel_price = sim[:fuel_price]
    config.fuel_cost = sim[:fuel_cost]
    config.pump_base_cost = sim[:pump_base_cost]
    config.cars_number = sim[:cars_number]
    config.cars_volume_range = sim[:cars_volume_range]
    config.cars_level_range = sim[:cars_level_range]
    config.cars_delay_interval_range = sim[:cars_delay_interval_range]
    config.station_fuel_reserve = sim[:station_fuel_reserve]
    config.station_closing_tick = sim[:station_closing_tick]
    config.pumps_number_range = sim[:pumps_number_range]
    config.pumps_speed_range = sim[:pumps_speed_range]
  end
end

Petrolex::Runner.new(simulations:, ascii_art:).call
