require_relative 'connection'

module DFormed

  module Connectable
    attr_reader :connections
    @connections = Hash.new

    def add_connection c
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
    
    def serialize_connections
      @connections.map{ |c| c.to_h }
    end

  end

end
