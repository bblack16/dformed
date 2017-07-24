# frozen_string_literal: true
module DFormed
  # A field that can be cloned and chopped.
  # Basically, a field that can have multiple instances of itself
  class MultiField < Field
    DEFAULT_BUTTONS = {
      add:    DFormed::Button.new(label: '+'),
      remove: DFormed::Button.new(label: '-'),
      up:     DFormed::Button.new(label: '^'),
      down:   DFormed::Button.new(label: 'v')
    }.map { |n, b| [n, b.serialize] }.to_h

    EMPTY_TEXT = '<i>Empty</i>'

    attr_int_between 0, nil, :min, default: 0, serialize: true
    attr_int_between 0, nil, :max, default: nil, allow_nil: true, serialize: true
    attr_int_between 1, nil, :per_col, default: 1, serialize: true
    attr_of Element, :template, serialize: true
    attr_bool :cloneable, :moveable, default: true, serialize: true
    attr_bool :hide_buttons, default: false, serialize: true
    attr_hash :buttons, serialize: true, ignore: DEFAULT_BUTTONS
    attr_array :value, default: [], add_rem: true, serialize: true
    attr_array :default, default: [], add_rem: true, serialize: true
    attr_array :fields, default: [], serialize: false
    attr_str :empty_text, default: EMPTY_TEXT, serialize: true

    def self.type
      [:multi_field, :mf, :multi]
    end

    def template=(t)
      @template = t.is_a?(Element) ? t : Element.create(t, parent)
    end

    def values
      value || default
    end

    def size
      fields.size
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def to_element
        element.empty if element?
        fields.clear
        reset_ids
        self.element = Element['<div class="multi_container"/>'] unless element?
        generate_fields
        if fields.empty?
          refresh_empty
        else
          element.find('.empty_placeholder').remove
          fields.each_with_index do |ef, i|
            ef.labeled = false if i.positive? && ef.is_a?(GroupField)
            id = next_id
            ef.add_attribute(mgf_sort: id)
            row = Element["<div class='multi_field' mgf_sort='#{id}'/>"]
            row.append(ef.to_element)
            element.append(row)
          end
          refresh_buttons
        end
        register_events
        element
      end

      def refresh_buttons
        retrieve_value
        element.find('.multi_field').each_with_index do |elem, indx|
          elem.find('button').remove
          buttons = [
            add_button(max && size >= max),
            remove_button(size <= min),
            up_button(indx.zero?),
            down_button(indx == (size-1))
          ].compact
          elem.append(buttons)
        end
      end

      def refresh_empty
        row = Element["<div class='multi_field empty_placeholder'>#{empty_text}</div>"]
        row.append(add_button)
        element.append(row)
      end

      def retrieve_value
        return [] unless element && !fields.empty?
        order = element.children('.multi_field').map { |e| e.attr(:mgf_sort) }
        result = []
        order.each { |i| result.push(fields[i.to_i].retrieve_value) if fields[i.to_i] }
        self.value = result
      end

      def clone(event)
        id  = next_id
        row = Element["<div class='multi_field' mgf_sort=#{id}/>"]
        if fields.empty?
          elm   = event.element.closest('div.empty_placeholder')
          new_f = generate_field
          new_f.add_attribute(mgf_sort: id)
          row.append(new_f.to_element)
          elm.replace_with(row)
        else
          elm   = event.element.closest('div[mgf_sort]')
          sort  = elm.attr(:mgf_sort).to_i
          f     = fields.find { |fl| fl.attributes[:mgf_sort].to_i == sort }
          new_f = generate_field f.value
          new_f.add_attribute(mgf_sort: id)
          row.append new_f.to_element
          elm.after(row)
        end
        self.fields.push(new_f)
        refresh_buttons
      end

      def chop(event)
        elm = event.element.closest('div[mgf_sort]')
        sort = elm.attr(:mgf_sort).to_i
        f = fields.find { |fl| fl.attributes[:mgf_sort].to_i == sort }
        fields.delete(f)
        elm.remove
        refresh_buttons
        refresh_empty if fields.empty?
      end

      # Uses an event to move a field up or down in the current order
      def move(event, position = :up)
        mover = event.element.closest('.multi_field')
        swapper = (position == :up ? mover.prev : mover.next)
        a = mover.clone
        b = swapper.clone
        mover.replace_with b
        swapper.replace_with a
        refresh_buttons
      end

      def add_button(disabled = false)
        return nil unless cloneable && (!disabled || !hide_buttons)
        btn = Element.create(buttons[:add].to_h)
        btn.disable(disabled)
        btn = btn.to_element
        btn.on :click do |evt|
          clone evt
        end
        btn
      end

      def remove_button(disabled = false)
        return nil unless cloneable && (!disabled || !hide_buttons)
        btn = Element.create(buttons[:remove].to_h)
        btn.disable(disabled)
        btn = btn.to_element
        btn.on :click do |evt|
          chop evt
        end
        btn
      end

      def up_button(disabled = false)
        return nil unless moveable && (!disabled || !hide_buttons)
        btn = Element.create(buttons[:up].to_h)
        btn.disable(disabled)
        btn = btn.to_element
        btn.on :click do |evt|
          move evt, :up
        end
        btn
      end

      def down_button(disabled = false)
        return nil unless moveable && (!disabled || !hide_buttons)
        btn = Element.create(buttons[:down].to_h)
        btn.disable(disabled)
        btn = btn.to_element
        btn.on :click do |evt|
          move evt, :down
        end
        btn
      end

    end

    protected

    def simple_setup
      reset_ids
      super
      self.buttons = default_buttons
    end

    def default_buttons
      {
        add:    DFormed::Button.new(label: '+'),
        remove: DFormed::Button.new(label: '-'),
        up:     DFormed::Button.new(label: '^'),
        down:   DFormed::Button.new(label: 'v')
      }
    end

    def next_id
      @last_id += 1
    end

    def reset_ids
      @last_id = -1
    end

    def generate_fields
      values.each do |h|
        fields.push generate_field(h)
      end
      fields.push generate_field while fields.size < min
    end

    def generate_field(val = nil)
      Element.create(template.to_h.merge(value: val), parent)
    end
  end
end
