# frozen_string_literal: true
module DFormed
  class AutoComplete < Input
    attr_int_between 0, nil, :delay, default: 500, serialize: true
    attr_int_between 0, nil, :min_length, default: 1, serialize: true
    attr_sym :type, default: :text, serialize: true, always: true
    attr_of [Hash, Array], :options, default: [], serialize: true
    attr_bool :ary_mode, default: false, serialize: true

    def self.type
      [:auto_complete, :autocomplete]
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def to_element
        super
        create_auto_complete if DFormed.jquery_ui?
        @element
      end

    end

    protected

    def create_auto_complete
      @element.JS.autocomplete({ source: option_hash, delay: delay, minLength: min_length }.to_n)
    rescue => e
      puts e
    end

    def option_hash
      if ary_mode?
        options.is_a?(Array) ? options : options.values
      else
        temp = options.is_a?(Array) ? options.map { |o| [o, o] }.to_h : options
        temp.map { |k, v| { label: v, value: k } }
      end.to_n
    end

  end
end
