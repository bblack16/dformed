

module DFormed

  class Button < ElementBase
    attr_str :label, serialize: true

    def disable t_or_f = true
      t_or_f ? add_attribute('disabled', true) : remove_attribute('disabled')
    end

    alias_method :disable=, :disable

    def enable
      disable false
    end

    alias_method :body=, :label=

    def self.type
      [:button, :btn]
    end

    protected

      def inner_html
        @label
      end

      def lazy_setup
        super
        @tagname = 'button'
      end

  end

end
