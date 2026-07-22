# Review-Report — ADR-0007 (Proposed) „Bootstrap-Phasen — Sprache via ADR, idempotente Fragment-Emission"

**Rolle:** unabhängiger ADR-Reviewer (frischer Kontext), **Proposed-first VOR** dem
Accept-Lock (`AGENTS.md` §3.4 — Accepted ADRs sind unveränderlich).
**Datum:** 2026-07-22. **Gegenstand:** `docs/plan/adr/0007-bootstrap-phasen.md` @ `2b2e939`.
**Prüfachse:** Entscheidungs-Qualität (nicht Code).

**Gelesen:** ADR-0007; ADR-0003/0004/0005/0006; `spec/lastenheft.md`
(LH-FA-01/-02/-03/-04/-06, LH-QA-01/-02); `spec/architecture.md` §Komponenten;
`docs/plan/planning/done/slice-025-bootstrap-preflight.md`;
`cmd/ai-harness-init/main.go` (4 Phasen, `preflightAbsent`, `emitTargets`);
`internal/emit/enforce.go` + `-_test.go` (BLOCKED-Set); Root-`Makefile` +
`d-check.mk` (`gates:`-Verdrahtung); `harness/conventions.md` (MR-010); `AGENTS.md` §3.

---

## Gesamturteil

**NICHT Accept-reif — gezielte, aber substanzielle Überarbeitung von Entscheidung 2/3
und tragender Annahme 2 nötig. Kern-Richtung (Phasierung · Sprache deferred · idempotente
Fragmente) tragfähig und beibehaltenswert.**

Die Motivation („doc führt gilt auch für die Zielsprache"), die Mono-Repo-Öffnung und
der Ersatz des `--force`-Clobber durch idempotente Konvergenz sind stimmig und lösen echte,
mehrfach protokollierte Schmerzen. **Aber:** der eigentliche Trägerpfeiler der ADR — die
**Idempotenz-Klassifikation** — ist unvollständig und an mindestens zwei Stellen intern
widersprüchlich, **eine tragende Annahme ist gegen den Ist-Code faktisch falsch**, und die
Fragment-Gate-Mechanik ist gegen die heutige Verdrahtung nicht belegt (Migrations-Bruch
unterschätzt). Das sind Design-Löcher im Kern der Entscheidung, keine Formulierungs-Politur —
sie gehören vor Accept geschlossen, sonst friert §3.4 sie ein.

**Befunde:** 2 HIGH · 5 MEDIUM · 3 LOW/INFO. Zum Vergleich: ADR-0006 fing in genau diesem
Zyklus 6 MEDIUM / 0 HIGH vor dem Freeze.

---

## HIGH — würde die Entscheidung kippen/blockieren

### H1 — Die Root-Makefile ist zugleich „konvergenter Aggregator" (Entscheidung 2) UND „skip-if-present-Skelett" (Konsequenzen). Eine Datei kann nicht beides sein.

- **Entscheidung 2:** „Die Root-Makefile wird ein **dünner Aggregator**"; `add-lang` und der
  idempotente Re-Lauf **heilen/erweitern** sie (Baseline-Upgrade, Fragment-Assembly). Das
  verlangt Klasse **konvergent** (auf kanonisch schreiben).
- **Konsequenzen §Offener Grenzfall:** „`main.go` **+ die adopter-editierbaren Skelett-Teile**
  sind **skip-if-present**", und die Makefile ist Teil des generierten Skeletts
  (`wire.Place` platziert sie am Root, `main.go:210`).
- **Widerspruch mit Folgen:** ist die Makefile **skip-if-present**, kann ein Baseline-Upgrade /
  `add-lang` den Aggregator **nicht heilen** — die zentrale Idempotenz-Zusage („Re-Lauf hebt die
  Harness") bricht für genau die Datei, die die Gate-Assembly trägt. Ist sie **konvergent**,
  **clobbert** jeder Re-Lauf adopter-eigene Makefile-Ergänzungen (eigene Targets, CI-Verdrahtung).
- **Verschärfend:** „`add-lang` = reiner Fragment-Drop, **kein In-Place-Makefile-Edit**" ist nur
  haltbar, wenn der Aggregator die Fragmente per **Glob-Include** einzieht (`include mk/*.mk` o. ä.)
  **und** die `gates:`-Regel **nach** allen Includes steht (Make expandiert die Prerequisite-Liste
  beim Lesen der Regel). Dieser Mechanismus ist **nicht benannt**; ohne ihn braucht jedes neue
  Fragment doch einen In-Place-`include`-Zusatz.
- **Nötig:** Makefile eindeutig einer Klasse zuordnen und den Konflikt auflösen — z. B.
  **Aggregator = konvergent, aber minimal** (nur Includes + `gates:`-Regel, keine adopter-Fläche;
  adopter-Eigenes lebt in einem separaten, skip-if-present `local.mk`), plus expliziter
  Glob-Include-Mechanismus. So lange offen, ist die Kern-Zusage der ADR nicht umsetzbar.

### H2 — Tragende Annahme 2 („Durchsetzung ist bereits sprach-agnostisch") ist gegen den Ist-Code falsch; die Init-ohne-Sprache-Emission der Durchsetzung ist dadurch unterspezifiziert und idempotenz-unsicher.

- **Behauptung (ADR, Annahme 2):** „Die Emit-Schicht ist **bereits sprach-agnostisch**
  (AGENTS/regelwerk/templates/**Durchsetzung**/Commands) — belegt in slice-031/033; **nur**
  `gen.Generate` + `wire.Place` brauchen `--lang`." Entscheidung 1 emittiert „Durchsetzung, Commands"
  entsprechend **im Init ohne Sprache**.
- **Ist-Befund (widerlegt):** `internal/emit/enforce.go:101` — `func Enforce(targetDir, lang string, …)`;
  der Command-Guard trägt eine **`--lang`-Substitution** (`@@BLOCKED_SET@@` → `blockedSet(lang)`,
  `enforce.go:56-64,121`), die die **Host-Toolchain der Zielsprache** blockt
  (`go` → „go gofmt golangci-lint staticcheck"). `spec/architecture.md:40` benennt den
  **Enforce-Emitter accepted als „tool-erzeugt, je `--lang`"**; `ADR-0004` §Entscheidung 3 /
  `ADR-0006` (fort geltend) fixieren das BLOCKED-Set **je `--lang`**. Die Durchsetzung ist also
  **nicht** vollständig sprach-agnostisch — der Guard ist es gerade **nicht**.
- **Folgen der Lücke:**
  1. **Init ohne Sprache** kann den Guard nur mit dem **universellen** BLOCKED-Set emittieren
     (pip/npm/cargo), **ohne** den Zielsprach-Block. `add-lang` müsste den Guard **nachrüsten** —
     das ist **nicht spezifiziert**. Ohne Nachrüstung verletzt der emittierte Guard `LH-FA-06`
     („BLOCKED-Set auf `--lang` des Ziels abgestimmt"): nach `add-lang go` liefe `go` **ungehindert**.
  2. **Idempotenz-Falle (Fehl-Klasse clobbert — der von der ADR selbst benannte Killer):** der Guard
     ist „tool-eigen" → Klasse **konvergent**. Ein Re-Lauf des **Init ohne Sprache** schreibt den
     Guard auf **universal-only** zurück und **entfernt still** den von `add-lang` installierten
     Sprach-Block. Genau der Zustand, den Entscheidung 3 vor Clobber schützen will, ist tool-emittiert
     und fällt damit in den überschreibenden Eimer.
  3. **Mono-Repo:** mehrere `add-lang` (go **und** python) verlangen ein **Vereinigungs-**BLOCKED-Set;
     `blockedSet(lang)` ist single-lang, und konvergentes Überschreiben kann nicht akkumulieren.
- **Nötig:** Annahme 2 korrigieren (Guard ist lang-spezifisch), die Guard-Emission der `add-lang`-Phase
  (bzw. einer akkumulierenden Guard-Klasse) zuordnen und die Re-Lauf-Konvergenz so definieren, dass
  ein sprachloser Init den Sprach-Block **nicht** zurücksetzt. Berührt eine **Accepted**-Setzung
  (`architecture.md` §Komponenten „je `--lang`", `ADR-0004`/`ADR-0006`) — die CR-/Nachzug-Pflicht ist
  dafür zu ergänzen.

---

## MEDIUM — vor Accept zu schärfen

### M1 — `.d-check.yml` (Gate-Config) als „tool-eigen, konvergent" fehlklassifiziert; Konvergenz clobbert die adopter-gewachsene Config.

Entscheidung 3 listet **„Gate-Config"** unter **konvergent** (Re-Lauf schreibt kanonisch). Aber
`LH-FA-03` und `AGENTS.md` §3.1 setzen fest: „`ids`/`codepaths` **nur mit existierenden Targets/roots**
aktivieren — **der Gate-Config wächst mit den Artefakten**." Im Ziel-Repo **füllt der Adopter**
`.d-check.yml` mit, sobald Artefakte entstehen. Konvergentes Überschreiben beim Re-Lauf **verwirft
diese Wachstums-Fläche** — der klassische „Fehl-Klasse clobbert Adopter-Inhalt"-Fall, den die ADR als
Risiko benennt, hier aber selbst produziert. Entweder `.d-check.yml` ist **skip-if-present** (dann kann
ein Baseline-Upgrade sie nicht heilen — dieselbe H1-Spannung), oder es braucht eine **dritte Klasse
„tool-seed + adopter-merge"**. Die Zwei-Klassen-Teilung ist für gewachsene Configs zu grob.

### M2 — Die Artefakt→Klasse-Liste ist unvollständig; mehrere emittierte Singletons sind unplatziert oder falsch platziert.

Entscheidung 3 nennt nur Beispiele. Ungeklärt/riskant:
- **`harness/conventions.md`** — der Adopter **füllt den MR-Block** (im Dogfood MR-001…MR-012). Muss
  **skip-if-present** sein; steht in keiner Klasse.
- **`AGENTS.md`** — `ADR-0005` stuft es als **agent/mensch-autort (tool-fremd)** ein → **skip-if-present**;
  Entscheidung 3 nennt es nicht (Entscheidung 1 emittiert es aber im Init).
- **`README.md`** (`LH-FA-05`) — gestempelt, adopter-editierbar → skip; ungenannt.
- **`roadmap`/`.gitkeep`-Struktur** — roadmap steht (korrekt) unter skip; die `.gitkeep`-Leerordner-Struktur
  (konvergent? egal weil leer?) ist unbenannt.

Die versprochene Fitness-Function „ein Test koppelt **jede** emittierte Datei an ihre Klasse" ist genau
die richtige Absicherung — aber die ADR muss die **vollständige** Zuordnungstabelle als Entscheidungs-Inhalt
mitliefern (sie ist der Kern), nicht in die Slices verschieben. Solange die Beispiel-Liste unvollständig
**und** (M1, H1) teils falsch ist, ist „die Klassifikation" nicht entschieden, nur skizziert.

### M3 — Fragment-Gate-Mechanik ist gegen die heutige Verdrahtung nicht belegt; „verallgemeinert `d-check.mk`/MR-010" überzieht den Präzedenzfall (Migrations-Bruch unterschätzt).

Annahme 3 / Entscheidung 2 behaupten, das Fragment-/Variablen-Muster **trage heute schon**. Ist-Stand:
- Root-`Makefile:142`: `gates: baseline-verify docs-check lint build test shell-lint ci-lint record-gates`
  — eine **hart aufgezählte, hand-authored Prerequisite-Liste**, **kein** `gates: $(GATE_CHECKS) record-gates`.
- `d-check.mk` **definiert nur das Target `docs-check`** (Z. 27-28); es **hängt an keine Variable an**.

Die vorgeschlagene Variablen-Akkumulation + Glob-Aggregator ist also **Neubau**, kein Weiterführen. **MR-010**
belegt lediglich, dass `d-check.mk` **tool-generiert** ist — **nicht** eine variablen-basierte Gate-Akkumulation.
„Verallgemeinert `d-check.mk`/MR-010" liest den Präzedenzfall stärker, als er ist. Der Migrationsschritt
(monolithische `gates:`-Liste → Variablen-Aggregator, plus Glob-Include, plus `record-gates`-Ordnungszusage)
gehört als **eigener Konsequenz-/Slice-Punkt** benannt, nicht als „trägt schon".

### M4 — „`record-gates` steht fix zuletzt / order-robust" hält nur seriell; unter `make -j` ist die Nachweis-Zusage gebrochen.

Make-Prerequisites sind bei **parallelem** Lauf (`make -j`) **reihenfolge-unabhängig**, und `record-gates`
trägt **keine** Abhängigkeitskante auf die Checks (`Makefile:136-137` — reiner Script-Aufruf). `gates: $(GATE_CHECKS)
record-gates` garantiert „zuletzt" **nur seriell**. Unter `-j` kann `record-gates` **vor/ohne** bestandene Gates
den Working-Tree-Hash schreiben — der Stop-Hook-Nachweis wird dann bedeutungslos (er belegt „Gates liefen", obwohl
ein Gate noch rot werden kann). Die Formulierung „**order-robust, egal wie viele Fragmente**" überzeichnet eine
**serielle** Eigenschaft. Nötig: eine **explizite Ordnungskante** (`record-gates: $(GATE_CHECKS)`) oder
`.NOTPARALLEL`, sonst ist die Robustheits-Zusage falsch. (Gilt latent auch heute — aber die ADR erhebt sie zur
tragenden Garantie und muss sie dann halten.)

### M5 — Interner Widerspruch Entscheidung 3 ⇄ Konsequenzen zum Skelett (`main.go`).

Entscheidung 3 klassifiziert **`main.go` fest als skip-if-present**. Die Konsequenzen nennen die
Skelett-Klassifikation (`main.go`/`Makefile`) den **noch offenen** „eigentlichen Design-Knackpunkt … je Datei zu
entscheiden". Der Entscheidungsteil setzt fest, was der Konsequenzteil als **unentschieden** ausweist. Das ist
kein Nuancen-Problem: bei Accept friert §3.4 beide Sätze ein. Auflösen — die Grenzfall-Diskussion in die
Entscheidung heben (und dort abschließen) **oder** Entscheidung 3 auf „vorläufig, Slice entscheidet je Datei"
entschärfen. (H1 zeigt, dass für die **Makefile** die Antwort ohnehin nicht-trivial ist.)

---

## LOW / INFO — Verbesserung

### L1 (LOW) — Init-Gate-Set-Aufzählung womöglich unvollständig.

Das „Doc-only-Gate" wird durchgängig als **„docs-check + baseline-verify + record-gates"** genannt. Aber die
**Durchsetzung** (bash-Hooks/Guard) wird laut Entscheidung 1 **im Init** emittiert — dann gehören `shell-lint`
(und ggf. `ci-lint`) plausibel schon zum Init-Fragment (der heutige `gates:` führt sie). Klären, welche
Belange **Init**- und welche **`add-lang`**-Fragmente sind, damit die Fitness-Function „nach Init `make gates` grün"
das reale Init-Set prüft.

### L2 (INFO) — Headless-Determinismus der Interaktivität nicht explizit an TTY gekoppelt.

Entscheidung 4 („Interaktivität sammelt nur Werte, ruft denselben Kern; Prompt beeinflusst nie die Bytes") ist
solide und `LH-QA-02`-konsistent. Ein Satz fehlt: das TTY-Frontend ist **auto-off ohne TTY** (CI/headless) und nie
Default — das macht die Headless-Zusage **testbar** statt nur behauptet. Empfehlung, keine Blockade.

### L3 (INFO) — Klassifikations-Fitness-Function muss Ist-Bestand-vollständig sein (§3.6).

Die vorgeschlagene „ein Test koppelt jede Datei an ihre Klasse" ist die richtige Maschine gegen M2 — aber sie
muss den **vollständigen Ist-Bestand gegen die Erwartung** prüfen (`AGENTS.md` §3.6: „vollständiger Ist-Bestand",
nicht Stichprobe je Datei), sonst ist sie ein stilles Grün (§3.1 eine Ebene tiefer). Als Slice-Leitplanke notieren.

---

## Negativbefunde (geprüft und solide — kein Handlungsbedarf)

- **Kein Konflikt mit `ADR-0003` (Docker-only / Determinismus / `LH-QA-02`):** der flag-getriebene Kern bleibt
  deterministisch; `add-lang` **generiert** (kein Netz, `ADR-0005`-Generator); byte-Determinismus des Kerns unberührt.
  Die einzige Netz-Nutzung (Baseline-Fetch beim Init) deckt sich mit `ADR-0005` „einmalig Netz". **Solide.**
- **Kein Konflikt mit `ADR-0005`-Distributionsmodell:** Herkunftsklassen (Fetch Kurs-SSoT vs. generiere Mechanik)
  bleiben unangetastet; Init fetcht die Baseline, danach netzlos. `add-lang` = Generator-Klasse. **Konsistent.**
- **Revision der slice-025-Pre-Flight-Semantik korrekt behandelt:** slice-025 wählte **explizit „keine ADR"**
  (additive CLI-Orchestrierung; done-Notiz §7), ist also **kein** §3.4-immutable-ADR. Die ADR benennt die Revision
  offen als „Teil-Supersede der Pre-Flight-Semantik" — angemessen, **keine** stille Änderung, kein fehlender
  ADR-Supersede-Zwang. **Richtig.**
- **CR-/Nachzug-Folgepflicht sauber benannt** (Muster `ADR-0006`): `LH-FA-01`-Split (Negative-AC `--lang`→Exit 2
  fällt), `LH-FA-04`-Hebung (wiederholbarer ADR-gegateter Skelett-Schritt), `architecture.md`-Nachzug, ADR-Index
  ergänzt. **Vorbildlich** — nur um die H2-Kopplung (Enforce je `--lang`) zu erweitern.
- **Motivation stimmig und präzedenz-geerdet:** „doc führt auch für die Zielsprache" spiegelt `ADR-0003` (eigene
  Sprache **nach** den Requirements im ADR gewählt); Mono-Repo-Öffnung und Idempotenz-statt-`--force`-Clobber lösen
  real protokollierte Schmerzen (slice-025 EHRLICHE GRENZE). **Kern-Richtung tragfähig.**
- **Alternativen A/B/D fair verglichen;** insb. das State-File-Contra (Drift-zweite-Wahrheit) und der
  In-Place-Edit-Contra (Fragilität) sind korrekt. Keine ernsthafte Option unterschlagen — bis auf die in H1
  fehlende **Abgrenzung „konvergenter Minimal-Aggregator vs. adopter-`local.mk`"**, die als Sub-Option gefehlt hat.

---

## Empfehlung an den Autor (Reihenfolge)

1. **H2 zuerst** — Annahme 2 gegen `enforce.go`/`architecture.md:40` korrigieren; Guard-BLOCKED-Set-Emission der
   Sprach-Phase zuordnen und die Re-Lauf-Konvergenz clobber-frei definieren (akkumulierendes Vereinigungs-Set
   für Mono-Repo). Ohne das ist „Init emittiert Durchsetzung sprach-agnostisch" nicht wahr.
2. **H1** — Makefile-Klasse entscheiden (Vorschlag: minimaler konvergenter Glob-Aggregator + separates
   skip-if-present `local.mk`); Glob-Include-Mechanik explizit machen.
3. **M1/M2** — die **vollständige** Artefakt→Klasse-Tabelle als Entscheidungs-Inhalt liefern; `.d-check.yml`
   (und andere adopter-gewachsene Configs) brauchen ggf. eine dritte Klasse (seed+merge).
4. **M3/M4/M5** — Migrations-Bruch der Gate-Assembly benennen; `record-gates`-Ordnung parallel-fest machen
   (Ordnungskante/`.NOTPARALLEL`); Entscheidung-3-⇄-Konsequenzen-Widerspruch zum Skelett auflösen.
5. LOW/INFO nach Ermessen.

Nach Einarbeitung von H1/H2 + M1–M5 ist die ADR aus dieser Sicht **Accept-fähig** — die Grund-Entscheidung
(Phasierung, deferred Sprache, idempotente Fragmente) muss dafür **nicht** fallen.
