# frozen_string_literal: true

require_relative '../app/petrolex'
require 'optparse'

params = {}
OptionParser.new do |opts|
  opts.on('--aa')
end.parse!(into: params)
silent = ascii_art = !!params[:aa]

report = Petrolex::Report.new(name: 'Many simulations')
timer1 = Petrolex::Timer.new
timer2 = Petrolex::Timer.new
timer3 = Petrolex::Timer.new
logger1 = Petrolex::Logger.new(timer: timer1, silent:, color: :none)
logger2 = Petrolex::Logger.new(timer: timer2, silent:, color: :yellow)
logger3 = Petrolex::Logger.new(timer: timer2, silent:, color: :red)
simulation1 = Petrolex::Simulation.new(name: 'Simulation1', timer: timer1, logger: logger1, report:)
simulation2 = Petrolex::Simulation.new(name: 'Simulation2', timer: timer2, logger: logger2, report:)
simulation3 = Petrolex::Simulation.new(name: 'Simulation3', timer: timer3, logger: logger3, report:)

simulations = [simulation1, simulation2, simulation3]
Petrolex::Runner.new(simulations:, ascii_art:).call
