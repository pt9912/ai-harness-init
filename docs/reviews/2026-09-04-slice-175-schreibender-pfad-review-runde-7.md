# Review Runde 7 — slice-175, das Namens-Muster und das Gesamt-Verdikt über sieben Runden

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 8/10) — frischer Kontext, getrennt von Implementation, Architektur und Planung |
| **Review-Art** | Nachprüfung des MEDIUM aus Runde 6 mit **selbst gefahrenen** Sonden, dazu das abschließende Gesamt-Verdikt über die Kette. **Nicht** DoD-Abhakung und **keine** Gate-Lauf-Bestätigung (Verifier, Modul 11) |
| **Gegenstand** | `git show e1faab5` — ein Behebungs-Commit über fünf Dateien (`test/unterkommando-kopplung.bats` +27/−3, `cmd/ai-harness-init/main.go` +5/−3, `harness/README.md`, `test/mutations/259-hostbin-name-mit-ziffer.sh` und `test/mutations/260-span-emit-hook-name-mit-ziffer.sh` neu) |
| **Runde 1** | [`2026-09-04-slice-175-schreibender-pfad-review.md`](2026-09-04-slice-175-schreibender-pfad-review.md) — 1 HIGH, 5 MEDIUM, 2 LOW, 2 INFO |
| **Runde 2** | [`2026-09-04-slice-175-schreibender-pfad-review-runde-2.md`](2026-09-04-slice-175-schreibender-pfad-review-runde-2.md) — 1 HIGH, 1 MEDIUM |
| **Runde 3** | [`2026-09-04-slice-175-schreibender-pfad-review-runde-3.md`](2026-09-04-slice-175-schreibender-pfad-review-runde-3.md) — 1 HIGH (Verdrahtung `echterEingang()`) |
| **Runde 4** | [`2026-09-04-slice-175-schreibender-pfad-review-runde-4.md`](2026-09-04-slice-175-schreibender-pfad-review-runde-4.md) — 1 HIGH (Bedien-Einstieg `Makefile:322`), 1 MEDIUM, 1 LOW |
| **Runde 5** | [`2026-09-04-slice-175-schreibender-pfad-review-runde-5.md`](2026-09-04-slice-175-schreibender-pfad-review-runde-5.md) — 0 HIGH, 2 MEDIUM, 1 LOW, 1 INFO |
| **Runde 6** | [`2026-09-04-slice-175-schreibender-pfad-review-runde-6.md`](2026-09-04-slice-175-schreibender-pfad-review-runde-6.md) — 0 HIGH, 1 MEDIUM, 1 LOW, 1 INFO |
| **Plan** | [`docs/plan/planning/done/slice-175-archive-welle-schreibender-pfad.md`](../plan/planning/done/slice-175-archive-welle-schreibender-pfad.md) |
| **Bindende ADRs** | [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) (**`Proposed`**, Prüfmaßstab laut Plan), [ADR-0011](../plan/adr/0011-telemetrie-erfassung-policy.md) (**`Accepted`**), [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md), [ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md), [ADR-0003](../plan/adr/0003-go-native-binaries.md) |
| **Anforderungen** | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit); [`AGENTS.md`](../../AGENTS.md) §3.2, §3.6, §3.7, §3.8, §3.9 |
| **Skill-Version** | `.harness/skills/reviewer.md` 1.6.0 |
| **Modell** | Claude Opus 5 (1M context) |
| **Kontext frisch** | ja — **kein Beleg aus dem Implementer-Bericht und keiner aus den eigenen Reports der Runden 1–6 übernommen.** Jedes Rot und jedes Grün unten ist in dieser Sitzung selbst gefahren; das Kommando steht beim Befund. Wo eine Stufe **nicht** selbst gemessen wurde, steht das ausdrücklich dabei |

**Wie gemessen wurde.** Vierzehn Sonden über einer **Kopie des Baums außerhalb des Repos**
(`tar --exclude=.git --exclude=.harness/state`), je mit `make test-bats`; dazu ein
`make test-go` über einer der mutierten Kopien und ein vollständiger, selbst gefahrener
`make mutate` über dem echten Baum. Alle Läufe Docker-only über `make`
([`AGENTS.md`](../../AGENTS.md) §3.9). Die Kopie ist byte-gleich zum HEAD-Blob —
`diff <(git show HEAD:<datei>) <kopie>` leer für `test/unterkommando-kopplung.bats`,
`Makefile`, `.claude/settings.json`, `cmd/ai-harness-init/main.go` und die zwei neuen
Fall-Dateien. Die Messungen gelten für `e1faab5`.

**Ausgangs-Lauf, unmutiert.** `make test-bats` über der Kopie: `1..212`, ein einziges
`not ok 127 driver: die Kopie traegt den Sensor-Bedarf inklusive .git` — ein Artefakt der Kopie
ohne `.git`, kein Befund. Beide Kopplungs-Fälle grün: `ok 211` (Makefile) und `ok 212`
(`.claude/settings.json`). Jedes Rot unten hebt sich gegen dieses Grün ab.

---

## Die vierzehn Sonden dieser Sitzung

| # | Sonde | Ziel | Erwartet | Gemessen |
|---|---|---|---|---|
| A | `bash test/mutations/259-hostbin-name-mit-ziffer.sh` | gelisteter Fall | rot | **rot** — `not ok 211`, *„der Makefile gibt dem Traeger 'archive-welle2', und main() dispatcht diesen Namen nicht"*, mit dem Dispatch-Auszug |
| B | `bash test/mutations/260-span-emit-hook-name-mit-ziffer.sh` | gelisteter Fall | rot | **rot** — `not ok 212`, dieselbe Form mit `'span-emit2'` |
| C | **eigener** Fall: `archive-welle` → `archive-welle.alt` (Punkt statt Ziffer) | Allgemeinheit des Musters | rot | **rot** — `not ok 211`, *„gibt dem Traeger 'archive-welle.alt'"* |
| D | **eigener** Fall: `span-emit` → `span-emitX` (Großbuchstabe) an **einem** der drei Hooks | Allgemeinheit + Einzel-Nennung | rot | **rot** — `not ok 212`, *„gibt dem Traeger 'span-emitX'"* |
| E | Weißlisten-Fassung `[a-z][a-z-]*` wiederhergestellt + Fälle 259/260 | Defekt reproduzieren | ? | **grün** — `ok 211` **und** `ok 212`; die Zähne kommen aus diesem Commit |
| F | Dispatch-Zweig zu `case "archive-welle-neu":` umbenannt **und** das Literal `case "archive-welle":` in eine Kommentar-Zeile von `main.go` geschrieben | Entscheidungs-Grep | ? | **grün** — `ok 211`; s. LOW-1 |
| F′ | dieselbe Kopie, `make test-go` | zweiter Sensor | ? | **rot** — drei `--- FAIL:` in `cmd/ai-harness-init/archive_welle_echt_test.go` |
| G | Makefile-Kommentar `# Beispiel: $(HOST_BIN) archive-welle, das Ziel.` | dokumentierte Grenze 2 | rot | **rot** — *„gibt dem Traeger 'archive-welle,'"* |
| H | Makefile-Kommentar `# Beispiel: $(HOST_BIN) "$(WELLE)"` | dokumentierte Grenze 1 | rot (Kalibrierung) | **rot** — *„aus 5 Nennung(en) in der Makefile sind 4 Name(n) gewonnen"* |
| J1 | Zeilen-Zählung der Nennungen wiederhergestellt, **ohne** Mutation | Kontrolle | grün | **grün** — der Defekt ist am ruhenden Baum unsichtbar |
| J2 | Zeilen-Zählung + `test/mutations/256-hostbin-zweite-nennung-in-derselben-zeile.sh` | misst `256` noch, was es sagt? | grün (so sagt es `256`) | **rot** — *„aus 4 Nennung(en) … sind 5 Name(n) gewonnen"*; s. MEDIUM-1 |
| K | Zeilen-Zählung + `254`, `257`, `258`, `259`, `260` | Bezugsmenge messen | ? | **alle fünf rot** |
| L1 | Zeilen-Zählung + zweite Nennung in **derselben** Zeile **ohne** Namen (`\|\| $(HOST_BIN) "$(NOTFALL)"`) | Restloch | ? | **grün** — `ok 211`, während die zweite Nennung ungekoppelt ist |
| L2 | **heutiger** Sensor + dieselbe Mutation | Gegenprobe | rot | **rot** — *„aus 5 Nennung(en) … sind 4 Name(n) gewonnen"* |
| M | Weißlisten-Fassung + Fall `256` | welcher Zweig fiel vor `e1faab5`? | ? | **rot über die Kalibrierung** — *„aus 5 Nennung(en) … sind 4 Name(n) gewonnen"* |

Und der vollständige eigene Lauf: `MUTATE_JOBS=4 make mutate` → **`246 ok, 0 Befund(e)`**, EXIT 0,
*„Vollstaendigkeit — 246 von 246 Fall-Dateien mit Ergebnis, jede Fall-ID genau einmal gezogen"*
(Fall-Arbeit gesamt 3910,3 s). `254`–`260` je `ok`. `git status --porcelain` davor und danach leer;
der Treiber meldet *„4 isolierte Kopie(n) unter /tmp/… — der Host-Baum wird NICHT veraendert"*.

---

## Findings

### MEDIUM-1 — Das neue Namens-Muster schiebt `test/mutations/256` von der Kalibrierung in die Dispatch-Schleife; die Eigenschaft, für die der Fall angelegt wurde, hat damit kein Gegenbeispiel mehr, und sein Kopf sagt das Gegenteil

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (Hard Rule — eine Zusage ist fertig, wenn benannt
  ist, was sie brechen ließe, und das rot gesehen wurde) · [`AGENTS.md`](../../AGENTS.md) §3.7
  (Klasse *Zusage*) · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- **pfad:** `test/mutations/256-hostbin-zweite-nennung-in-derselben-zeile.sh:6-17` ·
  `test/unterkommando-kopplung.bats:69-71` (die zwei Zählungen)
- **befund:** Der Fall-Kopf trägt drei Aussagen über seine eigene Wirkung, und alle drei sind
  seit `e1faab5` gemessen falsch. Er sagt, die angehängte zweite Nennung sei *„eine, aus der das
  Namens-Muster nichts zieht"* (`:6-8`) — das neue Muster zieht `$(NOTFALL)`. Er sagt *„ER TRIFFT
  DIE SELBST-KALIBRIERUNG, NICHT DIE DISPATCH-SCHLEIFE"* (`:12`) — gemessen fällt heute die
  Dispatch-Schleife (*„der Makefile gibt dem Traeger '$(NOTFALL)'"*), während die Kalibrierung
  ausgeglichen bleibt; unter der Weißlisten-Fassung fiel dieselbe Mutation über die Kalibrierung
  (Sonde M). Und er sagt *„Zaehlte eine der beiden Zeilen statt Vorkommen, bliebe der Fall unter
  genau dieser Mutation gruen"* (`:16-17`) — mit wiederhergestellter Zeilen-Zählung ist der Fall
  **rot** (Sonde J2, *„aus 4 Nennung(en) … sind 5 Name(n) gewonnen"*). **Die Folge ist nicht
  kosmetisch:** `256` war das kuratierte Gegenbeispiel für die Vorkommen-Zählung, die Runde 5
  gefordert und `78eaba5` eingesetzt hat. Über die **gemessene** Bezugsmenge — die sechs Fälle,
  deren `# expect:` einen der zwei Kopplungs-Fälle nennt (`254`, `256`, `257`, `258`, `259`,
  `260`) — färbt **jeder** den Sensor auch mit Zeilen-Zählung rot (Sonden J2 und K). Kein Fall
  unterscheidet die zwei Zählweisen mehr, während der stille Grün-Pfad, den die Vorkommen-Zählung
  schließt, offen bleibt: dieselbe Zeile mit einer zweiten Nennung, die **keinen** Namen hergibt,
  lässt den Fall unter Zeilen-Zählung grün (Sonde L1) und ist unter dem heutigen Sensor rot
  (Sonde L2). `make mutate` meldet für `256` `ok` mit dem erwarteten Wächter — der Treiber prüft,
  *dass* der genannte Wächter rot wird, nicht *woran* er fällt, und kann die Wanderung darum
  nicht sehen. Kein Gate deckt die Stelle: `make comment-claims` hat `test/` dauerhaft außerhalb
  seines Prüfbereichs ([`AGENTS.md`](../../AGENTS.md) §4), `make shell-lint` liest
  `test/mutations/*.sh` als Syntax (selbst gefahren, Exit 0), und keine Markdown-Prüfung liest
  eine Shell-Zusage.
- **verifizierbar:** ja — `nennungen` in `test/unterkommando-kopplung.bats:69` auf
  `grep -cE "$nennung_muster" "$datei"` zurücksetzen und `bash test/mutations/256-….sh` fahren,
  dann `make test-bats`: der Kopf sagt grün, gemessen ist rot. Die verlorene Unterscheidung zeigt
  das Paar L1/L2 an derselben Zeile.
- **klasse:** Ein Fix macht die Zusage seines eigenen Gegenbeispiels falsch und nimmt ihm den
  Zahn (`BEO-009`)

### LOW-1 — Der Entscheidungs-Grep der Dispatch-Schleife ist unverankert und kommentar-blind, der Diagnose-Grep derselben Funktion zeilenverankert

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 · Maintainability
- **pfad:** `test/unterkommando-kopplung.bats:87` (Entscheidung) gegen `:91` (Diagnose)
- **befund:** Die Entscheidung lautet `grep -qF "case \"$n\":" "$MAIN"` und trifft jedes
  Vorkommen der Zeichenkette in `cmd/ai-harness-init/main.go`, auch eines in einem Kommentar; die
  Diagnose zwei Zeilen darunter liest `grep -nE '^[[:space:]]*case "[^"]*":'` und ist an den
  Zeilenanfang gebunden. **Gemessen** (Sonde F): Dispatch-Zweig zu `case "archive-welle-neu":`
  umbenannt und das Literal in eine Kommentar-Zeile geschrieben — `ok 211` bleibt stehen, obwohl
  `make archive-welle` gebrochen ist. Der Restschaden ist begrenzt und ebenfalls gemessen: für
  `archive-welle` fällt derselbe Baum in `make test-go` mit drei `--- FAIL:` in
  `cmd/ai-harness-init/archive_welle_echt_test.go` (Sonde F′), das den Träger als Prozess durch
  den echten Dispatch fährt. Für `span-report` steht daneben nichts in `make gates`: der Aufrufer
  ist `Makefile:272`, das Ziel selbst ist ausdrücklich nicht in der Gate-Kette, und
  `harness/tools/full-smoke.sh` fährt `make span-report` im **emittierten** Repo
  (`git grep -n 'span-report' -- 'harness/tools/*.sh' Makefile`). Dass die heutige `main.go` kein
  solches Kommentar-Literal trägt, ist gemessen (`grep -nE 'case "[^"]*":' cmd/ai-harness-init/main.go`
  → drei Treffer, alle im `switch`); die Datei führt aber einen 36-zeiligen Kommentarblock über
  genau diesen `switch`.
- **verifizierbar:** ja — `case "span-report":` umbenennen und die alte Form in eine
  Kommentar-Zeile derselben Datei schreiben, dann `make test-bats`: heute grün.
- **klasse:** Entscheidung und Diagnose derselben Prüfung tragen verschiedene Strenge

---

## Negativbefunde — geprüft, ohne Befund

- **Das MEDIUM aus Runde 6 ist geschlossen, und die Zähne kommen aus diesem Commit.** Die zwei
  gelisteten Fälle färben rot (A, B), zwei **eigene** Formen derselben Klasse ebenso — ein Punkt
  statt einer Ziffer (C) und ein Großbuchstabe an nur einem der drei Hooks (D) —, und die
  Weißlisten-Fassung lässt beide gelisteten Mutationen grün (E). Die Meldung nennt in allen
  vier Fällen den konkreten Namen und den heutigen Dispatch, ist also lesbar und nicht nur rot
  ([`AGENTS.md`](../../AGENTS.md) §3.6). Kein Befund.
- **Beide dokumentierten Grenzen des Namens-Musters halten wörtlich.** Der Kommentar
  `test/unterkommando-kopplung.bats:59-64` sagt, ein Trenner direkt hinter der Nennung falle in
  die Kalibrierung und ein am Namen klebendes Satzzeichen werde als unbekannter Name mitgelesen —
  gemessen genau so (H bzw. G, letzteres mit `'archive-welle,'` in der Meldung). Kein Befund.
- **Die Zusage über die Bezugsmenge des Musters stimmt.** `harness/README.md:79` sagt, gelesen
  werde *„bis zum nächsten Wort-Ende (Zwischenraum, doppeltes Anführungszeichen, Backtick)"* und
  die gezogene Menge sei *„echt weiter als die Menge der gültigen"*. Beides ist an der
  negierten Zeichenklasse des Musters ablesbar, die genau diese drei Zeichen ausschließt, und
  an C/D/G gemessen: jede der drei Formen erreicht die Dispatch-Schleife statt vorher
  abgeschnitten zu werden. Kein Befund.
- **Die Formen-Zählung in `main.go` trifft den Bestand.** `cmd/ai-harness-init/main.go:522-526`
  nennt drei Formen für den Hook-Kanal (`257`, `258`, `260`); gemessen führen genau drei
  Fall-Dateien `.claude/settings.json` in ihrem `# files:`-Kopf
  (`grep -l '^# files:.*\.claude/settings\.json' test/mutations/*.sh`). Kein Befund.
- **Der Bestand hat seine Zähne behalten.** Selbst gefahrener `make mutate` über dem echten Baum:
  **246 ok, 0 Befund(e)**, EXIT 0, jede Fall-ID genau einmal gezogen. Die zwei neuen Fälle melden
  `ok`, und der Treiber prüft dabei auch, dass der erwartete Wächter in der Fehlschlag-Ausgabe
  steht (Bedingung 4 seines Kopfes). Kein Befund — die Grenze dieser Aussage steht in MEDIUM-1.
- **Kein Artefakt einer fremden Rolle angefasst** ([`AGENTS.md`](../../AGENTS.md) §3.8,
  [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)).
  `git show --name-only --pretty=format: e1faab5` nennt fünf Dateien und trifft weder `AGENTS.md`
  noch `harness/conventions*`, weder `docs/plan/adr/` noch `docs/plan/planning/` noch
  `.claude/commands/`. Kein Befund.
- **Lint-Suppression-Verbot** ([`AGENTS.md`](../../AGENTS.md) §3.2).
  `git diff 8343911..HEAD | grep -nE '^\+.*(nolint|shellcheck disable|d-check:ignore)'` leer, und
  `make shell-lint` — das `test/mutations/*.sh` einschließt — läuft mit Exit 0, obwohl Fall `259`
  ein Dollar in einer Klammer-Klasse führt. Kein Befund.
- **Die neuen Kommentare tragen ihre Klasse und keine Chronik**
  ([`AGENTS.md`](../../AGENTS.md) §3.7). Die Blöcke in `test/unterkommando-kopplung.bats:45-64`
  und `cmd/ai-harness-init/main.go:522-526` stehen im Indikativ und nennen Zusage, Kopplung und
  Grenze;
  `git diff 8343911..HEAD -- '*.go' '*.sh' '*.bats' 'Makefile' | grep -nE '^\+[[:space:]]*(#|//).*(Review-Befund|Runde [0-9]|MEDIUM-|HIGH-|frueher stand|bis slice)'`
  ist leer. Kein Befund — die inhaltliche Ausnahme steht in MEDIUM-1 und betrifft eine Datei, die
  dieser Commit **nicht** anfasst.
- **Der Kopplungs-Fall liegt wirklich im Gate.** `record-gates` führt `test` als Voraussetzung,
  `test` führt `test-bats` (`Makefile:36-54`), und im Ausgangs-Lauf stehen `ok 211` und `ok 212`.
  Kein halluziniertes Gate ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
  Kein Befund.
- **Der Arbeitsbaum ist übergabefähig.** `git status --porcelain` leer, `make comment-claims`
  meldet **55 Datei(en) geprueft, 0 Befund(e)**, `make shell-lint` Exit 0, `make docs-check`
  **590 Datei(en) geprüft, 0 Befund(e)**. Kein Befund.

**Nicht geprüft, weil nicht Reviewer-Rolle:** die DoD-Abhakung, `make gates` als Ganzes,
`make full-smoke`, `make lint`, und ob
[ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) ihren Acceptance-Trigger
erreicht hat.

**Nicht neu geprüft, unverändert delegiert:** MEDIUM-5 aus Runde 1
(`.claude/commands/close-welle.md` nennt Schritt 4 als Handarbeit und das Ziel gar nicht —
`grep -c 'archive-welle' .claude/commands/close-welle.md` → **0**, **Planner**), MEDIUM-3 und
MEDIUM-4 aus Runde 2, LOW-1 aus Runde 4 (Deckungs-Grenze des Feldes `schreibend`; unverändert
ohne kuratierten Fall, im Kopf von `echterEingang()` als Grenze benannt), LOW-1 und INFO-1 aus
Runde 5 sowie LOW-1 und INFO-1 aus Runde 6.

---

## Die Kette, Stufe für Stufe — Stand nach `e1faab5`

| # | Stufe | Stelle | Wächter | diese Sitzung |
|---|---|---|---|---|
| **−1** | Anweisungssatz für Schritt 4 | `.claude/commands/close-welle.md` | **keiner**, die Datei nennt das Ziel nicht | gemessen (`grep -c` → 0) — Runde-1-MEDIUM-5, **Planner** |
| **0** | Bedien-Einstieg `make archive-welle` | `Makefile:322` | `254`, `256`, `259` **+** die Sperre in `run()` (`253`) | **gefahren → rot** (A, C, G, H) |
| **0b** | das Argument `"$(WELLE)"` | `Makefile:322` | `255` | mittelbar gefahren (`make mutate`) |
| **0c** | Hook-Kanal, dasselbe Literal aus zweiter Quelle | `.claude/settings.json` | `257`, `258`, `260` | **gefahren → rot** (B, D) |
| 1–2 | Dispatch-Zweig und `os.Args[2:]` | `cmd/ai-harness-init/main.go:552-553` | `237` | mittelbar gefahren; die Grenze steht in LOW-1 |
| 3 | Wrapper `archiveWelle` → `archiveWelleMit` | `cmd/ai-harness-init/archive_welle.go` | die drei Echt-Fälle | **gefahren → rot** (F′) |
| 4 | Verdrahtung `echterEingang()`, vier Felder | `cmd/ai-harness-init/archive_welle.go` | `249`, `250`, `251` — **drei** der vier | mittelbar gefahren; `schreibend` weiter ohne Fall, im Kopf benannt |
| 5–6 | Parser gewinnt `--vorschau`, Weitergabe an den Zweig | `cmd/ai-harness-init/archive_welle.go` | `246`, `247` | mittelbar gefahren |
| 7 | Guard `if vorschau` | `cmd/ai-harness-init/archive_welle.go` | `242` | mittelbar gefahren |
| 8 | Sperren-Logik | `internal/archive/clean.go`, `internal/archive/scan.go` | `232`, `233` | mittelbar gefahren |
| 9 | Schreibvorgang | `internal/archive/anwenden.go` | `243`, `245`, `252` | mittelbar gefahren |

**„Mittelbar gefahren" heißt hier:** der Fall meldet im selbst gefahrenen `make mutate` `ok`,
nicht dass er in dieser Sitzung einzeln nachgestellt wurde. Alle genannten Fall-Dateien
existieren (`ls test/mutations/<N>-*.sh` für jede der zwanzig Kennungen).

**Eine elfte Stufe gibt es nicht, und diesmal auch keine neue am Rand.** Die Kette vom
Anweisungssatz bis zum Schreibvorgang trägt an jeder Stelle einen benannten Wächter; die zwei
Ausnahmen — Stufe −1 und das vierte Feld auf Stufe 4 — stehen seit Runde 1 bzw. Runde 4 auf dem
Protokoll und sind im Code und in `harness/README.md` als Grenze benannt, nicht verschwiegen.
Was diese Runde findet, liegt wie in den zwei Vorrunden **nicht** in der Kette, sondern in ihrem
Sensor — und zwar eine Ebene tiefer als zuvor: nicht mehr in dem, was er misst, sondern in der
**Haltbarkeit** seines eigenen Gegenbeispiels.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| **HIGH** | 0 | — |
| **MEDIUM** | 1 | Ein Fix macht die Zusage seines eigenen Gegenbeispiels falsch und nimmt ihm den Zahn |
| **LOW** | 1 | Entscheidung und Diagnose derselben Prüfung tragen verschiedene Strenge |
| **INFO** | 0 | — |

**Geschlossen aus Runde 6:** MEDIUM-1 (Namens-Muster), mit vier eigenen Sonden nachgeprüft und
mit reproduziertem Defekt davor.

**Warum MEDIUM-1 nicht HIGH ist.** Der HIGH-Anker der Skill-Datei nennt den *Stillen-Grün-Pfad in
einem Gate oder Gate-Skript*. Am **heutigen** Baum ist `make gates` ehrlich: die
Vorkommen-Zählung hält, und die Form, die sie schließt, färbt rot (Sonde L2). Verloren ist die
**Haltbarkeits**-Zusage — der Fall, der eine Rückkehr zur Zeilen-Zählung sichtbar machen soll,
tut es gemessen nicht mehr, und `make mutate` (kein Gate,
[`AGENTS.md`](../../AGENTS.md) §4) meldet dafür `ok`. Das ist ein Defekt am Feedback für §3.6,
nicht am Produkt. Wer diese Einschätzung nicht teilt, geht den Konflikt-Pfad aus Modul 8, nicht
den Weg über die Kategorie.

**Vierte Runde, dieselbe Familie, jedes Mal eine Ebene tiefer.** Runde 4 fand den `Makefile`
ungekoppelt, Runde 5 die Kalibrierung über der falschen Zählgröße, Runde 6 das Namens-Muster über
der falschen Zeichenklasse, Runde 7 das Gegenbeispiel, das durch die Reparatur der Runde 6 seinen
Zweig gewechselt hat. Die Klasse dieser Runde ist gegenüber den drei Vorrunden **verschoben** —
dort deckte der Sensor die Menge nicht, hier deckt der Sensor, aber sein Gegenbeispiel misst ihn
nicht mehr; sie fällt darum auf `BEO-009` und nicht auf
`BEO-025`. **Ob** ein Zähler-Schritt fällt und was er auslöst, entscheidet die Closure und nicht
dieser Report.

---

## Verdikt

**Nicht freigegeben für die Verifikation** — knapp, aus einem MEDIUM. Das Gesamt-Verdikt über
sieben Runden fällt in drei Teilen:

- **Die Kette ist vollständig.** Vom Anweisungssatz über Bedien-Einstieg, Argument, Dispatch,
  Wrapper, Verdrahtung, Parser, Weitergabe, Guard und Sperren-Logik bis zum Schreibvorgang trägt
  jede Stufe einen benannten Wächter; zwanzig Fall-Dateien decken sie, alle existieren, und
  `make mutate` fährt sie in dieser Sitzung mit **246 ok, 0 Befund(e)** über 246 Fälle. Die zwei
  unbewachten Stellen — der Anweisungssatz `close-welle.md` (Planner) und das vierte Feld von
  `echterEingang()` — sind seit den Runden 1 und 4 protokolliert und im Code als Grenze benannt.
  Eine elfte Stufe habe ich gesucht und nicht gefunden.
- **Die zwei Kopplungen halten.** `Makefile:322` und die drei Hook-Kommandos in
  `.claude/settings.json` fallen unter jeder Form, die ich ihnen selbst gebaut habe — Vertipper,
  Punkt, Großbuchstabe, Ziffer, Satzzeichen, fehlender Name, zweite Nennung in derselben Zeile —
  und die Reparatur aus `e1faab5` ist notwendig: mit der Weißlisten-Fassung bleiben beide
  Ziffer-Mutationen grün (Sonde E). Beide Fälle laufen in `make gates`.
- **Was blockiert, ist kein Loch in der Kette, sondern ein stumpf gewordener Zahn.**
  `test/mutations/256` wurde geschrieben, um die Vorkommen-Zählung zu messen; seit `e1faab5`
  fällt es über die Dispatch-Schleife, ist mit Zeilen-Zählung ebenfalls rot, und sein Kopf sagt
  in drei Sätzen das Gegenteil. Kein anderer der sechs Kopplungs-Fälle unterscheidet die zwei
  Zählweisen (gemessen), während der stille Grün-Pfad offen bleibt (L1 grün / L2 rot). Nach
  [`AGENTS.md`](../../AGENTS.md) §3.6 schließt den Befund, was das Gegenbeispiel wieder rot
  färbt — ein Fall, der die Eigenschaft trifft, **oder** ein Kopf, der nur noch sagt, was der
  Fall hält. Welcher der beiden Wege gegangen wird, entscheidet nicht dieser Report.

**Was trägt.** Kein neuer Kommentar trägt Chronik, kein fremdes Rollen-Artefakt ist berührt
(fünf Dateien, alle in der Implementer-Hoheit), keine Lint-Suppression ist dazugekommen,
`comment-claims` meldet 55/0, `shell-lint` Exit 0, `docs-check` 590/0, der Arbeitsbaum ist
sauber, und `make mutate` ist über 246 Fälle grün.

**Kein Rollen-Konflikt erkennbar.** Sollte die Implementation MEDIUM-1 mit dem Argument
bestreiten, `make mutate` melde den Fall doch als `ok`, greift der Konflikt-Pfad aus Modul 8
§Konflikt-Pfad als Rollen-Sequenz (Reviewer → Architect → Verdikt als Artefakt); das `ok` ist
genau der Beleg, um den es geht — der Treiber prüft, *dass* der genannte Wächter rot wird, nicht
*woran* er fällt.
