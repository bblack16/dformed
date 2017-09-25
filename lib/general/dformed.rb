module DFormed

  def self.form_for obj, *ignore, form: DFormed::VerticalForm.new, serialized_only: true, private: false, protected: false, bypass: false
    return form unless obj.is_a?(BBLib::Effortless) || obj.is_a?(Class) && obj.respond_to?(:_attrs)
    return obj.dformed_form(form) if obj.respond_to?(:dformed_form) && !bypass
    settings = obj._attrs.sort_by { |k, v| v[:options][:dformed_sort] || 0 }.to_h.map do |method, data|
      next if ignore.include?(method)
      next if data[:options].include?(:dformed) && (!data[:options][:dformed] || data[:options].include?(:serialize) && !data[:options][:serialize] && serialized_only)
      next if data[:options].include?(:protected) && data[:options][:protected] && !protected
      next if data[:options].include?(:private) && data[:options][:private] && !private
      data = data.merge(value: obj.send(method)) unless obj.is_a?(Class)
      form.add(field_for(method, data, is_class: obj.is_a?(Class)))
    end
    form
  end

  def self.field_for method, data, is_class: false
    value = (is_class ? data[:options][:default] : data[:value])
    if field = data[:options][:dformed_field]
      field = field.merge(value: value, name: method)
    else
      field = case data[:type]
      when :string, :dir, :file, :symbol
        { name: method, value: value, type: data[:options][:dformed_type] || :text }
      when :integer, :float, :integer_between, :float_between
        { name: method, value: value, type: data[:options][:dformed_type] || :number }
      when :array
        { name: method, value: value, type: data[:options][:dformed_type] || :multi_text }
      when :date
        { name: method, value: value, type: data[:options][:dformed_type] || :date }
      when :time
        { name: method, value: value, type: data[:options][:dformed_type] || :'datetime-local' }
      when :boolean
        { name: method, value: value, type: data[:options][:dformed_type] || :toggle }
      when :element_of, :elements_of
        list = data[:options][:list] || []
        list = list.call if list.is_a?(Proc)
        { name: method, value: value, options: list, type: (data[:type] == :element_of ? :select : :multi_select) }
      when :hash
        { type: data[:options][:dformed_type] || :json, name: method, value: value }
      when :of
        field_for_class(method, data[:options][:classes]).merge(value: value)
      when :array_of
        { name: method, value: value, type: data[:options][:dformed_type] || :multi_field, template: field_for_class(method, data[:options][:classes]) }
      else
        { name: method, value: value, type: data[:options][:dformed_type] || :text }
      end
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
        return { name: name, type: :group_field, fields: form_for(klass.first).serialize(true)[:fields].reject { |f| f[:type] == :label } }
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
