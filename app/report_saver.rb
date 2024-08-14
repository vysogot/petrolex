# frozen_string_literal: true

module Petrolex
  class ReportSaver
    attr_reader :sheet

    def call(stats:, elements:)
      File.open('./frontend/data.json', File::RDWR|File::CREAT, 0644) do |file|
        file.flock(File::LOCK_EX)
        file.rewind
        file.write(stats.to_json)
        file.flush
        file.truncate(file.pos)
      end

      File.open('./frontend/d3.json', File::RDWR|File::CREAT, 0644) do |file|
        file.flock(File::LOCK_EX)
        file.rewind
        file.write(elements.to_json)
        file.flush
        file.truncate(file.pos)
      end
    end
  end
end