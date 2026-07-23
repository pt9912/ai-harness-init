# Slice slice-038: Idempotenz-Klassifikation (konvergent / skip-if-present)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** welle-05.

**Bezug:** [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`ADR-0007`](../../adr/0007-bootstrap-phasen.md).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-23.

---

## 1. Ziel

<!--
Was liefert dieser Slice in einem Satz? Liefer-Fokus, kein "wir
machen aufräumen".
-->

Jede emittierte Datei bekommt **genau eine** Idempotenz-Klasse — **konvergent** (tool-eigene
Infrastruktur: bei jedem Lauf kanonisch neu geschrieben, heilt Drift/Baseline-Bump, **prunt nie**)
oder **skip-if-present** (Adopter-Boden: nur geschrieben, wenn abwesend, **nie** überschrieben) —
gemäß der Tabelle in [`ADR-0007`](../../adr/0007-bootstrap-phasen.md) Entscheidung 3. Das **ersetzt**
das Pre-Flight-refuse/`--force`-Modell (slice-025): ein zweiter Init-Lauf wird **idempotent** (Exit 0
statt Kollisions-Refuse), `--force` **entfällt** ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)/[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Zugleich wird `blocked/<sprache>`
von skip-if-present (slice-037) auf **konvergent** gehoben (Review-I-1-Versöhnung: die ADR-Tabelle
listet es als konvergent; kanonisch-neu-schreiben ist auch im Mono-Repo idempotent, byte-identisch).

## 2. Definition of Done

<!--
Was muss erfüllt sein, damit der Slice in done/ wandert?
Liste mit jeweils prüfbarem Kriterium.
-->

- [ ] **Ein zweiter Init-Lauf** (`ai-harness-init [--lang go]` auf einem bereits gebootstrappten Repo)
  liefert **Exit 0** (idempotent) statt des heutigen Kollisions-Refuse. Rot gesehen: eine Mutation, die
  einen konvergenten Emitter wieder refusen lässt, färbt den Idempotenz-Test rot
  ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)).
- [ ] **Konvergent-Dateien** (Enforce/Makefile/BaselineVerify/`d-check.mk`+`doc-gate.mk`/blocked/`harness/mk/<modul>.mk`/Baseline-Fetch)
  werden beim Re-Lauf **kanonisch neu geschrieben** (byte-identisch, [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)); eine adopter-modifizierte
  konvergente Datei wird auf kanonisch **geheilt**.
- [ ] **Skip-if-present-Dateien** (Templates/README/Commands/Skelett-Code/`.d-check.yml`) werden beim
  Re-Lauf **NICHT** angefasst — adopter-modifizierter Inhalt überlebt unverändert.
- [ ] **Kein Prune:** ein via `add-lang` gedropptes `blocked/<sprache>` bzw. `harness/mk/<modul>.mk`
  **überlebt** einen sprachlosen Init-Re-Lauf (kein Emitter prunt ein Verzeichnis).
- [ ] `--force` ist **entfernt** (Init + `add-lang`): Usage/Flag/Parsing raus; der Pre-Flight-refuse
  (`preflightAbsent`/`emitTargets`) entfällt.
- [ ] `blocked/<sprache>` ist **konvergent** (Review-I-1: nicht mehr skip-if-present); ein zweites
  `add-lang` gleicher Sprache schreibt es byte-identisch neu (idempotent, kein Fehler).
- [ ] `make full-smoke`: die Idempotenz-Fitness — 2. Init-Lauf Exit 0, skip-if-present-Datei unberührt,
  gedropptes Fragment überlebt ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md)-Closure-Trigger).
- [ ] `make gates` grün.
- [ ] Doku: README (`--force` raus), [`architecture.md`](../../../../spec/architecture.md) §5 (Idempotenz)
  prüfen; [`lastenheft.md`](../../../../spec/lastenheft.md) auf `--force`/Boundary-AC prüfen.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

<!--
Welche Änderungen sind geplant? Datei- oder Komponenten-Ebene reicht.
Der Implementation-Agent erweitert diese Liste in seinem ersten Lauf.
-->

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/enforce.go` | refactor | neuer `writeSkipIfPresent`-Writer neben `writeFileMode` (=konvergent); `Enforce` verliert `force` (alle konvergent); `BlockedFragment` skip-if-present → **konvergent** (I-1) |
| `internal/emit/{makefile,baseline,commands,readme,templates}.go` | refactor | `force`-Param + Refuse-Block raus; konvergent (Makefile/BaselineVerify) via `writeFileMode`, skip-if-present (Commands/RootReadme/Templates) via `writeSkipIfPresent` |
| `internal/emit/emit.go` | refactor | `DocGate` **gemischt**: `.d-check.yml` skip-if-present, `d-check.mk`+`doc-gate.mk` konvergent; `Options.Force` raus |
| `internal/wire/wire.go` | refactor | `Place` skip-if-present (Skelett-Code Adopter-Boden); `force`-Param + Kollisions-Vorpass raus; `Targets` bleibt (für Prune-Test) |
| `internal/fetch/baseline.go` | refactor | `Baseline`/`placeBaseline` konvergent: immer ersetzen (aside-Swap), `force`-Refuse raus |
| `cmd/ai-harness-init/main.go` | refactor | `--force` (Flag/Usage/Parsing) raus; `preflightAbsent`+`emitTargets` raus; `bootstrap`/`addLang`/`emitAll`/`wireLang` force-Threading entfernen; Aggregator-Check + `<pfad>`-Containment bleiben |
| `harness/tools/full-smoke.sh` | update | Idempotenz-Fitness: 2. Init-Lauf Exit 0, skip-if-present unberührt (modifizierte Datei bleibt), gedropptes Fragment überlebt sprachlosen Re-Lauf |
| `internal/**/\*_test.go` + `cmd/**/*_test.go` | update | Kollisions-Refuse-Tests → Idempotenz-Semantik; Signatur-Updates (force raus); neuer Idempotenz-Re-Lauf-Test |
| `test/mutations` | update | Kollisions-Mutationen obsolet; neu: konvergent-Emitter refust wieder · skip-if-present clobbert · Prune eines Fragments · blocked konvergent |
| `README.md` | update | `--force` aus der Usage; Idempotenz-Re-Lauf statt Refuse |

## 4. Trigger

<!--
Wann beginnt dieser Slice? (`next` → `in-progress`: Implementer beginnt.)
Beispiele: "Wenn Welle X done." / "Wenn Carveout CO-NN aufgelöst."

Auch die zwei Rückführungen vorab benennen — unter welcher Bedingung
geht dieser Slice zurück?
- `in-progress` → `next`: zu groß, zurück zur Zerlegung.
- `in-progress` → `open`: blockiert (Carveout? siehe Modul 7).
(kanonische Definition: [`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine))
-->

**Start** (`next` → `in-progress`): slice-037 in `done/` (add-lang wiederholbar, blocked skip-if-present).
slice-038 läuft **zuletzt** — es klassifiziert die Idempotenz über **alle** von 034–037 emittierten
Dateien. Der Implementer beginnt, sobald der Slice nach `next/` gezogen ist.

**Rückführungen:**
- `in-progress` → `next`: die Klassifikation über ~10 Emitter + der Test-Umbau (Kollisions- →
  Idempotenz-Semantik) + `--force`-Entfernung sprengen eine Session → neu zerlegen (z.B. Klassifikation
  vs. `--force`-Entfernung trennen).
- `in-progress` → `open`: blockiert, falls eine Fehl-Klassifikation Adopter-Inhalt clobbert und erst ein
  Folge-ADR die Grenze schärft (Carveout, Modul 7).

## 5. Closure-Trigger

<!--
Wann ist der Slice done?
"DoD vollständig + PR gemerged + Closure-Notiz geschrieben."
-->

DoD vollständig · `make gates` grün · `make full-smoke` (Idempotenz-Fitness: 2. Init Exit 0 + kein Prune +
skip-if-present unberührt) + `make mutate` grün · Slice per `git mv` nach `done/` · Closure-Notiz +
**welle-05-Closure** (`/close-welle`, letzter Slice).

## 6. Risiken und offene Punkte

<!--
Was könnte schief gehen? Welche Carveouts entstehen ggf.?
-->

- **Fehl-Klassifikation clobbert oder driftet** ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md)
  §Konsequenzen): eine konvergent-markierte Datei, die eigentlich Adopter-Boden ist, **clobbert**;
  eine skip-if-present-markierte Infrastruktur-Datei **driftet** (Re-Lauf heilt sie nicht). Im Zweifel
  **skip-if-present** (der sichere Default der ADR). Jede Klasse ist test- + mutations-gedeckt.
- **DocGate ist gemischt:** `.d-check.yml` (skip-if-present, Adopter kann Module aktivieren) vs.
  `d-check.mk`/`doc-gate.mk` (konvergent, tool-generiert). Die Datei-granulare Klasse muss stimmen — ein
  Test ankert beide Seiten.
- **Baseline-Fetch konvergent = Re-Fetch je Lauf:** der Re-Lauf holt + ersetzt die Baseline (aside-Swap,
  heilt Baseline-Bump). Netz nötig (real); im Test via injizierter Fetch. Kein Prune anderer `.harness/`-Inhalte
  (der Swap ersetzt nur `<tag>/`, ein rein tool-eigener Baum).
- **`--force`-Entfernung ist ein CLI-Vertragsbruch:** Alt-Skripte mit `--force` bekommen jetzt einen
  „unbekanntes Flag"-Exit 2. Bewusst (Nutzer-Entscheidung, ADR-treu); Usage nennt die Idempotenz.
- **kein Prune ist eine Abwesenheit:** schwer positiv zu testen. Der Test dropt ein Fragment, läuft
  sprachlos neu und prüft, dass das Fragment noch da ist (die H2-Clobber-Falle eine Ebene tiefer).

## 7. Closure-Notiz (nach `done/`)

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas sind **GF** (Greenfield) — siehe Kurs Modul 5 §Worked Mini-Example und die
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md) (`*` = Greenfield).
Kein BF/Hybrid, daher genügt dieser Hinweis.
