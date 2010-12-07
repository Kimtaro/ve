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
  
      def start!
        @stdin, @stdout, @stderr = Open3.popen3(@config[:app])
        @is_working = works?
      rescue
        @is_working = false
      end
  
      def works?
        (["だっ\t助動詞,*,*,*,特殊・ダ,連用タ接続,だ,ダッ,ダッ\n",
          "た\t助動詞,*,*,*,特殊・タ,基本形,た,タ,タ\n",
          "EOS\n"] == parse('だった'))
      end
  
      private
  
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
        
        output
      end
      
    end
  end
end
