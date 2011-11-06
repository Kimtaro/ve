# Encoding: UTF-8

require_relative 'test_helper'

class MecabIpadicTest < Test::Unit::TestCase

  def test_should_be_able_to_start
    mecab = Ve::Provider::MecabIpadic.new
    assert mecab.works?
  end

  def test_can_parse
    mecab = Ve::Provider::MecabIpadic.new
    parse = mecab.parse('')
    assert_equal Ve::Parse::MecabIpadic, parse.class
  end

  def test_all_literals_should_equal_the_input_text
    text = <<-EOS
    古池や
    蛙飛び込む
    水の音

    EOS
    mecab = Ve::Provider::MecabIpadic.new
    parse = mecab.parse(text)
    assert_equal text, parse.tokens.collect { |t| t[:literal] }.join
  end

  def test_tokens_must_be_created_for_parsed_and_unparsed_text
    mecab = Ve::Provider::MecabIpadic.new
    parse = mecab.parse(' A   B  ')
    assert_equal [:unparsed, :parsed, :unparsed, :parsed, :unparsed, :sentence_split], parse.tokens.collect { |t| t[:type] }
    assert_equal [' ', 'A', '   ', 'B', '  ', ''], parse.tokens.collect { |t| t[:literal] }
    assert_equal [0..0, 1..1, 2..4, 5..5, 6..7, nil], parse.tokens.collect { |t| t[:characters] }
  end

  def test_tokens_should_not_be_modified_when_attached_to_words
    mecab = Ve::Provider::MecabIpadic.new
    parse = mecab.parse('悪化する')
    tokens = parse.tokens
    assert_equal '悪化', tokens[0][:literal]
    assert_equal '悪化', tokens[0][:lemma]
  end

  def test_sentences
    mecab = Ve::Provider::MecabIpadic.new
    parse = mecab.parse('これは文章である。で、also containing some Englishですね')
    assert_equal ['これは文章である。', 'で、also containing some Englishですね'], parse.sentences
  end

  def test_this_shouldnt_crash
    mecab = Ve::Provider::MecabIpadic.new
    parse = mecab.parse('チューたろうは田中さんの犬です。')
    pp parse.words
  end

  def test_this_shouldnt_crash_either
	mecab = Ve::Provider::MecabIpadic.new
	parse = mecab.parse('三十年式歩兵銃')
	pp parse.words
  end

  def test_words
    mecab = Ve::Provider::MecabIpadic.new

    # Meishi
    assert_parses_into_words(mecab, {:words => ['車'],
                              :lemmas => ['車'],
                              :pos => [Ve::PartOfSpeech::Noun],
                              :extra => [{:reading => 'クルマ', :transcription => 'クルマ', :grammar => nil}],
                              :tokens => [0..0]},
                             '車')

    # Koyuumeishi
    assert_parses_into_words(mecab, {:words => ['太郎'],
                              :lemmas => ['太郎'],
                              :pos => [Ve::PartOfSpeech::ProperNoun],
                              :extra => [{:reading => 'タロウ', :transcription => 'タロー', :grammar => nil}],
                              :tokens => [0..0]},
                             '太郎')

    # Daimeishi
    assert_parses_into_words(mecab, {:words => ['彼'],
                              :lemmas => ['彼'],
                              :pos => [Ve::PartOfSpeech::Pronoun],
                              :extra => [{:reading => 'カレ', :transcription => 'カレ', :grammar => nil}],
                              :tokens => [0..0]},
                             '彼')

    # Fukushikanou
    assert_parses_into_words(mecab, {:words => ['午後に'],
                              :lemmas => ['午後に'],
                              :pos => [Ve::PartOfSpeech::Adverb],
                              :extra => [{:reading => 'ゴゴニ', :transcription => 'ゴゴニ', :grammar => nil}],
                              :tokens => [0..1]},
                             '午後に')

    # Kazu
    assert_parses_into_words(mecab, {:words => ['一'],
                              :lemmas => ['一'],
                              :pos => [Ve::PartOfSpeech::Number],
                              :extra => [{:reading => 'イチ', :transcription => 'イチ', :grammar => nil}],
                              :tokens => [0..0]},
                             '一')

    assert_parses_into_words(mecab, {:words => ['１２３'],
                              :lemmas => ['１２３'],
                              :pos => [Ve::PartOfSpeech::Number],
                              :extra => [{:reading => 'イチニサン', :transcription => 'イチニサン', :grammar => nil}],
                              :tokens => [0..2]},
                             '１２３')

    # Sahensetsuzoku + tokumi ta
    assert_parses_into_words(mecab, {:words => ['悪化した'],
                              :lemmas => ['悪化する'],
                              :pos => [Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'アッカシタ', :transcription => 'アッカシタ', :grammar => nil}],
                              :tokens => [0..2]},
                             '悪化した')

    # Keiyoudoushigokan
    assert_parses_into_words(mecab, {:words => ['重要な'],
                              :lemmas => ['重要'],
                              :pos => [Ve::PartOfSpeech::Adjective],
                              :extra => [{:reading => 'ジュウヨウナ', :transcription => 'ジューヨーナ', :grammar => nil}],
                              :tokens => [0..1]},
                             '重要な')

    # Naikeiyoushigokan
    assert_parses_into_words(mecab, {:words => ['とんでもない'],
                              :lemmas => ['とんでもない'],
                              :pos => [Ve::PartOfSpeech::Adjective],
                              :extra => [{:reading => 'トンデモナイ', :transcription => 'トンデモナイ', :grammar => nil}],
                              :tokens => [0..1]},
                             'とんでもない')

    # Meishi hijiritsu fukushikanou
    assert_parses_into_words(mecab, {:words => ['の', 'うちに'],
                              :lemmas => ['の', 'うちに'],
                              :pos => [Ve::PartOfSpeech::Postposition, Ve::PartOfSpeech::Adverb],
                              :extra => [{:reading => 'ノ', :transcription => 'ノ', :grammar => nil},
                                         {:reading => 'ウチニ', :transcription => 'ウチニ', :grammar => nil}],
                              :tokens => [0..0, 1..2]},
                             'のうちに')

    # Meishi hijiritsu jodoushigokan
    assert_parses_into_words(mecab, {:words => ['の', 'ような'],
                              :lemmas => ['の', 'ようだ'],
                              :pos => [Ve::PartOfSpeech::Postposition, Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'ノ', :transcription => 'ノ', :grammar => nil},
                                         {:reading => 'ヨウナ', :transcription => 'ヨーナ', :grammar => :auxillary}],
                              :tokens => [0..0, 1..2]},
                             'のような')

    assert_parses_into_words(mecab, {:words => ['の', 'ように'],
                              :lemmas => ['の', 'ように'],
                              :pos => [Ve::PartOfSpeech::Postposition, Ve::PartOfSpeech::Adverb],
                              :extra => [{:reading => 'ノ', :transcription => 'ノ', :grammar => nil},
                                         {:reading => 'ヨウニ', :transcription => 'ヨーニ', :grammar => nil}],
                              :tokens => [0..0, 1..2]},
                             'のように')

    # Meishi hijiritsu keiyoudoushigokan
    assert_parses_into_words(mecab, {:words => ['みたいな'],
                              :lemmas => ['みたいだ'],
                              :pos => [Ve::PartOfSpeech::Adjective],
                              :extra => [{:reading => 'ミタイナ', :transcription => 'ミタイナ', :grammar => nil}],
                              :tokens => [0..1]},
                             'みたいな')

    assert_parses_into_words(mecab, {:words => ['みたいの'],
                              :lemmas => ['みたいの'],
                              :pos => [Ve::PartOfSpeech::Adjective],
                              :extra => [{:reading => 'ミタイノ', :transcription => 'ミタイノ', :grammar => nil}],
                              :tokens => [0..1]},
                             'みたいの')

    assert_parses_into_words(mecab, {:words => ['みたい', 'だ'],
                              :lemmas => ['みたい', 'だ'],
                              :pos => [Ve::PartOfSpeech::Adjective, Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'ミタイ', :transcription => 'ミタイ', :grammar => nil},
                                         {:reading => 'ダ', :transcription => 'ダ', :grammar => nil}],
                              :tokens => [0..0, 1..1]},
                             'みたいだ')

    # Meishi tokushu jodoushigokan
    assert_parses_into_words(mecab, {:words => ['行く', 'そう', 'だ'],
                              :lemmas => ['行く', 'そう', 'だ'],
                              :pos => [Ve::PartOfSpeech::Verb, Ve::PartOfSpeech::Verb, Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'イク', :transcription => 'イク', :grammar => nil},
                                         {:reading => 'ソウ', :transcription => 'ソー', :grammar => :auxillary},
                                         {:reading => 'ダ', :transcription => 'ダ', :grammar => nil}],
                              :tokens => [0..0, 1..1, 2..2]},
                             '行くそうだ')

    # Meishi setsubi
    # TODO: This should maybe be parsed as one noun instead
    assert_parses_into_words(mecab, {:words => ['楽し', 'さ'],
                              :lemmas => ['楽しい', 'さ'],
                              :pos => [Ve::PartOfSpeech::Adjective, Ve::PartOfSpeech::Suffix],
                              :extra => [{:reading => 'タノシ', :transcription => 'タノシ', :grammar => nil},
                                         {:reading => 'サ', :transcription => 'サ', :grammar => nil}],
                              :tokens => [0..0, 1..1]},
                             '楽しさ')

    # Meishi setsuzokushiteki
    assert_parses_into_words(mecab, {:words => ['日本', '対', 'アメリカ'],
                              :lemmas => ['日本', '対', 'アメリカ'],
                              :pos => [Ve::PartOfSpeech::ProperNoun, Ve::PartOfSpeech::Conjunction, Ve::PartOfSpeech::ProperNoun],
                              :extra => [{:reading => 'ニッポン', :transcription => 'ニッポン', :grammar => nil},
                                         {:reading => 'タイ', :transcription => 'タイ', :grammar => nil},
                                         {:reading => 'アメリカ', :transcription => 'アメリカ', :grammar => nil}],
                              :tokens => [0..0, 1..1, 2..2]},
                             '日本対アメリカ')

    # Meishi doushihijiritsuteki
    assert_parses_into_words(mecab, {:words => ['見て', 'ごらん'],
                              :lemmas => ['見る', 'ごらん'],
                              :pos => [Ve::PartOfSpeech::Verb, Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'ミテ', :transcription => 'ミテ', :grammar => nil},
                                         {:reading => 'ゴラン', :transcription => 'ゴラン', :grammar => :nominal}],
                              :tokens => [0..1, 2..2]},
                             '見てごらん')

    # Settoushi
    assert_parses_into_words(mecab, {:words => ['お', '座り'],
                              :lemmas => ['お', '座り'],
                              :pos => [Ve::PartOfSpeech::Prefix, Ve::PartOfSpeech::Noun],
                              :extra => [{:reading => 'オ', :transcription => 'オ', :grammar => nil},
                                         {:reading => 'スワリ', :transcription => 'スワリ', :grammar => nil}],
                              :tokens => [0..0, 1..1]},
                             'お座り')

    # Kigou
    assert_parses_into_words(mecab, {:words => ['。'],
                              :lemmas => ['。'],
                              :pos => [Ve::PartOfSpeech::Symbol],
                              :extra => [{:reading => '。', :transcription => '。', :grammar => nil}],
                              :tokens => [0..0]},
                             '。')

    # Firaa
    assert_parses_into_words(mecab, {:words => ['えと'],
                              :lemmas => ['えと'],
                              :pos => [Ve::PartOfSpeech::Interjection],
                              :extra => [{:reading => 'エト', :transcription => 'エト', :grammar => nil}],
                              :tokens => [0..0]},
                             'えと')

    # Sonota
    assert_parses_into_words(mecab, {:words => ['だ', 'ァ'],
                              :lemmas => ['だ', 'ァ'],
                              :pos => [Ve::PartOfSpeech::Postposition, Ve::PartOfSpeech::Other],
                              :extra => [{:reading => 'ダ', :transcription => 'ダ', :grammar => nil},
                                         {:reading => 'ァ', :transcription => 'ア', :grammar => nil}],
                              :tokens => [0..0, 1..1]},
                             'だァ')

    # Kandoushi
    assert_parses_into_words(mecab, {:words => ['おはよう'],
                              :lemmas => ['おはよう'],
                              :pos => [Ve::PartOfSpeech::Interjection],
                              :extra => [{:reading => 'オハヨウ', :transcription => 'オハヨー', :grammar => nil}],
                              :tokens => [0..0]},
                             'おはよう')

    # Rentaishi
    assert_parses_into_words(mecab, {:words => ['この'],
                              :lemmas => ['この'],
                              :pos => [Ve::PartOfSpeech::Determiner],
                              :extra => [{:reading => 'コノ', :transcription => 'コノ', :grammar => nil}],
                              :tokens => [0..0]},
                             'この')

    # Setsuzokushi
    assert_parses_into_words(mecab, {:words => ['そして'],
                              :lemmas => ['そして'],
                              :pos => [Ve::PartOfSpeech::Conjunction],
                              :extra => [{:reading => 'ソシテ', :transcription => 'ソシテ', :grammar => nil}],
                              :tokens => [0..0]},
                             'そして')

    # Fukushi
    assert_parses_into_words(mecab, {:words => ['多分'],
                              :lemmas => ['多分'],
                              :pos => [Ve::PartOfSpeech::Adverb],
                              :extra => [{:reading => 'タブン', :transcription => 'タブン', :grammar => nil}],
                              :tokens => [0..0]},
                             '多分')

    # Doushi
    assert_parses_into_words(mecab, {:words => ['行く'],
                              :lemmas => ['行く'],
                              :pos => [Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'イク', :transcription => 'イク', :grammar => nil}],
                              :tokens => [0..0]},
                             '行く')

    assert_parses_into_words(mecab, {:words => ['行かない'],
                              :lemmas => ['行く'],
                              :pos => [Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'イカナイ', :transcription => 'イカナイ', :grammar => nil}],
                              :tokens => [0..1]},
                             '行かない')

    assert_parses_into_words(mecab, {:words => ['行って', 'きて'],
                              :lemmas => ['行く', 'くる'],
                              :pos => [Ve::PartOfSpeech::Verb, Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'イッテ', :transcription => 'イッテ', :grammar => nil},
                                         {:reading => 'キテ', :transcription => 'キテ', :grammar => :auxillary}],
                              :tokens => [0..1, 2..3]},
                             '行ってきて')

    # Doushi setsubi
    assert_parses_into_words(mecab, {:words => ['行かれる'],
                              :lemmas => ['行く'],
                              :pos => [Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'イカレル', :transcription => 'イカレル', :grammar => nil}],
                              :tokens => [0..1]},
                             '行かれる')

    assert_parses_into_words(mecab, {:words => ['食べさせられた'],
                              :lemmas => ['食べる'],
                              :pos => [Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'タベサセラレタ', :transcription => 'タベサセラレタ', :grammar => nil}],
                              :tokens => [0..3]},
                             '食べさせられた')

    # Doushi + jodoushi
    assert_parses_into_words(mecab, {:words => ['食べました'],
                              :lemmas => ['食べる'],
                              :pos => [Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'タベマシタ', :transcription => 'タベマシタ', :grammar => nil}],
                              :tokens => [0..2]},
                             '食べました')

    # Keiyoushi
    assert_parses_into_words(mecab, {:words => ['寒い'],
                              :lemmas => ['寒い'],
                              :pos => [Ve::PartOfSpeech::Adjective],
                              :extra => [{:reading => 'サムイ', :transcription => 'サムイ', :grammar => nil}],
                              :tokens => [0..0]},
                             '寒い')

    assert_parses_into_words(mecab, {:words => ['寒くて'],
                              :lemmas => ['寒い'],
                              :pos => [Ve::PartOfSpeech::Adjective],
                              :extra => [{:reading => 'サムクテ', :transcription => 'サムクテ', :grammar => nil}],
                              :tokens => [0..1]},
                             '寒くて')

    assert_parses_into_words(mecab, {:words => ['寒かった'],
                              :lemmas => ['寒い'],
                              :pos => [Ve::PartOfSpeech::Adjective],
                              :extra => [{:reading => 'サムカッタ', :transcription => 'サムカッタ', :grammar => nil}],
                              :tokens => [0..1]},
                             '寒かった')

    assert_parses_into_words(mecab, {:words => ['寒ければ'],
                              :lemmas => ['寒い'],
                              :pos => [Ve::PartOfSpeech::Adjective],
                              :extra => [{:reading => 'サムケレバ', :transcription => 'サムケレバ', :grammar => nil}],
                              :tokens => [0..1]},
                             '寒ければ')

    assert_parses_into_words(mecab, {:words => ['寒けりゃ'],
                              :lemmas => ['寒い'],
                              :pos => [Ve::PartOfSpeech::Adjective],
                              :extra => [{:reading => 'サムケリャ', :transcription => 'サムケリャ', :grammar => nil}],
                              :tokens => [0..0]},
                             '寒けりゃ')

    assert_parses_into_words(mecab, {:words => ['食べたい'],
                              :lemmas => ['食べる'],
                              :pos => [Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'タベタイ', :transcription => 'タベタイ', :grammar => nil}],
                              :tokens => [0..1]},
                             '食べたい')

    # Joshi
    assert_parses_into_words(mecab, {:words => ['日本', 'から'],
                              :lemmas => ['日本', 'から'],
                              :pos => [Ve::PartOfSpeech::ProperNoun, Ve::PartOfSpeech::Postposition],
                              :extra => [{:reading => 'ニッポン', :transcription => 'ニッポン', :grammar => nil},
                                         {:reading => 'カラ', :transcription => 'カラ', :grammar => nil}],
                              :tokens => [0..0, 1..1]},
                             '日本から')

    # The copula
    assert_parses_into_words(mecab, {:words => ['日本', 'です'],
                              :lemmas => ['日本', 'です'],
                              :pos => [Ve::PartOfSpeech::ProperNoun, Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'ニッポン', :transcription => 'ニッポン', :grammar => nil},
                                         {:reading => 'デス', :transcription => 'デス', :grammar => nil}],
                              :tokens => [0..0, 1..1]},
                             '日本です')

    assert_parses_into_words(mecab, {:words => ['日本', 'だった'],
                              :lemmas => ['日本', 'だ'],
                              :pos => [Ve::PartOfSpeech::ProperNoun, Ve::PartOfSpeech::Verb],
                              :extra => [{:reading => 'ニッポン', :transcription => 'ニッポン', :grammar => nil},
                                         {:reading => 'ダッタ', :transcription => 'ダッタ', :grammar => nil}],
                              :tokens => [0..0, 1..2]},
                             '日本だった')

	# いるから
	assert_parses_into_words(mecab, {:words => ['いる', 'から'],
                              		 :lemmas => ['いる', 'から'],
	                                 :pos => [Ve::PartOfSpeech::Verb, Ve::PartOfSpeech::Postposition],
                                     :extra => [{:reading => 'イル', :transcription => 'イル', :grammar => nil},
	                                            {:reading => 'カラ', :transcription => 'カラ', :grammar => nil}],
                                     :tokens => [0..0, 1..1]},
                             'いるから')

	# しているから
	assert_parses_into_words(mecab, {:words => ['して', 'いる', 'から'],
                              		 :lemmas => ['する', 'いる', 'から'],
	                                 :pos => [Ve::PartOfSpeech::Verb, Ve::PartOfSpeech::Verb, Ve::PartOfSpeech::Postposition],
                                     :extra => [{:reading => 'シテ', :transcription => 'シテ', :grammar => nil},
                                     			{:reading => 'イル', :transcription => 'イル', :grammar => :auxillary},
	                                            {:reading => 'カラ', :transcription => 'カラ', :grammar => nil}],
                                     :tokens => [0..0, 1..1, 2..2]},
                             'しているから')

	# 基準があるが、
	assert_parses_into_words(mecab, {:words => ['して', 'いる', 'から'],
                              		 :lemmas => ['する', 'いる', 'から'],
	                                 :pos => [Ve::PartOfSpeech::Verb, Ve::PartOfSpeech::Verb, Ve::PartOfSpeech::Postposition],
                                   :extra => [{:reading => 'シテ', :transcription => 'シテ', :grammar => nil},
                                     			    {:reading => 'イル', :transcription => 'イル', :grammar => :auxillary},
	                                            {:reading => 'カラ', :transcription => 'カラ', :grammar => nil}],
                                   :tokens => [0..0, 1..1, 2..2]},
                             '基準があるが、')

    # TODO: xした should parse as adjective?
    assert_parses_into_words(mecab, {:words => [],
                              :lemmas => [],
                              :pos => [],
                              :extra => [],
                              :tokens => []},
                             '')
  end

  def todo_test_word_transliteration
    mecab = Ve::Provider::MecabIpadic.new
    parse = mecab.parse('日本', :transliterate_words => :latn)

    assert_equal 'nihon', parse.words.first.transliteration(:latn)
  end

end
