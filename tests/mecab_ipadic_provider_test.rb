# Encoding: UTF-8

require_relative 'test_helper'

class MecabIpadicProviderTest < MiniTest::Unit::TestCase
  # TODO: make these run without running mecab

  def test_should_be_able_to_start
    skip
    mecab = Ve::Provider::MecabIpadic.new
    assert mecab.works?
  end

  def test_can_parse
    skip
    mecab = Ve::Provider::MecabIpadic.new
    parse = mecab.parse('')
    assert_equal Ve::Parse::MecabIpadic, parse.class
  end

end
