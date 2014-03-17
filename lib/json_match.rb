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
      expected.should be_kind_of(actual.class), "expected #{actual.inspect} to match #{expected.inspect}"
      case actual
      when Array
        actual.length.should equal(expected.length), "expected #{actual.inspect} to be the same length as #{expected.inspect}"

        expected.each_index do |i|
          recursive_check(actual[i], expected[i], exact)
        end
      when Hash
        if exact
          (actual.keys.sort == expected.keys.map(&:to_s).sort).should be_true, "expected #{actual.inspect} to have only the keys #{expected.keys.map(&:to_s).inspect}"
        else
          (expected.keys.map(&:to_s) - actual.keys).should be_empty, "expected #{actual.inspect} to include the keys #{expected.keys.map(&:to_s).inspect}"
        end

        expected.keys.each do |k|
          recursive_check(actual[k.to_s], expected[k], exact)
        end
      else
        actual.should == expected
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
