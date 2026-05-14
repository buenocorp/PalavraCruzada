package com.palavracruzada.model;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Random;
import java.util.Set;

import com.palavracruzada.model.PlacedWord.Orientation;

public class CrosswordGenerator {
    private static final int BOARD_SIZE = 21;
    private static final int TOTAL_SECRET_WORDS = 10;

    private final Random random = new Random();

    private final List<WordEntry> wordBank = Arrays.asList(
        // SQL Basico
        new WordEntry("SELECT",     "Qual comando usamos para buscar dados em uma tabela SQL?",                 "SQL"),
        new WordEntry("INSERT",     "Qual comando adiciona uma nova linha em uma tabela SQL?",                  "SQL"),
        new WordEntry("UPDATE",     "Qual comando muda o valor de um dado ja salvo no banco?",                  "SQL"),
        new WordEntry("DELETE",     "Qual comando apaga linhas de uma tabela SQL?",                             "SQL"),
        new WordEntry("WHERE",      "Que palavra usamos para filtrar resultados no SQL? Ex: ... nome = 'Ana'",  "SQL"),
        new WordEntry("TABELA",     "No banco de dados, os dados ficam organizados em linhas e colunas dentro de uma ___.", "SQL"),
        new WordEntry("CONSULTA",   "Quando escrevemos um SELECT para buscar dados, estamos fazendo uma ___ ao banco.", "SQL"),
        new WordEntry("CREATE",     "Qual comando SQL cria uma nova tabela do zero?",                           "SQL"),
        new WordEntry("INDICE",     "Recurso do banco que deixa as buscas mais rapidas, como o indice de um livro.", "SQL"),
        new WordEntry("JOIN",       "Qual comando SQL une dados de duas tabelas diferentes na mesma consulta?", "SQL"),
        // JavaScript Basico
        new WordEntry("JAVASCRIPT", "Linguagem de programacao que roda no navegador e deixa as paginas interativas.", "JavaScript"),
        new WordEntry("VARIAVEL",   "Caixinha que guarda um valor no codigo. Ex: let nome = 'Ana'",            "JavaScript"),
        new WordEntry("FUNCAO",     "Bloco de codigo com nome que podemos chamar varias vezes. Ex: function somar(){}", "JavaScript"),
        new WordEntry("OBJETO",     "Agrupamento de dados com chave e valor. Ex: { nome: 'Ana', idade: 20 }",  "JavaScript"),
        new WordEntry("ARRAY",      "Lista de varios valores em sequencia. Ex: [1, 2, 3, 4]",                  "JavaScript"),
        new WordEntry("STRING",     "Tipo de dado que representa texto entre aspas. Ex: 'Ola Mundo'",          "JavaScript"),
        new WordEntry("BOOLEANO",   "Tipo que so pode ser verdadeiro (true) ou falso (false).",                "JavaScript"),
        new WordEntry("EVENTO",     "Algo que acontece na pagina e podemos reagir. Ex: clique, tecla, scroll.", "JavaScript"),
        new WordEntry("RETORNO",    "O que a palavra-chave return faz em uma funcao? Devolve um ___.",         "JavaScript"),
        new WordEntry("DECLARACAO", "Ato de criar uma variavel ou funcao no codigo. Ex: let x = 10 e uma ___.", "JavaScript"),
        // Metodos Basicos
        new WordEntry("FILTER",     "Metodo de array que guarda so os itens que passam em uma condicao. Ex: numeros.filter(n => n > 5)", "Metodos"),
        new WordEntry("CONCAT",     "Metodo que junta dois arrays ou duas strings em um so.",                  "Metodos"),
        new WordEntry("SPLIT",      "Metodo de string que quebra o texto em partes e devolve um array. Ex: 'a,b,c'.split(',')", "Metodos"),
        new WordEntry("FOREACH",    "Metodo que percorre cada item de um array e executa uma acao para cada um.", "Metodos"),
        new WordEntry("SLICE",      "Metodo que copia um pedaco de um array ou string sem alterar o original.", "Metodos"),
        // Classes Basico
        new WordEntry("CLASSE",     "Molde que usamos para criar objetos com as mesmas propriedades e metodos.", "Classes"),
        new WordEntry("METODO",     "Funcao que fica dentro de uma classe. Ex: diminuirEstoque() e um ___ da classe Produto.", "Classes"),
        new WordEntry("ATRIBUTO",   "Variavel que pertence a um objeto. Ex: this.nome e um ___ da classe Produto.", "Classes"),
        new WordEntry("HERANCA",    "Quando uma classe filha reusa o codigo de outra usando a palavra extends.", "Classes"),
        new WordEntry("INSTANCIA",  "Objeto criado a partir de uma classe usando new. Ex: new Produto('Camiseta', 20, 10)", "Classes"),
        new WordEntry("CONSTRUTOR", "Metodo especial chamado ao usar new. No codigo: constructor(nome, preco, estoque){}", "Classes"),
        new WordEntry("PRODUTO",    "No projeto do carrinho, qual e o nome da classe que tem nome, preco e estoque?", "Classes"),
        new WordEntry("CARRINHO",   "Classe do projeto que guarda a lista de itens e calcula o total da compra.", "Classes"),
        new WordEntry("ESTOQUE",    "Atributo da classe Produto que controla quantas unidades ainda estao disponiveis.", "Classes"),
        // Metodos do contexto Carrinho/Produto
        new WordEntry("REDUCE",     "Metodo que soma ou acumula todos os valores de um array. Ex: itens.reduce((acc, item) => acc + item.preco, 0)", "Metodos"),
        new WordEntry("SPLICE",     "Metodo que remove itens de um array pelo indice. Usado em removerProduto() no projeto.", "Metodos"),
        new WordEntry("FINDINDEX",  "Metodo que devolve a posicao do primeiro item que atende a condicao. Ex: itens.findIndex(i => i.nome === 'Tenis')", "Metodos"),
        // JavaScript - Node.js
        new WordEntry("CONSOLE",    "Objeto que usamos para mostrar mensagens no terminal. Ex: ___.log('Ola!')",  "JavaScript"),
        new WordEntry("REQUIRE",    "Funcao do Node.js para importar outro arquivo. Ex: const Produto = ___('./Produto')", "JavaScript"),
        new WordEntry("MODULO",     "Cada arquivo .js que exporta algo com module.exports e chamado de ___.",   "JavaScript"),
        // CarteiraDigital
        new WordEntry("CARTEIRA",   "No projeto da carteira digital, qual e o nome da classe que representa a conta de um usuario?", "Classes"),
        new WordEntry("HISTORICO",  "Atributo da CarteiraDigital que registra todas as operacoes feitas. Ex: this.___ = []", "Classes"),
        new WordEntry("TRANSFERIR", "Metodo que envia dinheiro de uma carteira para outra descontando uma taxa. Ex: carteira1.___(20, carteira2)", "Classes"),
        new WordEntry("USUARIO",    "Atributo que guarda o nome do dono da carteira. Ex: this.___ = 'Joao'",   "Classes"),
        new WordEntry("SALDO",      "Atributo que mostra o dinheiro disponivel. Comeca em zero. Ex: this.___ = 0", "Classes"),
        new WordEntry("PAGAR",      "Metodo da CarteiraDigital que desconta um valor do saldo. Ex: carteira1.___(30)", "Classes")
    );

    public CrosswordGame generateGame() {
        for (int attempt = 0; attempt < 200; attempt++) {
            CrosswordGame game = tryGenerate();
            if (game != null) {
                return game;
            }
        }
        throw new IllegalStateException("Nao foi possivel gerar a cruzadinha com as regras definidas.");
    }

    private CrosswordGame tryGenerate() {
        char[][] board = new char[BOARD_SIZE][BOARD_SIZE];
        List<WordEntry> centralCandidates = getCentralCandidates();
        if (centralCandidates.isEmpty()) {
            return null;
        }

        WordEntry centralEntry = centralCandidates.get(random.nextInt(centralCandidates.size()));
        int centerRow = BOARD_SIZE / 2;
        int centralStartCol = (BOARD_SIZE - centralEntry.getWord().length()) / 2;

        List<PlacedWord> placedWords = new ArrayList<PlacedWord>();
        placeHorizontal(board, centralEntry.getWord(), centerRow, centralStartCol);
        placedWords.add(new PlacedWord(1, centralEntry, centerRow, centralStartCol, Orientation.HORIZONTAL));

        Set<String> usedWords = new HashSet<String>();
        usedWords.add(centralEntry.getWord());

        List<Integer> centralIndexes = new ArrayList<Integer>();
        for (int i = 0; i < centralEntry.getWord().length(); i++) {
            centralIndexes.add(Integer.valueOf(i));
        }
        Collections.shuffle(centralIndexes, random);

        int wordNumber = 2;
        for (Integer centralIndexObj : centralIndexes) {
            if (wordNumber > TOTAL_SECRET_WORDS) {
                break;
            }

            int centralIndex = centralIndexObj.intValue();
            char needed = centralEntry.getWord().charAt(centralIndex);
            int crossCol = centralStartCol + centralIndex;

            List<WordEntry> candidates = getCandidatesByLetter(needed, usedWords);
            Collections.shuffle(candidates, random);

            boolean placed = false;
            for (WordEntry candidate : candidates) {
                int rowStart = findVerticalStart(board, candidate.getWord(), centerRow, crossCol, needed);
                if (rowStart >= 0) {
                    placeVertical(board, candidate.getWord(), rowStart, crossCol);
                    placedWords.add(new PlacedWord(wordNumber, candidate, rowStart, crossCol, Orientation.VERTICAL));
                    usedWords.add(candidate.getWord());
                    wordNumber++;
                    placed = true;
                    break;
                }
            }

            if (!placed) {
                continue;
            }
        }

        if (placedWords.size() != TOTAL_SECRET_WORDS) {
            return null;
        }

        return new CrosswordGame(board, placedWords);
    }

    private List<WordEntry> getCentralCandidates() {
        List<WordEntry> candidates = new ArrayList<WordEntry>();
        for (WordEntry entry : wordBank) {
            if (entry.getWord().length() >= 10 && entry.getWord().length() <= BOARD_SIZE - 2) {
                candidates.add(entry);
            }
        }
        return candidates;
    }

    private List<WordEntry> getCandidatesByLetter(char letter, Set<String> usedWords) {
        List<WordEntry> candidates = new ArrayList<WordEntry>();
        for (WordEntry entry : wordBank) {
            if (!usedWords.contains(entry.getWord()) && entry.getWord().indexOf(letter) >= 0) {
                candidates.add(entry);
            }
        }
        return candidates;
    }

    private int findVerticalStart(char[][] board, String word, int crossRow, int crossCol, char neededChar) {
        for (int i = 0; i < word.length(); i++) {
            if (word.charAt(i) != neededChar) {
                continue;
            }

            int rowStart = crossRow - i;
            int rowEnd = rowStart + word.length() - 1;
            if (rowStart < 0 || rowEnd >= BOARD_SIZE) {
                continue;
            }

            if (canPlaceVertical(board, word, rowStart, crossCol, crossRow)) {
                return rowStart;
            }
        }
        return -1;
    }

    private boolean canPlaceVertical(char[][] board, String word, int rowStart, int col, int crossRow) {
        for (int i = 0; i < word.length(); i++) {
            int row = rowStart + i;
            char existing = board[row][col];
            char next = word.charAt(i);

            if (existing != '\0' && existing != next) {
                return false;
            }

            if (row != crossRow && existing != '\0') {
                return false;
            }
        }
        return true;
    }

    private void placeHorizontal(char[][] board, String word, int row, int colStart) {
        for (int i = 0; i < word.length(); i++) {
            board[row][colStart + i] = word.charAt(i);
        }
    }

    private void placeVertical(char[][] board, String word, int rowStart, int col) {
        for (int i = 0; i < word.length(); i++) {
            board[rowStart + i][col] = word.charAt(i);
        }
    }
}
