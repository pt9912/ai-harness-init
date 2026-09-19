# Review-Report: slice-stumme-mutations-faelle-folgen-der-config-form — 2026-09-19 (Runde 1)

**Review-Art:** Code — geprüft gegen Slice-Plan + Konventionen (`AGENTS.md` §3),
statisch und dynamisch gegen den kuratierten Mutations-Satz.

**Gegenstand:** Diff `0b6f53df..cc22df18` — genau ein Commit (`cc22df18`, 4 Dateien,
+25/−19): `internal/gen/archgate_test.go` (Zahn-Kommentar), `test/mutations/68-archconfig-kopplung.sh`,
`71-archgate-kante-auf-vorrat.sh`, `96-cpp-archgate-adapterport-kante.sh`.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 ·
**Modell:** GLM (glm-5.3-flash) · **Datum:** 2026-09-19

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis; die `<Platzhalter>` darin sind Formbeispiele)*. Dieser
> Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link
> (`v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt>). Der vendored Baum trägt
> genau einen Tag; der Sprung löscht den alten, und ein Link darauf färbt beim
> nächsten Bump ein Artefakt rot, das niemand mehr anfassen darf. Ein `pfad`-Feld
> auf den **geprüften Gegenstand** ist davon nicht betroffen — es zitiert den
> Stand des Laufs und darf ihn festhalten (`v<X.Y.Z>` ·
> `regelwerk/grundlagen-harness-dateien.md` §harness/README.md als
> Einstiegspunkt — diese Zeile ist selbst ein Beispiel der Form).

**Eingangs-Kontext:**

- Slice-Plan `slice-stumme-mutations-faelle-folgen-der-config-form` (`in-progress/`)
- `ADR-0060` (`Accepted`) — die re-geschnittene Config-Form; `ADR-0009` (in den
  Fall-Kommentaren zitiert)
- `AGENTS.md` §3 (Hard Rules, namentlich §3.6, §3.7)
- Verifikations-Report `docs/reviews/2026-09-19-slice-adapter-und-ports-ordner-folgen-ihren-rollen-namen-verifikation.md`
  (Befunde V-1, V-4 — der Anlass dieses Slices)
- `make gates` grün über `cc22df18` — nicht wiederholt, am Stempel gelesen (record-gates);
  `make docs-check` 1755/0 ebenda.

---

## Mess-Stand

**Statisch — Muster gegen den Baum (`cc22df18`):** je Fall trifft das neue Muster
genau eine Fundstelle, je Alt-Muster null:

- `grep -c 'greet/ports/inbound/\*\*' internal/gen/golang.go` → **1** (Fall 68); Alt-Form
  `grep -c 'greet/ports/\*\*' internal/gen/golang.go` → **0**
- `grep -c '  - {from: driven_adapters,  to: domain}' internal/gen/golang.go` → **1** (Fall 71);
  Alt-Form `grep -c 'from: ports,    to: domain' internal/gen/golang.go` → **0**
- `grep -c '{from: driven_adapters,  to: ports_outbound}' internal/gen/cpp.go` → **1** (Fall 96);
  Alt-Form `grep -c '{from: adapters, to: ports}' internal/gen/cpp.go` → **0**

**Dynamisch — alle drei Fälle im Wegwerf-Klon selbst gefahren** (Kopie des Baums nach
außerhalb, je Fall: Mutation ansetzen → `make test-go` → zurückgenommen): je Fall
`MUT-RC=0` (Mutation greift) und `TEST-GO-RC=2` (rot), je Fall steht der **benannte**
Wächter in der Fehlschlag-Ausgabe:

- Fall 68 (expect `TestArchGateConfig_MatchesSkeleton`): `--- FAIL: TestArchGateConfig_MatchesSkeleton`,
  daneben `--- FAIL: TestArchGateConfig_EdgesMatchSkeleton` — derselbe mutierte Port-Glob
  trifft beide Config-gegen-Skelett-Prüfungen; Bedingung 4 des Treibers (benannter Wächter
  in der FEHLSCHLAG-Ausgabe) ist erfüllt.
- Fall 71 (expect `TestArchGateConfig_EdgesMatchSkeleton`): `--- FAIL: TestArchGateConfig_EdgesMatchSkeleton`,
  daneben `--- FAIL: TestArchGateConfig_CppAllowsAdapterToPorts` — die hinzugefügte
  Go-Kante bricht zusätzlich die bewusste Go/C++-Asymmetrie, die derselbe Test-Satz prüft;
  benannter Wächter fällt.
- Fall 96 (expect `TestArchGateConfig_CppAllowsAdapterToPorts`): `--- FAIL: TestArchGateConfig_CppAllowsAdapterToPorts`
  — exakt der eine, kein weiterer.

**Zensus über den ganzen kuratierten Satz** (je Fall: `# files:`-Auflösung, `sed` in
einer Wegwerf-Kopie, `sha256sum`-Vergleich vor/nach, Restore aus der Pristin-Kopie):
`ls test/mutations/*.sh | wc -l` → **365**; Bilanz **362 greifen · 3 stumm · 0 defekt**
(kein `# files:`-Kopf unauflösbar, kein Skript-Exit ≠ 0). Die drei umgeschnittenen Fälle
68/71/96 stehen unter den 362. Die 22 Fälle, die auf die zwei emittierten Config-Dateien
zielen (`grep -lE '^# files: .*internal/gen/(golang|cpp)\.go' test/mutations/*.sh | wc -l`
→ **22**), sind in der Bilanz enthalten. **Kein vierter stummer Fall aus der
Config-Re-Schnitt-Klasse — dafür drei stumme Fälle aus derselben Defekt-Klasse an
anderen Zielen** (Befund F-1).

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Der kuratierte Satz trägt an drei weiteren Stellen Zähne, deren sed-Muster den Quell-Bestand nicht mehr treffen: Fall 29 sucht `body = NeutralizeRoadmap(body)` — `grep -cF 'body = NeutralizeRoadmap(body)' internal/emit/templates.go` → **0** (die Stelle liest sich jetzt `return NeutralizeRoadmap(body), nil`, `internal/emit/templates.go:414`); Fall 275 sucht `body = NeutralizePlanningReadmeCarveoutsDoneRef(body)` — `grep -cF` → **0** (jetzt `return NeutralizePlanningReadmeCarveoutsDoneRef(body), nil`, `:428`); Fall 114 sucht `if rmErr := syscall.Rmdir(path); rmErr != nil {` — `grep -cF 'rmErr := syscall.Rmdir(path)' internal/span/emit.go` → **0** (kein `Rmdir` mehr in der Datei; die Span-Sperre trägt je-OS-Dateien). `make mutate` meldet dort Bedingung 2 „Mutation hat nicht gegriffen — Patch veraltet?“ | `AGENTS.md` §3.6 (`make mutate` meldet jeden gelisteten Wächter, der seine Zähne verloren hat) | `test/mutations/29-roadmap-nicht-neutralisiert.sh` · `test/mutations/114-span-lock-verzeichnis.sh` · `test/mutations/275-planning-readme-carveouts-done-ref-nicht-neutralisiert.sh` | ja — der nächste `make mutate`-Lauf meldet die drei als BEFUND (Bedingung 2); statisch je `grep -cF` → 0 | stumme Mutations-Faelle nach Quell-Re-Schnitt |
| F-2 | LOW | Die Schlusssform des Zahn-Kommentars — „… der Gegenbeispiel-Nachweis liegt als Hand-Messung vor.“ — behauptet die Existenz eines Belegs ohne auflösbaren Ort; `AGENTS.md` §3.7 verlangt, dass Herkunft als **ein** auflösbares Feld steht oder nicht genannt wird. Die übrigen Sätze derselben Form tragen die Kommentar-Klassen (Kopplung/Zusage des Pins an die Fassung, Grenze: kein Fall im kuratierten Satz) und stehen in Zustandsform — kein Lauf-Protokoll, kein Datum, keine Runden-Nummer. | `AGENTS.md` §3.7 (Ein Kommentar beschreibt, was da ist) | `internal/gen/archgate_test.go:233-234` | nein — Kommentar-Behauptungen sind keinem Sensor unterworfen (dieselbe Grenze, die der Slice-Plan an Liefer-Punkt 2 benennt) | unauflösbarer Beleg-Anker im Zahn-Kommentar |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Fälle 68/71/96 — statisch gegen die re-geschnittene Form | geprüft, ohne Befund — je neues Muster 1 Fundstelle, je Alt-Muster 0 (Kommandos unter „Mess-Stand“) |
| Fälle 68/71/96 — dynamisch im Wegwerf-Klon | geprüft, ohne Befund — je Fall greift die Mutation (`MUT-RC=0`, sha-Diff im Zensus), `make test-go` fällt (exit 2) und der benannte Wächter steht in der Fehlschlag-Ausgabe; Polarität akkurat: Fall 96 exakt einzeln, Fälle 68/71 färben zusätzlich einen zweiten, aus derselben Mutation folgenden Wächter desselben emittierten Config-Satzes |
| Zensus über alle 365 Fälle | geprüft — Befund ist F-1; kein weiterer stummer oder defekter Fall |
| Commit-Umfang (`0b6f53df..cc22df18`) | geprüft, ohne Befund — der Range trägt genau einen Commit mit genau den vier genannten Dateien, +25/−19, nichts darüber hinaus |
| Fremd-Kennungen (Referenz `/Development/hexslice-architecture/`) | geprüft, ohne Befund — der Commit führt keine Referenz-Kennung des Nachbar-Repos ein; die `hexslice`-Treffer in `internal/gen/archgate_test.go` sind das Vokabular-Argument bestehender Fixtures (`GenerateArch(…, "hexslice")`, Arch-Name) und werden vom Commit nicht neu eingeführt |
| Zahn-Kommentar, übrige Sätze (`:227-232`) | geprüft, ohne Befund — Zustandsform (Kopplung/Zusage/Grenze), keine verworfene Alternative, kein abwesender Text; die 365-Fälle-Behauptung der Vorgänger-Fassung ist entfernt, sie steht nur noch im Zeitdokument (Verifikations-Report V-4) |
| Fall-Kommentare der drei umgeschnittenen Fälle | geprüft, ohne Befund — je Fall benennen Kopf und Kommentar den Wächter, die Config-Form und die Klasse, die er fängt (Kopplung/Konsequenz/Grenze), in Zustandsform |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 1 |
| INFO | 0 |

**Finding-Klassen dieses Laufs:** stumme Mutations-Faelle nach Quell-Re-Schnitt · unauflösbarer Beleg-Anker im Zahn-Kommentar

## Verdikt

**Merge-blockierend:** nein — beide Befunde berühren Gegenstände, die dieser Commit
nicht trägt. F-1 zielt auf `internal/emit/templates.go` und `internal/span/emit.go` —
beide zuletzt geändert am 2026-09-18 (`6db58a73`, `f9b62059`), vor dem Commit, und vom
Umschnitt nach Plan-Abgrenzung nicht getragen; der Commit selbst erfüllt seinen
Umfang statisch wie dynamisch vollständig. F-2 ist Kommentar-Form am bestehenden Zahn
und nicht gate-gebunden. F-1 braucht einen eigenen Umschnitt desselben Typs — als
Folge-Slice oder als Erweiterung dieses Slices vor seiner Closure; die Entscheidung
dazu ist Übergabe an den Implementer bzw. Planner.

**Übergabe:** Findings gehen an den Implementer; die **Finding-Klassen** gehen
zusätzlich in die Slice-Closure §7 und von dort in den Zähler. Dieser Report ist
ein **Lauf-Beleg** — er wird über Läufe hinweg nicht wieder gelesen. DoD-/
Spec-Konformität prüft die Verifikation separat (Modul 11).