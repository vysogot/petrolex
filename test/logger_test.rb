# frozen_string_literal: true

require_relative 'test_helper'

module Petrolex
  describe Logger do
    include SerialFaker

    FakeTimer = Struct.new(:current_tick)

    it 'formats info messages with zero-padded tick prefix' do
      logger = Logger.new(timer: FakeTimer.new(15), silent: false)
      output = catch_output { logger.info('hello') }
      assert_match '000015: hello', output
    end

    it 'prints messages without tick prefix' do
      logger = Logger.new(timer: FakeTimer.new(0), silent: false)
      output = catch_output { logger.print('standalone message') }
      assert_match 'standalone message', output
    end

    it 'suppresses info output when silent' do
      logger = Logger.new(timer: FakeTimer.new(0), silent: true)
      output = catch_output { logger.info('should be hidden') }
      _(output).must_be_empty
    end

    it 'suppresses print output when silent' do
      logger = Logger.new(timer: FakeTimer.new(0), silent: true)
      output = catch_output { logger.print('should be hidden') }
      _(output).must_be_empty
    end
  end
end
