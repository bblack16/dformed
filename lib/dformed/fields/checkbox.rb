module DFormed
  class Checkbox < ValueElement
    attr_ary_of String, :value, default: []
    attr_of [Array, Hash], :options, default: {}

    alias values value
    alias values= value=

    # TODO Check values against options
    # TODO Allow options to be loaded via ajax

    def to_tag
      BBLib::HTML.build(:div, **full_attributes.merge(context: self)) do
        context.options.map do |value, label|
          input(type: :checkbox, value: value, name: label || value, checked: context.values.include?(value))
        end
      end
    end

    def retrieve_value
      return value unless element?
      self.value = element.find('input:checked').map(&:value)
    end

    protected

    def _init_ignore
      super + [:values]
    end
  end
end
