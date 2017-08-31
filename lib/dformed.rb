require 'bblib' unless defined?(BBLib::VERSION)

module DFormed
  def self.in_opal?
    RUBY_ENGINE == 'opal'
  end

  def self.jquery_ui?
    in_opal? ? `typeof $.ui != 'undefined'` : false
  end
end

unless RUBY_ENGINE == 'opal'
  # Checks to see if we are currently in Opal or Ruby
  begin
    require 'opal'
    Opal.append_path File.expand_path('..', __FILE__).untaint
  rescue LoadError => e
    puts e, e.backtrace
  end
end

require_relative 'dformed/version'
require_relative 'connection/_connection'
require_relative 'general/element'
require_relative 'general/value_element'
require_relative 'general/options'
require_relative 'text/_requires'
require_relative 'button/button'
require_relative 'form/_form'
require_relative 'field/_requires'
require_relative 'controller/controller'
require_relative 'general/registry'
require_relative 'general/dformed'
require_relative 'general/loader'
