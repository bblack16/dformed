

# frozen_string_literal: true
module DFormed
  class KeyValue < Field
    attr_of Element, :key_field, :value_field, serialize: true, default: { type: :text }

    # def key_field=(field)
    #   set_field :key, field
    # end
    #
    # def value_field=(field)
    #   set_field :value, field
    # end
    #
    # def set_field(type, field)
    #   field = Element.create(field.include?(:type) ? field : field.values.first.merge(type: field.keys.first)) unless field.is_a?(Element)
    #   @key_field = field if type == :key
    #   @value_field = field if type == :value
    # end

    def self.type
      :key_value
    end

    def value=(val)
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
