# Encoding: UTF-8

require_relative 'test_helper'

class VeTest < MiniTest::Unit::TestCase
  # TODO: Set these up to run properly

  def test_get
    skip
    assert_equal ['日本語', 'です'], Ve.get('日本語です', :ja, :words).collect(&:word)
  end

  def test_in
    skip
    assert_equal ['日本語', 'です'], Ve.in(:ja).words('日本語です').collect(&:word)
  end

  def test_http_interface
    skip
    Ve.config(Ve::HTTPInterface, :url => 'http://localhost:4567')
    assert_equal ['日本語', 'です'], Ve.in(:ja).words('日本語です').collect(&:word)
  end
end
