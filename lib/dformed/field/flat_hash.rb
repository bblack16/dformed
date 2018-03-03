module DFormed
  class FlatHash < MultiField
    attr_hash :value, default: {}, pre_proc: :process_to_hash
    attr_of KeyValue, :template, default_proc: proc { KeyValue.new }
    attr_bool :symbolize_keys, default: false

    def retrieve_value
      return {} unless element? && !fields.empty?
      order = element.children('.multi-field-row').map { |elem| elem.attr('dformed-index') }
      self.value = {}.tap do |result|
        order.each do |index|
          result.merge!([fields[index.to_i].retrieve_value].to_h)
        end
      end
    end

    protected

    def process_to_hash(hash)
      return hash if hash.is_a?(Hash)
      return {} unless hash
      value = hash.to_h
      symbolize_keys? ? value.keys_to_sym : value
    end

  end
end
