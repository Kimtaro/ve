$: << File.expand_path(File.dirname(__FILE__))

require 'misc'
require 'word'
require 'part_of_speech'
require 'languages/english'
require 'languages/japanese'
require 'pp'

class Ve
  class Manager
    @@config_for = {}

    def self.set_default_config_for(klass, config = {})
      @@config_for[klass] = config
    end

    def self.provider_for(language, function)
      provider = @@provider_for[language.to_sym][function.to_sym]
      if provider.is_a?(Class)
        config = @@config_for[provider] || {}
        provider = @@provider_for[language.to_sym][function.to_sym].new(config)
        @@provider_for[language.to_sym][function.to_sym] = provider
      end
      provider
    end

    def self.languages
      @@provider_for.keys
    end

    def self.functions_for_language(language)
      @@provider_for[language.to_sym].keys
    end

    # TODO: Make a difference between what features are available locally
    # and what requires contacting external Ves
    def self.register(klass, language)
      @@provider_for ||= {}
      # This won't work if people start monkey patching the providers with public methods that arent abilities
      # It's also not pretty, but kinda nifty
      provider_name = klass.to_s.split('::').last
      parse_class = Kernel.class_eval("Ve::Parse::#{provider_name}")
      abilities = parse_class.public_instance_methods - Object.public_instance_methods
      abilities.each do |a|
        @@provider_for[language.to_sym] ||= {}
        @@provider_for[language.to_sym][a] = klass
      end
    end
  end

  # TODO: Put into separate files
  class LocalInterface
    def initialize(language, config = {})
      @language = language
    end

    def method_missing(function, *args)
      provider = Ve::Manager.provider_for(@language, function)
      parse = provider.parse(args[0])
      parse.send(function.to_sym)
    end
  end

  class HTTPInterface
    require 'net/http'
    require 'uri'
    require 'json'

    def initialize(language, config = {})
      @language = language
      @base_url = config[:url]
    end

    def method_missing(function, *args)
      url = "#{@base_url}/#{@language}/#{function}"
      uri = URI.parse(url)
      response = Net::HTTP.post_form(uri, {:text => args[0]})
      data = JSON.parse(response.body)
      result = []

      data.each do |obj|
        # TODO: Support transliterations
        case obj['_class']
        when 'Word'
          result << Ve::Word.new(obj['word'], obj['lemma'], obj['part_of_speech'], obj['tokens'], obj['extra'], obj['info'])
        end
      end

      result
    end
  end

  @@interface = Ve::LocalInterface
  @@interface_for = {}
  @@config = {}

  # End-users only interact with this class, so it must provide a sexy interface
  # to all functionality in the providers and parse objects

  # Basic, non-sexy, local interface only
  def self.get(text, language, function, *args)
    provider = Ve::Manager.provider_for(language, function, *args)
    parse = provider.parse(text, args)
    parse.send(function.to_sym)
  end

  # Early sexy verision
  def self.in(language)
    unless @@interface_for[language]
      @@interface_for[language] = @@interface.new(language, @@config)
    end

    @@interface_for[language]
  end

  def self.config(interface, config)
    @@interface = interface
    @@config = config
  end
end

# TODO: Autoload this shit
require 'providers/fallbacks'
require 'providers/mecab_ipadic'
require 'providers/mecab_unidic'
require 'providers/freeling_en'
require 'providers/japanese_transliterators'

