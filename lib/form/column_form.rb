# frozen_string_literal: true
module DFormed
  class ColumnForm < Form
    attr_int_between 1, nil, :columns, default: 3

    def self.type
      [:column_form]
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def to_element
        header = "<table class='dformed-hform fields'><tr class='dformed-hform-row'/></table>"
        @element = Element[header]
        fields.each_with_index do |f, i|
          row = Element['<tr class="dformed-column-form-row"/>']
          columns.times { |x| row.append('<td class="dformed-column-#{x}"') }
          index = i % columns
          if f.is_a?(Field)
            if f.labeled?
              row = Element['<td class="dformed-label"/>']
              row.append("<label class='dformed-field-label'>#{f.label}</label>")
              @element.append(row)
            end
            row = Element['<td class="dformed-field">']
            row.append(f.to_element)
          else
            row = Element['<td class="dformed-element"/>']
            row.append(f.to_element)
          end
          @element.append(row)
        end
        change_all_fields
        @element
      end

    end
  end
end
