# Encoding: UTF-8

require_relative 'test_helper'

class JapaneseTransliteratorsTest < Test::Unit::TestCase

  KATAKANA = "ァアィイゥウェエォオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂッツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマミムメモャヤュユョヨラリルレロヮワヰヱヲンヴヵヶ"
  HIRAGANA = "ぁあぃいぅうぇえぉおかがきぎくぐけげこごさざしじすずせぜそぞただちぢっつづてでとどなにぬねのはばぱひびぴふぶぷへべぺほぼぽまみむめもゃやゅゆょよらりるれろゎわゐゑをんゔゕゖ"
  HALFWIDTH = "!\"\#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ "
  FULLWIDTH = "！＂＃＄％＆＇（）＊＋，－．／０１２３４５６７８９：；＜＝＞？＠ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ［＼］＾＿｀ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ｛｜｝～　"
  
  def setup
    @trans = Ve::Provider::JapaneseTransliterators.new
  end
  
  def test_should_be_able_to_start
    assert @trans.works?
  end

  def test_transliterate_from_hira_to_latn
    assert_equal 'kosoado',   @trans.parse('こそあど').transliterate_from_hira_to_latn
    assert_equal 'konna',     @trans.parse('こんな').transliterate_from_hira_to_latn
    assert_equal 'konyaku',   @trans.parse('こにゃく').transliterate_from_hira_to_latn
    assert_equal 'kon\'yaku', @trans.parse('こんやく').transliterate_from_hira_to_latn
    assert_equal 'shinbun',   @trans.parse('しんぶん').transliterate_from_hira_to_latn
    assert_equal 'appa',      @trans.parse('あっぱ').transliterate_from_hira_to_latn
  end

  def test_transliterate_from_hira_to_kata
    assert_equal KATAKANA, @trans.parse(HIRAGANA).transliterate_from_hira_to_kata
  end

  def test_transliterate_from_kata_to_hira
    assert_equal HIRAGANA, @trans.parse(KATAKANA).transliterate_from_kata_to_hira
  end

  def test_transliterate_from_kana_to_latn
    assert_equal 'hiraganakatakana', @trans.parse('ひらがなカタカナ').transliterate_from_kana_to_latn
  end
  
  def test_transliterate_from_fullwidth_to_halfwidth
    assert_equal HALFWIDTH, @trans.parse(FULLWIDTH).transliterate_from_fullwidth_to_halfwidth
  end
  
  def test_transliterate_from_halfwidth_to_fullwidth
    assert_equal FULLWIDTH, @trans.parse(HALFWIDTH).transliterate_from_halfwidth_to_fullwidth
  end


end
