# frozen_string_literal: true

require_relative 'test_helper'

class QueueConsumerTest < Minitest::Test
  include ::QuietLogger

  def setup
    ENV['app_env'] = 'override_env'
  end

  def test_real_consumer_closes_after_tick
    # TODO: hard to do without getting stuck in a loop
    #
    # station = Station.new(is_open: true)
    # queue_consumer = QueueConsumer.new(station: station, closing_tick: 200)
    # queue_consumer.consumer.join

    # Timer.instance.stub :current_tick, 201 do
    #   refute station.is_open
    # end
  end

  def teardown
    ENV['app_env'] = 'test'
  end
end
