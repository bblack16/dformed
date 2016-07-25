
module DFormed

  class Label < ElementBase
    include Connectable
    attr_reader :label

    def label= lbl
      @label = lbl.to_s
      @element.text(@label) if element?
      self.name = @label.downcase.gsub(/\W|\s/,'_').gsub(/\_+/, '_') + '_label' if @name.to_s == ''
    end

    def self.type
      :label
    end

    # alias_method :label=, :name=
    alias_method :value=, :label=
    # alias_method :value, :label
    
    protected

      def inner_html
        @label
      end

      def setup_vars
        super
        @connections = Array.new
        @tagname     = 'label'
      end

      def custom_init *args
        self.label = args.first if args.first.is_a?(String)
      end

      def serialize_fields
        super.merge(
          {
            type:  { send: :type },
            label: { send: :label, unless: '' }
          }
        )
      end

  end

end
