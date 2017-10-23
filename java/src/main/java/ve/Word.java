package ve;

import org.atilika.kuromoji.Token;

import java.util.ArrayList;
import java.util.List;

/** Copyright © 2017 Jamie Birch: [GitHub] shirakaba | [Twitter] LinguaBrowse
 * Released under MIT license (see LICENSE.txt at root of repository).
 *
 * A Word is composed of one or more Tokens, as stored in an internal List.
 * It also has various fields like 'reading' and 'transcription', which may
 * build up as extra Tokens are added to the list.
 * Words are identified and built up by this project's Parse.words() method.
 **/
public class Word {
//    These five seem underdeveloped and underpopulated:
    private String reading;
    private String transcription;
    private Grammar grammar;
//    private String reading_script;
//    private String transcription_script;
    private String lemma; // "聞く"
    private Pos part_of_speech; // eg. Pos.Noun
    private List<Token> tokens = new ArrayList<>(); // those which were eaten up by this one word: {聞か, せ, られ}
    private String word; // "聞かせられ"

    /**
     * Incoming variables are named in the style of Sen; fields are named in the style of Ve.
     * @param read - call token.getReading().
     * @param pronunciation - call token.getPronunciation().
     * @param grammar - this is an underdeveloped enum-like variable originating from Ve.
     * @param basic - call token.getBasicString().
     * @param part_of_speech - this is another underdeveloped enum-like variable originating from Ve.
     * @param nodeStr - call token.getNodeStr().
     * @param token - pass in a Token composing part of the Word. Currently expects the Token to come from Sen, but could
     *              be simply adapted to come from Kuromoji.
     */
    public Word(String read,
                String pronunciation,
                Grammar grammar,
//                String reading_script,
//                String transcription_script,
                String basic,
                Pos part_of_speech,
                String nodeStr,
                Token token) {
        this.reading = read;
        this.transcription = pronunciation;
        this.grammar = grammar;
//        this.reading_script = reading_script;
//        this.transcription_script = transcription_script;
        this.lemma = basic;
        this.part_of_speech = part_of_speech;
        this.word = nodeStr;
        tokens.add(token);
    }

    public void setPart_of_speech(Pos part_of_speech) {
        this.part_of_speech = part_of_speech;
    }

    public String getLemma() {
        return lemma;
    }

    public Pos getPart_of_speech() {
        return part_of_speech;
    }

    public List<Token> getTokens() {
        return tokens;
    }

    public String getWord() {
        return word;
    }

    public void appendToWord(String suffix) {
        if(word == null) word = "_".concat(suffix); // likely won't experience a null word, actually.
        else word = word.concat(suffix);
    }

    public void appendToReading(String suffix) {
        if(reading == null) reading = "_".concat(suffix);
        else reading = reading.concat(suffix);
    }

    public void appendToTranscription(String suffix) {
        if(transcription == null) transcription = "_".concat(suffix);
        else transcription = transcription.concat(suffix);
    }

    // Not sure when this would change.
    public void appendToLemma(String suffix) {
        if(lemma == null) lemma = "_".concat(suffix);
        else lemma = lemma.concat(suffix);
    }

    @Override
    public String toString() {
        return word;
    }
}
