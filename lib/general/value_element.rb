
# frozen_string_literal: true
module DFormed
  class ValueElement < Element
    attr_of Object, :value, :default, serialize: true, allow_nil: true, ignore: nil

    def value
      @value ||= default
    end

    def value=(val)
      element.value = val if element? && value != val
      @value = val
    end

    def clear
      return if attributes.include?(:readonly)
      value = nil
      element.value = nil if element?
    end

    if DFormed.in_opal?

      def retrieve_value
        return nil unless element
        @value = element.value
      end

    end
  end
end
