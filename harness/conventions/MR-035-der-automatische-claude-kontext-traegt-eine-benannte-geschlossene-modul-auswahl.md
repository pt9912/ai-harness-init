# MR-035 — Der automatische Claude-Kontext trägt eine benannte, geschlossene Modul-Auswahl

- **Datum:** 2026-08-31
- **Wirksamkeits-Anlass:** kein Slice — die Ablage entstand außerhalb des Slice-Betriebs. Wirksam
  wurde sie mit dem Commit, der `.claude/rules/` in den Index nahm
  (`git log --diff-filter=A --format=%h -- .claude/rules/` → genau **ein** Hash).
  [`MR-028`](../conventions.md#mr-028--der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt) verlangt den
  Anlass als Arbeitseinheit und setzt für Slice-Nummern die blanke Form; hier steht das Kommando
  statt des Hashs, weil ein Hash eine Adresse ist und ein Rebase sie bewegt.
- **Geltungsbereich:** `.claude/rules/` und der Zugriffs-Absatz in
  [`AGENTS.md`](../../AGENTS.md) §1. **Dieses Repo, nicht das emittierte** — das Werkzeug emittiert
  kein solches Verzeichnis (`ls internal/emit/templates/` nennt `agents`, `commands`, `enforce`
  und zwei Dateien, kein `rules`); was ein emittiertes Repo an Kontext-Regeln bekommt, entscheidet
  der Slice, der die Tool-Ebene entscheidet.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**.
  Dieselbe Einordnung und dieselbe offene Folge wie bei
  [`MR-031`](../conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline),
  [`MR-033`](../conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  und [`MR-034`](../conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand): was daraus für
  den Block folgt, entscheidet slice-083 §2.
- **Was die Baseline sagt, gemessen am adoptierten Stand `v5.12.0`.** Zwei Sätze sprechen über das
  Halten des Regelwerks im Kontext, beide über den **ganzen** Baum:

  ```sh
  grep -c 'ohne das ganze Regelwerk im Kontext zu halten' .harness/baseline/v5.12.0/regelwerk/README.md                    # 1
  grep -c 'ohne das ganze Regelwerk im Kontext zu halten' .harness/baseline/v5.12.0/regelwerk/modul-02-harness-bootstrap.md # 1
  grep -rl 'claude/rules' .harness/baseline/v5.12.0/ | wc -l                                                               # 0
  ```

  Der erste ist eine **Fähigkeits**-Aussage (*„Pro Abschnitt eine Datei, damit ein Agent einen
  einzelnen Abschnitt laden kann, ohne …"*), der zweite beschreibt das **Nachschlagen** pro
  Entscheidung als Anwendung des Modul-0-Prinzips
  (`grep -c 'Per-Lauf-Relevantes gehört verkörpert, nicht extern' …/modul-02-harness-bootstrap.md`
  → **1**). Die Baseline kennt den Mechanismus nicht. **Grenze der Messung:** dass **kein** Satz
  eine Teilmenge im Auto-Kontext verbietet, ist eine Lesart und kein `grep` — die Zugehörigkeit
  eines Satzes zu dieser Frage ist ein **Urteil, kein Muster**
  ([`AGENTS.md`](../../AGENTS.md) §3.6). Gemessen ist, was oben steht.
- **Setzung 1 — was der Zustand ist.** Unter `.claude/rules/` liegen **4** Einträge, alle als
  Symlink in den vendored Baum (`ls .claude/rules/*.md | wc -l` → **4**;
  `git ls-files -s .claude/rules/ | awk '$1=="120000"' | wc -l` → **4**, also keiner mit eigenem
  Text). Der Bestand des Regelwerks ist **26** Dateien
  (`ls .harness/baseline/v5.12.0/regelwerk/*.md | wc -l`); der Anteil im Auto-Kontext beträgt
  **18,1 %** der Zeichen
  (`awk -v a="$(cat .claude/rules/*.md | wc -c)" -v b="$(cat .harness/baseline/v5.12.0/regelwerk/*.md | wc -c)" 'BEGIN{printf "%.1f\n", a/b*100}'`).
  **Keine Erwartungswerte** ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — alle drei wandern mit dem Verzeichnis und mit dem Tag. Dass Dateien unter diesem
  Pfad in den Kontext geladen werden, steht in der committet vendored Werkzeug-Doku
  ([`docs/user/claude-hooks-referenz.md`](../../docs/user/claude-hooks-referenz.md) §InstructionsLoaded,
  `grep -c 'claude/rules/\*\.md' docs/user/claude-hooks-referenz.md` → **2**): geladen wird
  **beim Sitzungsstart** (`load_reason: session_start`), träge nur bei `paths:`-Frontmatter oder
  verschachtelter `CLAUDE.md`. Die vier tragen kein Frontmatter — ein Symlink hat keinen eigenen
  Text —, also gilt für sie der Sitzungsstart-Fall.
- **Setzung 2 — die Menge ist geschlossen, und ihre Quelle ist das Verzeichnis.** Welche Module im
  Auto-Kontext liegen, sagt `ls .claude/rules/` und sonst nichts; eine zweite Aufzählung stünde
  neben der ersten und alterte. Geschlossen heißt: **ein Eintrag mehr oder weniger ist ein neuer
  Eintrag dieses Blocks**, keine Variante dieses einen — geschrieben von der Rolle, die den Block
  schreibt ([`AGENTS.md`](../../AGENTS.md) §3.8). Ein automatischer Kontext, der ohne Registereintrag
  wächst, ist genau die stille Norm-Änderung, gegen die dieser Block existiert. **Das ist eine
  Form-Setzung über das Register, kein Verbot des Verzeichnisses.**
- **Setzung 3 — Präsenz ist keine Durchsetzung.** Ein Modul im Auto-Kontext liegt im Quadranten
  *inferential feedforward* (Baseline `v5.12.0`,
  [`grundlagen-durchsetzungsschicht.md`](../../.harness/baseline/v6.0.0/regelwerk/grundlagen-durchsetzungsschicht.md)
  §Die Lücke: aspirativ vs. bindend — *„er **informiert**. Ein driftender oder vergesslicher Agent
  kann ihn ignorieren"*). Es erzwingt nichts, färbt nichts rot und ersetzt keinen Sensor. Wer eine
  Regel dort ablegt, hat sie **gezeigt**, nicht **gebunden**; die zwei fail-closed Bindepunkte
  dieses Repos bleiben der PreToolUse-Guard und der Stop-Hook.
- **Setzung 4 — die On-demand-Pflicht bleibt, und Codex ist unberührt.** Für jedes Modul außerhalb
  von `.claude/rules/` gilt der Lesepfad aus [`AGENTS.md`](../../AGENTS.md) §1 unverändert: Index
  plus relevantes Modul, nicht der Baum. Der Codex-Pfad ändert sich gar nicht — `.codex/hooks.json`
  führt allein den SessionStart-Injektor mit dem Index, und `.claude/` liest Codex nicht. Die
  beiden Agenten stehen damit wieder unterschiedlich, wie schon zwischen
  [`MR-004`](../conventions.md#mr-004--sessionstart-regelwerk-injektor) und
  [`MR-006`](../conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis) — nur mit vertauschten Rollen.
- **Setzung 5 — die Symlink-Form schließt die bedingte Ladung aus, und das ist der bezahlte
  Preis.** Ein Symlink kann nicht driften, weil er keinen eigenen Text hat; genau deshalb kann er
  auch kein `paths:`-Frontmatter tragen, mit dem die Werkzeug-Doku (§InstructionsLoaded,
  `load_reason: path_glob_match`) eine Regel-Datei nur bei passendem Dateizugriff lädt. Die
  Alternative — kopieren und Frontmatter setzen — erzeugt einen zweiten Wortlaut derselben Module,
  der beim nächsten Tag-Wechsel still veraltet. Gewählt ist Drift-Freiheit gegen unbedingtes
  Laden. **Ein dritter Weg ist denkbar und hier nicht gemessen:** die Doku führt
  `load_reason: include` mit einem `parent_file_path`, also eingebundene Anweisungsdateien; ob eine
  Regel-Datei mit Frontmatter den vendored Baum einbinden kann, ist an diesem Repo nicht erprobt
  und wird hier nicht behauptet.
- **Begründung.** Die vier sind die Prozess-Module — Entwicklungszyklus, Planning Harness, Roadmap
  Engineering, Agentenrollen (`for f in .claude/rules/*.md; do head -1 "$f"; done`) —, also der
  Teil des Regelwerks, den Slice-Lifecycle, Wellen-Prozedur und Rollen-Übergaben in **jedem** Lauf
  berühren, nicht nur bei einer Einzelentscheidung. Das Review-Modul fehlt darin und soll fehlen:
  dessen Urteil führt nach Modul 8 §Welche Rolle braucht welche Artefaktklasse eine Skill-Datei,
  und die liegt hier (`ls .harness/skills/`). Für den Gewinn gibt es einen Namen im Block selbst:
  [`MR-006`](../conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis) §Tradeoff hat das Index-only-
  Injizieren als **Schwächung der Presence-Garantie** ausgewiesen (*„was nicht im Kontext ist,
  existiert nicht"*) und den Preis bewusst gezahlt. Diese Ablage holt die Garantie für eine
  benannte Teilmenge zurück, auf der Claude-Achse, gegen einen Kontext-Aufschlag, den Setzung 1
  beziffert.
- **Grenze — was der Zustand an zwei Mess-Pfaden bewegt, und was nicht.** (1) Die vier Pfade
  fallen in den Geltungsbereichs-Pathspec von
  [`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert), der
  `.harness/baseline/**` ausdrücklich ausnimmt:
  `git ls-files '*.md' ':!docs/reviews/**' ':!docs/plan/planning/done/**' ':!.harness/baseline/**' | grep -c '^\.claude/rules/'`
  → **4**. **Zählende** Messungen über diesen Pathspec verschieben sich dadurch um vier;
  **inhaltliche** nicht: `git grep` liest den Blob, und der Blob eines Symlinks ist der Zielpfad —
  `grep -c 'Baseline' .claude/rules/modul-01-entwicklungszyklus.md` → **1** (das Dateisystem folgt),
  `git grep -c 'Baseline' -- '.claude/rules/modul-01-entwicklungszyklus.md'` → leer, Exit **1**
  (git folgt nicht). Jener Eintrag wird deshalb **nicht** angefasst; der Block ist append-only, und
  seine Ausnahme hat durch diese Pfade keinen Gegenstand verloren. (2) Das Doku-Gate prüft die vier
  nicht: `make docs-check` meldet `475 Datei(en) geprüft, 0 Befund(e)`, und die Differenz ist
  aufgelöst — der Kandidatenbestand nach den Regeln aus `.d-check.yml` §`scan.ignore` ist **479**
  (`find . -path ./.git -prune -o -name '*.md' -print | grep -v '^\./\.harness/baseline/' | grep -v '\.template\.md$' | grep -v '^\./\.tmp/' | grep -v '^\./docs/user/claude-hooks-referenz\.md$' | grep -v '^\./docs/plan/adr/0013-technik-stratum-als-zielort\.md$' | wc -l`),
  davon **475** ohne die vier Symlinks (dieselbe Pipeline, abschließend
  `grep -vc '^\./\.claude/rules/'`). **Keine Erwartungswerte** — beide wandern mit dem Baum. Die
  Ausnahme der Baseline vom Doku-Gate hält damit über beide Pfade, und das ist gewollt: geprüft
  wird, was dieses Repo schreibt.
- **Kein Wächter, und der Kandidat ist benannt, nicht gebaut.** Kein Modul aus `modules:` der
  `.d-check.yml` liest eine Ladeform — `links` prüft Link-Ziele, `ids` drei Kennungs-Muster —, und
  `make comment-claims` hat keine Markdown-Datei in seinem Prüfbereich. Ein **beobachtender**
  Kandidat existiert im Werkzeug: der Hook `InstructionsLoaded` feuert je geladener Datei mit
  `file_path` und `load_reason`
  ([`docs/user/claude-hooks-referenz.md`](../../docs/user/claude-hooks-referenz.md) §InstructionsLoaded).
  Er ist **kein** Gate — dieselbe Quelle sagt *„Der Hook unterstützt keine Blockierung oder
  Entscheidungskontrolle"* —, er hängt wie der PreToolUse-Guard an **einem** Agenten
  ([`AGENTS.md`](../../AGENTS.md) §3.9 §Grenze des Feedback-Quadranten), und er ist hier nicht
  verdrahtet (`grep -c InstructionsLoaded .claude/settings.json` → **0**, Exit 1). Träger dieser
  Setzungen ist der Rollen-Wechsel vor der Änderung.
- **Kein ADR nötig ([`AGENTS.md`](../../AGENTS.md) §3.5).** §3.5 bindet **Senkungen**. Hier sinkt
  keine Schwelle: kein Gate-Modul wird deaktiviert, kein Prüfbereich gekürzt, keine Strenge
  gelockert — es kommt Kontext hinzu, der nichts erzwingt (Setzung 3). Und keine Accepted-ADR
  entscheidet die Ladeform des Regelwerks **in diesem** Repo: `grep -n 'on-demand' docs/plan/adr/*.md`
  ist leer (Exit 1), `grep -n 'claude/rules' docs/plan/adr/*.md` ebenso; die ADRs, die das
  Regelwerk nennen, entscheiden über das **emittierte** Ziel-Repo
  ([`ADR-0005`](../../docs/plan/adr/0005-ziel-repo-distribution.md)) oder über Registerformen.
- **Was hier nicht entschieden ist.** Das Modul-0-Prinzip kennt zwei Zustände — *verkörpert* und
  *nachgeschlagen*. Ein Modul im Auto-Kontext ist keiner von beiden: die Quelle wird unbedingt
  geladen, ohne dass ihr per-Lauf-relevanter Gehalt in Hard Rule, Gate, Skill oder `MR` überführt
  wäre. Ob die Antwort des Prinzips hier **Verkörperung** wäre und das Verzeichnis danach
  entfiele, ist offen; sie zu geben verlangt, für jedes der vier Module zu bestimmen, welcher
  Gehalt per-Lauf-relevant ist und wo er hingehört. Das ist Arbeit für einen geschnittenen Slice
  und danach für eine ADR, nicht für diesen Eintrag. Bis dahin steht der Zustand hier
  **deklariert**, und Setzung 2 hält ihn davon ab, still zu wachsen.
- **Auflösungs-Trigger:** Die Setzungen 2 bis 4 sind permanent — sie hängen an keinem Tag und an
  keinem Pin. **Setzung 1 wandert** mit dem Verzeichnis und mit `BASELINE_TAG`: die Symlink-Ziele
  tragen den Tag im Pfad, ein Re-Baseline bricht sie, und `make baseline-verify` sieht das nicht
  (es prüft den Baum, nicht wer auf ihn zeigt). Ein Tag-Bump zieht die vier Symlinks nach oder
  entfernt sie; welches von beidem, ist ein neuer Eintrag nach Setzung 2. **Setzung 5** fällt neu
  an, sobald eine bedingte Ladung ohne zweiten Wortlaut möglich ist.
