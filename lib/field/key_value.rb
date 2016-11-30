

# frozen_string_literal: true
module DFormed
  class KeyValue < Field
    attr_of Element, :key_field, :value_field, serialize: true, default: { type: :text }

    def self.type
      :key_value
    end

    def value=(val)
      return unless val
      val.each do |k, v|
        @key_field.value = k if @key_field
        @value_field.value = v if @value_field
      end
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def to_element
        @element = super.append(@key_field.to_element, @value_field.to_element)
      end

      def retrieve_value
        { @key_field.retrieve_value => @value_field.retrieve_value }
      end

    end

    protected

    def inner_html
      return nil if DFormed.in_opal?
      [@key_field.to_html, @value_field.to_html].join
    end
  end
end
