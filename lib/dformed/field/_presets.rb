module DFormed
  [:text, :integer, :date, :time, :float].each do |type|
    add_preset("multi_#{type}", type: :multi_field, template: { type: type })
  end
end
