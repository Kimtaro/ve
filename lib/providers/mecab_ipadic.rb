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
      SETTOUSHI = '接頭詞'
      DOUSHI = '動詞'
      KIGOU = '記号'
      FIRAA = 'フィラー'
      SONOTA = 'その他'
      KANDOUSHI = '感動詞'
      RENTAISHI = '連体詞'
      SETSUZOKUSHI = '接続詞'
      FUKUSHI = '副詞'
      SETSUZOKUJOSHI = '接続助詞'

      # Pos2 and Inflection types
      HIJIRITSU = '非自立'
      FUKUSHIKANOU = '副詞可能'
      SAHENSETSUZOKU = 'サ変接続'
      KEIYOUDOUSHIGOKAN = '形容動詞語幹'
      NAIKEIYOUSHIGOKAN = 'ナイ形容詞語幹'
      JODOUSHIGOKAN = '助動詞語幹'
      FUKUSHIKA = '副詞化'
      TAIGENSETSUZOKU = '体言接続'
      RENTAIKA = '連体化'
      TOKUSHU = '特殊'
      SETSUBI = '接尾'
      SETSUZOKUSHITEKI = '接続詞的'
      DOUSHIHIJIRITSUTEKI = '動詞非自立的'
      SAHEN_SURU = 'サ変・スル'
      TOKUSHU_TA = '特殊・タ'
      TOKUSHU_DA = '特殊・ダ'
      TOKUSHU_NAI = '特殊・ナイ'

      # Etc
      NI = 'に'
      TE = 'て'

      def words
        words = []
        tokens = @tokens.find_all { |t| t[:type] == :parsed }
        tokens = tokens.to_enum

        # This is becoming very big
        begin
          while token = tokens.next
            pos = nil
            grammar = nil
            eat_next = false
            attach_to_previous = false
            also_attach_to_lemma = false

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
                    eat_next = true
                  elsif following[:inflection_type] == TOKUSHU_DA
                    pos = Sprakd::PartOfSpeech::Adjective
                    if following[:inflection_form] == TAIGENSETSUZOKU
                      eat_next = true
                    end
                  elsif following[:inflection_type] == TOKUSHU_NAI
                    pos = Sprakd::PartOfSpeech::Adjective
                    eat_next = true
                  elsif following[:pos] == JOSHI && following[:literal] == NI
                    pos = Sprakd::PartOfSpeech::Adverb
                    eat_next = true
                  end
                end
              when HIJIRITSU, TOKUSHU
                if tokens.more?
                  following = tokens.peek
                  case token[:pos3]
                  when FUKUSHIKANOU
                    if following[:pos] == JOSHI && following[:literal] == NI
                      pos = Sprakd::PartOfSpeech::Adverb
                      eat_next = true
                    end
                  when JODOUSHIGOKAN
                    if following[:inflection_type] == TOKUSHU_DA
                      pos = Sprakd::PartOfSpeech::Verb
                      grammar = :auxillary
                      if following[:inflection_form] == TAIGENSETSUZOKU
                        eat_next = true
                      end
                    elsif following[:pos] == JOSHI && following[:pos2] == FUKUSHIKA
                      pos = Sprakd::PartOfSpeech::Adverb
                      eat_next = true
                    end
                  when KEIYOUDOUSHIGOKAN
                    pos = Sprakd::PartOfSpeech::Adjective
                    if (following[:inflection_type] == TOKUSHU_DA && following[:inflection_form] == TAIGENSETSUZOKU) || following[:pos2] == RENTAIKA
                      eat_next = true
                    end
                  end
                end
              when KAZU
                # TODO: recurse and find following numbers and add to this word. Except non-numbers like 幾
                pos = Sprakd::PartOfSpeech::Number
                if words.length > 0 && words[-1].part_of_speech == Sprakd::PartOfSpeech::Number
                  attach_to_previous = true
                  also_attach_to_lemma = true
                end
              when SETSUBI
                # TODO: elaborate a bit?
                pos = Sprakd::PartOfSpeech::Suffix
              when SETSUZOKUSHITEKI
                pos = Sprakd::PartOfSpeech::Conjunction
              when DOUSHIHIJIRITSUTEKI
                pos = Sprakd::PartOfSpeech::Verb
                grammar = :nominal
              end
            when SETTOUSHI
              # TODO: elaborate this when we have the "main part" feature for words?
              pos = Sprakd::PartOfSpeech::Prefix
            when JODOUSHI
              pos = Sprakd::PartOfSpeech::Postposition

              if token[:inflection_type] == TOKUSHU_TA || token[:inflection_type] == TOKUSHU_NAI
                attach_to_previous = true
              end
            when DOUSHI
              pos = Sprakd::PartOfSpeech::Verb
              if token[:pos2] == SETSUBI
                attach_to_previous = true
              elsif token[:pos2] == HIJIRITSU
                grammar = :auxillary
              end
            when JOSHI
              if token[:pos2] == SETSUZOKUJOSHI && token[:literal] == TE
                attach_to_previous = true
              end
            when RENTAISHI
              pos = Sprakd::PartOfSpeech::Determiner
            when SETSUZOKUSHI
              pos = Sprakd::PartOfSpeech::Conjunction
            when FUKUSHI
              pos = Sprakd::PartOfSpeech::Adverb
            when KIGOU
              pos = Sprakd::PartOfSpeech::Symbol
            when FIRAA, KANDOUSHI
              pos = Sprakd::PartOfSpeech::Interjection
            when SONOTA
              pos = Sprakd::PartOfSpeech::Other
            else
              # C'est une catastrophe
            end

            if attach_to_previous && words.length > 0
              words[-1].tokens << token
              words[-1].word << token[:literal]
              words[-1].lemma << token[:lemma] if also_attach_to_lemma
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

