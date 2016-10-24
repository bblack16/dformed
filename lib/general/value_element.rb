
module DFormed

  class ValueElement < ElementBase
    attr_of Object, :value, :default, serialize: true, allow_nil: true, ignore: nil

    def value
      @value || @default
    end

    def value= val
      @element.value = val if element? && @value != val
      @value = val
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
        @value = @element.value
      end
      
    end

  end

end
