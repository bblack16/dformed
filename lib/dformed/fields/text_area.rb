module DFormed
  class TextArea < ValueElement
    attr_str :value

    def to_tag
      BBLib::HTML.build(:textarea, **attributes)
    end

    protected

    def update_element_value(txt)
      element.JS.val(txt) if element? && value != txt
    end
  end
end
