# Slice d-check-sprung-v0930: d-check-Pin-Sprung v0.86.1 → v0.93.0

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — es gibt keine Closure-Bedingung, die mehr beobachtet,
als die DoDs dieses Slice belegen: der Pin-Kette-Träger ist die Gegenmessung
und die Pin-koppelnden Tests, beide stehen in den DoDs; ein repo-weites
Beleg-Mehr (Replay, repo-weiter Verifikations-Beleg) steht nicht an
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht —
wellenlose Arbeit ist Baseline-Default,
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst);
Präzedenz [`slice-d-check-pin-bringt-den-go-sicherheitsfix`](../../done/slice-d-check-pin-bringt-den-go-sicherheitsfix.md)).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) — der Digest ist die Reproduzierbarkeits-Zusage, gepinnt und fail-closed · [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — kein Modul im Gate-Set ohne MR-054-Kriterien · [`MR-092`](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert) — der letzte d-check-Pin-Sprung, Form-Vorlage dieses Sprungs.

**Berührte Spec-Stellen:** [`spec/architecture.md §3`](../../../../spec/architecture.md#3-externe-abhängigkeiten) — `ARC-012` (d-check-Image-Lauf als Gate); der emittierte Default-Pin trägt keine eigene Kennung, der Verweis zeigt nach §3 aufwärts.

**Verantwortlich:** pt9912

**Autor:** Planner. **Datum:** 2026-11-25.

---

## 1. Ziel und Abgrenzung

**Ziel:** Der d-check-Pin springt `v0.86.1` → `v0.93.0` — `DCHECK_IMAGE`/`DCHECK_DIGEST` in [`d-check.mk`](../../../../d-check.mk) (Index-Digest `sha256:f7fb90800be0e3953bd8a64bc325a97a48bcaee08417f975fbb5996171846212`, aus dem Release-Objekt), der emittierte Default-Pin in [`internal/emit/emit.go`](../../../../internal/emit/emit.go) samt Kopfkommentar in derselben Lieferung, das Fragment frisch aus `d-check --print-mk` erzeugt (Deltas nur aus dem vom Werkzeug neu geschriebenen Teil, [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)/[`MR-062`](../../../../harness/conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff)), die Pin-Fassung der Kommentar-Blöcke `reviews`/`codepaths` in [`internal/emit/templates/d-check.yml`](../../../../internal/emit/templates/d-check.yml) nach [`MR-092`](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert)-Form, Gegenmessung nach [`MR-063`](../../../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen) auf Nicht-Null-Basis und der MR-Eintrag als Delta-Lesung über die acht Zwischenstände (kleiner Delta-Umfang — die Lesung läuft hier im Slice, anders als bei der v7-Welle, die sie separiert).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Sprung auf Baseline v7.0.0 (vendored Regelwerk)** — ein Folge-Slice übernimmt es: [`slice-baseline-vendorung-v7-0-0.md`](../open/slice-baseline-vendorung-v7-0-0.md) (Delta-Lesung: [`slice-baseline-delta-lesung-v7-0-0.md`](../open/slice-baseline-delta-lesung-v7-0-0.md)); hier berührt nur das **Werkzeug-Image**, nicht der vendored Kurs-Baum — zwei Pins, zwei Vorgänge, und die Baseline-Vorlagen von `d-check.mk`/`.d-check.yml` werden vom Sprung nicht gefasst.
- **Gate-Index [`harness/README.md`](../../../../harness/README.md) §Sensors** — Bestand bleibt bewusst stehen: kein Target wird neu, umbenannt oder umgebaut; das neue vierzehnte Target `doc-manual` aus dem Fragment (v0.89.0) ist advisory und trägt keinen Gate-Anspruch — es muss den Index nicht erweitern ([`MR-062`](../../../../harness/conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff) Marken-Form, kein `--enable`-Modul).
- **CI-Workflows und Mutations-Branch-Mechanik** — ein anderer Vorgang: der Push auf den CI-Branch ist **Teil der Lieferung** ([`MR-091`](../../../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt)), seine Mechanik bleibt byte-gleich; eine Änderung am Weg wäre eine eigene Entscheidung.
- **Messblock [`harness/conventions.md`](../../../../harness/conventions.md) §Zusatzklassen-Deklaration** — Übergabe-Artefakt an den **Architect-Zug** (Architect-Artefakte, eigener Commit-Zuschnitt, `AGENTS.md` §3.8), der nach diesem Slice kommt (Auftragsreihenfolge 2 → 3 → 1); nicht im Commit dieses Slices.
- **Modul-Aktivierungen** (die fünf neuen Stufen der Deltas, §3) — [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel) verlangt je Aktivierung Erprobung, grünen Start und ein rotes Gegenbeispiel; das ist je Modul ein eigener Vorgang mit eigener ADR und würde den Sprung verwandeln. Die Lesung benennt die Kandidaten (§3, Ansatz), die Wahl steht im selben Abschnitt.

## 2. Definition of Done

<!-- je Zeile ein pruefbares Kriterium; drei Liefer-Punkte. -->

- [ ] **Pin-Stand** ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)): alle drei Pin-Leben tragen `v0.93.0` — `d-check.mk` (`DCHECK_IMAGE ?= ghcr.io/pt9912/d-check:v0.93.0`, `DCHECK_DIGEST ?= sha256:f7fb9080…`, Kopfkommentar mit Zustandssatz), `internal/emit/emit.go` (`DefaultImage`/`DefaultDigest`, Kopfkommentar) und die Pin-Fassung der Kommentar-Blöcke `reviews`/`codepaths` (`internal/emit/templates/d-check.yml`, [`MR-092`](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert)-Form); `d-check --print-mk` frisch erzeugt und byte-gegen die Ist-Form gemessen — Deltas nur aus dem vom Werkzeug neu geschriebenen Teil, die fünf Handgriffe ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert), [`MR-062`](../../../../harness/conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff)) im Diff nachgemessen; Test: die gekoppelten Pin-Wächter (Implementer benennt die d-check-Form im ersten Lauf — `TestDefaultDigest_MatchesCanonical` hält den Digest, [`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)-Semantik).
- [ ] **Gegenmessung** ([`MR-063`](../../../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)): die Befund-Bilanz je aktivem Modul auf **Nicht-Null-Basis** (Dogfood-Stufenform wie in `MR-092` — unveränderter Bestand, entwertete Marker, Sonden, emittierte Form) gemessen am Pin `v0.93.0`; die Tabelle trägt der MR-Eintrag, kein Wert wird erwartet. — Messung dokumentiert im Eintrag.
- [ ] **MR-Eintrag + Index**: neuer Eintrag unter [`harness/conventions/`](../../../../harness/conventions/) (MR-094, Form folgt [`MR-092`](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert), **setzt MR-092 fort** — die d-check-Kette endet dort, [`MR-093`](../../../../harness/conventions.md#mr-093--a-check-pin-v0232-go-sicherheitsfix-prüfverhalten-unverändert) ist die a-check-Kette) mit der Delta-Lesung je Stufe `v0.87.0`…`v0.93.0` (je Stufe: Modul/Bedingung, Aktivierungs-Wahl, [`MR-086`](../../../../harness/conventions.md#mr-086--das-modul-reviews-bleibt-als-dritte-position-aus-dem-emittierten-doc-gate)-Positions-Prüfung), Index-Zeile in [`harness/conventions.md`](../../../../harness/conventions.md). Kein ADR — gleiche Befundmengen in der Gegenmessung ([`MR-092` §Kein ADR nötig](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert)).
- [ ] **Mutations-Runde** ([`AGENTS.md`](../../../../AGENTS.md) §3.6, Teil der Lieferung): Fallanlage an den geänderten Pin-Orten nach [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit); `make mutate-auswahl` nach dem Claim, Push auf den CI-Branch mit dem letzten Implementer-Commit ([`MR-091`](../../../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt)), Konsum vor der Verifikation.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update für die Pin-Segment-Fassung: die `v0.86.1`-Pin-Fassung der `MR-092`-Form ist in der `v0.93.0`-Fassung fortgeschrieben; der Gate-Index bleibt unverändert (§1).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

<!-- BEDIENHINWEIS: Datei- oder Komponenten-Ebene reicht; der
Implementer-Agent erweitert die Liste in seinem ersten Lauf, inklusive
einer Testdatei-Zeile mit der Akzeptanzkriterien-ID in `Begründung`
(Modul 9 §Minimal Agent Workflow). -->

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`d-check.mk`](../../../../d-check.mk) | update | Pin-Zeilen auf `v0.93.0`/`sha256:f7fb9080…`, Zustandssatz im Kopf; Fragment aus `d-check --print-mk` neu erzeugt, Deltas nur vom Werkzeug geschriebene Zeilen; die fünf Handgriffe nach [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)/[`MR-062`](../../../../harness/conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff) im Diff nachgemessen; das neue `doc-manual`-Target (v0.89.0) trägt keine Marke (kein `--enable`-Modul). Test: `test/doc-block-marke-wiring.bats` bleibt grün. |
| [`internal/emit/emit.go`](../../../../internal/emit/emit.go) | update | `DefaultImage`/`DefaultDigest` auf `v0.93.0` in derselben Lieferung wie der lebende Pin — fail-closed gekoppelt ([`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)); Test: die gekoppelte Form (`TestDefaultDigest_MatchesCanonical`) grün, Implementer benennt das Test-Set im ersten Lauf. |
| [`internal/emit/templates/d-check.yml`](../../../../internal/emit/templates/d-check.yml) | update | Pin-Fassung der Kommentar-Blöcke `reviews`/`codepaths` auf die `v0.93.0`-Fassung ([`MR-092`](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert)-Form); Test: `TestDCheckConfig_ReviewsBleibtKommentarBlock` grün. |
| `harness/conventions/MR-094-d-check-pin-v0930-…md` (Dateiname beim Anlegen festgelegt) | neu | Eintrag nach [`MR-092`](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert)-Form: Adaption mit Sprung über die acht Stufen, Strenge-Bilanz-Tabelle ([`MR-063`](../../../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)), Delta-Lesung je Stufe, `MR-086`-Positions-Fassung, Grenze, Auflösungs-Trigger permanent. |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | Index-Zeile MR-094 und die Zeile im Anpassungs-Zusammenhang — setzt [`MR-092`](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert) fort. |
| `test/mutations/<N>-<kennung>.sh` | neu | je geändertem Pin-Ort ein Fall, sed-Anker gegen den Quell-Bestand ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)), Anker am Claim-Commit ([`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)). |

**Ansatz:**

- Reihenfolge: Delta-Lesung (Upstream-CHANGELOG, Release-Bodies tragen den Digest je Tag) → Pin + Fragment + `emit.go` + Kommentare in **einer** Lieferung → Gegenmessung ([`MR-063`](../../../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen), Stufenform wie in [`MR-092`](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert)) → MR-094 → Mutations-Runde → Verifikation.
- **Delta-Lesung je Stufe** (Kurzfassung; der Eintrag trägt die volle):
  - `v0.87.0` — `trace.requirements` als Liste von Quellen (RTM; Objekt-Form bleibt gültig und byte-identisch, kein Module-Zug. Eine Kennung, die zwei Einträge erkennt, ist Exit 2). Kein `--enable`-Bedingungs-Zug.
  - `v0.87.1` — Security-Hebung in den Abhängigkeiten (go-git v5.19.3, x/net v0.61.0), keine Änderung der Konfiguration, der Grund-Codes oder der Ausgabe; Repo-intern CI-Range-Fallback (nicht Image).
  - `v0.88.0` — **nicht rein additiv:** `--trace` erkennt Slices mit Namens-Kennung ohne Konfiguration (die RTM eines Repos mit Namens-Slices ohne `trace`-Block wird breiter — Voraussetzungen hier über [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)); `hostpaths.variables` opt-in (keine Aktivierung).
  - `v0.89.0` — `--print-mk` trägt das vierzehnte Target `doc-manual`; das Fragment wächst, die fünf Handgriffe bleiben die Form ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)).
  - `v0.90.0` — neues Modul `metrics` (opt-in): Kennzahl eines Planungsdokuments gegen git-Messung; `metrics.*`-Schlüssel; byte-identisch ohne Aktivierung.
  - `v0.91.0` — neues Modul `pinsync` (opt-in): gleiche Werte an mehreren Dateistellen — naheliegend für die Pin-Kette dieses Repos ( fünf Pin-Stellen in [`harness/conventions.md`](../../../../harness/conventions.md) §Baseline); Aktivierung verlangt die [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)-Kriterien und eine ADR — benannt, kein Gegenstand dieses Slices.
  - `v0.92.0` — neues Modul `linelength` (opt-in): Zeichen je Zeile in Markdown; Security-Hebung (`x/net` v0.62.0), keine Änderung der Konfiguration oder der Ausgabe; byte-identisch ohne Aktivierung.
  - `v0.93.0` — `vcs.follow-renames` opt-in; **Zusagen-Änderung:** `linelength.exempt-tables` nimmt eingerückte Tabellenzeile (ein Bestand, der solche Zeilen trägt, wird grüner); `vcs --staged` Gitlink-Änderung (eine Abweichung ohne Schlüssel). Die zwei Verhaltens-Änderungen werden in der Gegenmessung gemessen.
- **Modul-Aktivierungswahl:** keine Aktivierung in diesem Slice ([`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)); jede Aktivierung (insbesondere `pinsync`) ist eigener Vorgang mit eigener ADR — benannt, nicht geplant.
- **[`MR-086`](../../../../harness/conventions.md#mr-086--das-modul-reviews-bleibt-als-dritte-position-aus-dem-emittierten-doc-gate)-Positions-Prüfung:** die Sonden mit aktivem `reviews` (`match: name` deckt nur den längsten passenden Basisnamen) laufen in der Gegenmessung wie in [`MR-092`](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert); die Positions-Aussage bleibt, solange die Befundmenge gleich bleibt — abweichend wäre ein ADR-/MR-Positions-Befund (Klasse [`BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus`](../observations/BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus/observation.md)).
- **Mutations-Runde:** Fallanzahl nach dem Claim messen (`make mutate-auswahl <Claim>..HEAD`); über neun Fällen → Push auf den CI-Branch Teil der Lieferung ([`MR-091`](../../../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt)), Konsum vor der Verifikation.

## 4. Trigger

**Start** (`next` → `in-progress`): der Auftrag des Auftraggebers ist eingetreten (dieser Slice liegt priorisiert in `next/`), und `make freshness-dcheck` meldet den neueren Tag `v0.93.0` gegen `DCHECK_IMAGE` — beobachtbar über den Lauf des Targets, kein Datum.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): die Delta-Lesung zeigt eine Verhaltens-Änderung, die ein **dogfood-aktives** Modul ohne Aktivierung umkonfigurieren müsste (neuer Pflicht-Schlüssel, geänderte Grund-Codes in einem der neun Module) — dann gehört die Konsequenz in einen eigenen Slice und der Pin-Sprung schrumpft auf das Umziehen.
- `in-progress` → `open` (blockiert — Carveout?): das Release-Objekt oder der Registry-Digest ist nicht erreichbar, oder die gekoppelte Pin-Fassung verliert ihre Quell-Form — dann wird die Frage offen gestellt, bevor gegen ein nicht verifizierbares Digest gezogen wird (Carveout statt `sha256:`-Blindflug).

## 5. Closure-Trigger

DoD vollständig (Pin-Stand byte-geprüft, Gegenmessung im MR-094-Eintrag, MR-Eintrag samt Index-Zeile, Mutations-Runde konsumiert) + die Pin-koppelnden Tests und `make docs-check` grün + Review-Report unter [`docs/reviews/`](../../../../docs/reviews/) + Closure-Notiz mit Lerneintrag — ohne ihn ist der Slice nur abgelegt. `make gates` läuft am Schluss: die Änderungen liegen im Baum-Hash, der Lauf fährt fail-closed voll (kein Stempel-Verlass auf einen Teilbaustand).

## 6. Risiken und offene Punkte

- Frisch erzeugtes `d-check --print-mk` schreibt Zeilen, die die fünf Handgriffe ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert), [`MR-062`](../../../../harness/conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff), Kopplung [`MR-061`](../../../../harness/conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv)) nicht decken — neue Ziel-Zeilen (`doc-manual`), geänderte Hilfe-Zeilen oder Marken-Formen. — **Ausgang:** <eingetreten: CO-NNN / slice-<Kennung> | entfallen: Grund | weiter offen: → BEO-<KUERZEL>/<slug> im Register>
- Die Fallmenge der Mutations-Fälle wächst über die neun ([`MR-091`](../../../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt)): drei geänderte Pin-Orte × Fälle plus die Bestands-Fälle, die denselben sed-Anker fassen. Der CI-Branch-Weg ist **geplanter Teil der Lieferung**; ein zweiter Push nach Infra-Unfällen (Re-Run) ist möglich, wie beim Fast-Pfad-Slice. — **Ausgang:** <eingetreten: CO-NNN / slice-<Kennung> | entfallen: Grund | weiter offen: → BEO-<KUERZEL>/<slug> im Register>
- Der emittierte Default-Pin driftet gegen `d-check.mk` — die fail-closed-Kopplung trägt ein Test-Set, das der Implementer benennt: [`TestDefaultDigest_MatchesCanonical`](../../../../internal/emit/) hält `DefaultDigest` an eine Kopie, aber kein Sensor hält den Pin gegen den Tag ([`BEO-ALL/pin-digest-ohne-waechter`](../observations/BEO-ALL/pin-digest-ohne-waechter/observation.md), verkörpert — 8 Belege); die Baseline-Klasse in `test/sources-pin.bats` pinnen den Baseline-Tag, nicht d-check. Fehlt eine d-check-koppelnde Form, nennt der MR-094-Eintrag die Grenze am Grenze-Feld ([`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)), nicht still. — **Ausgang:** <eingetreten: CO-NNN / slice-<Kennung> | entfallen: Grund | weiter offen: → BEO-<KUERZEL>/<slug> im Register>
- Die zwei Verhaltens-Änderungen ohne Schlüssel (`vcs --staged` Gitlink, geänderte `linelength.exempt-tables`-Zusage, v0.93.0) treffen den dogfood- oder emittierten Lauf — die Gegenmessung misst sie je Stufe; eine abweichende Befundmenge wäre kein [`MR-092`](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert)-Fall mehr und würde die ADR-Wahl im Eintrag neu stellen. — **Ausgang:** <eingetreten: CO-NNN / slice-<Kennung> | entfallen: Grund | weiter offen: → BEO-<KUERZEL>/<slug> im Register>
- Der Kopfkommentar-Zustandssatz in [`d-check.mk`](../../../../d-check.mk) wird vergessen — er nennt den Sprungstand und die fünf Handgriffe ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert), [`MR-062`](../../../../harness/conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff)); ohne ihn liest der nächste Lauf einen alten Stand als gültigen Pin, daneben datiert [`MR-053`](../../../../harness/conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen) die Werkzeug-Aussage. — **Ausgang:** <eingetreten: CO-NNN / slice-<Kennung> | entfallen: Grund | weiter offen: → BEO-<KUERZEL>/<slug> im Register>

## 7. Closure-Notiz

<!-- BEDIENHINWEIS — keine Norm; faellt beim Kopieren weg (README.md
§Verwendung, Schritt 5) und darf deshalb nichts Tragendes halten. Reihenfolge:
diese Sektion vor dem `git mv` nach done/ fuellen — einzige Ausnahme ist das
letzte DoD-Item in §2 (die Paarungen suchen in `done/`, also nach dem `git mv`).
Im Repo ohne Wellen-Betrieb braucht die Closure dadurch drei Commits: Inhalt,
`git mv`, Haekchen — das folgt aus der Hard Rule, es widerspricht ihr nicht. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Gegenstand:** <übernommen von `slice-<Kennung>` | entfallen: <Grund>>
  *(nur beim Ausgang ohne Arbeit; sonst Zeile löschen)*
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<KUERZEL>/<slug>` (<slice-kennung-a>, <slice-kennung-b>, <slice-kennung-c> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-<Kennung>.md` | `evidence/slice-<Kennung>.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-<Kennung> (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan — sie hängen weder am Modus noch am Slice-Typ. Bedingt
ist allein der Modus-Begründungsblock am Ende; deshalb nennt der Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** eine berührte Sub-Area, `*` (gesamtes Repo, Kürzel `ALL`): der Gegenstand ist die Gate-Konfiguration des ganzen Repos (`d-check.mk`, `.d-check.yml`) und der emittierte Default-Pin (`internal/emit/`); `internal/emit/` allein wird nicht ausdifferenziert — es trägt kein eigenes Kürzel und seine Pin-Fassung ist dieselbe Werkzeug-Aussage-Klasse (Pfad-Berührung plus Konventionen-Dichte über [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert), [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel), [`MR-063`](../../../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen), [`MR-092`](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert) — Schwelle ≥ 2 erfüllt).

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen. Treffer zur Sub-Area (Pin-Kette, Gate-Konfiguration), Stand gemessen auf dem Hauptzweig ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)): [`BEO-ALL/pin-digest-ohne-waechter`](../observations/BEO-ALL/pin-digest-ohne-waechter/observation.md) — `verkörpert`, 8 Belege; [`BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`](../observations/BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand/observation.md) — `geplant`, 6 Belege; [`BEO-ALL/strenge-bilanz-eines-pin-sprungs-fehlt-im-umsetzungs-commit`](../observations/BEO-ALL/strenge-bilanz-eines-pin-sprungs-fehlt-im-umsetzungs-commit/observation.md) — `offen`, 1 Beleg; [`BEO-ALL/pin-sprung-feuert-adr-trigger-ohne-nennung`](../observations/BEO-ALL/pin-sprung-feuert-adr-trigger-ohne-nennung/observation.md) — `offen`, 1; [`BEO-ALL/pin-sprung-macht-test-eingabe-gleich-default-die-zusage-unsichtbar`](../observations/BEO-ALL/pin-sprung-macht-test-eingabe-gleich-default-die-zusage-unsichtbar/observation.md) — `offen`, 1; [`BEO-ALL/aufruf-ohne-wirkung-am-pin-traegt-nur-eine-fixture`](../observations/BEO-ALL/aufruf-ohne-wirkung-am-pin-traegt-nur-eine-fixture/observation.md) — `offen`, 1. Alle unter der Schwelle 3; der Sprung trägt die Antworten der Klassen durch die [`MR-063`](../../../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)-Form und die `MR-092`-Pin-Fassung — kein 3×-Übertritt, kein eigener Folge-Slice.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF (Deklaration [`harness/conventions.md`](../../../../harness/conventions.md) §Modus-Deklaration pro Sub-Area — `*` GF); der Begründungsblock je Sub-Area entfällt, der Hinweis genügt.
