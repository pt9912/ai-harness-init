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
Präzedenz [`slice-d-check-pin-bringt-den-go-sicherheitsfix`](../done/slice-d-check-pin-bringt-den-go-sicherheitsfix.md)).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) — der Digest ist die Reproduzierbarkeits-Zusage, gepinnt und fail-closed · [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — kein Modul im Gate-Set ohne [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)-Kriterien · [`MR-092`](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert) — der letzte d-check-Pin-Sprung, Form-Vorlage dieses Sprungs.

**Berührte Spec-Stellen:** [`spec/architecture.md §3`](../../../../spec/architecture.md#3-externe-abhängigkeiten) — `ARC-012` (d-check-Image-Lauf als Gate); der emittierte Default-Pin trägt keine eigene Kennung, der Verweis zeigt nach §3 aufwärts.

**Verantwortlich:** pt9912

**Autor:** Planner. **Datum:** 2026-11-25.

---

## 1. Ziel und Abgrenzung

**Ziel:** Der d-check-Pin springt `v0.86.1` → `v0.93.0` — `DCHECK_IMAGE`/`DCHECK_DIGEST` in [`d-check.mk`](../../../../d-check.mk) (Index-Digest `sha256:f7fb90800be0e3953bd8a64bc325a97a48bcaee08417f975fbb5996171846212`, aus dem Release-Objekt), der emittierte Default-Pin in [`internal/emit/emit.go`](../../../../internal/emit/emit.go) samt Kopfkommentar in derselben Lieferung, das Fragment frisch aus `d-check --print-mk` erzeugt (Deltas nur aus dem vom Werkzeug neu geschriebenen Teil, [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)/[`MR-062`](../../../../harness/conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff)), die Pin-Fassung der Kommentar-Blöcke `reviews`/`codepaths` in [`internal/emit/templates/d-check.yml`](../../../../internal/emit/templates/d-check.yml) nach [`MR-092`](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert)-Form, Gegenmessung nach [`MR-063`](../../../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen) auf Nicht-Null-Basis — ihr Beleg trägt die Übergabe §9 (liegt vor) neben dem Zahl-Beleg der Commit-Message ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Sprung auf Baseline v7.0.0 (vendored Regelwerk)** — ein Folge-Slice übernimmt es: [`slice-baseline-vendorung-v7-0-0.md`](../done/slice-baseline-vendorung-v7-0-0.md) (Delta-Lesung: [`slice-baseline-delta-lesung-v7-0-0.md`](../done/slice-baseline-delta-lesung-v7-0-0.md)); hier berührt nur das **Werkzeug-Image**, nicht der vendored Kurs-Baum — zwei Pins, zwei Vorgänge, und die Baseline-Vorlagen von `d-check.mk`/`.d-check.yml` werden vom Sprung nicht gefasst.
- **Gate-Index [`harness/README.md`](../../../../harness/README.md) §Sensors** — Bestand bleibt bewusst stehen: kein Target wird neu, umbenannt oder umgebaut; das neue vierzehnte Target `doc-manual` aus dem Fragment (v0.89.0) ist advisory und trägt keinen Gate-Anspruch — es muss den Index nicht erweitern ([`MR-062`](../../../../harness/conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff) Marken-Form, kein `--enable`-Modul).
- **CI-Workflows und Mutations-Branch-Mechanik** — ein anderer Vorgang: der Push auf den CI-Branch ist **Teil der Lieferung** ([`MR-091`](../../../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt)), seine Mechanik bleibt byte-gleich; eine Änderung am Weg wäre eine eigene Entscheidung.
- **Messblock [`harness/conventions.md`](../../../../harness/conventions.md) §Zusatzklassen-Deklaration** — Übergabe-Artefakt an den **Architect-Zug** (Architect-Artefakte, eigener Commit-Zuschnitt, `AGENTS.md` §3.8), der nach diesem Slice kommt (Auftragsreihenfolge 2 → 3 → 1); nicht im Commit dieses Slices.
- **Modul-Aktivierungen** (die fünf neuen Stufen der Deltas, §3) — [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel) verlangt je Aktivierung Erprobung, grünen Start und ein rotes Gegenbeispiel; das ist je Modul ein eigener Vorgang mit eigener ADR und würde den Sprung verwandeln. Die Lesung benennt die Kandidaten (§3, Ansatz), die Wahl steht im selben Abschnitt.
- **MR-Eintrag für diesen Sprung** — Entscheidung des Auftraggebers: entfällt. Begründung: der
  Adaptions-Block ist nach dem Baseline-Wortlaut (`grundlagen-harness-dateien.md`
  §harness/conventions.md als Konventionsspeicher) der **Index der Abweichungen**, und ein
  Pin-Sprung ist keine — die Eintrags-Praxis ist eine repo-eigene Setzung seit
  [`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)
  und wird für diesen Sprung nicht fortgesetzt. Der Bestand
  [`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)…[`MR-092`](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert)
  bleibt bewusst
  bestehen (append-only, kein Rückbau); die Aussagen, deren Träger der Eintrag gewesen wäre,
  tragen der Zahl-Beleg der Commit-Message ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung))
  und §9 — Werkzeug-Deltas je Stufe §9.1, ADR-Wahl §9.2, Grenze der `vcs --staged`-Sonde §9.4;
  die Delta-Lesung bleibt als Kurzfassung in §3.
- **F-1 (Review) — Aufteilung der Gegenmessung je Modul und Grund-Code** — Bestand bleibt bewusst
  stehen (Auftraggeber-Setzung, 2026-11-25): die Gegenmessung bleibt in der Summen-Form je Stufe
  (§9.2); die Verteilung je Modul und Grund-Code wird **nicht** nachgeliefert. Begründung: keine
  funktionale Abweichung — alle fünf Stufen byte-gleich; der Mess-Kern (je Stufe alle neun Module
  mit Basis) bleibt in den Zahl-Belegen der Commit-Messages `625cdef0`/`aa2cee57`
  ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung));
  die Fassung des Bestands
  ([`MR-063`](../../../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen))
  bleibt für künftige Sprünge unverändert.
- **F-2 (Review) + Verifier-Turn — Kopie-Integritäts-Bedingung und separater
  Verifikations-Lauf** — Auftraggeber-Setzung (2026-11-25, Zeitbudget „max 15 Minuten"): die
  Symlink-/Kopie-Integritäts-Bedingung der Gegenmessung
  ([`MR-063`](../../../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)
  Setzung 2, [`MR-067`](../../../../harness/conventions.md#mr-067--eine-aufbau-anleitung-nennt-ihre-prüf-bedingung-vor-ihren-kommandos))
  bleibt unbenannt **und** der separate Verifier-Turn entfällt — beide unter demselben Beschluss.
  Die Belege, die der Verifier sonst trug, trägt die Session-Verifikation: Stempel
  `.harness/state/gates-passed.head` deckt `a5877411`, `make freshness-dcheck` Exit 0,
  CI-Urteil der Mutations-Probe grün 82/82 (§9.7). Die Lücke ist an dieser Stelle benannt, nicht
  durch einen grünen Sensor verdeckt.

## 2. Definition of Done

<!-- je Zeile ein pruefbares Kriterium; zwei Liefer-Punkte. -->

- [x] **Pin-Stand** ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)): alle drei Pin-Leben tragen `v0.93.0` — `d-check.mk` (`DCHECK_IMAGE ?= ghcr.io/pt9912/d-check:v0.93.0`, `DCHECK_DIGEST ?= sha256:f7fb9080…`, Kopfkommentar mit Zustandssatz), `internal/emit/emit.go` (`DefaultImage`/`DefaultDigest`, Kopfkommentar) und die Pin-Fassung der Kommentar-Blöcke `reviews`/`codepaths` (`internal/emit/templates/d-check.yml`, [`MR-092`](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert)-Form); `d-check --print-mk` frisch erzeugt und byte-gegen die Ist-Form gemessen — Deltas nur aus dem vom Werkzeug neu geschriebenen Teil, die fünf Handgriffe ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert), [`MR-062`](../../../../harness/conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff)) im Diff nachgemessen; Test: die gekoppelten Pin-Wächter (Implementer benennt die d-check-Form im ersten Lauf — `TestDefaultDigest_MatchesCanonical` hält den Digest, [`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)-Semantik).
- [x] **Gegenmessung** ([`MR-063`](../../../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)): die Befund-Bilanz je aktivem Modul auf **Nicht-Null-Basis** (Dogfood-Stufenform wie in [`MR-092`](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert) — unveränderter Bestand, entwertete Marker, Sonden, emittierte Form) gemessen am Pin `v0.93.0`; die Tabelle trägt die Übergabe der Slice-Datei §9 (liegt vor) und den Zahl-Beleg der Commit-Message ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)), kein Wert wird erwartet.
- [x] **Mutations-Runde** ([`AGENTS.md`](../../../../AGENTS.md) §3.6, Teil der Lieferung): Fallanlage an den geänderten Pin-Orten nach [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit); `make mutate-auswahl` nach dem Claim, Push auf den CI-Branch mit dem letzten Implementer-Commit ([`MR-091`](../../../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt)), Konsum vor der Verifikation.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update für die Pin-Segment-Fassung: die `v0.86.1`-Pin-Fassung der [`MR-092`](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert)-Form ist in der `v0.93.0`-Fassung fortgeschrieben; der Gate-Index bleibt unverändert (§1).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft; Ergebnis in §7, nach dem `git mv` (die Paarungen suchen in `done/`).

**Belege der Häkchen (Closure 2026-11-25, Planner in eigenem Kontext, [`AGENTS.md`](../../../../AGENTS.md) §3.10):**

- *Pin-Stand / Gegenmessung / Mutations-Runde:* Commit `625cdef0` (Diff, Hunk-Kommando 6, §9.1), Gegenmessung §9.2 — fünf Stufen byte-gleich, Zahl-Belege `625cdef0`/`aa2cee57` ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)); Fallanlage 786–789 und CI-Konsum Run 45625795106, Attempt 3, Urteil grün 82/82 (§9.7, Träger Job-Log).
- *`make gates`:* Stempel `.harness/state/gates-passed.head` = `a5877411` = Review-HEAD (Review-Negativbefund Stempel-Lage); der Schluss-Stempel-Lauf trägt der Session-Kontext — kein Verifier-Turn (§1, F-2).
- *Review:* [`docs/reviews/2026-11-25-slice-d-check-sprung-v0930.md`](../../../reviews/2026-11-25-slice-d-check-sprung-v0930.md) — 0 HIGH, kein blockierendes Verdikt.
- *Doku-Update:* keines nötig — kein Target neu, keine Zelle des Gate-Index geändert (§1); die Pin-Fassung der Kommentar-Blöcke zog in derselben Lieferung (`625cdef0`); pin-datierte Handbuch-Prosa bleibt benannter Rest (F-4, §7).
- *Closure-Notiz / Register / Risiken:* §7 dieser Datei (dieser Commit); §6 — jede Zeile mit Ausgang.

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
| `.d-check.yml` | update | der neue Target-Zeile `doc-manual` in `d-check.mk` (`targets`-Modul, `authority` `harness/README.md`) trägt einen `exempt-targets`-Eintrag (Gruppe (b) — Hilfetext, kein Gate-Versprechen); der Gate-Index bleibt unverändert (§1). |
| `test/mutations/<N>-<kennung>.sh` | neu | je geändertem Pin-Ort ein Fall, sed-Anker gegen den Quell-Bestand ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)), Anker am Claim-Commit ([`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)). |

**Ansatz:**

- Reihenfolge: Delta-Lesung (Upstream-CHANGELOG, Release-Bodies tragen den Digest je Tag) → Pin + Fragment + `emit.go` + Kommentare in **einer** Lieferung → Gegenmessung ([`MR-063`](../../../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen), Stufenform wie in [`MR-092`](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert)) → Mutations-Runde → Verifikation.
- **Delta-Lesung je Stufe** (Kurzfassung):
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

DoD vollständig (Pin-Stand byte-geprüft, Gegenmessung in §9 mit dem Zahl-Beleg der Commit-Message ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)), Mutations-Runde konsumiert) + die Pin-koppelnden Tests und `make docs-check` grün + Review-Report unter [`docs/reviews/`](../../../../docs/reviews/) + Closure-Notiz mit Lerneintrag — ohne ihn ist der Slice nur abgelegt. `make gates` läuft am Schluss: die Änderungen liegen im Baum-Hash, der Lauf fährt fail-closed voll (kein Stempel-Verlass auf einen Teilbaustand).

## 6. Risiken und offene Punkte

- Frisch erzeugtes `d-check --print-mk` schreibt Zeilen, die die fünf Handgriffe ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert), [`MR-062`](../../../../harness/conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff), Kopplung [`MR-061`](../../../../harness/conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv)) nicht decken — neue Ziel-Zeilen (`doc-manual`), geänderte Hilfe-Zeilen oder Marken-Formen. — **Ausgang:** entfallen — der frisch erzeugte Fragment-Diff trägt genau die
  drei Deltas-Klassen der fünf Handgriffe: Pin-Zeile, drei `--disable`-Anhänge an denselben sechs
  fokussierten advisory-Recipes, `doc-manual` verbatim hinter `doc-usage` und ohne
  `--enable`-Modul (§9.1, Hunk-Kommando 6); das Target fällt unter den `exempt-targets`-Eintrag
  (`exempt-targets`-Eintrag, kein Gate-Anspruch — Review-Negativbefund „Werkzeug-Deltas des
  Fragments").
- Die Fallmenge der Mutations-Fälle wächst über die neun ([`MR-091`](../../../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt)): drei geänderte Pin-Orte × Fälle plus die Bestands-Fälle, die denselben sed-Anker fassen. Der CI-Branch-Weg ist **geplanter Teil der Lieferung**; ein zweiter Push nach Infra-Unfällen (Re-Run) ist möglich, wie beim Fast-Pfad-Slice. — **Ausgang:** weiter offen → `BEO-ALL/mutations-ci-gruenvorlauf-bricht-unter-last`
  im Register (neu, 1 Beleg) — die Fallmenge (82) und der geplante CI-Branch-Weg haben getragen
  (Run 45625795106, Attempt 3, Urteil grün 82/82, Konsum-Träger Job-Log, §9.7); offen bleibt der
  Bruch des grünen Vorlaufs unter infrastruktureller Last, nicht die Fallzahl-Achse.
- Der emittierte Default-Pin driftet gegen `d-check.mk` — die fail-closed-Kopplung trägt ein Test-Set, das der Implementer benennt: [`TestDefaultDigest_MatchesCanonical`](../../../../internal/emit/) hält `DefaultDigest` an eine Kopie, aber kein Sensor hält den Pin gegen den Tag ([`BEO-ALL/pin-digest-ohne-waechter`](../observations/BEO-ALL/pin-digest-ohne-waechter/observation.md), verkörpert — 8 Belege); die Baseline-Klasse in `test/sources-pin.bats` pinnen den Baseline-Tag, nicht d-check. Fehlt eine d-check-koppelnde Form, trägt die Übergabe §9.4 die Grenze — die Sonde reproduziert die im CHANGELOG von v0.93.0 dokumentierte Differenz (Alt: Exit 2 `object not found`, neu: `core-drift-vcs`) nicht — nicht still ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung): Zahl-Beleg der Commit-Message). — **Ausgang:** entfallen — die gekoppelte Form steht und ist
  belegt: Fallanlage 786–789 am Quell-Bestand ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit), Review-Negativbefund Mutations-Fälle),
  Wächter `TestDefaultDigest_MatchesCanonical`/`TestDefaultImage_MatchesCanonical`; die Grenze
  der `vcs --staged`-Sonde trägt §9.4 wie geplant — benannt, nicht verdeckt.
- Die zwei Verhaltens-Änderungen ohne Schlüssel (`vcs --staged` Gitlink, geänderte `linelength.exempt-tables`-Zusage, v0.93.0) treffen den dogfood- oder emittierten Lauf — die Gegenmessung misst sie je Stufe; eine abweichende Befundmenge wäre kein [`MR-092`](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert)-Fall mehr und würde die ADR-Wahl neu stellen — ihre Begründung (byte-gleich je Stufe) trägt §9.2 neben dem Zahl-Beleg der Commit-Message
  ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)).
  — **Ausgang:** entfallen — beide Module opt-in, in keinem Prüfbereich aktiv, je gemessen (§9.3
  `linelength.exempt-tables`, §9.4 `vcs --staged`-Gitlink) und byte-gleich in §9.2; die ADR-Wahl
  stellt sich nicht neu ([`MR-092`](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert)-Fall: gleiche Befundmengen, AGENTS §3.5).
- Der Kopfkommentar-Zustandssatz in [`d-check.mk`](../../../../d-check.mk) wird vergessen — er nennt den Sprungstand und die fünf Handgriffe ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert), [`MR-062`](../../../../harness/conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff)); ohne ihn liest der nächste Lauf einen alten Stand als gültigen Pin, daneben datiert [`MR-053`](../../../../harness/conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)
  die Werkzeug-Aussage. — **Ausgang:** entfallen — der Zustandssatz trägt den Sprungstand und die
  fünf Handgriffe (Commit `625cdef0`, Review-Negativbefund Pin-Stand); [`MR-053`](../../../../harness/conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)
  wird beim nächsten Sprung weiter gelesen.

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

**Rolle:** Planner · **Datum:** 2026-11-25

- **Was hat funktioniert:** der Pin zog dreifach in einer Lieferung (`625cdef0` — `d-check.mk`,
  `internal/emit/emit.go`, Pin-Fassung der Kommentar-Blöcke; Review-Negativbefund Pin-Stand), der
  Fragment-Diff brachte genau 6 Werkzeug-Deltas (§9.1, Hunk-Kommando), die Gegenmessung lief
  schlagfertig über alle fünf Stufen byte-gleich (§9.2), die CI-Runde lief parallel zum Review und
  ihr Konsum war vor der Verifikation fertig (Run 45625795106, Attempt 3, Urteil grün 82/82, §9.7).
- **Was ging anders als geplant:** drei CI-Versuche der Mutations-Probe — zwei Vorlauf-Abbrüche
  unter Last (Versuche 1/2), das Docker-Image-Namen-Rennen im 4-worker-Lauf; Attempt 3 trug das
  Urteil (§9.7). Der Auftraggeber stellte die MR-Eintrag-Praxis für diesen Sprung ab (§1) und
  schloss mit dem Zeitbudget („max 15 Minuten") die Nachlieferung der Beleg-Form (F-1/F-2) und den
  separaten Verifier-Turn aus — beides ausdrückliche Setzungen in §1.
- **Benannte Reste (Review-Findings, nicht geliefert):**
  - F-3 (LOW): der `roadmap.md`-Handgriff ist in §3 der Plan-Tabelle nicht verzeichnet — getragen
    an der Commit-Message `625cdef0` (Handgriff wie `70ed9c0c`).
  - F-4 (LOW): pin-datierte Handbuch-Prosa, [`docs/user/benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md)
    Zeilen 816/826 (`v0.86.1`/`v0.86.x`) — vom Diff unberührt, Bestand.
  - F-5 (INFO): das `--trace`-Delta der Namens-Kennungen (v0.88.0) ohne Messstufe — wirksam nur in
    den advisory-Targets `doc-trace`/`doc-complete`, kein Gate-Lauf.
  - F-6 (INFO): der `ergebnis`-Job der Mutations-CI ist strukturell re-run-ungeeignet
    (non-fast-forward) — Konsum-Träger bleibt das Job-Log (§9.7).
- **Steering-Loop-Eintrag:** Beobachtung, gezählt nicht verkörpert (unter der Schwelle, kein
  `liegt in`-Feld): `BEO-ALL/mutations-ci-gruenvorlauf-bricht-unter-last` — der grüne Vorlauf der
  Mutations-Probe bricht unter infrastruktureller Last, bevor ein Fall urteilt; drei Auftreten
  heute (2 Vorlauf-Abbrüche der Versuche 1/2, Docker-Image-Namen-Rennen im 4-worker-Lauf, §9.7),
  alle in einem Vorgang — der Zähler folgt aus der Evidence-Datei.
- **Beobachtungs-Register (`../observations/`):** `BEO-ALL/mutations-ci-gruenvorlauf-bricht-unter-last/`
  neu angelegt, Beleg `evidence/slice-d-check-sprung-v0930.md` (Zähler 1×) ·
  `evidence/slice-d-check-sprung-v0930.md` in `BEO-ALL/baum-hash-deckt-nicht-jeden-pruefgegenstand/`
  ergänzt — Zähler 3×; Lese-Schritt dieser Closure: Ausgang *verkörpert* — die Klasse trägt als
  bewusst benannter Rest in
  [`ADR-0035`](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  (Festlegung 4, Träger `MUTATE_FORCE`); der Zielort bestand vor dem Anker-System und trägt keinen
  `seit …`-Anker (Immutabilität, [`AGENTS.md`](../../../../AGENTS.md) §3.4) — die Grenze benannt.
- **Archivierung:** entfällt — wellenlos; das `archive-slice`-Unterkommando von
  [`MR-078`](../../../../harness/conventions.md#mr-078--wellenlose-slices-werden-bei-der-eigenen-closure-archiviert)
  ist nicht gebaut (wie beim Vorgänger-Slice bewusst nicht vollzogen).
- **Folge-Slices:** keiner.
- **Risiken aus §6:** jede Zeile mit Ausgang — siehe §6.
- **Drei Paarungen (geprüft am 2026-11-25, nach dem `git mv`):**
  - *(a) Anker:* §7 trägt kein `liegt in`-Feld — der Steering-Loop-Eintrag ist gezählt, nicht
    verkörpert; kein Gegenstand. Die im Register *verkörperte* Klasse
    `baum-hash-deckt-nicht-jeden-pruefgegenstand` ist in einer ADR verkörpert, nicht in einem
    `liegt in`-Feld — ebenfalls kein Gegenstand der Paarung; die Grenze trägt §7 (kein
    `seit …`-Anker am Zielort, benannt).
  - *(b) Folge-Slice:* die in §1 genannten übernehmenden Slices existieren im Lifecycle —
    [`done/slice-baseline-vendorung-v7-0-0.md`](../done/slice-baseline-vendorung-v7-0-0.md) und
    [`done/slice-baseline-delta-lesung-v7-0-0.md`](../done/slice-baseline-delta-lesung-v7-0-0.md). Grün.
  - *(c) Register:* beide in §7 genannten Beobachtungen existieren und tragen je mindestens einen
    Beleg — [`../observations/BEO-ALL/mutations-ci-gruenvorlauf-bricht-unter-last/observation.md`](../observations/BEO-ALL/mutations-ci-gruenvorlauf-bricht-unter-last/observation.md),
    [`../observations/BEO-ALL/baum-hash-deckt-nicht-jeden-pruefgegenstand/observation.md`](../observations/BEO-ALL/baum-hash-deckt-nicht-jeden-pruefgegenstand/observation.md). Grün.

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

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen. Treffer zur Sub-Area (Pin-Kette, Gate-Konfiguration), Stand gemessen auf dem Hauptzweig ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)): [`BEO-ALL/pin-digest-ohne-waechter`](../observations/BEO-ALL/pin-digest-ohne-waechter/observation.md) — `verkörpert`, 8 Belege; [`BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`](../observations/BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand/observation.md) — `geplant`, 6 Belege; [`BEO-ALL/strenge-bilanz-eines-pin-sprungs-fehlt-im-umsetzungs-commit`](../observations/BEO-ALL/strenge-bilanz-eines-pin-sprungs-fehlt-im-umsetzungs-commit/observation.md) — `offen`, 1 Beleg; [`BEO-ALL/pin-sprung-feuert-adr-trigger-ohne-nennung`](../observations/BEO-ALL/pin-sprung-feuert-adr-trigger-ohne-nennung/observation.md) — `offen`, 1; [`BEO-ALL/pin-sprung-macht-test-eingabe-gleich-default-die-zusage-unsichtbar`](../observations/BEO-ALL/pin-sprung-macht-test-eingabe-gleich-default-die-zusage-unsichtbar/observation.md) — `offen`, 1; [`BEO-ALL/aufruf-ohne-wirkung-am-pin-traegt-nur-eine-fixture`](../observations/BEO-ALL/aufruf-ohne-wirkung-am-pin-traegt-nur-eine-fixture/observation.md) — `offen`, 1. Alle unter der Schwelle 3; der Sprung trägt die Antworten der Klassen durch die [`MR-063`](../../../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)-Form und die [`MR-092`](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert)-Pin-Fassung — kein 3×-Übertritt, kein eigener Folge-Slice.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF (Deklaration [`harness/conventions.md`](../../../../harness/conventions.md) §Modus-Deklaration pro Sub-Area — `*` GF); der Begründungsblock je Sub-Area entfällt, der Hinweis genügt.

---

## 9. Übergabe (Implementer → Architect)

**Entscheidung des Auftraggebers:** kein MR-Eintrag für diesen Sprung (§1). Dieser Abschnitt
trägt die Übergabe an den Architect; ihr Konsum liest die Zahl-Belege der Gegenmessung aus den
Commit-Messages `625cdef0`/`aa2cee57`
([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung))
und die Mess-Worte der zwei Verhaltensstufen aus §9.3/§9.4:

1. **Pin-Zug:** Dreifach-Kongruenz Release-Objekt (`gh api
   repos/pt9912/d-check/releases/tags/v0.93.0`, Pin-Zeile im Body) → Registry-Index
   (`docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.93.0`) → Pull. Werkzeug-Deltas
   `v0.86.1` → `v0.93.0` am Fragment: Pin-Zeile, drei `--disable metrics --disable pinsync
   --disable linelength`-Anhänge an denselben sechs fokussierten advisory-Recipes, vierzehntes
   Target `doc-manual` (v0.89.0) verbatim hinter `doc-usage`, ohne `--enable`-Modul ohne Marke.
   Hunk-Kommando im Kopf: 6.
2. **Gegenmessung ([`MR-063`](../../../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen), Stufenform wie in [`MR-092`](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert)):** netzlos, je Digest ein Lauf über
   `git archive`-Kopie von `625cdef0` (Klon aus dem lokalen Repo, kein Objektspeicher,
   [`MR-065`](../../../../harness/conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)
   Setzung 1); Digest per Override.
   - Stufe 1 (unveränderter Bestand): 2977 Dateien, 0 Befunde — alt/neu byte-gleich.
   - Stufe 2 (Marker entwertet): 97 Befunde (60 `codepath-missing`, 37 `id-unlinked`) — byte-gleich.
   - Stufe 3 (Sonden): 110 Befunde, 11 Grund-Codes, alle neun Module mit Basis — byte-gleich
     (`span-unclosed` ohne eigene Sonden-Basis; Modul-Basis über `span-nested-link`/`fence-unclosed`).
   - Stufe 4 (Ziel `--lang go` unverändert): 21 Dateien, 0 Befunde — byte-gleich.
   - Stufe 5 (Ziel mit Sonden): 23 Dateien, 13 Befunde, 9 Grund-Codes, alle neun Module mit
     Basis — byte-gleich. Gleiche Mengen in allen Stufen ⇒ kein ADR (§3.5 — keine Senkung; die Belege stehen in dieser
   Stufenliste und im Zahl-Beleg der Commit-Messages,
   [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)).
3. **`linelength.exempt-tables`** (eingerückte Tabellenzeile, ≤ 3 Leerzeichen vor dem ersten
   `|` gemessen): am neuen Pin mit Default-Ausnahme **0 Befunde** für den Sonden-Bestand
   (eingerückte Zeile > 100 Zeichen ausgenommen), mit `exempt-tables: false` **2 Befunde**
   (`line-chars-exceeded` je Zeile) — die Differenz ist die neue Zusage; am alten Pin ist das
   Modul nicht vorhanden (`v0.92.0`), die Konfiguration Exit 2 (`field linelength not found`).
   Opt-in, in keinem der beiden Prüfbereiche aktiv — keine Senkung im Gate.
4. **`vcs --staged` Gitlink:** Sonde `spec.md` mit `<!-- immutable: sha256:<core-hash> -->`
   (Core-Hash über die Whitespace-kollabierte Fassung berechnet; Basis `--range` je Pin
   0 Befunde), danach Gitlink an dem Pfad im Index. Messung: **beide Pins 0 Befunde** — die
   im CHANGELOG von v0.93.0 dokumentierte Differenz (Alt: Exit 2 `object not found`, neu:
   `core-drift-vcs`) ist mit dieser Sonde **nicht reproduziert**; die Grenze trägt diese
   Stelle (versioniert) neben dem Zahl-Beleg der Commit-Message
   ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)),
   nicht verdeckt. Beide Module opt-in, in keinem Prüfbereich aktiv.
5. **[`MR-086`](../../../../harness/conventions.md#mr-086--das-modul-reviews-bleibt-als-dritte-position-aus-dem-emittierten-doc-gate)-Nachmessung** (Sonden mit aktivem `reviews`, emittiertes Ziel, am neuen Pin;
   Kontroll am alten): leerer `done-dir` → fail-closed `review-missing`; `slice-cache` +
   `slice-cache-warmup` mit Report nur für den längeren → `review-missing` für
   `slice-cache` (`match: name` deckt nur den längsten passenden Basisnamen); Reports für
   beide → Exit 0; Ziffern-Plan mit Report → Exit 0; alter Pin Exit 0. Die Positions-Aussage
   bleibt, keine Kopf-Marke (Setzung 4-Fassung wie in [`MR-092`](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert)).
6. **`gate-undocumented`:** das neue `doc-manual` fiel im Lauf des Moduls `targets` auf; der
   Ausspruch lebt als `exempt-targets`-Eintrag (Gruppe (b), Makefile-Hilfetext) in
   `.d-check.yml`, nicht als Index-Zeile (§1).
7. **Mutations-Treiber, 4 Worker:** die Fälle 786/787 starben im 4-Worker-Lauf am
   Docker-Image-Namen-Rennen der parallelen `test-go`-Builds („No such image" nach dem
   buildx-Export), mit `MUTATE_JOBS=1` rot gesehen; das Verdikt hängt laut Kopf von
   [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) nicht an der Worker-Zahl.
   Kandidat für einen Register-Eintrag (Schreib-Schritt der Closure, nicht dieser Lauf). Konsum
   der Probe: das Urteil trägt das `ergebnis`-Job-Log des CI-Branch-Laufs (Run 45625795106,
   Attempt 3, Urteil grün 82/82) — `mutate-ergebnis.txt` ging mit dem Ergebnis-Commit nicht
   auf den Branch (non-fast-forward); der Konsum liest darum das Job-Log statt das
   Ergebnis-File.
