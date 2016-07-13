module DFormed

  class Connection < Base
    attr_reader :field, :expressions, :actions, :inactions
    @@cache = {}

    def compare field_a, field_b
      return unless match?(field_b.name)
      execute field_a, *(check(field_a, field_b) ? @actions : @inactions)
    end

    def available_operators
      @@cache[:operators] || (@@cache[:operators] = Operators.methods - Object.methods)
    end

    def available_actions
      @@cache[:actions] || (@@cache[:actions] = Actions.methods - Object.methods)
    end

    def field= field
      @field = field.to_s
    end

    def add_expression *hash, operator: nil, expression: nil, inverse: false
      hash = hash.to_h
      operator = hash.keys.first unless operator
      expression = hash.values.first unless expression
      raise ArgumentError, "Invalid operator for a Connection express: #{operator}" unless available_operators.include?(operator)
      @expressions.push({operator: operator, expression: expression, inverse: inverse})
    end

    def remove_expression index
      @expressions.delete_at index
    end

    def add_action *hash, action: nil, args: nil
      hash = hash.to_h
      action = hash.keys.first unless action
      args = hash.values.first unless args
      @actions.push({action: action, args: args}) if available_actions.include?(action)
    end

    def remove_action index
      @actions.delete_at index
    end

    def add_inaction *hash, action: nil, args: nil
      hash = hash.to_h
      action = hash.keys.first unless action
      args = hash.values.first unless args
      @inactions.push({action: action, args: args}) if available_actions.include?(action)
    end

    def remove_inaction index
      @inactions.delete_at index
    end

    protected

      def match? name
        if @field.is_a?(Array)
          @field.include?(name.to_s)
        else
          @field.to_s == name.to_s
        end
      end

      def check a, b
        @expressions.all? do |exp|
          res = Operators.send(exp[:operator], b.value, exp[:expression])
          exp[:inverse] ? !res : res
        end
      end

      def execute field, *actions
        actions.each do |action|
          Actions.send(action[:action], field, action[:args])
        end
      end

      def setup_vars
        @field = ''
        @expressions = Array.new
        @actions = Array.new
        @inactions = Array.new
      end

      def serialize_fields
        {
          field: { send: :field, unless: ''},
          expressions: { send: :expressions, unless: [] },
          actions: { send: :actions, unless: [] },
          inactions: { send: :inactions, unless: [] }
        }
      end

      def custom_init *args
        args.find_all{ |a| a.is_a?(Hash) }.each do |hash|
          hash.each do |k,v|
            case k
            when :action, :actions
              [v].flatten(1).each do |a|
                if a.include?(:action)
                  add_action(a)
                else
                  add_action(*a)
                end
              end
            when :inaction, :inactions
              [v].flatten(1).each do |a|
                if a.include?(:action)
                  add_inaction(a)
                else
                  add_inaction(*a)
                end
              end
            when :expression, :expressions
              [v].flatten(1).each do |e|
                if e.include?(:expression)
                  add_expression(e)
                else
                  add_expression(*e)
                end
              end
            else
              if available_operators.include?(k)
                add_expression(operator: k, expression: v)
              elsif available_actions.include?(k)
                add_action(action: k, args: v)
              end
            end
          end
        end
      end

  end

end
