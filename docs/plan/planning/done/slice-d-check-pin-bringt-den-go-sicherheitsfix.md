# Slice slice-d-check-pin-bringt-den-go-sicherheitsfix: d-check v0.86.1 mit dem Go-1.27.2-Image und x/net v0.60.0

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
2026-10-09; Zielversion v0.86.1 am 2026-10-10 (§1 Entscheidungen).

**Berührte Spec-Stellen:** `—` — die Pins sind Code-Konstanten.

**Verantwortlich:** pt9912 (Implementer)

**Autor:** Planner. **Datum:** 2026-10-09.

---

## 1. Ziel und Abgrenzung

**Ziel:** d-check `v0.86.1` steht im Dogfood (`d-check.mk`, `DCHECK_IMAGE`/`DCHECK_DIGEST`) und
als emittierter Default (`internal/emit/emit.go`, `DefaultImage`/`DefaultDigest`). Anlass ist der
Sicherheitsgrund: laut CHANGELOG des Nachbar-Repos ist das Image mit Go 1.27.2 gebaut und behebt
zwei HIGH-Befunde der Standardbibliothek (CVE-2026-78667, CVE-2026-97031).

**Entscheidung 2026-10-10 (Orchestrator):** Zielversion `v0.86.0` statt `v0.85.0`. Grund: der
Auftraggeber meldete `v0.86.0` als erschienen, bevor dieser Slice schloss; ein Sprung statt zwei
hintereinander. Die Abnahme ändert sich nur im Versionsziel. Die Arbeit an `v0.85.0` (Pin,
Exit-Zusage, `reviews`-Kommentar) wird auf `v0.86.0` nachgezogen.

**Entscheidung 2026-10-10, zweite (Orchestrator):** Zielversion `v0.86.1` statt `v0.86.0`. Grund:
der Auftraggeber meldete `v0.86.1` als erschienen, während dieser Slice noch offen ist; ein Sprung
statt eines dritten. Die Abnahme ändert sich nur im Versionsziel; der Pin auf `v0.86.0` wird auf
`v0.86.1` nachgezogen.

**Was `v0.86.1` gegenüber `v0.86.0` ändert** (CHANGELOG des Nachbar-Repos, gelesen): allein
Security — `golang.org/x/net` `v0.60.0` behebt vier HTTP/2-Befunde (CRITICAL/HIGH) und einen
MEDIUM im publizierten Image, laut CHANGELOG ohne Verhaltensänderung des Werkzeugs. Am lokalen
Klon `$D` des Nachbar-Repos berührt `git -C "$D" diff --stat v0.86.0 v0.86.1 -- internal cmd Dockerfile go.mod`
nur `go.mod`; `GO_VERSION ?= 1.27.2` bleibt
(`git -C "$D" show v0.86.1:Makefile | grep -n '^GO_VERSION'`). Ob das Prüfverhalten gleich bleibt,
misst Liefer-Punkt 2, nicht das CHANGELOG.

**Was `v0.86.0` gegenüber `v0.85.0` ändert** (CHANGELOG des Nachbar-Repos, gelesen):

- `reviews.match: name` deckt nur den **längsten** passenden Slice-Namen — nicht rein additiv. Der
  emittierte Kommentar-Block `reviews` nennt `match: name`; ob Kommentar und Trigger-Aussage am
  neuen Pin noch stimmen, prüft der Implementer an `v0.86.1` neu (§3).
- `skip-allows-empty` (neben `skip-pattern` in `reviews`, `planning.closure`, `structure`) erklärt
  eine erst durch `skip-pattern` geleerte Kandidatenmenge zum Ruhezustand. Das berührt den Grund
  von [`MR-086`](../../../../harness/conventions.md#mr-086) (leerer Start fail-closed); ob der
  Auflösungs-Trigger damit eintritt, prüft der Architect (§2, Doku-Update).
- `--suggest-config` schlägt `"8. Historie"` für `matrix.exclude-sections` vor. Betrifft unsere
  Konfiguration nicht: die Dogfood-`.d-check.yml` führt den Eintrag bereits, die emittierte
  Vorlage lässt ihn begründet weg (Kommentar über `matrix` in `internal/emit/templates/d-check.yml`)
  — `grep -n 'exclude-sections' .d-check.yml internal/emit/templates/d-check.yml`.

**Lage** (keine Erwartungswerte): `grep -n '^DCHECK_IMAGE\|^DCHECK_DIGEST' d-check.mk`,
`grep -n 'DefaultImage\|DefaultDigest' internal/emit/emit.go`; Index-Digest des Ziels:
`docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.86.1` (Netz).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **a-check-Pin `v0.23.0` → `v0.23.1`.** *Bestand bleibt:* `v0.23.1` ist als Release mit
  Multi-Arch-Index publiziert (`gh release view v0.23.1 -R pt9912/a-check`), trägt aber gegenüber
  `v0.23.0` keine Änderung an Produkt-Code und keinen Go-Wechsel
  (`git -C "$A" diff --stat v0.23.0 v0.23.1 -- internal cmd Dockerfile` leer, `$A` ein lokaler
  Klon von a-check; `GO_VERSION ?= 1.27.0` im `Makefile` beider Tags) und keinen eigenen CHANGELOG-Abschnitt. Der Sprung brächte
  einen neuen Digest ohne neuen Inhalt, also auch nicht den Sicherheitsfix dieses Slice.
- **Die neuen Opt-ins `vcs.ignore-link-targets`, `planning.closure.recursive`/`skip-pattern`,
  `structure[].skip-pattern`, `skip-allows-empty`, `--manual` und der `--suggest-config`-Vorschlag
  `"8. Historie"`.** *Anderer Vorgang:* der Pin macht sie verfügbar, eine Aktivierung
  ist eine eigene Entscheidung; aktiviert wird keiner. `vcs.ignore-link-targets` (ein reiner Pfad-Nachzug in einer
  immutablen Datei ist keine Drift) passt zu `slice-releasing-zieht-nach-docs-maintainer`, dort
  steht ein Pfad-Nachzug in eingefrorenen Artefakten an; die Entscheidung trifft jener Slice.
- **`reviews` aktivieren, im Dogfood oder im emittierten Doc-Gate.** *Anderer Vorgang:* dieser
  Slice liefert allein die Prüfung, ob der Auflösungs-Trigger von
  [`MR-086`](../../../../harness/conventions.md#mr-086) eintritt (Übergabe an den Architect, §2).
- **Der MR-Eintrag zum Pin.** *Anderer Vorgang:* Architect-Artefakt
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8); dieser Slice liefert das Mess-Material.

## 2. Definition of Done

- [x] **1 — d-check `v0.86.1`:** `DCHECK_IMAGE`/`DCHECK_DIGEST` in `d-check.mk` und
      `DefaultImage`/`DefaultDigest` in `internal/emit/emit.go` auf den Index-Digest (Kommando der
      Messung im Commit). **Rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6): eine der zwei
      Stellen bleibt auf `v0.84.0` — der Wächter, der sie koppelt, wird rot.
- [x] **2 — Strenge-Bilanz:** Gegenmessung nach
      [`MR-063`](../../../../harness/conventions.md#mr-063) zwischen `v0.84.0` und `v0.86.1`, also über alle drei Sprünge — jedes aktive Modul
      (`grep -m1 '^modules:' .d-check.yml`, Dogfood und emittiertes Ziel) mit Nicht-Null-Basis,
      Befund-Zahlen und `diff` samt Kommando im Umsetzungs-Commit. Die geänderten
      `reviews`-Defaults (`v0.85.0`) und die `match: name`-Regel (`v0.86.0`) treffen kein aktives
      Modul; die Bilanz nennt das mit dem Kommando, das es zeigt.
- [x] **3 — Sicherheitsgrund gemessen:** im Binär des gepinnten `v0.86.1`-Image ist die Go-Fassung
      mindestens 1.27.2 und `go version -m` zeigt `golang.org/x/net v0.60.0`, beides gemessen am
      Image selbst (Kommando im Umsetzungs-Commit), nicht am CHANGELOG.
- [x] `make gates` grün; `make full-smoke` EXIT 0 (emittierter Pin im Ziel).
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: Übergabe an den Architect liegt als eigener Commit vor — MR-Eintrag zum
      d-check-Pin `v0.86.1` nach dem Muster von [`MR-084`](../../../../harness/conventions.md#mr-084)
      mit der Bilanz aus Liefer-Punkt 2, **und** das Ergebnis der Prüfung, ob mit `reviews`
      `match: name` (Slug-Kennungen, längster Name), der erkannten Vorlagen-Zusage und
      `skip-allows-empty` am Pin `v0.86.1` der Auflösungs-Trigger von
      [`MR-086`](../../../../harness/conventions.md#mr-086) eintritt — im MR-Eintrag genannt, auch
      wenn er nicht eintritt.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind nach dem Move geprüft, §7.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `d-check.mk` | update | Pin und Kopfkommentar (Liefer-Punkt 1) |
| `internal/emit/emit.go` | update | emittierter Default-Pin (Liefer-Punkt 1) |
| Pin-Tests unter `internal/emit/` | update, falls sie den Tag nennen | Kopplung der zwei Stellen ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) |
| `internal/emit/templates/d-check.yml` | update | Prosa der Kommentar-Blöcke `reviews` und `codepaths` auf den Stand am Pin `v0.86.1` (`match: name` deckt den längsten Namen — neu prüfen); `reviews` bleibt auskommentiert ([`MR-086`](../../../../harness/conventions.md#mr-086)), der Block trägt `match: name` |
| `internal/emit/emit_test.go`, `test/mutations/` | update, neu | koppelt die Pin-Fassung der `reviews`-Prosa an `DefaultImage` und hält `match: name` im Block |
| `harness/README.md` | update | Werkzeuge-Zeile `make doc-trace`/`make doc-complete`: die Exit-Zusage nennt ihren Aufruf (`f652d6fb`); Übergabe aus der Closure von `slice-mutate-laeuft-ueber-einen-ci-branch` §7, nachgetragen bei der Closure |

## 4. Trigger

**Start** (`next` → `in-progress`): `slice-mutate-laeuft-ueber-einen-ci-branch` liegt in `done/`
(WIP-Limit frei); Auftraggeber-Freigabe 2026-10-09 liegt vor.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: die Gegenmessung zeigt in einem aktiven Modul eine abweichende
  Befund-Zahl — das Prüfverhalten hat sich geändert; dann braucht die Senkung oder Verschärfung
  ihre Entscheidung ([`AGENTS.md`](../../../../AGENTS.md) §3.5) vor dem Pin.
- `in-progress` → `open`: der Index-Digest löst im gepinnten Docker-Lauf (lokal oder CI) nicht
  auf, oder die gemessene Go-Fassung im Image liegt unter 1.27.2 oder `golang.org/x/net` unter
  `v0.60.0` — Übergabe an den Auftraggeber
  als Anforderung an das Nachbar-Repo.

## 5. Closure-Trigger

1. `make gates` grün und `make full-smoke` EXIT 0 mit d-check `v0.86.1`.
2. Gegenmessung und Go-Fassung im Umsetzungs-Commit, MR-Eintrag als eigener Architect-Commit.

**Lerneintrag** in einer der drei Formen, §7; die Closure schreibt der Planner
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

- **Digest ohne Wächter** — kein Sensor hält den Digest gegen den Tag;
  `BEO-ALL/pin-digest-ohne-waechter` steht bei 4 Belegen, `geplant`. — **Ausgang:** *weiter offen*
  → Register `BEO-ALL/pin-digest-ohne-waechter` (Beleg dieses Slice, 5×, Stand `geplant`).
- **a-check-Image mit derselben Go-Fassung** — das gepinnte a-check `v0.23.0` und `v0.23.1` sind
  mit `GO_VERSION 1.27.0` gebaut; ob die zwei Befunde der Standardbibliothek das a-check-Binär
  treffen, misst dieser Slice nicht (Abgrenzung §1). — **Ausgang:** *weiter offen* → Register
  `BEO-ALL/gepinntes-bild-ohne-schwachstellen-scan` (Beleg dieses Slice, 2×, `offen`); die
  Anforderung an a-check (Image mit Go ≥ 1.27.2) geht über den Orchestrator an den Auftraggeber.
- **Mutate-Weg offen** — die Fallmenge des `make mutate`-Laufs für diesen Slice liegt bei 46; der CI-Weg ist durch das
  Docker-Hub-Limit blockiert. Die Entscheidung des Auftraggebers, auf welchem Weg die Fälle
  laufen, steht aus. — **Ausgang:** *entfallen* — der wiederholte CI-Lauf über
  `mutate/slice-d-check-pin-bringt-den-go-sicherheitsfix-4abafc4f` ergab 46/46 `ok`
  ([Verifikation](../../../reviews/2026-10-10-slice-d-check-pin-bringt-den-go-sicherheitsfix-verifikation.md)).

## 7. Closure-Notiz

Geschrieben vom Planner in eigenem Kontext bei der Closure ([`AGENTS.md`](../../../../AGENTS.md)
§3.10).
**Rolle:** Planner · **Datum:** 2026-10-10

- **Was hat funktioniert:** Alle Liefer-Punkte bestätigt
  ([Verifikation](../../../reviews/2026-10-10-slice-d-check-pin-bringt-den-go-sicherheitsfix-verifikation.md),
  `91e6658b`): Pin `v0.86.1` als Index-Digest an beiden Stellen, Strenge-Bilanz `v0.84.0` gegen
  `v0.86.1` ohne Abweichung, Go 1.27.2 und `golang.org/x/net v0.60.0` am Image gemessen,
  `make full-smoke` EXIT 0. Mutation 46/46 `ok` über `mutate/…-4abafc4f`; beide `mutate/…`-Branches
  gelöscht, `git ls-remote origin 'refs/heads/mutate/*'` leer. Reviews:
  [erster](../../../reviews/2026-10-09-slice-d-check-pin-bringt-den-go-sicherheitsfix.md) (`4520ab1e`,
  MEDIUM-1 behoben in `724b63ff`),
  [Nachprüfung](../../../reviews/2026-10-10-slice-d-check-pin-bringt-den-go-sicherheitsfix-nachpruefung.md)
  (`a79d72a9`, 2 INFO),
  [Nachprüfung 2](../../../reviews/2026-10-10-slice-d-check-pin-bringt-den-go-sicherheitsfix-nachpruefung-2.md)
  (`cc5663a8`, freigegeben, 3 INFO).
- **Architect-Übergabe:** [`MR-092`](../../../../harness/conventions.md#mr-092) (`eb6f1f1b`) erfüllt
  sie; der Auflösungs-Trigger von [`MR-086`](../../../../harness/conventions.md#mr-086) ist nicht
  eingetreten, [`MR-086`](../../../../harness/conventions.md#mr-086) bleibt unverändert.
- **Was ging anders als geplant:** Zwei Entscheidungen des Orchestrators:
  - Zielversion zweimal nachgezogen, `v0.85.0` → `v0.86.0` → `v0.86.1` (beide am 2026-10-10, §1).
  - Der erste CI-Mutationslauf scheiterte am Docker-Hub-Limit (429); auf Wunsch des Auftraggebers
    wurde er wiederholt, nicht lokal gefahren.

  Plan-Lücke: die `harness/README.md`-Zeile aus `f652d6fb` fehlte in §3; nachgetragen.
- **Steering-Loop-Eintrag:** Neuer Sensor: `TestDCheckConfig_ReviewsBleibtKommentarBlock`
  (`internal/emit/emit_test.go`) koppelt die Pin-Fassung der emittierten `reviews`-Prosa an
  `DefaultImage` und hält `match: name` im Block (aus MEDIUM-1). Grenze: der `codepaths`-Block ist
  nicht gekoppelt (INFO-2 beider Nachprüfungen); gezählt, nicht verkörpert.
- **Beobachtungs-Register (`../observations/`):** je ein Beleg dieses Slice:
  - [`BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`](../observations/BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand/observation.md)
    (MEDIUM-1, INFO-2 beider Nachprüfungen) → 6×, Stand `geplant`, unverändert.
  - [`BEO-ALL/regel-rand-ohne-benannte-luecke`](../observations/BEO-ALL/regel-rand-ohne-benannte-luecke/observation.md)
    (INFO-1 beider Nachprüfungen, INFO-3 der Nachprüfung 2; Klasse *Grenzen-Aufzählung einer
    erkennenden Regel ohne Formen-Probe*) → 9×, Stand `geplant`, unverändert.
  - [`BEO-ALL/sensor-lauf-endet-rot-an-der-infrastruktur-bevor-der-fall-urteilt`](../observations/BEO-ALL/sensor-lauf-endet-rot-an-der-infrastruktur-bevor-der-fall-urteilt/observation.md)
    (INFO-1 des ersten Reviews, 429) → 2×, `offen`.
  - [`BEO-ALL/pin-digest-ohne-waechter`](../observations/BEO-ALL/pin-digest-ohne-waechter/observation.md)
    (Risiko 1) → 5×, Stand `geplant`, unverändert.
  - [`BEO-ALL/gepinntes-bild-ohne-schwachstellen-scan`](../observations/BEO-ALL/gepinntes-bild-ohne-schwachstellen-scan/observation.md)
    (Risiko 2) → 2×, `offen`.
  - Ohne Beleg: INFO-2 des ersten Reviews (`spans`-Basis über einen Grund-Code) — die Bilanz nennt
    die Grenze selbst, [`MR-063`](../../../../harness/conventions.md#mr-063) ist auf Modul-Ebene
    erfüllt; abgelehnt. INFO-3 des ersten Reviews (`doc-complete` „Exit 1") — Übergabe aus der Closure
    von `slice-mutate-laeuft-ueber-einen-ci-branch`, dort benannt, im Slice behoben (`f652d6fb`);
    nicht gezählt.
  - Kein Eintrag ohne Ausgang erreicht 3×.
- **Folge-Slices:** keiner.
- **Trigger-Audit:** Carveouts: keiner berührt. Bootstrap-aware Gates: keines. ADR/MR:
  Auflösungs-Trigger von [`MR-086`](../../../../harness/conventions.md#mr-086) geprüft, nicht
  eingetreten ([`MR-092`](../../../../harness/conventions.md#mr-092)). Hard Rules: keine mit
  eingetretenem Auflösungs-Trigger.
- **Archivierung:** entfällt ([`MR-078`](../../../../harness/conventions.md#mr-078); `archive-slice`
  ist nicht gebaut).
- **Risiken aus §6:** jede Zeile in §6 hat ihren Ausgang.
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
