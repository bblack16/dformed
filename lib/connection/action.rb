module DFormed
  class Connection
    class Action
      include BBLib::Effortless

      attr_sym :action, default: :show, serialize: true, pre_proc: proc { |x| raise ArgumentError, "Invalid operator #{x}." unless Connection.available_actions.include?(x.to_sym); x }
      attr_of Object, :args, default: nil, allow_nil: true, serialize: true

      def execute(field)
        Actions.send(action, field, args)
      rescue => e
        puts e
      end

      protected

      def simple_init(*args)
        args.each do |arg|
          next unless arg.is_a?(Hash)
          next if arg[:action]
          arg.each do |k, v|
            self.action = k
            self.args = v
          end
        end
      end
    end
  end
end
