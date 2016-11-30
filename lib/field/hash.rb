# frozen_string_literal: true
module DFormed
  class HashField < MultiField
    DEFAULT_BUTTONS = {
      options: DFormed::Select.new(class: 'option'),
      add:     DFormed::Button.new(label: '+'),
      remove:  DFormed::Button.new(label: '-'),
      up:      DFormed::Button.new(label: '^'),
      down:    DFormed::Button.new(label: 'v')
    }.map { |n, b| [n, b.serialize] }.to_h

    attr_hash :value, default: {}, add_rem: true, serialize: true
    attr_of KeyValue, :template, serialize: true, default: { type: :key_value, key_field: { type: :text }, value_field: { type: :text } }
    attr_array :default, default: {}, add_rem: true, serialize: true
    attr_hash :options, default: { text: 'String', number: 'Integer', toggle: 'Boolean', multi_text: 'Array', hash: 'Hash', textarea: 'Text' }

    after :change_options, :options=

    def self.type
      [:hash_field, :hash]
    end

    def values
      super.to_a.map { |a| { a.first => a.last } }
    end

    if DFormed.in_opal?
      def retrieve_value
        @value = super.each_with_object({}) { |a, h| h.merge!(a) }
      end
    end

    def clone(event)
      id   = next_id
      row  = Element["<div class='multi_field' mgf_sort=#{id}/>"]
      type = event.element.siblings('.option').value
      puts "TYPE: #{type}"
      if @fields.empty?
        elm   = event.element.closest('div.empty_placeholder')
        new_f = generate_field(type)
        new_f.add_attribute(mgf_sort: id)
        row.append(new_f.to_element)
        elm.replace_with(row)
      else
        elm   = event.element.closest('div[mgf_sort]')
        sort  = elm.attr(:mgf_sort).to_i
        f     = @fields.find { |fl| fl.attributes[:mgf_sort].to_i == sort }
        new_f = generate_field(type, f.value)
        new_f.add_attribute(mgf_sort: id)
        row.append new_f.to_element
        elm.after(row)
      end
      @fields.push new_f
      refresh_buttons
    end

    def options_elem
      opts = Element.create(@buttons[:options].to_h)
      opts.to_element
    end

    def refresh_buttons
      retrieve_value
      @element.find('.multi_field').each_with_index do |elem, indx|
        elem.find('button').remove
        # elem.find('.option').remove
        buttons = [
          # options_elem,
          add_button(!@max.nil? && size >= @max),
          remove_button(size <= @min),
          up_button(indx.zero?),
          down_button(indx == (size-1))
        ].compact
        elem.append(options_elem) unless elem.find('.option').size > 0
        elem.append(buttons)
      end
    end

    protected

    def lazy_setup
      super
      change_options
    end

    def default_buttons
      {
        options: DFormed::Select.new(class: 'option'),
        add:     DFormed::Button.new(label: '+'),
        remove:  DFormed::Button.new(label: '-'),
        up:      DFormed::Button.new(label: '^'),
        down:    DFormed::Button.new(label: 'v')
      }
    end

    def generate_fields
      values.each do |h|
        @fields.push generate_field(type_guess(h.values.first), h)
      end
      @fields.push generate_field(:text) while @fields.size < @min
    end

    def generate_field(type, val = nil)
      new_field = Element.create(@template.to_h, @parent)
      new_field.value_field = Element.create(type: type || :text)
      new_field.value = val
      new_field
    end

    def change_options
      @buttons[:options].options = @options
    end

    def type_guess value
      case value
      when String, NilClass
        value.to_s.size > 100 ? :textarea : :text
      when Numeric
        :number
      when TrueClass, FalseClass
        :toggle
      when Array
        :array_field
      when Hash
        :hash_field
      else
        :text
      end
    end
  end

end
