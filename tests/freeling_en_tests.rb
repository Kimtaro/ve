# Encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + "/../lib/sprakd")
require 'test/unit'

class FreelingEnTest < Test::Unit::TestCase
  
  def test_should_be_able_to_start
    freeling = Sprakd::Provider::FreelingEn.new
    assert freeling.works?
  end

  def test_can_parse
    freeling = Sprakd::Provider::FreelingEn.new
    parse = freeling.parse('')
    assert_equal Sprakd::Parse::FreelingEn, parse.class
  end
  
  def test_all_literals_should_equal_the_input_text
    text = <<-EOS
    There once was a man from X
    Who took it upon himself to Y
    Z
    
    EOS
    freeling = Sprakd::Provider::FreelingEn.new
    parse = freeling.parse(text)
    assert_equal text, parse.tokens.collect { |t| t[:literal] }.join
  end
  
  def test_creates_tokens_from_data_that_is_ignored_in_parsing
    freeling = Sprakd::Provider::FreelingEn.new
    parse = freeling.parse('A   B  ')
    assert_equal [:parsed, :unparsed, :parsed, :unparsed, :sentence_split], parse.tokens.collect { |t| t[:type] }
    assert_equal ['A', '   ', 'B', '  ', ''], parse.tokens.collect { |t| t[:literal] }
  end
  
  def test_can_give_sentences
    freeling = Sprakd::Provider::FreelingEn.new
    parse = freeling.parse('This is a sentence. And this was another one')
    assert_equal ['This is a sentence.', 'And this was another one'], parse.sentences
  end
  
  def test_can_give_words
    freeling = Sprakd::Provider::FreelingEn.new
    parse = freeling.parse('This was a sentence.')
    words = parse.words
    tokens = parse.tokens
    
    assert_equal ['This', 'was', 'a', 'sentence', '.'], words.collect(&:word)
    assert_equal ['this', 'be', 'a', 'sentence', '.'], words.collect(&:lemma)
    assert_equal [Sprakd::PartOfSpeech::Pronoun, Sprakd::PartOfSpeech::Verb, Sprakd::PartOfSpeech::Determiner, Sprakd::PartOfSpeech::Noun, Sprakd::PartOfSpeech::Symbol], words.collect(&:part_of_speech)
    assert_equal [:personal, :past, nil, nil, nil], words.collect(&:grammar)
    
    assert_equal [[tokens[0]], [tokens[2]], [tokens[4]], [tokens[6]], [tokens[7]]], words.collect(&:tokens)
  end
  
  def test_possessive_endings_must_be_reattached
    freeling = Sprakd::Provider::FreelingEn.new
    parse = freeling.parse("This is Jane's sentence.")
    words = parse.words
    tokens = parse.tokens
    
    assert_equal ['This', 'is', "Jane's", 'sentence', '.'], words.collect(&:word)
    assert_equal ['this', 'be', "jane's", 'sentence', '.'], words.collect(&:lemma)
    assert_equal [Sprakd::PartOfSpeech::Pronoun, Sprakd::PartOfSpeech::Verb, Sprakd::PartOfSpeech::ProperNoun, Sprakd::PartOfSpeech::Noun, Sprakd::PartOfSpeech::Symbol], words.collect(&:part_of_speech)
    assert_equal [:personal, nil, nil, nil, nil], words.collect(&:grammar)
    assert_equal [[tokens[0]], [tokens[2]], tokens[4..5], [tokens[7]], [tokens[8]]], words.collect(&:tokens)
  end
  
end