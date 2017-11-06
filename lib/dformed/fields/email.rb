module DFormed
  class Email < Text
    def to_tag
      BBLib::HTML.build(:input, **attributes.merge(type: :email))
    end
  end
end
