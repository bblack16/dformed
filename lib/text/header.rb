
module DFormed

  class Header < Separator
    include Connectable
    attr_reader :title, :size

    def self.type
      :header
    end

    def size= num
      @size = num.to_i if (1..4) === num.to_i
      @tagname = "h#{@size}"
    end

    def title= title
      @title = title.to_s
    end

    alias_method :value=, :title=

    protected

      def inner_html
        @title
      end

      def setup_vars
        super
        self.size = 1
        @title = ''
      end

      def custom_init *args
        self.title = args.first if args.first.is_a?(String)
      end

      def serialize_fields
        super.merge(
          {
            title: { send: :title },
            size: { send: :size, unless: 1 }
          }
        )
      end

  end

end
