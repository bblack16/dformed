# frozen_string_literal: true
module DFormed
  # A field that has multiple inputs
  # Such as key value pair type fields
  class GroupField < Field
    attr_ary_of Element, :fields, default: [], serialize: true
    attr_int :last_id, default: 0
    attr_bool :labeled, default: true, serialize: true

    def fields=(fields)
      @fields = []
      fields.each do |f, v|
        if v.nil?
          field = (f.is_a?(Field) ? f : Element.create(f))
          field.name = next_id if field.respond_to?(:name=) && field.name.to_s == ''
          @fields.push field
        else
          @fields.push(Element.create(v.merge(type: f)))
        end
      end
      @fields.each { |f| f.add_attribute(dfield_name: f.name) }
    end

    def self.type
      [:group_field, :group]
    end

    def value
      @fields.map { |f| [f.name.to_sym, f.value] }.to_h
    end

    def value=(val)
      val.each do |k, v|
        begin
          @fields.find { |f| f.name.to_s == k.to_s }.value = v
        rescue => e
          # Do Nothing???
        end
      end
    rescue => e
      # Do Nothing???
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def to_element
        if @labeled
          body = Element[
            '<table><thead><tr>' +
            @fields.map { |f| "<th>#{f.name.to_s.tr('_', ' ').title_case}</th>" }.join +
            '</tr></thead><tbody><tr id="fields"/></tbody></table>'
          ]
          @fields.each do |f|
            td = Element['<td>']
            td.append(f.to_element)
            body.find('#fields').append(td)
          end
          @element = body
        else
          @element = super.append(@fields.map(&:to_element))
        end
      end

      def retrieve_value
        return nil unless @element
        @value = @fields.map do |field|
          [field.name, field.retrieve_value]
        end.to_h
      end

    end

    protected

    def next_id
      (@last_id += 1).to_s
    end

    def inner_html
      return nil if DFormed.in_opal?
      @fields.map(&:to_html).join
    end
  end
end
