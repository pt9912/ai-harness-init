# Review-Report: slice-123 — 2026-09-06

**Review-Art:** Verifikation — geprüft wird gegen **DoD und Spec** (Modul 11), nicht gegen
Plan/ADR/Hard Rules (das ist Reviewer-Arbeit, zwei Runden liegen vor). Dieser Lauf liest den
Slice-Plan im **aktuellen** Wortlaut nach der Planner-Neufassung (`a43c3dd`, `9b9f07b`), nicht die
Zitate aus den Review-Reports. **Nicht Gegenstand:** Closure-Notiz §7, DoD-Häkchen (Planner,
§3.10) und `ADR-0037` (anderer Vorgang).

**Gegenstand:** `slice-123` — Bestand `bdc96e8..9b9f07b` auf `main` (11 Commits). Kern:
`harness/tools/history-range-guard.sh`, `Makefile`-Target `history-range-guard`,
`test/history-range-guard.bats`, `test/mutations/265-268-*.sh`, Checkout-Tiefen-Dokumentation in
`.github/workflows/{ci,release,upstream-drift}.yml`, `harness/README.md`, sowie zwei Nachträge an
`.claude/commands/implement-slice.md` und dessen emittiertem Pendant.

**Modell:** claude-sonnet-5 · **Datum:** 2026-09-06

**Eingangs-Kontext:**

- Slice-Plan `docs/plan/planning/done/slice-123-ci-sieht-die-historie.md`, aktueller Stand
  nach `9b9f07b` (§1 Anlass-Messung, §2 DoD (1)–(3), §3 Plan-Tabelle, §6 Risiken).
- Review-Report Runde 1 (`2026-09-06-slice-123-history-range-guard-review.md`) und Runde 2
  (`2026-09-06-slice-123-history-range-guard-review-runde-2.md`) — als Kontext gelesen, nicht als
  Prüfgrundlage übernommen; jede Behauptung unten ist selbst nachgemessen.
- `LH-QA-01` (keine halluzinierten Gates), `LH-QA-02` (Reproduzierbarkeit), `ADR-0003`
  (Docker-only), `MR-007` Setzung 3 (*blind und grün*), `MR-025` (Zahl neben Kommando).
- `AGENTS.md` §3.6 (rot gesehenes Gegenbeispiel), §3.7 (Kommentar-Regel), §3.9 (Docker-only),
  §3.10 (Abnahmekriterium bleibt beim Planner).

---

## 1. DoD-Punkte, einzeln nachgemessen

### DoD (1) — history-lesender Schritt mit leerer Range fällt statt grün zu melden

**Erfüllt.** Selbst reproduziert, nicht nur behauptet übernommen:

```
$ git clone --depth 1 file:///Development/KI/ai-harness-init /tmp/klon-verify
$ cd /tmp/klon-verify && git log --oneline | wc -l
1
$ bash harness/tools/history-range-guard.sh HEAD..HEAD
history-range-guard: Range 'HEAD..HEAD' ist aufloesbar, aber LEER (0 Commits).
  Shallow-Grenzen: 1
  Angeforderte Range: HEAD..HEAD
  -> Checkout braucht 'fetch-depth: 0' (oder ausreichende Tiefe) fuer diesen Job.
$ echo $?
1
```

Und das Gegenbeispiel — **ohne** den Wächter bleibt genau dieselbe Range blind grün — real gegen
d-check gefahren (Modul `vcs` mit gesetztem `paths:`-Config-Block, netzlos, `:ro`-Mount, Image
`v0.74.1` per Digest):

```
$ docker run --rm --network none -v "$PWD:/repo:ro" -w /repo \
    ghcr.io/pt9912/d-check:v0.74.1 --enable vcs --range HEAD..HEAD --config .d-check-vcs.yml
d-check: 840 Datei(en) geprüft, 0 Befund(e)
$ echo $?
0
```

Die unauflösbare Basis (`HEAD~1..HEAD`) bricht — wie DoD (1) selbst festhält — schon **ohne** den
Wächter mit d-check-Exit 2 ab; auch das selbst nachgefahren:

```
$ bash harness/tools/history-range-guard.sh HEAD~1..HEAD   # EXIT 2, "NICHT aufloesbar"
$ docker run … --enable vcs --range HEAD~1..HEAD …
d-check: error: Range-Basis "HEAD~1" nicht auflösbar: object not found   # EXIT 2
```

Alle vier Zahlen/Meldungen decken sich exakt mit der Tabelle in Slice-Plan §1. Die Zusage nennt
korrekt **Shallow-Grenzen** statt *Tiefe* (Nacharbeit zu F-2/N-3) — die Ausgabe trägt tatsächlich
`Shallow-Grenzen: 1`, kein `Tiefe:`-Label. Der bats-Fall-**Name** `test/history-range-guard.bats:26`
trägt noch das Wort „Tiefe" (Finding N-3, LOW, Runde 2) — das ist eine Reviewer-Beanstandung
gegen Maintainability, keine DoD-Verletzung: DoD (1) bindet die **Ausgabe des Wächters**, nicht den
bats-Fall-Namen, und die Ausgabe selbst ist korrekt.

### DoD (2) — Checkout-Zuordnung mit Begründung neben der Zeile

**Erfüllt, als Aussage über der leeren Menge — offen benannt, nicht verdeckt.** Nachgemessen:

```
$ grep -rnE 'doc-immutable|doc-commits' .github/workflows/ | grep -v ':[0-9]*:#' | wc -l
0
$ grep -rn 'fetch-depth' .github/workflows/ | grep -v ':[0-9]*:#' | wc -l
0
$ grep -c 'uses: actions/checkout' .github/workflows/ci.yml
4
$ grep -rn 'uses: actions/checkout' .github/workflows/*.yml | wc -l
7
```

Beide Mengen sind leer — das Kriterium „Historie-lesende Schritte ⊆ Checkouts mit voller Tiefe"
ist vakuos wahr, exakt wie die aktuelle DoD-Klausel selbst sagt („Das Kriterium ist damit über der
leeren Menge wahr, und das ist der Befund, nicht seine Umgehung"). Die verlangte Begründung neben
der Zeile ist an allen drei Workflow-Dateien vorhanden und wortgleich konsistent — selbst gelesen
in `ci.yml:18–33`, `release.yml:26–29`, `upstream-drift.yml:17–21`: alle drei tragen dieselbe
repo-weite Sieben-Checkout-Zählung und verweisen für die Begründung auf `ci.yml`. Kein
`fetch-depth: 0` wurde irgendwo gesetzt — konsistent mit der Feststellung, dass die Zuordnungsmenge
leer ist. **Ein Sensor dafür existiert nicht**, wie die DoD-Klausel selbst sagt — geprüft ist hier
nur, dass die Klausel die Realität korrekt beschreibt, nicht dass ein Gate sie hält.

### DoD (3) — Wächter hat seinen Zahn

**Erfüllt.** Der benannte Mutationsfall trifft die korrekt benannte Stelle (Leer-Erkennung der
Range, nicht eine nicht existierende Tiefen-Prüfung — Nacharbeit `9b9f07b`, Planner). Selbst
reproduziert, an einer isolierten Kopie (keine Repo-Datei verändert):

```
$ sed -i 's/count" -eq 0/count" -eq 1/' history-range-guard.sh   # = test/mutations/265-…
$ bash history-range-guard.sh --decide "HEAD..HEAD" 0
history-range-guard: Range 'HEAD..HEAD' aufgeloest, 0 Commit(s) — OK.
$ echo $?
0
```

Ohne den Zahn (ungemutiert) liefert derselbe Aufruf Exit 1 mit der LEER-Meldung (siehe DoD (1)) —
der benannte bats-Fall 119 fällt also rot, sobald die Mutation greift, exakt die Zusage. Drei
weitere Mutationsfälle (266–268) decken zusätzliche, in DoD (3) nicht verlangte Härtungen
(Ganzzahl-Wachen, `--staged`-Leerfall-Meldung) — ebenfalls selbst an Fall 266 nachgefahren (Exit 0
statt 2 nach Entfernen der `case`-Wache). Das ist zusätzliche Deckung, keine Abweichung von DoD (3).

### Standard-Punkte der Vorlage

- **`make gates` grün:** selbst gefahren, **EXIT 0** — `baseline-verify` (v6.0.0, 53 Dateien),
  `docs-check` (840 Dateien, 0 Befund(e)), `comment-claims` (56 Dateien, 0 Befund(e)), `lint`,
  `build`, `test` (Go `-count=1`, alle Pakete `ok`), `shell-lint` (shellcheck clean), `ci-lint`
  (actionlint clean), `host-bin`, `span-check` (Träger vorhanden, Span geschrieben,
  git-ignorierter Ablageort). `make test-bats` separat: **225 Fälle, 0 `not ok`**, darunter die
  sieben neuen `history-range-guard`-Fälle (119–125), alle `ok`.
- **`make mutate` ohne Befund:** **nicht** eigenständig als Vollauf reproduziert — beim Versuch
  hielt `.harness/state/mutate.lock` bereits ein aktiver Prozess (vermutlich ein weiterhin
  laufender Implementer-Lauf; der Auftrag verlangt ausdrücklich, keine Code-Dateien anzufassen und
  keine fremden Läufe zu stören, darum wurde der Lock nicht entfernt). Ersatzweise: die vier
  slice-eigenen Mutationsfälle (265–268) sind einzeln, isoliert und manuell nachgefahren (siehe
  DoD (3) oben) und schlagen exakt wie benannt. **Diese Lücke ist benannt, keine verdeckte
  Nicht-Prüfung:** ein repo-weiter `make mutate`-Beleg über diesem Endstand liegt nicht vor, weder
  von diesem Lauf noch von einem vorherigen (Review Runde 2 hält das für sich selbst fest: „`make
  mutate` ist **nicht** gefahren (Laufzeit)"). Empfehlung an den Planner: vor Closure einen
  `make mutate`-Lauf nachholen, sobald der Lock frei ist.
- **Doku-Update, falls öffentlicher Vertrag berührt:** `harness/README.md` aktualisiert — geprüft
  unten unter Spec-Konformität.

## 2. Plan-vs-Code-Diff

Vollständiger Datei-Diff über den Slice-Bestand (ADR-0037-Commit `dab5028` ausgenommen, gehört
nicht zu diesem Slice):

```
.claude/commands/implement-slice.md                 |  18 +-
.github/workflows/ci.yml                            |  17 +
.github/workflows/release.yml                       |   5 +
.github/workflows/upstream-drift.yml                |   6 +
Makefile                                            |  18 +-
harness/README.md                                   |   2 +
harness/tools/history-range-guard.sh                | 173 ++
internal/emit/templates/commands/implement-slice.md |  20 +-
test/history-range-guard.bats                       |  71 ++
test/mutations/265-268-*.sh                         |  61 ++
```

**Deckt Plan §3, was der Plan vorsah:** `ci.yml` (update — hier: nur die Begründungs-Kommentare,
kein `fetch-depth: 0`, konsistent mit der leeren Zuordnungsmenge aus DoD (2)) ·
`harness/tools/history-range-guard.sh` (neu, DoD (1)) · `Makefile` (update, `history-range-guard`
Target, **nicht** in `record-gates`/`gates`) · `test/` (neu, bats + vier Mutationsfälle) ·
`harness/README.md` (update). `harness/conventions.md` unberührt (Plan sagte „nicht durch diesen
Slice" — bestätigt, kein Treffer im Diff). `release.yml` war als „vermutlich unverändert, zu
prüfen" markiert — geprüft und dokumentiert (Kommentar-Zeilen ergänzt, keine funktionale
Änderung) — das ist die Einlösung des Prüfauftrags, keine Abweichung.

**Nicht von Plan §3 gedeckt (zwei Funde):**

1. **`upstream-drift.yml`** trägt denselben Begründungs-Kommentar wie `ci.yml`/`release.yml`, ist
   in der Plan-Tabelle §3 aber **gar nicht genannt** (die Tabelle nennt nur `ci.yml` und
   `release.yml`). Sachlich konsistent mit DoD (2)'s Anspruch, alle sieben Checkouts zu
   dokumentieren — aber der Plan hätte die Datei nennen müssen, um vollständig zu sein. Kein
   Hard-Rule-Verstoß, keine Scope-Ausweitung der Funktion — eine Lücke der Plan-Tabelle, nicht des
   Codes.
2. **`.claude/commands/implement-slice.md` + `internal/emit/templates/commands/implement-slice.md`**
   (Checklisten-Ergänzung „AGENTS.md §3.7-Check", Commits `11d02e1`/`82debf1`/`04c8f95`) stehen in
   **keiner** Zeile von Plan §3. Das ist der einzige Fund, der über eine Doku-Lücke hinausgeht: ein
   eigenständiger Prozess-Lerneintrag, ausgelöst durch eine während dieses Slice beobachtete
   Kommentar-Drift, aber sachlich unabhängig vom Wächter selbst. Die lokale Fassung ist nach
   [`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Eigentum der
   ausführenden Rolle (Implementer ändert sein eigenes Command-File legitim); für die
   **emittierte** Fassung lässt `ADR-0028` die Eigentumsfrage ausdrücklich offen, und genau das
   benennt der Slice-Plan selbst in §6 als *„Offene Norm-Frage"* — die Änderung ist also nicht
   verschwiegen, aber die Plan-Tabelle §3 hätte sie als Zeile führen müssen, statt sie nur im
   Risiko-Abschnitt zu erwähnen. **Kein DoD-Verstoß** (DoD (1)–(3) sagt über diese Dateien nichts
   aus) und **kein Merge-Blocker** — eine Unvollständigkeit der Plan-Tabelle gegenüber dem
   tatsächlichen Diff, die für den Planner bei Closure notierenswert ist.

**Kein Scope-Creep in der Kernfunktion:** Der Wächter selbst (`decide()`/`decide_staged()`) tut
genau, was §1/DoD (1) beschreibt — nichts darüber hinaus (keine zusätzliche Tiefen-Prüfung, kein
automatischer `fetch-depth`-Eintrag, keine CI-Integration, die DoD (2) nicht vorsieht).

## 3. Spec-/ADR-Konformität

- **`LH-QA-01` (keine halluzinierten Gates):** `history-range-guard` steht **nicht** in
  `record-gates`/`gates` — nachgemessen: `grep -nE '^record-gates:' Makefile` zeigt
  `baseline-verify docs-check lint build test shell-lint ci-lint comment-claims host-bin
  span-check`, ohne `history-range-guard`. Das Makefile-Kommentar zum Target trägt selbst
  „NICHT in gates". `harness/README.md:73` sagt dasselbe („kein Gate, in keiner
  Prerequisite-Kette"). **Konform.**
- **`LH-QA-02` (Reproduzierbarkeit):** Der Wächter ist reiner `bash`+`git`, deterministisch (keine
  Uhrzeit, kein Zufall), die reine Entscheidung (`decide()`/`decide_staged()`) ist von den
  `git`-Aufrufen getrennt und mit Fixture-Werten hermetisch bats-testbar — dieselbe Bauart wie
  `component-freshness.sh`/`slice-mv.sh`. **Konform.**
- **`ADR-0003` (Docker-only):** Der Wächter ruft `bash` und `git` — beide sind nach `AGENTS.md`
  §3.9 als Host-Voraussetzung geführt (wie `slice-mv`/`archive-welle`), keine Go-Toolchain, kein
  Paketmanager. **Konform.**
- **`harness/README.md`-Aussage über den Wächter (Zeile 73):** Selbst gegen den Code gehalten —
  jede Teilaussage stimmt: „kein Gate, in keiner Prerequisite-Kette" (bestätigt oben); „prüft die
  Range, nicht die Klon-Tiefe" (bestätigt, `decide()` bewertet ausschließlich `count`); „deckt die
  unauflösbare Basis nicht zusätzlich" (bestätigt, d-check bricht dort schon selbst ab); „heute
  ohne Aufrufer — kein Job ruft `doc-immutable`/`doc-commits`" (bestätigt,
  `grep -rn 'run:.*history-range-guard' .github/workflows/` → 0 Treffer). Das Zitat der
  `--staged`-Leerfall-Meldung in der README weicht in Zeichensetzung vom realen Output ab
  (bereits als N-4/LOW im Review-Report Runde 2 festgehalten: ASCII-Umschrift und Punkt fehlen im
  Zitat) — das ist eine bereits erkannte, nicht blockierende Maintainability-Abweichung, keine
  neue DoD- oder Spec-Verletzung.

## 4. §6-Risiken — auf verdeckte DoD-Verletzung geprüft

Alle acht Einträge in §6 gelesen und einzeln gegen die Frage geprüft, ob einer in Wahrheit ein
DoD-Defekt ist, der als Risiko getarnt wurde:

| Risiko | Befund |
|---|---|
| Wächter beweist sich nur am konstruierten Klon | Kein DoD-Verstoß — DoD (1) benennt diesen konstruierten Klon selbst als seinen Rot-Nachweis; kein Widerspruch. |
| `fetch-depth: 0`-Kosten ungemessen | Faktisch **gegenstandslos** geworden: Da die Zuordnungsmenge aus DoD (2) leer ist, wurde nirgends `fetch-depth: 0` gesetzt — es gibt keine Kosten zu messen. Kein DoD-Verstoß, aber ein stehengebliebener Risiko-Text, der die eigene Prämisse (es werde `fetch-depth: 0` gesetzt) nicht mehr trifft — für die Closure zu bereinigen. |
| Guard deckt nur einen Job | Ehrlich benannte Grenze, deckungsgleich mit README-Aussage. Kein Verstoß. |
| Kein zweiter Klient (`.codex`) | Lokal ohnehin nicht betroffen (CI-spezifische Blindheit) — kein Verstoß. |
| Offene Norm-Frage `internal/emit/templates/commands/*.md` | Siehe Abschnitt 2 oben — führt zu einer Plan-Tabellen-Lücke, nicht zu einer DoD-Verletzung; die Frage selbst ist zu Recht an den Architect delegiert und hier nicht entschieden. |
| DoD-(2)-Zuordnung über leerer Menge | Das ist die aktuelle DoD-Klausel selbst, nicht ihr Verstoß — konsistent (siehe DoD (2) oben). |
| Eingefrorener Runde-1-Report nennt Plan-Pfad (N-6) | Reine Closure-/Move-Vorbereitung nach §3.11 — kein DoD-Bezug, außerhalb dieses Verifikationsgegenstands. |

**Kein als Risiko getarnter DoD-Defekt gefunden.**

## Negativbefunde

- geprüft, ohne Befund: **DoD (1), (2), (3)** — jeweils der behauptete Rot-Nachweis selbst
  gefahren, nicht nur die Behauptung übernommen (Abschnitt 1).
- geprüft, ohne Befund: **`LH-QA-01`/`LH-QA-02`/`ADR-0003`** gegen den aktuellen Code-Stand
  (Abschnitt 3).
- geprüft, ohne Befund: **Scope-Creep in der Kernfunktion** des Wächters selbst — `decide()`/
  `decide_staged()` tun exakt, was DoD (1) beschreibt, nichts darüber hinaus.
- geprüft, ohne Befund: **§6-Risiken als versteckte DoD-Verletzung** — keiner der acht Einträge
  maskiert einen DoD-Defekt (Abschnitt 4).
- geprüft, mit **zwei Funden ohne Blockierwirkung**: Plan-§3-Tabelle nennt `upstream-drift.yml`
  nicht, obwohl berührt; Plan-§3-Tabelle nennt `.claude/commands/implement-slice.md` und ihr
  emittiertes Pendant nicht, obwohl geändert (Abschnitt 2).
- **nicht geprüft, benannt statt verschwiegen:** `make mutate` als Vollauf über dem Endstand —
  aktiver Lock durch einen (vermutlich) parallel laufenden Prozess; Ersatz-Nachweis über die vier
  isolierten Einzelfälle erbracht.

## Verdikt

**DoD erfüllt: (1) ja · (2) ja (als Aussage über der leeren Menge, offen benannt) · (3) ja.**

**Kein Merge-Blocker aus Verifier-Sicht.** Die beiden Plan-Tabellen-Lücken (`upstream-drift.yml`,
`implement-slice.md`-Paar) sind Vollständigkeits-Mängel des Plans gegenüber dem tatsächlichen Diff,
keine Abweichungen des Codes von einer expliziten Zusage, und keine der drei DoD-Klauseln wird
davon berührt. Die offene Norm-Frage zu `internal/emit/templates/commands/*.md` bleibt zu Recht
beim Architect.

**Einzige echte Lücke:** ein repo-weiter `make mutate`-Beleg über dem Endstand `9b9f07b` liegt
nicht vor (weder aus diesem noch aus einem vorherigen Lauf) — Standard-Punkt der Vorlage, nicht
slice-eigene DoD, aber Closure-Trigger (§5) nennt „`make mutate` ohne Befund" explizit. Empfehlung
an den Planner: vor `git mv` nach `done/` einen vollständigen `make mutate`-Lauf nachholen oder das
Fehlen bewusst als Closure-Notiz-Punkt festhalten.

**Übergabe:** Dieser Bericht geht an den Planner (Modul 8, Verifier→Planner-Kante). Er ersetzt kein
Review — Plan-/ADR-/Hard-Rule-Konformität ist bereits zweifach geprüft (Runde 1, Runde 2). Er
ersetzt keine Closure-Entscheidung über die beiden benannten Plan-Tabellen-Lücken oder die fehlende
`make mutate`-Vollabdeckung — das ist Planner-Urteil, ob es trägt.
