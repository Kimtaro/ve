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
  
  def test_can_give_words
    mecab = Sprakd::Provider::MecabIpadic.new
    parse = mecab.parse('これは文章です')
    words = parse.words
    
    assert_equal ['これ', 'は', '文章', 'です'], words.collect(&:word)
    assert_equal ['これ', 'は', '文章', 'です'], words.collect(&:lemma)
    assert_equal [Sprakd::PartOfSpeech::Pronoun, Sprakd::PartOfSpeech::Verb, Sprakd::PartOfSpeech::Determiner, Sprakd::PartOfSpeech::Noun, Sprakd::PartOfSpeech::Symbol], words.collect(&:part_of_speech)
    assert_equal [:personal, :past, nil, nil, nil], words.collect(&:grammar)
    
    assert_equal [[tokens[0]], [tokens[2]], [tokens[4]], [tokens[6]]], words.collect(&:tokens)
  end
  
  def test_sahen_setsuzoku_should_eat_the_suru
    mecab = Sprakd::Provider::MecabIpadic.new
    parse = mecab.parse('悪化した')
    words = parse.words
    tokens = parse.tokens
    
    assert_equal ['悪化した'], words.collect(&:word)
    assert_equal ['悪化する'], words.collect(&:lemma)
    assert_equal [Sprakd::PartOfSpeech::Verb], words.collect(&:part_of_speech)
    assert_equal [nil], words.collect(&:grammar)
    
    assert_equal [tokens[0..2]], words.collect(&:tokens)

    # Make sure we haven't modified the contents of the tokens
    assert_equal '悪化', tokens[0][:literal]
    assert_equal '悪化', tokens[0][:lemma]
  end
  
end
