# Encoding: UTF-8

# TODO: Retain capitalization in lemmas?
# TODO: Memoize

require 'open3'

class Ve
  class Provider
    class FreelingEn < Ve::Provider

      BIT_STOP = 'VeEnd'
  
      # TODO: Automatically set FREELINGSHARE if it's not set?
      def initialize(config = {})
        @config = {:app => 'analyzer',
                   :path => '',
                   :flags => ''}.merge(config)
    
        @config[:app] = `which #{@config[:app]}`.strip!
        local = @config[:app] =~ /local/ ? '/local' : ''
        @config[:flags] = "-f /usr#{local}/share/FreeLing/config/en.cfg --flush --nonumb --nodate"
        
        @is_working = false        
        start!
      end
  
      # Interface methods
  
      def works?
        (["Wrote write VBD 1", ""] == parse('Wrote').tokens.collect { |t| t[:raw] })
      end
  
      # Talks to the app and returns a parse object
      def parse(text, options = {})
        return text if @stdin.nil?
        
        # Fix Unicode chars
        # TODO: These need to be converted back to the original char in the :literal attribute
        text = text.gsub('’', "'")
        
        @stdin.puts "#{text}\n#{BIT_STOP}\n"
        output = []
        
        while line = @stdout.readline
          if line =~ /#{BIT_STOP}/x
            @stdout.readline
            break
          end
          output << line
        end
        
        Ve::Parse::FreelingEn.new(text, output)
      end

      private
  
      def start!
        @stdin, @stdout, @stderr = Open3.popen3("#{@config[:app]} #{@config[:flags]}")
        
        # TODO: Also filter out non-iso-latin-1 characters
        @stdin.set_encoding('UTF-8', 'ISO-8859-1')
        @stdout.set_encoding('ISO-8859-1', 'UTF-8')
        
        @is_working = works?
      rescue
        @is_working = false
      end
  
    end
  end
end

class Ve
  class Parse
    class FreelingEn < Ve::Parse
      
      attr_reader :tokens, :text
      
      def initialize(text, output)
        @tokens = []
        @text = text
        position = 0
        
        output.each_with_index do |line, index|
          line.rstrip!
          token = {:raw => line}

          # Anything unparsed at the end of the text
          # This must happen before sentence splits are detected to avoid funny ordering
          if output.length > 1 && output.length == index + 1
            unparsed_md = %r{(.*? \Z\n?)}mx.match(text, position)
            if unparsed_md[1].length > 0
              unparsed_token = {:type => :unparsed,
                                :literal => unparsed_md[1],
                                :raw => ''}
              unparsed_token[:characters] = (position..(position+unparsed_token[:literal].length-1))
              @tokens << unparsed_token
            end
          end
            
          # Sentence splits are just empty lines in Freeling
          if line.length == 0
            token[:type] = :sentence_split
            token[:literal] = ''
            @tokens << token
            next
          end
          
          # The parsed token
          info = line.split(/\s+/)
          token[:type] = :parsed
          [:literal, :lemma, :pos, :accuracy].each_with_index do |attr, i|
            token[attr] = info[i]
          end

          token[:literal].gsub!('_', ' ')
          token[:lemma].gsub!('_', ' ')
          
          # Anything unparsed preceding this token.
          # We need to do this complicated dance with _ since Freeling replaces spaces with it.
          # And so we need to be able to find the token with both spaces and _ in it since
          # we don't know what the original in the text actually is.
          # Once we have the location in the text we can figure out if it should be with spaces or _.
          unparsed_re = %r{(.*?) #{Regexp.quote(token[:literal])}}mx
          unparsed_re = %r{#{unparsed_re.to_s.gsub('_', '[\s_]')}}
          unparsed_md = unparsed_re.match(text, position)
          if unparsed_md && unparsed_md[1].length > 0
            unparsed_token = {:type => :unparsed, :literal => unparsed_md[1]}
            unparsed_token[:characters] = (position..(position+unparsed_token[:literal].length-1))
            @tokens << unparsed_token
            position += unparsed_token[:literal].length
          end

          token[:characters] = (position..(position+token[:literal].length-1))
          position += token[:literal].length
          @tokens << token
        end
      end
      
      INTERNAL_INFO_FOR_PARSED_POS = {
        'CC' => [Ve::PartOfSpeech::Conjunction, nil],
        'CD' => [Ve::PartOfSpeech::Number, nil],
        'DT' => [Ve::PartOfSpeech::Determiner, nil],
        'EX' => [Ve::PartOfSpeech::Pronoun, nil],
        'FW' => [Ve::PartOfSpeech::Unknown, nil],
        'IN' => [Ve::PartOfSpeech::Preposition, nil],
        'JJ' => [Ve::PartOfSpeech::Adjective, nil],
        'JJR' => [Ve::PartOfSpeech::Conjunction, :comparative],
        'JJS' => [Ve::PartOfSpeech::Conjunction, :superlative],
        'LS' => [Ve::PartOfSpeech::Unknown, nil],
        'MD' => [Ve::PartOfSpeech::Verb, :modal],
        'NN' => [Ve::PartOfSpeech::Noun, nil],
        'NNS' => [Ve::PartOfSpeech::Noun, :plural],
        'NNP' => [Ve::PartOfSpeech::ProperNoun, nil],
        'NNPS' => [Ve::PartOfSpeech::ProperNoun, :plural],
        'PDT' => [Ve::PartOfSpeech::Determiner, nil],
        'PRP' => [Ve::PartOfSpeech::Pronoun, :personal],
        'PRP$' => [Ve::PartOfSpeech::Pronoun, :possessive],
        'RB' => [Ve::PartOfSpeech::Adverb, nil],
        'RBR' => [Ve::PartOfSpeech::Adverb, :comparative],
        'RBS' => [Ve::PartOfSpeech::Adverb, :superlative],
        'RP' => [Ve::PartOfSpeech::Postposition, nil],
        'SYM' => [Ve::PartOfSpeech::Symbol, nil],
        'TO' => [Ve::PartOfSpeech::Preposition, nil],
        'UH' => [Ve::PartOfSpeech::Interjection, nil],
        'VB' => [Ve::PartOfSpeech::Verb, nil],
        'VBD' => [Ve::PartOfSpeech::Verb, :past],
        'VBG' => [Ve::PartOfSpeech::Verb, :present_participle],
        'VBN' => [Ve::PartOfSpeech::Verb, :past_participle],
        'VBP' => [Ve::PartOfSpeech::Verb, nil],
        'VBZ' => [Ve::PartOfSpeech::Verb, nil],
        'WDT' => [Ve::PartOfSpeech::Determiner, nil],
        'WP' => [Ve::PartOfSpeech::Pronoun, nil],
        'WP$' => [Ve::PartOfSpeech::Pronoun, :possessive],
        'WRB' => [Ve::PartOfSpeech::Adverb, nil],
        'Z' => [Ve::PartOfSpeech::Determiner, nil]
      }
      
      def words
        words = []
        
        @tokens.find_all { |t| t[:type] == :parsed }.each do |token|
          if token[:pos] == 'POS'
            # Possessive ending, add to previous token
            words[-1].word << token[:literal]
            words[-1].tokens << token
            next
          else
            # All other tokens
            pos, grammar = INTERNAL_INFO_FOR_PARSED_POS[token[:pos]]

            if pos.nil? && token[:pos] =~ /^F\w+$/
              pos = Ve::PartOfSpeech::Symbol
            end

            pos = Ve::PartOfSpeech::TBD if pos.nil?
            word = Ve::Word.new(token[:literal], token[:lemma], pos, [token], {:grammar => grammar})
            words << word
          end
        end
        
        words
      end
      
      def sentences
        sentences = []
        current = ''
        
        @tokens.each do |token|
          if token[:type] == :sentence_split
            sentences << current
            current = ''
          else
            current << token[:literal]
          end
        end
        
        # In case there is no :sentence_split at the end
        sentences << current if current.length > 0

        sentences.collect { |s| s.strip! }
        sentences
      end
        
    end
  end
end

Ve::Manager.register(Ve::Provider::FreelingEn, :en)

