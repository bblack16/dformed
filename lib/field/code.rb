
module DFormed

  class Code < Field

    def self.type
      [:code]
    end

    protected

      def inner_html
        "<code>#{value.to_s}</code>"
      end

      def setup_vars
        super
        @tagname = 'pre'
      end

  end

end
