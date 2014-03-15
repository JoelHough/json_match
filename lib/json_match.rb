require 'rspec'

module JsonMatch
  class JsonMatcher
    include RSpec::Matchers

    def initialize(expected)
      @expected = expected
    end

    def matches?(actual)
      @actual = actual
      begin
        recursive_check(@actual, @expected, false)
      rescue RSpec::Expectations::ExpectationNotMetError => e
        @failure_message = e
        false
      end
    end

    def failure_message_for_should
      @failure_message || "expected #{@actual.inspect} to match #{@expected.inspect}"
    end

    def failure_message_for_should_not
      "expected #{@actual.inspect} not to match #{@expected.inspect}"
    end

    def recursive_check(actual, expected, exact)
      return instance_exec(actual, &expected) if expected.is_a?(Proc)

      return actual.should == expected if !actual.is_a?(Hash)

      expected.should be_kind_of(Hash), "expected #{actual.inspect} to match #{expected.inspect}"

      if exact
        (actual.keys.sort == expected.keys.map(&:to_s).sort).should be_true, "expected #{actual.inspect} to have only the keys #{expected.keys.map(&:to_s).inspect}"
      else
        (expected.keys.map(&:to_s) - actual.keys).should be_empty, "expected #{actual.inspect} to include the keys #{expected.keys.map(&:to_s).inspect}"
      end

      expected.keys.each do |k|
        recursive_check(actual[k.to_s], expected[k], exact)
      end
    end
  end

  def json_match(expected)
    JsonMatcher.new(expected)
  end

  def include_json(expected)
    ->(actual) {recursive_check(actual, expected, false)}
  end

  def exact_json(expected)
    ->(actual) {recursive_check(actual, expected, true)}
  end

  def any_json
    ->(actual) {true}
  end
end
