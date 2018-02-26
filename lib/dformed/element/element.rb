require_relative '../events/event'

module DFormed
  class Element
    include BBLib::Effortless
    include BBLib::TypeInit

    attr_hash :attributes, default: {}, pre_proc: :process_attributes
    attr_ary_of String, :classes, default: [], pre_proc: :process_classes
    attr_hash :styles, default: {}, pre_proc: :process_styles
    attr_str :name
    attr_str :section, default: nil, allow_nil: true
    attr_of Element, :parent, allow_nil: true, default: nil, serialize: false
    attr_ary_of Event, :events, default: [], add_rem: true, adder_name: 'add_event', remover_name: 'remove_event'
    attr_reader :element, serialize: false

    init_type :loose

    class << self
      alias _new new
    end

    def self.new(*args, &block)
      named = BBLib.named_args(*args)
      unless named[:skip_presets]
        if named[:type] && DFormed.preset?(named[:type])
          return new(DFormed.preset(named[:type]).merge(skip_presets: true).merge(named.except(:type)), &block)
        end
      end
      _new(*args, &block)
    end

    def self.type
      self.to_s.split('::').last.method_case.to_sym
    end

    bridge_method :type

    def self.[](arg)
      arg = arg.to_s if arg.is_a?(BBLib::HTML::Tag)
      ::Element[arg]
    end

    def clone
      Element.new(self.serialize)
    end

    def delete
      element.remove if element?
    end

    def to_tag
      BBLib::HTML.build(:div, **full_attributes)
    end

    def to_html(*args)
      to_tag.to_s(*args)
    end

    def element?
      BBLib.in_opal? && @element
    end

    def to_element
      raise BBLib::WrongEngineError, 'Cannot cast to element outside of Opal.' unless BBLib.in_opal?
      @element = ::Element[to_html]
      register_events
      @element
    end

    def convert_to(type)
      return self if self.type == type.to_sym
      new(serialize.merge(type: type.to_sym))
    end

    def full_attributes
      custom_attributes.deep_merge(build_attributes)
    end

    def custom_attributes
      {
        'dformed-type': type,
        class: ["dformed-#{type.to_s.gsub('_', '-')}"],
        context: self
      }
    end

    def register_events
      return false unless element?
      events.each do |event|
        event.register(self)
      end
      return true
    end

    def on(event, code = nil, **opts, &block)
      add_event(opts.merge(event: block || code, events: event))
    end

    def build_attributes
      attributes.merge({ class: classes, style: styles }.reject { |k, v| v.empty? })
    end

    def add_class(klass)
      element.add_class(klass) if element?
      process_classes(klass).map do |cls|
        classes << cls unless classes.include?(cls)
      end.compact
    end

    def remove_class(klass)
      element.remove_class(klass) if element?
      classes.delete(klass)
    end

    def add_style(style, value = nil)
      style = { style => value } if !style.is_a?(Hash) && value
      process_styles(style).map do |k, v|
        element.css(k.to_s, v.to_s) if element?
        styles[k] = v
      end
    end

    def remove_style(name)
      element.css(name.to_s, '') if element?
      styles.delete(name)
    end

    def add_attribute(attr, value = nil)
      attr = { attr => value } if !attr.is_a?(Hash) && value
      process_attributes(attr).map do |k, v|
        element.attr(k.to_s, v.to_s) if element?
        attributes[k] = v
      end
    end

    def remove_attribute(name)
      element.remove_attr(name.to_s) if element?
      attributes.delete(name)
    end

    protected

    def _init_ignore
      _attrs.keys + [:type, :skip_presets]
    end

    def simple_init(*args)
      named = BBLib.named_args(*args)
      process_attributes(named.except(*_init_ignore)).each do |k, v|
        attributes[k] = v
      end
    end

    def process_attributes(attr)
      attr.hmap do |k, v|
        case k
        when :class
          add_class(v)
          next
        when :style
          add_style(v)
          next
        else
          [k.to_sym, v]
        end
      end
    end

    def process_classes(klasses)
      klasses.msplit(/\s+/).flatten
    end

    def process_styles(style)
      case style
      when Hash
        style.hmap do |k, v|
          [k.to_sym, v.to_s.strip]
        end
      when String
        style.split(';').hmap { |s| s.split(':', 2).map(&:strip) }
      else
        raise ArgumentError, "Invalid class for style. Expected Hash or String, got #{style.class}."
      end
    end
  end
end
