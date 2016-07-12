
module DFormed

  class Input < Field
    attr_reader :type

    INPUT_TYPES = [:text, :search, :tel, :color, :time, :datetime,
                    :date, :email, :password, :datetime_local, :number,
                    :range, :week, :month, :url
                  ]

    def type= type
      @type = INPUT_TYPES.include?(type) ? type : :text
      @attributes[:type] = @type
    end

    def value= v
      super
      @attributes[:value] = value
    end

    def default= d
      super
      @attributes[:value] = value
    end

    def self.type
      INPUT_TYPES
    end

    protected

      def inner_html
        nil
      end

      def serialize_fields
        super.merge(
          attributes: { send: :clean_attributes, unless: {} }
        )
      end

      def clean_attributes
        temp = @attributes.dup
        temp.delete :type
        temp.delete :value
        temp
      end

      def setup_vars
        super
        @tagname = 'input'
      end

  end

end
