
module DFormed

  class Header < ElementBase
    attr_reader :title

    def title= title
      @title = title.to_s
    end

    protected

      def inner_html
        @title
      end

      def setup_vars
        super
        @tagname = 'h1'
        @title = ''
      end

      def custom_init *args
        self.title = args.first if args.first.is_a?(String)
      end

      def serialize_fields
        {
          title: { send: :title }
        }
      end

  end

end
