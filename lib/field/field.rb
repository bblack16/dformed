
# frozen_string_literal: true
module DFormed
  class Field < ValueElement

    serialize_method :events, ignore: { refresh: { event: :change, selector: nil }, updated: { event: :change, selector: nil } }

    def self.type
      :abstract
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def to_element
        super
        register_events
        element
      end

    end

    def refresh
      retrieve_value
      # validate
    end

    def updated(field = self)
      parent.field_changed(field) if parent
    end

    protected

    def inner_html
      super
    end

    def simple_setup
      super
      register_event method: :refresh, event: :change, selector: nil
      register_event method: :updated, event: :change, selector: nil
    end
  end
end
