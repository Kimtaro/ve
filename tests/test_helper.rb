require File.expand_path(File.dirname(__FILE__) + "/../lib/ve")

class Test::Unit::TestCase

  private

  def assert_parses_into_words(provider, expected, text)
    parse = provider.parse(text)
    words = parse.words
    tokens = parse.tokens
    
    assert_equal expected[:words], words.collect(&:word)
    assert_equal expected[:lemmas], words.collect(&:lemma)
    assert_equal expected[:pos], words.collect(&:part_of_speech)
    assert_equal expected[:extra], words.collect(&:extra)

    words.each_with_index do |word, i|
      assert_equal tokens[expected[:tokens][i]], word.tokens
    end
  end

end

