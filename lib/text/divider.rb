
module DFormed

  class Divider < Separator

    def self.type
      [:divider, :hr, :horizontal_reference]
    end

    protected

      def inner_html
        nil
      end

      def setup_vars
        super
        @tagname = 'hr'
      end

  end

end
