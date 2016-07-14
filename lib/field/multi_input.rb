
module DFormed

  class MultiInput < MultiField

    INPUT_TYPES = [:text, :search, :tel, :color, :time, :datetime,
                    :date, :email, :password, :datetime_local, :number,
                    :range, :week, :month, :url
                  ]

    def type= type
      type = type.to_s.sub('multi_', '').to_sym
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

    def type
      "multi_#{@type}".to_sym
    end

    def self.type
      INPUT_TYPES.map{ |t| "multi_#{t}".to_sym }
    end

    protected

      def inner_html
        nil
      end

      def setup_vars
        super
        @min = 1
        @max = 10
        @label = 'Input'
        @tagname = 'input'
      end

      def increment
        super
        @attributes[:value] = value
        @index
      end

      def reset
        super
        @attributes[:value] = value
        @index
      end

  end

end
