# Encoding: UTF-8

require_relative 'test_helper'

class MecabIpadicParseTest < MiniTest::Unit::TestCase

  def test_all_literals_should_equal_the_input_text
    text = <<-EOS
    古池や
    蛙飛び込む
    水の音

    EOS
    raw = <<-EOR.split("\n")
古池	名詞,固有名詞,一般,*,*,*,古池,フルイケ,フルイケ
や	助動詞,*,*,*,特殊・ヤ,基本形,や,ヤ,ヤ
EOS
蛙	名詞,一般,*,*,*,*,蛙,カエル,カエル
飛び込む	動詞,自立,*,*,五段・マ行,基本形,飛び込む,トビコム,トビコム
EOS
水	名詞,一般,*,*,*,*,水,ミズ,ミズ
の	助詞,連体化,*,*,*,*,の,ノ,ノ
音	名詞,一般,*,*,*,*,音,オト,オト
EOS
    EOR
    parse = Ve::Parse::MecabIpadic.new(text, raw)
    assert_equal text, parse.tokens.collect { |t| t[:literal] }.join
  end

  def test_tokens_must_be_created_for_parsed_and_unparsed_text
    text = " A   B  "
    raw = <<-EOR.split("\n")
A	名詞,固有名詞,組織,*,*,*,*
B	名詞,一般,*,*,*,*,*
EOS
EOR
    parse = Ve::Parse::MecabIpadic.new(text, raw)
    assert_equal [:unparsed, :parsed, :unparsed, :parsed, :unparsed, :sentence_split], parse.tokens.collect { |t| t[:type] }
    assert_equal [' ', 'A', '   ', 'B', '  ', ''], parse.tokens.collect { |t| t[:literal] }
    assert_equal [0..0, 1..1, 2..4, 5..5, 6..7, nil], parse.tokens.collect { |t| t[:characters] }
  end

  def test_tokens_should_not_be_modified_when_attached_to_words
    text = '悪化する'
    raw = <<-EOR.split("\n")
悪化	名詞,サ変接続,*,*,*,*,悪化,アッカ,アッカ
する	動詞,自立,*,*,サ変・スル,基本形,する,スル,スル
EOS
EOR
    parse = Ve::Parse::MecabIpadic.new(text, raw)
    tokens = parse.tokens
    assert_equal '悪化', tokens[0][:literal]
    assert_equal '悪化', tokens[0][:lemma]
  end

  def test_sentences
    text = "これは文章である。で、also containing some Englishですね"
    raw = <<-EOR.split("\n")
これ	名詞,代名詞,一般,*,*,*,これ,コレ,コレ
は	助詞,係助詞,*,*,*,*,は,ハ,ワ
文章	名詞,一般,*,*,*,*,文章,ブンショウ,ブンショー
で	助動詞,*,*,*,特殊・ダ,連用形,だ,デ,デ
ある	助動詞,*,*,*,五段・ラ行アル,基本形,ある,アル,アル
。	記号,句点,*,*,*,*,。,。,。
で	助動詞,*,*,*,特殊・ダ,連用形,だ,デ,デ
、	記号,読点,*,*,*,*,、,、,、
also	名詞,固有名詞,組織,*,*,*,*
containing	名詞,一般,*,*,*,*,*
some	名詞,一般,*,*,*,*,*
English	名詞,一般,*,*,*,*,*
です	助動詞,*,*,*,特殊・デス,基本形,です,デス,デス
ね	助詞,終助詞,*,*,*,*,ね,ネ,ネ
EOS
EOR
    parse = Ve::Parse::MecabIpadic.new(text, raw)
    assert_equal ['これは文章である。', 'で、also containing some Englishですね'], parse.sentences
  end

  def test_this_shouldnt_crash
    text = 'チューたろうは田中さんの犬です。'
    raw = <<-EOR.split("\n")
チュー	名詞,一般,*,*,*,*,*
たろ	助動詞,*,*,*,特殊・タ,未然形,た,タロ,タロ
う	助動詞,*,*,*,不変化型,基本形,う,ウ,ウ
は	助詞,係助詞,*,*,*,*,は,ハ,ワ
田中	名詞,固有名詞,人名,姓,*,*,田中,タナカ,タナカ
さん	名詞,接尾,人名,*,*,*,さん,サン,サン
の	助詞,連体化,*,*,*,*,の,ノ,ノ
犬	名詞,一般,*,*,*,*,犬,イヌ,イヌ
です	助動詞,*,*,*,特殊・デス,基本形,です,デス,デス
。	記号,句点,*,*,*,*,。,。,。
EOS
EOR
    parse = Ve::Parse::MecabIpadic.new(text, raw)
    assert_equal 11, parse.tokens.size
  end

  def test_this_shouldnt_crash_either
    text = '三十年式歩兵銃'
    raw = <<-EOR.split("\n")
三	名詞,数,*,*,*,*,三,サン,サン
十	名詞,数,*,*,*,*,十,ジュウ,ジュー
年	名詞,接尾,助数詞,*,*,*,年,ネン,ネン
式	名詞,接尾,一般,*,*,*,式,シキ,シキ
歩兵	名詞,一般,*,*,*,*,歩兵,ホヘイ,ホヘイ
銃	名詞,一般,*,*,*,*,銃,ジュウ,ジュー
EOS
EOR
    parse = Ve::Parse::MecabIpadic.new(text, raw)
    assert_equal 7, parse.tokens.size
  end

  def test_words
    # Meishi
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['車'],
                              :lemmas => ['車'],
                              :pos => [Ve::PartOfSpeech::Noun],
                              :extra => [{:reading => 'クルマ', :transcription => 'クルマ', :grammar => nil}],
                              :tokens => [0..0]},
                             '車', <<-EOR.split("\n"))
車	名詞,一般,*,*,*,*,車,クルマ,クルマ
EOS
EOR

    # Koyuumeishi
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['太郎'],
                              :lemmas => ['太郎'],
                              :pos => [Ve::PartOfSpeech::ProperNoun],
                              :extra => [{:reading => 'タロウ', :transcription => 'タロー', :grammar => nil}],
                              :tokens => [0..0]},
                             '太郎', <<-EOR.split("\n"))
太郎	名詞,固有名詞,人名,名,*,*,太郎,タロウ,タロー
EOS
EOR

    # Daimeishi
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['彼'],
                              :lemmas => ['彼'],
                              :pos => [Ve::PartOfSpeech::Pronoun],
                              :extra => [{:reading => 'カレ', :transcription => 'カレ', :grammar => nil}],
                              :tokens => [0..0]},
                             '彼', <<-EOR.split("\n"))
彼	名詞,代名詞,一般,*,*,*,彼,カレ,カレ
EOS
EOR

    # Fukushikanou
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['午後', 'に'],
                              :lemmas => ['午後', 'に'],
                              :pos => [Ve::PartOfSpeech::Adverb, Ve::PartOfSpeech::Postposition],
                              :extra => [{:reading => 'ゴゴ', :transcription => 'ゴゴ', :grammar => nil}, {:reading=>"ニ", :transcription=>"ニ", :grammar=>nil}],
                              :tokens => [0..0, 1..1]},
                             '午後に', <<-EOR.split("\n"))
午後	名詞,副詞可能,*,*,*,*,午後,ゴゴ,ゴゴ
に	助詞,格助詞,一般,*,*,*,に,ニ,ニ
EOS
EOR

    # Akirakani shita should be "akiraka ni shita"
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ["明らか", "に", "した"],
                              :lemmas => ["明らか", "に", "する"],
                              :pos => [Ve::PartOfSpeech::Adverb, Ve::PartOfSpeech::Postposition, Ve::PartOfSpeech::Verb],
                              :extra => [{:reading=>"アキラカ", :transcription=>"アキラカ", :grammar=>nil}, {:reading=>"ニ", :transcription=>"ニ", :grammar=>nil}, {:reading=>"シタ", :transcription=>"シタ", :grammar=>nil}],
                              :tokens => [0..0, 1..1, 2..3]},
                             '明らかにした', <<-EOR.split("\n"))
明らか	名詞,形容動詞語幹,*,*,*,*,明らか,アキラカ,アキラカ
に	助詞,格助詞,一般,*,*,*,に,ニ,ニ
し	動詞,自立,*,*,サ変・スル,連用形,する,シ,シ
た	助動詞,*,*,*,特殊・タ,基本形,た,タ,タ
EOS
EOR

    # Kazu
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['一'],
                              :lemmas => ['一'],
                              :pos => [Ve::PartOfSpeech::Number],
                              :extra => [{:reading => 'イチ', :transcription => 'イチ', :grammar => nil}],
                              :tokens => [0..0]},
                             '一', <<-EOR.split("\n"))
一	名詞,数,*,*,*,*,一,イチ,イチ
EOS
EOR

    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['１２３'],
                              :lemmas => ['１２３'],
                              :pos => [Ve::PartOfSpeech::Number],
                              :extra => [{:reading => 'イチニサン', :transcription => 'イチニサン', :grammar => nil}],
                              :tokens => [0..2]},
                             '１２３', <<-EOR.split("\n"))
１	名詞,数,*,*,*,*,１,イチ,イチ
２	名詞,数,*,*,*,*,２,ニ,ニ
３	名詞,数,*,*,*,*,３,サン,サン
EOS
EOR

    # Sahensetsuzoku + tokumi ta
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['悪化した'],
                              :lemmas => ['悪化する'],
                              :pos => [Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'アッカシタ', :transcription => 'アッカシタ', :grammar => nil}],
                              :tokens => [0..2]},
                             '悪化した', <<-EOR.split("\n"))
悪化	名詞,サ変接続,*,*,*,*,悪化,アッカ,アッカ
し	動詞,自立,*,*,サ変・スル,連用形,する,シ,シ
た	助動詞,*,*,*,特殊・タ,基本形,た,タ,タ
EOS
EOR

    # Keiyoudoushigokan
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['重要な'],
                              :lemmas => ['重要'],
                              :pos => [Ve::PartOfSpeech::Adjective],
                              :extra => [{:reading => 'ジュウヨウナ', :transcription => 'ジューヨーナ', :grammar => nil}],
                              :tokens => [0..1]},
                             '重要な', <<-EOR.split("\n"))
重要	名詞,形容動詞語幹,*,*,*,*,重要,ジュウヨウ,ジューヨー
な	助動詞,*,*,*,特殊・ダ,体言接続,だ,ナ,ナ
EOS
EOR

    # Naikeiyoushigokan
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['とんでもない'],
                              :lemmas => ['とんでもない'],
                              :pos => [Ve::PartOfSpeech::Adjective],
                              :extra => [{:reading => 'トンデモナイ', :transcription => 'トンデモナイ', :grammar => nil}],
                              :tokens => [0..1]},
                             'とんでもない', <<-EOR.split("\n"))
とんでも	名詞,ナイ形容詞語幹,*,*,*,*,とんでも,トンデモ,トンデモ
ない	助動詞,*,*,*,特殊・ナイ,基本形,ない,ナイ,ナイ
EOS
EOR

    # Meishi hijiritsu fukushikanou
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['の', 'うちに'],
                              :lemmas => ['の', 'うちに'],
                              :pos => [Ve::PartOfSpeech::Postposition, Ve::PartOfSpeech::Adverb],
                              :extra => [{:reading => 'ノ', :transcription => 'ノ', :grammar => nil},
                                         {:reading => 'ウチニ', :transcription => 'ウチニ', :grammar => nil}],
                              :tokens => [0..0, 1..2]},
                             'のうちに', <<-EOR.split("\n"))
の	助詞,連体化,*,*,*,*,の,ノ,ノ
うち	名詞,非自立,副詞可能,*,*,*,うち,ウチ,ウチ
に	助詞,格助詞,一般,*,*,*,に,ニ,ニ
EOS
EOR

    # Meishi hijiritsu jodoushigokan
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['の', 'ような'],
                              :lemmas => ['の', 'ようだ'],
                              :pos => [Ve::PartOfSpeech::Postposition, Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'ノ', :transcription => 'ノ', :grammar => nil},
                                         {:reading => 'ヨウナ', :transcription => 'ヨーナ', :grammar => :auxillary}],
                              :tokens => [0..0, 1..2]},
                             'のような', <<-EOR.split("\n"))
の	助詞,連体化,*,*,*,*,の,ノ,ノ
よう	名詞,非自立,助動詞語幹,*,*,*,よう,ヨウ,ヨー
な	助動詞,*,*,*,特殊・ダ,体言接続,だ,ナ,ナ
EOS
EOR

    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['の', 'ように'],
                              :lemmas => ['の', 'ように'],
                              :pos => [Ve::PartOfSpeech::Postposition, Ve::PartOfSpeech::Adverb],
                              :extra => [{:reading => 'ノ', :transcription => 'ノ', :grammar => nil},
                                         {:reading => 'ヨウニ', :transcription => 'ヨーニ', :grammar => nil}],
                              :tokens => [0..0, 1..2]},
                             'のように', <<-EOR.split("\n"))
の	助詞,連体化,*,*,*,*,の,ノ,ノ
よう	名詞,非自立,助動詞語幹,*,*,*,よう,ヨウ,ヨー
に	助詞,副詞化,*,*,*,*,に,ニ,ニ
EOS
EOR

    # Meishi hijiritsu keiyoudoushigokan
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['みたいな'],
                              :lemmas => ['みたいだ'],
                              :pos => [Ve::PartOfSpeech::Adjective],
                              :extra => [{:reading => 'ミタイナ', :transcription => 'ミタイナ', :grammar => nil}],
                              :tokens => [0..1]},
                             'みたいな', <<-EOR.split("\n"))
みたい	名詞,非自立,形容動詞語幹,*,*,*,みたい,ミタイ,ミタイ
な	助動詞,*,*,*,特殊・ダ,体言接続,だ,ナ,ナ
EOS
EOR

    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['みたいの'],
                              :lemmas => ['みたいの'],
                              :pos => [Ve::PartOfSpeech::Adjective],
                              :extra => [{:reading => 'ミタイノ', :transcription => 'ミタイノ', :grammar => nil}],
                              :tokens => [0..1]},
                             'みたいの', <<-EOR.split("\n"))
みたい	名詞,非自立,形容動詞語幹,*,*,*,みたい,ミタイ,ミタイ
の	助詞,連体化,*,*,*,*,の,ノ,ノ
EOS
EOR

    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['みたい', 'だ'],
                              :lemmas => ['みたい', 'だ'],
                              :pos => [Ve::PartOfSpeech::Adjective, Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'ミタイ', :transcription => 'ミタイ', :grammar => nil},
                                         {:reading => 'ダ', :transcription => 'ダ', :grammar => nil}],
                              :tokens => [0..0, 1..1]},
                             'みたいだ', <<-EOR.split("\n"))
みたい	名詞,非自立,形容動詞語幹,*,*,*,みたい,ミタイ,ミタイ
だ	助動詞,*,*,*,特殊・ダ,基本形,だ,ダ,ダ
EOS
EOR

    # Meishi tokushu jodoushigokan
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['行く', 'そう', 'だ'],
                              :lemmas => ['行く', 'そう', 'だ'],
                              :pos => [Ve::PartOfSpeech::Verb, Ve::PartOfSpeech::Verb, Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'イク', :transcription => 'イク', :grammar => nil},
                                         {:reading => 'ソウ', :transcription => 'ソー', :grammar => :auxillary},
                                         {:reading => 'ダ', :transcription => 'ダ', :grammar => nil}],
                              :tokens => [0..0, 1..1, 2..2]},
                             '行くそうだ', <<-EOR.split("\n"))
行く	動詞,自立,*,*,五段・カ行促音便,基本形,行く,イク,イク
そう	名詞,特殊,助動詞語幹,*,*,*,そう,ソウ,ソー
だ	助動詞,*,*,*,特殊・ダ,基本形,だ,ダ,ダ
EOS
EOR

    # Meishi setsubi
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['楽しさ'],
                              :lemmas => ['楽しい'],
                              :pos => [Ve::PartOfSpeech::Noun],
                              :extra => [{:reading => 'タノシサ', :transcription => 'タノシサ', :grammar => nil}],
                              :tokens => [0..1]},
                             '楽しさ', <<-EOR.split("\n"))
楽し	形容詞,自立,*,*,形容詞・イ段,ガル接続,楽しい,タノシ,タノシ
さ	名詞,接尾,特殊,*,*,*,さ,サ,サ
EOS
EOR

    # Meishi setsuzokushiteki
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['日本', '対', 'アメリカ'],
                              :lemmas => ['日本', '対', 'アメリカ'],
                              :pos => [Ve::PartOfSpeech::ProperNoun, Ve::PartOfSpeech::Conjunction, Ve::PartOfSpeech::ProperNoun],
                              :extra => [{:reading => 'ニッポン', :transcription => 'ニッポン', :grammar => nil},
                                         {:reading => 'タイ', :transcription => 'タイ', :grammar => nil},
                                         {:reading => 'アメリカ', :transcription => 'アメリカ', :grammar => nil}],
                              :tokens => [0..0, 1..1, 2..2]},
                             '日本対アメリカ', <<-EOR.split("\n"))
日本	名詞,固有名詞,地域,国,*,*,日本,ニッポン,ニッポン
対	名詞,接続詞的,*,*,*,*,対,タイ,タイ
アメリカ	名詞,固有名詞,地域,国,*,*,アメリカ,アメリカ,アメリカ
EOS
EOR

    # Meishi doushihijiritsuteki
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['見て', 'ごらん'],
                              :lemmas => ['見る', 'ごらん'],
                              :pos => [Ve::PartOfSpeech::Verb, Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'ミテ', :transcription => 'ミテ', :grammar => nil},
                                         {:reading => 'ゴラン', :transcription => 'ゴラン', :grammar => :nominal}],
                              :tokens => [0..1, 2..2]},
                             '見てごらん', <<-EOR.split("\n"))
見	動詞,自立,*,*,一段,連用形,見る,ミ,ミ
て	助詞,接続助詞,*,*,*,*,て,テ,テ
ごらん	名詞,動詞非自立的,*,*,*,*,ごらん,ゴラン,ゴラン
EOS
EOR

    # Settoushi
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['お', '座り'],
                              :lemmas => ['お', '座り'],
                              :pos => [Ve::PartOfSpeech::Prefix, Ve::PartOfSpeech::Noun],
                              :extra => [{:reading => 'オ', :transcription => 'オ', :grammar => nil},
                                         {:reading => 'スワリ', :transcription => 'スワリ', :grammar => nil}],
                              :tokens => [0..0, 1..1]},
                             'お座り', <<-EOR.split("\n"))
お	接頭詞,名詞接続,*,*,*,*,お,オ,オ
座り	名詞,一般,*,*,*,*,座り,スワリ,スワリ
EOS
EOR

    # Kigou
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['。'],
                              :lemmas => ['。'],
                              :pos => [Ve::PartOfSpeech::Symbol],
                              :extra => [{:reading => '。', :transcription => '。', :grammar => nil}],
                              :tokens => [0..0]},
                             '。', <<-EOR.split("\n"))
。	記号,句点,*,*,*,*,。,。,。
EOS
EOR

    # Firaa
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['えと'],
                              :lemmas => ['えと'],
                              :pos => [Ve::PartOfSpeech::Interjection],
                              :extra => [{:reading => 'エト', :transcription => 'エト', :grammar => nil}],
                              :tokens => [0..0]},
                             'えと', <<-EOR.split("\n"))
えと	フィラー,*,*,*,*,*,えと,エト,エト
EOS
EOR

    # Sonota
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['だ', 'ァ'],
                              :lemmas => ['だ', 'ァ'],
                              :pos => [Ve::PartOfSpeech::Postposition, Ve::PartOfSpeech::Other],
                              :extra => [{:reading => 'ダ', :transcription => 'ダ', :grammar => nil},
                                         {:reading => 'ァ', :transcription => 'ア', :grammar => nil}],
                              :tokens => [0..0, 1..1]},
                             'だァ', <<-EOR.split("\n"))
だ	助動詞,*,*,*,特殊・タ,基本形,だ,ダ,ダ
ァ	その他,間投,*,*,*,*,ァ,ァ,ア
EOS
EOR

    # Kandoushi
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['おはよう'],
                              :lemmas => ['おはよう'],
                              :pos => [Ve::PartOfSpeech::Interjection],
                              :extra => [{:reading => 'オハヨウ', :transcription => 'オハヨー', :grammar => nil}],
                              :tokens => [0..0]},
                             'おはよう', <<-EOR.split("\n"))
おはよう	感動詞,*,*,*,*,*,おはよう,オハヨウ,オハヨー
EOS
EOR

    # Rentaishi
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['この'],
                              :lemmas => ['この'],
                              :pos => [Ve::PartOfSpeech::Determiner],
                              :extra => [{:reading => 'コノ', :transcription => 'コノ', :grammar => nil}],
                              :tokens => [0..0]},
                             'この', <<-EOR.split("\n"))
この	連体詞,*,*,*,*,*,この,コノ,コノ
EOS
EOR

    # Setsuzokushi
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['そして'],
                              :lemmas => ['そして'],
                              :pos => [Ve::PartOfSpeech::Conjunction],
                              :extra => [{:reading => 'ソシテ', :transcription => 'ソシテ', :grammar => nil}],
                              :tokens => [0..0]},
                             'そして', <<-EOR.split("\n"))
そして	接続詞,*,*,*,*,*,そして,ソシテ,ソシテ
EOS
EOR

    # Fukushi
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['多分'],
                              :lemmas => ['多分'],
                              :pos => [Ve::PartOfSpeech::Adverb],
                              :extra => [{:reading => 'タブン', :transcription => 'タブン', :grammar => nil}],
                              :tokens => [0..0]},
                             '多分', <<-EOR.split("\n"))
多分	副詞,一般,*,*,*,*,多分,タブン,タブン
EOS
EOR

    # Doushi
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['行く'],
                              :lemmas => ['行く'],
                              :pos => [Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'イク', :transcription => 'イク', :grammar => nil}],
                              :tokens => [0..0]},
                             '行く', <<-EOR.split("\n"))
行く	動詞,自立,*,*,五段・カ行促音便,基本形,行く,イク,イク
EOS
EOR

    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['行かない'],
                              :lemmas => ['行く'],
                              :pos => [Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'イカナイ', :transcription => 'イカナイ', :grammar => nil}],
                              :tokens => [0..1]},
                             '行かない', <<-EOR.split("\n"))
行か	動詞,自立,*,*,五段・カ行促音便,未然形,行く,イカ,イカ
ない	助動詞,*,*,*,特殊・ナイ,基本形,ない,ナイ,ナイ
EOS
EOR

    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['行って', 'きて'],
                              :lemmas => ['行く', 'くる'],
                              :pos => [Ve::PartOfSpeech::Verb, Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'イッテ', :transcription => 'イッテ', :grammar => nil},
                                         {:reading => 'キテ', :transcription => 'キテ', :grammar => :auxillary}],
                              :tokens => [0..1, 2..3]},
                             '行ってきて', <<-EOR.split("\n"))
行っ	動詞,自立,*,*,五段・カ行促音便,連用タ接続,行く,イッ,イッ
て	助詞,接続助詞,*,*,*,*,て,テ,テ
き	動詞,非自立,*,*,カ変・クル,連用形,くる,キ,キ
て	助詞,接続助詞,*,*,*,*,て,テ,テ
EOS
EOR

    # Doushi setsubi
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['行かれる'],
                              :lemmas => ['行く'],
                              :pos => [Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'イカレル', :transcription => 'イカレル', :grammar => nil}],
                              :tokens => [0..1]},
                             '行かれる', <<-EOR.split("\n"))
行か	動詞,自立,*,*,五段・カ行促音便,未然形,行く,イカ,イカ
れる	動詞,接尾,*,*,一段,基本形,れる,レル,レル
EOS
EOR

    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['食べさせられた'],
                              :lemmas => ['食べる'],
                              :pos => [Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'タベサセラレタ', :transcription => 'タベサセラレタ', :grammar => nil}],
                              :tokens => [0..3]},
                             '食べさせられた', <<-EOR.split("\n"))
食べ	動詞,自立,*,*,一段,未然形,食べる,タベ,タベ
させ	動詞,接尾,*,*,一段,未然形,させる,サセ,サセ
られ	動詞,接尾,*,*,一段,連用形,られる,ラレ,ラレ
た	助動詞,*,*,*,特殊・タ,基本形,た,タ,タ
EOS
EOR

    # Doushi + jodoushi
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['食べました'],
                              :lemmas => ['食べる'],
                              :pos => [Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'タベマシタ', :transcription => 'タベマシタ', :grammar => nil}],
                              :tokens => [0..2]},
                             '食べました', <<-EOR.split("\n"))
食べ	動詞,自立,*,*,一段,連用形,食べる,タベ,タベ
まし	助動詞,*,*,*,特殊・マス,連用形,ます,マシ,マシ
た	助動詞,*,*,*,特殊・タ,基本形,た,タ,タ
EOS
EOR

    # Keiyoushi
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['寒い'],
                              :lemmas => ['寒い'],
                              :pos => [Ve::PartOfSpeech::Adjective],
                              :extra => [{:reading => 'サムイ', :transcription => 'サムイ', :grammar => nil}],
                              :tokens => [0..0]},
                             '寒い', <<-EOR.split("\n"))
寒い	形容詞,自立,*,*,形容詞・アウオ段,基本形,寒い,サムイ,サムイ
EOS
EOR

    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['寒くて'],
                              :lemmas => ['寒い'],
                              :pos => [Ve::PartOfSpeech::Adjective],
                              :extra => [{:reading => 'サムクテ', :transcription => 'サムクテ', :grammar => nil}],
                              :tokens => [0..1]},
                             '寒くて', <<-EOR.split("\n"))
寒く	形容詞,自立,*,*,形容詞・アウオ段,連用テ接続,寒い,サムク,サムク
て	助詞,接続助詞,*,*,*,*,て,テ,テ
EOS
EOR

    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['寒かった'],
                              :lemmas => ['寒い'],
                              :pos => [Ve::PartOfSpeech::Adjective],
                              :extra => [{:reading => 'サムカッタ', :transcription => 'サムカッタ', :grammar => nil}],
                              :tokens => [0..1]},
                             '寒かった', <<-EOR.split("\n"))
寒かっ	形容詞,自立,*,*,形容詞・アウオ段,連用タ接続,寒い,サムカッ,サムカッ
た	助動詞,*,*,*,特殊・タ,基本形,た,タ,タ
EOS
EOR

    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['寒ければ'],
                              :lemmas => ['寒い'],
                              :pos => [Ve::PartOfSpeech::Adjective],
                              :extra => [{:reading => 'サムケレバ', :transcription => 'サムケレバ', :grammar => nil}],
                              :tokens => [0..1]},
                             '寒ければ', <<-EOR.split("\n"))
寒けれ	形容詞,自立,*,*,形容詞・アウオ段,仮定形,寒い,サムケレ,サムケレ
ば	助詞,接続助詞,*,*,*,*,ば,バ,バ
EOS
EOR

    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['寒けりゃ'],
                              :lemmas => ['寒い'],
                              :pos => [Ve::PartOfSpeech::Adjective],
                              :extra => [{:reading => 'サムケリャ', :transcription => 'サムケリャ', :grammar => nil}],
                              :tokens => [0..0]},
                             '寒けりゃ', <<-EOR.split("\n"))
寒けりゃ	形容詞,自立,*,*,形容詞・アウオ段,仮定縮約１,寒い,サムケリャ,サムケリャ
EOS
EOR

    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['食べたい'],
                              :lemmas => ['食べる'],
                              :pos => [Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'タベタイ', :transcription => 'タベタイ', :grammar => nil}],
                              :tokens => [0..1]},
                             '食べたい', <<-EOR.split("\n"))
食べ	動詞,自立,*,*,一段,連用形,食べる,タベ,タベ
たい	助動詞,*,*,*,特殊・タイ,基本形,たい,タイ,タイ
EOS
EOR

    # Joshi
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['日本', 'から'],
                              :lemmas => ['日本', 'から'],
                              :pos => [Ve::PartOfSpeech::ProperNoun, Ve::PartOfSpeech::Postposition],
                              :extra => [{:reading => 'ニッポン', :transcription => 'ニッポン', :grammar => nil},
                                         {:reading => 'カラ', :transcription => 'カラ', :grammar => nil}],
                              :tokens => [0..0, 1..1]},
                             '日本から', <<-EOR.split("\n"))
日本	名詞,固有名詞,地域,国,*,*,日本,ニッポン,ニッポン
から	助詞,格助詞,一般,*,*,*,から,カラ,カラ
EOS
EOR

    # The copula
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['日本', 'です'],
                              :lemmas => ['日本', 'です'],
                              :pos => [Ve::PartOfSpeech::ProperNoun, Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'ニッポン', :transcription => 'ニッポン', :grammar => nil},
                                         {:reading => 'デス', :transcription => 'デス', :grammar => nil}],
                              :tokens => [0..0, 1..1]},
                             '日本です', <<-EOR.split("\n"))
日本	名詞,固有名詞,地域,国,*,*,日本,ニッポン,ニッポン
です	助動詞,*,*,*,特殊・デス,基本形,です,デス,デス
EOS
EOR

    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['日本', 'だった'],
                              :lemmas => ['日本', 'だ'],
                              :pos => [Ve::PartOfSpeech::ProperNoun, Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'ニッポン', :transcription => 'ニッポン', :grammar => nil},
                                         {:reading => 'ダッタ', :transcription => 'ダッタ', :grammar => nil}],
                              :tokens => [0..0, 1..2]},
                             '日本だった', <<-EOR.split("\n"))
日本	名詞,固有名詞,地域,国,*,*,日本,ニッポン,ニッポン
だっ	助動詞,*,*,*,特殊・ダ,連用タ接続,だ,ダッ,ダッ
た	助動詞,*,*,*,特殊・タ,基本形,た,タ,タ
EOS
EOR

    # いるから
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['いる', 'から'],
                             :lemmas => ['いる', 'から'],
                             :pos => [Ve::PartOfSpeech::Verb, Ve::PartOfSpeech::Postposition],
                             :extra => [{:reading => 'イル', :transcription => 'イル', :grammar => nil},
                                        {:reading => 'カラ', :transcription => 'カラ', :grammar => nil}],
                             :tokens => [0..0, 1..1]},
                             'いるから', <<-EOR.split("\n"))
いる	動詞,自立,*,*,一段,基本形,いる,イル,イル
から	助詞,接続助詞,*,*,*,*,から,カラ,カラ
EOS
EOR

    # しているから
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ['して', 'いる', 'から'],
                             :lemmas => ['する', 'いる', 'から'],
                             :pos => [Ve::PartOfSpeech::Verb, Ve::PartOfSpeech::Verb, Ve::PartOfSpeech::Postposition],
                             :extra => [{:reading => 'シテ', :transcription => 'シテ', :grammar => nil},
                                        {:reading => 'イル', :transcription => 'イル', :grammar => :auxillary},
                                        {:reading => 'カラ', :transcription => 'カラ', :grammar => nil}],
                             :tokens => [0..1, 2..2, 3..3]},
                             'しているから', <<-EOR.split("\n"))
し	動詞,自立,*,*,サ変・スル,連用形,する,シ,シ
て	助詞,接続助詞,*,*,*,*,て,テ,テ
いる	動詞,非自立,*,*,一段,基本形,いる,イル,イル
から	助詞,接続助詞,*,*,*,*,から,カラ,カラ
EOS
EOR

    # 基準があるが、
    assert_parses_into_words(Ve::Parse::MecabIpadic, {:words => ["基準", "が", "ある", "が", "、"],
                             :lemmas => ["基準", "が", "ある", "が", "、"],
                             :pos => [Ve::PartOfSpeech::Noun, Ve::PartOfSpeech::Postposition, Ve::PartOfSpeech::Verb, Ve::PartOfSpeech::Postposition, Ve::PartOfSpeech::Symbol],
                             :extra => [{:reading=>"キジュン", :transcription=>"キジュン", :grammar=>nil}, {:reading=>"ガ", :transcription=>"ガ", :grammar=>nil}, {:reading=>"アル", :transcription=>"アル", :grammar=>nil}, {:reading=>"ガ", :transcription=>"ガ", :grammar=>nil}, {:reading=>"、", :transcription=>"、", :grammar=>nil}],
                             :tokens => [0..0, 1..1, 2..2, 3..3, 4..4]},
                             '基準があるが、', <<-EOR.split("\n"))
基準	名詞,一般,*,*,*,*,基準,キジュン,キジュン
が	助詞,格助詞,一般,*,*,*,が,ガ,ガ
ある	動詞,自立,*,*,五段・ラ行,基本形,ある,アル,アル
が	助詞,接続助詞,*,*,*,*,が,ガ,ガ
、	記号,読点,*,*,*,*,、,、,、
EOS
EOR

    # TODO: xした should parse as adjective?
  end

  def test_word_transliteration
    skip
    mecab = Ve::Provider::MecabIpadic.new
    parse = mecab.parse('日本', :transliterate_words => :latn)

    assert_equal 'nihon', parse.words.first.transliteration(:latn)
  end

end
