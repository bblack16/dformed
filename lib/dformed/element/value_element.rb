module DFormed
  class ValueElement < Element
    attr_str :name
    attr_of Object, :value, allow_nil: true, default: nil
    attr_str :label, allow_nil: true, default_proc: proc { |x| x.name.to_s.gsub('_', ' ').title_case }
    attr_bool :labeled, default: true

    before :value=, :update_element_value, send_arg: true

    # Used to clear a value element
    def clear
      return if attributes.include?(:readonly) && attributes[:readonly]
      value = nil
    end

    # Gets the current value from the DOM element and sets it to this object
    def retrieve_value
      return value unless element?
      @value = element.value
    end

    # Updates the DOM element. Called every time value= is.
    def update_element_value(value)
      element.value = value if element? && self.value != value
    end

  end
end
