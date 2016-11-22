# frozen_string_literal: true
module DFormed
  class Button < Element
    attr_str :label, serialize: true

    def disable(t_or_f = true)
      t_or_f ? add_attribute(disabled: true) : remove_attribute('disabled')
    end

    alias disable= disable

    def enable
      disable false
    end

    alias body= label=

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
