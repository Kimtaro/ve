Ve
==

A linguistic framework for anyone. No degree required.

Ruby
----

    require 've'
    words = Ve.in(:en).words('I like melons.')
    # => [#<Ve::Word:0x8ee00cc @word="I", @lemma="i", @part_of_speech=Ve::PartOfSpeech::Pronoun, @tokens=[{:raw=>"I i PRP 1", :type=>:parsed, :literal=>"I", :lemma=>"i", :pos=>"PRP", :accuracy=>"1", :characters=>0..0}], @extra={:grammar=>:personal}, @info={}>, #<Ve::Word:0x8edff28 @word="like", @lemma="like", @part_of_speech=Ve::PartOfSpeech::Preposition, @tokens=[{:raw=>"like like IN 0.815649", :type=>:parsed, :literal=>"like", :lemma=>"like", :pos=>"IN", :accuracy=>"0.815649", :characters=>2..5}], @extra={:grammar=>nil}, @info={}>, #<Ve::Word:0x8edfe24 @word="melons", @lemma="melon", @part_of_speech=Ve::PartOfSpeech::Noun, @tokens=[{:raw=>"melons melon NNS 1", :type=>:parsed, :literal=>"melons", :lemma=>"melon", :pos=>"NNS", :accuracy=>"1", :characters=>7..12}], @extra={:grammar=>:plural}, @info={}>, #<Ve::Word:0x8edfcbc @word=".", @lemma=".", @part_of_speech=Ve::PartOfSpeech::Symbol, @tokens=[{:raw=>". . Fp 1", :type=>:parsed, :literal=>".", :lemma=>".", :pos=>"Fp", :accuracy=>"1", :characters=>13..13}], @extra={:grammar=>nil}, @info={}>]
    
    words.collect(&:lemma) # => ["i", "like", "melon", "."]
    words.collect(&:part_of_speec) # => [Ve::PartOfSpeech::Pronoun, Ve::PartOfSpeech::Preposition, Ve::PartOfSpeech::Noun, Ve::PartOfSpeech::Symbol]

Javascript
----------

    <script type="text/javascript" charset="utf-8" src="ve.js"></script>
    <script type="text/javascript" charset="utf-8">
      Ve('ja').words('ビールがおいしかった', function(words) {
        // [{"_class":"Word","word":"ビール","lemma":"ビール","part_of_speech":"noun","tokens":[{"raw":"ビール\t名詞,一般,*,*,*,*,ビール,ビール,ビール","type":"parsed","literal":"ビール","pos":"名詞","pos2":"一般","pos3":"*","pos4":"*","inflection_type":"*","inflection_form":"*","lemma":"ビール","reading":"ビール","hatsuon":"ビール","characters":"0..2"}],"extra":{"reading":"ビール","transcription":"ビール","grammar":null},"info":{"reading_script":"kata","transcription_script":"kata"}},{"_class":"Word","word":"が","lemma":"が","part_of_speech":"postposition","tokens":[{"raw":"が\t助詞,格助詞,一般,*,*,*,が,ガ,ガ","type":"parsed","literal":"が","pos":"助詞","pos2":"格助詞","pos3":"一般","pos4":"*","inflection_type":"*","inflection_form":"*","lemma":"が","reading":"ガ","hatsuon":"ガ","characters":"3..3"}],"extra":{"reading":"ガ","transcription":"ガ","grammar":null},"info":{"reading_script":"kata","transcription_script":"kata"}},{"_class":"Word","word":"おいしい","lemma":"おいしい","part_of_speech":"adjective","tokens":[{"raw":"おいしい\t形容詞,自立,*,*,形容詞・イ段,基本形,おいしい,オイシイ,オイシイ","type":"parsed","literal":"おいしい","pos":"形容詞","pos2":"自立","pos3":"*","pos4":"*","inflection_type":"形容詞・イ段","inflection_form":"基本形","lemma":"おいしい","reading":"オイシイ","hatsuon":"オイシイ","characters":"4..7"}],"extra":{"reading":"オイシイ","transcription":"オイシイ","grammar":null},"info":{"reading_script":"kata","transcription_script":"kata"}}]
        
        $.each(words, function(i,w) { 
          console.log(w.lemma + "/" + w.part_of_speech)
        });
        // ビール/noun
        // が/postposition
        // おいしい/adjective
      });
    </script>

Structure
---------

- **Ve::LocalInterface** - Main interface that gives access to functionality in providers that exist locally
- **Ve::XInterface** - Allows for different ways of accessing Ve providers. Locally, through an HTTP API, binary protocol or whatever
- **Ve::Manager** - Keeps track of providers and what they can do
- **Ve::Provider::X** - Talks to the underlying parser
- **Ve::Parse::X** - Takes the output from the Provider and turns it into functions the end user can use

Todo
----

- Alias lemma to base, so people don't need to know what lemmas are
- Break out into separate projects for each component. Ve-ruby, Ve-js.
- Expose more through the sinatra server
- Better UTF-8 handling for Freeling
- See all the TODO's in the code
