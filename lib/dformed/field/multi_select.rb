module DFormed
  class MultiSelect < Select
    attr_ary :value

    alias values value

    def custom_attributes
      super.merge(multiple: nil)
    end

    def selected?(value)
      return false unless self.values
      self.values.map(&:to_s).include?(value.to_s)
    end
  end
end
