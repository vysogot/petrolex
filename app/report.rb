module Petrolex
  class Report
    attr_reader :sheet

    def initialize
      @lock = Mutex.new
      @sheet = {}
    end

    def call(record:, state: nil)
      lock.synchronize do
        status = record.delete(:status)

        if state
          sheet[:reserve] = state[:reserve]
          sheet[:waiting] = state[:waiting]
        end

        sheet[status] ||= []
        sheet[status] << record
      end

      save_to_file
    end

    def fully_fueled = sheet[:full]&.size || 0
    def partially_fueled = sheet[:partial]&.size || 0
    def not_fueled = sheet[:none]&.size || 0
    def reserve = sheet[:reserve]
    def unserved = sheet[:unserved] && sheet[:unserved].first[:value] || 0

    def fuel_given
      [sheet[:full], sheet[:partial]].compact.flatten.sum { |record| record[:units_given] }
    end

    def data
      [
        { name: 'reserve', value: sheet[:reserve] },
        { name: 'cars in queue', value: sheet[:waiting] },
        { name: 'cars fueled', value: sheet[:full]&.size || 0 },
        { name: 'cars partial', value: sheet[:partial]&.size || 0 },
        { name: 'cars none', value: sheet[:none]&.size || 0 }
      ].flatten
    end

    private

    attr_reader :lock

    def save_to_file
      File.open('/Users/jgodawa/Downloads/new/data.json', 'w') do |file|
        file.write(data.to_json)
      end
    end
  end
end
