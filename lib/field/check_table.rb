
module DFormed

  class CheckTable < Field
    attr_reader :columns, :data, :primary_col

    def data
      @data || []
    end
    
    def primary_col
      @primary_col || @columns.keys.first
    end

    def columns
      @columns || data.first.keys.map{ |k| [k, k] }.to_h
    end

    def value= val
      @value = [val].flatten.map{ |v| v.to_s }
      @element.html(to_html) if element?
      # @element.find('radio, checkbox').prop('checked', false) if element?
    end

    def columns= columns
      @columns = columns.map{ |k, v| [k.to_sym, v.to_s] }.to_h
    end
    
    def data= *data
      @data = data.reject{ |d| !d.is_a?(Hash) }
    end

    def self.type
      :check_table
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def retrieve_value
        case @type
        when :checkbox
          self.value = @element.find('input:checked').map{ |i| i.value }
        else
          self.value = @element.find('input:checked').value
        end
      end

    end

    protected

      def inner_html
        index = 0
        '<thead><tr><th></th>' + 
        columns.map do |k, v|
          "<th data_id='#{k}'>#{v}</th>"
        end.join +
        '</tr></thead><tbody>' + 
        data.map do |row|
          '<tr><td><input type="checkbox" class="check_table"/></td>' +
          columns.keys.map do |k|
            "<td>#{row[k]}</td>"
          end.join + '</tr>'
        end.join + '</tbody>'
      end

      def setup_vars
        super
        @data = {}
        @columns = nil
        @tagname = 'table'
      end

      def serialize_fields
        super.merge(
          data: { send: :data, unless: [] },
          columns: { send: :columns, unless: {} }
        )
      end

  end

end
