# Slice slice-085: Die emittierte Ebene zieht nach

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-10](welle-10-re-baseline.md).

**Bezug:** [`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren),
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen),
[`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren),
[`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed).

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-08-09.

---

## 1. Ziel

Was ein **frisch gebootstrapptes Zielrepo** bekommt, steht auf `v5.12.0` — und die emittierten
Artefakte, die die Struktur des Regelwerks benennen, nennen keine Datei, die es dort nicht gibt.

**Die Ebene ist die Pointe.** Der Tag ist der Emissions-Kanal: `internal/fetch/baseline.go`
`DefaultTag` entscheidet, welchen Baum ein Zielrepo zieht. Der Dogfood-Tausch aus
[slice-081](../done/slice-081-baum-tauschen-pin-ziehen.md) verschiebt ihn mit — **was für dieses Repo gilt,
ist damit noch keine Aussage über das emittierte.** Emittiert werden unter anderem drei
Workflow-Commands (`plan-welle`, `close-welle`, `implement-slice`), die ihrerseits Module und
Ziel-Formen des Regelwerks benennen; `implement-slice` allein trägt 28 solcher Nennungen.

## 2. Definition of Done

- [x] `make smoke` **und** `make full-smoke` sind mit dem neuen `DefaultTag` grün — ein frisch
      gebootstrapptes Zielrepo fährt mit `v5.12.0` out-of-the-box grün
      ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)).
- [x] Die emittierten Artefakte nennen keine Regelwerks-Datei, die es in `v5.12.0` nicht gibt —
      geprüft als **Inventar gegen Abdeckung** (Nennungen gegen den Dateibestand des neuen Baums),
      nicht als Trefferliste.
- [x] Wo ein emittierter Text eine Prozedur beschreibt, die die neue Fassung geändert hat
      (Freshness-Audit, Results-Template), ist entschieden: **nachziehen** oder als bewusste
      Abweichung **deklarieren** — nichts dazwischen.
- [x] `make gates` grün.
- [x] Doku-Update: `docs/user/benutzerhandbuch.md`, soweit es den emittierten Stand beschreibt.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/commands/` | update | drei Commands benennen Module und Ziel-Formen |
| `internal/emit/templates/` (übrige) | prüfen, ggf. update | `d-check.yml`, `baseline-verify.sh`, `enforce/` |
| `.harness/baseline/<tag>/templates/.harness/skills/*.template.md` als **Emissions-Quelle** | prüfen | was ein Zielrepo an Skills bekommt, entscheidet dieser Slice. **Die gefüllte Fassung dieses Repos** (`.harness/skills/reviewer.md`) gehört **nicht** hierher: sie ist ein ausgefülltes Artefakt der Dogfood-Ebene und liegt seit dem 2026-08-28 bei [slice-083](../done/slice-083-form-vergleich-pflichtfelder.md) §2 (1) — zwei Ebenen, zwei Verträge, dieselbe Trennung wie bei den Commands eine Zeile weiter |

## 4. Trigger

[slice-083](../done/slice-083-form-vergleich-pflichtfelder.md) liegt in `done/` — die Form-Entscheidungen
der Dogfood-Ebene stehen, bevor die emittierte Ebene sie spiegelt oder bewusst nicht spiegelt.

Rückführungen: `in-progress` → `next`, wenn die Command-Texte und der Skill zusammen eine Sitzung
sprengen. `in-progress` → `open`, wenn `make full-smoke` einen Fehler im Bootstrap-Pfad selbst
zeigt — der ist dann ein eigener Slice, nicht Fracht dieses.

## 5. Closure-Trigger

DoD vollständig, `make gates` grün, `make smoke` und `make full-smoke` grün, Closure-Notiz
geschrieben.

## 6. Risiken und offene Punkte

- **Zwei Ebenen, zwei Verträge.** Was in diesem Repo gilt, ist keine Aussage über das emittierte —
  und umgekehrt. Dieser Slice entscheidet die Ziel-Ebene und schreibt sie nicht aus dem Dogfood
  fort.
- **Der Lauf ist nicht offline.** `make smoke` und `make full-smoke` ziehen das Asset aus dem Netz;
  sie gehören darum nicht in `make gates`, sondern an DoD-Verify und Closure.
- **Die emittierte Starter-Config bleibt bewusst schmaler als der Dogfood.** Ihre Modul-Liste
  nachzuziehen ist eine eigene Frage und liegt bereits als
  [slice-073](../open/slice-073-emittierte-doc-gate-module.md) in `open/`; wer sie hier mitnimmt, vermischt
  Re-Baseline und Gate-Anhebung.

## 7. Closure-Notiz (nach `done/`)

**Vorgelagert — offene Beobachtungen gesichtet** (Modul 5, *Zwei Schritte vor der
Modus-Begründung*): `../observations.md` führt 15 Kennungen, alle mit
Sub-Area `*` und damit alle berührt. Einschlägig war `BEO-009` bei 2× — mit
diesem Slice **3×** (unten). Kein anderer Eintrag erreichte mit diesem Slice die Schwelle.

**Closure-Kriterien (beobachtet, nicht behauptet):**

1. **`make smoke` und `make full-smoke` sind mit `DefaultTag = "v5.12.0"` grün** — beide Exit 0;
   `full-smoke` fährt den zusammengeführten `make gates` im frisch gebootstrappten Ziel
   ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)). Der Tag ist gemessen,
   nicht angenommen: `grep -n 'DefaultTag = ' internal/fetch/baseline.go`.
2. **`make gates` grün** nach dem Commit dieser Notiz; der Stop-Hook-Stempel deckt den Arbeitsbaum.
   `make docs-check` meldet 486 Datei(en), 0 Befund(e).
3. **Inventar gegen Abdeckung, nicht Trefferliste** ([`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)):
   Nenner sind **26** Regelwerks-Dateien (`ls .harness/baseline/v5.12.0/regelwerk/ | wc -l`), gegen
   sie gehalten wurden **17** eindeutige Dateinamen-Nennungen aus dem *gesamten* Emissions-Quellsatz
   (`grep -rhoE '(modul-[0-9]+-[a-z0-9-]+|grundlagen-[a-z0-9-]+)\.md' internal/emit/templates/ .harness/baseline/v5.12.0/templates/ | sort -u | wc -l`)
   — Differenzmenge **leer**. Drei weitere Achsen ebenso geschlossen geprüft: **9** Modul-Nummern
   (`grep -rhoE 'Modul [0-9]+' internal/emit/templates/ | sort -u | wc -l`; jede hat ihre Datei,
   Gegenprobe je Nummer mit `ls .harness/baseline/v5.12.0/regelwerk/modul-<NN>-*.md`), **2**
   `§`-Anker und **8** wörtliche Zitate. Alles keine Erwartungswerte
   ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
   Setzung 2). **Ein Zitat fiel dabei durch** — siehe unten.
4. **Jede geänderte Prozedur hat genau einen Ausgang, keine dazwischen** (DoD 3). **Nachgezogen**,
   nichts deklariert: die Results-Notiz entsteht per `cp` aus der Vorlage, die es seit `v5.12.0`
   gibt (der Text sagte *„existiert **kein** Template im Baum"*) · Schritt 2 der Welle-Closure ist
   das **Trigger-Audit über drei Artefaktklassen** statt des Carveout-Audits · Schritt 3 trägt den
   **Lese-Schritt des Beobachtungs-Registers** und die **drei Paarungen** · der Roadmap-Abschnitt
   *Aktuelle Welle* existiert in der emittierten Roadmap nicht und heißt *Offene Wellen*
   (`grep -n '^## ' .harness/baseline/v5.12.0/templates/docs/plan/planning/roadmap.template.md`) ·
   `plan-welle` sichtet das Register bei der Eröffnung und je Slice-Plan · `implement-slice` trägt
   den **Schreib-Schritt** des Registers und die drei Risiko-Ausgänge.

- **Was hat funktioniert:** die Inventar-Form der DoD. Eine Trefferliste hätte die
  Dateinamen-Achse gefunden und dort aufgehört; der geschlossene Vergleich zwang dazu, auch die
  Modul-Nummern, die `§`-Anker und die Zitate als eigene Mengen zu bilden — und **nur** die
  Zitat-Achse trug einen Befund.
- **Was ging anders als geplant:** Der Befund lag nicht dort, wo die DoD ihn erwartete. Sie nennt
  *Freshness-Audit* und *Results-Template* als Beispiele; das erste Wort kommt im emittierten Satz
  nicht vor (`grep -rl 'Freshness' internal/emit/ | wc -l` → **0**). Gefunden wurde stattdessen ein Zitat aus
  Modul 11, das der abgelöste Stand wörtlich so trug und der adoptierte nicht mehr:
  `git show b902b60^:.harness/baseline/v3.5.2/regelwerk/modul-11-verification.md` schreibt
  *Implementation-Agent*, `v5.12.0` schreibt *Implementer-Agent*. Der Rollen-Name daneben zog nach
  ([`MR-030`](../../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)
  hatte genau diese Verschiebung schon gemessen) — sonst stünde in einer Datei das korrigierte
  Zitat neben dem alten Etikett, und das ist das *dazwischen*, das DoD 3 ausschließt.
- **Steering-Loop-Eintrag: eine benannte Lücke, nicht verkörpert.** *Der emittierte Vertrag hat
  zwei Hälften mit verschiedenen Änderungs-Trägern — die vendored Vorlagen wandern mit dem Tag, die
  tool-autorierten Artefakte unter `internal/emit/templates/` nur, wenn ein Slice sie anfasst — und
  kein Sensor hält die zweite gegen die erste.* Gemessen statt behauptet: kein Modul des Doku-Gates
  vergleicht Text mit dem Baum (`grep -m1 '^modules:' .d-check.yml`), und die beiden Smokes belegen
  **Grün**, nicht **Aktualität** (`grep -c 'regelwerk' harness/tools/full-smoke.sh` → 0). Ein
  Zielort steht hier bewusst **nicht**: die Lücke ist die dritte Instanz von
  `BEO-009`, und deren Lese-Schritt liegt bei der Closure von
  [welle-10](welle-10-re-baseline.md) (Rollen-Zug Planner → Architect → Planner, Modul 8).
- **Beobachtungs-Register (`../observations.md`):** keine neue Kennung —
  `BEO-009` von 2× auf **3×**, Beleg `slice-085`. Dieselbe Klasse: der
  Tausch-Commit korrigierte die Ableitung (den vendored Baum) und ließ die daneben stehenden
  Zusagen (die emittierten Command-Texte) stehen. Eine eigene Kennung für die *Asymmetrie* hätte
  dieselbe Beobachtung unter zwei Namen gezählt und keine der beiden erreichte je 3×.
- **Folge-Slices:** keine. Die emittierte Doc-Gate-Modul-Liste bleibt bei
  [slice-073](../open/slice-073-emittierte-doc-gate-module.md) in `open/`.
- **Risiken aus §6:** drei benannt, drei mit genau einem Ausgang, keines eingetreten.
  (1) *Zwei Ebenen, zwei Verträge* — **entfallen**: der Slice hat nur die Ziel-Ebene entschieden,
  `git diff --name-only 3881e44..HEAD | grep -E '^\.claude/|^\.harness/skills/'` bleibt leer.
  (2) *Der Lauf ist nicht offline* — **entfallen**: beide Smokes liefen mit Netz und Exit 0 und
  stehen weiterhin außerhalb von `make gates`. (3) *Starter-Config bleibt schmaler* —
  **entfallen**: `internal/emit/templates/d-check.yml` ist unverändert, Re-Baseline und
  Gate-Anhebung blieben getrennt.
- **Drei Paarungen:** hier **nicht** geprüft. Dieses Repo führt Wellen-Betrieb, und dieser Slice
  gehört zu [welle-10](welle-10-re-baseline.md); die Paarungen sind Schritt 3c der
  Wellen-Closure und prüfen den Bestand, den sie vorfinden (Modul 6).
- **Sensoren, die nicht liefen — und warum:** keine. `make gates` (Exit 0), `make smoke` (Exit 0),
  `make full-smoke` (Exit 0) und `make mutate` (`mutate: 214 ok, 0 Befund(e)`) sind gelaufen. Das
  letzte, weil dieser Slice mit `internal/emit/templates/commands/implement-slice.md` eine
  **Mutations-Zieldatei** anfasst (`grep -rl 'templates/commands' test/mutations/ | wc -l` → **3**)
  — ein grüner Emit-Smoke sagt über die Zähne über dieser Datei nichts.
- **Rot färbende Mutation:** kein Wächter ist neu oder geändert
  (`git diff --name-only 3881e44..HEAD | grep -E '^test/|_test\.go$|^harness/tools/|\.go$'` bleibt
  leer). Für die drei vorhandenen Fälle über der geänderten Datei ist die rot färbende Mutation
  bereits verdrahtet und in `make mutate` gefahren.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `internal/emit/` und
`.harness/skills/` gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
