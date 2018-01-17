module DFormed
  class MultiSelect < Select
    attr_ary :value

    alias values value

    def custom_attributes
      super.merge(multi: true)
    end
  end
end
