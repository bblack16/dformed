
module DFormed

  class ElementBase < Base
    attr_reader :classes, :attributes, :styles, :tagname, :element, :id, :events, :parent, :name

    @@registry = nil
    
    def parent= par
      @parent = par
    end

    def name= name
      @name = name.to_s
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
      begin
        [DFormed.const_get(self.class.to_s).type].flatten.first
      rescue
        :abstract
      end
    end

    def id= id
      @id = id.to_s.strip.gsub(' ', '_')
    end

    def classes= klasses
      @classes = [klasses].flatten.map{ |m| m.to_s }
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
      a = a.split(';').map{ |m| s = m.split(':'); [s[0].strip, s[1].strip]}.to_h if a.is_a?(String)
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
      @events[hash[:method]] = { event: hash[:event], selector: hash[:selector] }
      register_events
    end

    def to_html
      "<#{@tagname}#{compile_all}>#{inner_html}</#{@tagname}>"
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def to_element
        @element = Element[to_html]
      end

    end

    def self.create hash, parent = nil
      raise TypeError, 'Could not locate the appropriate class to instantiate a field.' unless registry.include?(hash[:type].to_sym)
      hash[:parent] = parent
      Object.const_get("#{@@registry[hash[:type].to_sym]}").new(hash)
    end
    
    def convert_to type
      ElementBase.create(self.to_h.merge(type: type.to_sym))
    end

    protected


###############################################
# REDEFINE
# => The following should be reimplemented in child classes

      def inner_html
        # This sets up the inner html for the to_html call
      end

      def setup_vars
        ElementBase.load_registry unless @@registry
        @name       = nil
        @parent     = nil
        @events     = Hash.new
        @id         = ''
        @classes    = Array.new
        @attributes = Hash.new
        @styles     = Hash.new
        @tagname    = 'div'
      end

      def serialize_fields
        # Make this return a hash of fields you want serialized
        # Format is {serialized_name => {send: :method_to_call, unless: nil}}
        # Be sure to merge with super if this is reimplemented
        #     super.merge({})
        {
          name:       { send: :name },
          classes:    { send: :classes, unless: [] },
          id:         { send: :id, unless: '' },
          styles:     { send: :styles, unless: {} },
          attributes: { send: :attributes, unless: {} },
          events:     { send: :events, unless: {} },
          type:       { send: :type }
        }
      end

      def custom_init *args
        # Defined custom initialization here...
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
              @element.on(*[evt, selector].reject(&:nil?)) do |event|
                self.send(method)
              end
            end
          end
        end
      end

      def self.load_registry *namespaces
        @@registry = Hash.new unless @@registry
        namespaces = [DFormed] if namespaces.empty?
        namespaces.each do |np|
          np.constants.map do |c|
            begin
              full = "#{np}::#{c}"
              [Object.const_get(full).type].flatten.each do |type|
                @@registry[type] = full unless type == :abstract
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
