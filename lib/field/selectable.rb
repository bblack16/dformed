
module DFormed

  class Selectable < Field
    attr_reader :options, :type, :per_col

    def type= t
      @type = t if Selectable.type.include?(t)
    end

    def per_col= pc
      @per_col = pc.to_i <= 1 ? 1 : pc.to_i
    end

    def value= val
      @value = val
      @element.find('radio, checkbox').prop('checked', false) if element?
    end

    def options= options
      if options.is_a?(Array)
        @options = options.map{ |o| [o,o] }.to_h
      elsif options.is_a?(Hash)
        @options = options
      else
        raise ArgumentError, "The options argument must be a hash or array"
      end
    end

    def self.type
      [:radio, :checkbox]
    end

    def validate
      true
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def retrieve_values
        case @type
        when :checkbox
          self.value = @element.find('input:checked').map{ |i| i.value }
        else
          self.value = @element.find('input:checked').value
        end
      end

    end

    protected

      def inner_html
        index = 0
        options.map do |v, c|
          new_col = index % @per_col == 0
          index+=1
          checked = [value].flatten.include?(v)
          "#{new_col ? '<tr>' : nil}<td>" +
          "<input type='#{self.type}' value='#{v}' name='#{@name}'#{checked ? ' checked' : nil}>#{c}</input>" +
          "</td>#{index % @per_col == 0 ? '</tr>' : nil}"
        end.join
      end

      def setup_vars
        super
        @options = {}
        @type = :radio
        @tagname = 'table'
        @per_col = 1
      end

      def serialize_fields
        super.merge(
          type: { send: :type },
          options: { send: :options, unless: {} },
          per_col: { send: :per_col, unless: 1 }
        )
      end

  end

end
