# frozen_string_literal: true

module Petrolex
  class Report
    attr_reader :sheet, :nodes, :links

    def initialize
      @lock = Mutex.new
      @sheet = {}
      @nodes = []
      @links = []
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
        { name: 'fuel given', value: fuel_given },
        { name: 'cars in queue', value: sheet[:waiting] },
        { name: 'cars fueled', value: fully_fueled },
        { name: 'cars partial', value: partially_fueled },
        { name: 'cars none', value: not_fueled },
        { name: 'cars unserved', value: unserved },
      ]
    end

    def add_node(node, group)
      nodes << { id: node.to_s, group: group }
    end

    def add_link(source, target)
      links << { source: source.to_s, target: target.to_s, value: 1 }
    end

    def remove_node(source)
      nodes.delete_if { |node| node[:id] == source.to_s }
    end

    def remove_link(source, target)
      links.delete_if { |node| node[:source] == source.to_s && node[:target] == target.to_s }
    end

    def elements
      {
        nodes: nodes,
        links: links
      }
    end

    private

    attr_reader :lock
  end
end
