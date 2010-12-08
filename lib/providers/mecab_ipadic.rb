# Encoding: UTF-8

require 'open3'

class Sprakd
  class Provider
    class MecabIpadic < Sprakd::Provider

      BIT_STOP = 'SprakdEnd'
  
      def initialize(config = {})
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
        (["だっ\t助動詞,*,*,*,特殊・ダ,連用タ接続,だ,ダッ,ダッ\n",
          "た\t助動詞,*,*,*,特殊・タ,基本形,た,タ,タ\n",
          "EOS\n"] == parse('だった').tokens.collect { |t| t[:raw] })
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
        
        output.each do |line|
          token = {:raw => line}
          
          if line =~ %r{^ EOS $}x
            token[:type] = :sentence_split
          else
            token[:type] = :token
            PARSER.match(line) do |md|
              token[:literal] = md[1]
              info = md[2].split(',')
              [:pos, :i1, :i2, :i3, :katsuyougata, :katsuyoukei, :lemma, :yomi, :hatsuon].each_with_index do |attr, i|
                token[attr] = info[i]
              end
            end
          end

          @tokens << token
        end
      end
      
      # TODO: Memoize
      def words
      end
        
    end
  end
end
