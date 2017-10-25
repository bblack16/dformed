# frozen_string_literal: true
module DFormed
  class DatePicker < Input
    attr_str :format, default: 'mm/dd/yy', serialize: true
    attr_sym :type, default: :text, serialize: true, always: true

    def self.type
      [:date_picker, :datepicker]
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def to_element
        super
        create_date_picker if DFormed.jquery_ui?
        element
      end

    end

    protected

    def create_date_picker
      element.JS.datepicker({ format: format }.to_n)
    rescue => e
      puts e
    end

  end
end
