
module DFormed

  class Form < ElementBase
    include Valuable
    attr_reader :fields, :last_id

    def field name
      @fields.find{ |f| f.name == name } rescue nil
    end

    def add *hashes
      hashes.each do |hash|
        if hash.is_a?(ElementBase)
          add_elem hash
        elsif hash[:type]
          add_elem hash
        else # Supports a slightly different shorthand for convenience
          hash.each do |k, v|
            add_elem v.merge(type: k)
          end
        end
      end
    end

    def add_at hash, index
      if hash.is_a?(ElementBase)
        add_elem hash, index
      elsif hash[:type]
        add_elem hash, index
      else # Supports a slightly different shorthand for convenience
        hash.each do |k, v|
          add_elem v.merge(type: k), index
        end
      end
    end

    def remove *names
      names.map do |name|
        @fields.delete_if{ |f| f.name.to_s == name.to_s rescue false }
      end.flatten
    end

    def remove_at index
      @fields.delete_at index
    end

    def replace name, field
      index = index_of(name)
      @fields.delete_at(index)
      add_at field, index
    end

    def replace_at index, field
      @fields.delete_at(index)
      add_at field, index
    end

    def index_of name
      @fields.each_with_index do |f, x|
        return x if (f.name.to_s == name.to_s) || name == f
      end
      nil
    end

    def value
      @fields.map{ |f| f.is_a?(ElementBase) && f.respond_to?(:value) ? [f.name, f.value] : nil }
        .reject{ |r| r.nil? }.to_h
    end

    def value= values
      @values = {}
      set values
    end

    alias_method :values=, :value=

    def set hash
      hash.each do |k, v|
        field = @fields.find{ |f| f.name == k.to_s }
        if field
          field.value = v
        end
      end
    end

    def get name
      @fields.find{ |f| f.name.to_s == name.to_s }
    end

    def vget name
      get(name).value
    end

    def clear
      @fields.each{ |f| f.clear if f.respond_to?(:clear) }
    end

    def field_changed field
      @fields.each{ |f| f.check_connections(field) if f.respond_to?(:check_connections) }
    end

    def change_all_fields
      @fields.each{ |f| field_changed f }
    end

    # These methods are only available if the engine is Opal
    if DFormed.in_opal?

      def delete
        @element.remove if element?
      end

      def to_element
        header = "<table class='fields'></table>"
        @element = Element[header]
        @fields.each do |field|
          row = Element['<tr class="form_row"/>']
          row.append(field.to_element)
          @element.append(row)
        end
        change_all_fields
        @element
      end

      def retrieve_value
        @fields.map{ |f| f.respond_to?(:retrieve_value) ? [f.name, f.retrieve_value] : nil }
          .reject{ |r| r.nil? }.to_h
      end

    end

    def self.type
      :form
    end

    protected

      def add_elem hash, index = @fields.size
        index          = @fields.size if index > @fields.size
        index          = 0 if index < 0
        elem           = hash.is_a?(ElementBase) ? hash : ElementBase.create(hash, self)
        elem.name      = next_id if elem.respond_to?(:name=) && elem.name.to_s == ''
        @fields.insert index, elem
      end

      def next_id
        (@last_id += 1).to_s
      end

      def inner_html
        '<table class="fields"><tr>' +
        @fields.map do |field|
          field.to_html
        end.join('</tr><tr>') +
        '</tr></table>'
      end

      def setup_vars
        @last_id = 0
        super
        @fields = Array.new
      end

      def custom_init *args
        hash = args.find{ |a| a.is_a?(Hash) }
        if hash && hash.include?(:fields)
          hash[:fields].each do |field|
            add field
          end
        end
      end

      def serialize_fields
        super.merge(
          {
            fields: { send: :fields_to_h },
            type:   { send: :type }
          }
        )
      end

      def fields_to_h
        @fields.map{ |f| f.to_h }
      end

  end

end
