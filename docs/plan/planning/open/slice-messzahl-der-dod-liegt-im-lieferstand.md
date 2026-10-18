# Slice slice-messzahl-der-dod-liegt-im-lieferstand: Eine Messzahl der DoD liegt bei der Übergabe im Baum

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt — eines von
`open/`, `next/`, `in-progress/`, `done/`. Er wechselt nur durch `git mv`, siehe Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Eine Closure-Bedingung über die DoD hinaus gibt es nicht
(`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:** [`MR-089`](../../../../harness/conventions.md#mr-089) (Form der Laufzeit-Aussage) ·
[`AGENTS.md`](../../../../AGENTS.md) §6 Schritt 8 (Handoff an Reviewer und Verifier). Ein `LH-*`-Element deckt den
Gegenstand nicht: es ist Prozess-Regel des Repos.

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-18.

---

## 1. Ziel und Abgrenzung

**Ziel:** Verlangt ein DoD-Punkt eine Messzahl im Lieferstand, steht sie bei der Übergabe an Review und Verifier im
Baum — in einer Commit-Message des Implementers oder in einer Datei des Lieferstands — mit Kommando, Lage und Variante,
sodass der Verifier sie gegen seine eigene Messung hält. Der Slice entscheidet den Ort und ob ein Sensor baubar ist oder
die Grenze benannt wird. Auslöser:
[`BEO-ALL/messzahl-der-dod-liegt-bei-der-uebergabe-nicht-im-baum`](../observations/BEO-ALL/messzahl-der-dod-liegt-bei-der-uebergabe-nicht-im-baum/observation.md)
(`slice-java-skelett`, `slice-python-skelett`, `slice-csharp-skelett` — 3×).

**Ausdrücklich NICHT in diesem Slice:**
- **Die Wahrheit der Zahl.** Ob eine Messzahl stimmt, hält kein Sensor; der Slice entscheidet nur, wo sie bei der Übergabe
  steht. Die Form der Aussage trägt [`MR-089`](../../../../harness/conventions.md#mr-089).
- **Die Kaltlauf-Messung** — ungemessen und mit eigenem Eintrag
  ([`BEO-ALL/kosten-einer-emittierten-pruefung-im-ziel-ungemessen`](../observations/BEO-ALL/kosten-einer-emittierten-pruefung-im-ziel-ungemessen/observation.md)).
- **Der Text der Anweisung und der Hard Rule selbst.** Ein Anweisungssatz gehört der Rolle, die ihn ausführt
  ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)), eine Hard Rule dem Architect
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8): der Slice liefert die Entscheidung und gibt den Text an die schreibende Rolle ab.

## 2. Definition of Done

- [ ] Der Ort der Zahl bei der Übergabe ist entschieden und in dem Anweisungssatz der ausführenden Rolle benannt;
      die Übergabe-Vorlage des Implementers (Handoff) nennt Kommando, Lage und Variante als Felder.
- [ ] Ein Sensor, der das Fehlen der Zahl im Baum färbt, steht und ist einmal rot gesehen — oder die Grenze steht
      benannt am Ort der Regel, mit dem Satz, dass kein Sensor sie hält ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`), kein Self-Review.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen, nach dem Move geprüft, §7.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.claude/commands/implement-slice.md` | update (Implementer) | Ort der Zahl und Handoff-Felder |
| Hard-Rule- oder Sensor-Träger | ggf. neu | Architect-Artefakt bzw. Sensor, je nach Entscheidung; eigener Commit |

## 4. Trigger

**Start** (`next` → `in-progress`): WIP-Slot frei; die Beobachtung steht mit dem Ausgang *geplant*.

**Rückführungen — vorab benennen:**
- `in-progress` → `next`: Ort und Sensor brauchen mehr als die zwei Liefer-Punkte — zurück zur Zerlegung.
- `in-progress` → `open`: die Entscheidung berührt eine Hard Rule und braucht zuerst eine ADR — Architect.

## 5. Closure-Trigger

DoD vollständig, Closure-Notiz mit Lerneintrag; der Ausgang der Beobachtung wechselt dort auf *verkörpert* mit
Zielort und Anker.

## 6. Risiken und offene Punkte

- Ein Sensor über Commit-Messages braucht einen Plan-Parser (welche DoD verlangt eine Zahl) und ist nicht baubar —
  **Ausgang:** bei der Closure; dann steht die Grenze statt des Sensors.

## 7. Closure-Notiz

<!-- Erst bei der Closure füllen. -->

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (`ALL`); der Slice berührt Anweisungssatz und Planungs-Text, für die die
Modus-Deklaration keine eigene Sub-Area führt.

**Vorgelagert — offene Beobachtungen sichten** (gelesen 2026-10-18):
`messzahl-der-dod-liegt-bei-der-uebergabe-nicht-im-baum` — 3, geplant; dieser Slice ist der Ausgang ·
`kosten-einer-emittierten-pruefung-im-ziel-ungemessen` — 7, verkörpert ([`MR-089`](../../../../harness/conventions.md#mr-089)).

**Modus:** alle berührten Sub-Areas GF.
