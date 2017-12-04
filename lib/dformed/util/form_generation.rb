module DFormed

  def self.form_for(object, opts = {})
    return object.dform if object.respond_to?(:dform) && !opts[:bypass]
    form = opts[:form] || Form.new
    return form unless object.respond_to?(:_attrs)
    object._attrs.sort_by { |k, v| v[:options][:dformed_sort] || 0 }.to_h.each do |method, data|
      next if opts[:ignore] && opts[:ignore].include?(method)
      next if data[:options].include?(:dformed) && !data[:options][:dformed]
      next if data[:options].include?(:serialize) && !data[:options][:serialize] && !opts[:serialized_only]
      next if data[:options].include?(:protected) && data[:options][:protected] && !opts[:protected]
      next if data[:options].include?(:private) && data[:options][:private] && !opts[:private]
      value = object.is_a?(Class) ? data[:options][:default] : object.send(method)
      form.add(field_for(method, value, data[:type], data[:options]))
    end
    form
  end

  def self.field_for(method, value, type, opts = {})
    value = value.map { |v| v.is_a?(BBLib::Effortless) ? v.serialize : v } if value.is_a?(Array)
    value = value.serialize if value.is_a?(BBLib::Effortless)
    field = if opts[:dformed_field]
      opts[:dformed_field].merge(value: value, name: method)
    else
      case type
      when :string, :dir, :file, :symbol
        { name: method, value: value, type: opts[:dformed_type] || :text }
      when :integer, :integer_between
        { name: method, value: value, type: opts[:dformed_type] || :integer }
      when :float, :float_between
        { name: method, value: value, type: opts[:dformed_type] || :float }
      when :array
        { name: method, value: value, type: opts[:dformed_type] || :multi_text }
      when :date
        { name: method, value: value, type: opts[:dformed_type] || :date }
      when :time
        { name: method, value: value, type: opts[:dformed_type] || :time }
      when :boolean
        { name: method, value: value, type: opts[:dformed_type] || :toggle }
      when :element_of, :elements_of
        list = opts[:list] || []
        list = list.call if list.is_a?(Proc)
        { name: method, value: value, options: list, type: (:type == :element_of ? :select : :multi_select) }
      when :hash
        { type: opts[:dformed_type] || :hash_field, name: method, value: value }
      when :of
        field_for_class(method, opts[:classes]).merge(value: value)
      when :array_of
        { name: method, type: :multi_field, template: field_for_class(method, opts[:classes]), value: value }
      else
        { name: method, value: value, type: opts[:dformed_type] || :text }
      end.merge(opts[:dformed_attributes] || {})
    end
    field.delete(:value) unless value
    field
  end

  DEFAULT_FIELD_MAPPING = {
    text:     [String, Symbol, File, Dir],
    datetime: [Time, Date],
    number:   [Integer, Float],
    boolean:  [TrueClass, FalseClass],
    json:     [Hash, Array]
  }

  def self.field_mapping
    @field_mapping ||= DEFAULT_FIELD_MAPPING
  end

  def self.field_mapping_for(klass)
    field_mapping.find { |k, v| v.include?(klass) }.first
  rescue => e
    :text
  end

  def self.field_for_class(name, *klass)
    klass = klass.flatten
    if klass.size == 1
      if !field_mapping.values.include?(klass.first) && klass.first.respond_to?(:_attrs)
        return form_for(klass.first, form: DFormed::HorizontalForm.new).serialize(true)
      else
        type = field_mapping_for(klass.first)
      end
    else
      types = klass.map { |c| field_mapping_for(c) }.uniq
      if types.size == 1
        type = types.first
      else
        return { name: name, type: :variable_field, fields: types }
      end
    end
    { name: name, type: type }
  end

end
