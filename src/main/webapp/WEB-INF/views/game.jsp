<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="com.palavracruzada.model.CrosswordGame" %>
<%@ page import="com.palavracruzada.model.PlacedWord" %>
<%
    CrosswordGame game = (CrosswordGame) request.getAttribute("game");
    boolean submitted = Boolean.TRUE.equals(request.getAttribute("submitted"));
    Integer score = (Integer) request.getAttribute("score");
    Map<Integer, String> answers = (Map<Integer, String>) request.getAttribute("answers");
    Map<Integer, Boolean> checks  = (Map<Integer, Boolean>) request.getAttribute("checks");
    char[][] board = game.getBoard();
    List<PlacedWord> words = game.getPlacedWords();

    Map<String, Integer> startCells = new HashMap<String, Integer>();
    for (PlacedWord pw : words) {
        startCells.put(pw.getRow() + "," + pw.getCol(), Integer.valueOf(pw.getNumber()));
    }
    Integer hintWordNumber = (Integer) request.getAttribute("hintWordNumber");
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Cruzadinha</title>
<style>
:root {
    --bg1: #312e81; --bg2: #4c1d95;
    --panel: #fff;
    --grid-bg: #1e1b4b;
    --cell-empty: #f5f3ff;
    --cell-ok:    #bbf7d0;
    --cell-ok-txt:#166534;
    --cell-typ-ok:#d1fae5;
    --cell-typ-err:#fee2e2;
    --cell-typ-err-txt:#991b1b;
    --num-color:  #7c3aed;
    --ink: #1e1b4b;
    --accent: #7c3aed;
    --card-ok-bg:#f0fdf4; --card-ok-border:#6ee7b7;
    --ok:#15803d; --bad:#dc2626;
}
*{box-sizing:border-box;margin:0;padding:0;}
body{
    font-family:"Trebuchet MS","Segoe UI",sans-serif;
    color:var(--ink);
    min-height:100vh;
    background:linear-gradient(135deg,var(--bg1) 0%,var(--bg2) 100%);
}

/* ─── Confete ─── */
#confete{position:fixed;inset:0;pointer-events:none;z-index:999;overflow:hidden;}
.cp{
    position:absolute;top:-20px;
    animation:cair linear forwards;
    border-radius:2px;
}
@keyframes cair{to{transform:translateY(110vh) rotate(720deg);opacity:0;}}

/* ─── Layout ─── */
.container{
    width:min(1500px,98%);
    margin:20px auto;
    display:grid;
    grid-template-columns:3fr 2fr;
    gap:20px;
    align-items:start;
}
.panel{
    background:var(--panel);
    border-radius:18px;
    padding:22px;
    box-shadow:0 12px 40px rgba(79,70,229,.25);
}
h1{font-size:1.65rem;margin-bottom:10px;
   background:linear-gradient(90deg,#7c3aed,#db2777);
   -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;}

/* ─── Progresso ─── */
.progress-wrap{margin-bottom:14px;}
.progress-label{font-size:.82rem;font-weight:700;margin-bottom:4px;color:var(--accent);}
.pb-bg{height:11px;border-radius:99px;background:#e0e7ff;overflow:hidden;}
.pb-fill{
    height:100%;border-radius:99px;
    background:linear-gradient(90deg,#7c3aed,#ec4899,#f59e0b);
    transition:width .55s cubic-bezier(.34,1.56,.64,1);
}

/* ─── Tabuleiro ─── */
.grid-wrap{overflow-x:auto;overflow-y:auto;padding-bottom:6px;}
.grid{
    display:inline-grid;
    grid-template-columns:repeat(21,46px);
    gap:3px;
    background:var(--grid-bg);
    padding:10px;
    border-radius:14px;
}

/* Cada slot é só a caixa da letra — sem subdivisão */
.cell-slot{
    width:46px;height:46px;
    border-radius:5px;
    background:var(--cell-empty);
    display:flex;align-items:center;justify-content:center;
    font-weight:700;font-size:19px;
    position:relative;
    transition:background .2s, color .2s;
}
.cell-slot.block{background:#0f0a2d;}
.cell-slot.c-ok  {background:var(--cell-ok);  color:var(--cell-ok-txt);}
.cell-slot.c-tok {background:var(--cell-typ-ok);}
.cell-slot.c-terr{background:var(--cell-typ-err); color:var(--cell-typ-err-txt);}

/* Número no canto — grande, colorido, sem afetar o layout */
.num-badge{
    position:absolute;
    top:3px;left:4px;
    font-size:13px;
    font-weight:900;
    line-height:1;
    color:#7c3aed;
}

.cell-letter{pointer-events:none;}

@keyframes letraPop{
    0%  {transform:scale(0) rotate(-20deg);opacity:0;}
    60% {transform:scale(1.3) rotate(5deg);opacity:1;}
    100%{transform:scale(1) rotate(0);opacity:1;}
}
.cell-slot.pop-anim .cell-letter{animation:letraPop .32s cubic-bezier(.34,1.56,.64,1) both;}

/* ─── Cards ─── */
.clues{margin-top:14px;display:grid;gap:10px;}
.clue-item{
    border:1.5px solid #e0e7ff;
    border-radius:14px;padding:10px;
    background:#fafaff;
    transition:background .35s,border-color .35s,transform .2s,box-shadow .35s;
}
.clue-item label{display:block;font-weight:600;margin-bottom:6px;font-size:.9rem;line-height:1.35;}
.clue-item input{
    width:100%;padding:11px 14px;
    border:1.5px solid #c7d2fe;border-radius:9px;
    font-size:1.05rem;text-transform:uppercase;letter-spacing:.08em;
    background:#f5f3ff;
    transition:border-color .3s,background .3s;
    outline:none;
}
.clue-item input:focus{border-color:#7c3aed;background:#fff;}

/* Correto */
.clue-item.correct{
    background:var(--card-ok-bg);border-color:var(--card-ok-border);
    box-shadow:0 4px 16px rgba(16,185,129,.18);
}
.clue-item.correct input{background:#ecfdf5;border-color:#6ee7b7;color:var(--ok);font-weight:700;}

@keyframes cardPop{
    0%  {transform:scale(1);}
    35% {transform:scale(1.04);}
    65% {transform:scale(.97);}
    100%{transform:scale(1);}
}
.clue-item.popping{animation:cardPop .4s ease forwards;}

@keyframes shake{
    0%,100%{transform:translateX(0);}
    20%    {transform:translateX(-7px);}
    40%    {transform:translateX(7px);}
    60%    {transform:translateX(-5px);}
    80%    {transform:translateX(4px);}
}
.clue-item.shaking{animation:shake .45s ease;}

/* Badges de categoria */
.cat-badge{
    display:inline-block;font-size:.7rem;font-weight:700;
    border-radius:6px;padding:1px 7px;margin-right:4px;vertical-align:middle;
}
.hint-tag{
    display:inline-block;font-size:.7rem;font-weight:700;
    color:#059669;background:#d1fae5;
    border-radius:6px;padding:1px 7px;margin-left:4px;vertical-align:middle;
}

/* Status */
.status{margin-top:6px;font-size:.85rem;font-weight:700;min-height:1.2em;}
.status.ok {color:var(--ok);}
.status.bad{color:var(--bad);}

/* Score */
.score{
    margin:10px 0;padding:10px;border-radius:10px;
    background:linear-gradient(90deg,#fef9c3,#fde68a);
    border:1px solid #fbbf24;font-weight:700;color:#92400e;
    font-size:1.05rem;
}

/* ─── Ações ─── */
.actions{margin-top:16px;display:flex;gap:10px;flex-wrap:wrap;}
button,.link-button{
    border:none;cursor:pointer;border-radius:10px;
    padding:11px 18px;font-weight:700;font-size:.95rem;
    text-decoration:none;display:inline-block;
    transition:transform .15s,filter .15s;
}
button:hover,.link-button:hover{transform:translateY(-2px);filter:brightness(1.08);}
button{background:linear-gradient(135deg,#7c3aed,#db2777);color:#fff;
       box-shadow:0 4px 14px rgba(124,58,237,.35);}
.link-button{background:#e0e7ff;color:#312e81;}

/* ─── Celebração ─── */
#celebracao{
    display:none;position:fixed;inset:0;
    align-items:center;justify-content:center;
    z-index:1000;background:rgba(30,27,75,.45);backdrop-filter:blur(4px);
}
#celebracao.show{display:flex;}
.cel-msg{
    background:#fff;border-radius:22px;
    padding:32px 50px;text-align:center;
    box-shadow:0 24px 70px rgba(0,0,0,.3);
    animation:msgIn .45s cubic-bezier(.34,1.56,.64,1) forwards;
}
@keyframes msgIn{from{transform:scale(.35);opacity:0;}to{transform:scale(1);opacity:1;}}
.cel-msg h2{font-size:2.2rem;margin-bottom:8px;
    background:linear-gradient(90deg,#7c3aed,#db2777,#f59e0b);
    -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;}
.cel-msg p{font-size:1.1rem;color:#555;margin-bottom:16px;}
.cel-msg button{pointer-events:auto;}

@media(max-width:1000px){.container{grid-template-columns:1fr;}}
</style>
</head>
<body>

<div id="confete"></div>
<div id="celebracao">
    <div class="cel-msg">
        <h2>🏆 Parabens!</h2>
        <p>Voce acertou todas as palavras!</p>
        <button onclick="document.getElementById('celebracao').classList.remove('show')">Fechar</button>
    </div>
</div>

<div class="container">

    <!-- ═══ Tabuleiro ═══ -->
    <div class="panel">
        <h1>Palavras Cruzadas</h1>
        <p style="font-size:.88rem;color:#4338ca;margin-bottom:14px;">
            Digite as respostas ao lado — as letras aparecem aqui a cada tecla!
        </p>
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
                                <div class="cell-slot" data-row="<%= r %>" data-col="<%= c %>">
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
    <div class="panel">
        <h1>Perguntas</h1>

        <div class="progress-wrap">
            <div class="progress-label" id="progressLabel">0 de <%= words.size() %> acertadas</div>
            <div class="pb-bg"><div class="pb-fill" id="progressBar" style="width:0%"></div></div>
        </div>

        <% if (submitted && score != null) { %>
            <div class="score">Pontuacao final: <%= score %> de <%= words.size() %> ⭐</div>
        <% } %>

        <form method="post" action="<%= request.getContextPath() %>/jogo">
            <div class="clues">
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

                        // Cor do badge por categoria
                        String cat = word.getEntry().getCategory();
                        String catColor, catBg;
                        if ("SQL".equals(cat))            { catColor="#1d4ed8"; catBg="#dbeafe"; }
                        else if ("JavaScript".equals(cat)){ catColor="#92400e"; catBg="#fef3c7"; }
                        else if ("Metodos".equals(cat))   { catColor="#6b21a8"; catBg="#f3e8ff"; }
                        else                              { catColor="#065f46"; catBg="#d1fae5"; }
                %>
                    <div id="card_<%= word.getNumber() %>"
                         class="clue-item<%= (isHint || isCorrect) ? " correct" : "" %>">
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
                                ? "readonly"
                                : "oninput=\"onInput(" + word.getNumber() + ",this)\"" %> />
                        <div id="status_<%= word.getNumber() %>" class="status<% if (submitted && ok != null) { %> <%= isCorrect ? "ok" : "bad" %><% } %>">
                            <% if (submitted && ok != null) { %>
                                <%= isCorrect ? "✅ Correta!" : "❌ Incorreta" %>
                            <% } %>
                        </div>
                    </div>
                <% } %>
            </div>
            <div class="actions">
                <button type="submit">Conferir respostas</button>
                <a class="link-button" href="<%= request.getContextPath() %>/jogo">Novo jogo</a>
            </div>
        </form>
    </div>
</div>

<script>
const WORDS = [
<%
    for (int wi = 0; wi < words.size(); wi++) {
        PlacedWord pw = words.get(wi);
        boolean ih = hintWordNumber != null && hintWordNumber.equals(Integer.valueOf(pw.getNumber()));
        Boolean ok2 = checks != null ? checks.get(Integer.valueOf(pw.getNumber())) : null;
%>
  {number:<%= pw.getNumber() %>,word:"<%= pw.getEntry().getWord() %>",
   row:<%= pw.getRow() %>,col:<%= pw.getCol() %>,
   orientation:"<%= pw.getOrientation().name() %>",
   isHint:<%= ih %>,isCorrect:<%= Boolean.TRUE.equals(ok2) %>}<%= wi < words.size()-1 ? "," : "" %>
<% } %>
];
const TOTAL = WORDS.length;
const SUBMITTED = <%= submitted %>;

/* ── Estado ── */
const correctSet = new Set();
let typingMap = {};   // wordNumber → string digitada

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
        el.querySelector('.cell-letter').textContent=' ';
        el.classList.remove('c-ok','c-tok','c-terr','pop-anim');
    });

    // 2. letras de palavras com digitação (menor prioridade)
    WORDS.forEach(w=>{
        if(correctSet.has(w.number)) return;
        const typed=(typingMap[w.number]||'').toUpperCase().replace(/[^A-Z0-9]/g,'');
        if(!typed) return;
        wordCells(w).forEach(({r,c,letter,idx})=>{
            if(idx>=typed.length) return;
            const cell=getCell(r,c);
            if(!cell) return;
            const ch=typed[idx];
            cell.querySelector('.cell-letter').textContent=ch;
            cell.classList.remove('c-tok','c-terr');
            cell.classList.add(ch===letter?'c-tok':'c-terr');
        });
    });

    // 3. palavras corretas sempre por cima
    correctSet.forEach(num=>{
        const w=WORDS.find(x=>x.number===num);
        if(!w) return;
        wordCells(w).forEach(({r,c,letter})=>{
            const cell=getCell(r,c);
            if(!cell) return;
            cell.querySelector('.cell-letter').textContent=letter;
            cell.classList.remove('c-tok','c-terr','pop-anim');
            cell.classList.add('c-ok');
        });
    });
}

/* ── Progresso ── */
function updateProgress(){
    const n=correctSet.size;
    document.getElementById('progressLabel').textContent=n+' de '+TOTAL+' acertadas';
    document.getElementById('progressBar').style.width=(n/TOTAL*100)+'%';
    if(n===TOTAL)setTimeout(celebrar,350);
}

/* ── Status do card ── */
function setStatus(num, correct, typedNorm){
    const el=document.getElementById('status_'+num);
    if(!el) return;
    const w=WORDS.find(x=>x.number===num);
    const wordLen = w ? w.word.length : 0;
    if(correct){
        el.className='status ok';
        el.textContent='✅ Correta!';
    } else if(SUBMITTED || typedNorm.length >= wordLen){
        el.className='status bad';
        el.textContent='❌ Incorreta';
    } else {
        el.className='status';
        el.textContent='';
    }
}

/* ── Handlers ── */
function onInput(num, inputEl){
    const w=WORDS.find(x=>x.number===num);
    const card=document.getElementById('card_'+num);
    if(!w||!card)return;

    typingMap[num]=inputEl.value;
    const typedNorm=norm(inputEl.value);
    const wordNorm=norm(w.word);
    const wasCorrect=correctSet.has(num);
    const isCorrect=(typedNorm===wordNorm);

    if(isCorrect && !wasCorrect){
        correctSet.add(num);
        card.classList.add('correct');
        card.classList.remove('popping');
        void card.offsetWidth;
        card.classList.add('popping');
        setTimeout(()=>animateWordCells(w),0);
    } else if(!isCorrect && wasCorrect){
        correctSet.delete(num);
        card.classList.remove('correct','popping');
    }

    setStatus(num, isCorrect, typedNorm);
    renderAll();
    updateProgress();
}

function animateWordCells(w){
    wordCells(w).forEach(({r,c},i)=>{
        setTimeout(()=>{
            const cell=getCell(r,c);
            if(!cell)return;
            cell.classList.remove('pop-anim');
            void cell.offsetWidth;
            cell.classList.add('pop-anim');
        },i*35);
    });
}

/* ── Confete ── */
const CORES=['#f94144','#f3722c','#f9c74f','#90be6d','#43aa8b','#577590','#e040fb','#00b4d8','#ff6b6b','#ffd93d'];
function lancarConfete(){
    const el=document.getElementById('confete');
    el.innerHTML='';
    for(let i=0;i<130;i++){
        const p=document.createElement('div');
        p.className='cp';
        const w=6+Math.random()*10, h=8+Math.random()*14;
        p.style.cssText=[
            'left:'+(Math.random()*100)+'%',
            'width:'+w+'px','height:'+h+'px',
            'background:'+CORES[Math.floor(Math.random()*CORES.length)],
            'border-radius:'+(Math.random()>.5?'50%':'2px'),
            'animation-duration:'+(1.6+Math.random()*2)+'s',
            'animation-delay:'+(Math.random()*1.2)+'s'
        ].join(';');
        el.appendChild(p);
    }
    setTimeout(()=>el.innerHTML='',5000);
}
function celebrar(){
    lancarConfete();
    document.getElementById('celebracao').classList.add('show');
}

/* ── Shake nos erros pós-envio ── */
function shakeWrong(){
    WORDS.forEach(w=>{
        if(!correctSet.has(w.number)&&!w.isHint){
            const c=document.getElementById('card_'+w.number);
            if(!c)return;
            c.classList.remove('shaking');void c.offsetWidth;
            c.classList.add('shaking');
        }
    });
}

/* ── Boot ── */
document.addEventListener('DOMContentLoaded',()=>{
    WORDS.forEach(w=>{
        if(w.isHint||w.isCorrect){
            correctSet.add(w.number);
            if(w.isHint||w.isCorrect) typingMap[w.number]=w.word;
        }
    });
    renderAll();
    updateProgress();
    if(SUBMITTED){
        setTimeout(shakeWrong,250);
        if(correctSet.size===TOTAL)setTimeout(celebrar,700);
    }
});
</script>
</body>
</html>
