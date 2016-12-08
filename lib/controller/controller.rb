# frozen_string_literal: true
module DFormed
  class Controller < BBLib::LazyClass
    attr_bool :track_changes, default: false
    attr_hash :forms, default: {}
    attr_hash :originals, default: {}

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

    def form?(id)
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

    def changed_values(id)
      (originals[id] || {}).diff(values(id))
    end

    def set(id, values)
      form(id).value = values
    end

    def clear(id)
      form(id).clear if form(id).respond_to? :clear
    end

    def reset(id)
      return unless track_changes?
      set(id, originals[id])
    end

    def update_original(id)
      return unless track_changes?
      originals[id] = values(id)
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
        retain = false if retain && !form?(id)
        HTTP.get(url, options) do |response|
          `console.log(#{response})`
          values = values(id) if retain
          add(response.json, id)
          set(id, values) if retain
          render(id, selector) if selector
        end
      end

      def render(id, selector, empty: false)
        form(id).tap do |form|
          elem = ::Element[selector].first
          empty ? elem.empty : elem.children.detach
          elem.append(form.element || form.to_element)
          update_original(id)
        end
      end

      def send_to(id, url)
        HTTP.post url, form(id) do |response|
          `console.log(#{response.json})`
        end
      end

    end
  end
end
