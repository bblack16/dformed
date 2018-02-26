require_relative 'datetime'

module DFormed
  class Date < DateTime

    def custom_attributes
      super.merge(type: :date, value: value ? value.strftime('%Y-%m-%d') : nil)
    end
  end
end
