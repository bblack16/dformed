# frozen_string_literal: true
module DFormed
  class JSONField < TextArea

    after :parse_json, :to_element, :value= if DFormed.in_opal?

    def self.type
      [:json]
    end

    protected

    def simple_setup
      super
      register_event method: :parse_json, event: :change, selector: nil
    end

    def parse_json
      `try { #{_parse} } catch(e) { this.$mark_failed(e.message) }`
      nil
    end

    def _parse
      value = element? ? retrieve_value : value
      parsed = JSON.parse(value) rescue nil
      self.value = `JSON.stringify(#{parsed.to_n}, null, 2)`
      remove_attribute(:title)
      remove_style('box-shadow')
    end

    def mark_failed(error)
      add_attribute(title: error)
      add_style('box-shadow': '0px 0px 5px red')
    end

  end
end
