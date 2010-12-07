require File.expand_path(File.dirname(__FILE__) + "/../lib/sprakd")
require 'test/unit'

class MecabIpadicTest < Test::Unit::TestCase
  
  def test_should_be_able_to_start
    @mecab = Sprakd::Provider::MecabIpadic.new
    assert @mecab.works?
  end
  
end