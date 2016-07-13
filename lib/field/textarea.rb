
module DFormed

  class Textarea < Field

    def self.type
      [:textarea, :text_area]
    end
    
    def type
      :textarea
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
