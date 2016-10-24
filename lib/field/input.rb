
module DFormed

  class Input < Field

    INPUT_TYPES = [
                    :text, :search, :tel, :color, :time, :datetime,
                    :date, :email, :password, :datetime_local, :number,
                    :range, :week, :month, :url
                  ]

    after :value_to_attr, :default=, :value=

    def type= type
      @type              = INPUT_TYPES.include?(type) ? type : :text
      @attributes[:type] = @type
    end

    def self.type
      INPUT_TYPES
    end

    protected

      def inner_html
        nil
      end

      def lazy_setup
        super
        serialize_method :attributes, :clean_attributes, ignore: Hash.new
      end

      def clean_attributes
        temp = @attributes.dup
        temp.delete :type
        temp.delete :value
        temp
      end

      def lazy_setup
        super
        @tagname = 'input'
      end

      def value_to_attr
        @attributes[:value] = self.value
      end

  end

end
