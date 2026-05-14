package com.palavracruzada.model;

import java.util.Collections;
import java.util.List;

public class CrosswordGame {
    private final char[][] board;
    private final List<PlacedWord> placedWords;

    public CrosswordGame(char[][] board, List<PlacedWord> placedWords) {
        this.board = board;
        this.placedWords = placedWords;
    }

    public char[][] getBoard() {
        return board;
    }

    public List<PlacedWord> getPlacedWords() {
        return Collections.unmodifiableList(placedWords);
    }
}
