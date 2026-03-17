# frozen_string_literal: true

Warning[:experimental] = false

require_relative '../app/petrolex'
require 'optparse'

params = {}
OptionParser.new do |opts|
  opts.on('--aa')
  opts.on('--silent')
  opts.on('--scenario STRING')
end.parse!(into: params)

silent    = params[:silent] || !!params[:aa]
ascii_art = !!params[:aa]
scenario  = params[:scenario]&.to_sym || :alpha

loaded = Petrolex::ScenarioLoader.new(
  path:      './config/simulations.yml',
  scenario:,
  silent:,
  ascii_art:
).load

Petrolex::Runner.new(simulations: loaded[:simulations], ascii_art:).call
