module DFormed
  class Select < ValueElement
    attr_str :value
    attr_of [Array, Hash], :options, default: {}
    attr_bool :include_blank, default: false

    alias values value

    # TODO Check values against options
    # TODO Allow options to be loaded via ajax

    def to_tag
      BBLib::HTML.build(:select, **full_attributes.merge(context: self)) do
        option('', value: nil) if context.include_blank?
        context.options.map do |value, label|
          payload = { value: value }
          payload[:selected] = nil if context.value.to_s == value.to_s
          option(label || value, payload)
        end
      end
    end
  end
end
