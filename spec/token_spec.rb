RSpec::Matchers.define :have_tokens do |*expected|
  match do |actual|
    @actual = Spellr::Token.tokenize(actual).map(&:to_s)
    expect(@actual).to match(expected)
  end

  diffable
end
RSpec::Matchers.alias_matcher :have_no_tokens, :have_tokens

RSpec.describe Spellr::Token do
  describe '.tokenize' do
    it 'returns tokens split by spaces' do
      expect("This line").to have_tokens "This", "line"
    end

    it 'returns tokens split by :' do
      expect("Spellr::Line").to have_tokens "Spellr", "Line"
    end

    it "doesn't tokenize a URL" do
      expect('click here https://google.com').to have_tokens 'click', 'here'
    end

    it "doesn't tokenize a URL in parentheses" do
      expect('[link](ftp://example.org)').to have_tokens 'link'
    end

    it "doesn't tokenize a URL in angle brackets" do
      expect('Dave <dave@example.com>').to have_tokens 'Dave'
    end

    it "doesn't tokenize a URL followed by punctuation" do
      expect('read this http://google.com, and this http://apple.com').to have_tokens 'read', 'this', 'and', 'this'
    end

    it "doesn't tokenize a URL with a query string" do
      expect('query https://the-google.com?query-string=whatever%2Bthing').to have_tokens 'query'
    end

    it "doesn't tokenize a URL with no scheme" do
      expect('click here //google.com').to have_tokens 'click', 'here'
    end

    it "doesn't tokenize an email" do
      expect('href="mailto:robot@dana.sh"').to have_tokens 'href'
    end

    it "doesn't tokenize an email with no scheme" do
      expect('send here: robot@dana.sh').to have_tokens 'send', 'here'
    end

    it "doesn't tokenize short words" do
      expect('to be or not to be').to have_tokens 'not'
    end

    it 'excludes URLs with numbers in them' do
      expect('http://www.the4wd.com').to have_no_tokens
    end

    it "doesn't tokenize numbers only" do
      expect('3.14 100 4,000').to have_no_tokens
    end

    it "doesn't tokenize maths only" do
      expect('1+1 1/2 10>4 15-10').to have_no_tokens
    end

    it "tokenizes html tags" do
      expect('<a style="background: red">').to have_tokens 'style', 'background', 'red'
    end

    it "doesn't tokenize CSS colours" do
      expect('color: #fee; background: #fad').to have_tokens 'color', 'background'
    end

    it "doesn't split on apostrophes" do
      expect("didn't shouldn't could've o'clock").to have_tokens "didn't", "shouldn't", "could've", "o'clock"
    end

    it "splits on wrapping quotes" do
      expect(%{"didn't" 'shouldn't' <could've> 'o'clock'}).to have_tokens "didn't", "shouldn't", "could've", "o'clock"
    end

    it "splits on underscore" do
      expect("this_that_the_other").to have_tokens 'this', 'that', 'the', 'other'
    end

    it "splits on underscore when all caps" do
      expect('SCREAMING_SNAKE_CASE').to have_tokens 'SCREAMING', 'SNAKE', 'CASE'
    end

    it "splits on dashes" do
      expect("align-items:center").to have_tokens 'align', 'items', 'center'
    end

    it "splits on dashes in all caps" do
      expect('CAPS-WITH-DASHES').to have_tokens 'CAPS', 'WITH', 'DASHES'
    end

    it 'splits on camel case' do
      expect("CamelCase camelCase").to have_tokens 'Camel', 'Case', 'camel', 'Case'
    end

    it 'splits on camel case with all caps' do
      expect("HTTParty GoogleAPI").to have_tokens 'HTT', 'Party', 'Google', 'API'
    end

    it "drops 's" do
      expect("do's and don't's").to have_tokens 'and', "don't"
    end

    it "drops 's with all caps" do
      expect("DO'S AND DON'T'S").to have_tokens 'AND', "DON'T"
    end

    it "drops 's with all camel case" do
      expect("TheThing's").to have_tokens 'The', "Thing"
    end
  end
end