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

      attr_reader :tokens, :text

      def initialize(text)
        @tokens = []
        @text = text
      end

      def transliterate_from_kana_to_latn
        return @text
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

    end
  end
end

Sprakd::Manager.register(Sprakd::Provider::Transliterators, :ja)

