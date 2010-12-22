class Sprakd
  class Word
    
    attr_accessor :word, :lemma, :part_of_speech, :grammar
    
    def initialize(word, lemma, part_of_speech, grammar = nil)
      @word = word
      @lemma = lemma
      @part_of_speech = part_of_speech
      @grammar = grammar
    end
    
    def base_form
      @lemma
    end
    
    def inflected?
      @word != @lemma
    end
    
  end
end
