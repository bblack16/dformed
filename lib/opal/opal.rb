

if DFormed.in_opal?
  
  class Element
    
    alias_native :prepend
    alias_native :replace_with, :replaceWith
    
  end
  
end