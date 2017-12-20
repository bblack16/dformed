module DFormed
  class DateTime < ValueElement
    attr_date :value

    def to_tag
      BBLib::HTML.build(:input, **full_attributes.merge(type: :datetime))
    end
  end
end
