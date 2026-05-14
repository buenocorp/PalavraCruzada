<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Map,java.util.HashMap,java.util.List,java.util.LinkedHashSet,java.util.Set" %>
<%@ page import="com.palavracruzada.model.CrosswordGame,com.palavracruzada.model.PlacedWord" %>
<%
    CrosswordGame game = (CrosswordGame) request.getAttribute("game");
    boolean submitted = Boolean.TRUE.equals(request.getAttribute("submitted"));
    Map<Integer, String> answers = (Map<Integer, String>) request.getAttribute("answers");
    Map<Integer, Boolean> checks  = (Map<Integer, Boolean>) request.getAttribute("checks");
    char[][] board = game.getBoard();
    List<PlacedWord> words = game.getPlacedWords();

    Map<String, Integer> startCells = new HashMap<String, Integer>();
    for (PlacedWord pw : words) {
        startCells.put(pw.getRow() + "," + pw.getCol(), Integer.valueOf(pw.getNumber()));
    }
    Integer hintWordNumber = (Integer) request.getAttribute("hintWordNumber");
    Integer nivelAttr = (Integer) request.getAttribute("nivel");
    int nivel = nivelAttr != null ? nivelAttr.intValue() : 1;
    String[] nivelLabels = {"","Iniciante","Basico","Facil","Regular","Medio","Desafiador","Avancado","Expert","Mestre","Lendario","Supremo"};
    String nivelLabel = (nivel >= 1 && nivel <= 11) ? nivelLabels[nivel] : "Nivel " + nivel;
    boolean gameComplete = Boolean.TRUE.equals(request.getAttribute("gameComplete"));

    Set<String> catsInGame = new LinkedHashSet<String>();
    for (PlacedWord pw : words) catsInGame.add(pw.getEntry().getCategory());

    // Tamanho dinâmico do grid
    int gridSize  = board.length;
    boolean large = gridSize > 30;
    int cellPx    = large ? 18 : 44;
    int gapPx     = large ? 2  : 3;
    int fontPx    = large ? 8  : 18;
    int numFontPx = large ? 6  : 11;
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Cruzadinha — Nivel <%= nivel %></title>
<style>
:root{
    --bg1:#312e81;--bg2:#4c1d95;
    --panel:#fff;
    --grid-bg:#1e1b4b;
    --cell-empty:#f5f3ff;
    --cell-ok:#bbf7d0;    --cell-ok-txt:#166534;
    --cell-tok:#d1fae5;
    --cell-terr:#fee2e2;  --cell-terr-txt:#991b1b;
    --cell-active:#ede9fe;
    --num-color:#7c3aed;
    --ink:#1e1b4b;--accent:#7c3aed;
    --card-ok-bg:#f0fdf4;--card-ok-border:#6ee7b7;
    --ok:#15803d;--bad:#dc2626;
}
*{box-sizing:border-box;margin:0;padding:0;}
body{
    font-family:"Trebuchet MS","Segoe UI",sans-serif;
    color:var(--ink);min-height:100vh;
    background:linear-gradient(135deg,var(--bg1) 0%,var(--bg2) 100%);
}

/* ── Confete ── */
#confete{position:fixed;inset:0;pointer-events:none;z-index:999;overflow:hidden;}
.cp{position:absolute;top:-20px;animation:cair linear forwards;border-radius:2px;}
@keyframes cair{to{transform:translateY(110vh) rotate(720deg);opacity:0;}}

/* ── Layout ── */
.container{
    width:min(1500px,98%);margin:16px auto;
    display:grid;grid-template-columns:3fr 2fr;gap:16px;align-items:start;
}
.panel{
    background:var(--panel);border-radius:18px;
    box-shadow:0 12px 40px rgba(79,70,229,.22);
}

/* ── Grid panel ── */
.grid-panel{padding:18px;position:sticky;top:16px;}
.grid-wrap{overflow-x:auto;overflow-y:hidden;padding-bottom:4px;}
.grid{
    display:inline-grid;
    grid-template-columns:repeat(<%= gridSize %>,<%= cellPx %>px);
    gap:<%= gapPx %>px;
    background:var(--grid-bg);padding:9px;border-radius:12px;
}
.cell-slot{
    width:<%= cellPx %>px;height:<%= cellPx %>px;
    border-radius:<%= large ? 3 : 5 %>px;
    background:var(--cell-empty);
    display:flex;align-items:center;justify-content:center;
    font-weight:700;font-size:<%= fontPx %>px;position:relative;
    transition:background .18s,color .18s;
}
.cell-slot.block{background:#0f0a2d;}
.cell-slot.c-ok    {background:var(--cell-ok);   color:var(--cell-ok-txt);}
.cell-slot.c-tok   {background:var(--cell-tok);}
.cell-slot.c-terr  {background:var(--cell-terr);  color:var(--cell-terr-txt);}
.cell-slot.c-active{background:var(--cell-active);}
.num-badge{
    position:absolute;top:1px;left:2px;
    font-size:<%= numFontPx %>px;font-weight:900;line-height:1;color:#7c3aed;
}
.cell-letter{pointer-events:none;}
@keyframes letraPop{
    0%  {transform:scale(0) rotate(-20deg);opacity:0;}
    60% {transform:scale(1.3) rotate(5deg);opacity:1;}
    100%{transform:scale(1) rotate(0);opacity:1;}
}
.cell-slot.pop-anim .cell-letter{animation:letraPop .3s cubic-bezier(.34,1.56,.64,1) both;}

/* ── Questions panel (sticky, flex-column) ── */
.questions-panel{
    position:sticky;top:16px;
    max-height:calc(100vh - 32px);
    display:flex;flex-direction:column;
    overflow:hidden;
}
.panel-head{
    flex-shrink:0;
    padding:18px 18px 12px;
    border-bottom:1px solid #e0e7ff;
}
.clues-wrap{
    flex:1;overflow-y:auto;overflow-x:hidden;
    padding:12px 18px 16px;
    scrollbar-width:thin;scrollbar-color:#c7d2fe #f5f3ff;
}
.clues-wrap::-webkit-scrollbar{width:5px;}
.clues-wrap::-webkit-scrollbar-track{background:#f5f3ff;border-radius:99px;}
.clues-wrap::-webkit-scrollbar-thumb{background:#c7d2fe;border-radius:99px;}

/* ── Heading ── */
h1{font-size:1.5rem;margin-bottom:8px;
   background:linear-gradient(90deg,#7c3aed,#db2777);
   -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;}
.nivel-badge{
    display:inline-block;font-size:.72rem;font-weight:800;
    background:linear-gradient(135deg,#7c3aed,#db2777);color:#fff;
    border-radius:99px;padding:3px 10px;margin-left:8px;vertical-align:middle;
}

/* ── Progresso ── */
.progress-wrap{margin-bottom:10px;}
.progress-label{font-size:.78rem;font-weight:700;margin-bottom:3px;color:var(--accent);}
.pb-bg{height:9px;border-radius:99px;background:#e0e7ff;overflow:hidden;}
.pb-fill{
    height:100%;border-radius:99px;
    background:linear-gradient(90deg,#7c3aed,#ec4899,#f59e0b);
    transition:width .5s cubic-bezier(.34,1.56,.64,1);
}

/* ── Filtros ── */
.filter-bar{display:flex;flex-wrap:wrap;gap:5px;margin-top:8px;}
.filter-btn{
    font-size:.7rem;font-weight:700;
    border:1.5px solid #c7d2fe;border-radius:99px;
    padding:3px 10px;background:#f5f3ff;color:#4338ca;
    cursor:pointer;transition:background .15s,border-color .15s,color .15s;
    line-height:1.4;
}
.filter-btn:hover{background:#ede9fe;border-color:#7c3aed;}
.filter-btn.active{background:#7c3aed;border-color:#7c3aed;color:#fff;}

/* ── Cards ── */
.clues{display:grid;gap:7px;}
.clue-item{
    border:1.5px solid #e0e7ff;border-radius:12px;padding:9px 11px;
    background:#fafaff;
    transition:background .3s,border-color .3s,box-shadow .3s,transform .15s;
}
.clue-item.active-card{
    border-color:#7c3aed;
    box-shadow:0 0 0 3px rgba(124,58,237,.13);
}
.clue-item label{display:block;font-weight:600;margin-bottom:5px;font-size:.85rem;line-height:1.35;}
.clue-item input{
    width:100%;padding:9px 12px;
    border:1.5px solid #c7d2fe;border-radius:8px;
    font-size:1rem;text-transform:uppercase;letter-spacing:.06em;
    background:#f5f3ff;transition:border-color .25s,background .25s;outline:none;
}
.clue-item input:focus{border-color:#7c3aed;background:#fff;}

/* Correto */
.clue-item.correct{
    background:var(--card-ok-bg);border-color:var(--card-ok-border);
    box-shadow:0 3px 12px rgba(16,185,129,.15);
}
.clue-item.correct input{background:#ecfdf5;border-color:#6ee7b7;color:var(--ok);font-weight:700;}

/* ── Card compacto (feito) ── */
.card-done-row{display:none;align-items:center;gap:8px;}
.clue-item.done{padding:6px 11px;cursor:default;}
.clue-item.done .card-full{display:none;}
.clue-item.done .card-done-row{display:flex;}
.done-num{
    font-size:.75rem;font-weight:900;color:#7c3aed;
    background:#ede9fe;border-radius:99px;padding:1px 7px;flex-shrink:0;
}
.done-word{font-size:.88rem;font-weight:700;color:#166534;flex:1;letter-spacing:.04em;}
.done-cat{font-size:.65rem;font-weight:700;border-radius:5px;padding:1px 6px;flex-shrink:0;}
.done-icon{font-size:.85rem;flex-shrink:0;}

/* ── Badges ── */
.cat-badge{
    display:inline-block;font-size:.67rem;font-weight:700;
    border-radius:5px;padding:1px 6px;margin-right:3px;vertical-align:middle;
}
.hint-tag{
    display:inline-block;font-size:.67rem;font-weight:700;
    color:#059669;background:#d1fae5;border-radius:5px;padding:1px 6px;margin-left:3px;vertical-align:middle;
}
.status{margin-top:4px;font-size:.8rem;font-weight:700;min-height:1.1em;}
.status.ok{color:var(--ok);}
.status.bad{color:var(--bad);}

/* ── Animações ── */
@keyframes cardPop{
    0%{transform:scale(1);}35%{transform:scale(1.03);}65%{transform:scale(.98);}100%{transform:scale(1);}
}
.clue-item.popping{animation:cardPop .35s ease forwards;}
@keyframes shake{
    0%,100%{transform:translateX(0);}20%{transform:translateX(-6px);}
    40%{transform:translateX(6px);}60%{transform:translateX(-4px);}80%{transform:translateX(3px);}
}
.clue-item.shaking{animation:shake .4s ease;}

/* ── Acoes ── */
.actions{margin-top:14px;display:flex;gap:8px;flex-wrap:wrap;}
button,.link-button{
    border:none;cursor:pointer;border-radius:9px;
    padding:10px 16px;font-weight:700;font-size:.9rem;
    text-decoration:none;display:inline-block;
    transition:transform .12s,filter .12s;
}
button:hover,.link-button:hover{transform:translateY(-2px);filter:brightness(1.08);}
button{background:linear-gradient(135deg,#7c3aed,#db2777);color:#fff;
       box-shadow:0 4px 12px rgba(124,58,237,.32);}
.link-button{background:#e0e7ff;color:#312e81;}

/* ── Celebracao ── */
#celebracao{
    display:none;position:fixed;inset:0;
    align-items:center;justify-content:center;
    z-index:1000;background:rgba(30,27,75,.45);backdrop-filter:blur(4px);
}
#celebracao.show{display:flex;}
.cel-msg{
    background:#fff;border-radius:22px;padding:30px 46px;text-align:center;
    box-shadow:0 24px 70px rgba(0,0,0,.3);
    animation:msgIn .4s cubic-bezier(.34,1.56,.64,1) forwards;
}
@keyframes msgIn{from{transform:scale(.3);opacity:0;}to{transform:scale(1);opacity:1;}}
.cel-msg h2{font-size:2rem;margin-bottom:6px;
    background:linear-gradient(90deg,#7c3aed,#db2777,#f59e0b);
    -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;}
.cel-msg p{font-size:1rem;color:#555;margin-bottom:14px;}

/* ── Hint na descricao do tabuleiro ── */
.grid-hint{font-size:.82rem;color:#4338ca;margin-bottom:12px;line-height:1.5;}

@media(max-width:1050px){
    .container{grid-template-columns:1fr;}
    .grid-panel,.questions-panel{position:static;max-height:none;}
    .questions-panel{overflow:visible;}
    .clues-wrap{overflow:visible;max-height:none;}
}
</style>
</head>
<body>

<div id="confete"></div>
<div id="celebracao">
    <div class="cel-msg">
        <h2>🏆 Parabens!</h2>
        <p>Voce acertou todas as palavras do Nivel <%= nivel %> — <%= nivelLabel %>!</p>
        <div style="display:flex;gap:10px;justify-content:center;flex-wrap:wrap;">
            <% if (nivel < 11) { %>
            <button onclick="submitAndNext(<%= nivel + 1 %>)"
                    style="background:linear-gradient(135deg,#7c3aed,#db2777);color:#fff;border:none;cursor:pointer;padding:11px 22px;border-radius:10px;font-weight:700;font-size:1rem;">
                Proximo Nivel ➜
            </button>
            <% } %>
            <button onclick="document.getElementById('celebracao').classList.remove('show')"
                    style="background:#e0e7ff;color:#312e81;">Fechar</button>
        </div>
    </div>
</div>

<div class="container">

    <!-- ═══ Tabuleiro ═══ -->
    <div class="panel grid-panel">
        <h1>Palavras Cruzadas <span class="nivel-badge">Nivel <%= nivel %> — <%= nivelLabel %></span></h1>
        <p class="grid-hint">Clique em uma pergunta e veja as celulas acenderem aqui!</p>
        <div class="grid-wrap">
            <div class="grid">
                <%
                    for (int r = 0; r < board.length; r++) {
                        for (int c = 0; c < board[r].length; c++) {
                            char val = board[r][c];
                            if (val == '\0') { %>
                                <div class="cell-slot block"></div>
                <%          } else {
                                Integer cn = startCells.get(r + "," + c); %>
                                <div class="cell-slot" data-row="<%= r %>" data-col="<%= c %>"
                                     <% if (cn != null && large) { %>title="<%= cn %>"<% } %>>
                                    <% if (cn != null) { %><span class="num-badge"><%= cn %></span><% } %>
                                    <span class="cell-letter">&nbsp;</span>
                                </div>
                <%          }
                        }
                    }
                %>
            </div>
        </div>
    </div>

    <!-- ═══ Perguntas ═══ -->
    <div class="panel questions-panel">

        <div class="panel-head">
            <h1>Perguntas <span class="nivel-badge">N<%= nivel %> · <%= words.size() %> palavras</span></h1>

            <div class="progress-wrap">
                <div class="progress-label" id="progressLabel">0 de <%= words.size() %> acertadas</div>
                <div class="pb-bg"><div class="pb-fill" id="progressBar" style="width:0%"></div></div>
            </div>

            <div class="filter-bar" id="filterBar">
                <button class="filter-btn active" data-cat="Todas" onclick="setFilter('Todas')">Todas</button>
                <% for (String cat : catsInGame) {
                       String btnColor;
                       if ("SQL".equals(cat))            btnColor="#1d4ed8";
                       else if ("JavaScript".equals(cat))btnColor="#92400e";
                       else if ("Metodos".equals(cat))   btnColor="#6b21a8";
                       else                              btnColor="#065f46";
                %>
                <button class="filter-btn" data-cat="<%= cat %>" onclick="setFilter('<%= cat %>')"
                        style="--fc:<%= btnColor %>">
                    <%= cat %>
                </button>
                <% } %>
            </div>
        </div>

        <div class="clues-wrap">
            <form id="gameForm" method="post" action="<%= request.getContextPath() %>/jogo">
            <input type="hidden" id="goNextNivel" name="goNextNivel" value="">

            <div class="clues" id="cluesList">
            <%
                for (PlacedWord word : words) {
                    Integer number = Integer.valueOf(word.getNumber());
                    boolean isHint = hintWordNumber != null && hintWordNumber.equals(number);
                    Boolean ok = checks != null ? checks.get(number) : null;
                    boolean isCorrect = Boolean.TRUE.equals(ok);

                    String currentAnswer;
                    if (isHint && !submitted) {
                        currentAnswer = word.getEntry().getWord();
                    } else {
                        currentAnswer = answers != null ? answers.get(number) : "";
                        if (currentAnswer == null) currentAnswer = "";
                    }

                    String cat = word.getEntry().getCategory();
                    String catColor, catBg;
                    if ("SQL".equals(cat))            { catColor="#1d4ed8"; catBg="#dbeafe"; }
                    else if ("JavaScript".equals(cat)){ catColor="#92400e"; catBg="#fef3c7"; }
                    else if ("Metodos".equals(cat))   { catColor="#6b21a8"; catBg="#f3e8ff"; }
                    else                              { catColor="#065f46"; catBg="#d1fae5"; }
            %>
                <div id="card_<%= word.getNumber() %>"
                     class="clue-item<%= (isHint || isCorrect) ? " correct" : "" %>"
                     data-category="<%= cat %>">

                    <!-- Vista compacta (mostrada ao acertar) -->
                    <div class="card-done-row">
                        <span class="done-num"><%= word.getNumber() %></span>
                        <span class="done-cat" style="color:<%= catColor %>;background:<%= catBg %>"><%= cat %></span>
                        <span class="done-word"><%= word.getEntry().getWord() %></span>
                        <span class="done-icon">✅</span>
                    </div>

                    <!-- Vista completa -->
                    <div class="card-full">
                        <label for="answer_<%= word.getNumber() %>">
                            <span class="cat-badge" style="color:<%= catColor %>;background:<%= catBg %>"><%= cat %></span>
                            <strong><%= word.getNumber() %></strong> — <%= word.getEntry().getClue() %>
                            <% if (isHint) { %><span class="hint-tag">Dica</span><% } %>
                        </label>
                        <input
                            id="answer_<%= word.getNumber() %>"
                            name="answer_<%= word.getNumber() %>"
                            maxlength="30"
                            value="<%= currentAnswer %>"
                            placeholder="Digite sua resposta..."
                            <%= isHint
                                ? "readonly onfocus=\"setActive(" + word.getNumber() + ")\" onblur=\"setActive(null)\""
                                : "oninput=\"onInput(" + word.getNumber() + ",this)\" onfocus=\"setActive(" + word.getNumber() + ")\" onblur=\"setActive(null)\"" %> />
                        <div id="status_<%= word.getNumber() %>" class="status<% if (submitted && ok != null) { %> <%= isCorrect ? "ok" : "bad" %><% } %>">
                            <% if (submitted && ok != null) { %>
                                <%= isCorrect ? "✅ Correta!" : "❌ Incorreta" %>
                            <% } %>
                        </div>
                    </div>
                </div>
            <% } %>
            </div>

            <div class="actions">
                <% if (!gameComplete) { %>
                <button type="submit">Conferir respostas</button>
                <% } %>
                <% if (gameComplete && nivel < 11) { %>
                <a href="<%= request.getContextPath() %>/jogo?nivel=<%= nivel + 1 %>"
                   style="background:linear-gradient(135deg,#7c3aed,#db2777);color:#fff;
                          padding:10px 16px;border-radius:9px;font-weight:700;font-size:.9rem;
                          text-decoration:none;display:inline-block;
                          box-shadow:0 4px 12px rgba(124,58,237,.32);">
                    Proximo Nivel ➜
                </a>
                <% } %>
                <a class="link-button" href="<%= request.getContextPath() %>/">Trocar nivel</a>
            </div>
            </form>
        </div>
    </div>
</div>

<script>
const WORDS = [
<%
    for (int wi = 0; wi < words.size(); wi++) {
        PlacedWord pw = words.get(wi);
        boolean ih = hintWordNumber != null && hintWordNumber.equals(Integer.valueOf(pw.getNumber()));
        Boolean ok2 = checks != null ? checks.get(Integer.valueOf(pw.getNumber())) : null;
        String cat2 = pw.getEntry().getCategory();
%>
  {number:<%= pw.getNumber() %>,word:"<%= pw.getEntry().getWord() %>",
   row:<%= pw.getRow() %>,col:<%= pw.getCol() %>,
   orientation:"<%= pw.getOrientation().name() %>",
   cat:"<%= cat2 %>",
   isHint:<%= ih %>,isCorrect:<%= Boolean.TRUE.equals(ok2) %>}<%= wi < words.size()-1 ? "," : "" %>
<% } %>
];
const TOTAL    = WORDS.length;
const SUBMITTED = <%= submitted %>;

/* ── Estado ── */
const correctSet = new Set();
let typingMap  = {};
let activeNum  = null;
let activeFilter = 'Todas';

/* ── Utilitários ── */
function norm(s){
    return s.normalize('NFD').replace(/[\u0300-\u036f]/g,'').toUpperCase().replace(/[^A-Z0-9]/g,'');
}
function getCell(r,c){
    return document.querySelector('[data-row="'+r+'"][data-col="'+c+'"]');
}
function wordCells(w){
    const cells=[];
    for(let i=0;i<w.word.length;i++){
        const r=w.orientation==='VERTICAL'?w.row+i:w.row;
        const c=w.orientation==='HORIZONTAL'?w.col+i:w.col;
        cells.push({r,c,letter:w.word[i],idx:i});
    }
    return cells;
}

/* ── Renderização do tabuleiro ── */
function renderAll(){
    // 1. limpa tudo
    document.querySelectorAll('[data-row]').forEach(el=>{
        el.querySelector('.cell-letter').textContent=' ';
        el.classList.remove('c-ok','c-tok','c-terr','c-active','pop-anim');
    });

    // 2. letras digitadas (menor prioridade)
    WORDS.forEach(w=>{
        if(correctSet.has(w.number)) return;
        const typed=(typingMap[w.number]||'').toUpperCase().replace(/[^A-Z0-9]/g,'');
        if(!typed) return;
        wordCells(w).forEach(({r,c,letter,idx})=>{
            if(idx>=typed.length) return;
            const cell=getCell(r,c);if(!cell)return;
            const ch=typed[idx];
            cell.querySelector('.cell-letter').textContent=ch;
            cell.classList.add(ch===letter?'c-tok':'c-terr');
        });
    });

    // 3. destaque de palavra ativa (sobre digitação parcial, abaixo de correta)
    if(activeNum!==null){
        const aw=WORDS.find(x=>x.number===activeNum);
        if(aw){
            wordCells(aw).forEach(({r,c})=>{
                const cell=getCell(r,c);if(!cell)return;
                if(!cell.classList.contains('c-ok')&&
                   !cell.classList.contains('c-tok')&&
                   !cell.classList.contains('c-terr')){
                    cell.classList.add('c-active');
                }
            });
        }
    }

    // 4. palavras corretas sempre por cima
    correctSet.forEach(num=>{
        const w=WORDS.find(x=>x.number===num);if(!w)return;
        wordCells(w).forEach(({r,c,letter})=>{
            const cell=getCell(r,c);if(!cell)return;
            cell.querySelector('.cell-letter').textContent=letter;
            cell.classList.remove('c-tok','c-terr','c-active','pop-anim');
            cell.classList.add('c-ok');
        });
    });
}

/* ── Progresso ── */
function updateProgress(){
    const n=correctSet.size;
    document.getElementById('progressLabel').textContent=n+' de '+TOTAL+' acertadas';
    document.getElementById('progressBar').style.width=(n/TOTAL*100)+'%';
    if(n===TOTAL) setTimeout(celebrar,350);
}

/* ── Status do card ── */
function setStatus(num,correct,typedNorm){
    const el=document.getElementById('status_'+num);if(!el)return;
    const w=WORDS.find(x=>x.number===num);
    const wLen=w?w.word.length:0;
    if(correct){
        el.className='status ok';el.textContent='✅ Correta!';
    }else if(SUBMITTED||typedNorm.length>=wLen){
        el.className='status bad';el.textContent='❌ Incorreta';
    }else{
        el.className='status';el.textContent='';
    }
}

/* ── Foco ativo ── */
function setActive(num){
    if(activeNum!==null){
        const prev=document.getElementById('card_'+activeNum);
        if(prev) prev.classList.remove('active-card');
    }
    activeNum=num;
    if(num!==null){
        const card=document.getElementById('card_'+num);
        if(card) card.classList.add('active-card');
    }
    renderAll();
}

/* ── Avanço automático ── */
function focusNext(fromNum){
    const remaining=WORDS.filter(w=>!correctSet.has(w.number)&&!w.isHint);
    if(!remaining.length) return;
    const idx=remaining.findIndex(w=>w.number>fromNum);
    const next=idx>=0?remaining[idx]:remaining[0];
    // Se estiver filtrado, muda para "Todas"
    const card=document.getElementById('card_'+next.number);
    if(card&&card.style.display==='none') setFilter('Todas');
    setTimeout(()=>{
        const el=document.getElementById('answer_'+next.number);
        if(el){
            el.focus();
            card&&card.scrollIntoView({behavior:'smooth',block:'nearest'});
        }
    },180);
}

/* ── Filtro ── */
function setFilter(cat){
    activeFilter=cat;
    document.querySelectorAll('.filter-btn').forEach(b=>{
        b.classList.toggle('active',b.dataset.cat===cat);
    });
    document.querySelectorAll('.clue-item').forEach(card=>{
        const show=cat==='Todas'||card.dataset.category===cat;
        card.style.display=show?'':'none';
    });
}

/* ── Input handler ── */
function onInput(num,inputEl){
    const w=WORDS.find(x=>x.number===num);
    const card=document.getElementById('card_'+num);
    if(!w||!card)return;

    typingMap[num]=inputEl.value;
    const typedNorm=norm(inputEl.value);
    const wordNorm=norm(w.word);
    const wasCorrect=correctSet.has(num);
    const isCorrect=(typedNorm===wordNorm);

    if(isCorrect&&!wasCorrect){
        correctSet.add(num);
        card.classList.add('correct');
        card.classList.remove('popping');
        void card.offsetWidth;
        card.classList.add('popping');
        setTimeout(()=>{
            animateWordCells(w);
            card.classList.add('done');
            focusNext(num);
        },420);
    }else if(!isCorrect&&wasCorrect){
        correctSet.delete(num);
        card.classList.remove('correct','popping','done');
    }

    setStatus(num,isCorrect,typedNorm);
    renderAll();
    updateProgress();
}

function animateWordCells(w){
    wordCells(w).forEach(({r,c},i)=>{
        setTimeout(()=>{
            const cell=getCell(r,c);if(!cell)return;
            cell.classList.remove('pop-anim');void cell.offsetWidth;
            cell.classList.add('pop-anim');
        },i*30);
    });
}

/* ── Confete ── */
const CORES=['#f94144','#f3722c','#f9c74f','#90be6d','#43aa8b','#577590','#e040fb','#00b4d8','#ff6b6b','#ffd93d'];
function lancarConfete(){
    const el=document.getElementById('confete');el.innerHTML='';
    for(let i=0;i<140;i++){
        const p=document.createElement('div');p.className='cp';
        const w=5+Math.random()*10,h=7+Math.random()*14;
        p.style.cssText=[
            'left:'+(Math.random()*100)+'%','width:'+w+'px','height:'+h+'px',
            'background:'+CORES[Math.floor(Math.random()*CORES.length)],
            'border-radius:'+(Math.random()>.5?'50%':'2px'),
            'animation-duration:'+(1.5+Math.random()*2)+'s',
            'animation-delay:'+(Math.random()*1.2)+'s'
        ].join(';');
        el.appendChild(p);
    }
    setTimeout(()=>el.innerHTML='',5500);
}
function celebrar(){lancarConfete();document.getElementById('celebracao').classList.add('show');}

/* ── Proximo nivel via submit ── */
function submitAndNext(n){
    document.getElementById('goNextNivel').value=n;
    document.getElementById('gameForm').submit();
}

/* ── Shake nos erros ── */
function shakeWrong(){
    WORDS.forEach(w=>{
        if(!correctSet.has(w.number)&&!w.isHint){
            const c=document.getElementById('card_'+w.number);if(!c)return;
            c.classList.remove('shaking');void c.offsetWidth;c.classList.add('shaking');
        }
    });
}

/* ── Boot ── */
document.addEventListener('DOMContentLoaded',()=>{
    // Inicializa estado
    WORDS.forEach(w=>{
        if(w.isHint||w.isCorrect){
            correctSet.add(w.number);
            typingMap[w.number]=w.word;
            const card=document.getElementById('card_'+w.number);
            if(card) card.classList.add('done');
        }
    });
    renderAll();
    updateProgress();

    // Tecla Enter avança para próximo campo
    document.querySelectorAll('.clue-item input:not([readonly])').forEach(el=>{
        el.addEventListener('keydown',e=>{
            if(e.key==='Enter'){
                e.preventDefault();
                const num=parseInt(el.id.replace('answer_',''));
                focusNext(num);
            }
        });
    });

    if(SUBMITTED){
        setTimeout(shakeWrong,220);
        if(correctSet.size===TOTAL) setTimeout(celebrar,650);
    }
});
</script>
</body>
</html>
