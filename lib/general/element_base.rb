
module DFormed

  class ElementBase < BBLib::LazyClass
    attr_array_of String, :classes, default: [], serialize: true
    attr_hash :attributes, :styles, :events, default: Hash.new, serialize: true
    attr_str :tagname, default: 'div'
    attr_str :id, :name, allow_nil: true, default: nil, serialize: true
    attr_of Object, :parent, allow_nil: true, default: nil
    attr_array_of Connection, :connections, add_rem: true, default: Array.new, serialize: true
    attr_reader :element

    self.serialize_method :type, always: true

    alias_method :to_h, :serialize
    alias_method :add_connection, :add_connections

    @@registry = nil

    def self.new *args
      if BBLib::named_args(*args).include?(:type) && self == ElementBase
        self.create(*args)
      else
        super
      end
    end

    def name? name
      @name == name.to_s
    end

    def self.registry
      @@registry || ElementBase.load_registry
    end

    def registry
      @@registry || ElementBase.load_registry
    end

    def type
      [DFormed.const_get(self.class.to_s).type].flatten.first rescue :abstract
    end

    alias_method :class=, :classes=

    def add_class klass
      @classes.push klass
      @element.add_class(klass) if element?
    end

    def remove_class klass
      @classes.delete klass
      @element.remove_class(klass) if element?
    end

    def attributes= a
      @attributes = Hash.new
      a.each do |k,v|
        add_attribute k, v
      end
    end

    def add_attribute k, v
      @attributes[k.to_sym] = v.to_s
      @element.attr(k.to_s, v.to_s) if element?
    end

    def remove_attribute k
      @attributes.delete k.to_sym
      @element.remove_attr(k.to_s) if element?
    end

    def styles= a
      @styles = Hash.new
      a = a.split(';').map{ |m| s = m.split(':', 2) }.to_h if a.is_a?(String)
      a.each do |k,v|
        add_style k, v
      end
    end

    alias_method :style=, :styles=

    def add_style key, value = nil
      if key.is_a?(String) && value.nil?
        styles = key.split(';').map{ |m| s = m.split(':'); [s[0].strip, s[1].strip]}.to_h
      elsif key.is_a?(Hash)
        styles = key
      else
        styles = { key => value }
      end
      styles.each do |k, v|
        @styles[k.to_s] = v.to_s
        @element.css(k.to_s, v.to_s) if element?
      end
    end

    def remove_style k
      @styles.delete k.to_s
      @element.css(k.to_s, '') if element?
    end

    def register_event hash
      unless hash.include?(:method)
        hash = { method: hash.keys.first }.merge(hash.values.first)
      end
      @events[hash[:method]] = { event: hash[:event], selector: hash[:selector] }
      register_events
    end

    def events= events
      return nil unless events
      @events = Hash.new unless @events
      if events.is_a?(Array)
        events.each{ |e| register_event e }
      else
        events.each{ |m, e| register_event({method: m}.merge(e)) }
      end
    end

    def check_connections elem
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

    end

    def self.create hash, parent = nil
      raise TypeError, 'Could not locate the appropriate class to instantiate a field.' unless registry.include?(hash[:type].to_sym)
      hash[:parent] = parent
      Object.const_get("#{@@registry[hash[:type].to_sym]}").new(hash)
    end

    def convert_to type
      ElementBase.create(self.serialize.merge(type: type.to_sym))
    end

    protected

    def lazy_setup
      ElementBase.load_registry unless @@registry
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
        data = [compile_id, compile_classes, compile_attributes, compile_style].reject{ |r| r.nil? }.join(' ')
        data == '' ? nil : ' ' + data
      end

      def compile_id
        "id='#{@id}'" unless @id.nil? || @id == ''
      end

      def compile_classes
        "class='#{@classes.join ' '}'" unless @classes.empty?
      end

      def compile_style
        "style='#{@styles.map{ |k,v| "#{k}: #{v}" }.join('; ')}'" unless @styles.empty?
      end

      def compile_attributes
        @attributes.map{ |k,v| "#{k}='#{v}'" }.join ' ' unless @attributes.empty?
      end

      def element?
        DFormed.in_opal? && @element
      end

      def register_events
        return nil unless element?
        @events.each do |method, data|
          [data[:event]].flatten.each do |evt|
            [data[:selector]].flatten.each do |selector|
              @element.on(*[evt, selector].compact) do |event|
                self.send(method)
              end
            end
          end
        end
      end

      def self.load_registry *namespaces
        @@registry = Hash.new unless @@registry
        namespaces = [DFormed] if namespaces.empty?
        namespaces.each do |namespace|
          namespace.constants.map do |constant|
            begin
              [namespace.const_get(constant.to_s).type].flatten.each do |type|
                @@registry[type] = "#{namespace}::#{constant}" unless type == :abstract
              end
            rescue
              # Nothing, load failed
            end
          end
        end
        @@registry
      end

      def self.reload_registry *namespaces
        @@registry = Hash.new
        load_registry(*namespaces)
      end

  end

end
