module DFormed
  class Range < ValueElement
    attr_float :value

    def to_tag
      BBLib::HTML.build(:input, **attributes.merge(type: :range))
    end
  end
end
