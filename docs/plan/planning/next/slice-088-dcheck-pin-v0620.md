# Slice slice-088: d-check-Pin v0.51.1 → v0.62.0 (elf Minors; `structure` wird verfügbar)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (reaktiv — der Pin ist veraltet) — gegen
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1 geprüft, alle drei Fragen samt Antwort in §3.

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) — der Pin **ist** die
Reproduzierbarkeit: ein Tag ohne Digest ist ein bewegliches Ziel, und ein Pin, der an mehreren
Orten steht, ist nur dann einer, wenn alle gleichzeitig wandern.
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — das
neue Modul `structure` wird **verfügbar gemacht, nicht aktiviert**; ein leer aktiviertes Modul
wäre ein Phantom-Gate, und kein neuer Gate-Name entsteht.
[`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile) —
das Muster: **Trockenlauf vor dem Pin**, netzlos, mit ausgewiesener Befund-Differenz.
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) — das
Fragment ist tool-generiert; die vier Handgriffe der Re-Adaption (`docs-check`, `doc-help`-Grep,
`DCHECK_DIGEST`, Kopfkommentar) stehen dort, nicht hier.
[`MR-012`](../../../../harness/conventions.md#mr-012--d-check-pin-v0511-sources-verfügbar) — der
Eintrag, den dieser Sprung fortsetzt; sein Auflösungs-Trigger ist genau dieser Slice-Typ.

**Autor:** Planner. **Datum:** 2026-08-22.

---

## 1. Ziel

**Das gepinnte d-check-Image steht auf v0.62.0 — an jedem Ort, der den Pin führt, mit dreifach
belegtem Digest und einem netzlosen Trockenlauf, der die Befund-Differenz ausweist.**

Der Sensor hat gefeuert: `make freshness-dcheck` meldet gepinnt **v0.51.1** gegen latest
**v0.62.0** — **elf** Minor-Releases (v0.52.0 vom 2026-08-09 bis v0.62.0 vom 2026-08-21). Der
Sprung ist die Fortsetzung der
[`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)/[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)/[`MR-012`](../../../../harness/conventions.md#mr-012--d-check-pin-v0511-sources-verfügbar)-Linie
und nichts darüber hinaus.

**Was der Slice ausdrücklich NICHT tut: das neue Modul `structure` aktivieren.** v0.62.0 bringt es
als 20. Modul samt eigenem advisory-Target mit; es wird **verfügbar**, wie `sources` es mit
[`MR-012`](../../../../harness/conventions.md#mr-012--d-check-pin-v0511-sources-verfügbar) wurde.
Ob dieses Repo eine Struktur-Prüfung will, ist eine Frage an den Prüfbereich und an die Strenge —
sie gehört in einen eigenen Schnitt mit eigenem False-Positive-Risiko, nicht in einen Pin
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

## 2. Definition of Done

Jeder Punkt nennt das Kommando, das ihn rot färbt — eine Zusage reicht nur so weit wie ihr Sensor
([slice-086](../done/slice-086-vordergrund-per-updatedinput.md) §7).

- [ ] **(1) Der Pin steht auf v0.62.0 an allen fünf Orten, die ihn führen — gleichzeitig.**
      [`d-check.mk`](../../../../d-check.mk) (`DCHECK_IMAGE`, `DCHECK_DIGEST`, Kopfkommentar),
      [`Makefile`](../../../../Makefile) (das Tag-Beispiel im Kommentar über `DCHECK_TAG`),
      [`internal/emit/emit.go`](../../../../internal/emit/emit.go) (`DefaultImage`/`DefaultDigest`)
      sowie [`harness/conventions.md`](../../../../harness/conventions.md) §Baseline **und** ein
      neuer MR-Eintrag. Der Digest ist **dreifach belegt** — lokaler RepoDigest ·
      `docker buildx imagetools inspect` · d-check-Release —, gemessen am 2026-08-22:
      `sha256:3996a593b9cb71aa3bcb4f3ddf8f637e7409db31b3a2dac7eedc28d65814cacf`
      ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).

      **Rot färbt ihn zweierlei:** `make test` über
      [`internal/emit/emit_test.go`](../../../../internal/emit/emit_test.go)
      (`TestDefaultImage_MatchesCanonical`/`TestDefaultDigest_MatchesCanonical` lesen
      [`d-check.mk`](../../../../d-check.mk) und fallen, wenn der Emitter-Pin nachhinkt) und die
      Rest-Suche `grep -rn 'v0\.51\.1\|fede3d02' --exclude-dir=.git --exclude-dir=docs
      --exclude-dir=.harness .` → **leer**. Der Ausschluss von `docs/` ist kein Beiwerk: dieser
      Plan führt die alte Version selbst, und eine Suche, die ihn mitliest, wird per Konstruktion
      fündig.

      **Der [`harness/conventions.md`](../../../../harness/conventions.md)-Anteil gehört dem
      Architect** ([`AGENTS.md`](../../../../AGENTS.md) §3.8): §Baseline-Zeile und MR-Eintrag
      landen in einem **eigenen** Commit, der nur Artefakte dieser Rolle berührt und die Rolle in
      seiner Message nennt.
- [ ] **(2) `d-check.mk` ist frisch aus `--print-mk` (v0.62.0) erzeugt und re-adaptiert; das neue
      Modul `structure` ist verfügbar, aber NICHT aktiviert.** Die
      [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)-Handgriffe
      sind vollzogen (`doc-check` → `docs-check` als Target **und** im Hilfetext, `doc-help`-Grep
      auf `docs?-`, `DCHECK_DIGEST` gepinnt, adaptierter Kopfkommentar). Alles Übrige ist
      **verbatim vom Tool** — auch das neue Target `doc-structure` und das neue
      `--disable structure` in den fokussierten advisory-Recipes.

      **Rot färbt ihn:** `grep -c 'structure' .d-check.yml` → **0** (das Modul steht in keiner
      `modules:`-Liste) und `grep -n 'docs-check' d-check.mk` → nicht leer;
      [`AGENTS.md`](../../../../AGENTS.md) §4 und [`harness/README.md`](../../../../harness/README.md)
      §Sensors bekommen **keinen** neuen Gate-Namen
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [ ] **(3) Der Pflicht-Trockenlauf ist gefahren und seine Befund-Differenz steht im Closure-Beleg**
      ([`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)-Muster,
      netzlos, `--network none`): v0.62.0 gegen den **unveränderten** Baum mit unveränderter
      [`.d-check.yml`](../../../../.d-check.yml), Exit-Code getrennt erhoben. Erwartet und am
      2026-08-22 vorab gemessen: `d-check: 330 Datei(en) geprüft, 0 Befund(e)`, Exit 0 — **0-Befund-
      Differenz** zum v0.51.1-Stand. Der Lauf ist im Slice zu **wiederholen**, nicht zu übernehmen:
      eine Messung vom Vortag gilt für den Baum vom Vortag.
- [ ] `make gates` grün; dazu `make smoke`, `make full-smoke` und `make mutate` — der Emitter-Pin
      wandert ins **emittierte** Repo, und nur der Voll-Smoke fährt dessen Gate mit v0.62.0.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

### Was am 2026-08-22 gemessen ist — und was der Slice trotzdem selbst misst

Die Vorab-Messung ist read-only gefahren und steht hier, damit der Schnitt entscheidbar ist:
`--print-mk` von v0.62.0 gegen das heutige [`d-check.mk`](../../../../d-check.mk) ist
**strukturgleich**; die Differenzen sind (a) Tag- und Digest-Zeile, (b) unsere Adaption
`docs-check` gegen das erzeugte `doc-check` samt dem erweiterten `doc-help`-Grep, (c) ein **neues
Modul** `structure` — ein neues Target `doc-structure` und ein zusätzliches `--disable structure`
in jedem fokussierten advisory-Recipe. Der Trockenlauf über den unveränderten Baum liefert
`330 Datei(en) geprüft, 0 Befund(e)`, Exit 0.

**Der Slice wiederholt beides.** Ein Ergebnis von gestern belegt den Baum von gestern; die
explizite `modules:`-Liste in [`.d-check.yml`](../../../../.d-check.yml) immunisiert gegen neue
Default-Module, aber „immunisiert" ist eine Erwartung und der Lauf ist die Messung
([`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile):
Handbuch ≠ mein Baum).

### Welle oder nicht — der Test aus [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 1

1. **Bündel?** Nein. Der Pin landet in einem Schnitt; kein zweiter Slice muss mitlanden, damit die
   Aussage stimmt. Eine spätere `structure`-Adoption **setzt** diesen Slice voraus, statt mit ihm
   zu landen.
2. **Gemeinsames Closure-Kriterium?** Nein — ein Trigger darüber schriebe die DoD ab.
3. **Auslöser reaktiv oder gewollt?** **Reaktiv**, und zwar der Musterfall, den
   [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
   Setzung 1 wörtlich nennt: *„Pin ist veraltet"*. Ein Sensor hat gefeuert; keine neue Fähigkeit
   wird gewollt.

Dreimal *ohne Welle*. **Folge nach Setzung 2 und 3:** die Roadmap bekommt **keinen** Eintrag —
weder jetzt noch beim Abschluss. Der Zustand dieses Slice ist sein Verzeichnis.

### Dogfood **und** emittiert — beide Ebenen, verschiedene Verträge

Der Pin lebt zweimal: als **Dogfood** in [`d-check.mk`](../../../../d-check.mk) (unser eigenes
`docs-check`) und als **Emitter-Default** in
[`internal/emit/emit.go`](../../../../internal/emit/emit.go), von wo aus er in jedes emittierte
Repo geht (Tier-1-Drift, per Go-Test an [`d-check.mk`](../../../../d-check.mk) gekoppelt). Was
**nicht** mitwandert, ist die Modul-Wahl: die emittierte Starter-Config bleibt
`modules: [links, anchors]` — dort ist `structure` so wenig aktiviert wie `sources` oder
`citations` ([`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)).
Deshalb steht `make full-smoke` in der DoD: es ist der einzige Lauf, der das emittierte Gate
**mit dem neuen Image** fährt.

### Berührte Dateien — und eine Stelle, die gemessen *nicht* dazugehört

| Datei / Komponente | Änderungs-Art | Wer schreibt | Begründung |
|---|---|---|---|
| [`d-check.mk`](../../../../d-check.mk) | update (neu erzeugt) | Implementer | v0.62.0-Fragment aus `--print-mk` + [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)-Adaption; `DCHECK_IMAGE`/`DCHECK_DIGEST` neu gepinnt, Kopfkommentar auf den neuen Stand |
| [`Makefile`](../../../../Makefile) | update | Implementer | der Kommentar über `DCHECK_TAG` führt das Tag als Beispiel; ein Kommentar beschreibt, was da ist ([`AGENTS.md`](../../../../AGENTS.md) §3.7) |
| [`internal/emit/emit.go`](../../../../internal/emit/emit.go) | update | Implementer | `DefaultImage`/`DefaultDigest` → v0.62.0; ohne den Nachzug färbt `make test` rot |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | **Architect** | §Baseline-Zeile *d-check: Image v0.51.1* und der neue MR-Eintrag — Adaptions-Block, eigener Commit, Rolle in der Message ([`AGENTS.md`](../../../../AGENTS.md) §3.8) |
| [`.d-check.yml`](../../../../.d-check.yml) | **unverändert** | — | `structure` bleibt un-aktiviert; ein leer aktiviertes Modul wäre ein Phantom-Gate ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) |
| [`test/component-freshness.bats`](../../../../test/component-freshness.bats) | **unverändert — gemessen, nicht vermutet** | — | die Datei nennt `v0.51.1`, führt den Pin aber **nicht**: die Werte gehen als Fixture-Strings in `--compare <name> <gepinnt> <latest>`, der Vergleicher liest [`d-check.mk`](../../../../d-check.mk) nicht (Datei-Kopf: *„HERMETISCH … der Fetch ist im Skript davon getrennt"*). Wer sie mitzieht, ändert eine Fixture, nicht einen Pin |

## 4. Trigger

**`open` → `next`: erfüllt, sofort.** Das Ereignis ist eingetreten — v0.62.0 ist veröffentlicht,
das Image ist lokal inspizierbar (`--print-mk` gefahren, Manifest-Digest gelesen), und
`make freshness-dcheck` steht auf **VERALTET**. Es gibt keine fremde Entscheidung, auf die dieser
Slice wartet.

**`next` → `in-progress`: WIP-Limit frei** — konkret: nach der Closure von
[slice-086](../done/slice-086-vordergrund-per-updatedinput.md), dem einzigen Slice, der
`in-progress/` heute belegt. `ls docs/plan/planning/in-progress/` ist das Prüfkommando; es zeigt
danach nur noch die Roadmap.

Rückführungen:

- `in-progress` → `open`: der Trockenlauf ist **nicht** 0-Befund-differenzfrei — ein neu feuerndes
  Pflicht-Modul, ein Schema-Bruch in [`.d-check.yml`](../../../../.d-check.yml) oder eine
  geänderte Befundklasse über elf Minors. Dann ist zuerst zu entscheiden, **welche** Befunde
  gelten sollen; das ist keine Pin-Frage mehr
  ([`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)
  sieht den Fall vor).
- `in-progress` → `next`: `structure` erweist sich als nicht abwählbar oder zieht Config-Arbeit
  nach sich. Dann trennt ein Re-Schnitt den **Pin** von der **Modul-Entscheidung**; der Pin ist
  einzeln lieferbar, die Entscheidung braucht einen eigenen Prüfbereich.

## 5. Closure-Trigger

DoD vollständig; der Trockenlauf im Slice selbst gefahren und seine Befund-Differenz berichtet;
Review konform (Modul 10) mit ausgestelltem Verdikt; Verifikation (Modul 11) bestätigt die DoD;
`make gates`, `make smoke`, `make full-smoke` und `make mutate` grün; Closure-Notiz mit
Steering-Loop-Eintrag.

**Der Link-Zug gehört zu BEIDEN Moves, nicht nur zum letzten.** Jeder `git mv` ist ein eigener,
reiner Move-Commit ([`AGENTS.md`](../../../../AGENTS.md) §3.3); **nach jedem** folgt der
Link-Reconciliation-Commit — beim Eintritt (`open` → `next` → `in-progress`) wie beim Abgang nach
`done/`. Betroffen sind die eigenen `../`-Links dieser Datei **und** jeder eingehende Verweis.
**Prüfkommando statt Erinnerung:** `make docs-check` nach jedem Move; solange es rot ist, ist der
Zug nicht fertig. Der Grund steht gemessen in
[slice-086](../done/slice-086-vordergrund-per-updatedinput.md) §7: dort war der Zug beim
Eintritts-Move nötig und im Plan nicht vorgesehen.

## 6. Risiken und offene Punkte

- **Elf Minors auf einmal sind kein „inerter Bump", bis der Lauf es sagt.** Die bisherigen Sprünge
  dieser Linie waren ein bis vier Minors; hier liegen elf dazwischen, und die Befundklassen können
  sich in jedem geändert haben. Die 0-Befund-Differenz ist deshalb **DoD-Punkt**, nicht Annahme —
  dieselbe Lehre wie in [slice-021](../done/slice-021-dcheck-pin-v0511.md): *„inert" ist zu messen*.
- **Fünf Pin-Orte, zwei Rollen.** Vier Orte trägt der Implementer, den fünften der Architect
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Wer den Architect-Anteil in den Implementer-Commit
  nimmt, verletzt die Regel — und wer ihn ganz vergisst, hinterlässt eine §Baseline-Zeile, die
  eine Version behauptet, die nicht mehr läuft.
- **`structure` nicht aktivieren — auch nicht „kurz probieren".** Ein aktiviertes Modul ohne
  entschiedenen Prüfbereich ist entweder ein Phantom-Gate oder eine Befundflut; beides ist eine
  Änderung an der Gate-Strenge und gehört nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5 in eine eigene Entscheidung.
- **Der Emitter-Pin ist ein öffentlicher Vertrag.** Er landet in fremden Repos. `make smoke` allein
  belegt ihn nicht — es prüft die Emission, nicht den Lauf des emittierten Gates; das tut
  `make full-smoke`. Wer nur den ersten fährt, hat den Pin behauptet, nicht belegt.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): Gate-Konfiguration
([`d-check.mk`](../../../../d-check.mk), [`.d-check.yml`](../../../../.d-check.yml)), der
Emitter-Pin in [`internal/emit/emit.go`](../../../../internal/emit/emit.go) und der
Adaptions-Block teilen die adoptierte Harness-Mechanik
([`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile),
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)); der
Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
