# frozen_string_literal: true
module DFormed
  class VerticalForm < Form
    def self.type
      [:vform, :vertical_form]
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def to_element
        # @element = Element['<div/>']
        # x = 0
        # until x >= fields.size
        #   row = Element['<div class="form_row">']
        #   if fields[x].is_a?(Label) && fields[x + 1] && !fields[x + 1].is_a?(Label)
        #     row.append(fields[x].to_element)
        #     row.append(fields[x + 1].to_element)
        #     x += 2
        #   else
        #     row.append(fields[x].to_element)
        #   end
        #   element.append(row)
        # end
        # element
        header = "<table class='fields'></table>"
        @element = Element[header]
        x = 0
        until x >= @fields.size
          row = Element['<tr class="form_row"><td class="label"/><td class="field"/></tr>']
          if @fields[x].is_a?(Label) && @fields[x+1] && !@fields[x+1].is_a?(Label)
            row.find('td.label').append(@fields[x].to_element)
            row.find('td.field').append(@fields[x+1].to_element)
            x+=2
          elsif @fields[x].is_a?(Label)
            row.find('td.label').append(@fields[x].to_element)
            x+=1
          elsif @fields[x].is_a?(Separator)
            row.empty
            td = Element['<td colspan=2/>']
            td.append @fields[x].to_element
            row.append td
            x+=1
          else
            row.find('td.field').append(@fields[x].to_element)
            x+=1
          end
          @element.append(row)
        end
        change_all_fields
        @element
      end

    end
  end
end
