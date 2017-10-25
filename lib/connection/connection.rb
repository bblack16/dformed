# frozen_string_literal: true
module DFormed
  class Connection
    include BBLib::Effortless

    require_relative 'expression'
    require_relative 'action'

    attr_str :field, serialize: true
    attr_ary_of Expression, :expressions, default: [], serialize: true, add_rem: true, adder_name: :add_expression, remover_name: :remove_expression
    attr_ary_of Action, :actions, default: [], serialize: true, add_rem: true, adder_name: :add_action, remover_name: :remove_action
    attr_ary_of Action, :inactions, default: [], serialize: true, add_rem: true, adder_name: :add_inaction, remover_name: :remove_inaction

    @cache = {}

    alias action= actions=
    alias inaction= inactions=

    def compare(field_a, field_b)
      return unless match?(field_b.name)
      execute field_a, *(check(field_a, field_b) ? @actions : @inactions)
    end

    def self.available_operators
      @cache[:operators] ||= Operators.methods - Object.methods
    end

    def self.available_actions
      @cache[:actions] ||= Actions.methods - Object.methods
    end

    def self.refresh_available
      available_operators = Operators.methods - Object.methods
      available_actions = Actions.methods - Object.methods
    end

    def available_operators
      self.class.available_operators
    end

    def available_actions
      self.class.available_actions
    end

    protected

    def match?(name)
      if field.is_a?(Array)
        field.include?(name.to_s)
      else
        field.to_s == name.to_s
      end
    end

    def check(_a, b)
      expressions.all? { |exp| exp.check(b.value) }
    end

    def execute(field, *actions)
      actions.each { |action| action.execute(field) }
    end

    def simple_init(*args)
      args.find_all { |a| a.is_a?(Hash) }.each do |hash|
        hash.each do |k, v|
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
