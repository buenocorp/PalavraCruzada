package com.palavracruzada.controller;

import java.io.IOException;
import java.text.Normalizer;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import com.palavracruzada.model.CrosswordGame;
import com.palavracruzada.model.CrosswordGenerator;
import com.palavracruzada.model.PlacedWord;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class GameControllerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int nivel = parseNivel(request.getParameter("nivel"));
        HttpSession session = request.getSession();
        Set<Integer> completedLevels = getOrCreateCompletedLevels(session);

        if (!isLevelAccessible(completedLevels, nivel)) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        int totalWords = getTotalWords(nivel);
        CrosswordGame game = new CrosswordGenerator(totalWords).generateGame();
        Integer hintNumber = pickHintWord(game);

        session.setAttribute("currentGame", game);
        session.setAttribute("hintWordNumber", hintNumber);
        session.setAttribute("nivel", Integer.valueOf(nivel));

        request.setAttribute("game", game);
        request.setAttribute("submitted", Boolean.FALSE);
        request.setAttribute("hintWordNumber", hintNumber);
        request.setAttribute("nivel", Integer.valueOf(nivel));
        request.setAttribute("gameComplete", Boolean.FALSE);

        forwardToGameView(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        CrosswordGame game = (CrosswordGame) session.getAttribute("currentGame");
        Integer nivelAttr = (Integer) session.getAttribute("nivel");
        int nivel = nivelAttr != null ? nivelAttr.intValue() : 1;
        if (game == null) {
            int totalWords = getTotalWords(nivel);
            game = new CrosswordGenerator(totalWords).generateGame();
            session.setAttribute("currentGame", game);
        }
        Integer hintNumber = (Integer) session.getAttribute("hintWordNumber");

        Map<Integer, String> answers = new LinkedHashMap<Integer, String>();
        Map<Integer, Boolean> checks = new HashMap<Integer, Boolean>();

        int score = 0;
        for (PlacedWord placed : game.getPlacedWords()) {
            String paramName = "answer_" + placed.getNumber();
            String answer = request.getParameter(paramName);
            if (answer == null) {
                answer = "";
            }

            answers.put(Integer.valueOf(placed.getNumber()), answer);

            String expected = normalize(placed.getEntry().getWord());
            String informed = normalize(answer);
            boolean isCorrect = expected.equals(informed);
            checks.put(Integer.valueOf(placed.getNumber()), Boolean.valueOf(isCorrect));
            if (isCorrect) {
                score++;
            }
        }

        boolean gameComplete = (score == game.getPlacedWords().size());
        if (gameComplete) {
            Set<Integer> completedLevels = getOrCreateCompletedLevels(session);
            completedLevels.add(Integer.valueOf(nivel));

            String goNextNivel = request.getParameter("goNextNivel");
            if (goNextNivel != null && !goNextNivel.trim().isEmpty()) {
                int nextNivel = parseNivel(goNextNivel);
                response.sendRedirect(request.getContextPath() + "/jogo?nivel=" + nextNivel);
                return;
            }
        }

        request.setAttribute("game", game);
        request.setAttribute("submitted", Boolean.TRUE);
        request.setAttribute("score", Integer.valueOf(score));
        request.setAttribute("answers", answers);
        request.setAttribute("checks", checks);
        request.setAttribute("hintWordNumber", hintNumber);
        request.setAttribute("nivel", Integer.valueOf(nivel));
        request.setAttribute("gameComplete", Boolean.valueOf(gameComplete));

        forwardToGameView(request, response);
    }

    @SuppressWarnings("unchecked")
    private Set<Integer> getOrCreateCompletedLevels(HttpSession session) {
        Set<Integer> completed = (Set<Integer>) session.getAttribute("completedLevels");
        if (completed == null) {
            completed = new HashSet<Integer>();
            session.setAttribute("completedLevels", completed);
        }
        return completed;
    }

    private boolean isLevelAccessible(Set<Integer> completedLevels, int nivel) {
        return nivel == 1 || completedLevels.contains(Integer.valueOf(nivel - 1));
    }

    private int parseNivel(String param) {
        if (param == null) return 1;
        try {
            int n = Integer.parseInt(param.trim());
            return Math.min(Math.max(n, 1), 11);
        } catch (NumberFormatException e) {
            return 1;
        }
    }

    private int getTotalWords(int nivel) {
        if (nivel == 11) return 50; // Supremo: grade 55x55 bidirecional
        return 9 + nivel; // nivel 1 = 10, nivel 10 = 19
    }

    private Integer pickHintWord(CrosswordGame game) {
        PlacedWord shortest = null;
        for (PlacedWord pw : game.getPlacedWords()) {
            if (pw.getNumber() == 1) {
                continue;
            }
            if (shortest == null || pw.getEntry().getWord().length() < shortest.getEntry().getWord().length()) {
                shortest = pw;
            }
        }
        return shortest != null ? Integer.valueOf(shortest.getNumber()) : null;
    }

    private void forwardToGameView(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/views/game.jsp");
        dispatcher.forward(request, response);
    }

    private String normalize(String value) {
        String noAccents = Normalizer.normalize(value, Normalizer.Form.NFD)
            .replaceAll("\\p{M}", "");
        return noAccents.replaceAll("[^A-Za-z0-9]", "")
            .toUpperCase(Locale.ROOT)
            .trim();
    }
}
