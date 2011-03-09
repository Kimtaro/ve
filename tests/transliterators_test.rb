# Encoding: UTF-8

require 'test/unit'
require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class TransliteratorsTest < Test::Unit::TestCase

  KATAKANA = "ァアィイゥウェエォオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂッツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマミムメモャヤュユョヨラリルレロヮワヰヱヲンヴヵヶ"
  HIRAGANA = "ぁあぃいぅうぇえぉおかがきぎくぐけげこごさざしじすずせぜそぞただちぢっつづてでとどなにぬねのはばぱひびぴふぶぷへべぺほぼぽまみむめもゃやゅゆょよらりるれろゎわゐゑをんゔゕゖ"

  def test_should_be_able_to_start
    trans = Ve::Provider::Transliterators.new
    assert trans.works?
  end

  def test_transliterate_from_hira_to_latn
    trans = Ve::Provider::Transliterators.new
    assert_equal 'kosoado',   trans.parse('こそあど').transliterate_from_hira_to_latn
    assert_equal 'konna',     trans.parse('こんな').transliterate_from_hira_to_latn
    assert_equal 'konyaku',   trans.parse('こにゃく').transliterate_from_hira_to_latn
    assert_equal 'kon\'yaku', trans.parse('こんやく').transliterate_from_hira_to_latn
    assert_equal 'shinbun',   trans.parse('しんぶん').transliterate_from_hira_to_latn
    assert_equal 'appa',      trans.parse('あっぱ').transliterate_from_hira_to_latn
  end
  
  def test_transliterate_from_hira_to_kata
    trans = Ve::Provider::Transliterators.new
    assert_equal KATAKANA, trans.parse(HIRAGANA).transliterate_from_hira_to_kata
  end

  def test_transliterate_from_kata_to_hira
    trans = Ve::Provider::Transliterators.new
    assert_equal HIRAGANA, trans.parse(KATAKANA).transliterate_from_kata_to_hira
  end

  def test_transliterate_from_kana_to_latn
    trans = Ve::Provider::Transliterators.new
    assert_equal 'hiraganakatakana', trans.parse('ひらがなカタカナ').transliterate_from_kana_to_latn
    
  end

end
