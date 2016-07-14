module DFormed

  # A field that has multiple inputs
  # Such as key value pair type fields
  class GroupField < Field
    attr_reader :fields, :last_id

    def fields= fields
      @fields = Array.new
      fields.each do |f|
        field = (f.is_a?(Field) ? f : ElementBase.create(f))
        field.name = next_id if field.respond_to?(:name=) && field.name.to_s == ''
        @fields.push field
      end
    end

    def self.type
      [:group_field, :group]
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
        @element = super.append(@fields.map{ |f| f.to_element })
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
        @fields.map do |f|
          f.to_html
        end.join
      end

      def setup_vars
        @last_id = 0
        super
        @fields = Array.new
      end

      def serialize_fields
        super.merge(
          {
            fields: { send: :fields_to_h, unless: [] }
          }
        )
      end

      def fields_to_h
        @fields.map{ |f| f.to_h rescue nil }
      end

  end

end
