Ve
==

A linguistic framework for anyone. No degree required.

Ve was originally created as a general wrapper for linguistic analyzer programs, to provide a unified interface and abstraction of linguistic concepts, so non-linguists could benefit from linguistic analysis.

In reality what Ve has become most used for, is splitting Japanese text into words through the MeCab analyzer with the IPADIC dictionary.

The Japanese word splitting part of Ve has been ported from Ruby into several other programming languages. I am immensely grateful to the folks who have written these ports 💚

| Language  | Repository |
| ------------- | ------------- |
| Ruby  | This repo.  |
| Javascript  | This repo. Must be used with Ruby HTTP server. |
| Java | This repo. By https://github.com/shirakaba |
| .Net 5 | https://github.com/luojunyuan/Ve.DotNet |
| Dart | https://github.com/lrorpilla/ve_dart |
| Scala | https://github.com/megafarad/Ve-scala |
| Rust | https://github.com/jannisbecker/ve-rs |

Getting Started
---------------

Ve relies on the [FreeLing](http://nlp.lsi.upc.edu/freeling/) and [MeCab](http://mecab.googlecode.com/svn/trunk/mecab/doc/index.html)
language parsers. You **must** install FreeLing for English or MeCab for Japanese or both.

Installation instructions for FreeLing can be found [here](http://nlp.lsi.upc.edu/freeling/index.php?option=com_content&task=view&id=15&Itemid=44).

Installation instruction for MeCab can be found [here](https://taku910.github.io/mecab/#install).

### Installing with HomeBrew

If you are using OSX, you can easily install FreeLing and MeCab with [HomeBrew](http://brew.sh/).

```
$ brew install freeling
$ brew install mecab-ipadic
```

### Building the Gem

You can build the Ve gem with the following:

```
$ gem build ve.gemspec
```

To install the newly built gem:

```
$ gem install ve-<version>.gem
```

Be sure to substitute `<version>` with the version of the newly built gem, for example `ve-0.0.3.gem`.

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
      new Ve('ja').words('ビールがおいしかった', function(words) {
        // [{"_class":"Word","word":"ビール","lemma":"ビール","part_of_speech":"noun","tokens":[{"raw":"ビール\t名詞,一般,*,*,*,*,ビール,ビール,ビール","type":"parsed","literal":"ビール","pos":"名詞","pos2":"一般","pos3":"*","pos4":"*","inflection_type":"*","inflection_form":"*","lemma":"ビール","reading":"ビール","hatsuon":"ビール","characters":"0..2"}],"extra":{"reading":"ビール","transcription":"ビール","grammar":null},"info":{"reading_script":"kata","transcription_script":"kata"}},{"_class":"Word","word":"が","lemma":"が","part_of_speech":"postposition","tokens":[{"raw":"が\t助詞,格助詞,一般,*,*,*,が,ガ,ガ","type":"parsed","literal":"が","pos":"助詞","pos2":"格助詞","pos3":"一般","pos4":"*","inflection_type":"*","inflection_form":"*","lemma":"が","reading":"ガ","hatsuon":"ガ","characters":"3..3"}],"extra":{"reading":"ガ","transcription":"ガ","grammar":null},"info":{"reading_script":"kata","transcription_script":"kata"}},{"_class":"Word","word":"おいしい","lemma":"おいしい","part_of_speech":"adjective","tokens":[{"raw":"おいしい\t形容詞,自立,*,*,形容詞・イ段,基本形,おいしい,オイシイ,オイシイ","type":"parsed","literal":"おいしい","pos":"形容詞","pos2":"自立","pos3":"*","pos4":"*","inflection_type":"形容詞・イ段","inflection_form":"基本形","lemma":"おいしい","reading":"オイシイ","hatsuon":"オイシイ","characters":"4..7"}],"extra":{"reading":"オイシイ","transcription":"オイシイ","grammar":null},"info":{"reading_script":"kata","transcription_script":"kata"}}]

        for ( i in words ) {
          var word = words[i];
          console.log(word.lemma + "/" + word.part_of_speech)
        }

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

- Expose more through the sinatra server
- Alias lemma to base, so people don't need to know what lemmas are
- Break out into separate projects for each component. Ve-ruby, Ve-js.
- Better UTF-8 handling for Freeling
- See all the TODO's in the code

License
-------

(c) Kim Ahlström 2011-2023

This is under the MIT license.
