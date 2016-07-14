
module DFormed

  class Paragraph < Separator
    include Connectable
    attr_reader :body

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

      def setup_vars
        super
        @tagname = 'p'
        @body = ''
      end

      def custom_init *args
        self.body = args.first if args.first.is_a?(String)
      end

      def serialize_fields
        super.merge(
          {
            body: { send: :body },
            connections: { send: :serialize_connections, unless: [] }
          }
        )
      end

  end

end
