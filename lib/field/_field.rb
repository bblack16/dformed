
module DFormed

  class Field < ElementBase
    attr_reader :name, :label, :description, :connections, :validator,
                :value, :default, :events, :parent, :html_template

    @@registry = nil

    def parent= par
      @parent = par
    end

    def self.registry
      @@registry || Field.load_registry
    end

    def registry
      @@registry || Field.load_registry
    end

    def label= lbl
      @label = lbl.is_a?(Label) ? lbl : Label.new(lbl)
    end

    def relabel lbl
      @label.name = lbl
    end

    def name= name
      @name = name.to_s
    end

    def name
      @name || @label.name.to_s
    end

    def description= t
      @description = t.to_s
    end

    def value= val
      @value = val
      @element.find('input').value = val if element?
    end

    def default= d
      @default = d
    end

    def value
      @value || @default
    end

    def html_template= temp
      @html_template = temp.to_s
    end

    def add_connection c
      [c].flatten(1).each do |con|
        con = Connection.new(con) if con.is_a?(Hash)
        @connections << con if con.is_a?(Connection)
      end
    end

    alias_method :connections=, :add_connection

    def remove_connection index
      @connections.delete_at index
    end

    def validator= val
      @validator = Validator.new(val)
    end

    def register_event hash
      @events[hash[:method]] = { event: hash[:event], selector: hash[:selector] }
      register_events
    end

    def self.type
      :abstract
    end

    def type
      if defined? @type
        @type
      else
        [Object.const_get("#{self.class}").type].flatten.first
      end
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def to_element
        row = Element[@html_template]
        if @html_template.include?('label')
          if row.find('.label').size > 0
            row.find('.label').append(@label.to_element)
          else
            row.append(@label.to_element)
          end
        end
        if @html_template.include?('field')
          if row.find('.field').size > 0
            row.find('.field').append(super)
          else
            row.append(super)
          end
        end
        @element = row
        register_events
        @element
      end

      def retrieve_values
        return nil unless @element
        self.value = @element.find(@tagname).value
      end

    end

    def clear
      value = ''
      if element?
        @element.find('input').value = ''
      end
    end

    def refresh
      retrieve_values
      validate
    end

    def updated
      @parent.field_changed self
    end

    def check_connections field
      @connections.each do |con|
        con.compare(self, field)
      end
    end

    def validate
      @validator.validate(self.value, self)
    end

    def invalid_messages
      @validator.invalid_message
    end

    def self.create hash, parent = nil
      raise TypeError, 'Could not locate the appropriate class to instantiate a field.' unless registry.include?(hash[:type].to_sym)
      hash[:parent] = parent
      field = Object.const_get("DFormed::#{@@registry[hash[:type].to_sym]}").new(hash)
    end

    protected

      def inner_html
        @html_template.gsub(/\$label/i, @label.to_html).gsub(/\$field/, super)
      end

      def setup_vars
        Field.load_registry
        super
        @parent = nil
        self.label = 'Field'
        @description = ''
        @connections = Array.new
        @validator = Validator.new
        @events = Hash.new
        @value = nil
        @default = nil
        @name = nil
        @html_template = '<tr><td class="label"></td><td class="field"></td></tr>'
        register_event method: :refresh, event: :change, selector: 'input, select, radio, checkbox, textarea'
        register_event method: :updated, event: :change, selector: 'input, select, radio, checkbox, textarea'
      end

      def serialize_fields
        super.merge(
          name: { send: :name },
          description: { send: :description, unless: '' },
          connections: { send: :serialize_connections, unless: [] },
          validator: { send: :serialize_validator, unless: {} },
          value: { send: :value, unless: nil },
          default: { send: :default, unless: nil },
          type: { send: :type },
          label: { send: :label_to_h },
          events: { send: :events, unless: {refresh:{event: :change, selector: 'input, select, radio, checkbox, textarea'}, updated:{event: :change, selector: 'input, select, radio, checkbox, textarea'}}}
        )
      end

      def label_to_h
        @label.to_h
      end

      def serialize_connections
        @connections.map{ |c| c.to_h }
      end

      def serialize_validator
        @validator.to_h rescue nil
      end

      def register_events
        return nil unless element?
        @events.each do |method, data|
          [data[:event]].flatten.each do |evt|
            [data[:selector]].flatten.each do |selector|
              @element.on(evt, selector) do |event|
                self.send(method)
              end
            end
          end
        end
      end

      def self.load_registry
        return @@registry unless @@registry.nil?
        @@registry = Hash.new
        DFormed.constants.map do |c|
          begin
            [Object.const_get("DFormed::#{c}").type].flatten.each do |type|
              @@registry[type] = c unless type == :abstract
            end
          rescue
            # Nothing, load failed
          end
        end
        @@registry
      end

  end

end
