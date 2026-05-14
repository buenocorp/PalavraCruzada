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
    private static final int SUPREMO_SIZE = 55;

    private final int totalWords;
    private final Random random = new Random();

    public CrosswordGenerator() {
        this(10);
    }

    public CrosswordGenerator(int totalWords) {
        this.totalWords = totalWords;
    }

    private final List<WordEntry> wordBank = Arrays.asList(
        // SQL Basico
        new WordEntry("SELECT",           "Qual comando usamos para buscar dados em uma tabela SQL?",                      "SQL"),
        new WordEntry("INSERT",           "Qual comando adiciona uma nova linha em uma tabela SQL?",                       "SQL"),
        new WordEntry("UPDATE",           "Qual comando muda o valor de um dado ja salvo no banco?",                       "SQL"),
        new WordEntry("DELETE",           "Qual comando apaga linhas de uma tabela SQL?",                                  "SQL"),
        new WordEntry("WHERE",            "Que palavra usamos para filtrar resultados no SQL? Ex: ... nome = 'Ana'",        "SQL"),
        new WordEntry("TABELA",           "No banco de dados, os dados ficam organizados em linhas e colunas dentro de uma ___.", "SQL"),
        new WordEntry("CONSULTA",         "Quando escrevemos um SELECT para buscar dados, estamos fazendo uma ___ ao banco.", "SQL"),
        new WordEntry("CREATE",           "Qual comando SQL cria uma nova tabela do zero?",                                "SQL"),
        new WordEntry("INDICE",           "Recurso do banco que deixa as buscas mais rapidas, como o indice de um livro.", "SQL"),
        new WordEntry("JOIN",             "Qual comando SQL une dados de duas tabelas diferentes na mesma consulta?",      "SQL"),
        new WordEntry("CHAVE",            "___ primaria e o campo unico que identifica cada linha de uma tabela.",         "SQL"),
        new WordEntry("COLUNA",           "Em uma tabela SQL, cada tipo de informacao fica em uma ___. Ex: nome, idade.",  "SQL"),
        new WordEntry("RESULTADO",        "O que um SELECT retorna quando encontra registros no banco de dados?",          "SQL"),
        new WordEntry("ORDERBY",          "Clausula SQL que organiza os resultados em ordem crescente ou decrescente.",    "SQL"),
        new WordEntry("GROUPBY",          "Clausula SQL usada para agrupar linhas com o mesmo valor em uma coluna.",       "SQL"),
        new WordEntry("CONSTRAINT",       "Regra aplicada a uma coluna da tabela, como NOT NULL ou UNIQUE.",               "SQL"),
        new WordEntry("TRANSACAO",        "Conjunto de operacoes SQL que devem ser executadas todas juntas ou nenhuma.",   "SQL"),
        new WordEntry("PROCEDURE",        "Bloco de codigo SQL salvo no banco que pode ser chamado pelo nome.",            "SQL"),
        // JavaScript Basico
        new WordEntry("JAVASCRIPT",       "Linguagem de programacao que roda no navegador e deixa as paginas interativas.", "JavaScript"),
        new WordEntry("VARIAVEL",         "Caixinha que guarda um valor no codigo. Ex: let nome = 'Ana'",                  "JavaScript"),
        new WordEntry("FUNCAO",           "Bloco de codigo com nome que podemos chamar varias vezes. Ex: function somar(){}", "JavaScript"),
        new WordEntry("OBJETO",           "Agrupamento de dados com chave e valor. Ex: { nome: 'Ana', idade: 20 }",        "JavaScript"),
        new WordEntry("ARRAY",            "Lista de varios valores em sequencia. Ex: [1, 2, 3, 4]",                        "JavaScript"),
        new WordEntry("STRING",           "Tipo de dado que representa texto entre aspas. Ex: 'Ola Mundo'",                "JavaScript"),
        new WordEntry("BOOLEANO",         "Tipo que so pode ser verdadeiro (true) ou falso (false).",                      "JavaScript"),
        new WordEntry("EVENTO",           "Algo que acontece na pagina e podemos reagir. Ex: clique, tecla, scroll.",      "JavaScript"),
        new WordEntry("RETORNO",          "O que a palavra-chave return faz em uma funcao? Devolve um ___.",               "JavaScript"),
        new WordEntry("DECLARACAO",       "Ato de criar uma variavel ou funcao no codigo. Ex: let x = 10 e uma ___.",     "JavaScript"),
        new WordEntry("CONDICIONAL",      "Estrutura que executa um bloco so se a condicao for verdadeira. Ex: if(x>0){}", "JavaScript"),
        new WordEntry("ITERACAO",         "Quando repetimos um bloco de codigo varias vezes usando for ou while.",         "JavaScript"),
        new WordEntry("PARAMETRO",        "Variavel que a funcao recebe ao ser chamada. Ex: function somar(a, b){}",       "JavaScript"),
        new WordEntry("ASSINCRONO",       "Codigo que nao espera a resposta antes de continuar. Relacionado a async/await.", "JavaScript"),
        new WordEntry("PROTOTYPE",        "Mecanismo do JavaScript que permite que objetos herdem propriedades uns dos outros.", "JavaScript"),
        new WordEntry("ESCOPO",           "Area do codigo onde uma variavel pode ser acessada. Ex: dentro ou fora de uma funcao.", "JavaScript"),
        new WordEntry("CALLBACK",         "Funcao passada como argumento para outra funcao e chamada depois.",             "JavaScript"),
        new WordEntry("PROMESSA",         "Objeto que representa o resultado futuro de uma operacao assincrona (Promise).", "JavaScript"),
        // Metodos Basicos
        new WordEntry("FILTER",           "Metodo de array que guarda so os itens que passam em uma condicao. Ex: numeros.filter(n => n > 5)", "Metodos"),
        new WordEntry("CONCAT",           "Metodo que junta dois arrays ou duas strings em um so.",                        "Metodos"),
        new WordEntry("SPLIT",            "Metodo de string que quebra o texto em partes e devolve um array. Ex: 'a,b,c'.split(',')", "Metodos"),
        new WordEntry("FOREACH",          "Metodo que percorre cada item de um array e executa uma acao para cada um.",    "Metodos"),
        new WordEntry("SLICE",            "Metodo que copia um pedaco de um array ou string sem alterar o original.",      "Metodos"),
        new WordEntry("REDUCE",           "Metodo que soma ou acumula todos os valores de um array. Ex: itens.reduce((acc, item) => acc + item.preco, 0)", "Metodos"),
        new WordEntry("SPLICE",           "Metodo que remove itens de um array pelo indice. Usado em removerProduto() no projeto.", "Metodos"),
        new WordEntry("FINDINDEX",        "Metodo que devolve a posicao do primeiro item que atende a condicao. Ex: itens.findIndex(i => i.nome === 'Tenis')", "Metodos"),
        new WordEntry("INCLUDES",         "Metodo que verifica se um valor existe em um array. Retorna true ou false.",    "Metodos"),
        new WordEntry("SORT",             "Metodo que ordena os itens de um array. Ex: nomes.sort()",                      "Metodos"),
        new WordEntry("REVERSE",          "Metodo que inverte a ordem dos itens de um array.",                             "Metodos"),
        new WordEntry("INDEXOF",          "Metodo que retorna a posicao de um elemento no array, ou -1 se nao encontrar.", "Metodos"),
        new WordEntry("TOLOWERCASE",      "Metodo de string que converte o texto para letras minusculas.",                 "Metodos"),
        new WordEntry("TOUPPERCASE",      "Metodo de string que converte o texto para letras maiusculas.",                 "Metodos"),
        new WordEntry("TRIM",             "Metodo de string que remove espacos extras do inicio e do fim do texto.",       "Metodos"),
        new WordEntry("REPLACE",          "Metodo de string que troca uma parte do texto por outra.",                     "Metodos"),
        new WordEntry("TOSTRING",         "Metodo que converte um numero ou objeto para texto.",                           "Metodos"),
        // Classes Basico
        new WordEntry("CLASSE",           "Molde que usamos para criar objetos com as mesmas propriedades e metodos.",    "Classes"),
        new WordEntry("METODO",           "Funcao que fica dentro de uma classe. Ex: diminuirEstoque() e um ___ da classe Produto.", "Classes"),
        new WordEntry("ATRIBUTO",         "Variavel que pertence a um objeto. Ex: this.nome e um ___ da classe Produto.", "Classes"),
        new WordEntry("HERANCA",          "Quando uma classe filha reusa o codigo de outra usando a palavra extends.",    "Classes"),
        new WordEntry("INSTANCIA",        "Objeto criado a partir de uma classe usando new. Ex: new Produto('Camiseta', 20, 10)", "Classes"),
        new WordEntry("CONSTRUTOR",       "Metodo especial chamado ao usar new. No codigo: constructor(nome, preco, estoque){}", "Classes"),
        new WordEntry("PRODUTO",          "No projeto do carrinho, qual e o nome da classe que tem nome, preco e estoque?", "Classes"),
        new WordEntry("CARRINHO",         "Classe do projeto que guarda a lista de itens e calcula o total da compra.",   "Classes"),
        new WordEntry("ESTOQUE",          "Atributo da classe Produto que controla quantas unidades ainda estao disponiveis.", "Classes"),
        new WordEntry("POLIMORFISMO",     "Quando metodos com o mesmo nome se comportam de forma diferente em classes diferentes.", "Classes"),
        new WordEntry("ENCAPSULAMENTO",   "Principio de esconder os detalhes internos de uma classe usando metodos de acesso.", "Classes"),
        new WordEntry("ABSTRATO",         "Classe que nao pode ser instanciada diretamente; serve de molde para outras.",  "Classes"),
        new WordEntry("INTERFACE",        "Contrato que define quais metodos uma classe deve ter, sem implementa-los.",    "Classes"),
        new WordEntry("SOBRESCRITA",      "Quando uma classe filha redefine um metodo que ja existia na classe pai.",      "Classes"),
        new WordEntry("VISIBILIDADE",     "Define se um atributo pode ser acessado de fora da classe: public, private...", "Classes"),
        // JavaScript - Node.js
        new WordEntry("CONSOLE",          "Objeto que usamos para mostrar mensagens no terminal. Ex: ___.log('Ola!')",     "JavaScript"),
        new WordEntry("REQUIRE",          "Funcao do Node.js para importar outro arquivo. Ex: const Produto = ___('./Produto')", "JavaScript"),
        new WordEntry("MODULO",           "Cada arquivo .js que exporta algo com module.exports e chamado de ___.",        "JavaScript"),
        // CarteiraDigital
        new WordEntry("CARTEIRA",         "No projeto da carteira digital, qual e o nome da classe que representa a conta de um usuario?", "Classes"),
        new WordEntry("HISTORICO",        "Atributo da CarteiraDigital que registra todas as operacoes feitas. Ex: this.___ = []", "Classes"),
        new WordEntry("TRANSFERIR",       "Metodo que envia dinheiro de uma carteira para outra descontando uma taxa. Ex: carteira1.___(20, carteira2)", "Classes"),
        new WordEntry("USUARIO",          "Atributo que guarda o nome do dono da carteira. Ex: this.___ = 'Joao'",        "Classes"),
        new WordEntry("SALDO",            "Atributo que mostra o dinheiro disponivel. Comeca em zero. Ex: this.___ = 0",  "Classes"),
        new WordEntry("PAGAR",            "Metodo da CarteiraDigital que desconta um valor do saldo. Ex: carteira1.___(30)", "Classes"),
        // Programacao geral
        new WordEntry("ALGORITMO",        "Sequencia de passos para resolver um problema. Todo programa e um ___.",        "JavaScript"),
        new WordEntry("DEPURACAO",        "Processo de encontrar e corrigir erros no codigo. Em ingles: debugging.",       "JavaScript"),
        new WordEntry("COMPILACAO",       "Processo de transformar o codigo-fonte em codigo executavel pela maquina.",     "JavaScript"),
        new WordEntry("RECURSIVIDADE",    "Quando uma funcao chama a si mesma para resolver um problema menor.",           "JavaScript"),
        new WordEntry("ESTRUTURA",        "Forma de organizar dados no codigo. Ex: array, objeto, lista.",                 "JavaScript"),
        // Palavras longas para niveis avancados (15-18 letras)
        new WordEntry("DESENVOLVIMENTO",  "O processo completo de criar um programa, do planejamento ate a entrega.",      "JavaScript"),
        new WordEntry("DISPONIBILIDADE",  "Capacidade de um sistema estar sempre pronto para ser acessado pelos usuarios.", "JavaScript"),
        new WordEntry("VULNERABILIDADE",  "Falha no codigo que pode ser explorada por um atacante. Conceito de seguranca.", "JavaScript"),
        new WordEntry("RESPONSABILIDADE", "Em programacao, cada modulo deve ter apenas uma ___: fazer uma coisa so.",       "Classes"),
        new WordEntry("COMPARTILHAMENTO", "Quando dois componentes do sistema usam o mesmo dado ou recurso.",              "Classes"),
        new WordEntry("INTEROPERABILIDADE","Capacidade de sistemas diferentes se comunicarem e trabalharem juntos.",         "JavaScript"),
        new WordEntry("DESENVOLVIMENTOAGIL","Metodologia de desenvolvimento que entrega o software em ciclos curtos chamados sprints.", "JavaScript"),
        // Projeto Jogo - Arma / Inimigo / Jogador / Jogo
        new WordEntry("INIMIGO",          "Classe do jogo que tem nome e vida, e pode receber dano de um jogador.",           "Classes"),
        new WordEntry("JOGADOR",          "Classe principal do jogo que ataca inimigos, ganha pontos e troca de arma.",       "Classes"),
        new WordEntry("ATACAR",           "Metodo da classe Jogador que usa a arma equipada para causar dano a um inimigo.",  "Classes"),
        new WordEntry("PONTOS",           "Atributo da classe Jogador que aumenta ao derrotar um inimigo. Ex: this.___ = 0", "Classes"),
        new WordEntry("ARMAATUAL",        "Atributo da classe Jogador que guarda a arma equipada no momento. Ex: this.___",  "Classes"),
        new WordEntry("TROCARARMA",       "Metodo da classe Jogador que substitui a arma equipada. Ex: jogador.___(novaArma)", "Classes"),
        new WordEntry("MOSTRARARMA",      "Metodo da classe Arma que exibe nome e dano da arma no console.",                  "Classes"),
        new WordEntry("RECEBERDANO",      "Metodo da classe Inimigo que desconta vida de acordo com o dano. Ex: inimigo.___(10)", "Classes"),
        new WordEntry("GANHARPONTOS",     "Metodo chamado quando o jogador derrota um inimigo. Ex: jogador.___(100)",         "Classes"),
        new WordEntry("MOSTRARSTATUS",    "Metodo presente nas classes Jogador e Inimigo que exibe nome e vida no console.",  "Classes"),
        new WordEntry("LISTARINIMIGOS",   "Metodo da classe Jogo que exibe no console todos os inimigos cadastrados.",        "Classes"),
        new WordEntry("LISTARJOGADORES",  "Metodo da classe Jogo que exibe no console todos os jogadores cadastrados.",       "Classes"),
        new WordEntry("ADICIONARJOGADOR", "Metodo da classe Jogo que inclui um novo jogador na lista. Ex: jogo.___(jogador)", "Classes"),
        new WordEntry("ADICIONARINIMIGO", "Metodo da classe Jogo que inclui um novo inimigo na lista. Ex: jogo.___(inimigo)", "Classes")
    );

    public CrosswordGame generateGame() {
        if (totalWords >= 30) {
            for (int attempt = 0; attempt < 80; attempt++) {
                CrosswordGame game = tryGenerateSupremo();
                if (game != null) return game;
            }
            throw new IllegalStateException("Nao foi possivel gerar o Supremo.");
        }
        for (int attempt = 0; attempt < 300; attempt++) {
            CrosswordGame game = tryGenerate();
            if (game != null) {
                return game;
            }
        }
        throw new IllegalStateException("Nao foi possivel gerar a cruzadinha com as regras definidas.");
    }

    // ── Algoritmo bidirecional para Supremo (grade 55×55) ──────────────────
    private CrosswordGame tryGenerateSupremo() {
        int size = SUPREMO_SIZE;
        char[][] board = new char[size][size];
        List<PlacedWord> placed = new ArrayList<PlacedWord>();
        Set<String> usedWords = new HashSet<String>();

        // 1. Palavra inicial horizontal no centro
        List<WordEntry> pool = new ArrayList<WordEntry>(wordBank);
        Collections.shuffle(pool, random);
        WordEntry first = pool.get(0);
        int firstRow = size / 2;
        int firstCol = (size - first.getWord().length()) / 2;
        placeHorizontal(board, first.getWord(), firstRow, firstCol);
        placed.add(new PlacedWord(1, first, firstRow, firstCol, Orientation.HORIZONTAL));
        usedWords.add(first.getWord());

        int wordNum = 2;
        int failStreak = 0;

        while (wordNum <= totalWords && failStreak < 1200) {
            // Escolhe palavra ainda nao colocada para ramificar
            PlacedWord anchor = placed.get(random.nextInt(placed.size()));
            Orientation newDir = (anchor.getOrientation() == Orientation.HORIZONTAL)
                ? Orientation.VERTICAL : Orientation.HORIZONTAL;

            // Escolhe posicao aleatoria na ancora
            int letterIdx = random.nextInt(anchor.getEntry().getWord().length());
            char needed = anchor.getEntry().getWord().charAt(letterIdx);

            int crossRow, crossCol;
            if (anchor.getOrientation() == Orientation.HORIZONTAL) {
                crossRow = anchor.getRow();
                crossCol = anchor.getCol() + letterIdx;
            } else {
                crossRow = anchor.getRow() + letterIdx;
                crossCol = anchor.getCol();
            }

            List<WordEntry> candidates = getCandidatesByLetter(needed, usedWords);
            Collections.shuffle(candidates, random);

            boolean placed_ok = false;
            for (WordEntry candidate : candidates) {
                if (newDir == Orientation.VERTICAL) {
                    int rowStart = findVerticalStartMulti(board, candidate.getWord(), crossRow, crossCol, needed, size);
                    if (rowStart >= 0) {
                        placeVertical(board, candidate.getWord(), rowStart, crossCol);
                        placed.add(new PlacedWord(wordNum, candidate, rowStart, crossCol, Orientation.VERTICAL));
                        usedWords.add(candidate.getWord());
                        wordNum++;
                        placed_ok = true;
                        failStreak = 0;
                        break;
                    }
                } else {
                    int colStart = findHorizontalStartMulti(board, candidate.getWord(), crossRow, crossCol, needed, size);
                    if (colStart >= 0) {
                        placeHorizontal(board, candidate.getWord(), crossRow, colStart);
                        placed.add(new PlacedWord(wordNum, candidate, crossRow, colStart, Orientation.HORIZONTAL));
                        usedWords.add(candidate.getWord());
                        wordNum++;
                        placed_ok = true;
                        failStreak = 0;
                        break;
                    }
                }
            }
            if (!placed_ok) failStreak++;
        }

        if (placed.size() < totalWords) return null;
        return new CrosswordGame(board, placed);
    }

    private int findVerticalStartMulti(char[][] board, String word, int crossRow, int crossCol, char neededChar, int size) {
        for (int i = 0; i < word.length(); i++) {
            if (word.charAt(i) != neededChar) continue;
            int rowStart = crossRow - i;
            int rowEnd = rowStart + word.length() - 1;
            if (rowStart < 0 || rowEnd >= size) continue;
            if (canPlaceMulti(board, word, rowStart, crossCol, true, size)) return rowStart;
        }
        return -1;
    }

    private int findHorizontalStartMulti(char[][] board, String word, int crossRow, int crossCol, char neededChar, int size) {
        for (int i = 0; i < word.length(); i++) {
            if (word.charAt(i) != neededChar) continue;
            int colStart = crossCol - i;
            int colEnd = colStart + word.length() - 1;
            if (colStart < 0 || colEnd >= size) continue;
            if (canPlaceMulti(board, word, crossRow, colStart, false, size)) return colStart;
        }
        return -1;
    }

    // vertical=true -> word placed top-to-bottom at (rowOrCol, fixed); false -> left-to-right at (fixed, rowOrCol)
    private boolean canPlaceMulti(char[][] board, String word, int primary, int secondary, boolean vertical, int size) {
        for (int i = 0; i < word.length(); i++) {
            int r = vertical ? primary + i : primary;
            int c = vertical ? secondary : secondary + i;
            if (r < 0 || r >= size || c < 0 || c >= size) return false;
            char existing = board[r][c];
            char next = word.charAt(i);
            if (existing != '\0' && existing != next) return false;
        }
        return true;
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
            if (wordNumber > totalWords) {
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

        if (placedWords.size() != totalWords) {
            return null;
        }

        return new CrosswordGame(board, placedWords);
    }

    private List<WordEntry> getCentralCandidates() {
        // Central word must be long enough to cross totalWords-1 vertical words
        int minLen = Math.max(totalWords - 1, 9);
        List<WordEntry> candidates = new ArrayList<WordEntry>();
        for (WordEntry entry : wordBank) {
            if (entry.getWord().length() >= minLen && entry.getWord().length() <= BOARD_SIZE - 2) {
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
