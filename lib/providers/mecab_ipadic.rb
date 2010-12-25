# Encoding: UTF-8

require 'open3'

class Sprakd
  class Provider
    class MecabIpadic < Sprakd::Provider

      BIT_STOP = 'SprakdEnd'
  
      def initialize(config = {})
        # TODO: Make config handling better
        @config = {:app => 'mecab',
                   :path => '',
                   :flags => ''}.merge(config)
    
        @config[:app] = `which #{@config[:app]}`
        @is_working = false
        
        start!
      end
  
      def works?
        (["だっ\t助動詞,*,*,*,特殊・ダ,連用タ接続,だ,ダッ,ダッ",
          "た\t助動詞,*,*,*,特殊・タ,基本形,た,タ,タ",
          "EOS"] == parse('だった').tokens.collect { |t| t[:raw] } )
      end
  
      # Talks to the app and returns a parse object
      def parse(text)
        @stdin.puts "#{text} #{BIT_STOP}"
        output = []
        
        while line = @stdout.readline
          if line =~ /#{BIT_STOP}/x
            output << @stdout.readline # Catch the EOS
            break
          end
          output << line
        end
        
        Sprakd::Parse::MecabIpadic.new(text, output)
      end

      private
  
      def start!
        @stdin, @stdout, @stderr = Open3.popen3(@config[:app])
        @is_working = works?
      rescue
        @is_working = false
      end
  
    end
  end
end

class Sprakd
  class Parse
    class MecabIpadic < Sprakd::Parse
      
      PARSER = %r{^ (.+?) \t (.+) }x
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
          if output.size > 1 && output.size == index + 1
            unparsed_md = %r{(.*? \Z\n?)}mx.match(text, position)
            if unparsed_md[1].length > 0
              unparsed_token = {:type => :unparsed, :literal => unparsed_md[1], :raw => ''}
              @tokens << unparsed_token
            end
          end
          
          if line =~ %r{^ EOS $}x
            token[:type] = :sentence_split
            token[:literal] = ''
          elsif md = PARSER.match(line)
            # The parsed token
            token[:type] = :parsed
            token[:literal] = md[1]
            info = md[2].split(',')
            [:pos, :pos2, :pos3, :pos4, :inflection_type, :inflection_form, :lemma, :reading, :hatsuon].each_with_index do |attr, i|
              token[attr] = info[i]
            end
            
            # Anything unparsed preceding this token
            unparsed_md = %r{(.*?) #{Regexp.quote(token[:literal])}}mx.match(text, position)
            if unparsed_md[1].length > 0
              unparsed_token = {:type => :unparsed, :literal => unparsed_md[1]}
              @tokens << unparsed_token
              position += unparsed_token[:literal].length
            end
            
            position += token[:literal].length
          else
            # C'est une catastrophe
          end

          @tokens << token
        end
      end
      
      # PoS
      MEISHI = '名詞'
      KOYUUMEISHI = '固有名詞'
      DAIMEISHI = '代名詞'
      JODOUSHI = '助動詞'
      KAZU = '数'
      JOSHI = '助詞'

      # Pos2 and Inflection types
      FUKUSHIKANOU = '副詞可能'
      SAHENSETSUZOKU = 'サ変接続'
      KEIYOUDOUSHIGOKAN = '形容動詞語幹'
      NAIKEIYOUSHIGOKAN = 'ナイ形容詞語幹'
      SAHEN_SURU = 'サ変・スル'
      TOKUMI_TA = '特殊・タ'
      TOKUMI_DA = '特殊・ダ'
      TOKUMI_NAI = '特殊・ナイ'

      # Etc
      NI = 'に'

      def words
        words = []
        tokens = @tokens.find_all { |t| t[:type] == :parsed }
        tokens = tokens.to_enum

        begin
          while token = tokens.next
            pos = nil
            grammar = nil
            eat_next = false
            attach_to_previous = false

            case token[:pos]
            when MEISHI
              pos = Sprakd::PartOfSpeech::Noun

              case token[:pos2]
              when KOYUUMEISHI
                pos = Sprakd::PartOfSpeech::ProperNoun
              when DAIMEISHI
                pos = Sprakd::PartOfSpeech::Pronoun
              when FUKUSHIKANOU, SAHENSETSUZOKU, KEIYOUDOUSHIGOKAN, NAIKEIYOUSHIGOKAN
                if tokens.more?
                  following = tokens.peek
                  if following[:inflection_type] == SAHEN_SURU
                    pos = Sprakd::PartOfSpeech::Verb
                  elsif following[:inflection_type] == TOKUMI_DA
                    pos = Sprakd::PartOfSpeech::Adjective
                  elsif following[:inflection_type] == TOKUMI_NAI
                    pos = Sprakd::PartOfSpeech::Adjective
                  elsif following[:pos] == JOSHI && following[:literal] == NI
                    pos = Sprakd::PartOfSpeech::Adverb
                  end
                  eat_next = true
                end
              when KAZU
                pos = Sprakd::PartOfSpeech::Number
              end
            when JODOUSHI
              pos = Sprakd::PartOfSpeech::Postposition

              if token[:inflection_type] == TOKUMI_TA
                words[-1].tokens << token
                words[-1].word << token[:literal]
                next
              end
            else
              # C'est une catastrophe
            end

            if attach_to_previous
              words[-1].tokens << token
              words[-1].word << token[:literal]
              words[-1].lemma << token[:lemma]
            else
              pos = Sprakd::PartOfSpeech::TBD if pos.nil?
              word = Sprakd::Word.new(token[:literal], token[:lemma], pos, [token], grammar)

              if eat_next
                following = tokens.next
                word.tokens << following
                word.word << following[:literal]
                word.lemma << following[:lemma]
              end

              words << word
            end
          end
        rescue StopIteration
        end

        return words
      end
      
      def sentences
        sentences = []
        current = ''
        
        @tokens.each do |token|
          if token[:type] == :sentence_split
            sentences << current
            current = ''
          elsif token[:literal] == '。'
            current << token[:literal]
            sentences << current
            current = ''
          else
            current << token[:literal]
          end
        end
        
        # In case there is no :sentence_split at the end
        sentences << current if current.length > 0
        
        sentences
      end
      
    end
  end
end

Sprakd::Manager.register(Sprakd::Provider::MecabIpadic, :ja, [:words, :sentences])

