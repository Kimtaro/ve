class Sprakd
  class PartOfSpeech
    
    def self.name
      self.to_s.split('::').last.downcase
    end
    
    class Noun < PartOfSpeech; end
    class ProperNoun < PartOfSpeech; end
    class Pronoun < PartOfSpeech; end
    class Adjective < PartOfSpeech; end
    class Adverb < PartOfSpeech; end
    class Determiner < PartOfSpeech; end
    class Preposition < PartOfSpeech; end
    class Postposition < PartOfSpeech; end
    class Verb < PartOfSpeech; end
    class Suffix < PartOfSpeech; end
    class Prefix < PartOfSpeech; end
    class Conjunction < PartOfSpeech; end
    class Interjection < PartOfSpeech; end
    class Number < PartOfSpeech; end
    class Unknown < PartOfSpeech; end
    class Symbol < PartOfSpeech; end
    class Determiner < PartOfSpeech; end
    class Other < PartOfSpeech; end

    class TBD < PartOfSpeech; end # Placeholder for provider PoS that haven't had a Sprakd PoS assigned yet
    
  end
end
