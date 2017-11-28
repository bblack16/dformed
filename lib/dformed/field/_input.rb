module DFormed
  class Input < ValueElement

    def to_tag
      BBLib::HTML.build(:input, **full_attributes)
    end

    def self.type
      self == Input ? nil : super
    end

    def custom_attributes
      super.merge(value: value, type: type)
    end

  end
end
