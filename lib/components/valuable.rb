# frozen_string_literal: true
# This module is used for Elements that should contain a value
# The methods added provide means of interacting with values from
# a generic Element and can be overwritten in subclasses if needed
module DFormed
  module Valuable
    attr_reader :value, :default
    @connections = {}
    @default = nil

    def value=(val)
      @element.value = val if element? && @value != val
      @value = val
    end

    def default=(d)
      @default = d
    end

    def value
      @value || @default
    end

    def clear
      return if attributes.include?(:readonly)
      value = nil
      @element.value = nil if element?
    end

    if DFormed.in_opal?

      def retrieve_value
        return nil unless @element
        @value = @element.value
      end

    end
  end
end
