# frozen_string_literal: true
module DFormed
  class VariableField < Field
    DEFAULT_FIELDS = [
      { type: :text },
      { type: :textarea },
      { type: :number },
      { type: :toggle },
      { type: :'datetime-local' }
    ].freeze

    attr_ary_of Element, :fields, default: DEFAULT_FIELDS, serialize: true
    attr_of Element, :field, default: { type: :text }, serialize: false

    after :apply_parent, :field=

    def self.type
      [:variable, :variable_field]
    end

    def value
      { field.type.to_sym => field.value }
    end

    def field_changed(field)
      updated(field)
    end

    def value=(val)
      if val.is_a?(Hash)
        change_field(val.keys.first.to_sym)
        field.value = val.values.first
      else
        field.value = val
      end
    end

    def change_field(type)
      template = fields.find { |f| f.type.to_s == type.to_s }.serialize rescue {}
      self.field = Element.create(template.merge(type: type.to_sym, value: retrieve_value.first.last))
      to_element
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def to_element
        if element?
          element.children.remove
        else
          @element = super
        end
        element.append(field.to_element, type_select)
        element
      end

      def retrieve_value
        { field.type.to_sym => field.retrieve_value }
      end

      def type_select
        select = Element['<select class="variable_select"/>']
        fields.each do |field|
          select.append("<option value='#{field.type}'#{field.type.to_s == self.field.type.to_s ? ' selected=true' : nil}>#{field.type.to_s.gsub('_', ' ').title_case}</option>")
        end
        select.on :change do |evt|
          change_field(evt.element.value)
        end
        select
      end

    end

    protected

    def apply_parent
      field.parent = self
    end

  end
end
