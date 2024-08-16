# frozen_string_literal: true

module Petrolex
  class Graph
    attr_reader :report

    def initialize(report:)
      @report = report
    end

    def elements
      nodes = []
      links = []

      {
        nodes:,
        links:
      }
    end

    def columns
      [
        { name: 'reserve', value: report.reserve },
        { name: 'fuel given', value: report.fuel_given },
        { name: 'cars in queue', value: report.waiting_count },
        { name: 'cars fueled', value: report.full_count },
        { name: 'cars partial', value: report.partial_count },
        { name: 'cars none', value: report.none_count },
        { name: 'cars unserved', value: report.unserved_count }
      ]
    end

    private

    def add_node(node, group)
      nodes << { id: node.to_s, group: }
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
  end
end
