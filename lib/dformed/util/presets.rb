module DFormed
  def self.presets
    @presets ||= {}
  end

  def self.add_preset(name, element)
    raise ArgumentError, "Invalid element for preset. Expected a Hash or DFormed::Element, got a #{element.class}." unless BBLib.is_any?(element, Hash, Element)
    presets[name.to_sym] = element.is_a?(Element) ? element.serialize(true) : element
  end

  def self.clear_preset(name)
    return nil unless preset?(name)
    presets.delete(name)
  end

  class << self
    alias remove_preset clear_preset
  end

  def self.preset?(name)
    presets.include?(name)
  end

  def self.preset(name)
    presets[name]
  end
end
