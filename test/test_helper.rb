require 'simplecov'
SimpleCov.start

require_relative '../app/petrolex'
require 'minitest/autorun'

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

    Timer.stub :wait, mock do
      yield
    end
  end
end
