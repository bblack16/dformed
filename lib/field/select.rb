
module DFormed

  class Select < Selectable

    def self.type
      :select
    end

    def type
      :select
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def retrieve_values
        self.value = @element.find('select').value
      end

    end

    protected

      def setup_vars
        super
        @label = 'Select'
        @tagname = 'select'
      end

      def inner_html
        @options.map do |k,v|
          selected = [value].flatten.include?(v)
          "<option value='#{k}'#{selected ? ' selected' : nil}>#{k}</option>"
        end.join("\n")
      end

      def serialize_fields
        super.merge(type: { send: :type })
      end

  end

end
