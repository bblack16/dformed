
module DFormed

  class Select < Selectable

    def self.type
      :select
    end
    
    def type
      :select
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def retrieve_value
        self.value = @element.value
      end

    end

    protected

      def setup_vars
        super
        @tagname = 'select'
      end

      def inner_html
        @options.map do |k,v|
          selected = [value].flatten.include?(v)
          "<option value='#{k}'#{selected ? ' selected' : nil}>#{v}</option>"
        end.join("\n")
      end

  end

end
