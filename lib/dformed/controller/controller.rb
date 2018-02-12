module DFormed
  class Controller
    include BBLib::Effortless

    attr_hash :forms, default: {}

    def add(id, form)
      payload = case form
      when Element, Hash
        form
      else
        JSON.parse(form.to_s).keys_to_sym
      end
      forms[id.to_s] = Element.new(payload)
    end

    def form(id)
      forms[id.to_s]
    end

    def remove(id)
      forms.delete(id.to_s)
    end

    def delete(id)
      form(id).delete if BBLib.in_opal?
      remove(id)
    end

    def values(id)
      BBLib.in_opal? ? form(id).retrieve_value : form(id).value
    end

    def download(url, id, opts = {})
      raise BBLib::WrongEngineError, 'Cannot download forms outside of Opal' unless BBLib.in_opal?
      HTTP.get(url, opts[:ajax] || {}) do |response|
        add(response.json, id)
        render(id, opts[:selector]) if opts[:selector]
      end
    end

    def render(id, selector = 'body', empty = false)
      raise BBLib::WrongEngineError, 'Cannot render forms outside of Opal' unless BBLib.in_opal?
      form(id).tap do |form|
        elem = ::Element[selector].first
        empty ? elem.empty : elem.children.detach
        elem.append(form.element || form.to_element)
      end
    end

    def add_and_render(id, form, selector = 'body', empty = false)
      add(id, form)
      render(id, selector, empty)
    end

    def send_to(id, url, method = :post, &block)
      raise BBLib::WrongEngineError, 'Cannot send forms outside of Opal' unless BBLib.in_opal?
      case method
      when :post
        HTTP.post(url, body: form(id)) do |response|
          yield response.json if block
        end
      when :put
        HTTP.put(url, body: form(id)) do |response|
          yield response.json if block
        end
      end
    end
  end
end
