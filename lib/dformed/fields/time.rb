module DFormed
  class Time < ValueElement
    attr_time :value

    def to_tag
      BBLib::HTML.build(:input, **attributes.merge(type: :time))
    end
  end
end
