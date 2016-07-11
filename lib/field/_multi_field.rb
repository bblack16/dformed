module DFormed

  # A field that can be cloned and chopped.
  # Basically, a field that can have multiple instances of itself
  class MultiField < Field
    attr_reader :min, :max, :per_col, :index
    attr_accessor :add, :remove, :up, :down, :moveable, :cloneable, :hide_buttons

    def value= v
      @value = [v].flatten(1)
    end

    def min= n
      @min = n.to_i
    end

    def max= n
      @max = n.to_i
    end

    def per_col= pc
      @per_col = pc.to_i <= 1 ? 1 : pc.to_i
    end

    def self.type
      :abstract
    end

    def value
      @value[@index]
    end

    def values
      [@value].flatten(1)
    end

    def to_html
      reset
      values.map do |val|
        html = '<div class="multi_field">' + super + make_buttons + '</div>'
        increment
        html
      end.join
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def to_element
        super
        refresh_buttons
        @element
      end

      def refresh_buttons
        retrieve_values
        @element.find('.multi_field').each_with_index do |elem, indx|
          elem.find('button').remove
          buttons = [
            add_button(values.size >= @max),
            remove_button(values.size <= @min),
            up_button(indx == 0),
            down_button(indx == (values.size-1) )
          ].reject{ |r| r.nil? }
          elem.append(buttons)
        end
      end

      def clone event
        elm = event.element.closest('.multi_field')
        cln = elm.clone
        elm.after(cln)
        refresh_buttons
      end

      def chop event
        event.element.closest('.multi_field').remove
        refresh_buttons
      end

      # Uses an event to move a field up or down in the current order
      def move event, position = :up
        mover = event.element.closest('.multi_field')
        swapper = (position == :up ? mover.prev : mover.next)
        a, b = mover.clone, swapper.clone
        `#{mover}.replaceWith(#{b})`
        `#{swapper}.replaceWith(#{a})`
        refresh_buttons
      end

      def retrieve_values
        @value = @element.find(@tagname).map{ |m| m.value }
      end

      def add_button disabled = false
        return nil unless cloneable && (!disabled || !hide_buttons)
        btn = Element[make_button('add', @add, disabled)]
        btn.on :click do |evt|
          clone evt
        end
        btn
      end

      def remove_button disabled = false
        return nil unless cloneable && (!disabled || !hide_buttons)
        btn = Element[make_button('remove', @remove, disabled)]
        btn.on :click do |evt|
          chop evt
        end
        btn
      end

      def up_button disabled = false
        return nil unless moveable && (!disabled || !hide_buttons)
        btn = Element[make_button('up', @up, disabled)]
        btn.on :click do |evt|
          move evt, :up
        end
        btn
      end

      def down_button disabled = false
        return nil unless moveable && (!disabled || !hide_buttons)
        btn = Element[make_button('down', @down, disabled)]
        btn.on :click do |evt|
          move evt, :down
        end
        btn
      end

    end

    protected

      def setup_vars
        super
        @min, @max, @per_col = 1, 1, 1
        @add = '+'
        @remove = '-'
        @up = '^'
        @down = 'v'
        @cloneable = true
        @moveable = true
        @value = [nil]
        @hide_buttons = false
        reset
      end

      def make_buttons
        if DFormed.in_opal?
          ''
        else
          (cloneable ? "#{make_button('add', @add)}#{make_button('remove', @remove)}" : '') +
          (moveable ? "#{make_button('up', @up)}#{make_button('down', @down)}" : '')
        end
      end

      def make_button klass, html, disabled = false
        "<button class='#{klass}'#{disabled ? ' disabled' : nil}>#{html}</button>"
      end

      def serialize_fields
        super.merge(
          min: { send: :min, unless: 1 },
          max: { send: :max, unless: 1 },
          per_col: { send: :per_col, unless: 1 },
          add: { send: :add, unless: '+' },
          remove: { send: :remove, unless: '-' },
          up: { send: :up, unless: '^' },
          down: { send: :down, unless: 'v' },
          type: { send: :type },
          moveable: { send: :moveable },
          cloneable: { send: :cloneable },
          hide_buttons: { send: :hide_buttons, unless: false },
          value: { send: :values, unless: [nil] }
        )
      end

      def increment
        @index += 1
      end

      def reset
        @index = 0
      end

  end

end
