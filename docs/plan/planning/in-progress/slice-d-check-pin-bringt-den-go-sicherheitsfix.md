# Slice slice-d-check-pin-bringt-den-go-sicherheitsfix: d-check v0.85.0 mit dem Go-1.27.2-Image

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
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7),
[`MR-063`](../../../../harness/conventions.md#mr-063) (Gegenmessung),
[`MR-084`](../../../../harness/conventions.md#mr-084) (Muster des Pin-Eintrags),
[`MR-086`](../../../../harness/conventions.md#mr-086) (Trigger-Prüfung). Auftraggeber-Freigabe
2026-10-09.

**Berührte Spec-Stellen:** `—` — die Pins sind Code-Konstanten.

**Verantwortlich:** pt9912 (Implementer)

**Autor:** Planner. **Datum:** 2026-10-09.

---

## 1. Ziel und Abgrenzung

**Ziel:** d-check `v0.85.0` steht im Dogfood (`d-check.mk`, `DCHECK_IMAGE`/`DCHECK_DIGEST`) und
als emittierter Default (`internal/emit/emit.go`, `DefaultImage`/`DefaultDigest`). Anlass ist der
Sicherheitsgrund: laut CHANGELOG des Nachbar-Repos ist das Image mit Go 1.27.2 gebaut und behebt
zwei HIGH-Befunde der Standardbibliothek (CVE-2026-78667, CVE-2026-97031).

**Lage** (keine Erwartungswerte): `grep -n '^DCHECK_IMAGE\|^DCHECK_DIGEST' d-check.mk`,
`grep -n 'DefaultImage\|DefaultDigest' internal/emit/emit.go`; Index-Digest des Ziels:
`docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.85.0` (Netz).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **a-check-Pin `v0.23.0` → `v0.23.1`.** *Bestand bleibt:* `v0.23.1` ist als Release mit
  Multi-Arch-Index publiziert (`gh release view v0.23.1 -R pt9912/a-check`), trägt aber gegenüber
  `v0.23.0` keine Änderung an Produkt-Code und keinen Go-Wechsel
  (`git -C "$A" diff --stat v0.23.0 v0.23.1 -- internal cmd Dockerfile` leer, `$A` ein lokaler
  Klon von a-check; `GO_VERSION ?= 1.27.0` im `Makefile` beider Tags) und keinen eigenen CHANGELOG-Abschnitt. Der Sprung brächte
  einen neuen Digest ohne neuen Inhalt, also auch nicht den Sicherheitsfix dieses Slice.
- **Die neuen Opt-ins `vcs.ignore-link-targets`, `planning.closure.recursive`/`skip-pattern`,
  `structure[].skip-pattern`.** *Anderer Vorgang:* der Pin macht sie verfügbar, eine Aktivierung
  ist eine eigene Entscheidung. `vcs.ignore-link-targets` (ein reiner Pfad-Nachzug in einer
  immutablen Datei ist keine Drift) passt zu `slice-releasing-zieht-nach-docs-maintainer`, dort
  steht ein Pfad-Nachzug in eingefrorenen Artefakten an; die Entscheidung trifft jener Slice.
- **`reviews` aktivieren, im Dogfood oder im emittierten Doc-Gate.** *Anderer Vorgang:* dieser
  Slice liefert allein die Prüfung, ob der Auflösungs-Trigger von
  [`MR-086`](../../../../harness/conventions.md#mr-086) eintritt (Übergabe an den Architect, §2).
- **Der MR-Eintrag zum Pin.** *Anderer Vorgang:* Architect-Artefakt
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8); dieser Slice liefert das Mess-Material.

## 2. Definition of Done

- [ ] **1 — d-check `v0.85.0`:** `DCHECK_IMAGE`/`DCHECK_DIGEST` in `d-check.mk` und
      `DefaultImage`/`DefaultDigest` in `internal/emit/emit.go` auf den Index-Digest (Kommando der
      Messung im Commit). **Rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6): eine der zwei
      Stellen bleibt auf `v0.84.0` — der Wächter, der sie koppelt, wird rot.
- [ ] **2 — Strenge-Bilanz:** Gegenmessung nach
      [`MR-063`](../../../../harness/conventions.md#mr-063) über beide Digests — jedes aktive Modul
      (`grep -m1 '^modules:' .d-check.yml`, Dogfood und emittiertes Ziel) mit Nicht-Null-Basis,
      Befund-Zahlen und `diff` samt Kommando im Umsetzungs-Commit. Die zwei geänderten
      `reviews`-Defaults treffen kein aktives Modul; die Bilanz nennt das mit dem Kommando, das es
      zeigt.
- [ ] **3 — Sicherheitsgrund gemessen:** die Go-Fassung des Binärs im gepinnten Image ist
      mindestens 1.27.2, gemessen am Image selbst (Kommando im Umsetzungs-Commit), nicht am
      CHANGELOG.
- [ ] `make gates` grün; `make full-smoke` EXIT 0 (emittierter Pin im Ziel).
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: Übergabe an den Architect liegt als eigener Commit vor — MR-Eintrag zum
      d-check-Pin `v0.85.0` nach dem Muster von [`MR-084`](../../../../harness/conventions.md#mr-084)
      mit der Bilanz aus Liefer-Punkt 2, **und** das Ergebnis der Prüfung, ob mit `reviews`
      `match: name` (Slug-Kennungen) und der erkannten Vorlagen-Zusage der Auflösungs-Trigger von
      [`MR-086`](../../../../harness/conventions.md#mr-086) eintritt — im MR-Eintrag genannt, auch
      wenn er nicht eintritt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind nach dem Move geprüft, §7.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `d-check.mk` | update | Pin und Kopfkommentar (Liefer-Punkt 1) |
| `internal/emit/emit.go` | update | emittierter Default-Pin (Liefer-Punkt 1) |
| Pin-Tests unter `internal/emit/` | update, falls sie den Tag nennen | Kopplung der zwei Stellen ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) |
| `internal/emit/templates/d-check.yml` | update | Prosa der Kommentar-Blöcke `reviews` und `codepaths` auf den Stand am neuen Pin; `reviews` bleibt auskommentiert ([`MR-086`](../../../../harness/conventions.md#mr-086)), der Block trägt `match: name` |
| `internal/emit/emit_test.go`, `test/mutations/` | update, neu | koppelt die Pin-Fassung der `reviews`-Prosa an `DefaultImage` und hält `match: name` im Block |

## 4. Trigger

**Start** (`next` → `in-progress`): `slice-mutate-laeuft-ueber-einen-ci-branch` liegt in `done/`
(WIP-Limit frei); Auftraggeber-Freigabe 2026-10-09 liegt vor.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: die Gegenmessung zeigt in einem aktiven Modul eine abweichende
  Befund-Zahl — das Prüfverhalten hat sich geändert; dann braucht die Senkung oder Verschärfung
  ihre Entscheidung ([`AGENTS.md`](../../../../AGENTS.md) §3.5) vor dem Pin.
- `in-progress` → `open`: der Index-Digest löst im gepinnten Docker-Lauf (lokal oder CI) nicht
  auf, oder die gemessene Go-Fassung im Image liegt unter 1.27.2 — Übergabe an den Auftraggeber
  als Anforderung an das Nachbar-Repo.

## 5. Closure-Trigger

1. `make gates` grün und `make full-smoke` EXIT 0 mit d-check `v0.85.0`.
2. Gegenmessung und Go-Fassung im Umsetzungs-Commit, MR-Eintrag als eigener Architect-Commit.

**Lerneintrag** in einer der drei Formen, §7; die Closure schreibt der Planner
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

- **Digest ohne Wächter** — kein Sensor hält den Digest gegen den Tag;
  `BEO-ALL/pin-digest-ohne-waechter` steht bei 4 Belegen, `geplant`. — **Ausgang:** offen bis zur
  Closure.
- **a-check-Image mit derselben Go-Fassung** — das gepinnte a-check `v0.23.0` und `v0.23.1` sind
  mit `GO_VERSION 1.27.0` gebaut; ob die zwei Befunde der Standardbibliothek das a-check-Binär
  treffen, misst dieser Slice nicht (Abgrenzung §1). — **Ausgang:** offen bis zur Closure; der
  Kandidat ist ein Beleg in `BEO-ALL/gepinntes-bild-ohne-schwachstellen-scan` oder eine
  Anforderung an das Nachbar-Repo.

## 7. Closure-Notiz

Geschrieben vom Planner in eigenem Kontext bei der Closure ([`AGENTS.md`](../../../../AGENTS.md)
§3.10).

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —
- **Drei Paarungen:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (`d-check.mk`, `internal/emit`); `TOOLS`
und `CODEX` nicht.

**Vorgelagert — offene Beobachtungen sichten:** Register am gemergten Stand gesichtet
(`grep -l -i 'Pin\|d-check\|a-check\|Digest' docs/plan/planning/observations/BEO-ALL/*/observation.md`,
Zähler je Treffer `ls <verzeichnis>/evidence | wc -l`). Treffer, die dieser Slice berührt:

- `BEO-ALL/pin-digest-ohne-waechter` (4, `geplant`) — Risiko §6.
- `BEO-ALL/strenge-bilanz-eines-pin-sprungs-fehlt-im-umsetzungs-commit` (1, offen) — Liefer-Punkt
  2 legt die Bilanz in den Umsetzungs-Commit.
- `BEO-ALL/pin-sprung-feuert-adr-trigger-ohne-nennung` (1, offen) — die Übergabe an den Architect
  (§2, Doku-Update) nennt den Trigger von [`MR-086`](../../../../harness/conventions.md#mr-086),
  den dieser Sprung berühren kann.
- `BEO-ALL/gepinntes-bild-ohne-schwachstellen-scan` (1, offen) — Anlass des Slice ist ein
  Schwachstellen-Fix, den kein Sensor dieses Repos meldete; Risiko §6.
- `BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand` (5, `geplant`) und
  `BEO-ALL/werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten` (6, `geplant`) —
  Liefer-Punkt 3 misst die Go-Fassung am Image statt am CHANGELOG.

Keiner der offenen Einträge erreicht mit diesem Slice 3×.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
