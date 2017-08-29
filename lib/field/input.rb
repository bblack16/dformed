
# frozen_string_literal: true
module DFormed
  class Input < Field
    INPUT_TYPES = [
      :text, :search, :tel, :color, :time, :datetime,
      :date, :email, :password, :'datetime-local', :number,
      :range, :week, :month, :url
    ].freeze

    attr_element_of INPUT_TYPES, :type, default: :text, serialize: true, serialize_opts: { always: true }

    serialize_method :attributes, :clean_attributes, ignore: {}

    after :default=, :value=, :value_to_attr
    after :type=, :type_to_attr
    before :value=, :convert_value, send_args: true, modify_args: true
    after :value, :convert_value, send_value: true, modify_value: true
    after :retrieve_value, :convert_value, send_value: true, modify_value: true if DFormed.in_opal?

    def self.type
      INPUT_TYPES
    end

    protected

    def inner_html
      nil
    end

    def clean_attributes
      temp = attributes.dup
      temp.delete :type
      temp.delete :value
      temp
    end

    def simple_setup
      super
      self.tagname = 'input'
    end

    def type_to_attr
      attributes[:type] = type
    end

    def value_to_attr
      attributes[:value] = value
    end

    def convert_value(value)
      case type
      when :text, :search, :tel, :color, :email, :password, :url
        value.to_s
      when :time, :datetime
        (Time.parse(value.to_s) rescue Time.now).strftime('%Y-%m-%d %H:%M:%S')
      when :date, :'datetime-local'
        (Time.parse(value.to_s) rescue Time.now).strftime('%Y-%m-%d')
      when :number, :range
        value.respond_to?(:to_f) ? value.to_f : value.to_s.to_f
      when :week, :month
        value.respond_to?(:to_f) ? value.to_i : value.to_s.to_i
      end
    end
  end
end
