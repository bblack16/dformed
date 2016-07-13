
module DFormed

  class Field < FormElement
    include Connectable, Valuable, Validateable

    def self.type
      :abstract
    end

    def type
      :abstract
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def to_element
        super
        register_events
        @element
      end

    end

    def refresh
      retrieve_values
      validate
    end

    def updated
      @parent.field_changed self
    end

    protected

      def inner_html
        super
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
          value: { send: :value, unless: @default },
          default: { send: :default, unless: nil },
          type: { send: :type },
          events: { send: :events, unless: {refresh:{event: :change, selector: 'input, select, radio, checkbox, textarea'}, updated:{event: :change, selector: 'input, select, radio, checkbox, textarea'}}}
        )
      end

  end

end
