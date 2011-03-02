# Encoding: UTF-8

require 'test/unit'
require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class FreelingEnTest < Test::Unit::TestCase
  
  def test_should_be_able_to_start
    freeling = Sprakd::Provider::FreelingEn.new
    assert freeling.works?
  end

  def test_doesnt_die_on_japanese
    freeling = Sprakd::Provider::FreelingEn.new
    parse = freeling.parse('これは日本語です')
    assert_equal Sprakd::Parse::FreelingEn, parse.class
  end

  # TODO: UTF-8 handling
  def test_can_handle_utf8
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
    assert_equal [{:grammar => :personal}, {:grammar => :past}, {:grammar => nil}, {:grammar => nil}, {:grammar => nil}], words.collect(&:extra)
    
    assert_equal [[tokens[0]], [tokens[2]], [tokens[4]], [tokens[6]], [tokens[7]]], words.collect(&:tokens)
  end
  
  def test_possessive_endings_must_be_reattached
    freeling = Sprakd::Provider::FreelingEn.new
    parse = freeling.parse("This is Jane's sentence.")
    words = parse.words
    tokens = parse.tokens
    
    assert_equal ['This', 'is', "Jane's", 'sentence', '.'], words.collect(&:word)
    assert_equal ['this', 'be', "jane", 'sentence', '.'], words.collect(&:lemma)
    assert_equal [Sprakd::PartOfSpeech::Pronoun, Sprakd::PartOfSpeech::Verb, Sprakd::PartOfSpeech::ProperNoun, Sprakd::PartOfSpeech::Noun, Sprakd::PartOfSpeech::Symbol], words.collect(&:part_of_speech)
    assert_equal [{:grammar => :personal}, {:grammar => nil}, {:gramamr => nil}, {:grammar => nil}, {:grammar => nil}], words.collect(&:extra)
    assert_equal [[tokens[0]], [tokens[2]], tokens[4..5], [tokens[7]], [tokens[8]]], words.collect(&:tokens)
  end

  def test_date_parsing
    # Should be turned off. At least for now
    freeling = Sprakd::Provider::FreelingEn.new

    assert_parses_into_words(freeling,
                             {:words => ['January'],
                              :lemmas => ['january'],
                              :pos => [Sprakd::PartOfSpeech::Noun],
                              :extra => [{:grammar => nil}],
                              :tokens => [0..0]},
                             'January')
  end

  def test_symbol_parsing
    freeling = Sprakd::Provider::FreelingEn.new

    assert_parses_into_words(freeling,
                             {:words => ['.', ',', '$'],
                              :lemmas => ['.', ',', '$'],
                              :pos => [Sprakd::PartOfSpeech::Symbol, Sprakd::PartOfSpeech::Symbol, Sprakd::PartOfSpeech::Symbol],
                              :extra => [{:grammar => nil}, {:grammar => nil}, {:grammar => nil}],
                              :tokens => [0..0, 1..1, 2..2]},
                             '.,$')
  end

  def test_can_handle_underscores_properly
    # Should restore them
    freeling = Sprakd::Provider::FreelingEn.new
    parse = freeling.parse("In New York")
    words = parse.words
    tokens = parse.tokens
    
    assert_equal ['In', 'New York'], words.collect(&:word)
    assert_equal ['in', 'new york'], words.collect(&:lemma)
    assert_equal [Sprakd::PartOfSpeech::Preposition, Sprakd::PartOfSpeech::ProperNoun], words.collect(&:part_of_speech)
    assert_equal [{:grammar => nil}, {:grammar => nil}], words.collect(&:extra)
    assert_equal [tokens[0..0], tokens[2..2]], words.collect(&:tokens)

    # Should keep them
    # TODO
    freeling = Sprakd::Provider::FreelingEn.new
    parse = freeling.parse("In New_York")
    words = parse.words
    tokens = parse.tokens
    
    assert_equal ['In', 'New_York'], words.collect(&:word)
    assert_equal ['in', 'new_york'], words.collect(&:lemma)
    assert_equal [Sprakd::PartOfSpeech::Preposition, Sprakd::PartOfSpeech::ProperNoun], words.collect(&:part_of_speech)
    assert_equal [{:grammar => nil}, {:grammarl => nil}], words.collect(&:extra)
    assert_equal [tokens[0..1], tokens[2..2], tokens[3..11]], words.collect(&:tokens)
  end
  
end
