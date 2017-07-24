# frozen_string_literal: true
module DFormed
  class MultiInput < MultiField
    INPUT_TYPES = [:multi_text, :multi_search, :multi_tel, :multi_color, :multi_time, :multi_datetime,
                   :multi_date, :multi_email, :multi_password, :multi_datetime_local, :multi_number,
                   :multi_range, :multi_week, :multi_month, :multi_url].freeze

    after :add_type_attribute,:type=
    before :to_multi, :type=, send_args: true, modify_args: true
    attr_element_of INPUT_TYPES, :type, default: :multi_text, serialize: true, always: true

    def self.type
      INPUT_TYPES
    end

    protected

    def simple_setup
      super
      self.template = Input.new(type: :text)
    end

    def add_type_attribute
      stype = type.to_s.sub('multi_', '').to_sym
      self.template = Input.new(type: stype)
    end

    def to_multi type
      if type.to_s.start_with?('multi_')
        type
      else
        "multi_#{type}".to_sym
      end
    end
  end
end
