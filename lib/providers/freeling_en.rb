# Encoding: UTF-8

require 'open3'

class Sprakd
  class Provider
    class FreelingEn < Sprakd::Provider

      BIT_STOP = 'SprakdEnd'
  
      def initialize(config = {})
        @config = {:app => 'analyzer',
                   :path => '',
                   :flags => ''}.merge(config)
    
        @config[:app] = `which #{@config[:app]}`.strip!
        local = @config[:app] =~ /local/ ? '/local' : ''
        @config[:flags] = "-f /usr#{local}/share/FreeLing/config/en.cfg --flush"
        
        @is_working = false        
        start!
      end
  
      # Provided services
  
  
  
      # Interface methods
  
      def provides
        {:language => :en,
         :features => [:words, :sentences, :parts_of_speech]}
      end

      def works?
        (["Wrote write VBD 1", ""] == parse('Wrote').tokens.collect { |t| t[:raw] })
      end
  
      # Talks to the app and returns a parse object
      def parse(text)
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
          if output.size > 1 && output.size == index + 1
            unparsed_md = %r{(.*? \Z\n?)}mx.match(text, position)
            if unparsed_md[1].length > 0
              unparsed_token = {:type => :unparsed, :literal => unparsed_md[1], :raw => ''}
              @tokens << unparsed_token
            end
          end
            
          # Sentence splits are just empty lines in Freeling
          if line.size == 0
            token[:type] = :sentence_split
            token[:literal] = ''
            @tokens << token
            next
          end
          
          # The parsed token
          info = line.split(/\s/)
          token[:type] = :parsed
          [:literal, :lemma, :pos, :accuracy].each_with_index do |attr, i|
            token[attr] = info[i]
          end
          
          # Anything unparsed preceding this token
          unparsed_md = %r{(.*?) #{Regexp.quote(token[:literal])}}mx.match(text, position)
          if unparsed_md && unparsed_md[1].length > 0
            unparsed_token = {:type => :unparsed, :literal => unparsed_md[1]}
            @tokens << unparsed_token
            position += unparsed_token[:literal].length
          end

          position += token[:literal].length
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
