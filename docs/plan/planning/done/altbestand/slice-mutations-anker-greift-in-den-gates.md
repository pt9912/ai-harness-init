# Slice slice-mutations-anker-greift-in-den-gates: Ob ein Mutations-Fall greift, prüft `make gates`

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt — eines von
`open/`, `next/`, `in-progress/`, `done/`. Er wechselt nur durch `git mv`, siehe Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — keine Closure-Bedingung jenseits der eigenen DoD.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
[`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
§Grenze · Gate-*Anheben*, kein ADR ([`AGENTS.md`](../../../../AGENTS.md) §3.5). Auslöser: Auftrag des
Auftraggebers vom 2026-10-09 auf Frage (2) des Verdikts
`2026-10-08-welle-handbuch-zeigt-den-bestand-architect-verdikt`.

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-10-09.

---

## 1. Ziel und Abgrenzung

**Ziel:** Ein billiger Modus von `harness/tools/mutate.sh` läuft in `make gates` und prüft je Fall nur,
ob die Mutation greift — jede Datei aus `# files:` ändert sich auf einer Kopie —, ohne Grün-Vorlauf
und ohne Testlauf; ein von einer berechtigten Änderung entwaffneter Anker fällt damit am Commit statt
im Nacht-Lauf.

**Ausdrücklich NICHT in diesem Slice:**

- Zeilennummern-Anker (`BEO-ALL/mutations-fall-an-zeilennummer-verankert`) — ein solcher Anker ändert
  immer etwas. Die Schwelle bleibt die des Treibers (*jede Zieldatei ändert sich*); eine schärfere setzt
  [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand) nicht.
- Der Nachfolge-Eintrag zu [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand) §Grenze — Norm-Artefakt, schreibt der Architect
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8); dieser Slice liefert die Übergabe.
- Reparatur von Fällen, die der Modus auf HEAD als entwaffnet meldet — Bestand mit eigenem Befund;
  dafür steht die Rückführung in §4.
- Ein zweites Skript — zwei Fassungen derselben Greift-Prüfung liefen auseinander.
- Brüche an `# files:` und `# expect:` — die zwei Nachbar-Klassen des Registers, anderer Vorgang.

## 2. Definition of Done

- [x] Greift-Modus in `harness/tools/mutate.sh` (Bedingung 2 des Treibers,
      `grep -n 'nicht gegriffen' harness/tools/mutate.sh`): je Fall Kopie der `# files:`, Patch
      anwenden, jede Datei geändert — sonst Exit ≠ 0 mit Fallname; kein Grün-Vorlauf, kein Testlauf,
      kein Beleg-Slot. In `make gates` verdrahtet, Zeile in `harness/README.md` §Sensors, Vertrag und
      Grenze in `harness/sensors/mutate.md`; Laufzeit-Zuwachs von `make gates` gemessen.
- [x] Rot an der realen Quelle: die Fälle `29-roadmap-nicht-neutralisiert` und
      `247-archive-welle-go-schalter-erreicht-zweig-nicht` in der Fassung `98bfab0b^` gegen den
      heutigen Quellbestand → rot, Meldung nennt den Fall (gelesen); HEAD grün. Ein bats-Fall hält beide
      Richtungen ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [x] Übergabe an den Architect liegt vor: Nachfolge-MR zu [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand) §Grenze mit Kopf-Marke
      ([`MR-032`](../../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger))
      — der Satz *„Kein Sensor hält die Anlage"* ist mit dem Modus falsch; Sensor und Grenze benannt.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`), kein Self-Review.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — oder in §7 notiert, dass keine Beobachtung anfiel.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) hier geprüft (ohne Wellen-Betrieb).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/mutate.sh` | update | Greift-Modus als Schalter des bestehenden Treibers |
| `Makefile` | update | Ziel des Modus, Abhängigkeit von `gates` |
| `harness/README.md`, `harness/sensors/mutate.md` | update | Gate-Zeile; Vertrag und Grenze |
| `test/mutate-driver.bats` | update | Rot (Fälle 29/247 aus `98bfab0b^`) und Grün (HEAD) |
| `test/mutations/<neu>` | neu | Zahn auf den Greift-Modus selbst |

## 4. Trigger

**Start** (`next` → `in-progress`): WIP-Slot frei; priorisiert am 2026-10-09.

**Rückführungen:**

- `in-progress` → `next`: der Modus braucht je Fall Isolationskopie oder Container, und `make gates`
  wächst dadurch spürbar (über eine Minute) — dann Schnitt neu.
- `in-progress` → `open`: der erste Lauf meldet auf HEAD entwaffnete Fälle — deren Reparatur zuerst,
  als eigener Vorgang, dann der Gate-Anschluss.

## 5. Closure-Trigger

DoD vollständig, Rot (Fassung `98bfab0b^`) und Grün (HEAD) belegt, Übergabe beim Architect,
Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Fälle, deren Patch nicht allein über die `# files:` wirkt, passen nicht in die Kopie-Prüfung —
  **Ausgang:** *entfallen* — `make mutate-greift` → `624 Fall/Faelle, 624 greifen, 0 Befund(e)`
  (Verifikation); kein Fall des Bestands fällt aus der Kopie-Prüfung.
- Der Modus läuft im Gate-Pfad; ob er ohne Container auskommt, ist an [`AGENTS.md`](../../../../AGENTS.md)
  §3.9 zu messen — **Ausgang:** *entfallen* — der Modus läuft ohne Container, §3.9 ist nicht
  verletzt (Review M-3); die GNU-Abhängigkeit (`sed -i`, `mktemp -d -p`) ist als Grenze in
  [`MR-090`](../../../../harness/conventions.md#mr-090) und `harness/sensors/mutate.md` benannt.
  Eine Frage an §3.9 entsteht erst mit einem zweiten Gate-Rezept ohne Container; ein
  Register-Eintrag trägt sie nicht (Verdikt `2026-10-09-slice-mutations-anker-greift-in-den-gates-architect-verdikt`).

## 7. Closure-Notiz

- **Was hat funktioniert:** Der Greift-Modus fand beim ersten Lauf auf HEAD zwei entwaffnete Fälle
  (145/147) außer den Fixtures 29/247 — der reale Fall, für den er gebaut ist. Laufzeit
  `real 0m17,155s`, unter der Schwelle aus §4.
- **Was ging anders als geplant:** **Abweichung vom Plan (Review M-4).** Die Reparatur von 145/147
  (`9fbc304c`) lief gegen §1 Punkt 3, und die Rückführung `in-progress → open` aus §4 wurde nicht
  gezogen. Entschieden hat das der Orchestrator mit Verweis auf
  [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand);
  die Begründung trägt nicht, weil der Eintrag die Anlage regelt und Bestand und Treiber ausschließt.
  Folge: eine Out-of-Scope-Grenze verschob sich ohne Plan-Diff und ohne Übergabe-Artefakt an den
  Planner; die Reparatur selbst ist inhaltlich gedeckt (Review L-1 ausgenommen, Fall 145 mutiert
  breiter als sein Kopf).
- **Steering-Loop-Eintrag:** neuer Sensor — `make mutate-greift` in `make gates`, Vertrag in
  [`MR-090`](../../../../harness/conventions.md#mr-090); dazu verkörpert:
  `BEO-ALL/teilzeichenketten-suche-bindet-einen-pfad-nicht-an-seine-grenze` — liegt in
  `.harness/skills/reviewer.md` (Eintrag *„Zugehörigkeit per Teilzeichenkette statt per Grenze"*),
  `seit slice-mutations-anker-greift-in-den-gates`.
- **Beobachtungs-Register ([`../observations/`](../observations/README.md)):** je ein Beleg
  `evidence/slice-mutations-anker-greift-in-den-gates.md` in
  `mutations-fall-wird-von-berechtigter-aenderung-entwaffnet` (I-2; verkörpert, Trigger des Eintrags
  im Sensor-Eintrag entschieden) · `plan-abweichung-landet-im-commit-bericht-statt-im-plan` (M-4;
  verkörpert) · `mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere` (L-1; verkörpert) ·
  `gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang` (I-1; geplant) ·
  `teilzeichenketten-suche-bindet-einen-pfad-nicht-an-seine-grenze` (M-2; 3×, Ausgang *verkörpert*
  nach Architect-Verdikt). Benannt, nicht gezählt: M-1 (Zahn fährt nicht die Verdrahtung
  `--greift`), M-3 (GNU-Werkzeuge im Gate-Pfad), L-2 (Übergabe-Grenze unvollständig) — keine
  passende Klasse.
- **Folge-Slices:** keine.
- **Risiken aus §6:** beide *entfallen* (§6).
- **Paarungen geprüft am 2026-10-09:** (a) Anker — `grep -c "seit slice-mutations-anker-greift-in-den-gates" .harness/skills/reviewer.md` → 1; (b) Folge-Slice — keiner genannt; (c) Register — die fünf genannten `BEO-ALL/<slug>/` existieren, `ls …/evidence/*.md | wc -l` → 8 · 8 · 7 · 4 · 3.
- **Archivierung:** entfällt — das Unterkommando `archive-slice`
  ([`MR-078`](../../../../harness/conventions.md#mr-078--wellenlose-slices-werden-bei-der-eigenen-closure-archiviert))
  ist nicht gebaut; die Wellen-Closure sammelt den Slice ein (Rückfall dort).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (`ALL`) und `harness/tools/` (`TOOLS`), beide in
`harness/conventions.md` §Modus-Deklaration geführt.

**Vorgelagert — offene Beobachtungen sichten** (Zähler je
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`, gelesen 2026-10-09, keine
Erwartungswerte):
[`mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`](../observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/observation.md)
— 7, verkörpert in [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand), seit der Verkörperung 2 von 3; dieser Slice ist die Sensor-Antwort ·
`mutations-fall-an-zeilennummer-verankert` — 1, offen, die Grenze des Modus ·
`mutations-fall-zeigt-auf-falsche-datei` — 2, offen, nicht gedeckt ·
`neuer-waechter-ohne-mutations-fall` — 19, geplant; der Modus ist ein neuer Wächter und bekommt
seinen Fall (§3).

**Modus:** alle berührten Sub-Areas GF.
