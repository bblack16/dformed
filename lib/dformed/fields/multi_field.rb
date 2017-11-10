module DFormed
  class MultiField < ValueElement

    attr_int_between 0, nil, :min, default: 0
    attr_int_between 0, nil, :max, default: nil, allow_nil: true
    attr_of Element, :template
    attr_bool :cloneable, :moveable, default: true
    attr_bool :hide_buttons, default: false
    attr_of Element, :add_button, :remove_button, :up_button, :down_button
    attr_ary :value, default: [], add_rem: true
    attr_ary :fields, default: [], serialize: false
    attr_str :empty_text, default: '<i>None</i>'
    attr_int :id, default: -1

    alias values value
    alias values= value=

    def empty?
      values.empty?
    end

    def to_tag
      BBLib::HTML.build(:div, **full_attributes.merge(context: self)) do
        unless BBLib.in_opal?
          if context.empty?
            add context.empty_field
          else
            add context.build_fields.map(&:to_tag)
          end
        end
      end
    end

    def to_element
      raise BBLib::WrongEngineError, 'Cannot cast to element when outside of Opal.' unless BBLib.in_opal?
      element.empty if element?
      fields.clear
      self.id = -1
      self.element = Element[to_html] unless element?
      self.fields = build_fields
      fields.each do |field|
        row = Element[build_row(field, self.id += 1)]
        element.append(row)
      end
    end

    def build_row(field, index = self.id += 1)
      BBLib::HTML.build(:div, context: field, class: 'multi-field-row', 'dformed-index': index) do
        add context.to_tag
        add context.build_buttons
      end
    end

    def build_buttons
      buttons = []
      buttons << build_add_button << build_remove_button << build_up_button << build_down_button
      buttons.compact
    end

    def build_add_button
      return nil unless cloneable && !hide_buttons
      add_button.clone.tap do |btn|
        btn.on :click do |evt|
          field = build_field
          row   = build_row(field)
          if fields.empty?
            element.find('.multi-field-empty').replace_with(row)
          else
            evt.element.after(row)
          end
          fields << field
        end
      end
    end

    def build_remove_button
      return nil unless cloneable && !hide_buttons
      remove_button.clone.tap do |btn|
        btn.on :click do |evt|
          row = evt.element.closest('.multi-field-row')
          index = row.attr('dformed-index').to_i
          field = fields.find { |f| f.attributes[:'dformed-index'].to_i == sort }
          fields.delete(field)
          row.remove
        end
      end
    end

    def build_up_button
      return nil unless moveable && !hide_buttons
      up_button.clone.tap do |btn|
        btn.on :click do |evt|
          move(evt, :up)
        end
      end
    end

    def build_down_button
      return nil unless moveable && !hide_buttons
      up_button.clone.tap do |btn|
        btn.on :click do |evt|
          move(evt, :down)
        end
      end
    end

    def move(event, position = :up)
      mover = event.element.closest('.multi-field-row')
      swapper = (position == :up ? mover.prev : mover.next)
      a = mover.clone
      b = swapper.clone
      mover.replace_with b
      swapper.replace_with a
      refresh_buttons
    end

    def build_fields
      [].tap do |fields|
        values.map do |value|
          fields << build_field(value)
        end
        fields << build_field while fields.size < min
      end
    end

    def build_field(value = nil)
      template.clone.tap do |field|
        field.value = value
      end
    end

    def empty_field
      BBLib::HTML.build(:div, empty_text, class: 'multi-field-empty')
    end

    protected

    def _init_ignore
      super + [:values]
    end
  end
end
