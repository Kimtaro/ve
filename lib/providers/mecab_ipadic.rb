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
  
      # Provided services
  
  
  
      # Interface methods
  
      def provides
        {:language => :ja,
         :features => [:words, :sentences, :parts_of_speech, :morphological_info]}
      end

      def works?
        (["だっ\t助動詞,*,*,*,特殊・ダ,連用タ接続,だ,ダッ,ダッ",
          "た\t助動詞,*,*,*,特殊・タ,基本形,た,タ,タ",
          "EOS"] == parse('だった').tokens.collect { |t| t[:raw] })
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
            [:pos, :i1, :i2, :i3, :katsuyougata, :katsuyoukei, :lemma, :yomi, :hatsuon].each_with_index do |attr, i|
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
      
      # TODO: Memoize
      def words
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
