# Encoding: UTF-8

# TODO: Retain capitalization in lemmas?
# TODO: Memoize

require 'open3'

class Sprakd
  class Provider
    class FreelingEn < Sprakd::Provider

      BIT_STOP = 'SprakdEnd'
  
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
        
        Sprakd::Parse::FreelingEn.new(text, output)
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

class Sprakd
  class Parse
    class FreelingEn < Sprakd::Parse
      
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
        'CC' => [Sprakd::PartOfSpeech::Conjunction, nil],
        'CD' => [Sprakd::PartOfSpeech::Number, nil],
        'DT' => [Sprakd::PartOfSpeech::Determiner, nil],
        'EX' => [Sprakd::PartOfSpeech::Pronoun, nil],
        'FW' => [Sprakd::PartOfSpeech::Unknown, nil],
        'IN' => [Sprakd::PartOfSpeech::Preposition, nil],
        'JJ' => [Sprakd::PartOfSpeech::Adjective, nil],
        'JJR' => [Sprakd::PartOfSpeech::Conjunction, :comparative],
        'JJS' => [Sprakd::PartOfSpeech::Conjunction, :superlative],
        'LS' => [Sprakd::PartOfSpeech::Unknown, nil],
        'MD' => [Sprakd::PartOfSpeech::Verb, :modal],
        'NN' => [Sprakd::PartOfSpeech::Noun, nil],
        'NNS' => [Sprakd::PartOfSpeech::Noun, :plural],
        'NNP' => [Sprakd::PartOfSpeech::ProperNoun, nil],
        'NNPS' => [Sprakd::PartOfSpeech::ProperNoun, :plural],
        'PDT' => [Sprakd::PartOfSpeech::Determiner, nil],
        'PRP' => [Sprakd::PartOfSpeech::Pronoun, :personal],
        'PRP$' => [Sprakd::PartOfSpeech::Pronoun, :possessive],
        'RB' => [Sprakd::PartOfSpeech::Adverb, nil],
        'RBR' => [Sprakd::PartOfSpeech::Adverb, :comparative],
        'RBS' => [Sprakd::PartOfSpeech::Adverb, :superlative],
        'RP' => [Sprakd::PartOfSpeech::Postposition, nil],
        'SYM' => [Sprakd::PartOfSpeech::Symbol, nil],
        'TO' => [Sprakd::PartOfSpeech::Preposition, nil],
        'UH' => [Sprakd::PartOfSpeech::Interjection, nil],
        'VB' => [Sprakd::PartOfSpeech::Verb, nil],
        'VBD' => [Sprakd::PartOfSpeech::Verb, :past],
        'VBG' => [Sprakd::PartOfSpeech::Verb, :present_participle],
        'VBN' => [Sprakd::PartOfSpeech::Verb, :past_participle],
        'VBP' => [Sprakd::PartOfSpeech::Verb, nil],
        'VBZ' => [Sprakd::PartOfSpeech::Verb, nil],
        'WDT' => [Sprakd::PartOfSpeech::Determiner, nil],
        'WP' => [Sprakd::PartOfSpeech::Pronoun, nil],
        'WP$' => [Sprakd::PartOfSpeech::Pronoun, :possessive],
        'WRB' => [Sprakd::PartOfSpeech::Adverb, nil],
        'Z' => [Sprakd::PartOfSpeech::Determiner, nil]
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
              pos = Sprakd::PartOfSpeech::Symbol
            end

            pos = Sprakd::PartOfSpeech::TBD if pos.nil?
            word = Sprakd::Word.new(token[:literal], token[:lemma], pos, [token], {:grammar => grammar})
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

Sprakd::Manager.register(Sprakd::Provider::FreelingEn, :en)

