# Encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + "/../lib/ve")
require 'test/unit'

class VeTest < Test::Unit::TestCase

  def test_get
    assert_equal ['日本語', 'です'], Ve.get('日本語です', :ja, :words).collect(&:word)
  end 

  def test_in
    assert_equal ['日本語', 'です'], Ve.in(:ja).words('日本語です').collect(&:word)
  end
  
  def test_http_interface
    Ve.config(Ve::HTTPInterface, :url => 'http://localhost:4567')
    assert_equal ['日本語', 'です'], Ve.in(:ja).words('日本語です').collect(&:word)
  end

end
