# frozen_string_literal: true
module DFormed
  class Break < Separator
    def self.type
      [:break, :br]
    end

    protected

    def inner_html
      nil
    end

    def simple_setup
      super
      self.tagname = 'br'
    end
  end
end
