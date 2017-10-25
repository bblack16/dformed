
# frozen_string_literal: true
module DFormed
  class Label < Element
    attr_str :label, serialize: true

    def label=(lbl)
      @label = lbl.to_s
      element.text(label) if element?
      self.name = label.downcase.gsub(/\W|\s/, '_').gsub(/\_+/, '_') + '_label' if name.to_s == ''
    end

    def self.type
      :label
    end

    alias value= label=
    alias value label

    protected

    def inner_html
      label
    end

    def simple_setup
      super
      self.tagname     = 'label'
    end

    def simple_init(*args)
      self.label = args.first if args.first.is_a?(String)
    end
  end
end
