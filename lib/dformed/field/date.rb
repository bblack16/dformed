module DFormed
  class Date < Input
    # TODO Fix date field type
    attr_date :value, formats: ['%Y-%m-%d', '%m-%d-%Y', '%Y/%m/%d', '%d/%m/%Y']
  end
end
