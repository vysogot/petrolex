require 'simplecov'
SimpleCov.start

require_relative '../app/petrolex'
require 'minitest/autorun'

Timer.setup(simulation_speed: 100)

module TestHelper
  def run
    Logger.stub :info, nil do
      super
    end
  end

  private

  def stub_waiting(&block)
    mock = Minitest::Mock.new
    def mock.wait; nil; end

    Timer.instance.stub :wait, mock do
      yield
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
