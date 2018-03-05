module DFormed
  class KeyValue < ValueElement
    attr_ary :value, default: ['', '']
    attr_of Element, :key_field, default_proc: proc { Text.new(name: :key) }
    attr_of Element, :value_field, default_proc: proc { Text.new(name: :value) }

    def to_tag
      BBLib::HTML.build(:span, **full_attributes) do
        unless BBLib.in_opal?
          add key_field.to_tag
          add value_field.to_tag
        end
      end
    end

    def to_element
      super.tap do |element|
        element.append(key_field.to_element)
        element.append(value_field.to_element)
      end
    end

    def clear
      return if attributes.include?(:readonly) && attributes[:readonly]
      self.value = ['', '']
    end

    def retrieve_value
      return value unless element?
      @value = [key_field.retrieve_value, value_field.retrieve_value]
    end

    def update_element_value(value)
      value = [value].flatten unless value.is_a?(Array)
      key_field.value = value.first
      value_field.value = value[1]
    end

  end
end
