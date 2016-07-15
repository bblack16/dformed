require_relative 'connection'

module DFormed

  module Connectable
    attr_reader :connections

    def add_connection c
      @connections = Hash.new unless @connections
      [c].flatten(1).each do |con|
        con = Connection.new(con) if con.is_a?(Hash)
        @connections << con if con.is_a?(Connection)
      end
    end

    alias_method :connections=, :add_connection

    def remove_connection index
      @connections.delete_at index
    end

    def check_connections elem
      return unless @connections
      @connections.each do |con|
        con.compare(self, elem)
      end
    end
    
    def serialize_fields
      super.merge(
        connections: { send: :serialize_connections, unless: [] }
      )
    end

    def serialize_connections
      return [] unless @connections
      @connections.map{ |c| c.to_h }
    end

  end

end
