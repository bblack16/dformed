module DFormed
  class MultiSelect < Select

    def value
      @value ||= default
    end

    def value=(val)
      @value = [val].flatten
      return @value unless element?
      element.children('option').each do |opt|
        opt.attr('selected', value.include?(opt.attr('value')))
      end
      value
    end

    def self.type
      [:multi_select, :multiselect]
    end

    def type
      :multi_select
    end

    protected

    def simple_setup
      super
      add_attribute multiple: true
      self.include_blank = false
    end
  end
end
