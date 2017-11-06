module DFormed
  class Search < Text
    
    def to_tag
      BBLib::HTML.build(:input, **attributes.merge(type: :search))
    end
  end
end
