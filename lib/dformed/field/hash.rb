module DFormed
  class HashField < Json
    def retrieve_value
      super
      @value = JSON.parse(value) rescue {}
    end
  end
end
