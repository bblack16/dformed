
module DFormed

  class Form < FormElement
    include Valuable
    attr_reader :fields, :last_id

    def field name
      @fields.find{ |f| f.name == name } rescue nil
    end

    def add *hashes
      hashes.each do |hash|
        elem = nil
        if hash[:type]
          elem = ElementBase.create(hash, self)
        else # Supports a slightly different shorthand for convenience
          hash.each do |k, v|
            elem = ElementBase.create(v.merge(type: k), self)
          end
        end
        elem.name = next_id if elem.respond_to?(:name=) && elem.name.to_s == ''
        @fields.push elem
      end
    end

    def remove index
      @fields.delete_at(index)
    end

    def value
      @fields.map{ |f| f.respond_to?(:value) ? [f.name, f.value] : nil }
        .reject{ |r| r.nil? }.to_h
    end

    def value= values
      @values = {}
      set values
    end

    def set hash
      hash.each do |k, v|
        field = @fields.find{ |f| f.name == k.to_s }
        if field
          field.value = v
        end
      end
    end

    def clear
      @fields.each{ |f| f.clear }
    end

    def field_changed field
      @fields.each{ |f| f.check_connections(field) if f.respond_to?(:check_connections) }
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def delete
        @element.remove if element?
      end

      def to_element
        header = "<table class='fields'></table>"
        @element = Element[header]
        @fields.each do |field|
          row = Element['<tr class="form_row"/>']
          row.append(field.to_element)
          @element.append(row)
        end
        @element
      end

      def retrieve_value
        @fields.map{ |f| f.respond_to?(:retrieve_value) ? [f.name, f.retrieve_value] : nil }
          .reject{ |r| r.nil? }.to_h
      end

    end

    def self.type
      :form
    end

    protected

      def next_id
        (@last_id += 1).to_s
      end

      def inner_html
        '<table class="fields"><tr>' +
        @fields.map do |field|
          field.to_html
        end.join('</tr><tr>') +
        '</tr></table>'
      end

      def setup_vars
        @last_id = 0
        super
        @fields = Array.new
        @element_type = 'div'
      end

      def custom_init *args
        hash = args.find{ |a| a.is_a?(Hash) }
        if hash && hash.include?(:fields)
          hash[:fields].each do |field|
            add field
          end
        end
      end

      def serialize_fields
        super.merge(
          {
            fields: { send: :fields_to_h },
            type: { send: :type }
          }
        )
      end

      def fields_to_h
        @fields.map{ |f| f.to_h }
      end

  end

end
