
module DFormed

  class Form < FormElement
    attr_reader :fields

    def field name
      @fields.find{ |f| f.name == name } rescue nil
    end

    def add *hashes
      hashes.each do |hash|
        if hash[:type]
          @fields.push ElementBase.create(hash, self)
        else # Supports a slightly different shorthand for convenience
          hash.each do |k, v|
            @fields.push ElementBase.create(v.merge(type: k), self)
          end
        end
      end
    end

    def remove index
      @fields.delete_at(index)
    end

    def values
      @fields.map{ |f| f.respond_to?(:value) ? [f.name, f.value] : nil }.reject{ |r| r.nil? }.to_h
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

      def retrieve_values
        @fields.map{ |f| f.respond_to?(:retrieve_values) ? [f.name, f.retrieve_values] : nil }.reject{ |r| r.nil? }.to_h
      end

    end

    def self.type
      :form
    end

    def type
      :form
    end

    protected

      def inner_html
        '<table class="fields"><tr>' +
        @fields.map do |field|
          field.to_html
        end.join('</tr><tr>') +
        '</tr></table>'
      end

      def setup_vars
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
