
# frozen_string_literal: true
module DFormed
  class Input < Field
    INPUT_TYPES = [
      :text, :search, :tel, :color, :time, :datetime,
      :date, :email, :password, :datetime_local, :number,
      :range, :week, :month, :url
    ].freeze

    attr_element_of INPUT_TYPES, :type, default: :text, serialize: true, always: true

    serialize_method :attributes, :clean_attributes, ignore: {}

    after :value_to_attr, :default=, :value=
    after :type_to_attr, :type=
    before :convert_value, :value=, send_args: true, modify_args: true
    after :convert_value, :value, :retrieve_value, send_value: true, modify_value: true

    def self.type
      INPUT_TYPES
    end

    protected

    def inner_html
      nil
    end

    def clean_attributes
      temp = @attributes.dup
      temp.delete :type
      temp.delete :value
      temp
    end

    def lazy_setup
      super
      @tagname = 'input'
    end

    def type_to_attr
      @attributes[:type] = @type
    end

    def value_to_attr
      @attributes[:value] = value
    end

    def convert_value(value)
      case type
      when :text, :search, :tel, :color, :email, :password, :url
        value.to_s
      when :time, :datetime, :date, :datetime_local
        Time.parse(value)
      when :number, :range
        value.to_f
      when :week, :month
        value.to_i
      end
    end
  end
end
