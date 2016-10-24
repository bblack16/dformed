
module DFormed

  class Label < ElementBase
    attr_str :label, serialize: true

    def label= lbl
      @label = lbl.to_s
      @element.text(@label) if element?
      self.name = @label.downcase.gsub(/\W|\s/,'_').gsub(/\_+/, '_') + '_label' if @name.to_s == ''
    end

    def self.type
      :label
    end

    alias_method :value=, :label=
    alias_method :value, :label

    protected

      def inner_html
        @label
      end

      def lazy_setup
        super
        @tagname     = 'label'
      end

      def lazy_init *args
        self.label = args.first if args.first.is_a?(String)
      end

  end

end
