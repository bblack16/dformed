module DFormed
  class Json < TextArea
    # after :to_element, :value=, :parse_json if BBLib.in_opal?

    protected

    def simple_setup
      on(:change, :parse_json, type: :method)
    end

    def parse_json
      `try { #{_parse} } catch(e) { this.$mark_failed(e.message) }`
      nil
    end

    def _parse
      val = element? ? retrieve_value : value
      parsed = JSON.parse(val) rescue nil
      self.value = `JSON.stringify(#{parsed.to_n}, null, 2)`
      remove_attribute(:title)
      remove_class('json-parse-failed')
    end

    def mark_failed(error)
      add_attribute(title: error)
      add_class('json-parse-failed')
    end
  end
end
