# Encoding: UTF-8

class Ve
  class Provider
    class JapaneseTransliterators < Ve::Provider

      def initialize(config = {})
      end

      def works?
        true
      end

      def parse(text, options = {})
        Ve::Parse::JapaneseTransliterators.new(text)
      end

    end
  end
end

class Ve
  class Parse
    class JapaneseTransliterators < Ve::Parse

      H_SYLLABIC_N   = 'ん'
      H_SMALL_TSU    = 'っ'

      HIRA_TO_LATN = {
        "あ"=>"a", "い"=>"i", "う"=>"u", "え"=>"e", "お"=>"o",
        "か"=>"ka", "き"=>"ki", "く"=>"ku", "け"=>"ke", "こ"=>"ko",
        "が"=>"ga", "ぎ"=>"gi", "ぐ"=>"gu", "げ"=>"ge", "ご"=>"go",
        "さ"=>"sa", "し"=>"shi", "す"=>"su", "せ"=>"se", "そ"=>"so",
        "ざ"=>"za", "じ"=>"ji", "ず"=>"zu", "ぜ"=>"ze", "ぞ"=>"zo",
        "た"=>"ta", "ち"=>"chi", "つ"=>"tsu", "て"=>"te", "と"=>"to",
        "だ"=>"da", "ぢ"=>"ji", "づ"=>"zu", "で"=>"de", "ど"=>"do",
        "な"=>"na", "に"=>"ni", "ぬ"=>"nu", "ね"=>"ne", "の"=>"no",
        "は"=>"ha", "ひ"=>"hi", "ふ"=>"fu", "へ"=>"he", "ほ"=>"ho",
        "ば"=>"ba", "び"=>"bi", "ぶ"=>"bu", "べ"=>"be", "ぼ"=>"bo",
        "ぱ"=>"pa", "ぴ"=>"pi", "ぷ"=>"pu", "ぺ"=>"pe", "ぽ"=>"po",
        "ま"=>"ma", "み"=>"mi", "む"=>"mu", "め"=>"me", "も"=>"mo",
        "や"=>"ya", "ゆ"=>"yu", "よ"=>"yo",
        "ら"=>"ra", "り"=>"ri", "る"=>"ru", "れ"=>"re", "ろ"=>"ro",
        "わ"=>"wa", "うぃ"=>"whi", "うぇ"=>"whe", "を"=>"wo",
        "ゑ"=>"we", "ゐ"=>"wi", "ー"=>"-", "ん"=>"n",

        "きゃ"=>"kya", "きゅ"=>"kyu", "きょ"=>"kyo", "きぇ"=>"kye", "きぃ"=>"kyi",
        "ぎゃ"=>"gya", "ぎゅ"=>"gyu", "ぎょ"=>"gyo", "ぎぇ"=>"gye", "ぎぃ"=>"gyi",
        "くぁ"=>"kwa", "くぃ"=>"kwi", "くぅ"=>"kwu", "くぇ"=>"kwe", "くぉ"=>"kwo",
        "ぐぁ"=>"qwa", "ぐぃ"=>"gwi", "ぐぅ"=>"gwu", "ぐぇ"=>"gwe", "ぐぉ"=>"gwo",
        "しゃ"=>"sha", "しぃ"=>"syi", "しゅ"=>"shu", "しぇ"=>"she", "しょ"=>"sho",
        "じゃ"=>"ja", "じゅ"=>"ju", "じぇ"=>"jye", "じょ"=>"jo", "じぃ"=>"jyi",
        "すぁ"=>"swa", "すぃ"=>"swi", "すぅ"=>"swu", "すぇ"=>"swe", "すぉ"=>"swo",
        "ちゃ"=>"cha", "ちゅ"=>"chu", "ちぇ"=>"tye", "ちょ"=>"cho", "ちぃ"=>"tyi",
        "ぢゃ"=>"ja", "ぢぃ"=>"dyi", "ぢゅ"=>"ju", "ぢぇ"=>"dye", "ぢょ"=>"jo",
        "つぁ"=>"tsa", "つぃ"=>"tsi", "つぇ"=>"tse", "つぉ"=>"tso", "てゃ"=>"tha",
        "てぃ"=>"thi", "てゅ"=>"thu", "てぇ"=>"the", "てょ"=>"tho", "とぁ"=>"twa",
        "とぃ"=>"twi", "とぅ"=>"twu", "とぇ"=>"twe", "とぉ"=>"two", "でゃ"=>"dha",
        "でぃ"=>"dhi", "でゅ"=>"dhu", "でぇ"=>"dhe", "でょ"=>"dho", "どぁ"=>"dwa",
        "どぃ"=>"dwi", "どぅ"=>"dwu", "どぇ"=>"dwe", "どぉ"=>"dwo", "にゃ"=>"nya",
        "にゅ"=>"nyu", "にょ"=>"nyo", "にぇ"=>"nye", "にぃ"=>"nyi", "ひゃ"=>"hya",
        "ひぃ"=>"hyi", "ひゅ"=>"hyu", "ひぇ"=>"hye", "ひょ"=>"hyo", "びゃ"=>"bya",
        "びぃ"=>"byi", "びゅ"=>"byu", "びぇ"=>"bye", "びょ"=>"byo", "ぴゃ"=>"pya",
        "ぴぃ"=>"pyi", "ぴゅ"=>"pyu", "ぴぇ"=>"pye", "ぴょ"=>"pyo", "ふぁ"=>"fwa",
        "ふぃ"=>"fyi", "ふぇ"=>"fye", "ふぉ"=>"fwo", "ふぅ"=>"fwu", "ふゃ"=>"fya",
        "ふゅ"=>"fyu", "ふょ"=>"fyo", "みゃ"=>"mya", "みぃ"=>"myi", "みゅ"=>"myu",
        "みぇ"=>"mye", "みょ"=>"myo", "りゃ"=>"rya", "りぃ"=>"ryi", "りゅ"=>"ryu",
        "りぇ"=>"rye", "りょ"=>"ryo",
        "ゔぁ"=>"va", "ゔぃ"=>"vyi", "ゔ"=>"vu", "ゔぇ"=>"vye", "ゔぉ"=>"vo",
        "ゔゃ"=>"vya", "ゔゅ"=>"vyu", "ゔょ"=>"vyo",
        "うぁ"=>"wha", "いぇ"=>"ye", "うぉ"=>"who",
        "ぁ"=>"xa", "ぃ"=>"xi", "ぅ"=>"xu", "ぇ"=>"xe", "ぉ"=>"xo",
        "ゕ"=>"xka", "ゖ"=>"xke", "ゎ"=>"xwa"
      }

      LATN_TO_HIRA = {
        'a'   => 'あ', 'i'   => 'い',                'u'  => 'う',               'e'  => 'え',   'o'  => 'お',
        'ka'  => 'か', 'ki'  => 'き',                'ku' => 'く',               'ke' => 'け',   'ko' => 'こ',
        'ga'  => 'が', 'gi'  => 'ぎ',                'gu' => 'ぐ',               'ge' => 'げ',   'go' => 'ご',
        'sa'  => 'さ', 'si'  => 'し', 'shi' => 'し', 'su' => 'す',               'se' => 'せ',   'so' => 'そ',
        'za'  => 'ざ', 'zi'  => 'じ', 'ji'  => 'じ', 'zu' => 'ず',               'ze' => 'ぜ',   'zo' => 'ぞ',
        'ta'  => 'た', 'ti'  => 'ち', 'chi' => 'ち', 'tu' => 'つ', 'tsu'=> 'つ', 'te' => 'て',   'to' => 'と',
        'da'  => 'だ', 'di'  => 'ぢ',                'du' => 'づ', 'dzu'=> 'づ', 'de' => 'で',   'do' => 'ど',
        'na'  => 'な', 'ni'  => 'に',                'nu' => 'ぬ',               'ne' => 'ね',   'no' => 'の',
        'ha'  => 'は', 'hi'  => 'ひ',                'hu' => 'ふ', 'fu' => 'ふ', 'he' => 'へ',   'ho' => 'ほ',
        'ba'  => 'ば', 'bi'  => 'び',                'bu' => 'ぶ',               'be' => 'べ',   'bo' => 'ぼ',
        'pa'  => 'ぱ', 'pi'  => 'ぴ',                'pu' => 'ぷ',               'pe' => 'ぺ',   'po' => 'ぽ',
        'ma'  => 'ま', 'mi'  => 'み',                'mu' => 'む',               'me' => 'め',   'mo' => 'も',
        'ya'  => 'や',                               'yu' => 'ゆ',                               'yo' => 'よ',
        'ra'  => 'ら', 'ri'  => 'り',                'ru' => 'る',               're' => 'れ',   'ro' => 'ろ',
        'la'  => 'ら', 'li'  => 'り',                'lu' => 'る',               'le' => 'れ',   'lo' => 'ろ',
        'wa'  => 'わ', 'wi'  => 'うぃ',                                          'we' => 'うぇ', 'wo' => 'を',
        'wye' => 'ゑ', 'wyi' => 'ゐ', '-' => 'ー',

        'n'   => 'ん', 'nn'  => 'ん', "n'"=> 'ん',

        'kya' => 'きゃ', 'kyu' => 'きゅ', 'kyo' => 'きょ', 'kye' => 'きぇ', 'kyi' => 'きぃ',
        'gya' => 'ぎゃ', 'gyu' => 'ぎゅ', 'gyo' => 'ぎょ', 'gye' => 'ぎぇ', 'gyi' => 'ぎぃ',
        'kwa' => 'くぁ', 'kwi' => 'くぃ', 'kwu' => 'くぅ', 'kwe' => 'くぇ', 'kwo' => 'くぉ',
        'gwa' => 'ぐぁ', 'gwi' => 'ぐぃ', 'gwu' => 'ぐぅ', 'gwe' => 'ぐぇ', 'gwo' => 'ぐぉ',
        'qwa' => 'ぐぁ', 'gwi' => 'ぐぃ', 'gwu' => 'ぐぅ', 'gwe' => 'ぐぇ', 'gwo' => 'ぐぉ',

        'sya' => 'しゃ', 'syi' => 'しぃ', 'syu' => 'しゅ', 'sye' => 'しぇ', 'syo' => 'しょ',
        'sha' => 'しゃ',                  'shu' => 'しゅ', 'she' => 'しぇ', 'sho' => 'しょ',
        'ja'  => 'じゃ',                  'ju'  => 'じゅ', 'je'  => 'じぇ', 'jo'  => 'じょ',
        'jya' => 'じゃ', 'jyi' => 'じぃ', 'jyu' => 'じゅ', 'jye' => 'じぇ', 'jyo' => 'じょ',
        'zya' => 'じゃ', 'zyu' => 'じゅ', 'zyo' => 'じょ', 'zye' => 'じぇ', 'zyi' => 'じぃ',
        'swa' => 'すぁ', 'swi' => 'すぃ', 'swu' => 'すぅ', 'swe' => 'すぇ', 'swo' => 'すぉ',

        'cha' => 'ちゃ',                  'chu' => 'ちゅ', 'che' => 'ちぇ', 'cho' => 'ちょ',
        'cya' => 'ちゃ', 'cyi' => 'ちぃ', 'cyu' => 'ちゅ', 'cye' => 'ちぇ', 'cyo' => 'ちょ',
        'tya' => 'ちゃ', 'tyi' => 'ちぃ', 'tyu' => 'ちゅ', 'tye' => 'ちぇ', 'tyo' => 'ちょ',
        'dya' => 'ぢゃ', 'dyi' => 'ぢぃ', 'dyu' => 'ぢゅ', 'dye' => 'ぢぇ', 'dyo' => 'ぢょ',
        'tsa' => 'つぁ', 'tsi' => 'つぃ',                  'tse' => 'つぇ', 'tso' => 'つぉ',
        'tha' => 'てゃ', 'thi' => 'てぃ', 'thu' => 'てゅ', 'the' => 'てぇ', 'tho' => 'てょ',
        'twa' => 'とぁ', 'twi' => 'とぃ', 'twu' => 'とぅ', 'twe' => 'とぇ', 'two' => 'とぉ',
        'dha' => 'でゃ', 'dhi' => 'でぃ', 'dhu' => 'でゅ', 'dhe' => 'でぇ', 'dho' => 'でょ',
        'dwa' => 'どぁ', 'dwi' => 'どぃ', 'dwu' => 'どぅ', 'dwe' => 'どぇ', 'dwo' => 'どぉ',

        'nya' => 'にゃ', 'nyu' => 'にゅ', 'nyo' => 'にょ', 'nye' => 'にぇ', 'nyi' => 'にぃ',

        'hya' => 'ひゃ', 'hyi' => 'ひぃ', 'hyu' => 'ひゅ', 'hye' => 'ひぇ', 'hyo' => 'ひょ',
        'bya' => 'びゃ', 'byi' => 'びぃ', 'byu' => 'びゅ', 'bye' => 'びぇ', 'byo' => 'びょ',
        'pya' => 'ぴゃ', 'pyi' => 'ぴぃ', 'pyu' => 'ぴゅ', 'pye' => 'ぴぇ', 'pyo' => 'ぴょ',
        'fa'  => 'ふぁ', 'fi'  => 'ふぃ',                  'fe'  => 'ふぇ', 'fo'  => 'ふぉ',
        'fwa' => 'ふぁ', 'fwi' => 'ふぃ', 'fwu' => 'ふぅ', 'fwe' => 'ふぇ', 'fwo' => 'ふぉ',
        'fya' => 'ふゃ', 'fyi' => 'ふぃ', 'fyu' => 'ふゅ', 'fye' => 'ふぇ', 'fyo' => 'ふょ',

        'mya' => 'みゃ', 'myi' => 'みぃ', 'myu' => 'みゅ', 'mye' => 'みぇ', 'myo' => 'みょ',

        'rya' => 'りゃ', 'ryi' => 'りぃ', 'ryu' => 'りゅ', 'rye' => 'りぇ', 'ryo' => 'りょ',
        'lya' => 'りゃ', 'lyu' => 'りゅ', 'lyo' => 'りょ', 'lye' => 'りぇ', 'lyi' => 'りぃ',

        'va'  => 'ゔぁ', 'vi'  => 'ゔぃ', 'vu'  => 'ゔ',   've'  => 'ゔぇ',  'vo' => 'ゔぉ',
        'vya' => 'ゔゃ', 'vyi' => 'ゔぃ', 'vyu' => 'ゔゅ', 'vye' => 'ゔぇ', 'vyo' => 'ゔょ',
        'wha' => 'うぁ', 'whi' => 'うぃ', 'ye'  => 'いぇ', 'whe' => 'うぇ', 'who' => 'うぉ',

        'xa'  => 'ぁ', 'xi'   => 'ぃ', 'xu'  => 'ぅ', 'xe'  => 'ぇ', 'xo'   => 'ぉ',
        'xya' => 'ゃ', 'xyu'  => 'ゅ', 'xyo' => 'ょ',
        'xtu' => 'っ', 'xtsu' => 'っ',
        'xka' => 'ゕ', 'xke'  => 'ゖ', 'xwa' => 'ゎ',

        '@@' => '　', '#[' => '「', '#]' => '」', '#,' => '、', '#.' => '。', '#/' => '・',
      }

      attr_reader :tokens, :text

      def initialize(text)
        @tokens = []
        @text = text
      end

      def transliterate_from_hrkt_to_latn
        @text = transliterate_from_kana_to_hira
        transliterate_from_hira_to_latn
      end

      def transliterate_from_hira_to_latn
        # Hepburn style romaji
        kana = @text.dup
        romaji = ''
        geminate = false

        while kana.length > 0
          [2, 1].each do |length|
            mora = ''
            for_conversion = kana[0, length]

            if for_conversion == H_SMALL_TSU
              geminate = true
              kana[0, length] = ''
              break
            elsif for_conversion == H_SYLLABIC_N && kana[1, 1].match(/[やゆよ]/)
              # Syllabic N before ya, yu or yo
              mora = "n'"
            elsif HIRA_TO_LATN[for_conversion]
              # Generic cases
              mora = HIRA_TO_LATN[for_conversion]
            end

            if mora.length > 0
              if geminate
                geminate = false
                romaji << mora[0, 1]
              end
              romaji << mora
              kana[0, length] = ''
              break
            elsif length == 1
              # Nothing found
              romaji << for_conversion
              kana[0, length] = ''
            end
          end
        end

        return romaji
      end

      def transliterate_from_latn_to_hrkt
        romaji = @text.dup
        kana = ''

        romaji.gsub!(/m([BbPp])/, 'n\1')
        romaji.gsub!(/M([BbPp])/, 'N\1')

        while romaji.length > 0
          [3, 2, 1].each do |length|
            mora = ''
            for_removal = length
            for_conversion = romaji[0, length]
            is_upper = !!(for_conversion.match(/^\p{Upper}/))
            for_conversion.downcase!

            if for_conversion.match(/nn[aiueo]/)
              # nna should kanafy to んな instead of んあ
              # This is what people expect for words like konna, anna, zannen
              mora = H_SYLLABIC_N
              for_removal = 1
            elsif LATN_TO_HIRA[for_conversion]
              # Generic cases
              mora = LATN_TO_HIRA[for_conversion]
            elsif for_conversion == 'tch' || ( length == 2 && for_conversion.match(/([kgsztdnbpmyrlwchf])\1/))
              # tch and double-consonants for small tsu
              mora = H_SMALL_TSU
              for_removal = 1
            end

            if mora.length > 0
              if is_upper
                # Dance so we can call transliterate_from_hira_to_kana on internal data
                # TODO: Need a better way for this
                temp_text = @text
                @text = mora.dup
                kana << transliterate_from_hira_to_kana
                @text = temp_text
              else
                kana << mora
              end

              romaji[0, for_removal] = ''
              break
            elsif length == 1
              # Nothing found
              kana << for_conversion
              romaji[0, 1] = ''
            end
          end
        end

        return kana
      end

      def transliterate_from_kana_to_hira
        transpose_codepoints_in_range(@text, -96, 12449..12534)
      end

      def transliterate_from_hira_to_kana
        transpose_codepoints_in_range(@text, 96, 12353..12438)
      end

      def transliterate_from_fullwidth_to_halfwidth
        res = transpose_codepoints_in_range(@text, -65248, 65281..65374)
        transpose_codepoints_in_range(res, -12256, 12288..12288)
      end

      def transliterate_from_halfwidth_to_fullwidth
        res = transpose_codepoints_in_range(@text, 65248, 33..126)
        transpose_codepoints_in_range(res, 12256, 32..32)
      end

      private

      def transpose_codepoints_in_range(text, distance, range)
        result = ''

        text.each_codepoint do |c|
          if c >= range.first and c <= range.last
            result << (c + distance).chr(Encoding::UTF_8)
          else
            result << c.chr(Encoding::UTF_8)
          end
        end

        return result
      end

    end
  end
end

Ve::Manager.register(Ve::Provider::JapaneseTransliterators, :ja)

