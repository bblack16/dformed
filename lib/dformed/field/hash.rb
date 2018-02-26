module DFormed
  class HashField < Json
    attr_hash :value, default: {}, pre_proc: proc { |x| x.is_a?(String) ? JSON.parse(x) : x }
  end
end
