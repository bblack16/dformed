module DFormed
  class MultiField < ValueElement

    attr_int_between 0, nil, :min, default: 0
    attr_int_between 0, nil, :max, default: nil, allow_nil: true
    attr_of Element, :template
    attr_bool :cloneable, :moveable, default: true
    attr_bool :hide_buttons, default: false
    attr_of Element, :add_button, default: Button.new(label: '+')
    attr_of Element, :remove_button, default: Button.new(label: '-')
    attr_of Element, :up_button, default: Button.new(label: '^')
    attr_of Element, :down_button, default: Button.new(label: 'v')
    attr_ary :value, default: [], add_rem: true
    attr_ary :fields, default: [], serialize: false
    attr_str :empty_text, default: '<i>None</i>'
    attr_int :id, default: -1
    attr_hash :row_attributes, default: {}

    def empty?
      value.empty?
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
      @element = Element[to_html] unless element?
      build_fields
      if fields.empty?
        element.append(empty_element)
      else
        fields.each do |field|
          row = build_row(field)
          element.append(row)
        end
      end
      element
    end

    def retrieve_value
      return [] unless element? && !fields.empty?
      order = element.children('.multi-field-row').map { |elem| elem.attr('dformed-index') }
      self.value = [].tap do |result|
        order.each do |index|
          result.push(fields[index.to_i].retrieve_value)
        end
      end
    end

    def build_row(field, index = self.id += 1)
      field.add_attribute('dformed-index': index)
      tag = BBLib::HTML.build(:div, **row_attributes.deep_merge(context: field, class: ['multi-field-row'])) do
        add context.to_tag unless BBLib.in_opal?
      end
      return tag unless BBLib.in_opal?
      Element[tag].tap do |row|
        row.append(field.to_element)
        row.append(build_buttons)
      end
    end

    def build_buttons
      buttons = []
      buttons << build_add_button << build_remove_button << build_up_button << build_down_button
      buttons.compact
    end

    def build_add_button
      return nil unless cloneable && !hide_buttons
      add_button.clone.to_element.tap do |btn|
        btn.add_class(:add)
        btn.on :click do |evt|
          next if max && fields.size >= max
          field = build_field
          row   = build_row(field)
          if fields.empty?
            element.find('.multi-field-empty').replace_with(row)
          else
            evt.element.closest('.multi-field-row').after(row)
          end
          fields << field
        end
      end
    end

    def build_remove_button
      return nil unless cloneable && !hide_buttons
      remove_button.clone.to_element.tap do |btn|
        btn.add_class(:remove)
        btn.on :click do |evt|
          next if min && fields.size <= min
          elem = evt.element.closest('div[dformed-index]')
          index = elem.attr('dformed-index').to_i
          row = evt.element.closest('.multi-field-row')
          index = row.attr('dformed-index').to_i
          field = fields.find { |f| f.attributes[:'dformed-index'] == index }
          fields.delete(field)
          row.remove
          element.append(empty_element) if fields.empty?
        end
      end
    end

    def build_up_button
      return nil unless moveable && !hide_buttons
      up_button.clone.to_element.tap do |btn|
        btn.add_class(:up)
        btn.on :click do |evt|
          move(evt, :up)
        end
      end
    end

    def build_down_button
      return nil unless moveable && !hide_buttons
      down_button.clone.to_element.tap do |btn|
        btn.add_class(:down)
        btn.on :click do |evt|
          move(evt, :down)
        end
      end
    end

    def move(event, position = :up)
      mover = event.element.closest('.multi-field-row')
      swapper = (position == :up ? mover.prev : mover.next)
      return unless swapper.first && !swapper.empty?
      mover.detach
      position == :up ? mover.insert_before(swapper) : mover.insert_after(swapper)
      refresh_buttons
    end

    def refresh_buttons
      # TODO disable buttons when they can no longer be used.
    end

    def build_fields
      self.fields = [].tap do |ary|
        value.each do |v|
          ary << build_field(v)
        end
        ary << build_field while ary.size < min
      end
    end

    def build_field(value = :_nil_)
      template.clone.tap do |field|
        field.value = value unless value == :_nil_
      end
    end

    def empty_field
      BBLib::HTML.build(:div, empty_text, class: 'multi-field-empty')
    end

    protected

    def empty_element
      raise BBLib::WrongEngineError, 'Cannot create elements outside of Opal.' unless BBLib.in_opal?
      Element[empty_field.to_s].tap do |elem|
        elem.append(build_add_button)
      end
    end

    def _init_ignore
      super + [:values]
    end

    # Updates the DOM element. Called every time value= is.
    def update_element_value(value)
      true
    end
  end
end
