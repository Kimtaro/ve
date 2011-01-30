# Encoding: UTF-8

require 'test/unit'
require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class TransliteratorsTest < Test::Unit::TestCase

  KATAKANA = "ァアィイゥウェエォオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂッツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマミムメモャヤュユョヨラリルレロヮワヰヱヲンヴヵヶ"
  HIRAGANA = "ぁあぃいぅうぇえぉおかがきぎくぐけげこごさざしじすずせぜそぞただちぢっつづてでとどなにぬねのはばぱひびぴふぶぷへべぺほぼぽまみむめもゃやゅゆょよらりるれろゎわゐゑをんゔゕゖ"

  def test_should_be_able_to_start
    trans = Sprakd::Provider::Transliterators.new
    assert trans.works?
  end
  
  def test_transliterate_from_hira_to_kata
    trans = Sprakd::Provider::Transliterators.new
    assert_equal KATAKANA, trans.parse(HIRAGANA).transliterate_from_hira_to_kata
  end

  def test_transliterate_from_kata_to_hira
    trans = Sprakd::Provider::Transliterators.new
    assert_equal HIRAGANA, trans.parse(KATAKANA).transliterate_from_kata_to_hira
  end

end
