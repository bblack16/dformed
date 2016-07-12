
module DFormed

  class FormElement < ElementBase
    attr_reader :name, :parent, :description

    def parent= par
      @parent = par
    end

    def name= name
      @name = name.to_s
    end

    def description= t
      @description = t.to_s
    end

    def html_template= temp
      @html_template = temp.to_s
    end

    protected


###############################################
# REDEFINE
# => The following should be reimplemented in child classes

      def inner_html
        # This sets up the inner html for the to_html call
      end

      def setup_vars
        super
        @name = nil
        @parent = nil
        @description = ''
      end

      def serialize_fields
        # Make this return a hash of fields you want serialized
        # Format is {serialized_name => {send: :method_to_call, unless: nil}}
        # Be sure to merge with super if this is reimplemented
        #     super.merge({})
        super.merge(
          {
            name: { send: :name },
            description: { send: :description, unless: '' }
          }
        )
      end

      def custom_init *args
        # Defined custom initialization here...
      end
#
# END OF REDEFINE
##############################################

  end

end
