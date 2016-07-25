

module DFormed 
  
  class Button < ElementBase
    include Connectable
    attr_reader :label
    
    def label= lbl
      @label = lbl.to_s
    end
    
    def disable t_or_f = true
      t_or_f ? add_attribute('disabled', true) : remove_attribute('disabled')
    end
    
    alias_method :disable=, :disable
    
    def enable
      disable false
    end
    
    alias_method :body=, :label=
    
    def self.type
      [:button, :btn]
    end
    
    protected
    
      def inner_html
        @label
      end
    
      def setup_vars
        super
        @tagname = 'button'
      end
      
      def serialize_fields
        super.merge(
          label: { send: :label }
        )
      end
    
  end
  
end