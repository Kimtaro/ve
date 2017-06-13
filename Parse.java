import net.java.sen.Token;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * A Java port of the Ruby code for Ve's Parse (which identifies word boundaries). Has dependency on Sen.
 */
public class Parse {
    private final Token[] tokenArray;
    private static final String NO_DATA = "*";

    private static final int POS = 0;
    private static final int POS2 = 1;
    private static final int POS3 = 2;
    private static final int POS4 = 3;

    public Parse(Token[] tokenArray) {
        if(tokenArray.length == 0) throw new UnsupportedOperationException("Cannot parse an empty array of tokens.");

        this.tokenArray = tokenArray;
//        setup();
    }

    /** Note: most of these methods, notably including setBasicString, are allegedly thread unsafe. */
    private void setup(){
        for (Token token : tokenArray) {                      // Ve.rb field name;   "Sen.java field name";
            token.setTermInfo(token.getTermInfo());           // raw;                "termInfo";           動詞,自立,*,*,五段・カ行イ音便,未然形,聞く,キカ,キカ
//          token.setNodeStr(token.getSurface());             // literal;            "nodeStr";            聞か
            token.setPos(token.getPos());                     // pos-pos2-pos3-pos4; "pos";                動詞-自立
            token.setCform(token.getCform());                 // inflection_form;    "cform";              未然形
            token.setBasicString(token.getBasicString());     // lemma;              "basic";              聞く
            token.setReading(token.getReading());             // reading;            "read";               キカ
            token.setPronunciation(token.getPronunciation()); // hatsuon;            "pronunciation";      キカ
         // token.setAddInfo(token.getAddInfo());             // N/A;                 "addInfo";            Actually hardcoded to return "".
         // token.setCost(token.getCost());                   // N/A;                 "cost";               [3205]
         // token.getNode().toString() would return the whole input phrase for tokenisation, but getNode() doesn't exist.
        }
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

            if(current.getPosArray().length == 0 || current.getPosArray()[POS].equals(NO_DATA))
                throw new IllegalStateException("No Pos data found for token.");

            switch (current.getPosArray()[POS]){
                case MEISHI:
//                case MICHIGO:
                    pos = Pos.Noun;
                    if(current.getPosArray()[POS2].equals(NO_DATA)) break;
                    switch (current.getPosArray()[POS2]){
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
                            if(current.getPosArray()[POS3].equals(NO_DATA)) break;
                            if(i == tokenArray.length -1) break; // protects against array overshooting.
                            following = tokenArray[i+1];
                            switch(following.getCType()){
                                case SAHEN_SURU:
                                    pos = Pos.Verb;
                                    eat_next = true;
                                    break;
                                case TOKUSHU_DA:
                                    pos = Pos.Adjective;
                                    if(following.getCform().equals(TAIGENSETSUZOKU)){
                                        eat_next = true;
                                        eat_lemma = false;
                                    }
                                    break;
                                case TOKUSHU_NAI:
                                    pos = Pos.Adjective;
                                    eat_next = true;
                                    break;
                                default:
                                    if(following.getPosArray()[POS].equals(JOSHI) && following.getNodeStr().equals(NI))
                                        pos = Pos.Adverb; // Ve script redundantly (I think) also has eat_next = false here.
                                    break;
                            }

                            break;
                        case HIJIRITSU:
                        case TOKUSHU:
                            // Refers to line 233 of Ve.
                            if(current.getPosArray()[POS3].equals(NO_DATA)) break;
                            if(i == tokenArray.length -1) break; // protects against array overshooting.
                            following = tokenArray[i+1];

                            switch(current.getPosArray()[POS3]){
                                case FUKUSHIKANOU:
                                    if(following.getPosArray()[POS].equals(JOSHI) && following.getNodeStr().equals(NI)){
                                        pos = Pos.Adverb;
                                        eat_next = false; // Changed this to false because 'case JOSHI' has 'attach_to_previous = true'.
                                    }
                                    break;
                                case JODOUSHIGOKAN:
                                    if(following.getCType().equals(TOKUSHU_DA)){
                                        pos = Pos.Verb;
                                     grammar = Grammar.Auxiliary;
                                        if(following.getCform().equals(TAIGENSETSUZOKU)) eat_next = true;
                                    }
                                    else if (following.getPosArray()[POS].equals(JOSHI)
                                        && following.getPosArray()[POS3].equals(FUKUSHIKA)){
                                        pos = Pos.Adverb;
                                        eat_next = true;
                                    }
                                    break;
                                case KEIYOUDOUSHIGOKAN:
                                    pos = Pos.Adjective;
                                    if(following.getCType().equals(TOKUSHU_DA) && following.getCType().equals(TAIGENSETSUZOKU)
                                            || following.getPosArray()[POS2].equals(RENTAIKA))
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
                            if(current.getPosArray()[POS3].equals(JINMEI)) pos = Pos.Suffix;
                            else{
                                if(current.getPosArray()[POS3].equals(TOKUSHU) && current.getBasicString().equals(SA)){
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
                    if(previous == null || !previous.getPosArray()[POS2].equals(KAKARIJOSHI)
                            && qualifyingList1.contains(current.getCType()))
                        attach_to_previous = true;
                    else if (current.getCType().equals(FUHENKAGATA) && current.getBasicString().equals(NN))
                        attach_to_previous = true;
                    else if (current.getCType().equals(TOKUSHU_DA) || current.getCType().equals(TOKUSHU_DESU)
                            && !current.getNodeStr().equals(NA))
                        pos = Pos.Verb;
                    break;
                case DOUSHI:
                    // Refers to line 299.
                    pos = Pos.Verb;
                    switch (current.getPosArray()[POS2]){
                        case SETSUBI:
                            attach_to_previous = true;
                            break;
                        case HIJIRITSU:
                            if(!current.getCform().equals(MEIREI_I)) attach_to_previous = true;
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
                    if(current.getPosArray()[POS2].equals(SETSUZOKUJOSHI) && qualifyingList2.contains(current.getNodeStr())
                            || current.getNodeStr().equals(NI))
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
                wordList.get(finalSlot).appendToWord(current.getNodeStr()); // literal == nodeStr.
                wordList.get(finalSlot).appendToReading(current.getReading()); // need to test when no read/pron data available.
                wordList.get(finalSlot).appendToTranscription(current.getPronunciation());
                if(also_attach_to_lemma) wordList.get(finalSlot).appendToLemma(current.getBasicString()); // lemma == basic.
                if(update_pos) wordList.get(finalSlot).setPart_of_speech(pos);
            }
            else {
                Word word = new Word(current.getReading(),
                        current.getPronunciation(),
                        grammar,
                        current.getBasicString(),
                        pos,
                        current.getNodeStr(),
                        current);
                if(eat_next){
                    if(i == tokenArray.length -1) throw new IllegalStateException("There's a path that allows array overshooting.");
                    following = tokenArray[i+1];
                    word.getTokens().add(following);
                    word.appendToWord(following.getNodeStr());
                    word.appendToReading(following.getReading());
                    word.appendToTranscription(following.getPronunciation());
                    if (eat_lemma) word.appendToLemma(following.getBasicString());
                }
                wordList.add(word);
            }
            previous = current;

        }

        return wordList;
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