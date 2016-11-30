# frozen_string_literal: true
module DFormed
  class Selectable < Field
    attr_hash :options, serialize: true
    attr_int_between 1, nil, :per_col, default: 1, serialize: true

    def type=(t)
      @type = t if Selectable.type.include?(t)
    end

    def value=(val)
      @value = if @type == :checkbox
                 [val].flatten.map(&:to_s)
               else
                 val.to_s
               end
      @element.html(to_html) if element?
      # @element.find('radio, checkbox').prop('checked', false) if element?
    end

    def options=(options)
      if options.is_a?(Array)
        @options = options.map { |o| [o.to_s, o.to_s] }.to_h
      elsif options.is_a?(Hash)
        @options = options.map { |k, v| [k.to_s, v.to_s] }.to_h
      else
        raise ArgumentError, "The options argument must be a Hash or Array, not a #{options.class}: #{options}"
      end
      if element?
        retrieve_value
        @element.html(to_html)
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

      def retrieve_value
        self.value = case @type
                     when :checkbox
                       @element.find('input:checked').map(&:value)
                     else
                       @element.find('input:checked').value
                     end
      end

    end

    protected

    def inner_html
      index = 0
      options.map do |v, c|
        new_col = (index % @per_col).zero?
        index+=1
        checked = [value].flatten.include?(v)
        "#{new_col ? '<tr>' : nil}<td>" \
          "<input type='#{type}' value='#{v}' name='#{@name}'#{checked ? ' checked' : nil}>#{c}</input>" \
          "</td>#{(index % @per_col).zero? ? '</tr>' : nil}"
      end.join
    end

    def lazy_setup
      super
      @options = {}
      @type = :radio
      @tagname = 'table'
      @per_col = 1
    end
  end
end
