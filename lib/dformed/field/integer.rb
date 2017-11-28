module DFormed
  class Integer < Input
    attr_int :value

    def custom_attributes
      super.merge(type: :number)
    end
  end
end
