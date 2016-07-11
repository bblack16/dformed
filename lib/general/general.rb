

module DFormed

  def self.keys_to_sym obj
    if obj.is_a?(Hash)
      obj.inject({}) do |memo,(k,v)|
        memo[k.to_s.to_sym] = ( v.is_a?(Hash) || v.is_a?(Array) ? keys_to_sym(v) : v )
        memo
      end
    elsif obj.is_a?(Array)
      obj.map{ |v| v.is_a?(Hash) || v.is_a?(Array) ? keys_to_sym(v) : v }
    end
  end

end
