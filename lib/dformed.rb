
module DFormed
  def self.in_opal?
    RUBY_ENGINE == 'opal'
  end
end

unless RUBY_ENGINE == 'opal'
  # Checks to see if we are currently in Opal or Ruby
  begin
    require 'opal'
    Opal.append_path File.expand_path('..', __FILE__).untaint
  rescue LoadError => e
  end
end

require_relative 'dformed/version'
require_relative 'general/general'
require_relative 'general/connectable'
require_relative 'general/base'
require_relative 'general/element_base'
require_relative 'general/form_element'
require_relative 'text/_requires'
require_relative 'form/_form'
require_relative 'field/_requires'
require_relative 'controller/controller'
