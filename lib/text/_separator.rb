module DFormed

  # This module currently exists solely to group elements made to divide a form
  # or add text to a form (other than labels).
  # Basically, if it isn't a field, form or label
  class Separator < ElementBase

    def self.type
      :abstract
    end

  end

end
