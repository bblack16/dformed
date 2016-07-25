
# This module is used for Elements that should contain a value
# The methods added provide means of interacting with values from
# a generic ElementBase and can be overwritten in subclasses if needed
module DFormed

  module Valuable
    attr_reader :value, :default
    @connections = Hash.new
    @default = nil

    def value= val
      @value = val
      @element.value = val if element?
    end

    def default= d
      @default = d
    end

    def value
      @value || @default
    end

    def clear
      return if attributes.include?(:readonly)
      value = nil
      if element?
        @element.value = nil
      end
    end

    if DFormed.in_opal?

      def retrieve_value
        return nil unless @element
        self.value = @element.value
      end

    end

  end

end
