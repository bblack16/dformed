# frozen_string_literal: true
module DFormed
  class Element < BBLib::LazyClass
    attr_array_of String, :classes, default: [], serialize: true
    attr_hash :attributes, :styles, :events, default: {}, serialize: true
    attr_str :tagname, default: 'div'
    attr_str :id, :name, allow_nil: true, default: nil, serialize: true
    attr_of Object, :parent, allow_nil: true, default: nil
    attr_array_of Connection, :connections, add_rem: true, default: [], serialize: true
    attr_reader :element

    serialize_method :type, always: true

    alias to_h serialize
    alias add_connection add_connections

    def self.new(*args)
      if BBLib.named_args(*args).include?(:type) && self == Element
        create(*args)
      else
        super
      end
    end

    def name?(name)
      @name == name.to_s
    end

    def type
      [DFormed.const_get(self.class.to_s).type].flatten.first rescue :abstract
    end

    alias class= classes=

    def add_class(klass)
      @classes.push klass
      @element.add_class(klass) if element?
    end

    def remove_class(klass)
      @classes.delete klass
      @element.remove_class(klass) if element?
    end

    def attributes=(a)
      @attributes = {}
      add_attribute(a)
    end

    def add_attribute(hash)
      hash.each do |k, v|
        @attributes[k.to_sym] = v.to_s
        @element.attr(k.to_s, v.to_s) if element?
      end
    end

    def remove_attribute(k)
      @attributes.delete k.to_sym
      @element.remove_attr(k.to_s) if element?
    end

    def styles=(a)
      @styles = {}
      a = a.split(';').map { |m| m.split(':', 2) }.to_h if a.is_a?(String)
      a.each do |k, v|
        add_style k, v
      end
    end

    alias style= styles=

    def add_style(key, value = nil)
      styles = if key.is_a?(String) && value.nil?
                 key.split(';').map { |m| s = m.split(':'); [s[0].strip, s[1].strip] }.to_h
               elsif key.is_a?(Hash)
                 key
               else
                 { key => value }
               end
      styles.each do |k, v|
        @styles[k.to_s] = v.to_s
        @element.css(k.to_s, v.to_s) if element?
      end
    end

    def remove_style(k)
      @styles.delete k.to_s
      @element.css(k.to_s, '') if element?
    end

    def register_event(hash)
      unless hash.include?(:method)
        hash = { method: hash.keys.first }.merge(hash.values.first)
      end
      @events[hash[:method]] = { event: hash[:event], selector: hash[:selector] }
      register_events
    end

    def events=(events)
      return nil unless events
      @events = {} unless @events
      if events.is_a?(Array)
        events.each { |e| register_event e }
      else
        events.each { |m, e| register_event({ method: m }.merge(e)) }
      end
    end

    def check_connections(elem)
      return unless @connections
      @connections.each do |connection|
        connection.compare(self, elem)
      end
    end

    def to_html
      "<#{@tagname}#{compile_all}>#{inner_html}</#{@tagname}>"
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def to_element
        @element = Element[to_html]
      end

      def reregister_events
        register_events
      end

      def self.[](args)
        ::Element[args]
      end

    end

    def self.create(hash, parent = nil)
      return hash if hash.is_a?(Element)
      raise TypeError, "Could not locate a class to instantiate a field. Type given: #{hash[:type]}" unless Registry.include?(hash[:type].to_sym)
      hash[:parent] = parent
      Object.const_get(Registry.registry[hash[:type].to_sym].to_s).new(hash)
    end

    def convert_to(type)
      Element.create(serialize.merge(type: type.to_sym))
    end

    protected

    def lazy_setup
      # Registry.load_registry
    end

    ###############################################
    # REDEFINE
    # => The following should be reimplemented in child classes

    def inner_html
      # This sets up the inner html for the to_html call
    end

    #
    # END OF REDEFINE
    ##############################################

    def compile_all
      data = [compile_id, compile_classes, compile_attributes, compile_style].reject(&:nil?).join(' ')
      data == '' ? nil : ' ' + data
    end

    def compile_id
      "id='#{@id}'" unless @id.nil? || @id == ''
    end

    def compile_classes
      "class='#{@classes.join ' '}'" unless @classes.empty?
    end

    def compile_style
      "style='#{@styles.map { |k, v| "#{k}: #{v}" }.join('; ')}'" unless @styles.empty?
    end

    def compile_attributes
      @attributes.map { |k, v| "#{k}='#{v}'" }.join ' ' unless @attributes.empty?
    end

    def element?
      DFormed.in_opal? && @element
    end

    def register_events
      return nil unless element?
      @events.each do |method, data|
        [data[:event]].flatten.each do |evt|
          [data[:selector]].flatten.each do |selector|
            @element.on(*[evt, selector].compact) do |_event|
              send(method)
            end
          end
        end
      end
    end
  end
end