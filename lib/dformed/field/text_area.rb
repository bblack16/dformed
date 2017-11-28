module DFormed
  class TextArea < ValueElement
    attr_str :value, default: ''

    def to_tag
      BBLib::HTML.build(:textarea, value, **full_attributes)
    end

    protected

    def update_element_value(txt)
      element.JS.val(txt) if element? && value != txt
    end
  end
end
