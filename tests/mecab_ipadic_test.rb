# Encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + "/../lib/sprakd")
require 'test/unit'

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
  
  def test_creates_tokens_from_data_that_is_ignored_in_parsing
    mecab = Sprakd::Provider::MecabIpadic.new
    parse = mecab.parse('A   B  ')
    assert_equal [:parsed, :unparsed, :parsed, :unparsed, :sentence_split], parse.tokens.collect { |t| t[:type] }
    assert_equal ['A', '   ', 'B', '  ', ''], parse.tokens.collect { |t| t[:literal] }
  end
  
  def test_can_give_sentences
    mecab = Sprakd::Provider::MecabIpadic.new
    parse = mecab.parse('これは文章である。で、also containing some Englishですね')
    assert_equal ['これは文章である。', 'で、also containing some Englishですね'], parse.sentences
  end
  
  def test_tokens_should_not_be_modified_when_attached_to_words
    mecab = Sprakd::Provider::MecabIpadic.new
    parse = mecab.parse('悪化する')
    tokens = parse.tokens
    assert_equal '悪化', tokens[0][:literal]
    assert_equal '悪化', tokens[0][:lemma]
  end

  # TODO: Test that entire rule tree
  def test_word_assembly
    mecab = Sprakd::Provider::MecabIpadic.new

    # For kopipe
    if false
      assert_parses_into_words({:words => [],
                                :lemmas => [],
                                :pos => [],
                                :grammar => [],
                                :tokens => []},
                               '')
    end

    # NOUNS
    # Meishi
    assert_parses_into_words({:words => ['車'],
                              :lemmas => ['車'],
                              :pos => [Sprakd::PartOfSpeech::Noun],
                              :grammar => [nil],
                              :tokens => [0..0]},
                             '車')
    
    # Koyuumeishi
    assert_parses_into_words({:words => ['太郎'],
                              :lemmas => ['太郎'],
                              :pos => [Sprakd::PartOfSpeech::ProperNoun],
                              :grammar => [nil],
                              :tokens => [0..0]},
                             '太郎')

    # Daimeishi
    assert_parses_into_words({:words => ['彼'],
                              :lemmas => ['彼'],
                              :pos => [Sprakd::PartOfSpeech::Pronoun],
                              :grammar => [nil],
                              :tokens => [0..0]},
                             '彼')

    # Fukushikanou
    assert_parses_into_words({:words => ['午後に'],
                              :lemmas => ['午後に'],
                              :pos => [Sprakd::PartOfSpeech::Adverb],
                              :grammar => [nil],
                              :tokens => [0..1]},
                             '午後に')

    # Kazu
    assert_parses_into_words({:words => ['一'],
                              :lemmas => ['一'],
                              :pos => [Sprakd::PartOfSpeech::Number],
                              :grammar => [nil],
                              :tokens => [0..0]},
                             '一')

    # Sahensetsuzoku + tokumi ta
    assert_parses_into_words({:words => ['悪化した'],
                              :lemmas => ['悪化する'],
                              :pos => [Sprakd::PartOfSpeech::Verb],
                              :grammar => [nil],
                              :tokens => [0..2]},
                             '悪化した')

    # Keiyoudoushigokan
    assert_parses_into_words({:words => ['重要な'],
                              :lemmas => ['重要だ'],
                              :pos => [Sprakd::PartOfSpeech::Adjective],
                              :grammar => [nil],
                              :tokens => [0..1]},
                             '重要な')

    # Naikeiyoushigokan
    assert_parses_into_words({:words => ['とんでもない'],
                              :lemmas => ['とんでもない'],
                              :pos => [Sprakd::PartOfSpeech::Adjective],
                              :grammar => [nil],
                              :tokens => [0..1]},
                             'とんでもない')

    # Meishi hijiritsu fukushikanou
    assert_parses_into_words({:words => ['の', 'うちに'],
                              :lemmas => ['の', 'うちに'],
                              :pos => [Sprakd::PartOfSpeech::TBD, Sprakd::PartOfSpeech::Adverb],
                              :grammar => [nil, nil],
                              :tokens => [0..0, 1..2]},
                             'のうちに')

    # Meishi hijiritsu jodoushigokan
    assert_parses_into_words({:words => ['の', 'ような'],
                              :lemmas => ['の', 'ようだ'],
                              :pos => [Sprakd::PartOfSpeech::TBD, Sprakd::PartOfSpeech::Verb],
                              :grammar => [nil, :auxillary],
                              :tokens => [0..0, 1..2]},
                             'のような')

    assert_parses_into_words({:words => ['の', 'ように'],
                              :lemmas => ['の', 'ように'],
                              :pos => [Sprakd::PartOfSpeech::TBD, Sprakd::PartOfSpeech::Adverb],
                              :grammar => [nil, nil],
                              :tokens => [0..0, 1..2]},
                             'のように')

    # Meishi hijiritsu keiyoudoushigokan
    assert_parses_into_words({:words => ['みたいな'],
                              :lemmas => ['みたいだ'],
                              :pos => [Sprakd::PartOfSpeech::Adjective],
                              :grammar => [nil],
                              :tokens => [0..1]},
                             'みたいな')

    assert_parses_into_words({:words => ['みたいの'],
                              :lemmas => ['みたいの'],
                              :pos => [Sprakd::PartOfSpeech::Adjective],
                              :grammar => [nil],
                              :tokens => [0..1]},
                             'みたいの')

    assert_parses_into_words({:words => ['みたい', 'だ'],
                              :lemmas => ['みたい', 'だ'],
                              :pos => [Sprakd::PartOfSpeech::Adjective, Sprakd::PartOfSpeech::Postposition],
                              :grammar => [nil, nil],
                              :tokens => [0..0, 1..1]},
                             'みたいだ')

    # Meishi tokushu jodoushigokan
    assert_parses_into_words({:words => ['行く', 'そう', 'だ'],
                              :lemmas => ['行く', 'そう', 'だ'],
                              :pos => [Sprakd::PartOfSpeech::TBD, Sprakd::PartOfSpeech::Verb, Sprakd::PartOfSpeech::Postposition],
                              :grammar => [nil, :auxillary, nil],
                              :tokens => [0..0, 1..1, 2..2]},
                             '行くそうだ')

    # Meishi setsubi
    assert_parses_into_words({:words => ['楽し', 'さ'],
                              :lemmas => ['楽しい', 'さ'],
                              :pos => [Sprakd::PartOfSpeech::TBD, Sprakd::PartOfSpeech::Suffix],
                              :grammar => [nil, nil],
                              :tokens => [0..0, 1..1]},
                             '楽しさ')

    # Meishi setsuzokushiteki
    assert_parses_into_words({:words => ['日本', '対', 'アメリカ'],
                              :lemmas => ['日本', '対', 'アメリカ'],
                              :pos => [Sprakd::PartOfSpeech::ProperNoun, Sprakd::PartOfSpeech::Conjunction, Sprakd::PartOfSpeech::ProperNoun],
                              :grammar => [nil, nil, nil],
                              :tokens => [0..0, 1..1, 2..2]},
                             '日本対アメリカ')

    # Meishi doushihijiritsuteki
    assert_parses_into_words({:words => ['見', 'て', 'ごらん'],
                              :lemmas => ['見る', 'て', 'ごらん'],
                              :pos => [Sprakd::PartOfSpeech::TBD, Sprakd::PartOfSpeech::TBD, Sprakd::PartOfSpeech::Verb],
                              :grammar => [nil, nil, :nominal],
                              :tokens => [0..0, 1..1, 2..2]},
                             '見てごらん')

    # Settoushi
    assert_parses_into_words({:words => ['お', '座り'],
                              :lemmas => ['お', '座り'],
                              :pos => [Sprakd::PartOfSpeech::Prefix, Sprakd::PartOfSpeech::Noun],
                              :grammar => [nil, nil],
                              :tokens => [0..0, 1..1]},
                             'お座り')

    # Kigou
    assert_parses_into_words({:words => ['。'],
                              :lemmas => ['。'],
                              :pos => [Sprakd::PartOfSpeech::Symbol],
                              :grammar => [nil],
                              :tokens => [0..0]},
                             '。')

    # Firaa
    assert_parses_into_words({:words => ['えと'],
                              :lemmas => ['えと'],
                              :pos => [Sprakd::PartOfSpeech::Interjection],
                              :grammar => [nil],
                              :tokens => [0..0]},
                             'えと')

    # Sonota
    assert_parses_into_words({:words => ['だ', 'ァ'],
                              :lemmas => ['だ', 'ァ'],
                              :pos => [Sprakd::PartOfSpeech::Postposition, Sprakd::PartOfSpeech::Other],
                              :grammar => [nil, nil],
                              :tokens => [0..0, 1..1]},
                             'だァ')

    # Kandoushi
    assert_parses_into_words({:words => ['おはよう'],
                              :lemmas => ['おはよう'],
                              :pos => [Sprakd::PartOfSpeech::Interjection],
                              :grammar => [nil],
                              :tokens => [0..0]},
                             'おはよう')

    # Rentaishi
    assert_parses_into_words({:words => ['この'],
                              :lemmas => ['この'],
                              :pos => [Sprakd::PartOfSpeech::Determiner],
                              :grammar => [nil],
                              :tokens => [0..0]},
                             'この')

    # Doushi
    assert_parses_into_words({:words => [],
                              :lemmas => [],
                              :pos => [],
                              :grammar => [],
                              :tokens => []},
                             '')
    assert_parses_into_words({:words => [],
                              :lemmas => [],
                              :pos => [],
                              :grammar => [],
                              :tokens => []},
                             '')
    assert_parses_into_words({:words => [],
                              :lemmas => [],
                              :pos => [],
                              :grammar => [],
                              :tokens => []},
                             '')
    assert_parses_into_words({:words => [],
                              :lemmas => [],
                              :pos => [],
                              :grammar => [],
                              :tokens => []},
                             '')
    assert_parses_into_words({:words => [],
                              :lemmas => [],
                              :pos => [],
                              :grammar => [],
                              :tokens => []},
                             '')
    assert_parses_into_words({:words => [],
                              :lemmas => [],
                              :pos => [],
                              :grammar => [],
                              :tokens => []},
                             '')
    assert_parses_into_words({:words => [],
                              :lemmas => [],
                              :pos => [],
                              :grammar => [],
                              :tokens => []},
                             '')
    assert_parses_into_words({:words => [],
                              :lemmas => [],
                              :pos => [],
                              :grammar => [],
                              :tokens => []},
                             '')
  end

  private

  def assert_parses_into_words(expected, text)
    mecab = Sprakd::Provider::MecabIpadic.new
    parse = mecab.parse(text)
    words = parse.words
    tokens = parse.tokens
    
    assert_equal expected[:words], words.collect(&:word)
    assert_equal expected[:lemmas], words.collect(&:lemma)
    assert_equal expected[:pos], words.collect(&:part_of_speech)
    assert_equal expected[:grammar], words.collect(&:grammar)

    words.each_with_index do |word, i|
      assert_equal tokens[expected[:tokens][i]], word.tokens
    end
  end
  
end
