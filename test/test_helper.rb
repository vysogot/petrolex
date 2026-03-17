# frozen_string_literal: true

require_relative '../app/petrolex'
require 'minitest/autorun'

module Petrolex
  module TestHelpers
    FakeTimer = Struct.new(:current_tick)

    def stub_timer(tick: 0)
      FakeTimer.new(tick)
    end

    def stub_simulation(name: 'TestStation')
      timer = stub_timer
      logger = Logger.new(timer:, silent: true)
      report = Report.new(name:)

      Struct.new(:timer, :logger, :report).new(timer, logger, report)
    end
  end
end

module SerialFaker
  def catch_output(&block)
    default = $stdout
    $stdout = StringIO.new
    block.call
    $stdout.string
  ensure
    $stdout = default
  end
end
