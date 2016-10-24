
module DFormed

  class MultiInput < MultiField

    INPUT_TYPES = [:text, :search, :tel, :color, :time, :datetime,
                    :date, :email, :password, :datetime_local, :number,
                    :range, :week, :month, :url
                  ]

    def type= type
      type = type.to_s.sub('multi_', '').to_sym
      @type = INPUT_TYPES.include?(type) ? type : :text
      @template = Input.new(type: @type)
      @attributes[:type] = @type
    end

    def type
      "multi_#{@type}".to_sym
    end

    def self.type
      INPUT_TYPES.map{ |t| "multi_#{t}".to_sym }
    end

    protected

      def lazy_setup
        super
        @template = Input.new(type: :text)
        @min = 1
        @max = 10
      end

  end

end
