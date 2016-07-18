
module DFormed

  class MultiSelect < Select

    def self.type
      [:multi_select, :multiselect]
    end
    
    def type
      :multi_select
    end

    # # These methods are only available if the engine is Opal
    # if DFormed.in_opal?
    # 
    #   def retrieve_value
    #     self.value = @element.value
    #   end
    # 
    # end

    protected

      def setup_vars
        super
        add_attribute :multiple, true
      end

  end

end
