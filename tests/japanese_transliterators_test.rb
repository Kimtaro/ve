# Encoding: UTF-8

require_relative 'test_helper'

class JapaneseTransliteratorsTest < MiniTest::Unit::TestCase

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
  
  def test_transliterate_from_latn_to_hrkt
    assert_equal('かなです',   @trans.parse('kanadesu').transliterate_from_latn_to_hrkt)
    assert_equal('こそあど',   @trans.parse('kosoado').transliterate_from_latn_to_hrkt)
    assert_equal('こんな',    @trans.parse('konna').transliterate_from_latn_to_hrkt)
    assert_equal('しんぶん',   @trans.parse('shimbun').transliterate_from_latn_to_hrkt)
    assert_equal('しんぱい',   @trans.parse('simpai').transliterate_from_latn_to_hrkt)
    assert_equal('うぁ',     @trans.parse('wha').transliterate_from_latn_to_hrkt)
    assert_equal('かっちゃった', @trans.parse('katchatta').transliterate_from_latn_to_hrkt)
    assert_equal('かっわいいぃ', @trans.parse('kawwaiixi').transliterate_from_latn_to_hrkt)
    assert_equal('おっとせい',  @trans.parse('ottosei').transliterate_from_latn_to_hrkt)
    assert_equal('あっち',    @trans.parse('acchi').transliterate_from_latn_to_hrkt)

    # Katakana
    assert_equal('カナデス',    @trans.parse('KANADESU').transliterate_from_latn_to_hrkt)
    assert_equal('コソアド',    @trans.parse('KOSOADO').transliterate_from_latn_to_hrkt)
    assert_equal('コンナ',     @trans.parse('KONNA').transliterate_from_latn_to_hrkt)
    assert_equal('シンブン',    @trans.parse('SHIMBUN').transliterate_from_latn_to_hrkt)
    assert_equal('シンパイ',    @trans.parse('SIMPAI').transliterate_from_latn_to_hrkt)
    assert_equal('ウァ',      @trans.parse('WHA').transliterate_from_latn_to_hrkt)
    assert_equal('カッチャッタ',  @trans.parse('KATCHATTA').transliterate_from_latn_to_hrkt)
    assert_equal('カッワイイィ',  @trans.parse('KAWWAIIXI').transliterate_from_latn_to_hrkt)
    assert_equal('オットセイ',   @trans.parse('OTTOSEI').transliterate_from_latn_to_hrkt)
    assert_equal('アッチ',     @trans.parse('ACCHI').transliterate_from_latn_to_hrkt)
    assert_equal('カタカナ です', @trans.parse('KATAKANA desu').transliterate_from_latn_to_hrkt)

    # Non-Japanese
    assert_equal('てぃs いs そめ えんgりsh', @trans.parse('this is some english').transliterate_from_latn_to_hrkt)
  end

  def test_transliterate_from_hira_to_kana
    assert_equal KATAKANA, @trans.parse(HIRAGANA).transliterate_from_hira_to_kana
  end

  def test_transliterate_from_kata_to_hina
    assert_equal HIRAGANA, @trans.parse(KATAKANA).transliterate_from_kana_to_hira
  end

  def test_transliterate_from_hrkt_to_latn
    assert_equal 'hiraganakatakana', @trans.parse('ひらがなカタカナ').transliterate_from_hrkt_to_latn
  end
  
  def test_transliterate_from_fullwidth_to_halfwidth
    assert_equal HALFWIDTH, @trans.parse(FULLWIDTH).transliterate_from_fullwidth_to_halfwidth
  end
  
  def test_transliterate_from_halfwidth_to_fullwidth
    assert_equal FULLWIDTH, @trans.parse(HALFWIDTH).transliterate_from_halfwidth_to_fullwidth
  end


end
