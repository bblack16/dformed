
module DFormed

  class Field < FormElement
    attr_reader :validator, :value, :default
    include Connectable

    def value= val
      @value = val
      @element.find('input').value = val if element?
    end

    def default= d
      @default = d
    end

    def value
      @value || @default
    end

    def validator= val
      @validator = Validator.new(val)
    end

    def self.type
      :abstract
    end

    def type
      if defined? @type
        @type
      else
        [Object.const_get("#{self.class}").type].flatten.first
      end
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def to_element
        super
        register_events
        @element
      end

      def retrieve_values
        return nil unless @element
        self.value = @element.find(@tagname).value
      end

    end

    def clear
      value = ''
      if element?
        @element.find('input').value = ''
      end
    end

    def refresh
      retrieve_values
      validate
    end

    def updated
      @parent.field_changed self
    end

    def validate
      @validator.validate(self.value, self)
    end

    def invalid_messages
      @validator.invalid_message
    end

    protected

      def inner_html
        @html_template.gsub(/\$label/i, @label.to_html).gsub(/\$field/, super)
      end

      def setup_vars
        super
        @connections = Array.new
        @validator = Validator.new
        @value = nil
        @default = nil
        register_event method: :refresh, event: :change, selector: 'input, select, radio, checkbox, textarea'
        register_event method: :updated, event: :change, selector: 'input, select, radio, checkbox, textarea'
      end

      def serialize_fields
        super.merge(
          connections: { send: :serialize_connections, unless: [] },
          validator: { send: :serialize_validator, unless: {} },
          value: { send: :value, unless: nil },
          default: { send: :default, unless: nil },
          type: { send: :type },
          events: { send: :events, unless: {refresh:{event: :change, selector: 'input, select, radio, checkbox, textarea'}, updated:{event: :change, selector: 'input, select, radio, checkbox, textarea'}}}
        )
      end

      def serialize_connections
        @connections.map{ |c| c.to_h }
      end

      def serialize_validator
        @validator.to_h rescue nil
      end

  end

end
