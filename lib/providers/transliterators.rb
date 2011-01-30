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
        return 'X'
      end

    end
  end
end

Sprakd::Manager.register(Sprakd::Provider::Transliterators, :ja)

