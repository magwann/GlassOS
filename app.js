/* =====================================================================
   GlassOS prototype — behaviour
   ===================================================================== */

/* ---- SVG glyphs (all rendered inside the square .app-tile) ---- */
const GLYPHS = {
  files:    `<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='1.8' stroke-linejoin='round'><path d='M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z'/></svg>`,
  welcome:  `<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='1.8' stroke-linecap='round' stroke-linejoin='round'><path d='M12 3l2.5 5 5.5.8-4 3.9 1 5.5L12 15.8 7 18.2l1-5.5-4-3.9 5.5-.8z'/></svg>`,
  settings: `<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='1.8'><circle cx='12' cy='12' r='3.2'/><path d='M12 2v3M12 19v3M2 12h3M19 12h3M4.9 4.9l2.1 2.1M17 17l2.1 2.1M19.1 4.9L17 7M7 17l-2.1 2.1' stroke-linecap='round'/></svg>`,
  browser:  `<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='1.8'><circle cx='12' cy='12' r='9'/><path d='M3 12h18M12 3c2.8 3 2.8 15 0 18M12 3c-2.8 3-2.8 15 0 18'/></svg>`,
  mail:     `<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='1.8' stroke-linejoin='round'><rect x='3' y='5' width='18' height='14' rx='2'/><path d='M3 7l9 6 9-6'/></svg>`,
  music:    `<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='1.8' stroke-linecap='round'><path d='M9 18V6l10-2v12'/><circle cx='6' cy='18' r='3'/><circle cx='16' cy='16' r='3'/></svg>`,
  photos:   `<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='1.8' stroke-linejoin='round'><rect x='3' y='4' width='18' height='16' rx='2'/><circle cx='8.5' cy='9.5' r='1.8'/><path d='M4 18l5-5 4 4 3-3 4 4'/></svg>`,
  terminal: `<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='1.8' stroke-linecap='round' stroke-linejoin='round'><rect x='3' y='4' width='18' height='16' rx='2'/><path d='M7 9l3 3-3 3M13 15h4'/></svg>`,
  calc:     `<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='1.8' stroke-linecap='round'><rect x='4' y='3' width='16' height='18' rx='2'/><path d='M8 7h8M8 12h.01M12 12h.01M16 12h.01M8 16h.01M12 16h.01M16 16h.01'/></svg>`,
  wifi:     `<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2' stroke-linecap='round'><path d='M2 8.5a16 16 0 0 1 20 0M5 12a11 11 0 0 1 14 0M8 15.5a6 6 0 0 1 8 0'/><circle cx='12' cy='19' r='1' fill='white'/></svg>`,
  volume:   `<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2' stroke-linejoin='round'><path d='M4 9v6h4l5 4V5L8 9z'/><path d='M17 8a5 5 0 0 1 0 8' stroke-linecap='round'/></svg>`,
  battery:  `<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2'><rect x='2' y='7' width='18' height='10' rx='2'/><path d='M22 10v4'/><rect x='4' y='9' width='11' height='6' rx='1' fill='white' stroke='none'/></svg>`,
};

/* ---- app registry ---- */
const APPS = {
  welcome:  { name: "Welcome",   glyph: "welcome",  tint: "tint-aqua" },
  files:    { name: "Files",     glyph: "files",    tint: "tint-teal" },
  settings: { name: "Settings",  glyph: "settings", tint: "tint-violet" },
  browser:  { name: "Aqua Web",  glyph: "browser",  tint: "tint-aqua" },
  mail:     { name: "Mail",      glyph: "mail",     tint: "tint-teal" },
  music:    { name: "Music",     glyph: "music",    tint: "tint-violet" },
  photos:   { name: "Photos",    glyph: "photos",   tint: "tint-warm" },
  terminal: { name: "Terminal",  glyph: "terminal", tint: "tint-leaf" },
  calc:     { name: "Calculator",glyph: "calc",     tint: "tint-aqua" },
};

const svgURL = (s) => `url("data:image/svg+xml;utf8,${encodeURIComponent(s)}")`;

/* paint a square app-tile element */
function paintTile(el, glyph, tint) {
  el.classList.add(tint);
  el.style.setProperty("--x", "0");
  const style = document.createElement("style");
  // set glyph via inline background on ::after using a data attribute technique
  el.setAttribute("data-glyph", glyph);
}
/* since ::after can't take inline bg, inject a child glyph layer instead */
function makeTile(glyph, tint, size) {
  const t = document.createElement("div");
  t.className = "app-tile " + tint;
  const g = document.createElement("div");
  g.style.position = "absolute";
  g.style.inset = "0";
  g.style.backgroundImage = svgURL(GLYPHS[glyph]);
  g.style.backgroundRepeat = "no-repeat";
  g.style.backgroundPosition = "center";
  g.style.backgroundSize = "52%";
  g.style.filter = "drop-shadow(0 1px 2px rgba(0,40,70,0.35))";
  t.appendChild(g);
  if (size) { t.style.width = t.style.height = size + "px"; }
  return t;
}

/* ---- desktop icons ---- */
document.querySelectorAll(".desk-icon").forEach((di) => {
  const app = di.dataset.app;
  const holder = di.querySelector(".app-tile");
  const a = APPS[app];
  holder.replaceWith(makeTile(a.glyph, a.tint));
  di.addEventListener("dblclick", () => openApp(app));
  // single-click also opens for prototype friendliness
  let clicks = 0;
  di.addEventListener("click", () => { clicks++; setTimeout(() => { if (clicks) openApp(app); clicks = 0; }, 220); });
});

/* ---- start menu grid ---- */
const startGrid = document.getElementById("startGrid");
Object.keys(APPS).forEach((key) => {
  const a = APPS[key];
  const item = document.createElement("div");
  item.className = "start-app";
  item.appendChild(makeTile(a.glyph, a.tint, 52));
  const label = document.createElement("span");
  label.textContent = a.name;
  item.appendChild(label);
  item.addEventListener("click", () => { openApp(key); toggleStart(false); });
  startGrid.appendChild(item);
});

/* ---- tray icons ---- */
document.querySelectorAll(".tray-icon").forEach((t) => {
  t.style.backgroundImage = svgURL(GLYPHS[t.dataset.glyph]);
});

/* ---- window management ---- */
const windowsLayer = document.getElementById("windows");
const taskApps = document.getElementById("taskApps");
const openWindows = {}; // app -> {win, taskBtn}
let zTop = 10;

const WINDOW_CONTENT = {
  welcome: () => `
    <div class="readable">
      <h2>Welcome to GlassOS</h2>
      <p>A clean, transparent desktop for FreeBSD — Frutiger Aero, reborn for 2026.</p>
      <p>Everything you see is live glass: layered blur, gloss highlights, and light. Solids appear only where text needs to stay readable.</p>
      <span class="pill-btn">Take the tour</span>
    </div>`,
  files: () => {
    const items = ["Documents","Downloads","Pictures","Music","Projects","freebsd.conf"];
    const glyphs = ["files","files","photos","music","files","terminal"];
    return `<div class="file-grid">` + items.map((n,i)=>`
      <div class="file-item"><div class="file-tile" data-g="${glyphs[i]}"></div><span>${n}</span></div>`).join("") + `</div>`;
  },
  settings: () => `
    <div style="display:flex;flex-direction:column;gap:2px">
      <div class="setting-row"><span class="label">Transparency</span><div class="toggle on" data-toggle></div></div>
      <div class="setting-row"><span class="label">Live wallpaper</span><div class="toggle on" data-toggle></div></div>
      <div class="setting-row"><span class="label">Glass blur intensity</span><div class="toggle on" data-toggle></div></div>
      <div class="setting-row"><span class="label">Night glass (dark mode)</span><div class="toggle" data-toggle></div></div>
      <div class="setting-row"><span class="label">Reduce motion</span><div class="toggle" data-toggle></div></div>
    </div>`,
  browser: () => `<div class="readable"><h2>Aqua Web</h2><p>A glassy browser shell would live here — address bar, tabs as squircle chips, and a translucent chrome that lets the page glow through.</p></div>`,
  terminal: () => `<div style="font-family:ui-monospace,Menlo,monospace;font-size:13px;color:#eaffff;background:rgba(6,26,44,0.55);border-radius:12px;padding:16px;border:1px solid rgba(255,255,255,0.2)"><div>GlassOS 1.0 — FreeBSD 14.2-RELEASE</div><div style="opacity:.8">Welcome, jack.</div><br><div>jack@glass:~$ <span style="opacity:.7">uname -sr</span></div><div>FreeBSD 14.2-RELEASE</div><div>jack@glass:~$ <span style="animation:blink 1s steps(1) infinite">▋</span></div></div>`,
  music: () => `<div class="readable"><h2>Music</h2><p>Now playing: nothing yet. A glossy transport bar and album art in a square tile would sit here.</p></div>`,
  photos: () => `<div class="readable"><h2>Photos</h2><p>A light-table of square thumbnails floating over glass.</p></div>`,
  calc: () => `<div class="readable"><h2>Calculator</h2><p>Glass keypad with glossy squircle keys.</p></div>`,
};

function openApp(app) {
  const meta = APPS[app];
  if (openWindows[app]) { focusWindow(app); return; }

  // window element
  const win = document.createElement("div");
  win.className = "window";
  const w = 460, h = 340;
  const offset = Object.keys(openWindows).length * 28;
  win.style.width = w + "px";
  win.style.height = h + "px";
  win.style.left = (window.innerWidth/2 - w/2 + offset) + "px";
  win.style.top  = (window.innerHeight/2 - h/2 - 30 + offset) + "px";
  win.style.zIndex = ++zTop;

  win.innerHTML = `
    <div class="titlebar">
      <div class="win-glyph"></div>
      <div class="win-title">${meta.name}</div>
      <div class="win-controls">
        <div class="win-btn min" title="Minimize"></div>
        <div class="win-btn max" title="Maximize"></div>
        <div class="win-btn close" title="Close"></div>
      </div>
    </div>
    <div class="win-body">${(WINDOW_CONTENT[app]||(()=>'<div class="readable"><p>App content.</p></div>'))()}</div>`;

  win.querySelector(".win-glyph").style.backgroundImage = svgURL(GLYPHS[meta.glyph]);
  // file tiles inside files app
  win.querySelectorAll(".file-tile").forEach((ft) => {
    const g = ft.dataset.g;
    ft.replaceWith(makeTile(g, APPS[app].tint, 54));
  });
  // toggles
  win.querySelectorAll("[data-toggle]").forEach((t)=> t.addEventListener("click",()=>t.classList.toggle("on")));

  windowsLayer.appendChild(win);
  makeDraggable(win);
  win.addEventListener("mousedown", () => focusWindow(app));

  // controls
  win.querySelector(".close").addEventListener("click", (e)=>{ e.stopPropagation(); closeApp(app); });
  win.querySelector(".min").addEventListener("click", (e)=>{ e.stopPropagation(); win.style.display="none"; });
  let maxed=false, prev={};
  win.querySelector(".max").addEventListener("click",(e)=>{
    e.stopPropagation();
    if(!maxed){ prev={l:win.style.left,t:win.style.top,w:win.style.width,h:win.style.height};
      win.style.left="14px"; win.style.top="14px"; win.style.width=(innerWidth-28)+"px"; win.style.height=(innerHeight-90)+"px"; maxed=true;
    } else { Object.assign(win.style,{left:prev.l,top:prev.t,width:prev.w,height:prev.h}); maxed=false; }
  });

  // taskbar button
  const btn = document.createElement("div");
  btn.className = "task-app running active-app";
  btn.appendChild(makeTile(meta.glyph, meta.tint, 40));
  btn.title = meta.name;
  btn.addEventListener("click", ()=>{
    if(win.style.display==="none"){ win.style.display="flex"; focusWindow(app); }
    else if (openWindows[app].active){ win.style.display="none"; }
    else { focusWindow(app); }
  });
  taskApps.appendChild(btn);

  openWindows[app] = { win, btn, active:true };
  focusWindow(app);
}

function focusWindow(app){
  const rec = openWindows[app];
  if(!rec) return;
  if(rec.win.style.display==="none") rec.win.style.display="flex";
  rec.win.style.zIndex = ++zTop;
  Object.keys(openWindows).forEach(k=>{
    openWindows[k].active = (k===app);
    openWindows[k].btn.classList.toggle("active-app", k===app);
  });
}

function closeApp(app){
  const rec = openWindows[app];
  if(!rec) return;
  rec.win.classList.add("closing");
  setTimeout(()=>{ rec.win.remove(); rec.btn.remove(); delete openWindows[app]; }, 200);
}

/* ---- dragging ---- */
function makeDraggable(win){
  const bar = win.querySelector(".titlebar");
  let sx,sy,ox,oy,drag=false;
  bar.addEventListener("mousedown",(e)=>{
    if(e.target.classList.contains("win-btn")) return;
    drag=true; sx=e.clientX; sy=e.clientY;
    ox=parseInt(win.style.left); oy=parseInt(win.style.top);
    document.body.style.userSelect="none";
  });
  window.addEventListener("mousemove",(e)=>{
    if(!drag) return;
    win.style.left=(ox+e.clientX-sx)+"px";
    win.style.top=Math.max(0,(oy+e.clientY-sy))+"px";
  });
  window.addEventListener("mouseup",()=>{ drag=false; document.body.style.userSelect=""; });
}

/* ---- start menu ---- */
const startMenu = document.getElementById("startMenu");
const startOrb = document.getElementById("startOrb");
function toggleStart(force){
  const open = force!==undefined ? force : !startMenu.classList.contains("open");
  startMenu.classList.toggle("open", open);
  startOrb.classList.toggle("active", open);
}
startOrb.addEventListener("click",(e)=>{ e.stopPropagation(); toggleStart(); });
document.addEventListener("click",(e)=>{
  if(!startMenu.contains(e.target) && e.target!==startOrb && !startOrb.contains(e.target))
    toggleStart(false);
});

/* ---- clock ---- */
function tick(){
  const d = new Date();
  const t = d.toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'});
  const ds = d.toLocaleDateString([], {month:'short', day:'numeric'});
  document.getElementById("clockTime").textContent = t;
  document.getElementById("clockDate").textContent = ds;
}
tick(); setInterval(tick, 10000);

/* ---- bokeh bubbles ---- */
const field = document.getElementById("bokehField");
const N = 18;
for(let i=0;i<N;i++){
  const b = document.createElement("div");
  b.className="bubble";
  const size = 20 + Math.floor(Math.pow(i%6/5,2)*140) + (i*7)%60;
  b.style.width = b.style.height = size+"px";
  b.style.left = ((i*53)%100)+"vw";
  b.style.bottom = "-20vh";
  const dur = 18 + (i%7)*4;
  b.style.animationDuration = dur+"s";
  b.style.animationDelay = "-"+((i*3)%dur)+"s";
  field.appendChild(b);
}

/* blink keyframe for terminal cursor */
const bs = document.createElement("style");
bs.textContent = "@keyframes blink{50%{opacity:0}}";
document.head.appendChild(bs);

/* open Welcome on boot */
setTimeout(()=>openApp("welcome"), 400);
