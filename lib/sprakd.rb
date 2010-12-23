$: << File.expand_path(File.dirname(__FILE__))

require 'misc'
require 'word'
require 'part_of_speech'
require 'languages/english'
require 'languages/japanese'
require 'providers/fallbacks'
require 'providers/mecab_ipadic'
require 'providers/freeling_en'

class Sprakd
end
