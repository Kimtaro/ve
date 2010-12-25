$: << File.expand_path(File.dirname(__FILE__))

require 'misc'
require 'word'
require 'part_of_speech'
require 'languages/english'
require 'languages/japanese'
require 'pp'

class Sprakd

  def self.get(text, language, function)
    provider = Sprakd::Manager.provider_for(language, function)
    parse = provider.parse(text)
    parse.send(function.to_sym)
  end

  class Manager

    def self.provider_for(language, function)
      @@provider_for[language.to_sym][function.to_sym]
    end

    def self.register(klass, language, functions)
      @@provider_for ||= {}
      provider = klass.new
      functions.each do |f|
        @@provider_for[language.to_sym] ||= {}
        @@provider_for[language.to_sym][f.to_sym] = provider
      end
    end

  end

end

require 'providers/fallbacks'
require 'providers/mecab_ipadic'
require 'providers/freeling_en'

