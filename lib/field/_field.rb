
module DFormed

  class Field < FormElement
    include Connectable, Valuable, Validateable

    def self.type
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
      retrieve_value
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
        register_event method: :refresh, event: :change, selector: nil
        register_event method: :updated, event: :change, selector: nil
      end

      def serialize_fields
        super.merge(
          connections: { send: :serialize_connections, unless: [] },
          validator:   { send: :serialize_validator, unless: {} },
          value:       { send: :value, unless: @default },
          default:     { send: :default, unless: nil },
          type:        { send: :type },
          events:      { send: :events, unless: {refresh:{event: :change, selector: nil}, updated:{event: :change, selector: nil}}}
        )
      end

  end

end
