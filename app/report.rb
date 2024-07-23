module Petrolex
  class Report
    attr_reader :sheet

    def initialize
      @lock = Mutex.new
      @sheet = {}
    end

    def call(state: nil, record:)
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
