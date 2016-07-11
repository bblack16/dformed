
module DFormed

  class Paragraph < ElementBase
    attr_reader :body

    def body= body
      @body = body.to_s
    end

    protected

      def inner_html
        @body
      end

      def setup_vars
        super
        @tagname = 'p'
        @body = ''
      end

      def custom_init *args
        self.body = args.first if args.first.is_a?(String)
      end

      def serialize_fields
        {
          body: { send: :body }
        }
      end

  end

end
