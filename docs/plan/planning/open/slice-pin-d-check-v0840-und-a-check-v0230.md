# Slice slice-pin-d-check-v0840-und-a-check-v0230: d-check v0.84.0 und a-check v0.23.0 als Multi-Arch-Pins

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD dieses Slice; Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht. Ziel-Release: `v0.5.0`.

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7),
[`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren),
[`MR-063`](../../../../harness/conventions.md#mr-063) (Gegenmessung),
[`MR-082`](../../../../harness/conventions.md#mr-082) (Muster des Pin-Eintrags). Ersetzt den geplanten
a-check-`v0.22.0`-Slice (Auftraggeber-Entscheidung 2026-10-07).

**Berührte Spec-Stellen:** `—` — die Pins sind Code-Konstanten.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-07.

---

## 1. Ziel und Abgrenzung

**Ziel:** d-check `v0.84.0` (Index-Digest, Multi-Arch amd64/arm64, Prüfverhalten laut CHANGELOG des
Nachbar-Repos unverändert) steht im Dogfood (`d-check.mk`) und als emittierter Default
(`internal/emit/emit.go`); a-check `v0.23.0` (Index-Digest, Multi-Arch) als
`DefaultArchImage`/`DefaultArchDigest` in `internal/emit/archgate.go`; das Handbuch nennt die
arm64-Unterstützung.

**Lage** (keine Erwartungswerte): `grep -n '^DCHECK_IMAGE\|^DCHECK_DIGEST' d-check.mk`,
`grep -n 'DefaultImage\|DefaultDigest' internal/emit/emit.go`,
`grep -n 'DefaultArch' internal/emit/archgate.go`.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **`shapes` aus a-check `v0.21`/`v0.22`.** *Bestand bleibt:* opt-in, nicht emittiert
  (Auftraggeber-Entscheidung 2026-10-07).
- **Der MR-Eintrag zum d-check-Pin.** *Anderer Vorgang:* Architect-Artefakt (`AGENTS.md` §3.8);
  dieser Slice liefert das Mess-Material (DoD-Zeile *Doku-Update*).
- **a-check im Dogfood.** *Bestand bleibt:* der Dogfood ist flach, a-check hätte einen leeren
  Prüfbereich ([`harness/README.md`](../../../../harness/README.md) §Safety and scope boundaries).
- **Übrige Pins (go, golangci-lint).** *Anderer Vorgang.*

## 2. Definition of Done

- [ ] **1 — d-check `v0.84.0`:** `DCHECK_IMAGE`/`DCHECK_DIGEST` in `d-check.mk` und
      `DefaultImage`/`DefaultDigest` in `internal/emit/emit.go` auf den Index-Digest (Kommando der
      Messung im Commit); Gegenmessung nach [`MR-063`](../../../../harness/conventions.md#mr-063) —
      jedes aktive Modul mit Nicht-Null-Basis vor und nach dem Pin, Befund-Zahlen samt Kommando im
      Umsetzungs-Commit. **Rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6): eine der zwei
      Stellen bleibt auf `v0.83.0` — der Wächter, der sie koppelt, wird rot; koppelt keiner, nennt der
      Umsetzungs-Commit die Lücke.
- [ ] **2 — a-check `v0.23.0`:** `DefaultArchImage`/`DefaultArchDigest` auf den Index-Digest;
      `make full-smoke` EXIT 0 über `hexslice` (go, cpp) und `hexagonal` (go), der verbotene Import
      färbt das emittierte Gate weiter rot.
- [ ] **3 — Handbuch:** [`docs/user/benutzerhandbuch.md`](../../../user/benutzerhandbuch.md) nennt,
      dass beide gepinnten Images per Index-Digest auf amd64 und arm64 laufen — begrenzt auf das, was
      der Index trägt (Kommando `docker manifest inspect`), Ist-Zustand.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: Übergabe an den Architect liegt als eigener Commit vor — MR-Eintrag zum
      d-check-Pin `v0.84.0` nach dem Muster von [`MR-082`](../../../../harness/conventions.md#mr-082),
      mit der Gegenmessung aus Liefer-Punkt 1.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die nächste Welle-Closure (das Repo fährt Wellen).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `d-check.mk`, `internal/emit/emit.go` | update | d-check-Pin (Liefer-Punkt 1) |
| `internal/emit/archgate.go` | update | a-check-Pin (Liefer-Punkt 2) |
| Pin-Tests unter `internal/emit/`, `test/` | update | Kopplung der Pin-Stellen |
| `docs/user/benutzerhandbuch.md` | update | Liefer-Punkt 3 |

## 4. Trigger

**Start** (`next` → `in-progress`): Auftraggeber-Entscheidung 2026-10-07 (erfüllt); WIP-Limit frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: die Gegenmessung zeigt in einem Modul eine abweichende Befund-Zahl — das
  Prüfverhalten hat sich doch geändert; dann werden d-check- und a-check-Pin getrennt geschnitten.
- `in-progress` → `open`: ein Index-Digest löst im gepinnten Docker-Lauf (lokal oder CI) nicht auf —
  Übergabe an den Architect.

## 5. Closure-Trigger

1. `make full-smoke` EXIT 0 über den drei Layouts mit a-check `v0.23.0`.
2. `make gates` grün mit d-check `v0.84.0`, Gegenmessung im Umsetzungs-Commit.

**Lerneintrag** in einer der drei Formen, §7; die Closure schreibt der Planner
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

- **arm64 ungemessen** — kein Lauf dieses Repos fährt arm64; der Handbuch-Satz trägt nur, was der
  Index-Manifest sagt. — **Ausgang:** offen bis zur Closure.
- **Digest ohne Wächter** — `BEO-ALL/pin-digest-ohne-waechter` steht bei 3 Belegen, `offen`; ein
  weiterer Pin-Sprung ohne Digest-Wächter berührt die Klasse erneut. — **Ausgang:** offen bis zur
  Closure.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (`d-check.mk`, `internal/emit`,
`docs/user/`); `TOOLS` und `CODEX` nicht.

**Vorgelagert — offene Beobachtungen sichten:** Register am gemergten Stand gesichtet
(`grep -l 'Pin\|d-check\|a-check\|Digest\|arm64' docs/plan/planning/observations/BEO-ALL/*/observation.md`):
`BEO-ALL/pin-digest-ohne-waechter` (3, offen — Risiko §6),
`BEO-ALL/strenge-bilanz-eines-pin-sprungs-fehlt-im-umsetzungs-commit` (1, offen — Liefer-Punkt 1
legt die Bilanz in den Umsetzungs-Commit),
`BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand` (4, geplant),
`BEO-ALL/werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten` (6, geplant).

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
