# frozen_string_literal: true
module DFormed
  class Options
    include BBLib::Effortless

    attr_hash :options, default: {}, serialize: true, always: true, pre_proc: proc { |x| x.is_a?(Array) ? x.map { |j| [j.to_s, j.to_s] }.to_h : x }
    attr_str :url, :key_path, :value_path, default: nil, allow_nil: true, serialize: true
    attr_bool :retrieved, default: false, serialize: false
    attr_of Object, :parent, default: nil, allow_nil: true, serialize: false

    before :retrieve_options, :options

    def retrieve_options
      return unless !retrieved? && url && DFormed.in_opal?
      self.retrieved = true
      HTTP.get(url) do |response|
        if response.ok?
          if key_path
            @options = response.json.hpath(key_path, value_path || key_path, multi_join: true).to_h
          else
            @options = response.json
          end
          notify_parent
        else
          puts "Failed to get data from #{url}"
        end
      end
    rescue => e
      # Nothing for now...
    end

    def notify_parent
      parent.options_updated if parent && parent.respond_to?(:options_updated)
    end

    def method_missing method, *args, &block
      if options.respond_to?(method)
        options.send(method, *args, &block)
      else
        super
      end
    end

    def respond_to_missing method, ignore = false
      options.respond_to?(method) || super
    end
  end
end
