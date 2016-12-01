# frozen_string_literal: true
module DFormed
  class TextArea < Field
    def self.type
      [:textarea, :text_area]
    end

    def value=(val)
      @element.JS.val(val) if element? && @value != val
      @value = val
    end

    protected

    def inner_html
      value.to_s
    end

    def lazy_setup
      super
      @tagname = 'textarea'
    end
  end
end
