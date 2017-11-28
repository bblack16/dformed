module DFormed
  class Button < Element
    attr_str :label

    def to_tag
      BBLib::HTML.build(:button, label, **full_attributes)
    end
  end
end
