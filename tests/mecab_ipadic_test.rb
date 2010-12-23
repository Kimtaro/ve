# Encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + "/../lib/sprakd")
require 'test/unit'

class MecabIpadicTest < Test::Unit::TestCase
  
  def test_should_be_able_to_start
    mecab = Sprakd::Provider::MecabIpadic.new
    assert mecab.works?
  end

  def test_can_parse
    mecab = Sprakd::Provider::MecabIpadic.new
    parse = mecab.parse('')
    assert_equal Sprakd::Parse::MecabIpadic, parse.class
  end
  
  def test_all_literals_should_equal_the_input_text
    text = <<-EOS
    古池や
    蛙飛び込む
    水の音
    
    EOS
    mecab = Sprakd::Provider::MecabIpadic.new
    parse = mecab.parse(text)
    assert_equal text, parse.tokens.collect { |t| t[:literal] }.join
  end
  
  def test_creates_tokens_from_data_that_is_ignored_in_parsing
    mecab = Sprakd::Provider::MecabIpadic.new
    parse = mecab.parse('A   B  ')
    assert_equal [:parsed, :unparsed, :parsed, :unparsed, :sentence_split], parse.tokens.collect { |t| t[:type] }
    assert_equal ['A', '   ', 'B', '  ', ''], parse.tokens.collect { |t| t[:literal] }
  end
  
  def test_can_give_sentences
    mecab = Sprakd::Provider::MecabIpadic.new
    parse = mecab.parse('これは文章である。で、also containing some Englishですね')
    assert_equal ['これは文章である。', 'で、also containing some Englishですね'], parse.sentences
  end
  
  def test_tokens_should_not_be_modified_when_attached_to_words
    mecab = Sprakd::Provider::MecabIpadic.new
    parse = mecab.parse('悪化する')
    tokens = parse.tokens
    assert_equal '悪化', tokens[0][:literal]
    assert_equal '悪化', tokens[0][:lemma]
  end

  # TODO: Test that entire rule tree
  def test_word_assembly
    mecab = Sprakd::Provider::MecabIpadic.new

    # For kopipe
    if false
      assert_parses_into_words({:words => [],
                                :lemmas => [],
                                :pos => [],
                                :grammar => [],
                                :tokens => []},
                               '')
    end

    # Meishi
    assert_parses_into_words({:words => ['車'],
                              :lemmas => ['車'],
                              :pos => [Sprakd::PartOfSpeech::Noun],
                              :grammar => [nil],
                              :tokens => [0..0]},
                             '車')
    
    # Koyuumeishi
    assert_parses_into_words({:words => ['太郎'],
                              :lemmas => ['太郎'],
                              :pos => [Sprakd::PartOfSpeech::ProperNoun],
                              :grammar => [nil],
                              :tokens => [0..0]},
                             '太郎')

    # Daimeishi
    assert_parses_into_words({:words => ['彼'],
                              :lemmas => ['彼'],
                              :pos => [Sprakd::PartOfSpeech::Pronoun],
                              :grammar => [nil],
                              :tokens => [0..0]},
                             '彼')

    # Kazu
    assert_parses_into_words({:words => ['一'],
                              :lemmas => ['一'],
                              :pos => [Sprakd::PartOfSpeech::Number],
                              :grammar => [nil],
                              :tokens => [0..0]},
                             '一')

    # Sahensetsuzoku + tokumi ta
    assert_parses_into_words({:words => ['悪化した'],
                              :lemmas => ['悪化する'],
                              :pos => [Sprakd::PartOfSpeech::Verb],
                              :grammar => [nil],
                              :tokens => [0..2]},
                             '悪化した')

    # Keiyoudoushigokan
    assert_parses_into_words({:words => ['重要な'],
                              :lemmas => ['重要だ'],
                              :pos => [Sprakd::PartOfSpeech::Adjective],
                              :grammar => [nil],
                              :tokens => [0..1]},
                             '重要な')

    # Naikeiyoushigokan
    assert_parses_into_words({:words => ['とんでもない'],
                              :lemmas => ['とんでもない'],
                              :pos => [Sprakd::PartOfSpeech::Adjective],
                              :grammar => [nil],
                              :tokens => [0..1]},
                             'とんでもない')
  end

  private

  def assert_parses_into_words(expected, text)
    mecab = Sprakd::Provider::MecabIpadic.new
    parse = mecab.parse(text)
    words = parse.words
    tokens = parse.tokens
    
    assert_equal expected[:words], words.collect(&:word)
    assert_equal expected[:lemmas], words.collect(&:lemma)
    assert_equal expected[:pos], words.collect(&:part_of_speech)
    assert_equal expected[:grammar], words.collect(&:grammar)

    words.each_with_index do |word, i|
      assert_equal tokens[expected[:tokens][i]], word.tokens
    end
  end
  
end
