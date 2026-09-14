# Slice slice-ortswechsel-zieht-sein-zustandsfeld-nach: Der Ortswechsel zieht sein Zustandsfeld nach

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Begründet gegen die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird):
(1) **Bündel?** Nein — eine Regel-Klasse, ihr Träger und ihr Zahn landen zusammen oder gar nicht.
(2) **Gemeinsames Closure-Kriterium?** Nein — jedes denkbare wäre die Abschrift der DoD. (3) **Reaktiv
oder gewollt?** **Reaktiv:** Auslöser ist eine Beobachtung über der Register-Schwelle, nicht der
Wunsch nach einer Fähigkeit. Damit **nicht** in der Roadmap geführt
([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2) — der Zustand ist das Verzeichnis.

**Bezug:** [`AGENTS.md`](../../../../AGENTS.md) §3.3 (Move und Inhalt sind zwei Commits),
[`AGENTS.md`](../../../../AGENTS.md) §3.11 (die Nachbar-Klasse *Adresse* und ihre Linie: gebunden
ist die Eigenschaft, nicht der Baum), [`AGENTS.md`](../../../../AGENTS.md) §3.7
(Zustandsfelder tragen Zustand und Beleg, nicht die Chronik),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert).

**Berührte Spec-Stellen:** `—`. Der Slice schreibt eine Harness-Regel; er berührt keine
Spec-Stelle.

**Verantwortlich:** — bis zur Priorisierung.

**Autor:** Planner. **Datum:** 2026-09-14.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Ziel:** Der Schritt, der ein bewachtes Zustandsfeld nach einem vom Prozess vorgeschriebenen
Ortswechsel nachzieht, steht an **einem** Norm-Artefakt — oder seine fehlende Trägerschaft steht
dort benannt.

Zwei Nachbarn derselben Ursache tragen je einen Zielort: die **Verweise** auf die bewegte Datei in
`make slice-mv` (`seit slice-144`), die **Adresse** in einem einfrierenden Artefakt in
[`AGENTS.md`](../../../../AGENTS.md) §3.11 (`seit welle-15`). Die dritte Hälfte — ein Zustandsfeld,
das ein Sensor bereits bewacht und das der Move falsch macht — hat keinen: Der Sensor aus
`slice-125` macht den Fehlschlag laut (Grund-Code `planning-drift`), er schreibt den
Ausgleichs-Schritt aber nicht vor. Der Beleg steht in
[`BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
(20 Belege).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die zwei Nachbar-Hälften (Verweise, Adresse).** Sie tragen ihren Zielort bereits; sie hier
  mitzunehmen wäre ein anderer Vorgang und würde zwei benannte Regeln überschreiben, statt die
  dritte zu schreiben.
- **Ein Umbau der Roadmap-Struktur.** Der Ruhe-Marker ist eine von mehreren Zustandsfeld-Formen;
  ihn zu verschieben wäre ein anderer Vorgang, der die Vorschrift selbst ändert, nicht ihre
  Nachführung.
- **Der Bestand.** Falsch stehende Zustandsfelder werden nicht rückwirkend geräumt; gebunden ist
  der Move, der geschrieben oder geplant wird (§3.11 für die Adress-Klasse, hier für das
  Zustandsfeld).

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als einer mit vier
erfundenen; die vier Klassen sind ein Suchraster, keine Ausfüll-Liste.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und gehört zurück zur
Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die Gate-Läufe und die fünf
Closure-Pflichten darunter zählen nicht mit.

- [ ] Die Regel steht an **einem** Norm-Artefakt: ein Ortswechsel zieht die Zustandsfelder nach, die
      er in einem lebenden Artefakt falsch macht, und **nennt den Schritt**, der es tut.
- [ ] Der Schritt ist verdrahtet — im Träger `make slice-mv` oder in einem benannten Nachfolger —
      **oder** seine fehlende Trägerschaft steht als Abschnitt am Zielort benannt; ein Wächter, der
      nur den Fehlschlag meldet, ohne den Ausgleich zu nennen, genügt nicht.
- [ ] Rot gesehen: eine Probe mit falschem Ruhe-Marker färbt den benannten Träger rot **oder** die
      Zusage ist auf das eingeschränkt, was der Lauf hält ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8, nicht die Antwort.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`AGENTS.md`](../../../../AGENTS.md) §3 | update | Die Hard Rule, die die Nachbar-Klasse trägt, nimmt die Zustandsfeld-Hälfte auf oder verweist auf einen eigenen Träger |
| [`harness/tools/slice-mv.sh`](../../../../harness/tools/slice-mv.sh) / `make slice-mv` | update | Träger des Moves; hier lebt der Ausgleichs-Schritt, wenn er mechanisch ist |
| [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) | update | Grenze der Sensor-Hälfte, die den Fehlschlag meldet, aber nicht ausgleicht |
| [`test/`](../../../../test) | neu | Rot-Beleg über einer Probe mit falschem Ruhe-Marker |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Priorisierung durch den Planner.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Regel den Move-Träger **und** die
  Sensor-Hälfte zugleich umbaut, statt den Schritt zu benennen.
- `in-progress` → `open` (blockiert — Carveout?): wenn der Ausgleichs-Schritt nur über eine Senkung
  am `planning`-Modul erreichbar wäre ([`AGENTS.md`](../../../../AGENTS.md) §3.5).

## 5. Closure-Trigger

DoD vollständig, Review ohne blockierenden Befund, Closure-Notiz geschrieben, Beleg des roten
Gegenbeispiels im Repo.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst.

- Die Regel bleibt ohne Zahn und wäre dann wieder nur Text — **Ausgang:** weiter offen →
  `BEO-ALL/benannte-luecke-ohne-ausgang` im Register.
- Der Ausgleichs-Schritt greift nur für ein Feld, während die Klasse mehrere Formen hat —
  **Ausgang:** weiter offen → `BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register · `grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln.

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung.

**Vorgelagert — Sub-Area-Wahl prüfen:** Die berührte Sub-Area ist `*` (gesamtes Repo), deklariert in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area); sie
erfüllt die Schwelle (Artefakt-Achse `AGENTS.md`, Pfad-Achse `harness/tools/` und `test/`,
Vorgangs-Achse Slice-Closure).

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen; die berührte Sub-Area `*`
trägt den Treffer
[`BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
mit dem Stand über der Schwelle — er **ist** der Gegenstand dieses Slice. Kein weiterer Treffer
erreicht die Schwelle.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF
([`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)).
