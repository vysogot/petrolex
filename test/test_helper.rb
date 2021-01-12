# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require_relative '../app/petrolex'
require 'minitest/autorun'

Timer.setup(simulation_speed: 1000)

ENV['app_env'] = 'test'

module QuietLogger
  def run
    Logger.stub :info, nil do
      super
    end
  end
end

module SerialFaker
  def catch_output(&block)
    default_serial_output = $stdout

    fake_serial_output = StringIO.new
    $stdout = fake_serial_output

    block.call

    fake_serial_output.string
  ensure
    $stdout = default_serial_output
  end
end
