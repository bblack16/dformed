
module DFormed

  class Label < ElementBase
    attr_reader :name

    def name= lbl
      @name = lbl.to_s
    end

    alias_method :label=, :name=

    protected

      def inner_html
        @name
      end

      def setup_vars
        super
        @tagname = 'label'
        @name = ''
      end

      def custom_init *args
        self.name = args.first if args.first.is_a?(String)
      end

      def serialize_fields
        {
          name: { send: :name }
        }
      end

  end

end
