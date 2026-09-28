# Slice slice-amend-haelt-den-index-pfadrein: Ein Träger hält `--amend` gegen fremde Index-Einträge

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. (1) Bündel? Nein. (2) Gemeinsames Closure-Kriterium? Nein.
(3) **Reaktiv:** eine Register-Beobachtung über der Schwelle. Begründet gegen die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird).

**Bezug:** Beobachtungs-Register
[`BEO-ALL/amend-committet-fremde-index-eintraege-mit`](../observations/BEO-ALL/amend-committet-fremde-index-eintraege-mit/observation.md)
(3 Belege — Konsistenz-Review 2026-09-15, `slice-174-archivierung-emittieren`,
`slice-d-check-pin-bringt-links-lookahead-und-referenz-definitionen`; 3× am
2026-09-27 erreicht, Ausgang `geplant`), [`AGENTS.md`](../../../../AGENTS.md) §3.10 (Rollentrennung
bei parallel laufenden Rollen im selben Klon).

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-27.

---

## 1. Ziel und Abgrenzung

**Ziel:** `git commit --amend` committet den **Index**, nicht die Pfade des eigenen Vorgangs — läuft
zwischen dem letzten eigenen Commit und dem Amend ein paralleler Vorgang und hinterlässt Dateien im
Index, reißt der Amend sie mit. Dieser Slice baut den Träger, der das verhindert: entweder eine
Disziplin (`git commit --only <pfad>` statt `--amend`/`-A`, verankert in den Rollen-Anweisungssätzen,
die selbst committen) oder ein `pre-commit`-Hook, der den Index vor dem Commit gegen die vom
aufrufenden Lauf erwarteten Pfade hält.

Beleg:
[`BEO-ALL/amend-committet-fremde-index-eintraege-mit`](../observations/BEO-ALL/amend-committet-fremde-index-eintraege-mit/observation.md)
(3 Belege: Konsistenz-Review 2026-09-15, `slice-174-archivierung-emittieren`,
`slice-d-check-pin-bringt-links-lookahead-und-referenz-definitionen`).

**Ausdrücklich NICHT in diesem Slice:**

- **Ein genereller Index-Wächter, der jeden Commit prüft.** *Anderer Vorgang:* Träger ist hier
  ausdrücklich der `--amend`-Fall, nicht jede Commit-Form.
- **Die Behebung bereits geschehener, gepushter Fälle.** *Bestand bleibt bewusst stehen:* Alle drei
  Belege sind bereits selbstheilend repariert (Reflog-Reset vor dem Push); es gibt nichts mehr zu
  korrigieren.

### Architect-Verdikt (DoD-Punkt 2, `AGENTS.md` §3.8)

**Träger: ein `.githooks/pre-commit`-Hook — nicht eine Disziplin-Regel in den
Rollen-Anweisungssätzen.** Abwägung entlang derselben zwei Achsen, die
[`harness/README.md`](../../../../harness/README.md) §Traceability für den `commit-msg`-Träger
bereits führt (Reichweite gegen technische Durchsetzung):

- **Reichweite entscheidet, nicht Bequemlichkeit.** Ein Hook feuert bei jedem `git commit` in
  diesem Klon, sobald `make hooks-install` gelaufen ist — unabhängig davon, welche Rolle den Commit
  auslöst. Eine Disziplin-Regel wirkt dagegen nur dort, wo ihr Träger als Eingabe gelesen wird. Von
  den sechs Rollen führen laut Baseline-Regelwerk `modul-08-agentenrollen.md` §Welche Rolle braucht
  welche Artefaktklasse nur **drei** überhaupt einen Rollen-Anweisungssatz, in den eine solche Regel
  geschrieben werden könnte — `.claude/commands/implement-slice.md` (Implementer),
  `.claude/commands/plan-welle.md`/`close-welle.md` (Planner), `.harness/skills/reviewer.md`
  (Reviewer). **Architect und Verifier führen laut derselben Tabelle keinen** (Artefaktklasse
  `Template` bzw. `keins`) — dieser Architect-Lauf selbst belegt die Lücke: er liest keinen
  dedizierten Anweisungssatz, sondern eine Freitext-Delegation. Eine Disziplin-Regel deckt damit
  strukturell nicht alle Rollen, die laut den drei Registerbelegen tatsächlich committen (die
  Commit-Historie führt Präfixe für alle sechs Rollen); ein Hook deckt sie, weil er am Commit hängt
  und nicht am Anweisungssatz — dieselbe Eigenschaft, die `commit-msg` für die
  Traceability-Kennung trägt (`harness/README.md` §Traceability: *„er sieht jede Commit-Klasse, die
  git selbst erzeugt"*).
- **Grenze, benannt statt vergrößert.** Wie beim `commit-msg`-Träger gilt: der Hook wirkt nur nach
  `make hooks-install` (lokale Konfiguration, reist nicht mit dem Klon) und wird von
  `git commit --no-verify` umgangen. Diese Grenze steht bereits als Risiko in §6 dieses Plans und
  wird durch die Trägerwahl nicht größer — sie ist identisch mit der am `commit-msg`-Träger bereits
  akzeptierten Grenze, kein neuer Preis.

**Schreibende Rolle: der Implementer, im normalen Ablauf dieses Slice — nicht der Architect.** Zwei
Normen wurden geprüft; beide schließen aus, dass diese konkrete Entscheidung eine andere Rolle
bindet:

- [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) bindet die
  schreibende Rolle nur für einen **Rollen-Anweisungssatz** — ein Artefakt, *„das die operative
  Ausführung genau einer Rolle für deren eigenen Ablauf distilliert"*. Ein `pre-commit`-Hook
  distilliert keinen Rollen-Ablauf; er ist ein rollenübergreifendes
  Durchsetzungsschicht-Element (Baseline-Regelwerk `modul-13-quality-gates.md` §Guard-Härtung,
  `grundlagen-durchsetzungsschicht.md`), das für jede Rolle gleich greift, egal welche gerade
  committet. [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) erreicht ihn nicht — dieselbe Grenze, die die ADR selbst für
  `.claude/agents/*.md` zieht: nicht jedes Artefakt, das eine Rolle berührt, ist ihr
  Anweisungssatz.
- `AGENTS.md` §3.8 bindet den Architect nur für zwei benannte Artefakte (Hard Rules §3,
  Adaptions-Block) und sagt selbst: *„Über andere Norm-Artefakte sagt diese Regel nichts. … wo keine
  sie benennt, bleibt die Frage offen."* Ein `pre-commit`-Hook ist keines der zwei benannten
  Artefakte.

Es gilt damit der Regelfall: ein technischer Wächter ist ein normales Implementierungs-Artefakt des
Slice und wird von der Rolle gebaut, die den Slice implementiert — exakt der Präzedenzfall des
bestehenden `.githooks/commit-msg`-Trägers, dessen gesamte Commit-Historie `Rolle Implementer:`
trägt (`git log --format='%s' -- .githooks/commit-msg harness/tools/commit-msg-traceability.sh`).
**Zielort:** `.githooks/pre-commit` (neu anzulegen, `.githooks/` existiert bereits mit
`commit-msg` als Nachbar) plus die zugehörige Prüfung unter `harness/tools/` (Namensgebung Sache
des Implementers, analog `commit-msg-traceability.sh`).

**ADR: nicht nötig — ein künftiger `MR-<NNN>`-Eintrag trägt die Dokumentation, sobald der Hook
existiert.** Baseline-Regelwerk `modul-13-quality-gates.md` §Guard-Härtung verlangt einen neuen
`MR-<NNN>` für die **Härtung** eines *bestehenden* Wächters — dieser Hook härtet keinen
vorhandenen, er ist neu. Trotzdem trägt er keine Architektur-Entscheidung im ADR-Sinn: Er ändert
keine Komponenten-/Sequenzsicht, keine Technik-Festlegung und keine Baseline-Abweichung. Er ist,
wie der `commit-msg`-Hook selbst
([`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)),
eine Erweiterung des Durchsetzungsschicht-Artefakt-Sets um einen weiteren git-nativen Hook neben
dem Claude-Hook-Kanal — dieselbe Klasse wie `commit-msg`, nur eine andere Sorge (dort
Traceability-Kennung, hier Index-Sauberkeit gegen `--amend`). Der richtige Träger für diese
Erweiterung ist ein **neuer `MR-<NNN>`-Eintrag** im Adaptions-Block, geschrieben vom **Architect**
(`AGENTS.md` §3.8) — aber erst, **wenn** der Hook geliefert ist: vorher gibt es nichts zu
dokumentieren, und ein vorab geschriebener Eintrag beschriebe ein Artefakt, das noch nicht
existiert. Dieser Slice trägt den MR-Eintrag als eigenen Folge-Schritt (Architect-Übergabe nach
Implementer-Lieferung), nicht als Teil dieses Verdikts.

## 2. Definition of Done

- [x] Ein Träger (`.githooks/pre-commit`-Hook, siehe Architect-Verdikt oben) hält `--amend` gegen
      fremde Index-Einträge ab. *(Rot-Kommando: zwei parallele Vorgänge simulieren — ein eigener
      Commit, danach ein fremder Datei-Stage, dann `--amend` — ohne Träger reißt der Amend den
      fremden Stand mit; mit Träger schlägt er an oder verhindert das Mitreißen.)* Real gefahren an
      einem konstruierten Repo, alle drei Beleg-Muster der Beobachtung nachgestellt (eigener Commit
      + parallel gestagte fremde Datei + `--amend`; sowie der dritte Beleg — Amend trifft einen
      zwischenzeitlich fremd gewordenen HEAD): ohne Träger reißt `--amend` die fremde Datei mit
      (Exit 0, `git show --name-only HEAD` listet sie), mit Träger bricht der Commit ab (Exit 1,
      HEAD unverändert, fremder Pfad bleibt gestaged) — der Fluchtpunkt
      `AMEND_EXPECTED_PATHS="<pfad>"` lässt einen bewusst erweiterten Amend durch.
- [x] Zielort und schreibende Rolle bestätigt der Architect (§3.8). — Siehe §1 *Architect-Verdikt*:
      Träger `.githooks/pre-commit` + `harness/tools/`, schreibende Rolle Implementer, kein
      ADR-Bedarf, MR-Eintrag folgt nach Lieferung (Architect-Übergabe).
- [x] `make gates` grün. — Working-Tree-Hash `0a22d05ba9feb07ce2e855536ba76ebd96b9432fa792a3704184865f1a05b7ca`
      (`.harness/state/gates-passed.diffsha`, deckungsgleich mit
      `bash harness/tools/working-tree-hash.sh`).
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor. —
      [`docs/reviews/2026-09-28-slice-amend-haelt-den-index-pfadrein.md`](../../../reviews/2026-09-28-slice-amend-haelt-den-index-pfadrein.md)
      (0 HIGH, 2 MEDIUM behoben in `c08ad58e`, 3 LOW, 3 INFO — nicht merge-blockierend).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag. — siehe §7.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben. — siehe §7.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.githooks/pre-commit` (neu) + zugehörige Prüfung unter `harness/tools/` | neu | Träger des Hooks — Architect-Verdikt §1, Implementer-Artefakt analog `.githooks/commit-msg` |
| [`harness/README.md`](../../../../harness/README.md) §Sensors/Werkzeuge oder §Traceability | update | Doku-Pflicht bei neuem Werkzeug/Träger — analog der bestehenden `commit-msg`-Tabelle |
| `test/pre-commit-amend-guard.bats` + `test/mutations/497-pre-commit-amend-guard-blankoscheck.sh` | neu | Zähne für die reinen Funktionen `has_amend_flag()`/`decide()` (bats-Image ohne `git`, dieselbe Trennung wie `history-range-guard.sh`), plus der rot färbende Mutations-Fall (AGENTS.md §3.6/§19) |
| `Makefile` (`shell-lint`-Rezept) | update | `.githooks/pre-commit` fehlte in der geprüften Dateiliste — `commit-msg` stand dort schon namentlich |
| [`docs/plan/planning/in-progress/roadmap.md`](roadmap.md) | update | Ruhe-Marker „Nichts in Arbeit" entfernt — dieser Slice liegt jetzt in `in-progress/` (Plan-Defekt-Rücksprung 16→13, beim `make gates`-Lauf gefunden, `d-check`-Befund `planning-drift`) |
| `harness/conventions/MR-<NNN>-…` (neu, **nach** Lieferung, Architect) | neu, Folge-Schritt | Dokumentiert die Hook-Erweiterung des Durchsetzungsschicht-Artefakt-Sets — Architect-Verdikt §1 |

## 4. Trigger

**Start** (`next` → `in-progress`): Priorisierung durch den Planner.

**Rückführungen:**

- `in-progress` → `next` (zu groß): wenn der Hook-Weg eine neue Wächter-Klasse in der
  Durchsetzungsschicht braucht, die über einen einzelnen Slice hinausgeht.
- `in-progress` → `open` (blockiert): wenn kein Träger ohne Gate-Senkung baubar ist.

## 5. Closure-Trigger

DoD vollständig, Review ohne blockierenden Befund, Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- Der Hook-Weg wirkt nur, wo `make hooks-install` gelaufen ist (dieselbe Grenze wie beim
  `commit-msg`-Träger, [`harness/README.md`](../../../../harness/README.md) §Traceability).
  **Ausgang:** weiter offen — neue Registerzeile
  [`BEO-ALL/traeger-wirkt-nur-nach-lokaler-aktivierung`](../observations/BEO-ALL/traeger-wirkt-nur-nach-lokaler-aktivierung/observation.md)
  (1. Beleg).
- Die Disziplin-Form wirkt nur, wo der Rollen-Anweisungssatz gelesen wird. **Ausgang:** entfallen —
  das gelieferte Artefakt ist der Hook, nicht die Disziplin-Form (Architect-Verdikt §1); das Risiko
  war an die verworfene Alternative gebunden und trifft das gelieferte Artefakt nicht. Es bleibt hier
  als benannte Grenze der verworfenen Option stehen, ohne eigenen Registereintrag — es beschreibt
  keine Eigenschaft dessen, was gebaut wurde.

## 7. Closure-Notiz

- **Was hat funktioniert:** Der Architect-Verdikt lag als Plan-Artefakt vor dem ersten
  Implementer-Commit vor (Träger, Zielort, schreibende Rolle, ADR-Frage — alle vier vorab
  entschieden) und wurde im Diff nicht angetastet (Review-Negativbefund). Der DoD-Rot/Grün-Beleg für
  den korrektheitskritischen Punkt (Träger hält `--amend` ab) wurde real an einem konstruierten
  Repo gegen alle drei Beleg-Muster der Beobachtung gefahren, nicht nur behauptet. Review fand 0
  HIGH; beide MEDIUM (F-1, F-2) wurden vom Implementer selbst vor der Verifikation behoben
  (`c08ad58e`).
- **Was ging anders als geplant:** Zwei Vollständigkeits-Lücken (F-1: Exec-Bit-Probe in
  `make hooks-install` nicht auf den neuen Hook nachgezogen; F-2: Werkzeuge-Doku blieb bei der
  Einzelzweck-Beschreibung von `commit-msg` fixiert) hätten den Träger lautlos unwirksam lassen
  können, wären sie nicht gefunden worden — derselbe Effekt, gegen den dieser Slice selbst antritt,
  nur eine Ebene tiefer (ein Nachbar-Mechanismus statt der eigentliche Träger). Beide sind behoben.
- **Steering-Loop-Eintrag:** neuer git-eigener Träger `.githooks/pre-commit` ergänzt das
  Durchsetzungsschicht-Artefakt-Set neben `commit-msg` (dieselbe Klasse wie
  [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks))
  — liegt in `.githooks/pre-commit`. Auslöser:
  `BEO-ALL/amend-committet-fremde-index-eintraege-mit` (Konsistenz-Review 2026-09-15,
  `slice-174-archivierung-emittieren`,
  `slice-d-check-pin-bringt-links-lookahead-und-referenz-definitionen` — 3×).
  **Offene Übergabe an den Architect:** Die zugehörige Adaptions-Block-Dokumentation
  (`harness/conventions/MR-<NNN>-…`, analog `MR-002`) ist laut Architect-Verdikt (§1) ein
  eigenständiger Folgeschritt **nach** dieser Lieferung und wurde in diesem Slice bewusst nicht
  mitgeliefert — sie ist kein DoD-Punkt dieses Slice. Der Registereintrag
  `BEO-ALL/amend-committet-fremde-index-eintraege-mit` steht deshalb auf `verkörpert` (der Träger
  existiert und wirkt), nennt die offene Adaptions-Block-Dokumentation aber ausdrücklich in seiner
  `state.md`. Diese Übergabe hängt an keinem Slice-Plan — sie ist direkte Architect-Schreibarbeit an
  `harness/conventions.md`/`harness/conventions/` nach `AGENTS.md` §3.8, kein Rollenwechsel, der
  einen neuen Slice bräuchte.
- **Beobachtungs-Register (`../observations/`):**
  - `BEO-ALL/amend-committet-fremde-index-eintraege-mit`: `state.md` von `geplant` auf `verkörpert`
    gehoben (Zielort `.githooks/pre-commit`, Herkunfts-Anker `· seit
    slice-amend-haelt-den-index-pfadrein`, im Ziel selbst vom Implementer bereits geschrieben).
  - `BEO-ALL/traeger-wirkt-nur-nach-lokaler-aktivierung` neu angelegt, Beleg
    `evidence/slice-amend-haelt-den-index-pfadrein.md` (Risiko 1 aus §6 — Zähler steht bei 1×).
  - `BEO-ALL/zweiter-fall-eines-mechanismus-laesst-begleitstellen-fixiert` neu angelegt, Beleg
    `evidence/slice-amend-haelt-den-index-pfadrein.md` (Review-Finding-Klasse F-1/F-2/F-4, in
    diesem Vorgang als **eine** Gelegenheit gezählt und im selben Slice behoben — Zähler steht bei
    1×).
- **Folge-Slices:** keine mit diesem Slice angelegt.
- **Risiken aus §6:** Risiko 1 (Hook wirkt nur nach `make hooks-install`) *weiter offen* →
  `BEO-ALL/traeger-wirkt-nur-nach-lokaler-aktivierung` · Risiko 2 (Disziplin-Form wirkt nur wo
  gelesen) *entfallen* — Begründung siehe §6, die verworfene Alternative wurde nicht gebaut.
- **Drei Paarungen:** Anker — `.githooks/pre-commit` und
  `harness/tools/pre-commit-amend-guard.sh` tragen `seit slice-amend-haelt-den-index-pfadrein`
  wörtlich (vom Implementer bereits geschrieben, geprüft per `grep`), Paarung getragen. ·
  Folge-Slice — keiner genannt, keine Prüfung nötig. · Register — alle drei zitierten
  Beobachtungen (`amend-committet-fremde-index-eintraege-mit`,
  `traeger-wirkt-nur-nach-lokaler-aktivierung`,
  `zweiter-fall-eines-mechanismus-laesst-begleitstellen-fixiert`) existieren als Verzeichnis und
  tragen je mindestens einen Beleg unter `evidence/`; geprüft nach dem `git mv`.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührte Sub-Area `*`; Schwelle erfüllt.

**Vorgelagert — offene Beobachtungen sichten:**
[`BEO-ALL/amend-committet-fremde-index-eintraege-mit`](../observations/BEO-ALL/amend-committet-fremde-index-eintraege-mit/observation.md)
(3 Belege, Stand `geplant`, dieser Slice) ist der Auslöser selbst.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF.
