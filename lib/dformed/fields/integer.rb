module DFormed
  class Integer < ValueElement
    attr_int :value

    def to_tag
      BBLib::HTML.build(:input, **attributes.merge(type: :number))
    end
  end
end
