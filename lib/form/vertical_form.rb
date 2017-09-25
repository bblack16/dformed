# frozen_string_literal: true
module DFormed
  class VerticalForm < Form
    def self.type
      [:vform, :vertical_form]
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def to_element
        header = "<table class='dformed-vform fields'></table>"
        @element = Element[header]
        fields.each do |f|
          if f.is_a?(Field)
            row = Element['<tr class="form-row"><td class="dformed-label"/><td class="dformed-field"></tr>']
            row.find('.dformed-label').append("<label class='dformed-field-label'>#{f.label}</label>") if f.labeled?
            row.find('.dformed-field').append(f.to_element)
          else
            row = Element['<tr class="form-row"><td class="dformed-element"/></tr>']
            row.find('.dformed-element').append(f.to_element)
          end
          @element.append(row)
        end
        change_all_fields
        @element
      end

    end
  end
end
