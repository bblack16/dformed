# frozen_string_literal: true
module DFormed
  class StarRating < Field
    attr_int_between 0, 100, :max, default: 5
    attr_ary_of String, :labels, default_proc: proc { DEFAULT_RATINGS }

    # attr_set(:value, default: 1)

    DEFAULT_RATINGS = ['Terrible', 'Poor', 'Average', 'Good', 'Excellent']

    def value=(val)
      @value = val.to_s.to_i
    end

    def self.type
      [:star_rating]
    end

    def validate
      true
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def retrieve_value
        self.value = element.find('input:checked').value.to_s.to_i
      end

    end

    protected

    def inner_html
      index = 0
      "<fieldset class='starability-growRotate'>" +
      (1..max).to_a.map do |i|
        checked = value == i || (value.nil? || value == 0) && i == 1
        "<input type='radio' id='rate#{i}' name='rating' value='#{i}' #{checked ? 'checked="true"' : nil}/>" \
        "<label for='rate#{i}' title='#{labels[i - 1]}'>#{i} star</label>"
      end.join +
      "</fieldset>"
    end

    def simple_setup
      super
      self.tagname = 'div'
    end
  end
end
