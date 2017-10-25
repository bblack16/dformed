# frozen_string_literal: true
module DFormed
  class HorizontalForm < Form
    def self.type
      [:hform, :horizontal_form]
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def to_element
        header = "<table class='dformed-hform fields'><tr class='dformed-hform-row'/></table>"
        @element = Element[header]
        fields.each do |f|
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
