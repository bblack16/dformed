module DFormed
  class Radio < ValueElement
    attr_str :value
    attr_of [Array, Hash], :options, default: {}

    alias values value

    # TODO Check values against options
    # TODO Allow options to be loaded via ajax

    def to_tag
      BBLib::HTML.build(:div, **full_attributes.merge(context: self)) do
        context.options.map do |value, label|
          input(type: :radio, value: value, name: label || value, checked: context.value.to_s == value.to_s)
        end
      end
    end

    def retrieve_value
      return value unless element?
      self.value = element.find('input:checked').value
    end
  end
end
