# Encoding: UTF-8

require_relative 'test_helper'

class FreelingEnParseTest < MiniTest::Unit::TestCase

  def test_all_literals_should_equal_the_input_text
    text = <<-EOS
    There once was a man from X
    Who took it upon himself to Y
    Z

    EOS
    raw = ["There there EX 0.857656", "once once RB 0.809237", "was be VBD 1", "a a DT 0.333333", "man man NN 0.980535", "from from IN 1", "X x NNP 1", "", "Who who WP 1", "took take VBD 1", "it it PRP 1", "upon upon IN 0.915152", "himself himself PRP 1", "to to TO 0.999909", "Y y NNP 1", "", "Z z NNP 1", ""]
    parse = Ve::Parse::FreelingEn.new(text, raw)
    assert_equal text, parse.tokens.collect { |t| t[:literal] }.join
  end

  def test_creates_tokens_from_data_that_is_ignored_in_parsing
    text = 'A   B  '
    raw = ['A a DT 0.333333', 'B b NNP 1', '']
    parse = Ve::Parse::FreelingEn.new(text, raw)
    assert_equal [:parsed, :unparsed, :parsed, :unparsed, :sentence_split], parse.tokens.collect { |t| t[:type] }
    assert_equal ['A', '   ', 'B', '  ', ''], parse.tokens.collect { |t| t[:literal] }
  end

  def test_can_give_sentences
    text = 'This is a sentence. And this was another one'
    raw = ['This this PRP 0.0001755', 'is be VBZ 1', 'a a DT 0.333333', 'sentence sentence NN 0.966667', '. . Fp 1', '', 'And and CC 1', 'this this PRP 0.0001755', 'was be VBD 1', 'another another DT 0.999067', 'one one NN 0.25', '']
    parse = Ve::Parse::FreelingEn.new(text, raw)
    assert_equal ['This is a sentence.', 'And this was another one'], parse.sentences
  end

  def test_can_give_words
    text = 'This was a sentence.'
    raw = ['This this PRP 0.0001755', 'was be VBD 1', 'a a DT 0.333333', 'sentence sentence NN 0.966667', '. . Fp 1', '']
    parse = Ve::Parse::FreelingEn.new(text, raw)
    words = parse.words
    tokens = parse.tokens

    assert_equal ['This', 'was', 'a', 'sentence', '.'], words.collect(&:word)
    assert_equal ['this', 'be', 'a', 'sentence', '.'], words.collect(&:lemma)
    assert_equal [Ve::PartOfSpeech::Pronoun, Ve::PartOfSpeech::Verb, Ve::PartOfSpeech::Determiner, Ve::PartOfSpeech::Noun, Ve::PartOfSpeech::Symbol], words.collect(&:part_of_speech)
    assert_equal [{:grammar => :personal}, {:grammar => :past}, {:grammar => nil}, {:grammar => nil}, {:grammar => nil}], words.collect(&:extra)

    assert_equal [[tokens[0]], [tokens[2]], [tokens[4]], [tokens[6]], [tokens[7]]], words.collect(&:tokens)
  end

  def test_words_can_handle_contractions
    text = "I'm eating."
    raw = ['I i PRP 1', "'m 'm VBP 0.997563", 'eating eat VBG 1', '. . Fp 1', '']
    parse = Ve::Parse::FreelingEn.new(text, raw)
    assert_equal ["I'm", "eating", "."], parse.tokens.collect { |t| t[:literal] }
  end

  def test_possessive_endings_must_be_reattached
    text = "This is Jane's sentence."
    raw = ["This this PRP 0.0001755", "is be VBZ 1", "Jane jane NNP 1", "'s 's POS 0.751711", "sentence sentence NN 0.966667", ". . Fp 1", ""]
    parse = Ve::Parse::FreelingEn.new(text, raw)
    words = parse.words
    tokens = parse.tokens

    assert_equal ['This', 'is', "Jane's", 'sentence', '.'], words.collect(&:word)
    assert_equal ['this', 'be', "jane", 'sentence', '.'], words.collect(&:lemma)
    assert_equal [Ve::PartOfSpeech::Pronoun, Ve::PartOfSpeech::Verb, Ve::PartOfSpeech::ProperNoun, Ve::PartOfSpeech::Noun, Ve::PartOfSpeech::Symbol], words.collect(&:part_of_speech)
    assert_equal [{:grammar => :personal}, {:grammar => nil}, {:grammar => nil}, {:grammar => nil}, {:grammar => nil}], words.collect(&:extra)
    assert_equal [[tokens[0]], [tokens[2]], tokens[4..5], [tokens[7]], [tokens[8]]], words.collect(&:tokens)
  end

  def test_date_parsing
    # Should be turned off. At least for now
    assert_parses_into_words(Ve::Parse::FreelingEn,
                             {:words => ['January'],
                              :lemmas => ['january'],
                              :pos => [Ve::PartOfSpeech::Noun],
                              :extra => [{:grammar => nil}],
                              :tokens => [0..0]},
                             'January', ['January january NN 1'])
  end

  def test_symbol_parsing
    assert_parses_into_words(Ve::Parse::FreelingEn,
                             {:words => ['.', ',', '$'],
                              :lemmas => ['.', ',', '$'],
                              :pos => [Ve::PartOfSpeech::Symbol, Ve::PartOfSpeech::Symbol, Ve::PartOfSpeech::Symbol],
                              :extra => [{:grammar => nil}, {:grammar => nil}, {:grammar => nil}],
                              :tokens => [0..0, 1..1, 2..2]},
                             '.,$', ['. . Fp 1', ', , Fc 1', '$ $ Fp', ''])
  end

  def test_can_handle_underscores_properly
    # Should restore them
    text = 'In New York'
    raw = ['In in IN 0.986184', 'New_York new_york NNP 1', '']
    parse = Ve::Parse::FreelingEn.new(text, raw)
    words = parse.words
    tokens = parse.tokens

    assert_equal ['In', 'New York'], words.collect(&:word)
    assert_equal ['in', 'new york'], words.collect(&:lemma)
    assert_equal [Ve::PartOfSpeech::Preposition, Ve::PartOfSpeech::ProperNoun], words.collect(&:part_of_speech)
    assert_equal [{:grammar => nil}, {:grammar => nil}], words.collect(&:extra)
    assert_equal [tokens[0..0], tokens[2..2]], words.collect(&:tokens)

    # Should keep them
    # TODO
    skip
    text = 'In New_York'
    raw = ['In in IN 0.986184', 'New_York new_york NNP 1', '']
    parse = Ve::Parse::FreelingEn.new(text, raw)
    words = parse.words
    tokens = parse.tokens

    assert_equal ['In', 'New_York'], words.collect(&:word)
    assert_equal ['in', 'new_york'], words.collect(&:lemma)
    assert_equal [Ve::PartOfSpeech::Preposition, Ve::PartOfSpeech::ProperNoun], words.collect(&:part_of_speech)
    assert_equal [{:grammar => nil}, {:grammarl => nil}], words.collect(&:extra)
    assert_equal [tokens[0..1], tokens[2..2], tokens[3..11]], words.collect(&:tokens)
  end

end

