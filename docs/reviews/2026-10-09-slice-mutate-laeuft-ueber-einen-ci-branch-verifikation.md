# Verifikation: slice-mutate-laeuft-ueber-einen-ci-branch — 2026-10-09

**Rolle:** Verifier (Modul 11), frischer Kontext · **Modell:** claude-opus-5-5
**Gegenstand:** `853db12e`, `b7de7a9a`, `fa950d7a`, `c4c9fa4e`, `79651a0e` gegen den Plan
`slice-mutate-laeuft-ueber-einen-ci-branch` (Stand `742c5f76`), [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten),
[`MR-014`](../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions).
Review: `2026-10-09-slice-mutate-laeuft-ueber-einen-ci-branch.md` (`9a9ea6e9`).

**Urteil:** Die drei Liefer-Punkte sind **bestätigt**. Ein LOW-Befund betrifft die Werkzeuge-Zeile in
`harness/README.md`, Closure-Arbeit bleibt offen (unten).

## CI-Ergebnis (einmal gelesen, zu Beginn)

- Kommando: `git fetch origin mutate/slice-mutate-laeuft-ueber-einen-ci-branch-79651a0e && git show FETCH_HEAD:mutate-ergebnis.txt`
  → Exit 0. Tip `786bd511` (`mutate-ergebnis: … @ 79651a0eb50f (MR-014)`).
- `gepruefter Commit: 79651a0eb50ffa9a479a6e81b22250be1f08e082` ist der verifizierte Commit.
  `Basis (Claim-Commit): 5c54dc7a…` stimmt mit `bash harness/tools/mutate-auswahl.sh basis slice-mutate-laeuft-ueber-einen-ci-branch` → `5c54dc7af5e8…` überein.
- 10 Shards, alle mit `Exit 0`, Laufzeiten 418–584 s; `Wanduhr gesamt … 615 s`.
- `Fallmenge: 66 (Slice: 66)`, alle 66 Fälle `ok`, kein `BEFUND`, kein `FEHLT`, kein `UNERWARTET`;
  `Urteil: gruen`. Darunter alle 14 Fälle des Slice, 652–665.
- Selbst nachgemessen: `make mutate-auswahl SLICE=slice-mutate-laeuft-ueber-einen-ci-branch` (HEAD
  `ed2ac693`, ein Architect-Commit über `79651a0e`) → `66 Fall/Faelle`, CI-Weg. Die Namensliste ist
  mit der Menge der Ergebnisdatei identisch (`diff` leer).

**Branches gelöscht:**
`git push origin --delete` auf `mutate/slice-mutate-laeuft-ueber-einen-ci-branch-79651a0e`,
`…-fa950d7a` und `mutate/slice-mutate-laeuft-ueber-einen-ci-branch` (alte Form, Rest leer) → drei
`[deleted]`, Exit 0. Danach `git ls-remote origin 'refs/heads/mutate/*'` → keine Zeile, Exit 0.
Branches anderer Slices gab es nicht.

## Verdikte je DoD-Punkt

- **Fallauswahl und Zuteilung — bestätigt.**
  - Das Werkzeug ist `harness/tools/mutate-auswahl.sh` hinter `make mutate-auswahl` und
    `make mutate-branch`. `test/mutate-auswahl.bats` läuft an `79651a0e` grün
    (`make test-bats BATS_TARGET=test/mutate-auswahl.bats` in einer Export-Kopie → 20 `ok`, Exit 0).
  - Grenze, selbst gefahren mit realem `git` und 8 bzw. 9 Fall-Köpfen
    (`# files: harness/tools/mutate-auswahl.sh`) über `MUTATE_AUSWAHL_FAELLE`:
    - 8 Fälle → `lokal — make mutate MUTATE_CASES='01-probe … 08-probe'`, Exit 0.
    - 9 Fälle → `CI-Branch — git push origin HEAD:refs/heads/mutate/<kennung>-79651a0e`, Skript-Exit 10. make meldet `Fehler 10`, der make-Prozess endet mit Exit 2.
  - Rot-Beleg, selbst gefahren: In einer Export-Kopie von `79651a0e` lief je der Fall-Skript, danach
    `make test-bats` über die Datei. Jedes Mal fiel **genau ein** Test, und zwar aus dem behaupteten
    Grund:
    - 652 (`-gt`→`-ge`) → `not ok 8 grenze: 8 Faelle ergeben den lokalen Weg`, `[ "$status" -eq 0 ]`. Das ist die Verschiebung um eins.
    - 663 → `not ok 18 ergebnis: ein Shard mit Exit ungleich 0 …`, `[ "$status" -eq 1 ]`.
    - **664** (Löschung von `befund=1` nach `FEHLT`) → `not ok 19 ergebnis: ein Fall der Fallmenge ohne Shard-Beleg ergibt BEFUND`, `[ "$status" -eq 1 ]`.
    - 665 → `not ok 14 lauf: ein Tip, der allein die Ergebnisdatei aendert …`, `laufen=false` fehlt.
  - Die übrigen Fälle 653–660 und 662 sind im CI-Lauf `ok`. Sie wurden nicht einzeln nachgefahren.
- **CI-Pfad — bestätigt.**
  - `mutate-branch.yml`: `push` auf `mutate/**`; die Matrix kommt aus dem Output von `plan`
    (`CI_SHARDS=10`). Der Workflow steht auf `contents: read`, `contents: write` allein im Job
    `ergebnis`, und jeder Schritt ist ein `make mutate-branch SCHRITT=…`.
  - `ci.yml` trägt `branches-ignore: ['mutate/**']` und `tags: ['**']`. `mutate.yml` hat die Matrix
    0–9 und fragt `make mutate-auswahl SLICE=--alle`.
  - `make ci-lint` läuft in `make gates` (unten). Der reale Lauf ist oben gelesen und zitiert.
  - **Injection-Probe** (Rot-Beleg zu 661), selbst gefahren:
    `make mutate-branch SCHRITT=lauf REF="mutate/x';echo\$\${IFS}INJIZIERT;'-12345678"` → Exit 2,
    `ABBRUCH — Ref 'mutate/x';echo${IFS}INJIZIERT;'-12345678' hat nicht die Form …`. Eine Zeile
    `INJIZIERT` gibt es nicht (`grep -cx INJIZIERT` → 0).
  - Gebrochen mit 661 (`"$$REF"` → `'$(REF)'`) → `not ok 16 rezept: mutate-branch reicht den Ref als
    Wert durch …`, `[ ! -e …/INJIZIERT-AUS-DEM-REF ]` failed. Unter der Mutation lief der
    eingeschleuste Code also tatsächlich.
- **Anweisungssätze und Sensor-Doku — bestätigt, mit LOW-1.** `implement-slice.md` Schritt 12 und
  `agents/implementer.md` lassen das Werkzeug fragen und dem Urteil folgen. Beide nennen den Weg, beim
  CI-Weg auch Branch und Commit, und benennen „make meldet Fehler 10“. `agents/verifier.md` regelt
  Lesen, Abgleich, Übernahme und Löschen; diesem Ablauf folgt dieser Lauf. `harness/sensors/mutate.md`
  §CI-Branch nennt Weg, Ergebnisform und Grenze, `harness/README.md` hat die zwei Werkzeuge-Zeilen mit
  `kein Gate`.
- **`make gates` grün** — Ergebnis im Commit dieses Berichts, gefahren über dem Stand vor dem Commit.
- **Review** — liegt vor (`9a9ea6e9`). Die Fixes sind stichprobenartig geprüft:
  - MEDIUM-1: Injection-Probe oben.
  - MEDIUM-2: eine Quelle `CI_SHARDS`, dazu `FEHLT` (664).
  - MEDIUM-3: Plan `742c5f76` nennt `mutate/<kennung>-<sha8>`, ohne Force.
  - LOW-1: 663.
  - LOW-3: §Grenze „Die Basis ist der Claim-Commit, nicht der Slice“.
- **Übergabe an den Architect** — liegt als `ed2ac693` (MR-091) vor, eigener Commit. Er entscheidet
  das Schreibrecht nach MR-014 und setzt Kopf-Marken an MR-090 und MR-014. MR-071 ist laut Message
  „unberuehrt“, obwohl der DoD-Punkt MR-071 *und* MR-090 nennt. Ob das trägt, entscheidet der Planner.
- **Closure-Punkte** (Notiz, Register, Risiko-Ausgänge, Paarungen) — offen, Planner-Arbeit.

## Befunde

- **LOW-1 — Zusage zum Exit-Code an der make-Zeile.**
  - `harness/README.md` (Zeile `make mutate-auswahl`) sagt „lokaler Lauf (Exit 0) oder Push … (Exit 10)“.
  - Gemessen endet `make mutate-auswahl` beim CI-Weg mit **Exit 2**, gleich dem Abbruch ohne
    Claim-Commit. Exit 10 hat nur das Skript.
  - Damit unterscheidet ein Aufrufer über den make-Exit allein den CI-Weg nicht vom Abbruch. Plan §1
    („Die zwei Wege unterscheiden sich im Exit-Code“) gilt so nur für das Skript.
  - Die Anweisungssätze fangen das über die Meldung `Fehler 10` ab, die README-Zeile nicht.
  - Folge: die Zeile auf das Skript beziehen oder den make-Exit durchreichen. Kein Sensor hält das.

## Plan-vs-Code

- **Plan → Code:** Alle Punkte aus §1 und §3 sind gebaut: Branch-Form, Basis = Claim-Commit
  (fail-closed), Fallmenge, Schwelle, Zuteilung über `is_heavy_mode`/`plan_self_contained`, eigene
  Workflow-Datei, Ergebnisform, Push ohne Force mit Präfix-Abbruch, Überspringen des Ergebnis-Tips
  und 10 Shards nachts.
- **Code ohne Plan, alles folgerichtig, kein Befund:**
  - zweites Ziel `make mutate-branch`, weil die Workflow-Schritte nach MR-014 `make` rufen;
  - `.d-check.yml` `targets.exempt-targets` (`b7de7a9a`);
  - `tags: ['**']` in `ci.yml`, damit Tag-Pushes neben dem Branch-Filter weiterlaufen;
  - `FEHLT`/`UNERWARTET` in der Ergebnisdatei.
- **Abweichung im Wortlaut:** DoD-1 nennt die Eingaben „Basis, Commit, Shard-Zahl und Index“. Das
  Werkzeug nimmt die Kennung (die Basis folgt daraus) und misst immer `HEAD`. Der Sache nach deckt §1
  das ab.
- **Risiko „Ergebnisdatei gelangt nach `main`“:** `git ls-files mutate-ergebnis.txt | wc -l` → 0. Ein
  Wächter fehlt weiter, `mutate.md` §Grenze benennt das.

## Offen für die Closure (Planner)

- Ausgänge für die Risiken aus §6: Schreibrecht, Branch-Leichen, Ergebnisdatei nach `main`, Grenze
  der Auswahl, Schleife. Zu „Schleife“: 665 ist rot gesehen; ob der Ergebnis-Tip `786bd511` einen zweiten
  Workflow-Lauf startete, ist ohne `gh` nicht beobachtbar (ein solcher Lauf pusht nicht).
- MR-071 aus der Übergabe: siehe oben.
- LOW-1.
- Closure-Trigger „kein Branch dieses Slice liegt mehr“: zum Zeitpunkt dieses Berichts erfüllt
  (`git ls-remote` leer).
