# Encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + "/../lib/sprakd")
require 'test/unit'

class SprakdTest < Test::Unit::TestCase

  def test_get
    assert_equal ['日本語', 'です'], Sprakd.get('日本語です', :ja, :words).collect(&:word)
  end 

  def test_in
    assert_equal ['日本語', 'です'], Sprakd.in(:ja).words('日本語です').collect(&:word)
  end 

end
