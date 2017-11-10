module DFormed
  class Range < ValueElement
    attr_float :value

    def to_tag
      BBLib::HTML.build(:input, **full_attributes.merge(type: :range))
    end
  end
end
