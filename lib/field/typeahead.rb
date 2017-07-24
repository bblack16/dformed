# frozen_string_literal: true
module DFormed
  class TypeAhead < AutoComplete

    def self.type
      [:typeahead, :type_ahead]
    end

    protected

    def create_auto_complete
      element.JS.autocomplete(
        {
          source: proc { |request, response| `response( $.ui.autocomplete.filter(#{option_hash}, request.term.split(/\s+/).pop() ) );` },
          delay: delay,
          minLength: min_length ,
          focus: proc { false },
          select: proc do |evt, ui|
                        current = `this.value`
                        selection = ' ' + `ui.item.value` + ' '
                        current = current.sub(/\s\w+$|\w+$|$/, selection)
                        puts current, selection
                        `this.value = #{current}`
                        false
                      end
        }.to_n
      )
    rescue => e
      puts e
    end

  end
end
