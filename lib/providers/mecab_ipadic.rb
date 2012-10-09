# Encoding: UTF-8

require 'open3'

class Ve
  class Provider
    class MecabIpadic < Ve::Provider

      BIT_STOP = 'VeEnd'
  
      def initialize(config = {})
        # TODO: Make config handling better
        @config = {:app => 'mecab',
                   :path => '',
                   :flags => ''}.merge(config)
    
        @config[:app] = `which #{@config[:app]}`
        
        start!
      end
  
      def works?
        (["だっ\t助動詞,*,*,*,特殊・ダ,連用タ接続,だ,ダッ,ダッ",
          "た\t助動詞,*,*,*,特殊・タ,基本形,た,タ,タ",
          "EOS"] == parse('だった').tokens.collect { |t| t[:raw] } )
      end
  
      # Talks to the app and returns a parse object
      def parse(text, options = {})
        start! if @stdin.nil? # Restart if the provider crashed
        
        @stdin.puts "#{text} #{BIT_STOP}"
        output = []
        
        while line = @stdout.readline.force_encoding('UTF-8')
          if line =~ /#{BIT_STOP}/x
            output << @stdout.readline # Catch the EOS
            break
          end
          output << line
        end
        
        Ve::Parse::MecabIpadic.new(text, output)
      rescue
        # TODO: No good to catch all errors like this
        # I need a backtrace when something unexpected fails
        Ve::Parse::MecabIpadic.new(text, [])
      end

      private
  
      # TODO: Use Process.spawn/kill for process control?
      def start!
        @stdin, @stdout, @stderr = Open3.popen3(@config[:app])
        @stdin.set_encoding('UTF-8')
        @stdout.set_encoding('UTF-8')
      rescue Errno::ENOENT
        # The parser couldn't be started. Probably not installed on this system
      end
  
    end
  end
end

class Ve
  class Parse
    class MecabIpadic < Ve::Parse
      
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
          if output.length > 1 && output.length == index + 1
            unparsed_md = %r{(.*? \Z\n?)}mx.match(text, position)
            if unparsed_md[1].length > 0
              unparsed_token = {:type => :unparsed, :literal => unparsed_md[1], :raw => ''}
              unparsed_token[:characters] = (position..(position+unparsed_token[:literal].length-1))
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
              unparsed_token[:characters] = (position..(position+unparsed_token[:literal].length-1))
              @tokens << unparsed_token
              position += unparsed_token[:literal].length
            end
            
            token[:characters] = (position..(position+token[:literal].length-1))
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
      KEIYOUSHI = '形容詞'

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
      TOKUSHU_NAI = '特殊・ナイ'
      TOKUSHU_TAI = '特殊・タイ'
      TOKUSHU_DESU = '特殊・デス'
      TOKUSHU_DA = '特殊・ダ'
      TOKUSHU_MASU = '特殊・マス'
      TOKUSHU_NU = '特殊・ヌ'
      FUHENKAGATA = '不変化型'
      JINMEI = '人名'

      # Etc
      NA = 'な'
      NI = 'に'
      TE = 'て'
      DE = 'で'
      BA = 'ば'
      NN = 'ん'
      SA = 'さ'

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
            eat_lemma = true
            attach_to_previous = false
            also_attach_to_lemma = false
            update_pos = false

            case token[:pos]
            when MEISHI
              pos = Ve::PartOfSpeech::Noun

              case token[:pos2]
              when KOYUUMEISHI
                pos = Ve::PartOfSpeech::ProperNoun
              when DAIMEISHI
                pos = Ve::PartOfSpeech::Pronoun
              when FUKUSHIKANOU, SAHENSETSUZOKU, KEIYOUDOUSHIGOKAN, NAIKEIYOUSHIGOKAN
                if tokens.more?
                  following = tokens.peek
                  if following[:inflection_type] == SAHEN_SURU
                    pos = Ve::PartOfSpeech::Verb
                    eat_next = true
                  elsif following[:inflection_type] == TOKUSHU_DA
                    pos = Ve::PartOfSpeech::Adjective
                    if following[:inflection_form] == TAIGENSETSUZOKU
                      eat_next = true
                      eat_lemma = false
                    end
                  elsif following[:inflection_type] == TOKUSHU_NAI
                    pos = Ve::PartOfSpeech::Adjective
                    eat_next = true
                  elsif following[:pos] == JOSHI && following[:literal] == NI
                    pos = Ve::PartOfSpeech::Adverb
                    eat_next = false
                  end
                end
              when HIJIRITSU, TOKUSHU
                if tokens.more?
                  following = tokens.peek
                  case token[:pos3]
                  when FUKUSHIKANOU
                    if following[:pos] == JOSHI && following[:literal] == NI
                      pos = Ve::PartOfSpeech::Adverb
                      eat_next = true
                    end
                  when JODOUSHIGOKAN
                    if following[:inflection_type] == TOKUSHU_DA
                      pos = Ve::PartOfSpeech::Verb
                      grammar = :auxillary
                      if following[:inflection_form] == TAIGENSETSUZOKU
                        eat_next = true
                      end
                    elsif following[:pos] == JOSHI && following[:pos2] == FUKUSHIKA
                      pos = Ve::PartOfSpeech::Adverb
                      eat_next = true
                    end
                  when KEIYOUDOUSHIGOKAN
                    pos = Ve::PartOfSpeech::Adjective
                    if (following[:inflection_type] == TOKUSHU_DA && following[:inflection_form] == TAIGENSETSUZOKU) || following[:pos2] == RENTAIKA
                      eat_next = true
                    end
                  end
                end
              when KAZU
                # TODO: recurse and find following numbers and add to this word. Except non-numbers like 幾
                pos = Ve::PartOfSpeech::Number
                if words.length > 0 && words[-1].part_of_speech == Ve::PartOfSpeech::Number
                  attach_to_previous = true
                  also_attach_to_lemma = true
                end
              when SETSUBI
                if token[:pos3] == TOKUSHU && token[:lemma] == SA
                  attach_to_previous = true
                  update_pos = true
                  pos = Ve::PartOfSpeech::Noun
                else
                  pos = Ve::PartOfSpeech::Suffix
                end
              when SETSUZOKUSHITEKI
                pos = Ve::PartOfSpeech::Conjunction
              when DOUSHIHIJIRITSUTEKI
                pos = Ve::PartOfSpeech::Verb
                grammar = :nominal
              end
            when SETTOUSHI
              # TODO: elaborate this when we have the "main part" feature for words?
              pos = Ve::PartOfSpeech::Prefix
            when JODOUSHI
              pos = Ve::PartOfSpeech::Postposition

              if [TOKUSHU_TA, TOKUSHU_NAI, TOKUSHU_TAI, TOKUSHU_MASU, TOKUSHU_NU].include?(token[:inflection_type])
                attach_to_previous = true
              elsif token[:inflection_type] == FUHENKAGATA && token[:lemma] == NN
                attach_to_previous = true
              elsif (token[:inflection_type] == TOKUSHU_DA || token[:inflection_type] == TOKUSHU_DESU) && token[:literal] != NA
                pos = Ve::PartOfSpeech::Verb
              end
            when DOUSHI
              pos = Ve::PartOfSpeech::Verb
              if token[:pos2] == SETSUBI
                attach_to_previous = true
              elsif token[:pos2] == HIJIRITSU
                attach_to_previous = true
              end
            when KEIYOUSHI
              pos = Ve::PartOfSpeech::Adjective
            when JOSHI
              pos = Ve::PartOfSpeech::Postposition
              if token[:pos2] == SETSUZOKUJOSHI && [TE, DE, BA].include?(token[:literal])
                attach_to_previous = true
              end
            when RENTAISHI
              pos = Ve::PartOfSpeech::Determiner
            when SETSUZOKUSHI
              pos = Ve::PartOfSpeech::Conjunction
            when FUKUSHI
              pos = Ve::PartOfSpeech::Adverb
            when KIGOU
              pos = Ve::PartOfSpeech::Symbol
            when FIRAA, KANDOUSHI
              pos = Ve::PartOfSpeech::Interjection
            when SONOTA
              pos = Ve::PartOfSpeech::Other
            else
              # C'est une catastrophe
            end

            if attach_to_previous && words.length > 0
              words[-1].tokens << token
              words[-1].word << token[:literal]
              words[-1].extra[:reading] << (token[:reading] || '')
              words[-1].extra[:transcription] << (token[:hatsuon] || '')
              words[-1].lemma << token[:lemma] if also_attach_to_lemma
              words[-1].part_of_speech = pos if update_pos
            else
              pos = Ve::PartOfSpeech::TBD if pos.nil?
              word = Ve::Word.new(token[:literal], token[:lemma], pos, [token], {
                :reading => token[:reading] || '',
                :transcription => token[:hatsuon] || '',
                :grammar => grammar
              }, {
                :reading_script => :kata,
                :transcription_script => :kata
              })

              if eat_next
                following = tokens.next
                word.tokens << following
                word.word << following[:literal]
                word.extra[:reading] << following[:reading]
                word.extra[:transcription] << following[:hatsuon]
                word.lemma << following[:lemma] if eat_lemma
              end

              words << word
            end
          end
        rescue StopIteration
        end

        return words
      end
      
      def sentences
        # TODO: Sentence objects that keep track of the sentence's tokens
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

Ve::Manager.register(Ve::Provider::MecabIpadic, :ja)

