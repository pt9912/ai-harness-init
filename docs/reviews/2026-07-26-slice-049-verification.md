# Verifier-Report slice-049 — Baseline-Re-Vendor v3.5.1 → v3.5.2

**Rolle:** Verifier (Modul 11,
`.harness/baseline/v3.5.2/regelwerk/modul-11-verification.md`). Frischer Kontext, getrennt von
Implementation und Review. Geprüft wird **nicht** Stil/Qualität (das ist die Review-Achse), sondern
ob die **DoD-Behauptung** des Implementers hält — „Behauptung ohne Bestätigung ist die häufigste
Verifier-Lücke".

**Gegenstand:** [`slice-049-baseline-bump-v3.5.2.md`](../plan/planning/in-progress/slice-049-baseline-bump-v3.5.2.md)
§2 (DoD, 11 Punkte) · §3 (Plan) · §6 (Risiken).
**Range:** `80eec58..HEAD` = `9cfa1f3` (Lifecycle-Move) → `ce4b611` (Impl) → `d38db74` (Review-Fix).
**Datum:** 2026-07-26 · **Modell:** claude-opus-5[1m].

**Eingangs-Kontext:** [`harness/conventions.md`](../../harness/conventions.md) (`MR-007` Setzungen 1–4,
`MR-013`, `MR-015`) · [`AGENTS.md`](../../AGENTS.md) §1/§3 · [`harness/README.md`](../../harness/README.md) ·
[`spec/lastenheft.md`](../../spec/lastenheft.md) `LH-QA-01`/`LH-QA-02`/`LH-QA-03` ·
[Review-Report mit Implementation-Nachtrag](2026-07-26-slice-049-impl-review.md).

**Was ich selbst erhoben habe** (statt Behauptungen nachzuerzählen):

- **Provenienz-Kette live nachgezogen:** Release-Asset per `curl` geholt, `sha256sum` gebildet,
  entpackt und `diff -rq` gegen den vendorten Baum — die Achse, die `SHA256SUMS` allein **nicht**
  deckt (`MR-007` Setzung 1: Provenienz ≠ Integrität).
- **`SHA256SUMS` unabhängig neu berechnet** aus dem entpackten Upstream-Inhalt und gegen die
  committete Datei diffed.
- **Vier Gate-Targets selbst gefahren:** `make baseline-verify`, `make gates`, `make mutate`,
  `make baseline-freshness` — dazu `make full-smoke` (Begründung s. u.). Nur `make`-Targets, keine
  Host-Toolchain ([`ADR-0003`](../plan/adr/0003-go-native-binaries.md)).
- **Die in `MR-015` behaupteten Messungen selbst nachgemessen** (16/6/10 + Klassifikation der 10),
  inklusive Lesen der beiden als „rein redaktionell" eingeordneten Diffs.
- **Alt-Baum gegen Neu-Baum normalisiert diffed**, um die §3-Ist-Messung (42 / 36 / genau 3
  substanziell) unabhängig zu reproduzieren.

---

## Unabhängig nachgezogene Provenienz-Kette

Das ist der Punkt, an dem der Review ausdrücklich seine Grenze zog („die Herkunft des Baums aus
genau diesem Asset ist netzlos nicht nachprüfbar"). Der Verifier hat sie geschlossen:

| Schritt | Ergebnis |
|---|---|
| `curl` auf `…/releases/download/v3.5.2/lab-regelwerk.zip` | Exit 0, **125180 Bytes** — identisch mit der Planungs-Messung (§3) |
| `sha256sum lab-regelwerk.zip` | `2af45aad2777cadf26127066c9a2dc43f7111ee2687e44fe2eceb95c6c0a1925` |
| gegen `BASELINE_ZIP_SHA256` ([`Makefile`](../../Makefile):35) | **gleich** |
| gegen `DefaultBaselineSHA256` ([`internal/fetch/baseline.go`](../../internal/fetch/baseline.go):55) | **gleich** |
| gegen [`.d-check.yml`](../../.d-check.yml):73 `sources.sha256` | **gleich** |
| `unzip` → 42 Dateien, Top-Level `regelwerk/` + `templates/` | wie geplant |
| `diff -rq <entpackt> .harness/baseline/v3.5.2` | **einzige Meldung:** `Nur in …/v3.5.2: SHA256SUMS` — d. h. **alle 42 Dateien byte-identisch** |
| `SHA256SUMS` aus dem Upstream-Inhalt neu gerechnet (`find`, `LC_ALL=C sort`, `sha256sum`) vs. committete Datei | `diff` **Exit 0** — zeichengleich |

**Damit ist mehr belegt als die DoD verlangt:** nicht nur, dass die Pins konsistent sind, sondern
dass der committete Baum **real aus genau diesem Asset stammt**. Die einzige Aussage, die
nachträglich *nicht* artefaktisch belegbar bleibt, ist die **Reihenfolge** („Provenienz vor dem
Entpacken") — sie steht nur in der Commit-Message. Sie ist hier jedoch materiell entwertet: die
Byte-Identität hätte eine nachgelagerte Prüfung nicht anders ausfallen lassen.

---

## DoD Punkt für Punkt

| # | DoD-Punkt | Urteil | Eigener Beleg |
|---|---|---|---|
| 1 | Baum re-vendored (42 Dateien, `SHA256SUMS` nach Setzung 2, alter Baum weg) | **BESTÄTIGT** | `.harness/baseline/` enthält **nur** `v3.5.2/`; 43 Dateien im HEAD-Tree (42 + `SHA256SUMS`); `SHA256SUMS` = 42 Zeilen, listet sich **selbst nicht** (`grep -c` = 0), `LC_ALL=C sort -k2 -c` grün, Pfade relativ zu `<tag>/`; unabhängig neu berechnet → `diff` Exit 0. Einziger `v3.5.1`-Pfad in HEAD ist der frozen Dateiname `done/slice-043-baseline-bump-v3.5.1.md`. |
| 2 | Provenienz-Pin (`BASELINE_ZIP_SHA256`, `BASELINE_TAG`) | **BESTÄTIGT** | Live gemessen: Asset 125180 B, sha256 `2af45aad…1925` = Pin. `BASELINE_TAG ?= v3.5.2` ([`Makefile`](../../Makefile):26). Reihenfolge-Zusage nur inferentiell (Commit-Message) — s. A-4. |
| 3 | Fünf gekoppelte Pins (fail-closed-Tests grün) | **BESTÄTIGT** | Alle fünf Stellen tragen `v3.5.2`/`2af45aad…1925` (Diffs gelesen). Wächter real grün im eigenen `make gates`-Lauf: bats `ok 106 sources-sha256 … == Makefile BASELINE_ZIP_SHA256`, `ok 107 sources-url … traegt den aktuellen BASELINE_TAG`; `TestDefaultTag_MatchesBaseline` + `TestDefaultBaselineSHA256_MatchesMakefile` im `ok github.com/…/internal/fetch`. |
| 4 | CR-Regel entschieden, als **Adaptions-Eintrag** abgelegt | **BESTÄTIGT** | `MR-015` steht als vollwertiger Eintrag in [`harness/conventions.md`](../../harness/conventions.md):640–728 (nicht als Slice-Prosa), verankert und aus `conventions.md`:18 + `roadmap.md`:22 verlinkt. Zitat **verbatim**: zeichengleich mit `.harness/baseline/v3.5.2/regelwerk/grundlagen-konventionen.md` §Spec-Stratifizierung. Messungen selbst nachgezogen — s. Detailtabelle unten. |
| 5 | `spec/lastenheft.md` unberührt (**ganze** Range) | **BESTÄTIGT** | `git diff --stat 80eec58..HEAD -- spec/` **leer**; zusätzlich pro Commit geprüft: `9cfa1f3` 0, `ce4b611` 0, `d38db74` 0 Zeilen. Der Slice adoptiert die Regel, ohne sie im Vollzug zu widerlegen. |
| 6 | Doc-Reconciliation vollständig **und** korrekt abgegrenzt | **BESTÄTIGT** (Zähl-Abweichung A-1) | Nach dem Bump verbleibt in aktiven Pfaden **keine** normative `v3.5.1`-Referenz: `benutzerhandbuch.md` 3→0, `conventions.md` 6→1 (Re-Baseline-**Historie**), `reviewer.md` 3→1 alt (1.3.0-Historie) + 2 neue beschreibende, `roadmap.md` 3→2 (Trigger-Beschreibung der Zeile slice-049). Abgrenzung exakt: `git diff --name-status 80eec58..HEAD -- docs/plan/planning/done/ docs/plan/adr/ docs/reviews/` liefert **ausschließlich** `A docs/reviews/2026-07-26-slice-049-impl-review.md` — frozen `done/` und **alle** accepted ADRs unangetastet (Hard Rule 3.4). Kein `blob/v3.5.1`-Ziel-Form-Verweis mehr in aktiven Dokumenten (F-5 real behoben). |
| 7 | `make baseline-verify` grün | **BESTÄTIGT** | Selbst gefahren, Exit 0: `baseline-verify: v3.5.2 OK — 42 Dateien (Integritaet + Vollstaendigkeit, netzlos)`. |
| 8 | `make gates` grün | **BESTÄTIGT** | Selbst gefahren, **Exit 0**. `d-check: 182 Datei(en) geprüft, 0 Befund(e)`; `go test ./...` alle fünf Pakete `ok`; bats `1..107`, **107 `ok` / 0 `not ok`**; shellcheck + actionlint durchgelaufen; `record-gates` gestempelt. |
| 9 | `make mutate` grün | **BESTÄTIGT** | Selbst gefahren, Exit 0: **`mutate: 81 ok, 0 Befund(e)`** — jede Mutation färbt ihren eigenen Wächter rot (u. a. `11-baseline-groessen-schranke`, `13-baseline-defer-tmp`, `67-baseline-traversierbar`). **Vorab-Befund bestätigt:** kein Re-Anchoring nötig — `git diff --name-only 80eec58..HEAD -- test/` = **0 Dateien**. Isolation aus slice-047 hält: `git status --porcelain` nach dem Lauf **leer**. |
| 10 | `make baseline-freshness` Exit 0 | **BESTÄTIGT** | Selbst gefahren, Exit 0: `baseline-freshness: aktuell — gepinnt und latest sind beide v3.5.2`. Der Sensor, der den Slice auslöste, bestätigt seine eigene Auflösung. |
| 11 | Closure-Notiz mit Steering-Loop-Lerneintrag | **NOCH NICHT FÄLLIG** | §7 trägt weiterhin nur den Template-Kommentar („Erst nach Abschluss füllen"). Korrekt für einen Slice in `in-progress/` — aber offen, und damit ein Closure-Rest (s. A-3). |

### Detail zu DoD 4 — die in `MR-015` behaupteten Messungen, selbst nachgerechnet

`git log --follow -- spec/lastenheft.md`, dann je Commit `git show --pretty="" --name-only`:

| Behauptung in `MR-015` Setzung 2 | Eigene Messung | Urteil |
|---|---|---|
| 16 Commits berühren `spec/lastenheft.md` | **16** | trifft zu |
| 6 ändern sie allein: `5c4930b`, `9ce4721`, `af0d454`, `2c8227b`, `2879429`, `27628b5` | **6**, hash-identische Menge, je 1 Datei | trifft zu |
| 10 bündeln sie | **10** | trifft zu |
| 7 Entscheidungs-Bündel — mit tragendem ADR (`43f1eda`, `65f4bcf`, `ec3af11`, `a0e74f1`, `bc447fe`), mit `conventions.md` (`beec837`), mit Slice-Datei (`4b0d0d5`) | ADR-Anteil gemessen: `43f1eda` 2, `65f4bcf` 2, `ec3af11` 4, `a0e74f1` 2, `bc447fe` 3 ADR-Dateien; `beec837` = 2 Dateien mit `harness/conventions.md`, 0 ADR; `4b0d0d5` = 2 Dateien mit einer Slice-Datei, 0 ADR | trifft zu |
| 1 Initial-Bootstrap `d30db38`, 21 Dateien | **21 Dateien** | trifft zu |
| 2 rein redaktionell: `c615da7`, `7b717f4` | Diffs gelesen: `c615da7` ändert in `spec/lastenheft.md` **nur** die Link-Form der Historie-Zeile 0.2.0; `7b717f4` **nur** die Zeilenreihenfolge 0.12.0/0.13.0 | trifft zu |
| „Keine Anforderung wurde je in einem Slice-Implementierungs-Commit inhaltlich geändert" | Von den 16 sind **14** CR-/Entscheidungs-/Bootstrap-Commits (10× `spec:`-Präfix, 1× `plan:`, dazu `a0e74f1` „Entscheidungs-Schritt", `bc447fe` „Lastenheft-CR v0.2.0", `d30db38` Bootstrap); die einzigen **zwei** Implementierungs-Commits (`c615da7`, `7b717f4`) sind genau die zwei redaktionellen | trifft zu |

Der vom Review widerlegte Satz ist im Eintrag **benannt statt geglättet** (Zeilen 683–687, mit
ausdrücklichem Verweis auf [`AGENTS.md`](../../AGENTS.md) §3.6) — das ist die von Modul 11 verlangte
Behandlung: der Cutoff macht Setzung 2 zu einer **neuen Disziplin**, nicht zu einer falschen
Ist-Beschreibung. Die Durchsetzungs-Lücke ist ehrlich als „benannt, nicht geschlossen" ausgewiesen
(kein halluziniertes Gate, `LH-QA-01` gewahrt).

### Detail zu §3 — die Ist-Messung des Plans, unabhängig reproduziert

Alt-Baum aus `80eec58` extrahiert, gegen HEAD-Baum verglichen (Versions-Strings und Welle-Nummer
normalisiert):

- Dateisatz **identisch** (0 hinzugefügt, 0 entfernt), **42** Dateien.
- **36 von 42** inhaltlich geändert.
- Nach Normalisierung bleiben **genau drei** substanzielle Änderungen:
  `regelwerk/grundlagen-konventionen.md` (12 Zeilen — der CR-Absatz),
  `regelwerk/README.md` (2 Zeilen — Stand-Zeile),
  `templates/spec/lastenheft.template.md` (6 Zeilen — dieselbe Regel im Template).

Die §3-Messung ist damit **nicht geschätzt, sondern reproduzierbar** — genau der Punkt, gegen den
§6 das Risiko „eine Regel geht im Rauschen von 36 geänderten Dateien unter" formuliert.

### Zusätzlich: `make full-smoke` — wiederholt, begründet

**Entscheidung: wiederholt.** Begründung: der **Emit-Pfad ist real berührt** —
`templates/spec/lastenheft.template.md` liegt im vendorten Template-Baum, den ein Ziel-Repo erbt,
und hat +6 Zeilen bekommen. §6 benennt `make smoke`/`make full-smoke` ausdrücklich als *den Beleg*
statt der Annahme, und `full-smoke` liegt **nicht** in `make gates` — der Lauf des Implementers ist
also eine Behauptung ohne deckenden Gate-Lauf. Genau die Klasse, die Modul 11 dem Verifier zuweist.

Ergebnis: **Exit 0**, alle **elf** `full-smoke: OK —`-Zusagen grün, inklusive
`Bootstrap (Baseline v3.5.2 vendored + …)` im emittierten Repo, Gate-Nachweis-Kreis, Guard-Boden,
Mono-Repo-Koexistenz, Arch-Gate konditional + robust, Idempotenz/kein Prune. Der geerbte
Template-Zuwachs bricht den Emit-Pfad nicht.

---

## Abweichungen

### A-1 — die Zählung „13 Vorkommen in 4 Dateien" trifft weder Ist-Stand noch Diff (LOW, Plan-Text)

DoD-Punkt 6 und §3 nennen „13 Vorkommen in 4 Dateien" (`conventions.md` 6×,
`benutzerhandbuch.md` 3×, `reviewer.md` 3×, `roadmap.md` 1×). Selbst gezählt (Vorkommen, nicht
Zeilen) trug `80eec58` **15**: `conventions.md` 6, `benutzerhandbuch.md` 3, `reviewer.md` 3,
**`roadmap.md` 3** (die slice-049-Zeile trägt zwei weitere, beschreibende). Gezogen wurden **11**,
bewusst behalten **4** (nicht 2). Die Korrektur im Review-Nachtrag (F-4: „13 Vorkommen, 11 gezogen,
2 behalten") ist damit **selbst noch zwei zu niedrig**.

**Wirkung:** keine auf die Substanz — es blieb keine aktive Referenz stehen, und keine historische
wurde fälschlich gebumpt (unabhängig verifiziert). Die Zahl ist jedoch als Checkliste für den
nächsten Re-Vendor gedacht; sie stimmt in keiner der drei Lesarten (Gesamt-Vorkommen, aktive
Vorkommen, gezogene Vorkommen) durchgängig. **Empfehlung:** in der Closure-Notiz die Form
„N aktive gezogen / M historisch behalten" festhalten statt einer Gesamtzahl.

### A-2 — der stehende Review-Verdikt ist weiter NICHT KONFORM (Closure-Trigger, nicht DoD)

§5 Closure-Trigger verlangt „Review konform (Modul 10)". Der
[Review-Report](2026-07-26-slice-049-impl-review.md) verdiktiert **NICHT KONFORM, merge-blockierend**;
aufgelöst ist das bislang nur durch einen **Nachtrag der Implementation in derselben Datei**, nicht
durch einen neu ausgestellten Reviewer-Verdikt. Ich habe die behaupteten Auflösungen einzeln
geprüft — sie sind **real eingetreten**:

- **F-1** (HIGH): `MR-015` Setzung 2 ist umgeschrieben, die 16/6/10-Messung und die Klassifikation
  der 10 sind im Eintrag korrekt (von mir nachgemessen), der widerlegte Satz ist benannt.
- **F-2** (MEDIUM): `c615da7` steht gleichrangig neben `7b717f4`; beide Diffs von mir gelesen und
  als rein redaktionell bestätigt.
- **F-4** (LOW): übernommen — mit der in A-1 beschriebenen Rest-Ungenauigkeit.
- **F-5** (LOW): behoben — `git grep "blob/v3.5.1"` findet in aktiven Dokumenten nur noch die
  §6-**Prosa-Erwähnung** des Bump-Musters, keinen Verweis mehr.
- **INFO-1**: behoben — `MR-015`-Geltungsbereich nennt `AGENTS.md` nicht mehr als berührt.
- **F-3** (MEDIUM): **bewusst nicht behoben.** Die Ablehnung ist belegt begründet (beide Commits
  liegen auf `origin/main`; Abhilfe wäre ein Force-Push auf den öffentlichen Default-Branch; keine
  adoptierte Konvention verlangt gate-grüne Zwischen-Commits). Ich teile die Substanz-Feststellung
  und die Verhältnismäßigkeits-Abwägung — **aber die Annahme einer abgelehnten
  MEDIUM-Review-Feststellung ist keine Implementer-Entscheidung.** Sie gehört vor die Closure, und
  der Slice führt sie derzeit nur als Roadmap-Kandidaten-Schärfung.

**Das berührt die DoD nicht** (kein DoD-Punkt verlangt gate-grüne Zwischen-Commits) — es blockiert
den Closure-Trigger. Kein „wir nehmen das mildere Ergebnis" (Modul 11 §Regeln).

### A-3 — DoD-Abhakung und Closure-Notiz stehen aus (formal)

Alle **11** DoD-Kästchen im aktiven Slice sind `- [ ]`, keines `- [x]`. Repo-Praxis für abgeschlossene
Slices ist das Gegenteil (`done/slice-048-release-artefakte.md`: 9× `- [x]`, 0× `- [ ]`). Zusammen mit
der leeren §7 (DoD-Punkt 11) sind das die beiden offenen Closure-Schritte. Erwartbar für einen Slice
in `in-progress/` — hier festgehalten, damit die Abhakung nicht *nach* diesem Report als bereits
verifiziert gilt: **verifiziert ist der Sachstand, nicht das Häkchen.**

### A-4 — „Provenienz vor dem Entpacken" bleibt inferentiell (INFO)

`MR-007` Setzung 1 verlangt die Prüfung **vor** dem Entpacken; DoD-Punkt 2 wiederholt das. Kein
Artefakt hält die Reihenfolge fest — sie steht allein in der Commit-Message von `ce4b611`. Der
Verifier kann sie nachträglich nicht widerlegen und nicht bestätigen. **Materiell entwertet** ist
die Frage hier durch die oben nachgezogene Byte-Identität: der Baum stammt nachweislich aus dem
Asset mit dem gepinnten Hash, eine nachgelagerte Prüfung hätte dasselbe Ergebnis gehabt. Für den
Regelfall bleibt es eine nicht sensorisch gedeckte Zusage — dieselbe Quadranten-Lücke, die
`MR-015` §Durchsetzung für sich selbst benennt.

---

## Gesamt-Urteil

**DoD BESTÄTIGT.**

Zehn von zehn prüfbaren DoD-Punkten sind **bestätigt — jeder mit einem Beleg, den ich selbst
erhoben habe**, nicht mit einem übernommenen. Punkt 11 (Closure-Notiz) ist für einen Slice in
`in-progress/` noch nicht fällig.

Der Kern des Slice hält doppelt: die **Provenienz-Kette ist zum ersten Mal in diesem Repo bis zum
Upstream-Asset durchgezogen** (`curl` → sha256 → `diff -rq` byte-identisch → `SHA256SUMS`
unabhängig nachgerechnet), und die **normative Arbeit** — `MR-015` — trägt nach dem Review-Fix eine
Ist-Messung, die ihrem eigenen benannten Verfahren standhält: 16/6/10 und die Klassifikation der
zehn Bündel sind von mir Commit für Commit reproduziert worden. Alle vier geforderten Gate-Läufe
sind **real grün gesehen** (`gates` Exit 0 · `mutate` 81 ok/0 · `baseline-verify` 42 Dateien ·
`baseline-freshness` Exit 0), dazu der nicht geforderte, aber sachlich gebotene `full-smoke`
(Exit 0) für den berührten Emit-Pfad.

Keine **DoD-Verletzung** — also kein Fund der Klasse, die nur der Verifier fängt. Die vier
Abweichungen sind eine Zähl-Ungenauigkeit im Plan-Text (A-1), zwei Closure-Reste (A-2, A-3) und
eine artefaktisch nicht deckbare Reihenfolge-Zusage (A-4).

**Vor der Closure zu klären:** A-2 — der stehende Review-Verdikt lautet NICHT KONFORM, und die
Annahme des abgelehnten F-3 ist keine Implementer-Entscheidung. Der Closure-Trigger §5 verlangt
einen konformen Review; die DoD verlangt ihn nicht. Beides ist getrennt zu halten.
