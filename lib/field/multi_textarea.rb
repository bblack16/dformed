
module DFormed

  class Textarea < MultiField

    def self.type
      [:multi_textarea, :multi_text_area]
    end

    protected

      def inner_html
        value.to_s
      end

      def setup_vars
        super
        @tagname = 'textarea'
      end

  end

end
