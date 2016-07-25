module DFormed

  # A field that can be cloned and chopped.
  # Basically, a field that can have multiple instances of itself
  class MultiField < Field
    attr_reader :min, :max, :per_col, :template, :fields, :last
    attr_accessor :buttons, :moveable, :cloneable, :hide_buttons

    def self.type
      [:multi_field, :mf, :multi]
    end

    def template= t
      @template = t.is_?(ElementBase) ? t : ElementBase.create(t, @parent)
    end

    def value= v
      @value = [v].flatten(1)
      to_element if element?
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

    def values
      [@value].flatten(1)
    end
    
    def size
      @fields.size
    end
    
    def add_value v = nil
      @value << v
    end

    def to_html
      add_value until size >= @min
      '<div class="multi_container">' +
      values.map do |val|
        html = '<div class="multi_field">' + super + make_buttons + '</div>'
        increment
        html
      end.join + '</div>'
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def to_element
        @element.empty if element?
        @fields.clear
        reset_ids
        @element = Element['<div class="multi_container"/>'] unless element?
        generate_fields
        @fields.each do |ef|
          id = next_id
          ef.add_attribute('mgf_sort', id)
          row = Element["<div class='multi_field' mgf_sort='#{id}'/>"]
          row.append(ef.to_element)
          @element.append(row)
        end
        refresh_buttons
        @element
      end
      
      def refresh_buttons
        retrieve_value
        @element.find('.multi_field').each_with_index do |elem, indx|
          elem.find('button').remove
          buttons = [
            add_button(size >= @max),
            remove_button(size <= @min),
            up_button(indx == 0),
            down_button(indx == (size-1) )
          ].reject{ |r| r.nil? }
          elem.append(buttons)
        end
      end
      
      def retrieve_value
        return [] unless @element
        @value = @fields.map{ |ef| ef.retrieve_value }
      end
      
      def clone event
        id    = next_id
        elm   = event.element.closest('div[mgf_sort]')
        sort  = elm.attr(:mgf_sort).to_i
        f     = @fields.find{ |fl| fl.attributes[:mgf_sort].to_i == sort }
        new_f = generate_field f.value
        new_f.add_attribute(:mgf_sort, id)
        row = Element["<div class='multi_field' mgf_sort=#{id}/>"]
        row.append new_f.to_element
        elm.after(row)
        @fields.push new_f
        refresh_buttons
      end

      def chop event
        elm = event.element.closest('div[mgf_sort]')
        sort = elm.attr(:mgf_sort).to_i
        f = @fields.find{ |fl| fl.attributes[:mgf_sort].to_i == sort }
        @fields.delete(f)
        elm.remove
        refresh_buttons
      end

      # Uses an event to move a field up or down in the current order
      def move event, position = :up
        mover = event.element.closest('.multi_field')
        swapper = (position == :up ? mover.prev : mover.next)
        a, b = mover.clone, swapper.clone
        mover.replace_with b
        swapper.replace_with a
        refresh_buttons
      end

      def add_button disabled = false
        return nil unless cloneable && (!disabled || !hide_buttons)
        btn = ElementBase.create(@buttons[:add].to_h)
        btn.disable(disabled)
        btn = btn.to_element
        btn.on :click do |evt|
          clone evt
        end
        btn
      end

      def remove_button disabled = false
        return nil unless cloneable && (!disabled || !hide_buttons)
        btn = ElementBase.create(@buttons[:remove].to_h)
        btn.disable(disabled)
        btn = btn.to_element
        btn.on :click do |evt|
          chop evt
        end
        btn
      end

      def up_button disabled = false
        return nil unless moveable && (!disabled || !hide_buttons)
        btn = ElementBase.create(@buttons[:up].to_h)
        btn.disable(disabled)
        btn = btn.to_element
        btn.on :click do |evt|
          move evt, :up
        end
        btn
      end

      def down_button disabled = false
        return nil unless moveable && (!disabled || !hide_buttons)
        btn = ElementBase.create(@buttons[:down].to_h)
        btn.disable(disabled)
        btn = btn.to_element
        btn.on :click do |evt|
          move evt, :down
        end
        btn
      end

    end

    protected

      def setup_vars
        reset_ids
        super
        @min          = 1
        @max          = 1
        @per_col      = 1
        @cloneable    = true
        @moveable     = true
        @value        = [nil]
        @hide_buttons = false
        @fields       = Array.new
        @buttons      = default_buttons
      end
      
      def default_buttons
        {
          add:    DFormed::Button.new(label: '+'),
          remove: DFormed::Button.new(label: '-'),
          up:     DFormed::Button.new(label: '^'),
          down:   DFormed::Button.new(label: 'v')
        }
      end
      
      def next_id
        @last_id += 1
      end
      
      def reset_ids
        @last_id = 0
      end
      
      def generate_fields
        values.each do |h|
          @fields.push generate_field h
        end
        @fields.push generate_field while @fields.size < @min
      end
      
      def generate_field val = nil
        ElementBase.create(@template.to_h.merge(value: val), @parent)
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
        dis = disabled ? ' disabled' : nil
        "<button class='multi_button #{klass}#{dis}'#{dis}>#{html}</button>"
      end

      def serialize_fields
        super.merge(
          min:          { send: :min, unless: 1 },
          max:          { send: :max, unless: 1 },
          per_col:      { send: :per_col, unless: 1 },
          buttons:      { send: :serialize_buttons, unless: serialize_default_buttons },
          type:         { send: :type },
          moveable:     { send: :moveable },
          cloneable:    { send: :cloneable },
          hide_buttons: { send: :hide_buttons, unless: false },
          value:        { send: :values, unless: [nil] }
        )
      end
      
      def serialize_buttons btns = @buttons
        @buttons.map do |name, btn|
          [name, btn.to_h]
        end.to_h
      end
      
      def serialize_default_buttons
        serialize_buttons default_buttons
      end

  end

end
