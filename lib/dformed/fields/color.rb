module DFormed
  class Color < Text
    def to_tag
      BBLib::HTML.build(:input, **attributes.merge(type: :color))
    end
  end
end
