# Encoding: UTF-8

require 'test/unit'
require File.expand_path(File.dirname(__FILE__) + "/../lib/sprakd")
require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class MecabIpadicTest < Test::Unit::TestCase
  
  def test_should_be_able_to_start
    mecab = Sprakd::Provider::MecabIpadic.new
    assert mecab.works?
  end

  def test_can_parse
    mecab = Sprakd::Provider::MecabIpadic.new
    parse = mecab.parse('')
    assert_equal Sprakd::Parse::MecabIpadic, parse.class
  end
  
  def test_all_literals_should_equal_the_input_text
    text = <<-EOS
    古池や
    蛙飛び込む
    水の音
    
    EOS
    mecab = Sprakd::Provider::MecabIpadic.new
    parse = mecab.parse(text)
    assert_equal text, parse.tokens.collect { |t| t[:literal] }.join
  end
  
  def test_tokens_must_be_created_for_parsed_and_unparsed_text
    mecab = Sprakd::Provider::MecabIpadic.new
    parse = mecab.parse(' A   B  ')
    assert_equal [:unparsed, :parsed, :unparsed, :parsed, :unparsed, :sentence_split], parse.tokens.collect { |t| t[:type] }
    assert_equal [' ', 'A', '   ', 'B', '  ', ''], parse.tokens.collect { |t| t[:literal] }
    assert_equal [0..0, 1..1, 2..4, 5..5, 6..7, nil], parse.tokens.collect { |t| t[:characters] }
  end
  
  def test_tokens_should_not_be_modified_when_attached_to_words
    mecab = Sprakd::Provider::MecabIpadic.new
    parse = mecab.parse('悪化する')
    tokens = parse.tokens
    assert_equal '悪化', tokens[0][:literal]
    assert_equal '悪化', tokens[0][:lemma]
  end

  def test_sentences
    mecab = Sprakd::Provider::MecabIpadic.new
    parse = mecab.parse('これは文章である。で、also containing some Englishですね')
    assert_equal ['これは文章である。', 'で、also containing some Englishですね'], parse.sentences
  end
  

  def test_words
    mecab = Sprakd::Provider::MecabIpadic.new

    # Meishi
    assert_parses_into_words(mecab, {:words => ['車'],
                              :lemmas => ['車'],
                              :pos => [Sprakd::PartOfSpeech::Noun],
                              :grammar => [nil],
                              :tokens => [0..0]},
                             '車')
    
    # Koyuumeishi
    assert_parses_into_words(mecab, {:words => ['太郎'],
                              :lemmas => ['太郎'],
                              :pos => [Sprakd::PartOfSpeech::ProperNoun],
                              :grammar => [nil],
                              :tokens => [0..0]},
                             '太郎')

    # Daimeishi
    assert_parses_into_words(mecab, {:words => ['彼'],
                              :lemmas => ['彼'],
                              :pos => [Sprakd::PartOfSpeech::Pronoun],
                              :grammar => [nil],
                              :tokens => [0..0]},
                             '彼')

    # Fukushikanou
    assert_parses_into_words(mecab, {:words => ['午後に'],
                              :lemmas => ['午後に'],
                              :pos => [Sprakd::PartOfSpeech::Adverb],
                              :grammar => [nil],
                              :tokens => [0..1]},
                             '午後に')

    # Kazu
    assert_parses_into_words(mecab, {:words => ['一'],
                              :lemmas => ['一'],
                              :pos => [Sprakd::PartOfSpeech::Number],
                              :grammar => [nil],
                              :tokens => [0..0]},
                             '一')

    assert_parses_into_words(mecab, {:words => ['１２３'],
                              :lemmas => ['１２３'],
                              :pos => [Sprakd::PartOfSpeech::Number],
                              :grammar => [nil],
                              :tokens => [0..2]},
                             '１２３')

    # Sahensetsuzoku + tokumi ta
    assert_parses_into_words(mecab, {:words => ['悪化した'],
                              :lemmas => ['悪化する'],
                              :pos => [Sprakd::PartOfSpeech::Verb],
                              :grammar => [nil],
                              :tokens => [0..2]},
                             '悪化した')

    # Keiyoudoushigokan
    assert_parses_into_words(mecab, {:words => ['重要な'],
                              :lemmas => ['重要'],
                              :pos => [Sprakd::PartOfSpeech::Adjective],
                              :grammar => [nil],
                              :tokens => [0..1]},
                             '重要な')

    # Naikeiyoushigokan
    assert_parses_into_words(mecab, {:words => ['とんでもない'],
                              :lemmas => ['とんでもない'],
                              :pos => [Sprakd::PartOfSpeech::Adjective],
                              :grammar => [nil],
                              :tokens => [0..1]},
                             'とんでもない')

    # Meishi hijiritsu fukushikanou
    assert_parses_into_words(mecab, {:words => ['の', 'うちに'],
                              :lemmas => ['の', 'うちに'],
                              :pos => [Sprakd::PartOfSpeech::Postposition, Sprakd::PartOfSpeech::Adverb],
                              :grammar => [nil, nil],
                              :tokens => [0..0, 1..2]},
                             'のうちに')

    # Meishi hijiritsu jodoushigokan
    assert_parses_into_words(mecab, {:words => ['の', 'ような'],
                              :lemmas => ['の', 'ようだ'],
                              :pos => [Sprakd::PartOfSpeech::Postposition, Sprakd::PartOfSpeech::Verb],
                              :grammar => [nil, :auxillary],
                              :tokens => [0..0, 1..2]},
                             'のような')

    assert_parses_into_words(mecab, {:words => ['の', 'ように'],
                              :lemmas => ['の', 'ように'],
                              :pos => [Sprakd::PartOfSpeech::Postposition, Sprakd::PartOfSpeech::Adverb],
                              :grammar => [nil, nil],
                              :tokens => [0..0, 1..2]},
                             'のように')

    # Meishi hijiritsu keiyoudoushigokan
    assert_parses_into_words(mecab, {:words => ['みたいな'],
                              :lemmas => ['みたいだ'],
                              :pos => [Sprakd::PartOfSpeech::Adjective],
                              :grammar => [nil],
                              :tokens => [0..1]},
                             'みたいな')

    assert_parses_into_words(mecab, {:words => ['みたいの'],
                              :lemmas => ['みたいの'],
                              :pos => [Sprakd::PartOfSpeech::Adjective],
                              :grammar => [nil],
                              :tokens => [0..1]},
                             'みたいの')

    assert_parses_into_words(mecab, {:words => ['みたい', 'だ'],
                              :lemmas => ['みたい', 'だ'],
                              :pos => [Sprakd::PartOfSpeech::Adjective, Sprakd::PartOfSpeech::Verb],
                              :grammar => [nil, nil],
                              :tokens => [0..0, 1..1]},
                             'みたいだ')

    # Meishi tokushu jodoushigokan
    assert_parses_into_words(mecab, {:words => ['行く', 'そう', 'だ'],
                              :lemmas => ['行く', 'そう', 'だ'],
                              :pos => [Sprakd::PartOfSpeech::Verb, Sprakd::PartOfSpeech::Verb, Sprakd::PartOfSpeech::Verb],
                              :grammar => [nil, :auxillary, nil],
                              :tokens => [0..0, 1..1, 2..2]},
                             '行くそうだ')

    # Meishi setsubi
    # TODO: This should maybe be parsed as one noun instead
    assert_parses_into_words(mecab, {:words => ['楽し', 'さ'],
                              :lemmas => ['楽しい', 'さ'],
                              :pos => [Sprakd::PartOfSpeech::Adjective, Sprakd::PartOfSpeech::Suffix],
                              :grammar => [nil, nil],
                              :tokens => [0..0, 1..1]},
                             '楽しさ')

    # Meishi setsuzokushiteki
    assert_parses_into_words(mecab, {:words => ['日本', '対', 'アメリカ'],
                              :lemmas => ['日本', '対', 'アメリカ'],
                              :pos => [Sprakd::PartOfSpeech::ProperNoun, Sprakd::PartOfSpeech::Conjunction, Sprakd::PartOfSpeech::ProperNoun],
                              :grammar => [nil, nil, nil],
                              :tokens => [0..0, 1..1, 2..2]},
                             '日本対アメリカ')

    # Meishi doushihijiritsuteki
    assert_parses_into_words(mecab, {:words => ['見て', 'ごらん'],
                              :lemmas => ['見る', 'ごらん'],
                              :pos => [Sprakd::PartOfSpeech::Verb, Sprakd::PartOfSpeech::Verb],
                              :grammar => [nil, :nominal],
                              :tokens => [0..1, 2..2]},
                             '見てごらん')

    # Settoushi
    assert_parses_into_words(mecab, {:words => ['お', '座り'],
                              :lemmas => ['お', '座り'],
                              :pos => [Sprakd::PartOfSpeech::Prefix, Sprakd::PartOfSpeech::Noun],
                              :grammar => [nil, nil],
                              :tokens => [0..0, 1..1]},
                             'お座り')

    # Kigou
    assert_parses_into_words(mecab, {:words => ['。'],
                              :lemmas => ['。'],
                              :pos => [Sprakd::PartOfSpeech::Symbol],
                              :grammar => [nil],
                              :tokens => [0..0]},
                             '。')

    # Firaa
    assert_parses_into_words(mecab, {:words => ['えと'],
                              :lemmas => ['えと'],
                              :pos => [Sprakd::PartOfSpeech::Interjection],
                              :grammar => [nil],
                              :tokens => [0..0]},
                             'えと')

    # Sonota
    assert_parses_into_words(mecab, {:words => ['だ', 'ァ'],
                              :lemmas => ['だ', 'ァ'],
                              :pos => [Sprakd::PartOfSpeech::Postposition, Sprakd::PartOfSpeech::Other],
                              :grammar => [nil, nil],
                              :tokens => [0..0, 1..1]},
                             'だァ')

    # Kandoushi
    assert_parses_into_words(mecab, {:words => ['おはよう'],
                              :lemmas => ['おはよう'],
                              :pos => [Sprakd::PartOfSpeech::Interjection],
                              :grammar => [nil],
                              :tokens => [0..0]},
                             'おはよう')

    # Rentaishi
    assert_parses_into_words(mecab, {:words => ['この'],
                              :lemmas => ['この'],
                              :pos => [Sprakd::PartOfSpeech::Determiner],
                              :grammar => [nil],
                              :tokens => [0..0]},
                             'この')

    # Setsuzokushi
    assert_parses_into_words(mecab, {:words => ['そして'],
                              :lemmas => ['そして'],
                              :pos => [Sprakd::PartOfSpeech::Conjunction],
                              :grammar => [nil],
                              :tokens => [0..0]},
                             'そして')

    # Fukushi
    assert_parses_into_words(mecab, {:words => ['多分'],
                              :lemmas => ['多分'],
                              :pos => [Sprakd::PartOfSpeech::Adverb],
                              :grammar => [nil],
                              :tokens => [0..0]},
                             '多分')

    # Doushi
    assert_parses_into_words(mecab, {:words => ['行く'],
                              :lemmas => ['行く'],
                              :pos => [Sprakd::PartOfSpeech::Verb],
                              :grammar => [nil],
                              :tokens => [0..0]},
                             '行く')

    assert_parses_into_words(mecab, {:words => ['行かない'],
                              :lemmas => ['行く'],
                              :pos => [Sprakd::PartOfSpeech::Verb],
                              :grammar => [nil],
                              :tokens => [0..1]},
                             '行かない')

    assert_parses_into_words(mecab, {:words => ['行って', 'きて'],
                              :lemmas => ['行く', 'くる'],
                              :pos => [Sprakd::PartOfSpeech::Verb, Sprakd::PartOfSpeech::Verb],
                              :grammar => [nil, :auxillary],
                              :tokens => [0..1, 2..3]},
                             '行ってきて')

    # Doushi setsubi
    assert_parses_into_words(mecab, {:words => ['行かれる'],
                              :lemmas => ['行く'],
                              :pos => [Sprakd::PartOfSpeech::Verb],
                              :grammar => [nil],
                              :tokens => [0..1]},
                             '行かれる')

    assert_parses_into_words(mecab, {:words => ['食べさせられた'],
                              :lemmas => ['食べる'],
                              :pos => [Sprakd::PartOfSpeech::Verb],
                              :grammar => [nil],
                              :tokens => [0..3]},
                             '食べさせられた')

    # Doushi + jodoushi
    assert_parses_into_words(mecab, {:words => ['食べました'],
                              :lemmas => ['食べる'],
                              :pos => [Sprakd::PartOfSpeech::Verb],
                              :grammar => [nil],
                              :tokens => [0..2]},
                             '食べました')

    # Keiyoushi
    assert_parses_into_words(mecab, {:words => ['寒い'],
                              :lemmas => ['寒い'],
                              :pos => [Sprakd::PartOfSpeech::Adjective],
                              :grammar => [nil],
                              :tokens => [0..0]},
                             '寒い')

    assert_parses_into_words(mecab, {:words => ['寒くて'],
                              :lemmas => ['寒い'],
                              :pos => [Sprakd::PartOfSpeech::Adjective],
                              :grammar => [nil],
                              :tokens => [0..1]},
                             '寒くて')

    assert_parses_into_words(mecab, {:words => ['寒かった'],
                              :lemmas => ['寒い'],
                              :pos => [Sprakd::PartOfSpeech::Adjective],
                              :grammar => [nil],
                              :tokens => [0..1]},
                             '寒かった')

    assert_parses_into_words(mecab, {:words => ['寒ければ'],
                              :lemmas => ['寒い'],
                              :pos => [Sprakd::PartOfSpeech::Adjective],
                              :grammar => [nil],
                              :tokens => [0..1]},
                             '寒ければ')

    assert_parses_into_words(mecab, {:words => ['寒けりゃ'],
                              :lemmas => ['寒い'],
                              :pos => [Sprakd::PartOfSpeech::Adjective],
                              :grammar => [nil],
                              :tokens => [0..0]},
                             '寒けりゃ')

    assert_parses_into_words(mecab, {:words => ['食べたい'],
                              :lemmas => ['食べる'],
                              :pos => [Sprakd::PartOfSpeech::Verb],
                              :grammar => [nil],
                              :tokens => [0..1]},
                             '食べたい')

    # Joshi
    assert_parses_into_words(mecab, {:words => ['日本', 'から'],
                              :lemmas => ['日本', 'から'],
                              :pos => [Sprakd::PartOfSpeech::ProperNoun, Sprakd::PartOfSpeech::Postposition],
                              :grammar => [nil, nil],
                              :tokens => [0..0, 1..1]},
                             '日本から')

    # The copula
    assert_parses_into_words(mecab, {:words => ['日本', 'です'],
                              :lemmas => ['日本', 'です'],
                              :pos => [Sprakd::PartOfSpeech::ProperNoun, Sprakd::PartOfSpeech::Verb],
                              :grammar => [nil, nil],
                              :tokens => [0..0, 1..1]},
                             '日本です')

    assert_parses_into_words(mecab, {:words => ['日本', 'だった'],
                              :lemmas => ['日本', 'だ'],
                              :pos => [Sprakd::PartOfSpeech::ProperNoun, Sprakd::PartOfSpeech::Verb],
                              :grammar => [nil, nil],
                              :tokens => [0..0, 1..2]},
                             '日本だった')

    # TODO: xした should parse as adjective?
    assert_parses_into_words(mecab, {:words => [],
                              :lemmas => [],
                              :pos => [],
                              :grammar => [],
                              :tokens => []},
                             '')
  end

  def test_word_transliteration
    mecab = Sprakd::Provider::MecabIpadic.new
    parse = mecab.parse('日本', :transliterate_words => :latn)

    assert_equal 'にほん', parse.words.first.transliteration(:latn)
  end
  
end
