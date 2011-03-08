# Encoding: UTF-8

require 'open3'

class Sprakd
  class Provider
    class Transliterators < Sprakd::Provider

      def initialize(config = {})
      end

      def works?
        true
      end

      def parse(text, options = {})
        Sprakd::Parse::Transliterators.new(text)
      end

    end
  end
end

class Sprakd
  class Parse
    class Transliterators < Sprakd::Parse

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
        "ゑ"=>"wye", "ゐ"=>"wyi", "ー"=>"-", "ん"=>"n",

        "きゃ"=>"kya", "きゅ"=>"kyu", "きょ"=>"kyo", "きぇ"=>"kye", "きぃ"=>"kyi",
        "ぎゃ"=>"gya", "ぎゅ"=>"gyu", "ぎょ"=>"gyo", "ぎぇ"=>"gye", "ぎぃ"=>"gyi",
        "くぁ"=>"kwa", "くぃ"=>"kwi", "くぅ"=>"kwu", "くぇ"=>"kwe", "くぉ"=>"kwo",
        "ぐぁ"=>"qwa", "ぐぃ"=>"gwi", "ぐぅ"=>"gwu", "ぐぇ"=>"gwe", "ぐぉ"=>"gwo",
        "しゃ"=>"sha", "しぃ"=>"syi", "しゅ"=>"shu", "しぇ"=>"she", "しょ"=>"sho",
        "じゃ"=>"jya", "じゅ"=>"zyu", "じぇ"=>"zye", "じょ"=>"zyo", "じぃ"=>"zyi",
        "すぁ"=>"swa", "すぃ"=>"swi", "すぅ"=>"swu", "すぇ"=>"swe", "すぉ"=>"swo",
        "ちゃ"=>"tya", "ちゅ"=>"tyu", "ちぇ"=>"tye", "ちょ"=>"tyo", "ちぃ"=>"tyi",
        "ぢゃ"=>"dya", "ぢぃ"=>"dyi", "ぢゅ"=>"dyu", "ぢぇ"=>"dye", "ぢょ"=>"dyo",
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

      attr_reader :tokens, :text

      def initialize(text)
        @tokens = []
        @text = text
      end

      # TODO:
      def transliterate_from_latn_to_hira
        @text
      end
      
      # TODO: How to deal with inter-provider dependencies?
      # TODO: hani is language independent (hanzi + kanji + hanja)
      def transliterate_from_hani_to_latn
        @text
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

            if for_conversion == 'っ'
              geminate = true
              kana[0, length] = ''
              break
            elsif for_conversion == 'ん' && kana[1, 1].match(/[やゆよ]/)
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
      
      def transliterate_from_hira_to_kata
        kata = ''

        @text.each_codepoint do |c|
          if c >= 12353 and c <= 12438
            kata << (c + 96).chr(Encoding::UTF_8)
          else
            kata << c.char(Encoding::UTF_8)
          end
        end

        return kata
      end
      
      def transliterate_from_kata_to_hira
        hira = ''

        @text.each_codepoint do |c|
          if c >= 12449 and c <= 12534
            hira << (c - 96).chr(Encoding::UTF_8)
          else
            hira << c.chr(Encoding::UTF_8)
          end
        end

        return hira
      end

      # TODO: test
      def transliterate_from_kana_to_latn
        @text = transliterate_from_kata_to_hira
        transliterate_from_hira_to_latn
      end
      
    end
  end
end

Sprakd::LocalInterface::Manager.register(Sprakd::Provider::Transliterators, :ja)

