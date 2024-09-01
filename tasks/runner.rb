# frozen_string_literal: true

require_relative '../app/petrolex'
require 'optparse'

params = {}
OptionParser.new do |opts|
  opts.on('--aa')
end.parse!(into: params)
silent = ascii_art = !!params[:aa]

timer1 = Petrolex::Timer.new
# timer2 = Petrolex::Timer.new(speed: 100)
logger1 = Petrolex::Logger.new(timer: timer1, silent:, color: :none)
# logger2 = Petrolex::Logger.new(timer: timer2, silent:, color: :yellow)
simulation1 = Petrolex::Simulation.new(timer: timer1, logger: logger1)
# simulation2 = Petrolex::Simulation.new(timer: timer2, logger: logger2)

simulations = [simulation1]
Petrolex::Runner.new(simulations:, ascii_art:).call
