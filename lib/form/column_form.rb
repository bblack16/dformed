
module DFormed

  class ColumnForm < Form
    attr_reader :cols

    def cols= num
      @cols = num.to_i
    end

  end

end
