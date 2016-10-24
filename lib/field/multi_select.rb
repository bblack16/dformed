
module DFormed

  class MultiSelect < Select

    def self.type
      [:multi_select, :multiselect]
    end

    def type
      :multi_select
    end

    protected

      def lazy_setup
        super
        add_attribute :multiple, true
      end

  end

end
