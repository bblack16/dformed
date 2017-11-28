module DFormed
  class Float < Integer
    attr_float :value
    attr_float :step, default: 0.1

    def custom_attributes
      super.merge(type: :number, step: step)
    end
  end
end
