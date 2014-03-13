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
      {a: {b: 1, c: 2}}.should_not json_match({a: {b: 1}})
    end
  end

  describe ".exactly" do
    context "used as key" do
      it "matches an equal hash" do
        {a: {b: 1}}.should json_match(exactly => {a: {b: 1}})
      end

      it "doesn't match an inequal hash" do
        {a: {b: 1, c: 2}}.should_not json_match(exactly => {a: {b: 1}})
      end

      it "can be nested" do
        {a: {b: 1, c: 2}}.should json_match({a: {exactly => {b: 1, c: 2}}})
      end
    end

    context "used as value" do
      it "matches an equal value" do
        {a: {b: 1}}.should json_match({a: exactly(b: 1)})
      end

      it "doesn't match an inequal value" do
        {a: {b: 1, c: 2}}.should_not json_match({a: exactly(b: 1)})
      end

      it "can be nested" do
        {a: {b: 1, c: 2}}.should json_match(a: exactly(exactly => {b: exactly(1), c: 2}))
      end
    end
  end
end
