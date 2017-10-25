# frozen_string_literal: true
module DFormed
  class VerticalForm < Form
    def self.type
      [:vform, :vertical_form]
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def to_element
        @element = Element["<div class='dformed-vform'/>"]
        sections.each do |section|
          sfields = fields.find_all { |f| f.section == section }
          sect_elem = Element["<div class='section-label'>#{section}</div>"]
          @element.append(sect_elem) if section
          table = Element["<table class='fields'></table>"]
          sfields.each do |f|
            if f.is_a?(Field)
              row = Element['<tr class="form-row"><td class="dformed-label"/><td class="dformed-field"></tr>']
              row.find('.dformed-label').append("<label class='dformed-field-label'>#{f.label}</label>") if f.labeled?
              row.find('.dformed-field').append(f.to_element)
            else
              row = Element['<tr class="form-row"><td class="dformed-element"/></tr>']
              row.find('.dformed-element').append(f.to_element)
            end
            table.append(row)
          end
          @element.append(table)
        end
        change_all_fields
        @element
      end

    end
  end
end
