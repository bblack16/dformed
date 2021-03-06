# frozen_string_literal: true
module DFormed
  module Registry
    def self.registry
      @registry ||= load_registry
    end

    def self.registry=(hash)
      @registry = hash if hash.is_a?(Hash)
    end

    def self.include?(type)
      registry.include?(type)
    end

    def self.load_registry(*namespaces)
      registry = {} unless registry
      namespaces = [DFormed] if namespaces.empty?
      namespaces.each do |namespace|
        namespace.constants.each do |constant|
          con = namespace.const_get(constant.to_s)
          next unless con.respond_to?(:type)
          [con.type].flatten.each do |type|
            registry[type] = "#{namespace}::#{constant}" unless type.nil? || type == :abstract
          end
        end
      end
      registry
    end

    def self.reload_registry(*namespaces)
      registry = {}
      load_registry(*namespaces)
    end

    def self.presets
      @presets ||= {}
    end

    class << self
      alias preset presets
    end

    def self.add_preset(name, elem)
      elem = elem.serialize if elem.is_a?(Element)
      raise ArgumentError, "Element must be a hash. Cannot be a #{elem.class}." unless elem.is_a?(Hash)
      raise ArgumentError, "Preset hashes must contain an element type." unless elem[:type]
      presets[name.to_sym] = elem
    end

    def self.remove_preset(name)
      presets.remove(name)
    end

    def self.preset?(name)
      presets.include?(name)
    end
  end
end
