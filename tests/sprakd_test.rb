# Encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + "/../lib/sprakd")
require 'test/unit'

class SprakdTest < Test::Unit::TestCase

  def test_general_interface
    assert_equal ['日本語', 'です'], Sprakd.get('日本語です', :ja, :words).collect(&:word)
  end 

end
