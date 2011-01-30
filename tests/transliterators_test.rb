# Encoding: UTF-8

require 'test/unit'
require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class TransliteratorsTest < Test::Unit::TestCase

  def test_should_be_able_to_start
    trans = Sprakd::Provider::Transliterators.new
    assert trans.works?
  end

end
