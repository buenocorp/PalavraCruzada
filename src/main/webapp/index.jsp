<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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
}
.card{
    width:min(90%,640px);
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
.sub{font-size:1rem;line-height:1.6;color:#4338ca;margin-bottom:28px;}
.badges{display:flex;flex-wrap:wrap;justify-content:center;gap:8px;margin-bottom:28px;}
.badge{
    font-size:.78rem;font-weight:700;border-radius:99px;padding:4px 14px;
}
.badge.sql{color:#1d4ed8;background:#dbeafe;}
.badge.js {color:#92400e;background:#fef3c7;}
.badge.met{color:#6b21a8;background:#f3e8ff;}
.badge.cls{color:#065f46;background:#d1fae5;}
a{
    display:inline-block;text-decoration:none;
    background:linear-gradient(135deg,#7c3aed,#db2777);
    color:#fff;padding:14px 28px;border-radius:12px;
    font-weight:700;font-size:1.05rem;
    box-shadow:0 6px 20px rgba(124,58,237,.4);
    transition:transform .15s,filter .15s;
}
a:hover{transform:translateY(-2px);filter:brightness(1.08);}
</style>
</head>
<body>
<div class="card">
    <h1>Palavras Cruzadas</h1>
    <p class="sub">
        <br>
        Cada partida gera uma nova cruzadinha com 10 palavras secretas.<br>
        As letras aparecem no tabuleiro a cada resposta correta!<br>
    </p>
    <div class="badges">
        <span class="badge sql">SQL Basico</span>
        <span class="badge js">JavaScript</span>
        <span class="badge met">Metodos</span>
        <span class="badge cls">Classes</span>
    </div>
    <a href="<%= request.getContextPath() %>/jogo">Iniciar partida</a>
</div>
</body>
</html>
