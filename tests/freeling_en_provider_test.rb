# Encoding: UTF-8

require_relative 'test_helper'

class FreelingEnProviderTest < MiniTest::Unit::TestCase
  # TODO: Make these tests not require running freeling

  def test_should_be_able_to_start
    skip
    Ve::Provider::FreelingEn.any_instance.expects(:start!).returns({})
    Ve::Provider::FreelingEn.any_instance.expects(:parse).returns(Ve::Parse::FreelingEn.new("Wrote", ["Wrote write VBD 1", ""]))
    freeling = Ve::Provider::FreelingEn.new
    assert freeling.works?
  end

  def test_doesnt_die_on_japanese
    skip
    freeling = Ve::Provider::FreelingEn.new
    parse = freeling.parse('これは日本語です')
    assert_equal Ve::Parse::FreelingEn, parse.class
  end

  # TODO: UTF-8 handling
  def test_can_handle_utf8
    skip
    freeling = Ve::Provider::FreelingEn.new
    parse = freeling.parse('I’m')
    assert_equal ['I\'m'], parse.tokens.collect { |t| t[:literal] }
  end
  
  def test_can_parse
    skip
    freeling = Ve::Provider::FreelingEn.new
    parse = freeling.parse('')
    assert_equal Ve::Parse::FreelingEn, parse.class
  end

end
