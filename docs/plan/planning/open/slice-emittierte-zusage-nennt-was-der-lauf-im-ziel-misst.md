# Slice slice-emittierte-zusage-nennt-was-der-lauf-im-ziel-misst: Eine emittierte Zusage nennt, was der Lauf im Ziel misst — und was nicht

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — der Closure-Trigger wäre die Abschrift der eigenen DoD.

**Bezug:** [`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung), [`LH-FA-12`](../../../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren) (Scope), [`AGENTS.md`](../../../../AGENTS.md) §3.6.

**Berührte Spec-Stellen:** [`LH-FA-12`](../../../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren) — Spalte *Kurzbeschreibung* der erzeugten Sicht.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-01. **Auslöser:** Register-Zähler 3× ([`emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md), `plan-welle.md` §Slices bereitstellen, Auslöser 3); dritter Beleg aus [`slice-e2e-belegt-die-rolle-der-erfassung-im-ziel`](../done/slice-e2e-belegt-die-rolle-der-erfassung-im-ziel.md).

---

## 1. Ziel und Abgrenzung

**Ziel:** Die Kurzbeschreibung einer `e2e_abdeckung`-Stufe in `harness/tools/full-smoke.sh` nennt, was der Lauf im Ziel misst und was nicht, statt die ganze Anforderung zu behaupten — zuerst für `LH-FA-15` in den zwei Stufen, die `traeger_im_ziel` rufen; die Regel dazu schreibt der Architect.

**Ausdrücklich NICHT in diesem Slice:**

- Eine ADR — die Regel verschärft [`AGENTS.md`](../../../../AGENTS.md) §3.6 und schwächt keine Schwelle (§3.5 gilt für Senkungen); ob sie als Falsch/Richtig-Paar dort oder als Eintrag im Konventionsspeicher steht, entscheidet der Architect.
- Neue Messung der drei ungemessenen Kriterienteile von `LH-FA-15` (Rolle aus `tool_response.agentType`, Lesevorschrift, echter `agent_type`) — anderer Vorgang: ein E2E-Lauf sieht keinen Claude-Code-Lauf.
- Die Matrix-Zelle *E2E ok* in `make doc-trace` — Werkzeug-Aussage des Doku-Gates, nicht dieses Repos.
- Andere Stufen und andere Anforderungen — jede weitere Kurzbeschreibung ist ein eigener Beleg im Register.

## 2. Definition of Done

- [ ] Die Kurzbeschreibungen der zwei Stufen, die `traeger_im_ziel` rufen, nennen die Teilabdeckung von `LH-FA-15` (*Rolle besetzt*, *abgeleitet, erster Teil*; nicht gemessen: Rolle aus `tool_response.agentType`, Lesevorschrift); `make e2e-abdeckung` hat [`docs/user/e2e-abdeckung.md`](../../../user/e2e-abdeckung.md) neu erzeugt. Rot gesehen: die Teilabdeckung aus der Kurzbeschreibung entfernt → ein benannter Fall färbt rot.
- [ ] Die Regel *„eine emittierte Zusage trägt, was der Lauf im Ziel misst, und nennt, was nicht"* steht als Architect-Artefakt in eigenem Commit (Übergabe: dieser Plan); Zielort bestätigt der Architect.
- [ ] `make gates` grün; Review; Closure-Notiz mit Lerneintrag; Beobachtungs-Register fortgeschrieben; jedes Risiko aus §6 trägt einen Ausgang; die drei Paarungen sind getragen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/full-smoke.sh` | update | Kurzbeschreibung der zwei Stufen |
| `docs/user/e2e-abdeckung.md` | update (erzeugt) | `make e2e-abdeckung` |
| Hard Rule oder Konventions-Eintrag | Architect | Regel; Ort offen |

## 4. Trigger

**Start** (`next` → `in-progress`): Auftraggeber priorisiert; `harness/tools/full-smoke.sh` liegt in keinem anderen `in-progress/`-Slice.

**Rückführungen:**

- `in-progress` → `next`: die Kurzbeschreibung braucht eine neue Spalte statt einer Textänderung.
- `in-progress` → `open`: die Regel braucht eine ADR — Frage an den Architect.

## 5. Closure-Trigger

DoD vollständig, `make gates` grün, Review- und Verifikationsbericht liegen vor, Closure-Notiz mit Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

- Kein Risiko über die Abgrenzung in §1 hinaus erkannt; der Implementer trägt ein, was er findet.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register:** —
- **Folge-Slices:** —
- **Risiken aus §6:** —
- **Drei Paarungen:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo, Kürzel `ALL`) mit `harness/tools/` (`TOOLS`); Schwelle ≥ 2 erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen. Treffer: [`emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md) (3 Dateien unter `evidence/`) — dieser Slice ist der Folge-Slice des Lese-Schritts.

alle berührten Sub-Areas GF.
