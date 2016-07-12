
module DFormed

  class Divider < FormElement

    protected

      def inner_html
        nil
      end

      def setup_vars
        super
        @tagname = 'hr'
      end

      def serialize_fields
        {}
      end

  end

end
