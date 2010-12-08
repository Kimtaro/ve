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
  
end