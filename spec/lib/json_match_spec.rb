require 'json_match'

describe 'JsonMatch' do
  include JsonMatch

  describe "json_match" do
    it "matches trivial equality" do
      {}.should json_match({})
    end

    it "doesn't match trivial inequality" do
      {}.should_not json_match(5)
    end

    it "doesn't match an inequal hash" do
      {'a' => {'b' => 2}}.should_not json_match({'a' => {'b' => 1}})
    end

    it "matches a superset hash" do
      {'a' => {'b' => 1, 'c' => 2}}.should json_match({'a' => {'b' => 1}})
    end

    it "calls a proc hash value with the actual hash at that point" do
      {'a' => {'b' => 1, 'c' => 2}}.should json_match({'a' => {'b' => ->(v) {v.should == 1}}})
      {'a' => {'b' => 1, 'c' => 2}}.should json_match({'a' => {'b' => ->(v) {v.should_not == 2}}})
      {'a' => {'b' => 1, 'c' => 2}}.should_not json_match({'a' => {'b' => ->(v) {v.should == 2}}})
      {'a' => {'b' => 1, 'c' => 2}}.should_not json_match({'a' => {'b' => ->(v) {v.should_not == 1}}})
    end
  end

  describe ".exact_json" do
    it "matches an equal value" do
      {'a' => {'b' => 1}}.should json_match({'a' => exact_json('b' => 1)})
    end

    it "doesn't match an inequal value" do
      {'a' => {'b' => 1, 'c' => 2}}.should_not json_match({'a' => exact_json('b' => 1)})
    end

    it "can be nested" do
      {'a' => {'b' => 1, 'c' => 2}}.should json_match('a' => exact_json({'b' => exact_json(1), 'c' => 2}))
    end
  end

  describe ".include_json" do
    it "matches an equal hash" do
      {'a' => {'b' => 1}}.should json_match(include_json('a' => {'b' => 1}))
    end

    it "matches a superset hash" do
      {'a' => {'b' => 1, 'c' => 1}}.should json_match(include_json('a' => {'b' => 1}))
    end

    it "doesn't match a subset hash" do
      {'a' => {'b' => 1}}.should_not json_match(include_json({'a' => {'b' => 1, 'c' => 2}}))
    end

    it "can be nested" do
      {'a' => {'b' => {'d' => 3, 'e' => 4}, 'c' => 2}}.should json_match('a' => include_json('b' => include_json('e' => 4)))
    end
  end

  describe "omnibus" do
    it "matches all the things" do
      hash = {
        'a' => {
          'b' => [2, 4, 8],
          'c' => "hallo"
        },
        'd' => 1
      }
      hash.should json_match(a: any_json)
      hash.should json_match(a: {
                               b: ->(a) do
                                 a.size.should == 3
                                 a.each {|e| e.should be_even}
                               end,
                               c: "hallo"
                             })
      hash.should json_match(exact_json(a: include_json(b: [2,4,8], c: any_json),
                                        d: 1))
    end
  end
end
