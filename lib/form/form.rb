# frozen_string_literal: true
module DFormed
  class Form < ValueElement
    after :fields=, :add_fields, :check_field_names

    attr_array_of Element, :fields, default: [], serialize: true, add_rem: true
    dont_serialize_method :value

    alias add add_fields
    alias add_field add_fields

    def field(name)
      fields.find { |f| f.name == name } rescue nil
    end

    def remove(*names)
      names.map do |name|
        fields.delete_if { |f| f.name.to_s == name.to_s rescue false }
      end.flatten
    end

    def remove_at(index)
      fields.delete_at(index)
    end

    def replace(name, field)
      index = index_of(name)
      raise ArgumentError, "Cannot find a matching field to replace for '#{name}'." unless index
      fields[index] = Element.create(field)
    end

    def replace_at(index, field)
      fields[index] = Element.create(field)
    end

    def index_of(name)
      fields.each_with_index do |f, x|
        return x if (f.name.to_s == name.to_s) || name == f
      end
      nil
    end

    def value
      fields.map { |f| f.is_a?(Element) && f.respond_to?(:value) ? [f.name, f.value] : nil }
             .compact.to_h
    end

    def value=(values)
      @values = {}
      set values
    end

    alias values= value=

    def set(hash)
      hash.each do |k, v|
        field = fields.find { |f| f.name == k.to_s }
        field.value = v if field
      end
    end

    def get(name)
      fields.find { |f| f.name.to_s == name.to_s }
    end

    def vget(name)
      get(name).value
    end

    def clear
      fields.each { |f| f.clear if f.respond_to?(:clear) }
    end

    def field_changed(field)
      fields.each { |f| f.check_connections(field) if f.respond_to?(:check_connections) }
    end

    def change_all_fields
      fields.each { |f| field_changed f }
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def delete
        element.remove if element?
      end

      def to_element
        header = "<table class='fields'></table>"
        @element = Element[header]
        fields.each do |field|
          row = Element['<tr class="form_row"/>']
          row.append(field.to_element)
          element.append(row)
        end
        change_all_fields
        element
      end

      def retrieve_value
        fields.map { |f| f.respond_to?(:retrieve_value) ? [f.name, f.retrieve_value] : nil }
               .reject(&:nil?).to_h
      end

      def reregister_field_events
        fields.each { |f| f.reregister_events rescue nil }
      end

    end

    def self.type
      :form
    end

    protected

    def check_field_names
      fields.each do |field|
        field.parent = self
        used = [nil]
        count = 0
        while used.include?(field.name)
          field.name = "#{field.name}#{count += 1}"
        end
        used.push(field.name)
      end
    end

    def inner_html
      '<table class="fields"><tr>' +
        fields.map(&:to_html).join('</tr><tr>') +
        '</tr></table>'
    end
  end
end
