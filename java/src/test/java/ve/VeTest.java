package ve;

import org.atilika.kuromoji.Token;
import org.atilika.kuromoji.Tokenizer;
import org.junit.Test;

import java.util.List;

/** Copyright © 2017 Jamie Birch: [GitHub] shirakaba | [Twitter] LinguaBrowse
  * Released under MIT license (see LICENSE.txt at root of repository).
  *
  * This test is purely to show the console output; it is unconditional.
  **/
public class VeTest {

    /** More hardcore test sentence at: https://hondou.homedns.org/pukiwiki/index.php?cmd=read&page=Java%20SEN%20%A4%C7%B7%C1%C2%D6%C1%C7%B2%F2%C0%CF
     */
    @Test
    public void coreUsage() {
        String kanji = "お金がなければいけないです。";
        List<Token> tokensList = Tokenizer.builder().build().tokenize(kanji);
        Token[] tokensArray = tokensList.toArray(new Token[tokensList.size()]);

        Parse parser = new Parse(tokensArray);
        List<Word> words = parser.words();
        System.out.println(words);

        /*  Prints out:
            [お金, が, なければいけない, です, 。]
        */

        /* Note: I have found that, depending on the MeCab dictionary/model, POS-tagging of tokens may vary.
           ie: for a particular sentence, when tokenizing using net.java.sen:
               なけれ is labelled as a DOUSHI-JITATSU-*-*.
           However, when tokenizing using org.atilika.kuromoji:
               なけれ is labelled as a KEIYOUSHI-JITATSU-*-*.
           So your mileage may vary (very slightly) if comparing to other tokenizer results..!
           Not the Ve algorithm's fault, fortunately.
        */
    }
}
