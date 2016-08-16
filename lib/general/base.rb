module DFormed

  class Base

    def initialize *args
      setup_vars
      value = nil
      unless args.nil?
        args.each do |arg|
          if arg.is_a?(Hash)
            arg.each do |k,v|
              if k.to_s == 'value'
                value = v
                next 
              end
              self.send("#{k}=".to_sym, v) if self.respond_to?("#{k}=".to_sym)
            end
          end
        end
        custom_init *args
      end
      if value && respond_to?(:value=)
        self.value = value 
      end
    end

    def to_h
      serialize_fields.map do |k,v|
        val = self.send(v[:send])
        unless v.include?(:unless) && val == v[:unless]
          [k, val]
        else
          nil
        end
      end.reject{ |r| r.nil? }.to_h
    end

    if defined? JSON
      def to_json
        to_h.to_json
      end
    end

    if defined? YAML
      def to_yaml
        to_h.to_yaml
      end
    end

    protected

      def setup_vars
        # Do things in your implementation
      end

      def custom_init *args
        # Do things in your implementation
      end

  end

end
