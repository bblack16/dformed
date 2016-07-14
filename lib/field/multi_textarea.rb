
module DFormed

  class MultiTextArea < MultiField

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
        @template = TextArea.new
      end

  end

end
