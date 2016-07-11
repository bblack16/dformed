
module DFormed

  class ElementBase < Base
    attr_reader :classes, :attributes, :styles, :tagname, :element, :id

    def id= id
      @id = id.to_s.strip.gsub(' ', '_')
    end

    def classes= klasses
      @classes = klasses.map{ |m| m.to_s }
    end

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
      @element.remove_attr(k.to_s)
    end

    def styles= a
      @styles = Hash.new
      a.each do |k,v|
        add_style k, v
      end
    end

    def add_style k, v
      @styles[k.to_s] = v.to_s
      @element.css(k.to_s, v.to_s) if element?
    end

    def remove_style k
      @styles.delete k.to_s
      @element.css(k.to_s, '') if element?
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

    protected


###############################################
# REDEFINE
# => The following should be reimplemented in child classes

      def inner_html
        # This sets up the inner html for the to_html call
      end

      def setup_vars
        @id = ''
        @classes = Array.new
        @attributes = Hash.new
        @styles = Hash.new
        @tagname = 'div'
      end

      def serialize_fields
        # Make this return a hash of fields you want serialized
        # Format is {serialized_name => {send: :method_to_call, unless: nil}}
        # Be sure to merge with super if this is reimplemented
        #     super.merge({})
        {
          classes: { send: :classes, unless: [] },
          id: { send: :id, unless: '' },
          styles: { send: :styles, unless: {} },
          attributes: { send: :attributes, unless: {} }
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

  end

end
