
module DFormed

  class Label < ElementBase
    include Connectable
    attr_reader :name

    def name= lbl
      @name = lbl.to_s
      @element.text(@name) if element?
    end

    def self.type
      :label
    end

    alias_method :label=, :name=
    alias_method :value=, :name=
    alias_method :value, :name
    
    protected

      def inner_html
        @name
      end

      def setup_vars
        super
        @connections = Array.new
        @tagname     = 'label'
        @name        = ''
      end

      def custom_init *args
        self.name = args.first if args.first.is_a?(String)
      end

      def serialize_fields
        super.merge(
          {
            name: { send: :name },
            type: { send: :type }
          }
        )
      end

  end

end
