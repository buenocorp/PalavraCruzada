package com.palavracruzada.model;

public class PlacedWord {
    public enum Orientation {
        HORIZONTAL,
        VERTICAL
    }

    private final int number;
    private final WordEntry entry;
    private final int row;
    private final int col;
    private final Orientation orientation;

    public PlacedWord(int number, WordEntry entry, int row, int col, Orientation orientation) {
        this.number = number;
        this.entry = entry;
        this.row = row;
        this.col = col;
        this.orientation = orientation;
    }

    public int getNumber() {
        return number;
    }

    public WordEntry getEntry() {
        return entry;
    }

    public int getRow() {
        return row;
    }

    public int getCol() {
        return col;
    }

    public Orientation getOrientation() {
        return orientation;
    }
}
