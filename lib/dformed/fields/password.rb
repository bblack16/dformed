module DFormed
  class Password < Text
    def to_tag
      BBLib::HTML.build(:input, **attributes.merge(type: :password))
    end
  end
end
