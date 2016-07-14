
module DFormed

  class Break < Separator

    def self.type
      [:break, :br]
    end

    protected

      def inner_html
        nil
      end

      def setup_vars
        super
        @tagname = 'br'
      end

  end

end
