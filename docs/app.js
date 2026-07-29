// Everything on this page is rendered from data/site.json, which is generated
// from the live config — new widgets, themes and icon sets appear by themselves.
const $ = (s, r = document) => r.querySelector(s);
const el = (t, c, h) => { const n = document.createElement(t); if (c) n.className = c; if (h != null) n.innerHTML = h; return n; };

const FAQ = [
  ["Does this replace my menu bar?", "It draws over the native bar in the strip macOS already reserves, so your windows still tile below it. The native menus stay reachable, and one row in the 󰀵 menu reverts everything instantly."],
  ["What permissions does it need?", "Accessibility for window snapping and desktop switching, Automation for media and app switching, Calendar for the meeting widget, Screen Recording for screenshots. Everything degrades gracefully if you decline."],
  ["How do I uninstall?", "<code>~/.local/share/sketchetc/app/uninstall.sh</code> stops the service, removes the symlink and restores any config it backed up. Brew packages stay unless you remove them."],
  ["Is piping to bash safe here?", "Read it first — that is the honest answer. The installer is ~130 lines of plain shell with no obfuscation: the site shows its SHA256, the README embeds the whole script, and you can pin an immutable release tag. It never uses sudo."],
  ["Is it really free?", "Free and open source, forever. No tiers, no telemetry, no account."],
  ["Can I add my own widget?", "Yes — a widget is about 30 lines of bash in two files. WIDGETS.md in the repo walks through it, and the landing page picks it up automatically once it is in the config."],
];

function applyTheme(t) {
  const c = t.colors, r = document.documentElement;
  r.style.setProperty("--bar", c.BAR_COLOR); r.style.setProperty("--pill", c.ITEM_BG_COLOR);
  r.style.setProperty("--pop", c.POPUP_BG); r.style.setProperty("--border", c.POPUP_BORDER);
  r.style.setProperty("--a1", c.PINK); r.style.setProperty("--a2", c.CYAN);
  r.style.setProperty("--warn", c.ORANGE); r.style.setProperty("--crit", c.RED);
  r.style.setProperty("--glow", c.PURPLE); r.style.setProperty("--text", c.WHITE);
  r.dataset.theme = t.name;
  localStorage.setItem("sketchetc-theme", t.name);
  document.querySelectorAll(".dot").forEach(d => d.setAttribute("aria-pressed", d.dataset.name === t.name));
}

function render(d) {
  $("#ver").textContent = "v" + d.version;
  $("#total").textContent = "$" + d.replaces_total;
  $("#count").textContent = d.widgets.length;
  $("#isets").textContent = d.iconsets.join(", ");

  // theme dots
  const dots = $("#dots");
  d.themes.forEach(t => {
    const b = el("button", "dot");
    b.dataset.name = t.name;
    b.title = t.name;
    b.style.background = `linear-gradient(135deg, ${t.colors.PINK}, ${t.colors.CYAN})`;
    b.onclick = () => applyTheme(t);
    dots.appendChild(b);
  });
  const saved = localStorage.getItem("sketchetc-theme");
  applyTheme(d.themes.find(t => t.name === saved) || d.themes.find(t => t.name === "vice-city") || d.themes[0]);

  // price table (only widgets that replace something paid)
  const tb = $("#pricetable tbody");
  d.widgets.filter(w => w.replaces).sort((a, b) => b.replaces.price - a.replaces.price).forEach(w => {
    const tr = el("tr");
    tr.appendChild(el("td", null, `<span class="glyph">${w.icons.nerd || ""}</span>${w.key}`));
    tr.appendChild(el("td", null, w.description || ""));
    tr.appendChild(el("td", null, `<span class="price">${w.replaces.app}${w.replaces.price ? " · $" + w.replaces.price : ""}</span>`));
    tb.appendChild(tr);
  });

  // feature grid
  const g = $("#featgrid");
  d.widgets.forEach(w => {
    const c = el("div", "card");
    c.appendChild(el("h3", null,
      `<span class="g">${w.icons.nerd || "󰧮"}</span>${w.key}
       <span class="badge ${w.default_on ? "on" : "off"}">${w.default_on ? "default" : "opt in"}</span>`));
    c.appendChild(el("p", null, w.description || ""));
    g.appendChild(c);
  });

  // theme gallery from the shipped screenshots
  const shots = $("#shots");
  d.themes.forEach(t => {
    const s = el("div", "shot");
    const img = el("img");
    img.loading = "lazy";
    img.alt = t.name + " theme";
    img.src = `../assets/theme-${t.name}.png`;
    img.onerror = () => s.remove();
    s.appendChild(img);
    s.appendChild(el("span", null, t.name));
    shots.appendChild(s);
  });

  // faq
  const f = $("#faqlist");
  FAQ.forEach(([q, a]) => {
    const dt = el("details");
    dt.appendChild(el("summary", null, q));
    dt.appendChild(el("p", null, a));
    f.appendChild(dt);
  });

  observe();
}

// live bar: real clock, drifting network numbers, breathing aura
function animateBar() {
  const clock = $("#fb-clock b"), net = $("#fb-net b"), aura = $("#fb-aura b");
  const tick = () => {
    const n = new Date();
    clock.textContent = n.toLocaleDateString("en-GB", { weekday: "short", day: "2-digit", month: "short" })
      + "  " + n.toTimeString().slice(0, 5);
  };
  tick(); setInterval(tick, 10000);
  const hum = v => v > 999 ? (v / 1000).toFixed(1) + "M" : v + "K";
  setInterval(() => {
    net.textContent = `↓${hum(Math.floor(4 + Math.random() * 90))} ↑${hum(Math.floor(20 + Math.random() * 700))}`;
  }, 2200);
  let a = 187;
  setInterval(() => { a += Math.random() < .35 ? 1 : 0; aura.textContent = a; }, 3500);
}

function observe() {
  const io = new IntersectionObserver(es => es.forEach(e => {
    if (e.isIntersecting) { e.target.classList.add("shown"); io.unobserve(e.target); }
  }), { threshold: .12 });
  document.querySelectorAll(".reveal, .card, .step").forEach(n => io.observe(n));
}

$("#copy").onclick = async () => {
  await navigator.clipboard.writeText($("#cmd").textContent.trim());
  const b = $("#copy"); b.textContent = "copied"; setTimeout(() => b.textContent = "copy", 1600);
};

addEventListener("pointermove", e => {
  const g = $("#glow");
  g.style.left = e.clientX + "px";
  g.style.top = e.clientY + "px";
}, { passive: true });

// trust material: checksum + pinned tag, straight from the generated file
fetch("data/trust.json").then(r => r.json()).then(t => {
  $("#sum").textContent = "# " + t.sha256;
  $("#lines").textContent = t.lines;
  $("#pin").textContent = `raw.githubusercontent.com/himanshu007-creator/sketchetc/v${t.version}/docs/install.sh`;
}).catch(() => {});

// install counter (CounterAPI v1, no auth) and GitHub badges
fetch("https://api.counterapi.dev/v1/sketchetc/installs/")
  .then(r => r.json())
  .then(d => {
    if (typeof d.count === "number") {
      $("#installs").textContent = d.count.toLocaleString();
      $("#counter").hidden = false;
    }
  }).catch(() => {});

const REPO = "himanshu007-creator/sketchetc";
["stars", "forks", "last-commit"].forEach(kind => {
  const img = new Image();
  img.src = `https://img.shields.io/github/${kind}/${REPO}?style=flat&color=555&labelColor=222`;
  img.alt = kind;
  img.onload = () => $("#badges").appendChild(img);
});
// OpenSSF Scorecard, once the workflow has published results
const sc = new Image();
sc.src = `https://api.scorecard.dev/projects/github.com/${REPO}/badge`;
sc.alt = "OpenSSF Scorecard";
sc.onload = () => {
  const a = el("a");
  a.href = `https://scorecard.dev/viewer/?uri=github.com/${REPO}`;
  a.target = "_blank"; a.rel = "noopener";
  a.appendChild(sc);
  $("#badges").appendChild(a);
};

fetch("data/site.json")
  .then(r => r.json())
  .then(d => { render(d); animateBar(); })
  .catch(() => { $("#featgrid").innerHTML = '<p class="sub">Could not load feature data.</p>'; });
