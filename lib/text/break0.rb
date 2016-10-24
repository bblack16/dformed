
module DFormed

  class Break < Separator

    def self.type
      [:break, :br]
    end

    protected

      def inner_html
        nil
      end

      def lazy_setup
        super
        @tagname = 'br'
      end

  end

end
