# frozen_string_literal: true
module DFormed
  class Header < Separator
    after :refresh_tagname, :size=

    attr_str :title, serialize: true
    attr_int_between 1, 4, :size, default: 1, serialize: true

    def self.type
      :header
    end

    alias value= title=

    protected

    def inner_html
      @title
    end

    def refresh_tagname
      @tagname = "h#{@size}"
    end

    def lazy_init(*args)
      self.title = args.first if args.first.is_a?(String)
    end
  end
end
