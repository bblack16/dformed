# frozen_string_literal: true
module DFormed
  class MultiTextArea < MultiField
    def self.type
      [:multi_textarea, :multi_text_area]
    end

    protected

    def inner_html
      value.to_s
    end

    def simple_setup
      super
      self.tagname = 'textarea'
      self.template = TextArea.new
    end
  end
end
