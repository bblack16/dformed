# frozen_string_literal: true
module DFormed
  class Code < Element
    def self.type
      [:code]
    end

    protected

    def inner_html
      "<code>#{value}</code>"
    end

    def setup_vars
      super
      @tagname = 'pre'
    end
  end
end
