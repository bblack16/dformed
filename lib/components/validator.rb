module DFormed

  class Validator < BBLib::LazyClass
    attr_reader :active, :checks, :invalid_message, :classes, :styles

    def active= a
      @active = a == true || a = 'true'
    end

    def checks= exp
      [exp].flatten(1).each{ |e| add_check e }
    end

    def add_check hash
      hash = { expression: hash } unless hash.is_a?(Hash)
      @checks.push(
        {
          expression: deserialize_expressions([hash[:expression]].flatten(1)),
          type:       hash[:type]    || :any,
          inverse:    hash[:inverse] || false,
          message:    hash[:message] || 'invalid entry'
        }
      )
    end

    def validate value, field
      @invalid_message = []
      valid = @checks.all? do |exp|
        validity = validate_value(value, exp)
        validity = !validity if exp[:inverse]
        @invalid_message.push exp[:message] unless validity
        validity
      end
      apply_changes valid, field
      valid
    end

    def classes= klasses
      @classes = klasses.map{ |m| m.to_s }
    end

    def add_class klass
      @classes.push klass
    end

    def remove_class klass
      @classes.delete klass
    end

    def styles= a
      @styles = Hash.new
      a.each do |k,v|
        add_style k, v
      end
    end

    def add_style k, v
      @styles[k.to_s] = v.to_s
    end

    def remove_style k
      @styles.delete k.to_s
    end

    protected

      def validate_value value, expressions, exp = nil
        exp = expressions[:expression] if exp.nil?
        case [exp.class]
        when [String], [Fixnum], [Float]
          exp == value
        when [Regexp]
          exp =~ value
        when [Range]
          exp === value
        when [Array]
          compound_validate value, expressions
        else
          true # Can't validate...so true?
        end
      end

      def compound_validate value, expressions
        exp = expressions[:expression]
        case expressions[:type].to_s.downcase.to_sym
        when :all
          exp.all? do |e|
            validate_value value, expressions, e
          end
        when :any
          exp.any? do |e|
            validate_value value, expressions, e
          end
        else
          false
        end
      end

      def apply_changes valid, field
        if valid
          @classes.each{ |c| field.remove_class(c) }
          @styles.each{ |s, v| field.remove_style(s) }
        else
          @classes.each{ |c| field.add_class(c) }
          @styles.each{ |s, v| field.add_style(s, v) }
        end
      end

      def setup_vars
        @active = false
        @checks = Array.new
        @classes = Array.new
        @styles = Hash.new
      end

      def custom_init *args
        args.each do |a|
          allow = [String, Regexp, Range, Array]
          add_check(a) if allow.any?{ |c| a.class == c }
        end
      end

      def serialize_fields
        {
          active: { send: :active, unless: false},
          checks: { send: :serialize_checks, unless: [] }
        }
      end

      def serialize_checks
        @checks.map do |exp|
          temp = exp.dup
          temp[:expression] = serialize_type(temp[:expression])
          ignore = { expression: nil, type: :any, message: 'invalid entry', inverse: false}
          temp.keys.each{ |k| temp.delete(k) if temp[k] == ignore[k] }
          temp
        end
      end

      def serialize_type obj
        case [obj.class]
        when [String], [Fixnum], [Float]
          obj
        when [Regexp]
          "!regexp #{obj}"
        when [Range]
          "!range #{obj}"
        when [Array]
          obj.map{ |o| serialize_type o }
        end
      end

      def deserialize_expressions exps
        exps.map do |exp|
          convert_type exp
        end
      end

      def convert_type obj
        if obj.is_a?(String)
          if obj.start_with?('!regexp ')
            letters = (obj.to_s.scan(/\?\w+[\-\:]/).first.scan(/\w/) rescue [])
            options = (
              (letters.include?('i') ? Regexp::IGNORECASE : 0) |
              (letters.include?('m') ? Regexp::MULTILINE : 0) |
              (letters.include?('x') ? Regexp::EXTENDED : 0)
            )
            Regexp.new(obj[15..-2], options)
          elsif obj.start_with?('!range ')
            Range.new(*obj.scan(/\-?\d+/)[0..1])
          else
            obj
          end
        elsif obj.is_a?(Array)
          obj.map{ |o| convert_type o }
        else
          obj
        end
      end

  end

end
