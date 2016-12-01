# frozen_string_literal: true
module DFormed
  class Connection
    module Actions
      def self.hide(field, _args)
        if DFormed.in_opal?
          field.element.hide
        else
          puts "Can't hide outside of Opal"
        end
      end

      def self.show(field, _args)
        if DFormed.in_opal?
          field.element.show
        else
          puts "Can't show outside of Opal"
        end
      end

      def self.add_class(field, args)
        [args].flatten.each { |arg| field.add_class arg }
      end

      def self.remove_class(field, args)
        [args].flatten.each { |arg| field.remove_class arg }
      end

      def self.add_style(field, args)
        if args.is_a? String
          args = args.split(';').map do |style|
            spl = style.split(':')
            [spl.first.strip, spl[1].to_s.strip]
          end.to_h
        end
        if args.is_a?(Hash)
          args.each { |k, v| field.add_style(k, v) }
        else
          raise ArgumentError, 'Args must be valid css or a hash of style => value pairs'
        end
      end

      def self.remove_style(field, args)
        [args].flatten.each { |_arg| field.remove_style(k, '') }
      end

      def self.require(_field, _args)
        # Not supported yet
      end

      def self.unrequire(_field, _args)
        # Not supported yet
      end

      def self.clear(field, _args)
        field.clear if field.respond_to?(:clear)
      end

      def self.replace_with(field, args)
        return unless field.respond_to?(:value)
        value = field.value
        if value.is_a? Array
          field.value = value.map { |_v| args.to_s }
        else
          field.value = args.to_s
        end
      end

      def self.append(field, args)
        return unless field.respond_to?(:value)
        value = field.value
        if value.is_a? String
          field.value = "#{value}#{args}"
        elsif value.is_a? Array
          field.value = value.map { |v| "#{v}#{args}" }
        end
      end

      def self.prepend(field, args)
        return unless field.respond_to?(:value)
        value = field.value
        if value.is_a? String
          field.value = "#{args}#{value}"
        elsif value.is_a? Array
          field.value = value.map { |v| "#{args}#{v}" }
        end
      end

      def self.relabel(_field, _arg)
        # field.relabel arg
        # Probably deprecated and should not be used now that the Label class is a Connectable
      end

      def add_connection(field, _args)
        field.add_connection arg
      end

      def remove_connection(field, args)
        # Not yet supported
      end
    end
  end
end
