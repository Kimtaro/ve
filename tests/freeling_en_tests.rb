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
  
end