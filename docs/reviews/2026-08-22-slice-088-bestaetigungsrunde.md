# Review-Report: slice-088 — Bestätigungsrunde (Runde 2) — 2026-08-22

> `docs/reviews/**` ist doc-gate-exempt (MR-009 `codepaths.exempt-paths`, MR-011 `ids.exempt-paths`)
> — bare IDs und Pfade stehen hier ohne Link-Pflicht.

**Review-Art:** **Code** — Bestätigungsrunde über die drei Nachzug-Commits zum Runde-1-Report,
geprüft gegen Plan + Konventionen (AGENTS.md, Hard Rules). Kein Plan-Review, kein Design-Review.

**Gegenstand:** `1f3f6e6..c53d849` — vier Commits: `c89612f` (Runde-1-Report, Reviewer) ·
`5e96bd4` (Implementer, HIGH-1) · `abe01f4` (Planner, MEDIUM-1 / LOW-1 / LOW-2 / INFO-1) ·
`c53d849` (Architect, MEDIUM-2 / MEDIUM-3). HEAD = `c53d849`, Arbeitsbaum sauber
(`git status --porcelain | wc -l` → **0**).

**Skill:** `.harness/skills/reviewer.md` @ **1.4.0** (Baseline v3.5.2, Kurs-Welle 34) · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-08-22

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

1. **Diff/Commit-Range:** `1f3f6e6..c53d849`; je Commit `git show --stat` gelesen
   (`5e96bd4`: `d-check.mk` 5+/3−; `abe01f4`: die Plan-Datei 72+/22−; `c53d849`:
   `harness/conventions.md` 65+/21−).
2. **Runde-1-Report:** `docs/reviews/2026-08-22-slice-088-review.md` (1 HIGH / 3 MEDIUM / 3 LOW /
   1 INFO) — die zu bestätigende Befundmenge.
3. **Slice-Plan:** `docs/plan/planning/in-progress/slice-088-dcheck-pin-v0620.md` in seiner
   **neuen** Fassung, vollständig gelesen.
4. **Berührte `LH-*`:** `LH-QA-02`, `LH-QA-01`, `LH-QA-03` (`spec/lastenheft.md`).
5. **Aktive Adaptions-Einträge / ADRs:** `MR-001`, `MR-009`, `MR-010` (neu gefasst), `MR-011`,
   `MR-012`, `MR-017`, `MR-020`, `MR-024` (neu gefasst); keine ADR-Datei im Range.
6. **Hard Rules:** `AGENTS.md` §3.1–§3.8, Schwerpunkt §3.5, §3.6, §3.7, §3.8.
7. **Vorherige Findings am gleichen Modul:** Runde 1 (oben) sowie
   `docs/reviews/2026-08-22-slice-086-{review,bestaetigungsrunde,verdikt-runde}.md` und
   `docs/reviews/2026-07-19-slice-021-review.md`.

**Grundsatz dieser Runde:** jede Zahl und jede Kausal-Aussage der drei Commit-Messages ist als
**Behauptung** behandelt und selbst nachgefahren. Für `MR-024` ist ausdrücklich die
**Gegenrichtung** geprüft — nicht „bestätigt der Klon die Bilanz?", sondern „findet sich in einem
**aktiven** Modul eine Senkung, die die Bilanz übersehen hat?".

**Selbst gefahrene Läufe:**

| Kommando | Ergebnis |
|---|---|
| `grep -c -- '--enable' d-check.mk` | **6** |
| `grep -- '--enable' d-check.mk \| grep -c -- '--disable structure'` | **5** |
| je Recipe ausgewertet (`--enable X` + drei `--disable`-Flags) | fünfmal `citations=1 sources=1 structure=1`; einmal (`--enable structure`, `:72`) `citations=1 sources=1 structure=0` |
| `grep -n '^gates:' Makefile` | `gates: baseline-verify docs-check lint build test shell-lint ci-lint comment-claims span-emit-build span-check record-gates` — kein `doc-*` |
| `grep -n 'v0\.51\.1\|fede3d02' d-check.mk Makefile internal/emit/emit.go` | leer, **Exit 1** |
| `grep -n 'Image v0\.62\.0' harness/conventions.md` | **eine** Zeile (`:14`), Exit 0 |
| `grep -c 'docs-check' d-check.mk` | **5** (Zeilen 3, 17, 30, 31, 75) |
| `grep -rn 'd-check.yml' test/ \| wc -l` / `grep -rl …` | **7** Zeilen in **2** Dateien (`sources-pin.bats` 6, `mutations/04-…` 1) |
| `grep -c 'doc-structure' AGENTS.md harness/README.md` | `AGENTS.md:0`, `harness/README.md:0` |
| `grep -cE '^docs?-[a-z-]+:' d-check.mk` · `make doc-help` | **12** · dieselben zwölf |
| Aufzählung aus `MR-010` §Setzung 2 mechanisch gegen Datei und `doc-help` diffed | **identisch**, 12/12 |
| `docker run --network none …@sha256:fede3d02…` (v0.51.1) über HEAD | `334 Datei(en) geprüft, 0 Befund(e)`, Exit 0 |
| `docker run --network none …@sha256:3996a593…` (v0.62.0) über HEAD | identisch, Exit 0; `diff` der Ausgaben **leer** |
| `docker run …@sha256:3996a593… --print-mk` vs. `d-check.mk` | **drei** Hunks = Kopf + Digest-Pin + `docs-check`-Rename + `doc-help`-Grep; sonst nichts |
| **Sonde A** (Kopie via `git archive HEAD`, `### MR-024`-Überschrift gelöscht) | `334 Datei(en), 1 Befund(e)`, **Exit 1**: `harness/conventions.md:14 #mr-024--… anchor-missing` |
| **Sonde B** (dieselbe Kopie unverändert) | `334 Datei(en), 0 Befund(e)`, Exit 0 |
| **Sonde C** (Anker-Link **und** `MR-024`-Überschrift konsistent auf `v0.61.0`, §Baseline-Zeile bleibt `Image v0.62.0`) | `334 Datei(en), 0 Befund(e)`, **Exit 0** — und `grep -c 'Image v0.62.0'` → 1 |
| `git diff --numstat v0.51.1..v0.62.0 -- rules/{links,ids,matrix,codepaths}.go` (d-check-Klon) | je **keine Zeile** (unverändert) |
| `… -- rules/spans.go` · `… -- rules/links_resolvefrom.go` | **+85 / −0** · **+146 / −0** (neue Datei) |
| `… -- rules/anchors.go` · `… -- rules/markdown.go` | **+59 / −25** · **+112 / −7** — jede Entfernung einzeln gelesen |
| `… -- rules/run.go` | **+10 / −1**; die eine Änderung ist ein zusätzlicher Parameter an `CheckSources`, kein entfernter Modul-Aufruf |
| CHANGELOG `[0.52.0]`…`[0.62.0]` nach `findet weniger\|Lockerung\|verliert` | 7 Fundstellen, alle in `planning`/`planning.closure`, `citations`, `pins`, `versions` |
| `grep -c -- '--config' Makefile d-check.mk` | **0** |
| `make docs-check` (HEAD) | `334 Datei(en) geprüft, 0 Befund(e)`, Exit 0 |

**Nicht gefahren, mit Grund:** `make gates` / `smoke` / `full-smoke` / `mutate` — `gates` schreibt
über `record-gates` einen Zustandsstempel und kollidiert mit dem laufenden Slice; ihre Bestätigung
ist Modul-11-Territorium. Die tragenden Teilaussagen sind stattdessen direkt gemessen.

---

## Status der Runde-1-Findings

Je Finding eine Zeile *aufgelöst / teilweise / offen* mit dem Beleg, der den Status trägt.

| Runde-1-Finding | Status | Beleg (Kommando → Ergebnis) |
|---|---|---|
| **HIGH-1** — `d-check.mk`-Kopf zählte sechs Recipes, die `structure` disablen | **aufgelöst** | `d-check.mk:11-13` sagt jetzt *„von den sechs fokussierten advisory-Recipes disablen FUENF alle drei … das sechste IST `doc-structure` und enabled sein Modul, wie jedes advisory-Target ohne Platz in `make gates`"*. Selbst gemessen: `--enable`-Recipes **6**, davon mit `--disable structure` **5**; je Recipe ausgewertet trägt genau das `--enable structure`-Recipe (`:72`) kein `--disable structure`. Der Zusatz *„ohne Platz in `make gates`"* stimmt: die `gates:`-Kette (`Makefile:262`) enthält kein `doc-*`-Target. Die tragende Aussage ist unberührt: `grep -c structure .d-check.yml` → **0**, `grep -c 'doc-structure' AGENTS.md harness/README.md` → **0/0**. |
| **MEDIUM-1** — Rot-Kommando von DoD (1) konnte nicht leer werden; 3 von 5 Orten ohne Sensor | **aufgelöst** (Rest-Risiko als LOW-2 dieser Runde) | DoD (1) führt jetzt fünf Kommandos Ort für Ort (`:67-88`) und benennt drei davon als **Handläufe**. Nachgefahren: `grep -n 'v0\.51\.1\|fede3d02' d-check.mk Makefile internal/emit/emit.go` → leer/Exit 1; `grep -n 'Image v0\.62\.0' harness/conventions.md` → eine Zeile; `make test`-Kopplung unverändert vorhanden; `make freshness-dcheck` → *aktuell*. Die neue, tragende Zusage — `make docs-check` deckt den MR-Eintrag über den Anker-Link — ist **hermetisch in beide Richtungen** unabhängig verifiziert (Sonde A: `anchor-missing`, Exit 1; Sonde B: 0 Befunde, Exit 0). Die Baum-Suche mit dem unerfüllbaren „→ leer" ist ersatzlos entfallen. |
| **MEDIUM-2** — `MR-010` §Setzung 2 zählte zehn advisory-Targets | **aufgelöst** | `harness/conventions.md:466-476` führt jetzt **zwölf** Targets mit ihrem Kommando und **elf** advisory inkl. `doc-structure`. Mechanisch geprüft: die Aufzählung aus §Setzung 2 gegen `grep -oE '^docs?-[a-z-]+:' d-check.mk` und gegen `make doc-help` gediffed → **identisch, 12/12**. Die konkurrierende Zweitzählung in §Adaption (c) ist entfernt (`:456-458`); im Repo steht *„elf Targets"* nur noch in `docs/plan/planning/done/slice-017-…` — einem Zeitdokument über v0.46.0, korrekt unangetastet. Der Ort stimmt: `MR-010` ist aktiv und spricht im Präsens, `MR-012` ist eingefrorener Zeitbezug. Neu ist ein **Träger**: §Auflösungs-Trigger (`:489-493`) verlangt den Abgleich der Aufzählung gegen `make doc-help` beim nächsten Re-Pin. |
| **MEDIUM-3** — „senkt keine Strenge" ruhte auf einem 0-→-0-Lauf | **aufgelöst** | `MR-024` sagt jetzt zuerst, **was der Lauf nicht beantwortet** (`:1148-1152`), und stellt die §3.5-Antwort auf die **Versions-Differenz der Regelmodule** (`:1153-1188`). Die Gegenrichtung ist von mir selbst gefahren, nicht übernommen — Ergebnis in der Tabelle oben und im Negativbefund *Strenge-Bilanz* unten: **keine** Senkung in einem der sechs aktiven Module. Neuer Träger: der §Auflösungs-Trigger (`:1195-1198`) verlangt die Bilanz beim nächsten Sprung neu. |
| **LOW-1** — Plan datierte `structure` auf v0.62.0 | **aufgelöst** | Plan `:42-44`: *„Ausgeliefert ist es seit **v0.57.0** … mit v0.62.0 kommt es **hier** an."* Deckt sich mit meiner Runde-1-Messung (`git ls-tree` je Tag: v0.56.0 → 0, v0.57.0 → 1; CHANGELOG `[0.57.0]`) und mit `d-check.mk:10` sowie `MR-024`. Alle drei Fundorte tragen jetzt dieselbe Version. |
| **LOW-2** — DoD (3) nannte `330 Datei(en)` als Erwartungswert | **aufgelöst** | Plan `:130-137`: erwartet ist *„eine **Differenz, keine Zahl**"*; die Dateizahl ist ausdrücklich **kein** Erwartungswert mehr, mit Begründung (der Baum wuchs am selben Tag von 330 auf 334). Auch §3 (`:153`) führt nur noch `0 Befund(e)`, Exit 0. Selbst nachgefahren am HEAD: beide Digests `334/0`, Exit 0, `diff` leer — die Aussage ist jetzt unabhängig von der Baumgröße wahr. |
| **LOW-3** — `d-check.mk` verwies auf `MR-024`, bevor es existierte | **aufgelöst am Endzustand, als Prozess-Beobachtung offen** | Am HEAD löst der Verweis auf (`make docs-check` grün, `MR-024` bei `harness/conventions.md:1117`). Die Sensor-Lücke besteht unverändert: `.mk`-Dateien liegen außerhalb des `ids`-Prüfbereichs — die vier bare `MR-`-Kennungen in `d-check.mk:2` erzeugen bei grünem Lauf keinen Befund. Kein neuer Befund dieser Runde; als wiederkehrende Prozess-Beobachtung im Steering-Loop-Absatz unten festgehalten. |
| **INFO-1** — DoD (2) nannte den grünen Fall als Rot-Kommando | **aufgelöst** | Plan `:108-117` nennt jetzt **drei Bruch-Ereignisse** statt eines Erwartungswerts, und `:118-127` sagt ausdrücklich, dass es für die `modules:`-Liste dieses Repos **keinen Sensor** gibt; §6 (`:252-260`) führt die Lücke als offenen Punkt mit der Begründung, dass ein unkonfiguriertes Modul am Gate-Ausgang nicht von echtem Grün zu unterscheiden ist. Selbst gegengeprüft: `make doc-structure` → `334 Datei(en) geprüft, 0 Befund(e)`, Exit 0 über leerem Regelsatz. (Zwei Zahlen im neuen Text sind unbelegt — LOW-1 dieser Runde.) |

**Bilanz:** 1 HIGH, 3 MEDIUM, 3 LOW und 1 INFO aus Runde 1 sind **aufgelöst**; keines ist offen,
keines nur teilweise. Vier der acht Auflösungen habe ich nicht nur nachgelesen, sondern gegen eine
**eigene** Messung gestellt (HIGH-1, MEDIUM-2, MEDIUM-3, MEDIUM-1/Sonden).

---

## Neue Findings dieser Runde

### MEDIUM-1 — Der Plan trägt die von HIGH-1 widerlegte Aussage an ihrem zweiten Fundort weiter und widerspricht damit den zwei korrigierten Artefakten

- `kategorie`: **MEDIUM**
- `quelle`: `LH-QA-02` (§3 ist die aufgezeichnete Vorab-**Messung** des Slice) · Reviewer-Skill
  §MEDIUM (*Spec-Treue-Lücke einer Messmethode*); **nicht** `AGENTS.md` §3.7 — dessen
  Geltungsbereich ist *„Code, Konfiguration und Skripte"*, ein Plan-Dokument fällt nicht darunter,
  deshalb **kein** HIGH wie in Runde 1
- `pfad`: `docs/plan/planning/in-progress/slice-088-dcheck-pin-v0620.md:151-152` (§3, Vorab-Messung)
  — Randfall am selben Gegenstand: `:106` (DoD (2))
- `befund`: §3 hält als gemessene Fragment-Differenz fest: *„(c) ein **neues Modul** `structure` —
  ein neues Target `doc-structure` und ein zusätzliches `--disable structure` **in jedem
  fokussierten advisory-Recipe**"*. Gemessen sind es fünf von sechs: `grep -c -- '--enable'
  d-check.mk` → **6**, davon mit `--disable structure` → **5**; das sechste ist `doc-structure`
  selbst. Das ist wörtlich die Aussage, die `5e96bd4` in `d-check.mk` als falsch korrigiert hat und
  die `MR-024:1145-1146` von Anfang an richtig trägt (*„in den **bestehenden** fokussierten
  advisory-Recipes"*). Nach dieser Runde stehen damit drei Live-Artefakte zu derselben Sache
  nebeneinander, und eines widerspricht den anderen zwei. DoD (2) `:106` schreibt *„in den
  fokussierten advisory-Recipes"* ohne Quantor — für sich vertretbar, im Verbund mit §3 aber
  dieselbe Lesart.
- `failure-szenario`: Die Verifikation (Modul 11) prüft DoD (2) *„Alles Übrige ist verbatim vom
  Tool"* gegen die Fragment-Differenz, die §3 ausweist. Sie zählt `--disable structure` und findet
  fünf statt sechs — und schließt entweder, die Re-Adaption sei **nicht** verbatim (falsches Rot an
  einem korrekten Fragment), oder sie übergeht die Abweichung und trainiert dabei, ausgewiesene
  Messungen nicht nachzuzählen. Zweiter Pfad: die Zahl wandert über die Closure-Notiz in ein
  Zeitdokument, das danach niemand mehr anfasst — dort steht dann die widerlegte Fassung neben der
  korrigierten in `d-check.mk`.
- `verifizierbar`: **nein, kein Gate.** `make comment-claims` erfasst keine Markdown-Datei
  (`AGENTS.md` §4, Ausschluss 2); kein Modul des Doku-Gates zählt Recipe-Flags. Die zwei
  `grep -c`-Läufe oben belegen den Ist-Zustand.
- `rollen-verweis`: **Planner**-Artefakt — hier gemeldet, nicht geändert.

### LOW-1 — Zwei Zahlen im neuen DoD-(2)-Text nennen ein Kommando, das sie nicht liefert

- `kategorie`: **LOW** (Reviewer-Skill §LOW; bewusst dieselbe Stufe wie Runde-1 LOW-2, s. u.)
- `quelle`: `AGENTS.md` §3.6 (der DoD-Punkt ist ausdrücklich Zusage-Träger) · Reviewer-Skill §LOW
- `pfad`: `docs/plan/planning/in-progress/slice-088-dcheck-pin-v0620.md:116` und `:119`
- `befund`: (a) `:116` — *„oder `docs-check` verschwindet aus `d-check.mk`
  (`grep -n 'docs-check' d-check.mk` → **vier Zeilen**)"*; das genannte Kommando liefert **fünf**
  Zeilen (`grep -c` → 5; Fundstellen `:3`, `:17`, `:30`, `:31`, `:75`). (b) `:119` — *„`grep -rn
  'd-check.yml' test/` liefert **zwei Treffer**"*; `grep -rn` liefert **sieben** Zeilen
  (`sources-pin.bats` 6, `mutations/04-inscope-filterregel.sh` 1) in zwei Dateien; zwei Treffer
  liefert `grep -rln`. Die Sache dahinter stimmt in beiden Fällen — `docs-check` steht in
  `d-check.mk`, und keine der zwei Dateien trägt die `modules:`-Liste; falsch ist die Zahl, die das
  Dokument seinem eigenen Kommando zuschreibt.
- `failure-szenario`: (a) ist derselbe Mechanismus, den derselbe Commit in DoD (3) beseitigt hat:
  eine Zahl, die mit dem Artefakt wandert. Wer den Kopfkommentar von `d-check.mk` erneut anfasst,
  ändert die Trefferzahl, ohne dass am Gate etwas bricht — der DoD-Punkt liest dann rot, obwohl die
  Zusage hält. (b) Ein Lauf, der `grep -rn` wie geschrieben fährt und sieben Zeilen sieht, kann die
  Aussage *„keiner trägt sie"* nicht mehr gegen die genannte Menge prüfen und muss die Datei-Ebene
  selbst rekonstruieren.
- `verifizierbar`: **ja** — beide Kommandos stehen im Dokument und sind direkt nachfahrbar.
- `warum LOW und nicht MEDIUM`: In Runde 1 ist die inhaltsgleiche Beobachtung (`330` statt `333`
  in DoD (3)) als LOW eingestuft worden; die Substanz beider Punkte trägt, betroffen ist die
  Beleg-Ziffer, nicht das Kriterium. Eine Höherstufung hier wäre gegenüber Runde 1 inkonsistent.
- `rollen-verweis`: **Planner**-Artefakt.

### LOW-2 — Die Deckungs-Zusage für den fünften Ort ist breiter als der Sensor; die Blindstelle, die der Nachbar-Punkt ausdrücklich nennt, fehlt hier

- `kategorie`: **LOW**
- `quelle`: `AGENTS.md` §3.6 · `LH-QA-02` · Reviewer-Skill §MEDIUM/§LOW (*Zusage breiter als
  Beleg*)
- `pfad`: `docs/plan/planning/in-progress/slice-088-dcheck-pin-v0620.md:90-94` (letzter Spiegelstrich
  von DoD (1))
- `befund`: Der Punkt sagt: *„`make docs-check` deckt den neuen MR-Eintrag — **sofern** die
  §Baseline-Zeile ihn als Anker-Link nennt"*. Die Bedingung ist richtig und von mir hermetisch in
  beide Richtungen belegt (Sonde A/B). Was der Satz nicht sagt: die Deckung reicht auf die
  **Existenz** der Überschrift, nicht auf die Version, die sie nennt. Gemessen an Sonde C — Kopie
  via `git archive HEAD`, Anker-Link **und** `MR-024`-Überschrift konsistent auf `v0.61.0`, die
  §Baseline-Zeile unverändert `Image v0.62.0` — bleibt `make docs-check` bei `334 Datei(en), 0
  Befund(e)`, Exit 0, **und** der Handlauf `grep -c 'Image v0.62.0' harness/conventions.md` liefert
  weiter `1`. Beide für diesen Ort genannten Kommandos passieren, während der MR-Eintrag eine
  Version führt, die nirgends gepinnt ist. Es ist exakt die Blindstelle *„zwei gleich alte Werte"*,
  die derselbe DoD-Punkt beim Nachbar-Kommando (`make test`) ausdrücklich benennt und dort mit
  `make freshness-dcheck` schließt.
- `failure-szenario`: Beim nächsten Pin-Sprung wird der neue MR-Eintrag aus dem vorigen kopiert und
  die Version im Titel nicht mitgezogen; der Anker-Link wird gegen den kopierten Titel geschrieben,
  damit er auflöst. `make docs-check` bleibt grün, der §Baseline-Handlauf bleibt grün, und der
  Adaptions-Block trägt einen Eintrag, dessen Überschrift eine andere Version behauptet als der
  Pin — die §Baseline-Zeile zeigt per Link auf ihn.
- `verifizierbar`: **teilweise** — die *Existenz*-Deckung bestätigt jeder `make docs-check`-Lauf;
  die Lücke belegt Sonde C, kein Gate.
- `rollen-verweis`: **Planner**-Artefakt (DoD-Text).

### INFO-1 — Die Lockerungs-Hälfte der Strenge-Bilanz stützt sich auf eine Liste, die upstream selbst als offen ausweist

- `kategorie`: **INFO** (dokumentationswürdige, undokumentierte Annahme; **keine** Aktion in diesem
  Slice erwartet — die Bilanz trägt auf ihrem zweiten Bein)
- `quelle`: `AGENTS.md` §3.5 · `MR-024` §*Die ausgewiesenen Lockerungen*
- `pfad`: `harness/conventions.md:1170-1181`
- `befund`: `MR-024` sagt korrekt *„die **ausgewiesenen** Lockerungen"* und zählt sie mit ihren
  CHANGELOG-Stellen auf — von mir nachgezählt und je Modul bestätigt (`[0.56.0]` zweimal
  `closure-note-boilerplate`, `[0.58.0]` zwei Falsch-Rot in `planning` sowie *„findet weniger"* bei
  `citations`/`pins`/`versions`; alle fünf Module inaktiv). Was der Eintrag nicht nennt: derselbe
  `[0.58.0]`-Block sagt über seine eigene Aufzählung *„**Diese Aufzählung ist offen** — sie nennt
  die gemessenen Fälle, nicht alle möglichen; in drei Review-Runden ist sie dreimal unvollständig
  gewesen."* Die CHANGELOG-Hälfte des Belegs ist damit keine Vollständigkeitsaussage. Tragend ist
  sie hier auch nicht: das zweite Bein — die Quell-Differenz über die sechs aktiven Module — ist
  geschlossen und von mir unabhängig nachgefahren (s. Negativbefund *Strenge-Bilanz*).
- `failure-szenario`: Beim nächsten Sprung wird die Bilanz nach dem Muster dieses Eintrags gezogen
  und dabei auf die schnellere Hälfte verkürzt — CHANGELOG nach *„findet weniger"* durchsuchen,
  Modul-Zuordnung prüfen, fertig. Über eine Spanne, in der eine Lockerung an einem aktiven Modul
  **nicht** ausgewiesen ist, liefert dieses Verfahren ein grünes Ergebnis ohne Deckung, und §3.5
  greift nicht.
- `verifizierbar`: **nein** — kein Modul dieses Repos liest einen fremden CHANGELOG. Die Aussage
  ist gegen den lokalen Klon reproduzierbar
  (`awk '/^## \[0\.58\.0\]/,/^## \[0\.57\.0\]/' CHANGELOG.md`).
- `rollen-verweis`: **Architect**-Artefakt (`AGENTS.md` §3.8).

---

## Negativbefunde

- **geprüft, ohne Befund — HIGH-1-Korrektur erzeugt keine neue Ungenauigkeit:** die drei Aussagen
  des neuen Satzes sind einzeln gemessen — sechs fokussierte Recipes (`grep -c -- '--enable'` → 6),
  fünf davon mit allen drei `--disable`-Flags (je Recipe ausgewertet: `citations=1 sources=1
  structure=1`), das sechste mit `--enable structure` und ohne `--disable structure`, und kein
  advisory-Target in der `gates:`-Kette (`Makefile:262`). Der Zusatz *„verbatim vom Tool"* hält:
  im Regenerations-Diff gegen die frische `--print-mk`-Ausgabe erscheinen alle sechs Recipes als
  unveränderter Kontext.
- **geprüft, ohne Befund — Strenge-Bilanz, Gegenrichtung selbst gefahren (`AGENTS.md` §3.5):** über
  `v0.51.1..v0.62.0` am lokalen d-check-Klon sind die Regeldateien der aktiven Module
  `links`, `ids`, `matrix`, `codepaths` **unverändert** (`git diff --numstat` liefert je keine
  Zeile); `spans.go` ist **+85/−0**, also rein additiv; `resolve-from` kommt als **neue** Datei
  `links_resolvefrom.go` (+146/−0), und ihr Einstieg ist nil-geschützt
  (`group := resolveFromGroupOf(groups, …); if group == nil { return nil }`, dazu `CheckResolveFromDirs`
  als Schleife über eine leere Gruppenliste) — ohne Schlüssel wirkungslos, im Quelltext
  gegengelesen. `anchors.go` (**+59/−25**) hat genau drei Hunks, alle Extraktion:
  `HeadingSlugs` delegiert an `headingSlugsOrdered`, `htmlAnchors` an `htmlAnchorLines`, und das
  inline `url.PathUnescape` wird `DecodeFragment` mit identischem Fallback; `Slugify` und
  `ExtractHeadings` sind unberührt. `markdown.go` (**+112/−7**) — die geteilte Vorverarbeitung, aus
  der **alle** hier aktiven Module lesen — entfernt sieben Zeilen, und jede ist gelesen: zweimal
  `strings.TrimLeft(raw, " \t")` → `TrimFenceIndent(raw)` mit **identischem** Rumpf, einmal
  `pl.no != prevNo+1` → `fencedBlockBetween(prevNo, pl.no)` mit identischer Bedingung, viermal
  Kommentar. Damit ist die `[0.53.0]`-Fence-Lexik für die aktiven Module nachweislich **nicht**
  bewegt worden. `run.go` (**+10/−1**) entfernt keinen Modul-Aufruf; die eine Änderung ist ein
  zusätzlicher Parameter an `CheckSources`. Und der `[0.52.0]`-`sources`-Fix greift laut CHANGELOG
  nur *„unter `--config`"*; `grep -c -- '--config' Makefile d-check.mk` → **0**. Ergebnis: **keine
  Senkung an einem aktiven Modul**, eine Anhebung (`spans`) — die §3.5-Bewertung („kein ADR;
  Anheben ist Steering-Loop nach `MR-001`") trägt.
- **geprüft, ohne Befund — der Prüfbereich hat sich nicht verengt:** eine Lockerung könnte auch
  außerhalb der Regelmodule sitzen, in Scan-/Ignore-Semantik. Beide Digests liefern über demselben
  Baum **dieselbe** Dateizahl (`334`), in Runde 1 über einem kleineren Baum ebenfalls beidseitig
  identisch (`333`) — der Scan-Umfang ist über die elf Minors unverändert.
- **geprüft, ohne Befund — `MR-010` ist der richtige Ort (gegen einen `MR-024`-Nachtrag):**
  `MR-010` ist aktiv (§Auflösungs-Trigger *permanent*), spricht im Präsens über die heute lebende
  Datei und ist nicht nach `MR-020` auf Kopf und Zeiger zurückgeführt; `MR-012` dagegen nennt ein
  Ereignis von damals. Ein Nachtrag in `MR-024` hätte die Grenzziehung auf zwei Einträge verteilt,
  von denen der ältere weiter falsch zählte. Die neue Fassung nennt ihr Kommando **im Text**
  (`grep -cE '^docs?-[a-z-]+:' d-check.mk` → 12) statt nur eine Zahl.
- **geprüft, ohne Befund — der fünfte Handgriff erzeugt keine Zähl-Kollision:** `MR-010`
  §Auflösungs-Trigger verlangt zusätzlich den Abgleich der Aufzählung gegen `make doc-help`, ohne
  ihn zu nummerieren. Alle Live-Artefakte sprechen weiter einheitlich von **vier** Handgriffen der
  Re-Adaption (`harness/conventions.md:462` §Setzung 1, `:1146` in `MR-024`, Plan `:22` und `:102`);
  die Formulierung *„fünfter Handgriff"* steht allein in der Commit-Message, nicht im Artefakt.
  Kein Widerspruch im Bestand.
- **geprüft, ohne Befund — Hard Rule 3.8, Zuschnitt beider Rollen-Commits:**
  `git show --stat c53d849` → **genau eine** Datei, `harness/conventions.md`; die Message beginnt
  mit *„Rolle Architect: …"*. `git show --stat abe01f4` → **genau eine** Datei, die Slice-Plan-Datei;
  Message *„Rolle Planner: …"*. Der Implementer-Commit `5e96bd4` berührt ausschließlich `d-check.mk`
  und damit kein fremdes Rollen-Artefakt. Kein Commit dieser Runde mischt zwei Rollen.
- **geprüft, ohne Befund — Hard Rule 3.4 / ADR-Lage:** keine Datei unter `docs/plan/adr/` im Range;
  `MR-024` §*Kein ADR nötig* begründet das an §3.5 und `MR-001`, und die Begründung ist oben
  unabhängig gemessen. Kein Eintrag mit `Accepted`-Status wurde überschrieben.
- **geprüft, ohne Befund — Hard Rule 3.3:** der Range enthält keinen `git mv`; die Slice-Datei liegt
  unverändert in `in-progress/`.
- **geprüft, ohne Befund — Hard Rule 3.2:** kein `//nolint`, kein `# shellcheck disable` im Range.
- **geprüft, ohne Befund — Hard Rule 3.7 in den neuen Texten:** der einzige **Kommentar** im Range
  ist der `d-check.mk`-Kopf (oben geprüft). `MR-010`/`MR-024` und der Slice-Plan sind
  Markdown-Register- bzw. Planungstext; §3.7 §Geltungsbereich nennt *„Code, Konfiguration und
  Skripte"*. Die neuen Register-Absätze sind durchweg Indikativ über den Ist-Zustand; die eine
  Passage über die verworfene Beleg-Führung (`:1148-1152`, *„Er trägt eine Richtung … in der
  Gegenrichtung informationsleer"*) beschreibt die **geltende** Grenze des Laufs, nicht eine
  verworfene Alternative — sie fällt nicht unter die erste Falsch-Klasse.
- **geprüft, ohne Befund — `LH-QA-01` unverändert gewahrt:** `grep -c 'doc-structure' AGENTS.md
  harness/README.md` → **0/0**; `make gates` führt weiter genau ein d-check-Target (`docs-check`);
  `grep -c structure .d-check.yml` → **0**. Kein neuer Gate-Name in dieser Runde.
- **geprüft, ohne Befund — Substanz des Slice unverändert tragfähig:** am HEAD `c53d849` liefern
  beide Digests über demselben Baum `334 Datei(en) geprüft, 0 Befund(e)`, Exit 0, `diff` leer; der
  Regenerations-Diff gegen die frische `--print-mk`-Ausgabe hat weiter **drei** Hunks (Kopf +
  Digest-Pin, `docs-check`-Rename, `doc-help`-Grep) und nichts sonst; `make docs-check` grün. Der
  Pin steht an allen fünf Orten (`d-check.mk:18-19`, `Makefile:40`, `internal/emit/emit.go:33-34`,
  `harness/conventions.md:14`, `MR-024`).
- **geprüft, ohne Befund — Zeitdokumente unangetastet:** kein Commit dieser Runde berührt
  `docs/reviews/**` oder `docs/plan/planning/done/**`; die zwei verbliebenen *„elf Targets"*-Stellen
  in `done/slice-017-…` sind Zeitbezug auf v0.46.0 und korrekt stehengeblieben.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 2 |
| INFO | 1 |

**Konvergenz über zwei Runden, gezählt:** R1 → 1 HIGH / 3 MEDIUM / 3 LOW / 1 INFO ·
R2 → 0 HIGH / 1 MEDIUM / 2 LOW / 1 INFO. **Alle acht** Runde-1-Findings sind aufgelöst; die vier
neuen liegen sämtlich in Planner- und Architect-Text, keines am Pin, keines an einem Gate.

**Steering-Loop-Signal (Skill §Kontext-Eskalation) — dieselbe Klasse zum vierten und fünften Mal.**
R2-LOW-1 und R2-LOW-2 sind erneut *ein Beleg, den das Kommando im Dokument nicht herstellt* bzw.
*eine Zusage, die weiter reicht als ihr Sensor* — dieselbe Klasse wie R1-MEDIUM-1/-3 und wie die
drei MEDIUM des Vortags-Reviews zu slice-086. Bemerkenswert und für den Steering-Loop das
eigentliche Datum: sie tritt **in dem Commit auf, der sie behebt** — `abe01f4` entfernt in DoD (3)
eine mitwandernde Zahl und setzt zwei neue in DoD (2), acht Zeilen darüber. Das ist kein
Sorgfaltsproblem einer Rolle, sondern ein fehlender Träger: das Repo hat keinen Sensor, der eine
Zahl im Fließtext gegen das danebenstehende Kommando hält, und `make comment-claims` schließt
Markdown dauerhaft aus (`AGENTS.md` §4, Ausschluss 2). R2-MEDIUM-1 ist die zweite Trägerlücke
derselben Sitzung: eine Korrektur, die **einen** genannten Fundort trifft und den zweiten
stehenlässt. Beide sind benannt, nicht gelöst — Träger und Sensor sind nicht die Rolle des
Reviewers.

## Verdikt

**Merge-blockierend: ja** — wegen **eines** MEDIUM (R2-MEDIUM-1).

**Begründung, und warum das Verdikt trotzdem eine gute Nachricht ist.** Der Nachzug hat geliefert,
was er sollte: das HIGH ist an der Sache behoben und nicht nur umformuliert, und die drei MEDIUM
sind nicht durch Zusicherung, sondern durch **Beleg-Ketten** geschlossen, die ich unabhängig
nachfahren konnte — die Anker-Kopplung hermetisch in beide Richtungen, die Target-Aufzählung
mechanisch gegen Datei und `make doc-help`, die Strenge-Bilanz gegen den Quell-Diff aller sechs
aktiven Regelmodule. Zwei der drei Auflösungen bringen zudem einen **Träger** mit (die zwei
ergänzten §Auflösungs-Trigger-Zeilen), statt nur den Text zu reparieren; das ist die Antwort, die
das Runde-1-Klassen-Signal verlangt hat.

Was blockiert, ist **ein Satz in einem Planner-Artefakt**: §3 des Plans hält als gemessene
Fragment-Differenz *„in jedem fokussierten advisory-Recipe"* fest, während `d-check.mk` und
`MR-024` nach dieser Runde beide sagen, dass es fünf von sechs sind. Ich stufe das nicht deshalb
als MEDIUM ein, weil der Satz falsch ist, sondern weil er die **aufgezeichnete Messung** ist, gegen
die die Verifikation DoD (2) prüft — ein falscher Messwert an dieser Stelle erzeugt entweder ein
falsches Rot oder die Gewohnheit, ausgewiesene Messungen nicht nachzuzählen. Kein HIGH: §3.7 bindet
Code, Konfiguration und Skripte, nicht ein Plan-Dokument.

Die zwei LOW und das INFO blockieren nicht und sind ausdrücklich **nicht** als Nacharbeit vor dem
Merge gemeint; sie gehören in dieselbe Übergabe, damit sie nicht in einem Review-Report enden.

**Übergabe.** R2-MEDIUM-1, R2-LOW-1 und R2-LOW-2 gehen an den **Planner** (Rückkante Review → Plan);
R2-INFO-1 an den **Architect** (`AGENTS.md` §3.8). Der Report ersetzt **keine** Verifikation —
DoD-Abhakung und die Bestätigung von `make gates` / `make smoke` / `make full-smoke` / `make mutate`
sind Modul-11-Territorium mit anderem Prüf-Artefakt und anderem Eingabe-Kontext; sie sind hier
bewusst nicht vorgenommen.
