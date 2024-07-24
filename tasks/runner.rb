# frozen_string_literal: true

require_relative '../app/petrolex'

simulation = Petrolex::Simulation.new
Petrolex::Runner.new.call(simulation:)
