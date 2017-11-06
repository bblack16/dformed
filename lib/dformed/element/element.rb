module DFormed
  class Element
    include BBLib::Effortless

    attr_hash :attributes, default: {}
    attr_of Element, :parent, allow_nil: true, default: nil, serialize: false

    serialize_method :type, always: true
    init_type :loose
    setup_init_foundation(:type) do |arga, argb|
      arga.to_sym == argb.to_sym
    end

    def self.type
      self.to_s.split('::').last.method_case.to_sym
    end

    bridge_method :type

    def to_tag
      BBLib::HTML.build(:div, **attributes)
    end

    def append_attribute(attribute, value)
      attributes[attribute] = (attributes[attribute] || "") + " #{value}"
    end

    def to_html
      to_tag.to_s
    end

    def element?
      BBLib.in_opal? && @element
    end

    def to_element
      raise StandardError, 'Cannot cast to element when outside of Opal.' unless BBLib.in_opal?
      @element = ::Element[to_html]
    end

    def convert_to(type)
      return self if self.type == type.to_sym
      new(serialize.merge(type: type.to_sym))
    end

    protected

    def _init_ignore
      _attrs.keys + [:type]
    end

    def simple_init(*args)
      named = BBLib.named_args(*args)
      named.except(*_init_ignore).each do |k, v|
        attributes[k] = v
      end
    end
  end
end
