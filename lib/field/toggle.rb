# frozen_string_literal: true
module DFormed
  class Toggle < Field
    attr_bool :value, default: false, serialize: true, always: true
    serialize_method :attributes, :clean_attributes, ignore: {}

    after :setup_attributes, :value=, :default=

    def self.type
      :toggle
    end

    def validate
      true
    end

    def toggle
      value = !value
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def retrieve_value
        self.value = element.prop('checked')
      end

      def to_element
        super
        setup_attributes
      end

    end

    protected

    def inner_html
      nil
    end

    def simple_setup
      super
      self.tagname = 'input'
      setup_attributes
    end

    def setup_attributes
      add_attribute(name: name, type: :checkbox)
      element.prop(:checked, value) if element?
    end

    def clean_attributes
      temp = attributes.dup
      temp.delete(:name)
      temp.delete(:type)
      temp
    end

  end
end
