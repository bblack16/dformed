
# frozen_string_literal: true
module DFormed
  class Divider < Separator
    def self.type
      [:divider, :hr, :horizontal_reference]
    end

    protected

    def inner_html
      nil
    end

    def simple_setup
      super
      self.tagname = 'hr'
    end
  end
end
