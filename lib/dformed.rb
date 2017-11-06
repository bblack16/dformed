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
require_relative 'dformed/element/element'
require_relative 'dformed/element/value_element'
require_relative 'dformed/fields/_fields'
