class Ve
  class Word
    
    attr_accessor :word, :lemma, :part_of_speech, :tokens, :extra, :info
    
    # TODO: More elegance
    def initialize(word, lemma, part_of_speech, tokens, extra = {}, info = {})
      @word = word.dup
      @lemma = lemma.dup
      @part_of_speech = part_of_speech
      @tokens = tokens
      
      # TODO: I don't like this, it's too unstructured
      @extra = extra
      @info = info
    end
    
    # TODO: the main part of a word, for example 重要 in 重要な
    def main_part
    end

    def base_form
      @lemma
    end
    
    def inflected?
      @word != @lemma
    end

    def as_json
      {
        :_class => 'Word',
        :word => @word,
        :lemma => @lemma,
        :part_of_speech => @part_of_speech.name,
        :tokens => @tokens,
        :extra => @extra,
        :info => @info
      }
    end
    
  end
end
