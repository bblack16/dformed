# frozen_string_literal: true
require_relative 'validator'

# This module provides methods to implement validators with a Element
# Anything that uses this must either also include the Valuable module or
# implement a value attr itself
module DFormed
  module Validateable
    attr_reader :validator

    @validator = DFormed::Validator.new

    def validate
      @validator.validate(value, self)
    end

    def invalid_messages
      @validator.invalid_message
    end

    def serialize_validator
      @validator.to_h rescue nil
    end
  end
end
