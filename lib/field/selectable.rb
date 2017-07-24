# frozen_string_literal: true
module DFormed
  class Selectable < Field
    attr_of Options, :options, default: {}, serialize: true, pre_proc: proc { |x| x.is_a?(Hash) && (x.include?(:options) || x.include?(:url)) ? x : { options: x } }
    attr_int_between 1, nil, :per_col, default: 1, serialize: true
    # attr_element_of [:radio, :checkbox], :type, default: :radio, serialize: true, always: true

    after :options=, :options_updated if DFormed.in_opal?
    after :options=, :apply_parent, send_value: true

    # def type=(t)
    #   @type = t if Selectable.type.include?(t)
    # end

    def value=(val)
      @value = if type == :checkbox
                 [val].flatten.map(&:to_s)
               else
                 val.to_s
               end
      element.html(to_html) if element?
    end

    def options_updated
      return unless element?
      retrieve_value
      element.html(to_html)
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
        self.value = case type
                     when :checkbox
                       element.find('input:checked').map(&:value)
                     else
                       element.find('input:checked').value
                     end
      end

    end

    protected

    def inner_html
      index = 0
      options.map do |v, c|
        new_col = (index % per_col).zero?
        index+=1
        checked = [value].flatten.include?(v)
        "#{new_col ? '<tr>' : nil}<td>" \
          "<input type='#{type}' value='#{v}' name='#{name}'#{checked ? ' checked' : nil}>#{c}</input>" \
          "</td>#{(index % per_col).zero? ? '</tr>' : nil}"
      end.join
    end

    def apply_parent obj
      obj.parent = self
    end

    def simple_setup
      super
      self.tagname = 'table'
    end
  end
end
