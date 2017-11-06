module DFormed
  class Text < ValueElement
    attr_str :value

    def to_tag
      BBLib::HTML.build(:input, **attributes.merge(type: :text))
    end
  end
end
