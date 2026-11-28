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

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-10-01. **Auslöser:** Register-Zähler 3× ([`emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md), `plan-welle.md` §Slices bereitstellen, Auslöser 3); dritter Beleg aus [`slice-e2e-belegt-die-rolle-der-erfassung-im-ziel`](../done/slice-e2e-belegt-die-rolle-der-erfassung-im-ziel.md).

---

## 1. Ziel und Abgrenzung

**Ziel:** Die Kurzbeschreibung einer `e2e_abdeckung`-Stufe in `harness/tools/full-smoke.sh` nennt, was der Lauf im Ziel misst und was nicht, statt die ganze Anforderung zu behaupten — zuerst für [`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung) in den zwei Stufen, die `traeger_im_ziel` rufen; die Regel dazu schreibt der Architect.

**Ausdrücklich NICHT in diesem Slice:**

- Eine ADR — die Regel verschärft [`AGENTS.md`](../../../../AGENTS.md) §3.6 und schwächt keine Schwelle (§3.5 gilt für Senkungen); ob sie als Falsch/Richtig-Paar dort oder als Eintrag im Konventionsspeicher steht, entscheidet der Architect.
- Neue Messung der drei ungemessenen Kriterienteile von [`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung) (Rolle aus `tool_response.agentType`, Lesevorschrift, echter `agent_type`) — anderer Vorgang: ein E2E-Lauf sieht keinen Claude-Code-Lauf.
- Die Matrix-Zelle *E2E ok* in `make doc-trace` — Werkzeug-Aussage des Doku-Gates, nicht dieses Repos.
- Andere Stufen und andere Anforderungen — jede weitere Kurzbeschreibung ist ein eigener Beleg im Register.

## 2. Definition of Done

- [x] Die Kurzbeschreibungen der zwei Stufen, die `traeger_im_ziel` rufen, nennen die Teilabdeckung von [`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung) (*Rolle besetzt*, *abgeleitet, erster Teil*; nicht gemessen: Rolle aus `tool_response.agentType`, Lesevorschrift); `make e2e-abdeckung` hat [`docs/user/e2e-abdeckung.md`](../../../user/e2e-abdeckung.md) neu erzeugt. Rot gesehen: die Teilabdeckung aus der Kurzbeschreibung entfernt → ein benannter Fall färbt rot.
- [x] Die Regel *„eine emittierte Zusage trägt, was der Lauf im Ziel misst, und nennt, was nicht"* steht als Architect-Artefakt in eigenem Commit (Übergabe: dieser Plan); Zielort bestätigt der Architect.
- [x] `make gates` grün; Review; Closure-Notiz mit Lerneintrag; Beobachtungs-Register fortgeschrieben; jedes Risiko aus §6 trägt einen Ausgang; die drei Paarungen sind getragen.

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
  **Ausgang:** entfallen: kein Risiko eingetreten; die in Review und Verifikation gefundenen Grenzen stehen in §7 und im Register.

## 7. Closure-Notiz

- **Zustand:** DoD 1 und 2 bestätigt in `docs/reviews/2026-10-01-folge-slice-zusage-verifikation.md`; Review `docs/reviews/2026-10-01-folge-slice-zusage-review.md`; `make gates` Exit 0 am Endstand der Closure.
- **Was ging anders als geplant:** ergänzt um die Zählprüfung in `rolle_im_ziel` (Commit zur Anzahl der Rollen-Typ-Dateien, aus dem Review des Vorgängers).
- **Steering-Loop-Eintrag — geschärfte Regel:** Paar „emittierte Abdeckungs-Aussage nennt, was der Lauf im Ziel misst" — liegt in `AGENTS.md §3.6` (Anker `seit slice-emittierte-zusage-nennt-was-der-lauf-im-ziel-misst` steht dort). Auslöser: `BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` (3×).
- **Grenzen:** der Fall in `test/e2e-abdeckung.bats` hält die Gleichheit Deklaration ↔ erzeugte Datei, nicht den Inhalt gegen den Stufenkörper (Review F2; „Teilabdeckung entfernt → Fall rot" gilt nur ohne Neuerzeugung). Die Zählprüfung in `rolle_im_ziel` zählt nur die Anzahl; die Namensmenge hält `rollen_typen_im_ziel` davor (F4). Stufe nicht im Docker-E2E gefahren.
- **Abweichung, benannt:** Architect-Commit `c6badd9b` berührt `state.md` der Beobachtung (Review F1, §3.8/§3.10); der Planner hat den Stand in dieser Closure festgeschrieben: `verkörpert in AGENTS.md §3.6`.
- **Beobachtungs-Register:** `evidence/slice-emittierte-zusage-nennt-was-der-lauf-im-ziel-misst.md` in `BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/` ergänzt (Stufen 2 und 5 deklarieren [`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans) ohne Teilabdeckungs-Text, Review F3) — Zähler 4×, Stand bleibt verkörpert.
- **Folge-Slices:** keine; Stufen 2 und 5 sind Register-Beleg.
- **Risiken aus §6:** das eine Risiko — *entfallen* (siehe §6).
- **Drei Paarungen:** nach dem `git mv` geprüft — (a) `liegt in` `AGENTS.md §3.6` trägt den Anker (`grep` Zeile 137) · (b) keine Folge-Slices · (c) Beobachtung existiert, `evidence/` trägt 4 Dateien.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo, Kürzel `ALL`) mit `harness/tools/` (`TOOLS`); Schwelle ≥ 2 erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen. Treffer: [`emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md) (3 Dateien unter `evidence/`) — dieser Slice ist der Folge-Slice des Lese-Schritts.

alle berührten Sub-Areas GF.
