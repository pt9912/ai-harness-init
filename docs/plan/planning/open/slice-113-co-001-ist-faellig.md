# Slice slice-113: `CO-001` ist fällig — der Auflösungs-Trigger ist eingetreten, und die Auflösung wird vollzogen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Carveout-Auflösung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1: **(1) Bündel?** Nein — der Gegenstand ist **ein** Carveout. **(2) Gemeinsames
Closure-Kriterium?** Nein — jedes denkbare wäre die Abschrift seiner DoD. **(3) Auslöser reaktiv oder
gewollt?** Reaktiv: der Auflösungs-Trigger von
[`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) ist eingetreten und beim vorangegangenen
Audit nicht gesehen worden (§1). Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Schnitt vom 2026-10-21.** Der Slice war als Gate-Arbeit **und** Auflösung geschnitten. Die
Gate-Arbeit (Prüfbereich öffnen, Befunde beheben, Pfad-Ausnahme zurücknehmen) trägt jetzt
[slice-bats-ruempfe-erreichen-shell-lint](slice-bats-ruempfe-erreichen-shell-lint.md); **dieser Slice
behält die Kennung und die Auflösung**, weil `CO-001`, [`ADR-0098`](../../adr/0098-co-001-aufloesung-reiner-move-nachzug-und-ein-namentliches-paar-fuer-adr-0021.md) und die Zeitdokumente ihn als
Folge-Slice nennen. Er beginnt erst, wenn jener in `done/` liegt (§4).

**Ebene: Dogfood, nicht emittiert.** Gegenstand sind der Carveout dieses Repos und die
Gate-Konfiguration [`.d-check.yml`](../../../../.d-check.yml). Was ein emittiertes Repo bekommt,
entscheidet der Slice, der die Tool-Ebene entscheidet.

**Bezug:**
[`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) (der Carveout selbst),
[`ADR-0098`](../../adr/0098-co-001-aufloesung-reiner-move-nachzug-und-ein-namentliches-paar-fuer-adr-0021.md)
(Reihenfolge, Paar, Grenz-Absatz),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine
Gate-Ausnahme, deren Auflösungs-Trigger eingetreten ist, sagt einen Prüfbereich zu, den sie nicht mehr
rechtfertigt),
[`AGENTS.md`](../../../../AGENTS.md) §3.3 (Move und Inhaltsänderung in zwei Commits), §3.4, §3.6,
§3.11,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert).

**Autor:** Planner. **Datum:** 2026-08-27.

---

## 1. Ziel

**`CO-001` liegt in `docs/plan/carveouts/done/`, ohne dass der Move einen Befund erzeugt, den niemand
beheben darf.** Voraussetzung ist, dass `shell-lint` die bats-Rümpfe liest und `make gates` ohne die
Pfad-Ausnahme grün ist — das liefert
[slice-bats-ruempfe-erreichen-shell-lint](slice-bats-ruempfe-erreichen-shell-lint.md), und dieser
Slice prüft sie vor dem Move.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Gate-Arbeit** (Verkettung, Befunde, Rücknahme der Pfad-Ausnahme) — ein anderer Vorgang an
  einer anderen Schicht (Makefile, Skript, bats-Dateien) und der Vorgänger dieses Slice; sie trägt die
  Architect-Frage zur zentralen Ausnahme. Ein zweiter Verweis `CO-001` im `shell-lint`-Rezept entfällt
  mit der Ausnahme.
- **Die Neufassung des Carveouts** — nur der Ausgang des Vorgängers, falls die Verkettung scheitert; dann
  entfällt dieser Slice mit Grund (§4).

### Die Ausgangslage: der Trigger ist eingetreten, gemessen an der Eigenschaft, die er nennt

[`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) §Auflösungs-Trigger lautet: *„sobald **eine
einzelne .bats-Datei eigene Hilfsfunktionen mit Verzweigung oder Schleifen** trägt (nicht nur
lineare `run`+`assert`-Zeilen)"*. Die Eigenschaft, über die gezählt wird, ist damit gegeben —
**eine Verzweigungs- oder Schleifen-Zeile im Rumpf einer benannten Funktion, die kein
`@test`-Rumpf ist**. Sie ist mit einem Kommando entscheidbar; der Sensor liegt als Programm-Text
neben seiner Zahl, weil ihn kein Gate fährt:

```
awk '/^@test /{t=1;d=1;next}
     /^[a-zA-Z_][a-zA-Z0-9_]*\(\)[[:space:]]*\{/{f=1;n=$1;d=1;next}
     (t||f){d+=gsub(/\{/,"{")-gsub(/\}/,"}");
            if(f && $0~/^[[:space:]]*(if|for|while|case|until)[[:space:]]/)
              printf "%s\t%s\t%d\n",FILENAME,n,FNR;
            if(d<=0){t=0;f=0}}' $(git ls-files 'test/*.bats')
```

→ **zwei** Zeilen, beide in **einer** Datei und **einer** Funktion:
[`test/release-matrix.bats`](../../../../test/release-matrix.bats), `lh_platforms()`, Zeilen 47
und 51 — zwei verschachtelte `for`-Schleifen über zwei aus dem Lastenheft gelesene Mengen. Der
Prüfbereich dabei: `git ls-files 'test/*.bats' | wc -l` → **16** Dateien. Beide Zahlen wandern mit
ihrem Bestand und sind **kein** Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Die Zwei ist eine Untergrenze, mit Absicht.** Dieselbe Funktion trägt zwei
`[ … ] || return 1`-Wächter, die das Muster nicht erfasst — Steuerfluss ohne Schlüsselwort. Wer
die Zahl als Menge liest, liest sie falsch; was sie trägt, ist die Aussage *„der Trigger ist
eingetreten"*, und dafür genügt eine.

**Seit wann, auf die Minute, und welcher Audit daran vorbeigegangen ist.** Die Funktion kam mit
der Datei (`git log --diff-filter=A --format='%h %ad' --date=iso -- test/release-matrix.bats | tail -1`
→ `dfca6c6 2026-07-25 17:17:58 +0200`, slice-048, wellenlos), und `lh_platforms` steht seit
demselben Commit darin (`git log --format='%h %ad' --date=iso -S 'lh_platforms' -- test/release-matrix.bats | tail -1`).
Gegen die drei seitherigen Audits gehalten:

| Audit | Zeitpunkt | Urteil damals | trifft zu? |
|---|---|---|---|
| welle-06-Closure | `git log -1 --format=%ad --date=iso e44cd58` → 2026-07-24 09:45:25 | Trigger nicht erfüllt | **ja** — die Datei existierte nicht |
| welle-07-Closure | `git log -1 --format=%ad --date=iso 5050fa9` → 2026-07-25 08:59:54 | Trigger nicht erfüllt | **ja** — acht Stunden vor der Datei |
| welle-08-Closure | `git log -1 --format=%ad --date=iso 392093f` → 2026-07-27 13:24:04 | Trigger nicht erfüllt | **nein** — die Funktion lag da |

**Die Ursache ist die Frage, nicht die Sorgfalt.** Alle drei Audits fragten *„hat **diese Welle**
eine `.bats`-Datei hinzugefügt, und trägt **die** Verzweigungen?"*. Der Trigger fragt über den
**Bestand**: *„trägt **eine einzelne** `.bats`-Datei …"*. Eine Datei, die zwischen zwei Wellen
aus wellenloser Arbeit entsteht, fällt durch jede Wellen-Frage hindurch — und genau so ist es
gekommen: slice-048 lief ohne Welle.

### Ein zweiter Befund aus demselben Audit, hier mitgenommen statt nebenan vergessen

Der fehlende Verweis `CO-001` im Kommentar des `shell-lint`-Rezepts
(`grep -c 'CO-001' Makefile` → **0**, Exit 1) entfällt mit der Pfad-Ausnahme selbst; ihn trägt der
Vorgänger-Slice, weil er die Ausnahme zurücknimmt. Die Abwägung der zwei Techniken des Carveouts
(Extraktion oder bats-natives Werkzeug) steht dort in §1 und §3.

## 2. Definition of Done

Drei slice-eigene Punkte (Modul 5 §Ziel-Form: ≤ 3).

- [ ] **(1) Der Move ist ein reiner `git mv`, vor ihm steht die Entscheidung.** `make gates` ist ohne
      Pfad-Ausnahme grün (Vorgänger in `done/`); dann
      `git mv docs/plan/carveouts/CO-001-bats-shell-lint.md docs/plan/carveouts/done/` in einem
      **eigenen** Commit ([`AGENTS.md`](../../../../AGENTS.md) §3.3,
      [`ADR-0098`](../../adr/0098-co-001-aufloesung-reiner-move-nachzug-und-ein-namentliches-paar-fuer-adr-0021.md)
      Festlegung 4).
      **Rot:** `ls docs/plan/carveouts/CO-001-*.md` findet eine Datei, oder
      `ls docs/plan/carveouts/done/CO-001-*.md` keine.
- [ ] **(2) Der Nachzug-Commit repariert, was reparierbar ist, und das Paar deckt den Rest.** Der Pfad in
      den 29 reparierbaren Quellen (in der bewegten Datei jedes `](../` zu `](../../`, im Carveout-Index
      und in `CO-002` die Geschwister-Form), das zehnte `ignore-refs`-Paar in
      [`.d-check.yml`](../../../../.d-check.yml) mit `# Deckung: 2` und einem Kommentar, der seinen ganzen
      Gegenstand nennt und auf die ADR zeigt, und der Absatz *„GRENZE, keine Regel"* im Kopfkommentar des
      `ignore-refs`-Blocks, um dieses Paar nachgezogen.
      **Nachweis im Commit:** `make docs-check` mit **0** Befunden und gleicher Datei-Zahl vor und nach dem
      Paar, `make test` mit dem Paar vom Restbreite-Wächter gedeckt (`Deckung: 3` einmal rot gesehen), der
      Beleg nennt die angefassten Dateien
      ([`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 5). Beide
      Commits gehören in denselben Push.
- [ ] **(3) Index und Bindung folgen dem Move.** Die Zeile im Carveout-Index
      ([`docs/plan/carveouts/README.md`](../../carveouts/README.md)) steht in *Aufgelöst* statt *Aktiv*,
      die Verifikations-Checkliste des Carveouts ist abgehakt, und eine Bindung `CO-001` in der
      Sensors-Tabelle von [`harness/README.md`](../../../../harness/README.md) ist zurückgesetzt, falls
      der Lauf eine findet (`grep -c 'CO-001' harness/README.md` → beim Schnitt **0**).
      **Rot:** `sed -n '/^## Aktiv/,/^## Permanent/p' docs/plan/carveouts/README.md | grep -c 'CO-001'`
      findet die Zeile weiterhin in *Aktiv*.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`docs/plan/carveouts/CO-001-bats-shell-lint.md`](../../carveouts/CO-001-bats-shell-lint.md) | `git mv` nach `done/`, danach update | DoD (1), (3); Move und Inhalt in zwei Commits |
| die 29 reparierbaren Quellen der Sonde aus [`ADR-0098`](../../adr/0098-co-001-aufloesung-reiner-move-nachzug-und-ein-namentliches-paar-fuer-adr-0021.md) | update (Pfad-Nachzug) | DoD (2) |
| [`.d-check.yml`](../../../../.d-check.yml) | update | zehntes Paar, Grenz-Absatz (DoD 2) |
| [`docs/plan/carveouts/README.md`](../../carveouts/README.md), [`harness/README.md`](../../../../harness/README.md) | update | DoD (3) |
| [`.harness/baseline`](../../../../.harness/baseline), `internal/emit/` | **unverändert** | Dogfood; Baseline byte-verifiziert |

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): das WIP-Limit ist frei,
[slice-bats-ruempfe-erreichen-shell-lint](slice-bats-ruempfe-erreichen-shell-lint.md) liegt in `done/`,
[`ADR-0098`](../../adr/0098-co-001-aufloesung-reiner-move-nachzug-und-ein-namentliches-paar-fuer-adr-0021.md)
trägt den Status `Accepted` **und**
[slice-141](../done/slice-141-co-001-aufloesung-ist-vorher-entschieden.md) liegt in `done/`.** Die
beiden letzten Bedingungen sind erfüllt; die erste ist die Abhängigkeit dieses Slice. Ein Wächter für
diese Reihenfolge existiert nicht — kein Modul des Doku-Gates liest Lifecycle-Reihenfolgen — und das steht
hier statt eines behaupteten
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

**Warum die ADR-Bedingung.** Der `git mv` bricht an der Sonde der ADR (Kommandos dort, §Kontext
*Die Sonde*) 61 Befunde in 30 Quelldateien; 29 davon sind reparierbar, allein zwei Pfad-Links in
[`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) bleiben, und die deckt das
namentliche Paar. [`AGENTS.md`](../../../../AGENTS.md) §3.4 sperrt die Reparatur am Ziel; ein Move ohne
vorherige Entscheidung erzeugte einen Befund, den niemand beheben darf.

**Rückführungen, vorab benannt:**

- `in-progress` → `next`: der Move erzeugt nach dem Nachzug mehr Befunde als die Sonde nannte. Dann
  Entscheidung **vor** dem Move ([`ADR-0098`](../../adr/0098-co-001-aufloesung-reiner-move-nachzug-und-ein-namentliches-paar-fuer-adr-0021.md)
  Festlegung 4), nicht ein viertes Paar im Lauf.
- `in-progress` → `open`: `make gates` ist ohne Ausnahme nicht grün, obwohl der Vorgänger in `done/` liegt.
  Dann bleibt der Carveout aktiv und der Befund geht an den Vorgänger zurück.
- **Entfällt**, wenn der Vorgänger mit `→ open` endet (Verkettung trägt nicht): `CO-001` wird neu gefasst,
  §7 nennt den Grund.

## 5. Closure-Trigger

DoD (1) bis (3) erfüllt, `make gates` grün, `make docs-check` mit 0 Befunden, Review nach Modul 10 und
Verifikation nach Modul 11 ohne blockierenden Befund, Closure-Notiz in §7 mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der Bestand hat den Schnitt überholt** (beim Schnitt 16 bats-Dateien, heute
  `git ls-files 'test/*.bats' | wc -l` → 50; die Gate-Arbeit war kein ein-Sitzungs-Slice). —
  **Ausgang:** eingetreten: slice-bats-ruempfe-erreichen-shell-lint
- **Die Audit-Frage bleibt offen, auch wenn dieser Slice schließt.** Dass drei Audits nach der **Welle**
  statt nach dem **Bestand** fragten, ist ein Befund über die Audit-Methode, nicht über diesen Carveout;
  sein Ort ist die Closure-Notiz von
  [welle-12](../done/welle-12-erfassungsschicht-emittieren.md), die ihn gefunden hat. —
  **Ausgang:** <eingetreten: slice-<Kennung> | entfallen: Grund | weiter offen: → BEO>
- **Zehn Paare machen die Grenz-Aussage des `ignore-refs`-Blocks länger.** Der Absatz wird um dieses Paar
  nachgezogen; ein Sensor für die Aufnahme neuer Paare existiert nicht
  (`BEO-ALL/ignore-refs-paar-aufnahme-hat-keinen-sensor`, §8). — **Ausgang:** <…>

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** eine Sub-Area, *Carveout- und Gate-Konfiguration dieses Repos*
(`docs/plan/carveouts/`, `.d-check.yml`, `harness/README.md`): Konvention (§3.3, §3.5, §3.11), Artefakte
und Sensor (`docs-check`) tragen sie, Schwelle ≥ 2 von 3 erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-ALL/ignore-refs-paar-aufnahme-hat-keinen-sensor` —
**1×**, offen; dieser Slice trägt das zehnte Paar und berührt ihn damit, ein Beleg aus der Closure hebt
ihn auf 2×. Sonst keine Treffer.

### Sub-Area: Carveout- und Gate-Konfiguration dieses Repos

- **Modus:** GF
- **Konventionen-Dichte:** hoch — Carveout-Lebenszyklus, [`ADR-0098`](../../adr/0098-co-001-aufloesung-reiner-move-nachzug-und-ein-namentliches-paar-fuer-adr-0021.md) Festlegungen 1 bis 4, §3.4/§3.11.
- **Phase-Reife:** Phase 4 — `docs-check` und der Restbreite-Wächter laufen in `make gates`.
- **Evidenz-/Diskrepanz-Risiko:** niedrig — die Sonde der ADR hat die Befund-Menge gemessen; Abweichung
  ist die Rückführung `→ next`.
- **Reconciliation-Aufwand:** S; Graduation entfällt.
