# MR-025 — Eine Zahl im Text steht neben dem Kommando, das sie liefert

- **Datum:** 2026-08-22
- **Geltungsbereich:** die **lebenden**, repo-eigenen Markdown-Artefakte — gemessen
  `git ls-files '*.md' ':!docs/reviews/**' ':!docs/plan/planning/done/**' ':!.harness/baseline/**' | wc -l`
  → **108** von **476** Markdown-Dateien im Index (`git ls-files '*.md' | wc -l`). Draußen liegen,
  jeweils mit Grund: `docs/reviews/**` und `docs/plan/planning/done/**` — **328** Dateien
  (`git ls-files 'docs/reviews/*.md' 'docs/plan/planning/done/*.md' | wc -l`), **Zeitdokumente**,
  die eine Messung zu ihrem Datum festhalten und darum nicht nachgezogen werden;
  `.harness/baseline/**` — **40** Dateien (`git ls-files '.harness/baseline/**/*.md' | wc -l`),
  committet vendored Fremd-Bestand, den dieses Repo spiegelt statt schreibt
  ([`MR-007`](../conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)); und
  `**/*.template.md`, Ziel-Form-Vorlagen mit Platzhaltern statt Aussagen
  ([`MR-001`](../conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) §`scan.ignore`). **Alle
  vier Zahlen sind keine Erwartungswerte** — sie wandern mit dem Bestand und messen ihn, nicht den
  Geltungsbereich (Setzung 2 an sich selbst angelegt); der Geltungsbereich sind die vier Kommandos.
  **Dieses Repo, nicht das emittierte:** was ein emittiertes Repo an Beleg-Regeln bekommt,
  entscheidet der Slice, der die Tool-Ebene entscheidet.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  und die Messung ist am adoptierten Stand `v5.12.0` wiederholt: das Regelwerk führt keine Regel
  über den Beleg einer Zahl in Prosa
  (`grep -rl 'Erwartungswert' .harness/baseline/v5.12.0/regelwerk/` ist leer, Exit 1). Die Klasse
  kennt es dem Begriff nach als **Harness-Lüge**
  ([`grundlagen-begriffe.md`](../../.harness/baseline/v6.0.0/regelwerk/grundlagen-begriffe.md#kernbegriffe))
  und verlangt an mehreren Stellen, eine Grenze zu benennen statt sie zu behaupten — das ist die
  Umgebung dieser Setzung, nicht die Regel, an deren Stelle sie träte. Der Absatz *Der Ort ist
  offen* unten misst dieselbe Frage gegen `v3.5.2`; hier steht sie gegen den adoptierten Stand.
- **Setzung 1 — die Zahl und ihr Kommando stehen beieinander, und das Kommando ist gefahren.**
  Eine Zahl, die als **Messwert** auftritt — Erwartungswert, Bruch-Kriterium, Beleg —, trägt im
  selben Absatz das Kommando, das **genau sie** ausgibt, und wer sie schreibt, hat es über dem
  Baum gefahren, von dem sie spricht. Liefert kein Kommando sie — Fremdquelle, Zählung von Hand,
  Beobachtung an einer Oberfläche —, steht **das** dabei; ein ungefähr passendes Kommando
  danebenzustellen ist der Fehler, nicht die Lücke. Zahlen ohne Messwert-Rolle (Versionen, Daten,
  Aufzählungen im Fließtext) bindet die Setzung nicht.
- **Setzung 2 — ein Erwartungswert misst seinen Gegenstand, nicht sein Umfeld.** Eine Zahl, die
  mit dem Artefakt mitwandert — die Dateizahl eines Gate-Laufs, die Trefferzahl über einen
  wachsenden Baum, die Vorkommen-Zahl in einer Datei, deren Kopf noch bearbeitet wird —, taugt
  nicht als Erwartungswert: sie bricht, ohne dass am Gegenstand etwas bricht. Sie wird entweder
  ausdrücklich als **kein** Erwartungswert gekennzeichnet oder durch ein Kriterium ersetzt, das
  den Gegenstand selbst misst (`grep -c '^docs-check:' d-check.mk` statt der Zahl aller
  `docs-check`-Vorkommen derselben Datei). Musterfall ist die Dateizahl des Doku-Gates: am
  2026-08-22 meldet `make docs-check` → `336 Datei(en) geprüft, 0 Befund(e)`, Exit 0, und jedes
  neu angelegte Dokument erhöht sie.
- **Begründung (gemessen, nicht postuliert):** Die Klasse — *eine Zahl im Fließtext, die ihr
  danebenstehendes Kommando nicht liefert* — ist über **zwei** Slices und **sechs** Review-Runden
  wiederholt gemeldet worden. Der Nenner ist mechanisch:
  `grep -h '^### \(HIGH\|MEDIUM\|LOW\|INFO\)-' docs/reviews/2026-08-22-slice-08*.md | wc -l` →
  **29** Findings über sieben Dateien. **Zehn** davon tragen diese Klasse — **Untergrenze, mit
  Absicht:** die Zugehörigkeit ist ein Urteil, kein Muster, und sie mechanisch zu beziffern hieße,
  ein Muster als Kriterium auszugeben, das keines ist ([`AGENTS.md`](../../AGENTS.md) §3.6). Die
  Fundorte liegen in Planungs-Text, in einer Commit-Message und in einem Mess-Zeitdokument — drei
  Artefakt-Arten und mehr als eine schreibende Rolle. **Zwei** der zehn entstehen in demselben
  Commit, der die Klasse an anderer Stelle behebt: `git show abe01f4` (**eine** Datei, ein
  Slice-Plan) streicht in einem DoD-Punkt eine mitwandernde Dateizahl als Erwartungswert und setzt
  in einem anderen zwei Zahlen, die ihre danebenstehenden Kommandos nicht liefern. Der Befund ist damit
  nicht die Wiederholung, sondern die fehlende **Trägerschaft**: was allein in Zeitdokumenten
  steht, schlägt kein Lauf wieder auf.
- **Was der Schaden ist.** Nicht die falsche Ziffer, sondern was ein Lauf aus ihr macht, der sie
  nachzählt: entweder ein falsches Rot an einem korrekten Gegenstand oder die Gewohnheit,
  ausgewiesene Messungen gar nicht erst nachzuzählen. Die zweite Wirkung ist die teurere — sie
  entwertet jede Zahl im Repo, auch die richtigen.
- **Kein Wächter, und das gehört dazu — die Setzung liegt im Feedforward-Quadranten.** Der
  nächstliegende Kandidat deckt sie in **zwei** Achsen nicht: `make comment-claims` bildet seinen
  Prüfbereich im Rezept aus vier `git ls-files`-Mustern, und keines trifft eine Markdown-Datei
  (`git ls-files 'internal/*.go' 'internal/**/*.go' 'cmd/**/*.go' 'harness/tools/*.sh' '.claude/hooks/*.sh' | grep -c '\.md$'`
  → **0**, Exit 1); dieser Ausschluss ist **dauerhaft** ([`AGENTS.md`](../../AGENTS.md) §4
  Ausschluss 2, [`harness/README.md`](../README.md) §*Was `comment-claims` nicht deckt* Punkt 2 —
  „(2) und (3) sind permanent"). Und er prüft die **Existenz** eines genannten Sensors, nicht
  seinen Wert.
- **Drei Kandidaten liegen im Bestand; ihre Eignung ist ungeprüft.** `citations` und
  `codepaths.check-lines`
  ([`MR-011`](../conventions.md#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines)) binden Text an eine
  **Datei-Spanne**; `structure` — mit dem Pin aus
  [`MR-024`](../conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar) verfügbar, nicht aktiviert
  (`grep -c 'structure' .d-check.yml` → **0**) — bindet Abschnitte an **Struktur-Invarianten**.
  Das ist aus ihren Modul-Verträgen gelesen und an diesem Repo **nicht** erprobt; daraus folgt
  bestenfalls, dass eines von ihnen die **Form** fordern könnte (Zahl und Kommando im selben
  Abschnitt). Den **Wert** gegen einen Lauf zu halten kann keines, denn keines fährt einen Lauf:
  `git grep -ln 'os/exec' v0.65.0 -- 'internal/*.go' 'internal/**/*.go' 'cmd/**/*.go' ':!*_test.go'`
  am lokalen d-check-Klon ist **leer** (Exit 1) — ohne die Test-Ausnahme bleibt genau ein
  Akzeptanztest übrig, kein Produktionspfad.
- **Cutoff — ab diesem Eintrag, kein Nachrüsten.** Gebunden ist die Zahl, die geschrieben oder
  geändert wird; der **Bestand ist kein Arbeitsauftrag**. Seine Fläche ist gemessen: **95** der
  **108** lebenden Markdown-Dateien nennen mindestens ein Kommando
  (`git grep -lE '(make [a-z-]+|grep -|docker run|git (grep|ls-files|show|log|diff))' -- '*.md' ':!docs/reviews/**' ':!docs/plan/planning/done/**' ':!.harness/baseline/**' | wc -l`).
  Das ist die **Obergrenze der Fläche** und **kein Erwartungswert** — keine Zahl von Verstößen,
  und mit dem Bestand wandernd: wie viele Zahlen dort ihr Kommando nicht liefern, sagt kein
  Kommando, weil die Zugehörigkeit ein Urteil ist. Ein Maßstab
  über diesen Bestand wäre dauerhaft rot und entwertete die Setzung, statt sie zu tragen —
  dieselbe Begründung trägt den Cutoff in
  [`MR-015`](../conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) und in
  [`AGENTS.md`](../../AGENTS.md) §3.7. Wer eine solche Zeile ohnehin anfasst, zieht sie nach; wer sie
  stehen lässt, bricht nichts.
- **Kein ADR nötig ([`AGENTS.md`](../../AGENTS.md) §3.5).** §3.5 verlangt einen ADR für **Senkungen**.
  Beide Setzungen sind eine **Verschärfung** — eine zusätzliche Beleg-Pflicht, eine engere Form
  des Erwartungswerts —, und „Anheben → Steering-Loop, kein ADR nötig" hält
  [`MR-001`](../conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) fest.
- **Der Ort ist offen, die Verbindlichkeit nicht.** Hierher gestellt hat die Setzung ihre
  Befristung: eine Hard Rule ist permanent, ein Eintrag mit fälligem Trigger nicht. Diese Hälfte
  des Grundes ist mit dem Auflösungs-Trigger unten entfallen, und die andere Hälfte — der
  Sensor-Vorbehalt — trennt nicht, denn [`AGENTS.md`](../../AGENTS.md) §3.7 und §3.8 tragen denselben
  Vorbehalt im Katalog. Nach [`AGENTS.md`](../../AGENTS.md) §3.8 gehört eine Regel, die eine **Lücke
  füllt** statt von der Baseline abzuweichen, ohnehin nicht in den Adaptions-Block, und diese
  Setzung füllt eine: die Baseline `v3.5.2` kennt die Klasse als **Harness-Lüge** dem Begriff nach
  (`.harness/baseline/v3.5.2/regelwerk/grundlagen-konventionen.md` §Kernbegriffe: *„Der Harness
  behauptet eine Kontrolle, die real nicht (mehr) greift"*), führt aber keine Regel über den Beleg
  einer Zahl in Prosa. Die Verlegung nach [`AGENTS.md`](../../AGENTS.md) §3 hat einen eigenen Preis —
  hier bleiben nach [`MR-020`](../conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
  Kopf und Zeiger, der Rumpf wird dort **angehängt**, nicht eingeschoben
  ([`MR-026`](../conventions.md#mr-026--die-hard-rule-nummer-ist-eine-adresse-keine-baseline-entsprechung)
  Setzung 2) — und wird deshalb nicht beiläufig mitgenommen. Bis sie fällt, gilt die Setzung von
  hier: der Adaptions-Block ist normativ wie eine ADR, nur ohne deren Immutabilität
  ([`AGENTS.md`](../../AGENTS.md) §3.8). Dieselbe Grenzziehung trifft
  [`MR-015`](../conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) für seine
  eigene Setzung.
- **Auflösungs-Trigger: keiner — die Setzung ist permanent und liegt bewusst im
  Feedforward-Quadranten.** Von den drei Wegen, die beim d-check-Pin-Sprung zur Wahl standen, ist
  keiner gangbar, und beide Absagen sind gemessen. **(a) Ein eigener hermetischer Prüfer** müsste
  entscheiden, ob eine Zahl in einer **Messwert-Rolle** steht, und das ist ein Urteil, kein Muster
  (Begründung oben, zweimal). Das nächstliegende mechanisierbare Surrogat — eine fett gesetzte
  Zahl, in deren Absatz kein Kommando steht — trifft über den lebenden Markdown-Bestand **228**
  Absätze mit fetter Zahl, davon **30** ohne Kommando im selben Absatz (ein `awk` mit `RS=""` über
  die Dateiliste des §Geltungsbereichs, Zahl-Muster `\*\*[0-9][0-9.]*\*\*`, Kommando-Muster wie im
  Cutoff-Bullet; **keine Erwartungswerte**, beide wandern mit dem Bestand). Die **30** sind
  gelesen: sie führen ADR-Nummern, das Wort **Accepted** aus einer Historie-Tabelle,
  Zeilenspannen und Zahlen, deren Kommando einen Absatz weiter steht. **10** von ihnen liegen in
  `docs/plan/adr/` (dieselbe Ausgabe durch `grep -c '^docs/plan/adr/'`), verteilt auf sechs
  Dateien, von denen **fünf** `**Status:** Accepted` tragen
  (`grep -m1 '^\*\*Status:\*\*' <datei>` je Datei) — ein Wächter dieser Bauart stünde auf
  unveränderlichen Artefakten dauerhaft rot ([`AGENTS.md`](../../AGENTS.md) §3.4), und die einzige
  Abhilfe dafür wäre eine Ausnahme wie
  [`ADR-0017`](../../docs/plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md). **(b) Ein
  d-check-Modul, das die Form trägt**, deckt den **Wert** nicht: die Vorfrage ist am neuen Tag
  wiederholt und unverändert — das `os/exec`-Kommando oben ist über `v0.65.0` leer (Exit 1), kein
  Modul fährt einen Lauf. Und die Form allein trägt die Setzung nicht, denn eine Zahl mit einem
  falschen Kommando daneben erfüllt sie. Aktiviert eine spätere Entscheidung ein Modul, das die
  Form fordern kann (heute keines: `grep -c 'structure' .d-check.yml` → **0**, Exit 1), ist die
  Form-Hälfte hier nachzutragen; an der Permanenz ändert das nichts, solange der Wert ungedeckt
  bleibt. **(c) Bleibt** — und steht hier als Entscheidung, nicht als Rest.
- **Ihr Träger ist der Rollen-Wechsel, nicht ein Gate — und ein Trigger, der auf einen fremden
  Lauf zeigt, ist keiner.** Der Sprung auf `v0.65.0` ist erfolgt; die Planungsdateien des
  Pin-Commits nennen diesen Eintrag nicht. `git grep -c 'MR-025' 3ce4ea3 -- '*slice-122-*.md'`
  ist leer (Exit 1), während dieselbe Suche über die Kennung des Vorgänger-Sprungs **5** Treffer
  in einer Datei liefert, und `git log -1 --format=%B 3ce4ea3 | grep -c 'MR-025'` → **0**. Die
  Messung hängt an `3ce4ea3`, nicht am heutigen Baum — über diesem fände sie sich selbst.
  Gefunden hat die Klasse in genau jenem Lauf etwas anderes: zwei getrennte Kontexte, Review nach
  Modul 10 und Verifikation nach Modul 11, meldeten **unabhängig** dieselbe falsche Zeile
  ([Review](../../docs/reviews/2026-08-28-slice-122-review.md) HIGH-1,
  [Verifikation](../../docs/reviews/2026-08-28-slice-122-verify.md) V-2). Das ist die
  Trägerschaft, die diese Setzung hat.
