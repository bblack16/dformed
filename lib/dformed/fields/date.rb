module DFormed
  class Date < ValueElement
    attr_date :value

    def to_tag
      BBLib::HTML.build(:input, **full_attributes.merge(type: :date))
    end
  end
end
