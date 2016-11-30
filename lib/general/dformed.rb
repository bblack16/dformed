module DFormed

  def self.form_for obj, *ignore, form: DFormed::VerticalForm.new
    return {} unless obj.is_a?(BBLib::LazyClass) || obj.is_a?(Class)
    return obj.dformed_form(form) if obj.respond_to?(:dformed_form)
    settings = obj.attrs.map do |method, data|
      next if ignore.include?(method)
      data = data.merge(value: obj.send(method)) unless obj.is_a?(Class)
      form.add(type: :label, label: method.to_clean_sym.to_s.tr('_', ' ').title_case)
      form.add(field_for(method, data, is_class: obj.is_a?(Class)))
    end
    form
  end

  def self.field_for method, data, is_class: false
    value = (is_class ? data[:options][:default] : data[:value])
    field = case data[:type]
    when :string, :valid_dir, :valid_file
      { name: method, value: value, type: :text }
    when :int, :float, :int_between, :float_between
      { name: method, value: value, type: :number }
    when :array, :array_of
      { name: method, value: value, type: :multi_text }
    when :time
      { name: method, value: value, type: :datetime }
    when :bool
      { name: method, value: value, type: :toggle }
    when :symbol
      { name: method, value: value, type: :text }
    when :element_of
      { name: method, value: value, options: data[:options][:list], type: :select }
    when :hash
      # template = { name: method, key_field: { type: :text }, value_field: { type: :text }, type: :key_value }
      { type: :hash, name: method, value: value }
    else
      { name: method, value: value, type: :text }
    end
    field.delete(:value) unless value
    field
  end

end
