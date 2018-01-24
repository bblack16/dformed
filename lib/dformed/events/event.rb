module DFormed
  class Event
    include BBLib::Effortless

    TYPES = [:ruby, :method, :javascript, :proc]

    attr_of [String, Symbol, Proc], :event, required: true, arg_at: 0
    attr_ary_of String, :events, default: [], arg_at: 1, pre_proc: proc { |x| [x].flatten.map(&:to_s).map(&:downcase) }
    attr_element_of TYPES, :type, default: nil, allow_nil: true
    attr_str :selector, default: nil, allow_nil: true
    attr_of Object, :element, serialize: false

    after :event=, :change_type

    def register(df_element)
      raise BBLib::WrongEngineError, 'Events cannot be registered outside of Opal.' unless BBLib.in_opal?
      self.element = df_element
      elem = df_element.element
      elem = elem.find(selector) if selector
      elem.on(event_string) do |event|
        execute(event)
      end
    end

    def event_string
      events.join(' ')
    end

    protected

    def execute(evt)
      return unless event
      case type
      when :ruby
        element.instance_eval(event.to_s)
      when :javascript
        eval("`#{event}`")
      when :proc
        event.arity != 0 ? event.call(evt) : event.call
      when :method
        element.send(event)
      end
    end

    def change_type
      if type != :proc && event.is_a?(Proc)
        self.type = :proc
      elsif type == :proc && !event.is_a?(Proc)
        self.type = :eval
      elsif type.nil?
        case event
        when Proc
          self.type = :proc
        when String
          self.type = :ruby
        when Symbol
          self.type = :method
        end
      end
    end
  end
end
