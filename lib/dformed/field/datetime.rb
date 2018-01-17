module DFormed
  class DateTime < Input
    attr_time :value

    def custom_attributes
      super.merge(type: :'datetime-local', value: value ? value.strftime('%Y-%m-%dT%H:%M:%S') : nil)
    end
  end
end
