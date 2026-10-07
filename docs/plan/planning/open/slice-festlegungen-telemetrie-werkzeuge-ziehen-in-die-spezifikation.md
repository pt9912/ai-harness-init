# Slice slice-festlegungen-telemetrie-werkzeuge-ziehen-in-die-spezifikation: Was die Telemetrie-Werkzeuge messen, steht in der Spezifikation

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD dieses Slice; Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`ADR-0078`](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) (Festlegung 3, Zeile Welle 158),
[`MR-075`](../../../../harness/conventions.md#mr-075).

**Berührte Spec-Stellen:** `spezifikation.md §7` (*Festlegungen der Harness-Werkzeuge*); `spezifikation.md §1`,
wenn die Inventur eine Verfeinerung liefert; `spezifikation.md §8` (Historie-Zeile).

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-07.

---

## 1. Ziel und Abgrenzung

**Ziel:** Jede Randform-Festlegung aus `harness/sensors/span-report.md`, `harness/sensors/hook-overhead.md`, `harness/tools/span-check.sh`, `harness/tools/hook-overhead.sh`, `harness/tools/agent-watch.sh` steht in der Spezifikation — als Verfeinerung in
§1, wenn das Werkzeug genau eine Anforderung durchsetzt, sonst als Zeile in §7 *Festlegungen der
Harness-Werkzeuge*; die Quelle trägt statt der Festlegung einen Rang-Zeiger dorthin. Der Slice ist
eine Werkzeug-Gruppe der Inventur, die `slice-werkzeug-festlegungen-ziehen-in-die-spezifikation` nach
Review-Größe abgegeben hat.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Werkzeuge der anderen Gruppen.** *Anderer Gegenstand:* je Gruppe ein eigener Slice mit der
  Kennungs-Form `slice-festlegungen-<gruppe>-ziehen-in-die-spezifikation`; geschnitten, damit ein
  Review den Umzug in einer Sitzung prüft.
- **Gliederung §7/§8, Aufnahme-Regel, emittierte Kommentare.** *Bestand bleibt stehen:* geliefert
  von `slice-werkzeug-festlegungen-ziehen-in-die-spezifikation`.
- **Form der Sensor-Datei.** *Folge-Slice:*
  [`slice-222`](slice-222-sensor-datei-traegt-die-form-ihrer-vorlage.md).
- **`Accepted`-ADRs.** *Bestand bleibt stehen:* [`AGENTS.md`](../../../../AGENTS.md) §3.4; trägt eine
  Festlegung nur eine ADR, greift die Rückführung nach `open` (§4).

## 2. Definition of Done

- [ ] **1 — Inventur:** jede Randform-Festlegung aus den Quellen in §3 ist mit Ziel (§1-Verfeinerung
      oder §7-Zeile) in §3 dieses Plans gelistet, bevor umgezogen wird.
- [ ] **2 — Spezifikation:** jede gelistete Festlegung steht als Zeile mit `SPEC-<NNN>` und Spalte
      `Präzisiert` ([`MR-075`](../../../../harness/conventions.md#mr-075)) in §7 oder als Verfeinerung
      in §1; §8 trägt eine Historie-Zeile.
- [ ] **3 — Rang-Zeiger:** jede Quelle nennt statt der Festlegung ihre Zeile in der Spezifikation.
      **Rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6) für den Sensor, den der Implementer als
      Träger nennt — oder die Lücke benannt, wo keiner urteilt.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die nächste Welle-Closure (das Repo fährt Wellen).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `spec/spezifikation.md` §7 (§1, §8) | update | Liefer-Punkt 2 |
| `harness/sensors/span-report.md`, `harness/sensors/hook-overhead.md`, `harness/tools/span-check.sh`, `harness/tools/hook-overhead.sh`, `harness/tools/agent-watch.sh` | update | Festlegung raus, Rang-Zeiger rein (Liefer-Punkt 3) |

## 4. Trigger

**Start** (`next` → `in-progress`): `slice-werkzeug-festlegungen-ziehen-in-die-spezifikation` liegt in
`done/` (Gliederung und Aufnahme-Regel stehen); WIP-Limit frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: Die Inventur ergibt mehr Umzüge, als eine Review-Sitzung prüft — dann wird
  die Gruppe je Quelle geteilt; die Inventur bleibt hier.
- `in-progress` → `open`: Eine Festlegung lässt sich weder genau einer Anforderung noch §7 zuordnen,
  ohne eine `Accepted`-ADR zu berühren — Übergabe an den Architect.

## 5. Closure-Trigger

1. Die Inventur liegt in §3 vor, und keine gelistete Festlegung steht mehr allein in einer Quelle
   dieser Gruppe.
2. `make docs-check` ist grün.

**Lerneintrag** in einer der drei Formen, §7; die Closure schreibt der Planner
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

- **Rang-Zeiger nennt eine Festlegung, deren Zweifelsregel anders entscheidet** — beim Umzug
  divergieren Quelle und Spezifikation;
  `rang-zeiger-nennt-eine-festlegung-deren-zweifelsregel-anders-entscheidet` im Register.
  — **Ausgang:** offen bis zur Closure.
- **Festlegung und Rumpf nennen verschiedene Reichweiten** —
  `festlegung-und-ihr-rumpf-nennen-verschiedene-reichweiten` im Register. — **Ausgang:** offen bis
  zur Closure.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `*` (Spezifikation, `harness/sensors/`) und `TOOLS` (Skriptköpfe in `harness/tools/`); `CODEX` nicht.

**Vorgelagert — offene Beobachtungen sichten:** Register am gemergten Stand gesichtet, nach
Gegenstand; Zähler `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`: die zwei
Einträge aus §6. Für `TOOLS` kein Eintrag — alle Beobachtungen führen `*`.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
