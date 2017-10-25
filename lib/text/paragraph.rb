# frozen_string_literal: true
module DFormed
  class Paragraph < Separator
    attr_str :body, serialize: true

    def self.type
      [:paragraph, :p]
    end

    alias value= body=

    protected

    def inner_html
      body
    end

    def simple_setup
      super
      self.tagname = 'p'
    end

    def simple_init(*args)
      self.body = args.first if args.first.is_a?(String)
    end
  end
end
