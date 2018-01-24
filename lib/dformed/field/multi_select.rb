module DFormed
  class MultiSelect < Select
    attr_ary :value

    alias values value

    def custom_attributes
      super.merge(multiple: nil)
    end
  end
end
