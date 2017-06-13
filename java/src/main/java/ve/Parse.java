package ve;

import org.atilika.kuromoji.Token;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/** Copyright © 2017 Jamie Birch: [GitHub] shirakaba | [Twitter] LinguaBrowse
  * Released under MIT license (see LICENSE.txt at root of repository).
  *
  * A Java port of Kim Ahlström's Ruby code for Ve's Parse (which identifies word boundaries).
  **/
public class Parse {
    private final Token[] tokenArray;
    private static final String NO_DATA = "*";

    private static final int POS1 = 0;
    private static final int POS2 = 1;
    private static final int POS3 = 2;
    private static final int POS4 = 3;
    private static final int CTYPE = 4;
    private static final int CFORM = 5;
    private static final int BASIC = 6;
    private static final int READING = 7;
    private static final int PRONUNCIATION = 8;

    public Parse(Token[] tokenArray) {
        if(tokenArray.length == 0) throw new UnsupportedOperationException("Cannot parse an empty array of tokens.");

        this.tokenArray = tokenArray;
    }

    /**
     * @return List of all words in the instance's tokenArray, or an empty list if tokenArray was empty.
     *         Ve returns an asterisk if no word was recognised.
     *  */
    public List<Word> words(){
        List<Word> wordList = new ArrayList<>();
        Token current = null, previous = null, following = null;

        for(int i = 0; i < tokenArray.length; i++){
            int finalSlot = wordList.size() - 1;
            current = tokenArray[i];
            Pos pos = null; // could make this TBD instead.
            Grammar grammar = Grammar.Unassigned;
            boolean eat_next = false,
                    eat_lemma = true,
                    attach_to_previous = false,
                    also_attach_to_lemma = false,
                    update_pos = false;

            String[] currentPOSArray = Arrays.copyOfRange(current.getAllFeaturesArray(), POS1, POS4 +1);

            if(currentPOSArray.length == 0 || currentPOSArray[POS1].equals(NO_DATA))
                throw new IllegalStateException("No Pos data found for token.");

            switch (currentPOSArray[POS1]){
                case MEISHI:
//                case MICHIGO:
                    pos = Pos.Noun;
                    if(currentPOSArray[POS2].equals(NO_DATA)) break;
                    switch (currentPOSArray[POS2]){
                        case KOYUUMEISHI:
                            pos = Pos.ProperNoun;
                            break;
                        case DAIMEISHI:
                            pos = Pos.Pronoun;
                            break;
                        case FUKUSHIKANOU:
                        case SAHENSETSUZOKU:
                        case KEIYOUDOUSHIGOKAN:
                        case NAIKEIYOUSHIGOKAN:
                            // Refers to line 213 of Ve.
                            if(currentPOSArray[POS3].equals(NO_DATA)) break;
                            if(i == tokenArray.length -1) break; // protects against array overshooting.
                            following = tokenArray[i+1];
                            switch(following.getAllFeaturesArray()[CTYPE]){
                                case SAHEN_SURU:
                                    pos = Pos.Verb;
                                    eat_next = true;
                                    break;
                                case TOKUSHU_DA:
                                    pos = Pos.Adjective;
                                    if(Arrays.copyOfRange(following.getAllFeaturesArray(), POS1, POS4 +1)[POS2].equals(TAIGENSETSUZOKU)){
                                        eat_next = true;
                                        eat_lemma = false;
                                    }
                                    break;
                                case TOKUSHU_NAI:
                                    pos = Pos.Adjective;
                                    eat_next = true;
                                    break;
                                default:
                                    if(Arrays.copyOfRange(following.getAllFeaturesArray(), POS1, POS4 +1)[POS1].equals(JOSHI)
                                            && following.getSurfaceForm().equals(NI))
                                        pos = Pos.Adverb; // Ve script redundantly (I think) also has eat_next = false here.
                                    break;
                            }

                            break;
                        case HIJIRITSU:
                        case TOKUSHU:
                            // Refers to line 233 of Ve.
                            if(currentPOSArray[POS3].equals(NO_DATA)) break;
                            if(i == tokenArray.length -1) break; // protects against array overshooting.
                            following = tokenArray[i+1];

                            switch(currentPOSArray[POS3]){
                                case FUKUSHIKANOU:
                                    if(Arrays.copyOfRange(following.getAllFeaturesArray(), POS1, POS4 +1)[POS1].equals(JOSHI)
                                        && following.getSurfaceForm().equals(NI)){
                                        pos = Pos.Adverb;
                                        eat_next = false; // Changed this to false because 'case JOSHI' has 'attach_to_previous = true'.
                                    }
                                    break;
                                case JODOUSHIGOKAN:
                                    if(following.getAllFeaturesArray()[CTYPE].equals(TOKUSHU_DA)){
                                        pos = Pos.Verb;
                                     grammar = Grammar.Auxiliary;
                                        if(following.getAllFeaturesArray()[CFORM].equals(TAIGENSETSUZOKU)) eat_next = true;
                                    }
                                    else if (Arrays.copyOfRange(following.getAllFeaturesArray(), POS1, POS4 +1)[POS1].equals(JOSHI)
                                        && Arrays.copyOfRange(following.getAllFeaturesArray(), POS1, POS4 +1)[POS3].equals(FUKUSHIKA)){
                                        pos = Pos.Adverb;
                                        eat_next = true;
                                    }
                                    break;
                                case KEIYOUDOUSHIGOKAN:
                                    pos = Pos.Adjective;
                                    if(following.getAllFeaturesArray()[CTYPE].equals(TOKUSHU_DA) && following.getAllFeaturesArray()[CTYPE].equals(TAIGENSETSUZOKU)
                                            || Arrays.copyOfRange(following.getAllFeaturesArray(), POS1, POS4 +1)[POS2].equals(RENTAIKA))
                                        eat_next = true;
                                    break;
                                default:
                                    break;
                            }
                            break;
                        case KAZU:
                            // TODO: "recurse and find following numbers and add to this word. Except non-numbers like 幾"
                            // Refers to line 261.
                            pos = Pos.Number;
                            if(wordList.size() > 0 && wordList.get(finalSlot).getPart_of_speech().equals(Pos.Number)){
                                attach_to_previous = true;
                                also_attach_to_lemma = true;
                            }
                            break;
                        case SETSUBI:
                            // Refers to line 267.
                            if(currentPOSArray[POS3].equals(JINMEI)) pos = Pos.Suffix;
                            else{
                                if(currentPOSArray[POS3].equals(TOKUSHU) && current.getAllFeaturesArray()[BASIC].equals(SA)){
                                    update_pos = true;
                                    pos = Pos.Noun;
                                }
                                else also_attach_to_lemma = true;
                                attach_to_previous = true;
                            }
                            break;
                        case SETSUZOKUSHITEKI:
                            pos = Pos.Conjunction;
                            break;
                        case DOUSHIHIJIRITSUTEKI:
                            pos = Pos.Verb;
                            grammar = Grammar.Nominal; // not using.
                            break;
                        default:
                            // Keep Pos as Noun, as it currently is.
                            break;
                    }
                    break;
                case SETTOUSHI:
                    // TODO: "elaborate this when we have the "main part" feature for words?"
                    pos = Pos.Prefix;
                    break;
                case JODOUSHI:
                    // Refers to line 290.
                    pos = Pos.Postposition;
                    final List<String> qualifyingList1 = Arrays.asList(TOKUSHU_TA, TOKUSHU_NAI, TOKUSHU_TAI, TOKUSHU_MASU, TOKUSHU_NU);
                    if(previous == null || !Arrays.copyOfRange(previous.getAllFeaturesArray(), POS1, POS4 +1)[POS2].equals(KAKARIJOSHI)
                            && qualifyingList1.contains(current.getAllFeaturesArray()[CTYPE]))
                        attach_to_previous = true;
                    else if (current.getAllFeaturesArray()[CTYPE].equals(FUHENKAGATA) && current.getAllFeaturesArray()[BASIC].equals(NN))
                        attach_to_previous = true;
                    else if (current.getAllFeaturesArray()[CTYPE].equals(TOKUSHU_DA) || current.getAllFeaturesArray()[CTYPE].equals(TOKUSHU_DESU)
                            && !current.getSurfaceForm().equals(NA))
                        pos = Pos.Verb;
                    break;
                case DOUSHI:
                    // Refers to line 299.
                    pos = Pos.Verb;
                    switch (currentPOSArray[POS2]){
                        case SETSUBI:
                            attach_to_previous = true;
                            break;
                        case HIJIRITSU:
                            if(!current.getAllFeaturesArray()[CFORM].equals(MEIREI_I)) attach_to_previous = true;
                        default:
                            break;
                    }
                    break;
                case KEIYOUSHI:
                    pos = Pos.Adjective;
                    break;
                case JOSHI:
                    // Refers to line 309.
                    pos = Pos.Postposition;
                    final List<String> qualifyingList2 = Arrays.asList(TE, DE, BA); // added NI
                    if(currentPOSArray[POS2].equals(SETSUZOKUJOSHI) && qualifyingList2.contains(current.getSurfaceForm())
                            || current.getSurfaceForm().equals(NI))
                        attach_to_previous = true;
                    break;
                case RENTAISHI:
                    pos = Pos.Determiner;
                    break;
                case SETSUZOKUSHI:
                    pos = Pos.Conjunction;
                    break;
                case FUKUSHI:
                    pos = Pos.Adverb;
                    break;
                case KIGOU:
                    pos = Pos.Symbol;
                    break;
                case FIRAA:
                case KANDOUSHI:
                    pos = Pos.Interjection;
                    break;
                case SONOTA:
                    pos = Pos.Other;
                    break;
                default:
                    pos = Pos.TBD;
                    // C'est une catastrophe
            }

            if(attach_to_previous && wordList.size() > 0){
                // these sometimes try to add to null readings.
                wordList.get(finalSlot).getTokens().add(current);
                wordList.get(finalSlot).appendToWord(current.getSurfaceForm());
                wordList.get(finalSlot).appendToReading(getFeatureSafely(current, READING));
                wordList.get(finalSlot).appendToTranscription(getFeatureSafely(current, PRONUNCIATION));
                if(also_attach_to_lemma) wordList.get(finalSlot).appendToLemma(current.getAllFeaturesArray()[BASIC]); // lemma == basic.
                if(update_pos) wordList.get(finalSlot).setPart_of_speech(pos);
            }
            else {
                Word word = new Word(current.getReading(),
                        getFeatureSafely(current, PRONUNCIATION),
                        grammar,
                        current.getAllFeaturesArray()[BASIC],
                        pos,
                        current.getSurfaceForm(),
                        current);
                if(eat_next){
                    if(i == tokenArray.length -1) throw new IllegalStateException("There's a path that allows array overshooting.");
                    following = tokenArray[i+1];
                    word.getTokens().add(following);
                    word.appendToWord(following.getSurfaceForm());
                    word.appendToReading(following.getReading());
                    word.appendToTranscription(getFeatureSafely(following, PRONUNCIATION));
                    if (eat_lemma) word.appendToLemma(following.getAllFeaturesArray()[BASIC]);
                }
                wordList.add(word);
            }
            previous = current;

        }

        return wordList;
    }

    /** Return an asterisk if pronunciation field isn't in array (READING and PRONUNCIATION fields are left undefined,
      * rather than as "*" by MeCab). Other feature fields are guaranteed to be safe, however. */
    private String getFeatureSafely(Token token, int feature) {
        if(feature > PRONUNCIATION) throw new IllegalStateException("Asked for a feature out of bounds.");
        return token.getAllFeaturesArray().length >= feature + 1 ? token.getAllFeaturesArray()[feature] : "*";
    }

    // POS1
    private static final String MEISHI = "名詞";
    private static final String KOYUUMEISHI = "固有名詞";
    private static final String DAIMEISHI = "代名詞";
    private static final String JODOUSHI = "助動詞";
    private static final String KAZU = "数";
    private static final String JOSHI = "助詞";
    private static final String SETTOUSHI = "接頭詞";
    private static final String DOUSHI = "動詞";
    private static final String KIGOU = "記号";
    private static final String FIRAA = "フィラー";
    private static final String SONOTA = "その他";
    private static final String KANDOUSHI = "感動詞";
    private static final String RENTAISHI = "連体詞";
    private static final String SETSUZOKUSHI = "接続詞";
    private static final String FUKUSHI = "副詞";
    private static final String SETSUZOKUJOSHI = "接続助詞";
    private static final String KEIYOUSHI = "形容詞";
    private static final String MICHIGO = "未知語";

    // POS2_BLACKLIST and inflection types
    private static final String HIJIRITSU = "非自立";
    private static final String FUKUSHIKANOU = "副詞可能";
    private static final String SAHENSETSUZOKU = "サ変接続";
    private static final String KEIYOUDOUSHIGOKAN = "形容動詞語幹";
    private static final String NAIKEIYOUSHIGOKAN = "ナイ形容詞語幹";
    private static final String JODOUSHIGOKAN = "助動詞語幹";
    private static final String FUKUSHIKA = "副詞化";
    private static final String TAIGENSETSUZOKU = "体言接続";
    private static final String RENTAIKA = "連体化";
    private static final String TOKUSHU = "特殊";
    private static final String SETSUBI = "接尾";
    private static final String SETSUZOKUSHITEKI = "接続詞的";
    private static final String DOUSHIHIJIRITSUTEKI = "動詞非自立的";
    private static final String SAHEN_SURU = "サ変・スル";
    private static final String TOKUSHU_TA = "特殊・タ";
    private static final String TOKUSHU_NAI = "特殊・ナイ";
    private static final String TOKUSHU_TAI = "特殊・タイ";
    private static final String TOKUSHU_DESU = "特殊・デス";
    private static final String TOKUSHU_DA = "特殊・ダ";
    private static final String TOKUSHU_MASU = "特殊・マス";
    private static final String TOKUSHU_NU = "特殊・ヌ";
    private static final String FUHENKAGATA = "不変化型";
    private static final String JINMEI = "人名";
    private static final String MEIREI_I = "命令ｉ";
    private static final String KAKARIJOSHI = "係助詞";
    private static final String KAKUJOSHI = "格助詞";

    // etc
    private static final String NA = "な";
    private static final String NI = "に";
    private static final String TE = "て";
    private static final String DE = "で";
    private static final String BA = "ば";
    private static final String NN = "ん";
    private static final String SA = "さ";

}
