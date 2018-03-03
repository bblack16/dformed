module DFormed
  class Json < TextArea
    attr_of [Hash, Array], :value, allow_nil: true, default: {}, pre_proc: proc { |x| x.is_a?(String) ? JSON.parse(x) : x }

    def parse_json
      `try { #{_parse} } catch(e) { this.$mark_failed(e.message) }`
      nil
    end

    def to_tag
      BBLib::HTML.build(:textarea, value.to_json, **full_attributes)
    end

    def to_element
      super
      parse_json
      element
    end

    def retrieve_value(raise_errors = false)
      return value unless element?
      @value = JSON.parse(element.value)
    rescue => e
      raise_errors ? raise(e) : nil
    end

    protected

    def simple_setup
      on(:change, :parse_json, type: :method)
    end

    def _parse
      val = (element? ? retrieve_value(true) : value)
      return mark_failed('Malformed or empty JSON.') unless val
      element.text(`JSON.stringify(#{val.to_n}, null, 2)`)
      remove_attribute(:title)
      add_class('json-parse-succeeded')
      remove_class('json-parse-failed')
    rescue => e
      mark_failed(e.to_s)
    end

    def mark_failed(error)
      add_attribute(title: error)
      add_class('json-parse-failed')
      remove_class('json-parse-succeeded')
    end
  end
end
