package com.palavracruzada.model;

public class WordEntry {
    private final String word;
    private final String clue;
    private final String category;

    public WordEntry(String word, String clue, String category) {
        this.word = word;
        this.clue = clue;
        this.category = category;
    }

    public String getWord() {
        return word;
    }

    public String getClue() {
        return clue;
    }

    public String getCategory() {
        return category;
    }
}
