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

    /** Based on https://hondou.homedns.org/pukiwiki/index.php?cmd=read&page=Java%20SEN%20%A4%C7%B7%C1%C2%D6%C1%C7%B2%F2%C0%CF
     */
    @Test
    public void coreUsage() {
        String kanji = "金がなければくよくよします女に振られりゃなきまする\n"
                + "腹が減ったらおまんま食べて命尽きればあの世行き\n"
                + "有難や有難や\n";
        List<Token> tokensList = Tokenizer.builder().build().tokenize(kanji);
        Token[] tokensArray = tokensList.toArray(new Token[tokensList.size()]);

        Parse parser = new Parse(tokensArray);
        List<Word> words = parser.words();
        System.out.println(words);

        /*  Prints out:
            [金, が, なけれ, ば, くよくよ, します, 女に, 振られりゃなき, まする,
            , 腹, が, 減ったら, お, まんま, 食べ, て, 命, 尽きれ, ば, あの世行き,
            , 有難, や, 有難, や,
            ]
        */

        /* Note: I have found that, depending on the MeCab dictionary/model, POS-tagging of tokens may vary.
           ie: when tokenizing using net.java.sen:
               なけれ is labelled as a DOUSHI-JITATSU-*-*.
           However, when tokenizing using org.atilika.kuromoji:
               なけれ is labelled as a KEIYOUSHI-JITATSU-*-*.
        */
    }
}
