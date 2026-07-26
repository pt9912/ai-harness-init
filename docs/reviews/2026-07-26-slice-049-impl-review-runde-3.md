# Review-Report: slice-049 — Runde 3 — 2026-07-26

**Review-Art:** Code — geprüft wird der Diff gegen **Plan + aktive ADRs + Hard Rules +
Konventionen** (Modul 10 §Drei Review-Arten). **Nicht** geprüft: die DoD-Abhakung
(Modul 11, getrennter Kontext, anderes Prüf-Artefakt).

**Gegenstand:** slice-049, **dritte Runde**. Runde 1
([`2026-07-26-slice-049-impl-review.md`](2026-07-26-slice-049-impl-review.md)) endete NICHT KONFORM
(1 HIGH, 2 MEDIUM, 2 LOW, 1 INFO), Runde 2
([`2026-07-26-slice-049-impl-review-runde-2.md`](2026-07-26-slice-049-impl-review-runde-2.md)) ebenfalls
NICHT KONFORM (1 HIGH, 1 MEDIUM, 1 LOW, 1 INFO). Die Implementation hat mit `3a1e37a` reagiert.
Runde 3 prüft **zwei Fragen**: (a) sind die Runde-2-Findings real aufgelöst — am Diff von `3a1e37a`,
nicht an der Behauptung; (b) hat der Auflösungs-Commit **neue** Befunde eingeführt.
Gesamt-Range `80eec58..HEAD` (`9cfa1f3` Move · `ce4b611` Impl · `d38db74` Fix-1 · `3a1e37a` Fix-2),
5 Dateien in `3a1e37a`.

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-26 · **Frischer Kontext**, getrennt von
Implementation und Verifikation; Runde 1 und Runde 2 nur als Prüfgegenstand gelesen, ihre Urteile
nicht übernommen.

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- Slice-Plan: `in-progress/slice-049-baseline-bump-v3.5.2.md` (§2 DoD, §3 Plan, §5 Closure-Trigger, §6 Risiken)
- **Vorherige Findings am gleichen Modul (Pflicht-Punkt 5):** Runde 1 F-1…F-6 **und** Runde 2
  N-1…N-4 im Wortlaut, samt beider Implementations-Nachträge
- **Verifier-Report** [`2026-07-26-slice-049-verification.md`](2026-07-26-slice-049-verification.md)
  (DoD BESTÄTIGT; A-1 Zählung 15/11/4, A-2 stehender Review-Verdikt, A-3 Closure-Reste, A-4 Provenienz-Reihenfolge)
- aktive ADRs: keine im Diff geändert; mittelbar berührt [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) (Docker-only)
- berührte `LH-*`-IDs: [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules 3.1–3.6) — **verbatim gelesen**, nicht aus den Vorrunden übernommen
- Konventionen: [`harness/conventions.md`](../../harness/conventions.md) — `MR-007`, `MR-013`, `MR-015`
- Rollen-Vertrag: `.harness/skills/reviewer.md`, <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad) -->
  `.harness/baseline/v3.5.2/regelwerk/modul-10-review-harness.md`

**Prüfumfang / Grenze:** jede Zahl und jeder Commit-Hash in `3a1e37a` ist **selbst nachgemessen**
(`git show <rev>:<datei> | grep -o … | wc -l`, `git show --stat`, `git ls-tree`, `git log --diff-filter=A`),
nicht aus Nachtrag oder Verifier-Report übernommen. Das Vendoring-Verfahren (`MR-007` Setzungen 1–4,
`MR-013`, Pin-Kette) ist in Runde 1 geprüft und vom Verifier bis zum Upstream-Asset durchgezogen
worden; `3a1e37a` fasst es nicht an — es wird als Negativbefund geführt, nicht erneut aufgerollt.
Eigene Sensor-Läufe: `make docs-check`, `make baseline-verify` (lesend). **Nicht** gefahren:
`make mutate`, `make gates`, `make test` (mutierend bzw. verifizierende Rolle, läuft getrennt) —
die Zusage „`make gates` Exit 0" aus der Commit-Message ist damit in dieser Runde **nicht**
nachgeprüft; sie liegt beim Verifier (DoD-Punkt 8, dort selbst gefahren).

---

## Status der Runde-2-Findings

Jede Zeile ist am Diff von `3a1e37a` bzw. an einer eigenen Messung geprüft, nicht am Nachtrag.

| # | Kat. R2 | Status Runde 3 | eigener Beleg |
|---|---|---|---|
| N-1 | HIGH | **aufgelöst** | s. u. „N-1 im Detail" |
| N-2 | MEDIUM | **Artefakt erbracht — die neue Aussage ist in einem Teil selbst falsch** | s. u. „N-2 im Detail" → R-1 |
| N-3 | LOW | **aufgelöst** | s. u. „N-3 im Detail" |
| N-4 | INFO | **angenommen, tragfähig** | s. u. „N-4 im Detail" |

### N-1 im Detail — Korrektur-Sektion trägt, falscher Satz steht, `08410bc` stimmt

Drei Prüfungen, alle drei bestanden:

1. **Trägt die Korrektur-Sektion?** Ja. `git show 3a1e37a --stat` weist für
   [`2026-07-26-slice-049-impl-review.md`](2026-07-26-slice-049-impl-review.md) **14 Insertions, 0 Deletions**
   aus — die Sektion „Korrektur zum Nachtrag (2026-07-26, nach Review-Runde 2)" ist rein additiv
   angehängt, mit eigener Überschrift, Datum, Rollen-Zuordnung und Vorwärts-Verweis auf den
   Runde-2-Report.
2. **Ist der falsche Satz stehen geblieben statt geglättet?** Ja — das war die Forderung, und sie ist
   erfüllt. Der Satz „die Praxis wurde nie ausgeübt, die Commit-Message überzeichnet" steht
   unverändert in der dritten Säule der F-3-Ablehnung (Zeilenumbruch zwischen „nie" und „ausgeübt",
   darum von einer naiven Ein-Zeilen-Suche nicht getroffen — hier über den Diff belegt: **0
   Deletions** in der Datei). Die Korrektur benennt ihn wörtlich, statt ihn zu ersetzen.
3. **Ist `08410bc` korrekt wiedergegeben?** Ja, selbst nachgemessen. `git show --stat 08410bc`:
   **6 Dateien, 7 Insertions / 7 Deletions**; `--name-status` zeigt `R100` für den Slice-Move plus
   **5 modifizierte** Dateien (`slice-045b-arch-cli.md`, `welle-07-results.md`, `roadmap.md`, zwei
   slice-047-Review-Reports), deren Diffs **ausschließlich** `../in-progress/…` → `../done/…`-Link-
   Reparaturen enthalten — genau **7 Links über 5 Dateien im selben Commit**. Die Angabe in der
   Korrektur-Sektion, im Roadmap-Eintrag und in der Commit-Message ist zeichengenau die gemessene.

### N-2 im Detail — die Verortung ist erbracht, ihre Aussage greift zu weit

**Erbracht:** `git diff 80eec58..HEAD -- docs/plan/planning/in-progress/roadmap.md` zeigt jetzt zwei
Commits (`ce4b611`, `3a1e37a`); der Kandidat *Doku- und Sensor-Wartung*,
[`roadmap.md`](../plan/planning/in-progress/roadmap.md):36, Achse (4) trägt die zweite gemessene
Instanz. Der Befund existiert damit nicht mehr nur in Report und Commit-Message — „kein Pfeil ohne
benennbares Artefakt" ist eingelöst.

**Korrekt ist:** beide Commit-Hashes und ihre Messgrößen (`08410bc`: 7 Links / 5 Dateien — s. o.;
`9cfa1f3`: reiner Rename, 0 Insertions, und auf diesem Checkout zeigen
`roadmap.md`:22 und :48 auf `../open/slice-049-…`, während `git ls-tree 9cfa1f3 docs/plan/planning/open/`
nur `.gitkeep` liefert). Korrekt ist auch „geübt, aber uneinheitlich" und „nicht bewacht":
`make docs-check` läuft ausweislich seines eigenen Aufrufs gegen den gemounteten **Arbeitsbaum**
(`-v "…:/repo:ro"`), nie gegen einen Zwischen-Commit.

**Nicht korrekt ist** die Hälfte „kein Dokument schreibt sie" — s. **R-1**.

### N-3 im Detail — 15 / 11 / 4 stimmt, §2 und §3 sind konsistent

Eigene Zählung, mit genau dem Verfahren, das der Nachtrag benennt
(`git show <rev>:<datei> | grep -o 'v3\.5\.1' | wc -l`):

| Datei | `80eec58` | `HEAD` | gezogen | behalten |
|---|---|---|---|---|
| [`harness/conventions.md`](../../harness/conventions.md) | 6 | 1 | 5 | 1 (Re-Baseline-Historie, Zeile 17) |
| [`docs/user/benutzerhandbuch.md`](../../docs/user/benutzerhandbuch.md) | 3 | 0 | 3 | 0 |
| `.harness/skills/reviewer.md` <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad) --> | 3 | 3 | 2 | 1 (1.3.0-Historie, Zeile 14) + 2 **neu** geschriebene (1.4.0-Eintrag) |
| [`roadmap.md`](../plan/planning/in-progress/roadmap.md) | 3 | 2 | 1 | 2 (Bump-Ziel in der slice-049-Zeile) |
| **Summe** | **15** | **6** | **11** | **4** |

Die Zahlen des Slice-Plans §2 sind damit **exakt** reproduziert: 15 Vorkommen, 11 gezogen, 4 bewusst
behalten — und die Aufzählung der vier behaltenen („Re-Baseline-Historie, Reviewer-1.3.0-Eintrag,
zwei Roadmap-Nennungen des Bump-Ziels") trifft Fundstelle für Fundstelle zu. Sie deckt sich mit
A-1 des Verifiers.

**§2/§3-Konsistenz:** §2 (Zeilen 45–52) trägt die korrigierte Zählung mit Herkunftsangabe
(„Verifikation A-1 / Review-Runde-2 N-3, bei `80eec58` nachgemessen"); §3 (Zeilen 85–88) lässt die
falsche Planungs-Messung „13 Vorkommen" **inline markiert** stehen („Diese Planungs-Messung war
falsch — real 15 … der Fehler wird hier stehen gelassen statt überschrieben") und verweist auf §2.
Kein Widerspruch, keine dritte Zahl, keine geglättete Historie. Der voreilige Verweis „in die
Closure-Notiz übernommen" ist ersatzlos entfallen; §7 ist unverändert leer — das ist Verifier-Gebiet
(A-3), nicht meines.

### N-4 im Detail — Annahme ohne Änderung ist tragfähig

N-4 war ausdrücklich als „nur Beobachtung; keine Aktion aus diesem Report erwartet" ausgewiesen.
Die Begründung der Annahme (eine eigene Antwort-Datei je Runde wäre eine Änderung der
Report-Ablage-Konvention und gehört nicht in diesen Slice) hält gegen die Ablage-Regel: Modul 10
§Ablage verlangt „ein Report pro Lauf, Folgeläufe als neue Datei, nie überschreiben" — beides ist
gewahrt (drei Dateien, rein additive Nachträge). Zusätzlich geprüft, ob die gemischte Rollen-Ablage
ein Sonderfall dieses Slice ist: `git log --diff-filter=A` zeigt für die slice-047-Runde dasselbe
Muster (`8c3e095` trug Review- **und** Verifier-Report, `b42cf28` den Runde-2-Report) — es ist
etablierte Repo-Praxis, keine in diesem Slice eingeführte Abweichung. Die Vertagung ist damit
sachlich begründet und nicht bloß eine Vertagung nach Severity-Label.

---

## Neue Findings (aus `3a1e37a`)

### R-1 — Der neue Roadmap-Eintrag behauptet „kein Dokument schreibt sie" — ein Dokument schreibt sie, und zwar anders

- `kategorie`: MEDIUM
- `quelle`: Hard Rule 3.6 ([`AGENTS.md`](../../AGENTS.md) §3.6, „Richtig: benennen, was wirklich
  deckt — oder dass nichts deckt") · Maintainability
- `pfad`: [`docs/plan/planning/in-progress/roadmap.md`](../plan/planning/in-progress/roadmap.md):36
  (Kandidat *Doku- und Sensor-Wartung*, Achse (4), neuer Satz „Sie ist damit **weder verankert noch
  bewacht**: kein Dokument schreibt sie …")
- `befund`: Der Repo-Guide `.claude/commands/close-welle.md`:48–52 schreibt die Konvention
  ausdrücklich: „Der Move bricht die Inbound-Links (Roadmap + die Welle-Verweise der Slices) **und**
  die eigenen `../`-Links der Datei … → im selben Zug reconcilen, bis `docs-check` grün ist"; der
  Slice-Plan selbst verlangt sie in §5 („eigener Move-Commit, eingehende Links im selben Zug
  repariert"). Der Gegenbeleg lag in einem Verzeichnis, das die Prüfung nicht ansah — dieselbe Klasse,
  die N-1 (HIGH) und F-1 (HIGH) in dieser Sitzung bereits getroffen haben. Verschärfend: `close-welle.md`:53–58
  löst dieselbe Spannung **anders** als der Kandidat sie formuliert — nicht „Links in den
  Move-Commit", sondern reiner `git mv`-Commit **plus** eigener Link-Reconciliation-Commit (Hard Rule
  3.3) — und derselbe Text steht als ausgeliefertes Template unter
  `internal/emit/templates/commands/close-welle.md`:55–61, wird also in **jedes** Ziel-Repo emittiert.
- `verifizierbar`: nein für ein Gate (kein Sensor prüft Prosa-Behauptungen über Abdeckung);
  statisch belegt per `grep -rn "im selben Zug" --include="*.md" .` und
  `grep -rniE "inbound[- ]?link|eingehende[nr]? link" --include="*.md" .` — beide Treffer-Mengen
  enthalten `.claude/commands/close-welle.md` und seinen emittierten Zwilling.
- `Failure-Szenario`: Der geplante Wartungs-Slice liest seinen eigenen Trigger, hält die Konvention
  für ungeschrieben und verankert „eingehende Links gehören in den Move-Commit" in `AGENTS.md` oder
  [`harness/conventions.md`](../../harness/conventions.md). Damit stehen zwei Quellen mit
  **gegenläufiger** Commit-Aufteilung im Repo — und die eine davon wird in jedes Adopter-Repo
  emittiert. Genau die Dopplungs-Klasse, gegen die Achse (1) desselben Kandidaten geschnitten ist.

### R-2 — Der widerlegte Satz trägt an seiner Fundstelle keine Marke, anders als im selben Commit im Slice-Plan

- `kategorie`: INFO
- `quelle`: Maintainability · Modul 10 §Ablage (Zeitdokument-Charakter der Reports)
- `pfad`: [`2026-07-26-slice-049-impl-review.md`](2026-07-26-slice-049-impl-review.md):275–276
  (Satz) gegen :300–310 (Korrektur-Sektion)
- `befund`: Derselbe Commit behandelt zwei widerlegte Aussagen unterschiedlich: im Slice-Plan §3
  bekommt die falsche Planungs-Messung eine **Inline**-Marke an ihrer Fundstelle („Diese
  Planungs-Messung war falsch — real 15"), im Runde-1-Report bleibt der widerlegte Satz „die Praxis
  wurde nie ausgeübt" unmarkiert stehen; die Korrektur steht 25 Zeilen später unter eigener
  Überschrift. Wer die F-3-Ablehnung liest und dort aufhört, liest die widerlegte Aussage ohne
  Hinweis. (Nur Beobachtung; keine Aktion aus diesem Report erwartet — die Forderung „stehen lassen
  statt glätten" ist erfüllt, s. N-1.)
- `verifizierbar`: nein — kein Gate deckt Korrektur-Marken in `docs/reviews/**`; belegbar per Lektüre
  der Datei.

---

## Steering-Loop-Signal (Modul 10 §Kontext-Eskalation, Modul 10 §Pflege)

Die Klasse **„Zusage weiter als Abdeckung" — eine behauptete Messung, die ihr eigenes Verfahren
nicht ausführt** ([`AGENTS.md`](../../AGENTS.md) §3.6) tritt in dieser Sitzung zum **vierten** Mal
auf, und drei der vier sind universelle Negative bzw. Allquantoren:

| # | Ort | Aussage | Träger |
|---|---|---|---|
| F-1 | [`harness/conventions.md`](../../harness/conventions.md) (`MR-015` Setzung 2) | „alle 13 CR-Zeilen stammen aus eigenen `spec:`/`plan:`-Commits" | normativer Text |
| N-1 | Commit-Message `d38db74` + Report | „die Praxis wurde **nie** ausgeübt" | schließender Beleg eines offenen Findings |
| N-3 | Slice-Plan §3 + Commit-Message | „13 Vorkommen" / „11 gezogen, 2 behalten" | Planungs-Zahl |
| **R-1** | [`roadmap.md`](../plan/planning/in-progress/roadmap.md):36 | „**kein** Dokument schreibt sie" | Trigger-/Backlog-Text, zugleich Auflösungs-Artefakt von N-2 |

Der Skill verlangt ab der dritten Wiederholung **Guide/Sensor nachziehen statt nur melden**. Das ist
eine Feststellung für die Closure-Notiz, **kein Auftrag an diesen Slice**. Drei Kanten sind
benennbar — die ersten beiden sind die eigentliche Empfehlung:

1. **Guide — [`AGENTS.md`](../../AGENTS.md) §3.6 um den Träger erweitern, der viermal versagt hat.**
   §3.6 zählt heute „Doc-Kommentar, Test-Name, DoD-Punkt, Commit-Message" als Zusage-Träger auf;
   alle vier Instanzen waren **Ist-Messungen in Konventions-, Planungs- und Report-Prosa** und damit
   formal außerhalb der Aufzählung. Die kleinste tragende Schärfung: **ein Allquantor
   (kein/alle/nie/einmalig/immer) über einen Repo-Zustand ist eine Zusage — er trägt den Befehl, der
   ihn misst, neben sich** (Kommando + Suchraum + Ergebnis), sonst ist er nicht fertig. Alle vier
   Instanzen wären damit beim Schreiben aufgefallen: F-1 und N-3 hatten ihr Kommando sogar benannt
   und nicht ausgeführt, N-1 und R-1 hatten einen zu engen Suchraum.
2. **Sensor — den bereits geführten Roadmap-Kandidaten *Prosa-Zahlen-Provenienz* auf
   Behauptungs-Provenienz erweitern**, statt eine neue Achse zu schneiden: derselbe Kandidat
   *Doc-Gate-Härtung* ([`roadmap.md`](../plan/planning/in-progress/roadmap.md):35) führt „Prosa-Zahlen-Provenienz"
   schon als Slice; R-1/N-1 sind dieselbe Form mit **Wörtern statt Zahlen**. Ein d-check-Modul, das
   Allquantoren über Repo-Zustände ohne benachbarte Provenienz-Marke meldet, deckt beide Ausprägungen
   mit einem Bauplan. Der Bedarfsnachweis ist real und liegt bei 4 Instanzen in einer Sitzung.
3. **Reviewer-Skill — zwei Schärfungen aus dieser Sitzung.** (a) *Suchraum:* der Runde-2-Report
   belegte sein „keine adoptierte Konvention" mit einem `grep` über `AGENTS.md`, `harness/`,
   `docs/plan/`, `CLAUDE.md` — `.claude/commands/` und `internal/emit/templates/` waren nicht dabei,
   und genau dort lag der Gegenbeleg (R-1). Die Klasse traf also nicht nur die Implementation,
   sondern auch die Reviewer-Methode. (b) *Kategorisierung:* dieselbe Klasse bekam in dieser Sitzung
   HIGH (F-1), HIGH (N-1), LOW (N-3) und MEDIUM (R-1). Der Skill sagt „Streit über eine
   Kategorisierung ⇒ Regel hier schärfen"; der reproduzierbare Anker wäre die **Wirkungsstelle**:
   normative Quelle (Rang 1–2) oder schließender Beleg eines offenen Findings = HIGH · Planungs-/
   Backlog-Text mit Folgewirkung auf einen geschnittenen oder geführten Slice = MEDIUM · isolierte
   Zahl ohne normative Wirkung = LOW. Nach diesem Anker ist R-1 reproduzierbar MEDIUM.

---

## Negativbefunde

- geprüft, ohne Befund: **Umfang von `3a1e37a`.** `git show --name-only 3a1e37a` = genau fünf Dateien
  (Roadmap-Zeile, Slice-Plan §2/§3, Runde-1-Report-Anhang, Runde-2-Report neu, Verifier-Report neu).
  Kein Code, kein Gate, kein Makefile, kein Test, kein Baseline-Baum, keine Konventions-Datei berührt —
  die Auflösung greift nicht über die Findings hinaus.
- geprüft, ohne Befund: **`harness/conventions.md` / `MR-015` unberührt in `3a1e37a`.** Die in Runde 2
  als real repariert bestätigte Setzung-2-Fassung ist nicht nachträglich angefasst worden
  (`git diff 80eec58..HEAD -- harness/conventions.md` = nur `ce4b611`, `d38db74`).
- geprüft, ohne Befund: **Slice-Plan-Diff bleibt in §2/§3.** Zwei Hunks, beide in der
  Doc-Reconciliation-Achse; keine DoD-Checkbox umgestellt (alle 12 stehen weiter auf `- [ ]`),
  §4/§5/§6/§7/§8 unverändert. Die Abhakung selbst ist Verifier-Gebiet (A-3), nicht meines.
- geprüft, ohne Befund: **Roadmap-Diff bleibt in einer Zelle.** Genau eine Zeile geändert
  ([`roadmap.md`](../plan/planning/in-progress/roadmap.md):36); Meilenstein-Tabelle, Trigger-Historie,
  Kandidaten-Reihenfolge und die slice-049-Zeile unangetastet. Der Befund R-1 betrifft den Inhalt
  dieser einen Zelle, nicht den Umfang.
- geprüft, ohne Befund: **Rein additive Report-Änderung.** 14 Insertions / **0 Deletions** in
  [`2026-07-26-slice-049-impl-review.md`](2026-07-26-slice-049-impl-review.md) — nichts überschrieben,
  Zeitdokument-Charakter gewahrt (Modul 10 §Ablage).
- geprüft, ohne Befund: **Report-Ablage der beiden neuen Dateien.** Runde-2- und Verifier-Report sind
  in `3a1e37a` erstmals in den Baum gekommen; `git log --diff-filter=A` über die slice-047-Runde zeigt
  dasselbe Muster — etablierte Praxis, keine in diesem Slice eingeführte Abweichung, kein
  Überschreiben eines Vorgänger-Reports.
- geprüft, ohne Befund: **`spec/lastenheft.md` über die ganze Range.**
  `git diff --stat 80eec58..HEAD -- spec/` ist leer, auch pro Commit. Die von `MR-015` adoptierte
  Regel wird im Vollzug nicht widerlegt.
- geprüft, ohne Befund: **Hard Rule 3.4 (ADRs immutable).** `git diff 80eec58..HEAD -- docs/plan/adr/`
  ist leer; `3a1e37a` fasst keinen ADR an.
- geprüft, ohne Befund: **Hard Rule 3.5 / `MR-001`.** `3a1e37a` senkt keine Schwelle, aktiviert kein
  Modul, lockert kein Gate — es ändert ausschließlich Doku-Text. Kein ADR nötig.
- geprüft, ohne Befund: **`LH-QA-01` (kein halluziniertes Gate).** Weder die neue Roadmap-Zelle noch
  der Slice-Plan-Text behauptet einen Sensor; die Zelle sagt ausdrücklich „nicht bewacht" und benennt
  `make docs-check`s Grenze korrekt (Arbeitsbaum, nie ein Zwischen-Commit).
- geprüft, ohne Befund: **Vendoring-Verfahren (`MR-007` Setzungen 1–4, `MR-013`).** Von `3a1e37a`
  nicht berührt; `make baseline-verify` in dieser Runde selbst gefahren:
  `baseline-verify: v3.5.2 OK — 42 Dateien (Integritaet + Vollstaendigkeit, netzlos)`.
  `.harness/baseline/` enthält ausschließlich `v3.5.2/`.
- geprüft, ohne Befund: **`make docs-check` selbst gefahren:** `d-check: 184 Datei(en) geprüft,
  0 Befund(e)`, Exit 0 — deckt sich zeichengleich mit der Angabe in der Commit-Message von `3a1e37a`
  (184 statt 183: der Runde-2-Report kam als Datei hinzu). Alle Links und Anker der geänderten
  Dateien lösen auf.
- geprüft, ohne Befund: **`ADR-0003` (Docker-only) / Host-Toolchain.** `3a1e37a` führt kein Werkzeug
  und keine Abhängigkeit ein; beide Sensor-Läufe dieser Runde liefen über `make`-Targets in
  gepinnten Images.
- geprüft, ohne Befund: **Wiederkehr der Runde-1-Findings.** F-1 (Setzung-2-Ist-Messung), F-2
  (`c615da7` gleichrangig), F-5 (`blob/v3.5.1`-Ziel-Form-URLs) sind in Runde 2 am Diff bestätigt und
  von `3a1e37a` nicht rückgängig gemacht; `git grep -n "blob/v3\.5\.1"` über aktive Pfade trifft
  weiterhin nur die §6-Prosa des Slice (Musterbeschreibung, kein Verweis).
- geprüft, ohne Befund: **F-3 bleibt REFUTED.** Die zwei tragenden Säulen der Runde-2-Refutation
  (kein Konventions-Anker für gate-grüne Zwischen-Commits; `9cfa1f3` war nie gepushter Head) werden
  durch R-1 **nicht** berührt — im Gegenteil: `.claude/commands/close-welle.md`:53–58 trennt Move und
  Link-Reconciliation ausdrücklich in zwei Commits und setzt damit einen nicht-grünen Zwischenstand
  voraus. Der Force-Push bleibt nicht verlangt.
- geprüft, ohne Befund: **DoD-Abhakung, Closure-Notiz und `make gates`** — bewusst **nicht** bewertet
  (Modul 11, andere Rolle; A-2/A-3 des Verifiers halten den Stand fest).

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 0 |
| INFO | 1 |

## Verdikt

**NICHT KONFORM. Merge-blockierend: ja** (R-1 MEDIUM) — aber der Blocker ist auf **einen Halbsatz in
einer Roadmap-Zelle** geschrumpft.

**Was hält:** Alle vier Runde-2-Findings sind real beantwortet, jedes am Diff nachgemessen. N-1 ist
die sauberste Auflösung der Sitzung: die Korrektur-Sektion trägt, der widerlegte Satz steht benannt
statt geglättet (0 Deletions), und `08410bc` ist mit 7 Links über 5 Dateien zeichengenau richtig
wiedergegeben. N-3 ist mit 15/11/4 unabhängig reproduziert — Datei für Datei, Fundstelle für
Fundstelle —, §2 und §3 des Slice-Plans widersprechen einander nicht mehr, und der Planungsfehler
bleibt inline markiert sichtbar. N-4 ist begründet angenommen, nicht nach Label vertagt. Das
Vendoring-Verfahren, `spec/`, alle accepted ADRs und `MR-015` sind unberührt; `docs-check` und
`baseline-verify` habe ich selbst grün gesehen.

**Was blockiert:** Das Artefakt, das N-2 einlösen sollte, trägt selbst eine ungemessene
Abdeckungs-Aussage. „Kein Dokument schreibt sie" ist durch `.claude/commands/close-welle.md`
widerlegt — einen Guide, den dieses Repo nicht nur befolgt, sondern über
`internal/emit/templates/commands/close-welle.md` in jedes Ziel-Repo **ausliefert** — und dieser
Guide löst dieselbe Frage sogar **gegenläufig** zu der Formulierung, die der Kandidat als Ziel führt.
Ein Backlog-Eintrag, dessen Trigger-Messung falsch ist, produziert im Folge-Slice entweder eine
zweite, widersprechende Quelle oder eine erneute Messung von vorn. Das ist keine Kategorie-Frage
nach Ermüdung: nach dem Wirkungsstellen-Anker (s. Steering-Loop, Punkt 3b) ist es reproduzierbar
MEDIUM — Planungstext mit Folgewirkung auf einen geführten Kandidaten, nicht normative Quelle
(sonst HIGH), nicht isolierte Zahl (sonst LOW).

**Umfang einer möglichen Runde 4:** genau eine Zelle,
[`roadmap.md`](../plan/planning/in-progress/roadmap.md):36. Alles Übrige aus Runde 1 und Runde 2 ist
in dieser Runde als aufgelöst bestätigt und braucht keine erneute Prüfung; für den Rest des Diffs
lautet mein Urteil konform.

**Übergabe:** R-1 geht an die Implementation (die Aussage dort berichtigen, wo sie steht — der
Roadmap-Eintrag ist der Ort, den N-2 verlangt hat; die Commit-Message von `3a1e37a` trägt denselben
Satz und ist gepusht, also am selben Ort zu berichtigen wie F-4 und N-3). R-2 ist ein Hinweis ohne
erwartete Aktion. Das **Steering-Loop-Signal** (vierte Instanz derselben Klasse) gehört in die
**Closure-Notiz** des Slice, nicht in seinen Umsetzungs-Umfang — die Empfehlung lautet §3.6 um den
Allquantor-Träger zu schärfen und den bereits geführten Kandidaten *Prosa-Zahlen-Provenienz* auf
Behauptungs-Provenienz zu erweitern. Der Report ersetzt keine Verifikation — die DoD hat der Verifier
separat bestätigt (Modul 11); sein A-2 („der stehende Review-Verdikt ist NICHT KONFORM") wird durch
diesen Report nicht aufgehoben, sondern eingegrenzt: der Closure-Trigger §5 ist weiterhin nicht
erfüllt, aber nur noch an einer Stelle.

---

## Nachtrag der Implementation (2026-07-26) — Auflösung der Runde-3-Findings

- **R-1 (MEDIUM) — bestätigt, korrigiert.** Selbst nachgelesen: `.claude/commands/close-welle.md`
  Schritt 3 schreibt die Konvention wörtlich („Der Move bricht die Inbound-Links … im selben Zug
  reconcilen, bis `docs-check` grün ist") und Schritt 4 löst sie als **eigenen
  Link-Reconciliation-Commit nach dem Move** — also **gegenläufig** zur Kandidaten-Formulierung
  „gehören in den Move-Commit"; derselbe Text reist über
  `internal/emit/templates/commands/close-welle.md` in jedes Ziel-Repo. Zusätzlich gemessen:
  `.claude/commands/implement-slice.md`:57 verlangt für die **Slice**-Lifecycle-Moves nur den
  reinen Move, ohne Inbound-Link-Klausel — genau dort wich `9cfa1f3` ab. Mein „kein Dokument
  schreibt sie" war die **vierte** Instanz derselben Klasse (ungeprüfter Allquantor über einen
  Repo-Zustand). Die Roadmap-Zelle trägt jetzt den präzisen Befund: geschrieben **nur** für den
  Welle-Closure-Move, dort **gegenläufig** aufgelöst, für Slice-Moves gar nicht — und in keinem
  Fall bewacht. Der zu klärende Punkt ist damit **zuerst der Widerspruch**, dann die Ausdehnung.
- **R-2 (INFO) — behoben.** Der widerlegte Satz im Runde-1-Report trägt jetzt einen
  Inline-Marker an seiner Fundstelle (HTML-Kommentar, damit der Fließtext des Zeitdokuments
  unverändert bleibt) mit Zeiger auf die Korrektur-Sektion.
- **Steering-Loop-Empfehlung übernommen** — sie geht unverändert in die Closure-Notiz: vier
  Instanzen der Klasse „Zusage weiter als Abdeckung", drei davon Allquantoren; nachzuziehen ist
  `AGENTS.md` §3.6 (Träger-Aufzählung kennt die **Ist-Messung in Prosa** nicht), der Sensor-Bauplan
  liegt beim bestehenden Roadmap-Kandidaten *Prosa-Zahlen-Provenienz*.
