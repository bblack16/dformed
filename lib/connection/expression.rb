module DFormed
  class Connection
    class Expression
      include BBLib::Effortless

      attr_of Object, :expression, serialize: true
      attr_sym :operator, default: :is, serialize: true, pre_proc: proc { |x| raise ArgumentError, "Invalid operator #{x}." unless Connection.available_operators.include?(x.to_sym); x }
      attr_bool :inverse, default: false

      def check(value)
        res = Connection::Operators.send(operator, value, expression)
        inverse? ? !res : res
      end
    end
  end
end
