class Sprakd
  class Word
    
    attr_accessor :word, :lemma, :part_of_speech, :grammar, :tokens
    
    def initialize(word, lemma, part_of_speech, tokens, grammar = nil)
      @word = word.dup
      @lemma = lemma.dup
      @part_of_speech = part_of_speech
      @tokens = tokens
      @grammar = grammar
    end
    
    def base_form
      @lemma
    end
    
    def inflected?
      @word != @lemma
    end

    def as_json
      {
        :word => @word,
        :lemma => @lemma,
        :part_of_speech => @part_of_speech.name
      }
    end
    
  end
end
