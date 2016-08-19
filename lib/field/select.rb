
module DFormed

  class Select < Selectable

    def self.type
      :select
    end
    
    def type
      :select
    end
    
    def value= val
      @value = val.to_s
      if element?
        @element.children('option').each do |opt|
          opt.attr('selected', opt.attr('value') == val)
        end
      end
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
        @type = :select
      end

      def inner_html
        @options.map do |k,v|
          selected = [@value].flatten.include?(k.to_s)
          "<option value='#{k}'#{selected ? ' selected' : nil}>#{v}</option>"
        end.join("\n")
      end

  end

end
