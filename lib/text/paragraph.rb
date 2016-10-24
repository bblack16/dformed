
module DFormed

  class Paragraph < Separator
    attr_str :body, serialize: true

    def self.type
      [:paragraph, :p]
    end

    def body= body
      @body = body.to_s
    end

    alias_method :value=, :body=

    protected

      def inner_html
        @body
      end

      def lazy_setup
        super
        @tagname = 'p'
      end

      def lazy_init *args
        self.body = args.first if args.first.is_a?(String)
      end

  end

end
