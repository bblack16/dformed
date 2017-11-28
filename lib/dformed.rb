require 'bblib' unless defined?(BBLib::VERSION)

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
require_relative 'dformed/util/presets'
require_relative 'dformed/element/element'
require_relative 'dformed/element/value_element'
require_relative 'dformed/general/_general'
require_relative 'dformed/field/_fields'
require_relative 'dformed/form/_forms'
require_relative 'dformed/controller/controller'
require_relative 'dformed/util/form_generation'
