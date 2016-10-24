
module DFormed

  class Divider < Separator

    def self.type
      [:divider, :hr, :horizontal_reference]
    end

    protected

      def inner_html
        nil
      end

      def lazy_setup
        super
        @tagname = 'hr'
      end

  end

end
