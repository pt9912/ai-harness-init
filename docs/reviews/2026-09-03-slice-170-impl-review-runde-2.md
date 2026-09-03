# Review — slice-170, Runde 2 (Nachprüfung der Behebungen)

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 8/10) — frischer Kontext, getrennt von Implementation, Architektur und Planung |
| **Review-Art** | Nachprüfung: halten die Behebungen der Runde-1-Findings? **Nicht** DoD-Abhakung (Verifier, Modul 11) |
| **Gegenstand** | `git diff 0d4029e..HEAD` — die zwei Behebungs-Commits `80426ab` (Skript, bats, drei neue Mutations-Fälle) und `669eb4c` (`harness/README.md`) |
| **Plan** | [`docs/plan/planning/in-progress/slice-170-archivierungs-werkzeug.md`](../plan/planning/in-progress/slice-170-archivierungs-werkzeug.md) |
| **Vorherige Findings am gleichen Modul** | [`2026-09-03-slice-170-impl-review.md`](2026-09-03-slice-170-impl-review.md) (3 HIGH, 3 MEDIUM, 3 LOW, 2 INFO); davor [`2026-08-31-slice-144-review.md`](2026-08-31-slice-144-review.md) zum Präzedenz-Werkzeug `harness/tools/slice-mv.sh` |
| **Bindende ADRs** | keine — auch die zwei Behebungs-Commits nennen keine ADR-ID und berühren `docs/plan/adr/` nicht |
| **Anforderungen** | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`AGENTS.md`](../../AGENTS.md) §3.2, §3.3, §3.6, §3.7, §3.9 |
| **Skill-Version** | `.harness/skills/reviewer.md` 1.6.0 |
| **Modell** | Claude Opus 5 (1M context) |
| **Kontext frisch** | ja — **kein Beleg aus dem Implementer-Bericht übernommen.** Jede Aussage unten ist in dieser Sitzung selbst gemessen; das Kommando steht beim Befund |

**Was in diesem Lauf gefahren wurde.** **Vier eigene Scratch-Repos** mit echten `git`- und
`docker`-Läufen von `main()`: (1) zwei Wellen in Folge für die aufsteigende Verweis-Form und die
Hänger-Vorprüfung, (2) ein `NNNa`/`NNNb`-Paar mit einer Spionage-Kopie des Skripts, die kurz vor dem
Stagen eine untrackte Datei anlegt, (3) ein Lauf ohne jeden Verweis-Nachzug (leere
Berührt-Liste), (4) eine gebrochene Vorlage für den Ausgang 4. Dazu ein **Gegenprobe-Lauf des alten
Skripts** (`git show 0d4029e:harness/tools/archive-welle.sh`) über demselben Repo, die **neue
bats-Datei gegen den alten Stand**, die **drei neuen Mutations-Fälle einzeln** auf Kopien, ein
**Klon** des Hauptzweigs für die Anwendbarkeits-Aussage, und die Sensoren `make docs-check`
(570/0), `make shell-lint` (EXIT 0), `make comment-claims` (48/0), `bats test/archive-welle.bats`
im gepinnten Bild (32/32 `ok`). Alle Arbeitskopien liegen außerhalb des Repos; der Arbeitsbaum
dieses Repos ist unverändert.

---

## Nachprüfung der drei HIGH

### HIGH-1 — Hänger-Wächter sieht `docs/reviews`-Verweise — **behoben, gemessen**

`grep_suchraum()` liefert genau einen Pathspec, `:!.harness/baseline`; beide `git grep`-Läufe des
Skripts nehmen ihn. `haenger_filtern()` streicht aus der Trefferliste, was den Lauf selbst nicht
überlebt (`verschwindend` = Slices + Welle-Plan + alle einzusammelnden Reports).

Scratch-Repo mit zwei Wellen: `2026-02-06-slice-502-review.md` (bleibt, gehört zu `welle-12`)
verlinkt `2026-01-06-slice-501-review.md` (verschwindet mit `welle-11`). Der Lauf
`archive-welle.sh welle-11` meldet

```
archive-welle: ein Review-Report soll verschwinden, auf den noch verwiesen wird:
  docs/reviews/2026-02-06-slice-502-review.md -> 2026-01-06-slice-501-review.md
```

und endet mit `EXIT=3`, **vor** jeder Mutation — `git log` und `git status --porcelain` danach
unverändert. **Gegenprobe am alten Stand:** dasselbe Repo, `harness/tools/archive-welle.ALT.sh`
aus `0d4029e`, derselbe Fall — die Vorprüfung läuft durch, das Skript druckt seinen Kopf und geht
bis zum `git mv`. Der Wechsel ist damit rot gesehen, nicht abgeleitet.

Die Kopplungs-Behauptung des neuen Funktionskommentars ist **unabhängig gegen die Config
gehalten**, nicht übernommen: `.d-check.yml` nimmt `docs/reviews/**` in drei `ids`-Regeln
(`:96`, `:100`, `:112`) und in `codepaths.exempt-paths` (`:137`) aus — unter `links` oder
`anchors` steht keine Ausnahme.

### HIGH-2 — Untrackte Dateien im Closure-Commit — **behoben, beide Hälften gemessen**

*Vorbedingung:* `unsauber_grund()` liest `git status --porcelain` und zählt `?? `-Zeilen getrennt.
Scratch-Repo mit `FREMDE-UNTRACKED-DATEI.txt` und `scratch/notiz.md`:

```
archive-welle: Arbeitsbaum nicht sauber (2 untrackte Datei(en)) — erst committen, stashen oder aufraeumen …
EXIT=2
```

`git log` danach unverändert — der Abbruch liegt vor dem ersten `git mv`.

*Stagen:* `git add -A` ist verschwunden; Commit 2 stagt `zu_stagen` (Archiv, Stubs, berührte
Dateien). Gemessen mit einer **Spionage-Kopie**, die unmittelbar vor `git add` eine untrackte Datei
anlegt — also genau den Fall, den die Vorprüfung nicht mehr sehen kann:

```
git show --stat HEAD   → archiv.zip, 3 Stubs, welle-20-results.md, 2 geloeschte Reports
git status --porcelain → ?? SPION-UNTRACKT.txt
```

Die Datei bleibt draußen. Die Zusage hält auch dort, wo die Vorprüfung nicht mehr greift.

### HIGH-3 — Aufsteigende `](../<datei>)`-Form beim Folgelauf — **behoben, gemessen**

`rewrite_parent_relative_in_file()` läuft über `"$DONE"/*/*.md`. Zwei Läufe in Folge im
Scratch-Repo:

| Zeitpunkt | `done/welle-11/slice-501-a.md`, Feld `Hervorgegangen` |
|---|---|
| nach Lauf 1 (`welle-11`) | `[slice-502](../slice-502-b.md)` |
| nach Lauf 2 (`welle-12`) | `[slice-502](../welle-12/slice-502-b.md)` |

Ziel `docs/plan/planning/done/welle-12/slice-502-b.md` existiert; der Lauf meldet
`1 aufsteigende Ziel(e)` und stagt die Stub-Datei der **fremden** Welle mit. Damit ist die
Grenzen-Liste wieder deckungsgleich mit dem, was das Werkzeug selbst schreibt.

Über den einen gemeldeten Fall hinaus geprüft: `slice_pfad_relativ()` liefert vier Formen. Die
Geschwister-Form (`<basename>`, Folge-Slice in derselben Welle) bleibt korrekt, weil die Datei mit
umzieht; `../<dir>/<basename>` zeigt auf ein bereits archiviertes Verzeichnis und wandert nicht;
`../../<open|next|in-progress>/<basename>` trägt ein Verzeichnis-Literal und fällt damit unter die
Präfix-Regel von `make slice-mv` und danach unter die des Werkzeugs. Alle vier laufen auf einen
auflösbaren Pfad hinaus.

---

## Findings

### LOW-1 — `titel_von` lässt eine fünfte H1-Form halb stehen, und der Bestand führt sie einmal

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (die Zusage auf das einschränken, was der Code
  hält)
- **pfad:** `harness/tools/archive-welle.sh:367-380`
- **befund:** Der Funktionskommentar sagt zu: *„… traegt die Zeile keine Kennung, bleibt sie ganz
  stehen."* Für die Form `# Slice <NNN>: T` trifft weder das eine noch das andere zu: Der zweite
  `sed`-Ausdruck streicht das Wort `Slice`, der dritte greift nicht (die Zeile führt keine
  `slice-NNN`-Kennung), und die Nummer bleibt im Titel stehen. Gemessen über den echten Bestand —
  genau **eine** von **119** `done/`-Slice-Dateien trägt diese Form
  (`for f in docs/plan/planning/done/slice-*.md; do head -n1 "$f" | grep -qE '^# (Slice )?slice-[0-9]' || echo "$f"; done`),
  und sie ist Mitglied von `welle-10`:
  `titel_von docs/plan/planning/done/slice-149-welle-10-traegt-ihre-drei-fehlenden-belege.md`
  → `149: Welle-10 trägt ihre drei fehlenden Belege`. Der Stub bekäme die H1
  `# slice-149 — 149: Welle-10 trägt ihre drei fehlenden Belege`. Failure-Szenario: der Stub ist
  nach der Archivierung die einzige lesbare Identität, und er trägt die Nummer doppelt — beim
  Abzählen des Archivs liest sie sich wie ein zweiter Vorgang.
- **verifizierbar:** ja — `bash -c 'source harness/tools/archive-welle.sh; titel_von docs/plan/planning/done/slice-149-*.md'`
- **klasse:** Kommentar-Zusage nennt mehr Fälle, als der Code trägt

### LOW-2 — Der neue Untrackt-Zähler zählt Porcelain-Einträge und nennt sie „Datei(en)"

- **kategorie:** LOW
- **quelle:** Maintainability
- **pfad:** `harness/tools/archive-welle.sh:208-224` (`unsauber_grund`), Meldung `:532`
- **befund:** `git status --porcelain` bündelt untrackte **Verzeichnisse** zu einer Zeile;
  `unsauber_grund` zählt Zeilen und beschriftet sie mit `untrackte Datei(en)`. Gemessen an einem
  Scratch-Repo mit fünf untrackten Dateien in einem Verzeichnis: `git status --porcelain` gibt
  `?? fremd/`, `unsauber_grund` meldet `1 untrackte Datei(en)`, während
  `git status --porcelain -uall | grep -c '^?? '` **5** liefert. Failure-Szenario: die Meldung
  nennt eine Zahl, gegen die der Aufrufer sein Aufräumen abzählt; er räumt eine Datei weg und
  wundert sich, dass der nächste Lauf wieder abbricht. Der Abbruch selbst ist richtig — nur seine
  Zahl ist es nicht. Dieselbe Klasse trug LOW-1 der Runde 1 (`praefix_treffer` als „Datei(en)"),
  die dort behoben wurde; sie ist mit derselben Behebung an neuer Stelle wieder entstanden.
- **verifizierbar:** ja — untracktes Verzeichnis mit mehreren Dateien anlegen, Lauf starten, die
  Zahl gegen `git status --porcelain -uall | grep -c '^?? '` halten
- **klasse:** Zähler-Label nennt eine andere Einheit als der Zähler zählt

### INFO-1 — Die Rot-Zahl in der Commit-Message von `80426ab` ist um eins zu klein

- **kategorie:** INFO
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (eine Commit-Message ist eine Zusage);
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
- **pfad:** `git log 80426ab` — *„elf neue bats-Faelle (32 gruen, 10 davon rot gegen den alten
  Stand)"*
- **befund:** Nachgemessen: die neue `test/archive-welle.bats` gegen
  `git show 0d4029e:harness/tools/archive-welle.sh` gefahren, im gepinnten `BATS_IMAGE` — **11**
  von 32 Fällen werden rot, und es sind genau die elf neuen (7, 8, 9, 10, 11, 12, 13, 14, 22, 23,
  26). Die Aussage ist damit konservativ falsch, nicht optimistisch: es sind mehr Zähne als
  behauptet. Die Message liegt in `git` und ist nicht mehr korrigierbar; der Befund steht hier,
  damit ein Nachrechnen die Differenz nicht für einen Zahn ohne Biss hält.
- **verifizierbar:** ja — altes Skript in eine Kopie legen, `bats test/archive-welle.bats` im
  gepinnten Bild fahren, `grep -c '^not ok'`
- **klasse:** Zahl in einer Zusage weicht von der Messung ab

---

## Negativbefunde

- **MEDIUM-1 der Runde 1 (Nummern-Substring beim Einsammeln):** geprüft, kein Befund.
  `slice_nummer` trägt den Buchstaben-Suffix, `reviews_zu_nummer` prüft die Grenze
  `slice-$nr([^0-9A-Za-z]|$)`, und `LC_ALL=C sort -u` entdoppelt. Scratch-Lauf mit `slice-001a`,
  `slice-001b` und einem Fremd-Report `…-slice-001-review.md`: beide suffixierten Reports gelöscht,
  der unsuffixierte bleibt liegen; der Welle-Stub sagt `2 Slices, 2 Reviews`, und `unzip -l` im
  gepinnten Bild führt genau zwei Slice- und zwei Report-Einträge. Zahl und Archiv decken sich.
- **MEDIUM-2 (H1-Identität bei `NNNa`/`NNNb`):** geprüft, kein Befund. Derselbe Lauf schreibt
  `# slice-001a — Erster Teil` und `# slice-001b — Zweiter Teil` — zwei Dateien, zwei Identitäten.
- **MEDIUM-3 (`titel_von` unter `LC_ALL=C`):** geprüft, kein Befund über LOW-1 hinaus. Der Trenner
  steht als Alternative `(:|—|-)` statt im Klammerausdruck; bats-Fall 26 fährt beide
  Gedankenstrich-Formen unter `LC_ALL=C` und ist gegen den alten Stand rot. Als Regressions-Sonde
  zusätzlich über **alle** realen H1 des Lifecycle gefahren — kein Titel wird von der Alternative
  angeschnitten; die Kennung-ohne-Trenner-Form (`# slice-901-titel-ohne-trenner`) verhält sich
  unter alter und neuer Fassung identisch und ist damit keine Regression.
- **LOW-1 der Runde 1 (Verweis-Zahl):** geprüft, kein Befund. `beruehrt_uniq` sammelt Dateien und
  entdoppelt; die Ausgabe trennt jetzt „N Datei(en) nachgezogen" von „(M geschwister-relative, K
  aufsteigende Ziel(e))". Im Zwei-Wellen-Lauf: gemeldet `2 Datei(en)`, `git show --stat` weist
  genau zwei berührte Fremd-Dateien aus.
- **LOW-2 der Runde 1 (doppelte Zustandsaussage):** geprüft, kein Befund. Der Skriptkopf zeigt auf
  `harness/README.md`, statt die Anwendbarkeit ein zweites Mal zu behaupten; die Aussage steht nur
  noch dort. Sie ist heute richtig — über einem frischen Klon meldet
  `archive-welle.sh welle-10` `42 wellenlose Slice(s) … kein …/*/archiv.zip` und endet mit
  `EXIT=3`, der Klon bleibt sauber.
- **LOW-3 der Runde 1 (zwei Auszählungen derselben Menge):** geprüft, kein Befund. Das Dateiende
  von `test/archive-welle.bats` zählt nicht mehr selbst, sondern zeigt auf den Skriptkopf.
- **INFO-1 der Runde 1 (Abbruch ohne Wiederanlauf):** geprüft, kein Befund. `abbruch_nach_commit1`
  ist ein echter `exit 4`. An einer gebrochenen Vorlage gefahren: die Meldung nennt
  `git reset --hard HEAD~1 && git clean -fd -- docs/plan/planning/done/welle-30`; **wortwörtlich
  gefahren** stellt sie den Stand vor dem Lauf her — `HEAD` identisch mit dem Commit davor,
  `git status --porcelain` leer.
- **INFO-2 der Runde 1 (Sammel-Report über mehrere Slices):** geprüft, kein Befund. Grenze 6 im
  Skriptkopf benennt die Klasse.
- **Die drei Zahlen der neuen `harness/README.md`-Fassung:** geprüft, kein Befund — **selbst
  nachgerechnet**, nicht übernommen. `zehn` Ausgänge
  (`grep -vE '^[[:space:]]*#' … | grep -cE '\bexit [0-9]'` → `10`), `83` Report-Dateien als
  Link-Ziel (das im README abgedruckte Kommando wortwörtlich gefahren → `83`), `sechs` Grenzen
  (`grep -cE '^# \([1-9]\) ' harness/tools/archive-welle.sh` → `6`).
- **Die drei neuen Mutations-Fälle (`229`–`231`):** geprüft, kein Befund. Jeder einzeln auf eine
  Kopie angewendet und die bats-Datei im gepinnten Bild darüber gefahren: `229` färbt Fall 12,
  `230` die Fälle 10 und 11, `231` Fall 22 — jeder trifft den in seiner `# expect:`-Zeile
  genannten. `230` färbt einen zweiten Fall mit; der `mutate`-Treiber verlangt nur, dass der
  genannte unter den roten ist.
- **[`AGENTS.md`](../../AGENTS.md) §3.3 (Move und Inhalt = zwei Commits):** geprüft, kein Befund.
  In allen vier Scratch-Läufen zeigt `git show --stat` auf Commit 1 ausschließlich Renames mit
  `0 insertions(+), 0 deletions(-)`; Commit 2 trägt Archiv, Stubs, Löschungen und Nachzug.
- **[`AGENTS.md`](../../AGENTS.md) §3.2 (Lint-Suppression):** geprüft, kein Befund. Kein
  `# shellcheck disable` in den geänderten Dateien; `make shell-lint` in dieser Sitzung gefahren,
  EXIT 0.
- **[`AGENTS.md`](../../AGENTS.md) §3.7 (Kommentar-Klassen) im neuen Code:** geprüft, kein Befund.
  Die vier neuen Funktionskommentare (`unsauber_grund`, `grep_suchraum`, `haenger_filtern`,
  `rewrite_parent_relative_in_file`) und der Stagen-Kommentar stehen im Indikativ über den
  Zustand, tragen Zusage, Kopplung, Abgrenzung oder Grenze und nennen keine Befund-Kennung und kein
  Lauf-Protokoll. Die Wendung *„Explizite Pfade statt `git add -A`"* ist Abgrenzung, kein Konjunktiv
  über eine verworfene Alternative, und folgt der in `harness/tools/slice-mv.sh:222` etablierten
  Form. `make comment-claims` gefahren: `48 Datei(en) geprueft, 0 Befund(e)`.
- **[`AGENTS.md`](../../AGENTS.md) §3.9 / [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten):**
  geprüft, kein Befund. Der neue Code führt kein neues Host-Werkzeug ein — `git`, `bash`, `sed`,
  `grep`, `wc`, `sort`; gepackt wird unverändert im digest-gepinnten `ARCHIVE_IMAGE` mit
  `--network none` über einen `:ro`-Mount.
- **[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6):**
  geprüft, kein Befund. `archive-welle` steht weiterhin in keiner Voraussetzungsliste von
  `record-gates`/`gates`; die Behebungs-Commits ändern am `Makefile` nichts.
- **`make docs-check` über dem Arbeitsbaum:** geprüft, kein Befund — `570 Datei(en) geprüft,
  0 Befund(e)`. Die neue `harness/README.md`-Fassung löst auf.
- **`test/archive-welle.bats` (32 Fälle):** geprüft, kein Befund. Im gepinnten `BATS_IMAGE`
  gefahren, `32/32 ok`. Gegen den alten Stand sind alle elf neuen Fälle rot (siehe INFO-1) — die
  Zähne beißen, sie behaupten nicht nur.
- **Der `errexit`-Pfad bei leerer Berührt-Liste:** geprüft, kein Befund. Das neue
  `[ "${#beruehrt_uniq[@]}" -gt 0 ] && zu_stagen+=(…)` steht unter `set -e`; ein Scratch-Lauf ohne
  jeden eingehenden Verweis läuft durch (`0 Datei(en) nachgezogen`, EXIT 0), und
  `bash -c 'set -euo pipefail; a=(); [ "${#a[@]}" -gt 0 ] && b=(x); echo ERREICHT'` bestätigt die
  Ausnahme der `&&`-Liste von `errexit`.
- **Falsch-positive Präfix-Treffer durch die Wortgrenzen-Regel:** geprüft, kein Befund. Eine Datei,
  die `git grep -F "done/$base"` trifft, ohne dass die Wortgrenze der Ersetzung greift, würde
  gezählt und gestagt, ohne sich zu ändern. Über den echten Bestand gemessen:
  `git grep -cE '[A-Za-z0-9_-]done/slice-' -- ':!.harness/baseline'` → **0**.
- **Aktive ADRs:** geprüft, kein Befund. Auch die zwei Behebungs-Commits nennen keine ADR-ID und
  berühren `docs/plan/adr/` nicht; damit weder Verstoß gegen eine aktive noch Bezug auf eine
  superseded ADR.
- **Anwendbarkeit nach der Verschärfung:** geprüft, kein Befund. Der erweiterte Suchraum macht das
  Werkzeug nicht unbrauchbar, sondern lauter: über einem Klon des Hauptzweigs greift ohnehin schon
  Grenze 1 (kein `done/*/archiv.zip`), und der Klon bleibt nach dem Versuch sauber. Dass 83 Reports
  Ziel eines Report-Links sind, ist die Arbeit vor der ersten Archivierung — sie steht als eigener
  Vorgang im README.
- **DoD-Abhakung, `make gates`, Closure-Notiz, Register-Fortschreibung:** **nicht** geprüft — nicht
  Reviewer-Rolle (Verifier bzw. Planner, Modul 8). Als beobachtbare Handreichung ohne Bewertung:
  der Haken *„`make gates` grün"* wurde in `0d4029e` gesetzt, und `80426ab` hat danach
  `harness/tools/archive-welle.sh` um 295 Zeilen geändert.

---

## Kategorie-Summary

- HIGH: 0
- MEDIUM: 0
- LOW: 2
- INFO: 1

**Behoben und einzeln nachgemessen:** alle drei HIGH, alle drei MEDIUM, alle drei LOW und beide
INFO der Runde 1 — elf von elf.

**Wiederkehrende Finding-Klasse (für Closure/Beobachtungs-Register,
[`observations.md`](../plan/planning/observations.md)):** Die Klasse *„Zähler-Label nennt eine
andere Einheit als der Zähler zählt"* trat in Runde 1 als LOW-1 auf und ist mit der Behebung an
neuer Stelle wieder entstanden (LOW-2 dieser Runde, `unsauber_grund`) — **zweites Auftreten
derselben Klasse innerhalb desselben Slice**. Die Klasse *„Kommentar-Zusage nennt mehr Fälle, als
der Code trägt"* trat in Runde 1 dreimal auf (HIGH-2, HIGH-3, MEDIUM-3) und einmal in dieser Runde
(LOW-1) — die dritte Wiederholung ist damit überschritten, und nach
[`AGENTS.md`](../../AGENTS.md) §3.6 ist das ein Steering-Loop-Signal, kein bloßer Befund. Beide
gehören in die Closure-Sichtung des Planners.

---

## Verdikt

**Freigegeben für die Verifikation.** Kein HIGH, kein MEDIUM. Die drei blockierenden Befunde der
Runde 1 sind nicht nur benannt, sondern in dieser Sitzung an echten Läufen nachgemessen — die
Hänger-Vorprüfung bricht dort ab, wo der alte Stand durchlief; die Vorbedingung sieht untrackten
Bestand, und der Inhalts-Commit bleibt auch dann sauber, wenn eine untrackte Datei nach der
Vorprüfung entsteht; die aufsteigende Verweis-Form, die das Werkzeug selbst schreibt, wird beim
Folgelauf auf ein existierendes Ziel gezogen. Jede der drei Behebungen trägt einen bats-Fall, der
gegen den alten Stand rot ist, und einen Mutations-Zahn, der sie einzeln nachweisbar entwertet.

**LOW-1, LOW-2 und INFO-1 sind kein Merge- und kein Closure-Hindernis.** LOW-1 materialisiert sich
erst bei der Archivierung von `welle-10` und dort an genau einer Datei; LOW-2 verfälscht eine Zahl
in einer Abbruch-Meldung, nicht den Abbruch; INFO-1 liegt in einer Commit-Message und ist
konservativ falsch.

Unberührt bleibt: die Zwei-Commit-Disziplin, die Docker-only-Linie, die Einsammel-Regel über die
drei Klassen samt Suffix-Grenze, die Stub-Erzeugung aus den vendored Vorlagen, der
Wiederanlauf-Weg nach Ausgang 4 und die drei nachgerechneten Zahlen der README-Fassung — sie sind
in diesem Lauf einzeln gefahren und halten.
