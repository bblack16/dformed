module DFormed
  class Select < ValueElement
    attr_str :value
    attr_of [Array, Hash], :options, default: {}

    alias values value

    # TODO Check values against options
    # TODO Allow options to be loaded via ajax

    def to_tag
      BBLib::HTML.build(:select, **full_attributes.merge(context: self)) do
        context.options.map do |value, label|
          option(label || value, value: value || value, selected: context.value.to_s == value.to_s)
        end
      end
    end
  end
end
