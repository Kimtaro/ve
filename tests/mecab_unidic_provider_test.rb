# Encoding: UTF-8

require_relative 'test_helper'

class MecabUnidicProviderTest < MiniTest::Unit::TestCase
  # TODO: make these run without running mecab

  def test_should_be_able_to_start
    skip
    mecab = Ve::Provider::MecabUnidic.new
    assert mecab.works?
  end

  def test_can_parse
    skip
    mecab = Ve::Provider::MecabUnidic.new
    parse = mecab.parse('')
    assert_equal Ve::Parse::MecabUnidic, parse.class
  end
end
