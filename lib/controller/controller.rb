module DFormed

  class Controller
    attr_reader :forms

    def initialize
      @forms = Hash.new
    end

    def add form, id
      @forms[id.to_s] = Form.new(form)
    end

    def form id
      @forms[id]
    end

    def remove id
      @forms.delete id
    end

    def delete id
      form(id).delete if DFormed.in_opal?
      remove id
    end

    def values id
      form(id).retrieve_values
    end

    def clear id
      form(id).clear
    end

    if DFormed.in_opal?

      def add_and_render form, id, selector
        add form, id
        render id, selector
      end

      def download_and_render url, id, selector
        download url, id, selector
      end

      def download url, id, selector = false
        HTTP.get url do |response|
          `console.log(#{response})`
          add response.json, id
          render id, selector unless !selector
        end
      end

      def render id, selector
        Element[selector].first.append(form(id).to_element)
      end

      def delete id
        form(id).delete
      end

      def send id, url
        HTTP.post url, form(id) do |response|
          `console.log(response.json)`
        end
      end

    end

  end

end
