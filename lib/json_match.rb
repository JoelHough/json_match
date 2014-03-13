require 'rspec'

RSpec::Matchers.define :json_match do |expected|
  match do |actual|
    JsonMatch::match(actual, expected)
  end
end

module JsonMatch
  def self.match(actual, expected)
    unless expected.is_a? Hash
      if expected.respond_to?(:call)
        expected.call(actual)
      else
        expected == actual
      end
    else
      explicit_keys = expected.keys.reject{|k| k.respond_to?(:call)}
      return false if explicit_keys.any? && explicit_keys.to_set != actual.keys.to_set
      expected.keys.all? do |expected_key|
        unless expected_key.respond_to? :call
          actual.has_key?(expected_key) && match(actual[expected_key], expected[expected_key])
        else
          expected_key.call(actual, expected[expected_key])
        end
      end
    end
  end

  def exactly(expected_value=nil)
    if expected_value
      proc do |actual|
        JsonMatch::match(actual, expected_value)
      end
    else
      proc do |actual, expected|
        JsonMatch::match(actual, expected)
      end
    end
  end
end
