$: << File.expand_path(File.dirname(__FILE__))

require 'misc'
require 'word'
require 'part_of_speech'
require 'languages/english'
require 'languages/japanese'
require 'pp'

class Sprakd
  
  # End-users only interact with this class, so it must provide a sexy interface
  # to all functionality in the providers and parse objects
  
  # Basic, non-sexy
  def self.get(text, language, function, *args)
    provider = Sprakd::Manager.provider_for(language, function, *args)
    parse = provider.parse(text, args)
    parse.send(function.to_sym)
  end
  
  

  class Manager

    def self.provider_for(language, function)
      @@provider_for[language.to_sym][function.to_sym]
    end

    # TODO: Make a difference between what features are available locally
    # and what requires contacting external Sprakds
    def self.register(klass, language)
      @@provider_for ||= {}
      provider = klass.new
      # This won't work if people start monkey patching the providers with public methods that arent abilities
      # It's also not pretty, but kinda nifty
      provider_name = provider.class.to_s.split('::').last
      parse_class = Kernel.class_eval("Sprakd::Parse::#{provider_name}")
      abilities = parse_class.public_instance_methods - Object.public_instance_methods
      abilities.each do |a|
        @@provider_for[language.to_sym] ||= {}
        @@provider_for[language.to_sym][a] = provider
      end
    end

  end

end

# Autoload this shit
require 'providers/fallbacks'
require 'providers/mecab_ipadic'
require 'providers/freeling_en'
require 'providers/transliterators'

