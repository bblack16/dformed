module DFormed
  class Boolean < ValueElement
    attr_bool :value, default: false

    alias values value

    def to_tag
      BBLib::HTML.build(:input, **{ type: :checkbox, value: value, name: nil, checked: value? }.merge(attributes))
    end

    def retrieve_value
      return value unless element?
      self.value = element.prop('checked')
    end
  end
end
