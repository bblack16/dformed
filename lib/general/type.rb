module DFormed

  module Type

    def attr_type *types
      defined_singleton_method(:type){ types }
    end

  end

end
