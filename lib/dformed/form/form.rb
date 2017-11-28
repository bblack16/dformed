module DFormed
  class Form < ValueElement
    attr_ary_of Element, :fields, default: [], add_rem: true
    dont_serialize_method :value

    alias add add_fields
    alias add_field add_fields

    def field(name)
      fields.find { |f| f.name.to_s == name.to_s }
    end

    def sections
      fields.map(&:section).uniq
    end

    def remove(*names)
      names.map do |name|
        fields.delete_if { |f| f.name.to_s == name.to_s }
      end.flatten
    end

    def index_of(name)
      fields.each_with_index do |f, x|
        return x if (f.name.to_s == name.to_s) || name == f
      end
      nil
    end

    def replace(name, field)
      name = index_of(name) unless index.is_a?(Integer)
      return false unless name
      fields[name] = field.is_a?(Field) ? field : Element.new(field)
    end

    def value
      fields.map do |field|
        next unless field.is_a?(ValueElement)
        [field.name, field.value]
      end.compact.to_h
    end

    def value=(values)
      @values = {}
      set(values)
      @values
    end

    def set(values = {})
      values.each do |name, value|
        field = field(name)
        next unless field
        field.value = value
      end
    end

    def clear
      fields.each { |field| field.clear if field.respond_to?(:clear) }
    end

    def to_tag
      BBLib::HTML.build(:div, **full_attributes) do
        sections.each do |section|
          add section_header(section) if section
          div(class: 'section-group') do
            fields = context.fields.find_all { |field| field.section == section }
            fields.each do |field|
              div(class: 'dformed-form-field') do
                add field.to_tag
              end
            end
          end
        end unless BBLib.in_opal?
      end
    end

    def to_element
      super
      sections.each do |section|
        @element.append(section_header) if section
        section_elem = Element['<div class="section-group"></div>']
        @element.append(section_elem)
        fields = self.fields.find_all { |field| field.section == section }
        fields.each do |field|
          wrapper = Element['<div class="dformed-form-field"></div>']
          wrapper.append(Element["<label class='dformed-label'>#{field.label}</label>"]) if field.labeled?
          wrapper.append(field.to_element)
          section_elem.append(wrapper)
        end
      end
      @element
    end

    def retrieve_value
      fields.map do |field|
        next unless field.respond_to?(:retrieve_value)
        [field.name, field.retrieve_value]
      end.to_h
    end

    def section_header(name)
      BBLib::HTML.build(:div, name, class: 'section-label')
    end
  end
end
