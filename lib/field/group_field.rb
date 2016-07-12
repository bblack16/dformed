module DFormed

  # A field that has multiple inputs
  # Such as key value pair type fields
  class GroupField < Field
    attr_reader :fields, :vertical

    def fields= fields
      @fields = Array.new
      fields.each do |f|
        field = (f.is_a?(Field) ? f : Field.create(f))
        @fields.push field
      end
    end

    def vertical= v
      @vertical = v == true
    end

    def self.type
      [:group, :group_field]
    end

    def value= val
      val.each do |k, v|
        begin
          @fields.find{ |f| f.name.to_s == k.to_s }.value = v
        rescue
        end
      end
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def to_element
        # row = Element[@html_template]
        # if @html_template.include?('label')
        #   if row.find('.label').size > 0
        #     row.find('.label').append(@label.to_element)
        #   else
        #     row.append(@label.to_element)
        #   end
        # end
        # if @html_template.include?('field')
        #   if row.find('.field').size > 0
        #     row.find('.field').append(@fields.map{ |f| f.to_element })
        #   else

          # end
        # end
        @element = super.append(@fields.map{ |f| f.to_element })
        # register_events
        # @element
      end

      def retrieve_values
        return nil unless @element
        @value = @fields.map do |field|
          [field.name, field.retrieve_values]
        end.to_h
      end

    end

    protected

      def inner_html
        # labels = @fields.map{ |f| "<th>#{f.label.to_html}</th>" }.join
        # fields = @fields.map do |f|
          # "<td>#{f.to_html}</td>"
        # end.join
        # @html_template.gsub(/\$label/i, labels).gsub(/\$fields/i, fields)
      end

      def setup_vars
        super
        @fields = Array.new
        @vertical = false
      end

      def serialize_fields
        super.merge(
          {
            fields: { send: :fields_to_h, unless: [] },
            vertical: { send: :vertical, unless: false }
          }
        )
      end

      def fields_to_h
        @fields.map{ |f| f.to_h rescue nil }
      end

  end

end
