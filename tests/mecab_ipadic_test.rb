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
  
end