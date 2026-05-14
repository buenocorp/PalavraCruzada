package com.palavracruzada.controller;

import java.io.IOException;
import java.text.Normalizer;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;

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

    private final CrosswordGenerator generator = new CrosswordGenerator();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        CrosswordGame game = generator.generateGame();
        Integer hintNumber = pickHintWord(game);

        HttpSession session = request.getSession();
        session.setAttribute("currentGame", game);
        session.setAttribute("hintWordNumber", hintNumber);

        request.setAttribute("game", game);
        request.setAttribute("submitted", Boolean.FALSE);
        request.setAttribute("hintWordNumber", hintNumber);

        forwardToGameView(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        CrosswordGame game = (CrosswordGame) session.getAttribute("currentGame");
        if (game == null) {
            game = generator.generateGame();
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

        request.setAttribute("game", game);
        request.setAttribute("submitted", Boolean.TRUE);
        request.setAttribute("score", Integer.valueOf(score));
        request.setAttribute("answers", answers);
        request.setAttribute("checks", checks);
        request.setAttribute("hintWordNumber", hintNumber);

        forwardToGameView(request, response);
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
