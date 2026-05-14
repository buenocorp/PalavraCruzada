<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Set, java.util.HashSet" %>
<%
    Set<Integer> completedLevels = (Set<Integer>) session.getAttribute("completedLevels");
    if (completedLevels == null) completedLevels = new HashSet<Integer>();
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Palavras Cruzadas - MVC</title>
<style>
*{box-sizing:border-box;margin:0;padding:0;}
body{
    font-family:"Trebuchet MS","Segoe UI",sans-serif;
    min-height:100vh;
    display:flex;align-items:center;justify-content:center;
    background:linear-gradient(135deg,#312e81 0%,#4c1d95 100%);
    color:#1e1b4b;
    padding:20px;
}
.card{
    width:min(90%,700px);
    background:rgba(255,255,255,.96);
    border-radius:22px;
    padding:40px 44px;
    text-align:center;
    box-shadow:0 24px 60px rgba(79,70,229,.3);
}
h1{
    font-size:2.1rem;margin-bottom:10px;letter-spacing:.01em;
    background:linear-gradient(90deg,#7c3aed,#db2777);
    -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;
}
.sub{font-size:1rem;line-height:1.6;color:#4338ca;margin-bottom:20px;}
.badges{display:flex;flex-wrap:wrap;justify-content:center;gap:8px;margin-bottom:28px;}
.badge{font-size:.78rem;font-weight:700;border-radius:99px;padding:4px 14px;}
.badge.sql{color:#1d4ed8;background:#dbeafe;}
.badge.js {color:#92400e;background:#fef3c7;}
.badge.met{color:#6b21a8;background:#f3e8ff;}
.badge.cls{color:#065f46;background:#d1fae5;}

.section-title{
    font-size:.88rem;font-weight:700;color:#6d28d9;
    text-transform:uppercase;letter-spacing:.08em;
    margin-bottom:14px;
}
.levels{
    display:grid;
    grid-template-columns:repeat(5,1fr);
    gap:10px;
    margin-bottom:20px;
}
.levels-supremo{
    margin-bottom:32px;
}
.lvl-btn{
    display:flex;flex-direction:column;align-items:center;justify-content:center;
    text-decoration:none;
    border-radius:14px;
    padding:14px 8px 10px;
    font-weight:700;
    transition:transform .15s, filter .15s, box-shadow .15s;
    position:relative;
    overflow:hidden;
    cursor:pointer;
}
.lvl-btn.unlocked:hover{transform:translateY(-3px);filter:brightness(1.08);box-shadow:0 8px 24px rgba(124,58,237,.4);}
.lvl-btn.locked{
    cursor:not-allowed;
    opacity:.45;
    filter:grayscale(.7);
}
.lvl-num{font-size:1.45rem;line-height:1;}
.lvl-label{font-size:.68rem;margin-top:4px;opacity:.85;}
.lvl-words{font-size:.72rem;margin-top:3px;font-weight:900;}
.lvl-status{font-size:.85rem;margin-top:4px;line-height:1;}

.lvl-1 {background:linear-gradient(135deg,#a78bfa,#7c3aed);color:#fff;}
.lvl-2 {background:linear-gradient(135deg,#818cf8,#4f46e5);color:#fff;}
.lvl-3 {background:linear-gradient(135deg,#6366f1,#3730a3);color:#fff;}
.lvl-4 {background:linear-gradient(135deg,#db2777,#be185d);color:#fff;}
.lvl-5 {background:linear-gradient(135deg,#ec4899,#db2777);color:#fff;}
.lvl-6 {background:linear-gradient(135deg,#f59e0b,#d97706);color:#fff;}
.lvl-7 {background:linear-gradient(135deg,#10b981,#059669);color:#fff;}
.lvl-8 {background:linear-gradient(135deg,#0ea5e9,#0284c7);color:#fff;}
.lvl-9 {background:linear-gradient(135deg,#ef4444,#b91c1c);color:#fff;}
.lvl-10{background:linear-gradient(135deg,#1e1b4b,#312e81);color:#fff;}
.lvl-11{
    background:linear-gradient(135deg,#78350f,#b45309,#f59e0b);
    color:#fff;
    box-shadow:0 0 0 3px #f59e0b, 0 0 18px rgba(245,158,11,.6);
    grid-column:span 5;
    flex-direction:row;
    gap:14px;
    padding:16px 24px;
    justify-content:center;
    font-size:1.05rem;
}
.lvl-11 .lvl-num{font-size:1.8rem;}
.lvl-11 .lvl-label{font-size:.9rem;opacity:1;font-weight:900;}
.lvl-11 .lvl-words{font-size:.85rem;}
.lvl-11 .lvl-status{font-size:1rem;}
</style>
</head>
<body>
<div class="card">
    <h1>Palavras Cruzadas</h1>
    <p class="sub">
        Cada partida gera uma nova cruzadinha.<br>
        Complete cada nivel para desbloquear o proximo!
    </p>
    <div class="badges">
        <span class="badge sql">SQL Basico</span>
        <span class="badge js">JavaScript</span>
        <span class="badge met">Metodos</span>
        <span class="badge cls">Classes</span>
    </div>

    <div class="section-title">Escolha o Nivel</div>
    <div class="levels">
        <%
            String[] labels   = {"","Iniciante","Basico","Facil","Regular","Medio","Desafiador","Avancado","Expert","Mestre","Lendario","Supremo"};
            int[]    wordCounts = {0, 10,11,12,13,14,15,16,17,18,19,50};
            for (int n = 1; n <= 11; n++) {
                boolean completed  = completedLevels.contains(Integer.valueOf(n));
                boolean accessible = (n == 1) || completedLevels.contains(Integer.valueOf(n - 1));
                String statusIcon  = completed ? "✅" : (accessible ? "▶" : "🔒");
        %>
        <% if (accessible) { %>
        <a class="lvl-btn lvl-<%= n %> unlocked"
           href="<%= request.getContextPath() %>/jogo?nivel=<%= n %>">
        <% } else { %>
        <span class="lvl-btn lvl-<%= n %> locked">
        <% } %>
            <span class="lvl-num"><%= n %><%= n == 11 ? " 👑" : "" %></span>
            <span class="lvl-label"><%= labels[n] %></span>
            <span class="lvl-words"><%= wordCounts[n] %> palavras</span>
            <span class="lvl-status"><%= statusIcon %></span>
        <% if (accessible) { %>
        </a>
        <% } else { %>
        </span>
        <% } %>
        <% } %>
    </div>
</div>
</body>
</html>
