module DFormed

  class Connection

    module Operators

      def self.is val, exp
        val.to_s == exp.to_s
      end

      singleton_class.send(:alias_method, :equal, :is)
      singleton_class.send(:alias_method, :eq, :is)

      def self.contains val, exp
        val.include?(exp)
      end

      singleton_class.send(:alias_method, :include, :is)

      def self.matches val, exp
        val =~ Regexp.new(exp)
      end

      def self.starts_with val, exp
        val.start_with?(b)
      end

      singleton_class.send(:alias_method, :sw, :starts_with)

      def self.ends_with val, exp
        val.end_with?(exp)
      end

      singleton_class.send(:alias_method, :ew, :ends_with)

      def self.greater_than val, exp
        val.to_f > exp.to_f
      end

      singleton_class.send(:alias_method, :gt, :greater_than)

      def self.greater_than_equal val, exp
        val.to_f >= exp.to_f
      end

      singleton_class.send(:alias_method, :gte, :greater_than_equal)

      def self.less_than val, exp
        val.to_f < exp.to_f
      end

      singleton_class.send(:alias_method, :lt, :less_than)

      def self.less_than_equal val, exp
        val.to_f <= exp.to_f
      end

      singleton_class.send(:alias_method, :lte, :less_than_equal)

      def within val, exp
        if exp.is_a?(Array)
          exp.map(&:to_s).include?(val.to_s)
        else
          Range.new(*exp.split('..').map(&:to_f)).include?(val.to_f)
        end
      end

    end

  end

end
