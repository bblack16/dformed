# frozen_string_literal: true
module DFormed
  class Controller
    attr_reader :forms

    def initialize
      @forms = {}
    end

    def add(form, id)
      form = JSON.parse(form) if form.is_a?(String)
      form[:type] = :form unless form.include?(:type)
      @forms[id.to_s] = Element.create(form, nil)
    end

    def form(id)
      @forms[id]
    end

    def remove(id)
      @forms.delete id
    end

    def delete(id)
      form(id).delete if DFormed.in_opal?
      remove id
    end

    def has_form?(id)
      @forms.include?(id)
    end

    def clone(from, to)
      add(form(from).to_h, to)
    end

    def values(id)
      if DFormed.in_opal?
        form(id).retrieve_value
      else
        form(id).value
      end
    end

    def set(id, values)
      form(id).value = values
    end

    def clear(id)
      form(id).clear if form(id).respond_to? :clear
    end

    if DFormed.in_opal?

      def add_and_render(form, id, selector)
        add form, id
        render id, selector
      end

      def clone_and_render(from, to, selector)
        add_and_render(form(from).to_h, to, selector)
      end

      def download(url, id, selector = false, retain = true, options: {})
        retain = false if retain && !has_form?(id)
        HTTP.get(url, options) do |response|
          `console.log(#{response})`
          values = values(id) if retain
          add response.json, id
          set id, values if retain
          render id, selector, values if selector
        end
      end

      def render(id, selector)
        elem = ::Element[selector].first
        elem.empty
        fe = form(id).element || form(id).to_element
        form(id).reregister_field_events
        elem.append(fe)
      end

      def send(id, url)
        HTTP.post url, form(id) do |_response|
          `console.log(response.json)`
        end
      end

    end
  end
end
