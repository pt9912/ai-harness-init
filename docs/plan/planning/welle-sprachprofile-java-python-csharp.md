# Welle welle-sprachprofile-java-python-csharp: Sprachprofile java, python und csharp

**Lifecycle:** Diese Datei entsteht bei der **Eröffnung** der Welle und liegt
flach unter `docs/plan/planning/`; bei Closure wandert sie per `git mv` nach
`done/` (neben ihre `welle-<Kennung>-results.md`). Der Zustand ist die
Verzeichnis-Position — kein Status-Feld. **Geplante Wellen bekommen noch keine
Datei:** Sie stehen in der Roadmap unter *Nächste Wellen* und nirgends sonst —
zwei Positionen, nicht drei.

**Zielmeilenstein:** kein Meilenstein-Bezug.

**Verantwortlich:** Planner. **Datum:** 2026-10-17.

---

## 1. Welle-Ziel

Das Lastenheft nennt sechs Sprachen ([`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4):
`go`, `python`, `kotlin`, `java`, `csharp`, `cpp`); `internal/gen/` trägt drei Profile (`go`, `cpp`,
`kotlin`). Die Welle schließt die Lücke für `java`, `python` und `csharp`: `add-lang <sprache>` rendert
je Sprache ein Skelett mit Code-Gate und Guard-Set, dessen Toolchain, Pins, Gate-Targets und
Arch-Unterstützung eine ADR des Architect je Sprache festlegt. Das *Mehr* über die Slice-DoDs: ein
einziger `make full-smoke`-Lauf trägt die Stufen aller drei Sprachen zugleich und bleibt neben
Go, C++ und Kotlin grün (§3).

## 2. Trigger (Welle startet)

- `welle-kotlin-skelett` ist geschlossen (Muster-Welle, Renderer-Vorbild
  [ADR-0088](../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md)): `ls docs/plan/planning/done/welle-kotlin-skelett-results.md` findet die Datei. Die
  Welle setzt auf dem Renderer-Muster und den Stufen auf, die jene Welle geliefert hat.
- `gen.SupportedLangs()` führt `cpp`, `go`, `kotlin` und keine der drei Sprachen dieser Welle
  (`internal/gen/gen.go`, Funktion `SupportedLangs`) — die Lücke besteht.

## 3. Closure-Trigger (Welle schließt)

- Alle Slices aus §4 liegen in `done/`.
- `make gates` grün.
- **`make full-smoke` grün, und `docs/user/e2e-abdeckung.md` führt je neuer Sprache mindestens eine
  Stufe mit [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), deren Kurzbeschreibung die Sprache nennt.** Der Ist-Stand, gegen den der
  Trigger formuliert ist: die Stufen 12 bis 14 fahren je Sprache ein Ziel mit `add-lang` im Mono-Repo
  (Go+Go, C++, Kotlin), und keine Stufe nennt `java`, `python` oder `csharp` (`grep -n -E 'java|csharp' harness/tools/full-smoke.sh docs/user/e2e-abdeckung.md`
  → kein Treffer; `python` steht dort nur in einem Kommentar über die Abwesenheit von `python`/`jq`
  auf dem Host). Je neuer Sprache muss die Stufe mindestens messen, was Stufe 14 für Kotlin misst:
  `add-lang <sprache>` ins Mono-Repo, die Skelett-Dateien liegen, `make gates` des Ziels ist grün
  **mit Beleg, dass das Code-Gate der Sprache gelaufen ist**, und der Guard blockt die Host-Toolchain
  der Sprache. Layouts darüber hinaus (`hexslice` mit Arch-Gate, Root-Bootstrap) liefert ein Slice
  nur, soweit seine ADR sie trägt; was eine Stufe nicht misst, nennt ihre Kurzbeschreibung am selben
  Ort ([`AGENTS.md`](../../../AGENTS.md) §3.6).
- Closure-Notiz in `welle-sprachprofile-java-python-csharp-results.md`.

## 4. Slices in dieser Welle

| Slice | Titel | Bezug |
|---|---|---|
| `slice-java-skelett` | Java als Sprachskelett mit Code-Gate und Guard | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) |
| `slice-python-skelett` | Python als Sprachskelett mit Code-Gate und Guard | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) |
| `slice-csharp-skelett` | C# als Sprachskelett mit Code-Gate und Guard | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) |

Offene Beobachtungen sind gesichtet in §8 jedes Slice-Plans; Treffer der Eröffnung (Schritt 2):
`handbuch-sprachbaum-ohne-sensor-in-full-smoke` (1, offen),
`emittiertes-gate-am-gemischten-root-baut-das-dockerfile-einer-anderen-sprache` (1, offen),
`emittiertes-lint-rezept-uebergibt-die-go-version-nicht` (1, offen) und
`cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht` (offen, ohne Beleg-Verzeichnis) — alle
unter der Schwelle; keiner erreicht mit der Eröffnung 3×.

## 5. Abhängigkeiten

- Binnen-Kanten: keine tragende. Der Reihenfolge-Vorschlag `slice-java-skelett`,
  `slice-python-skelett`, `slice-csharp-skelett` ordnet nur — die Slices berühren dieselben Dateien
  (`internal/gen/gen.go`, `harness/tools/full-smoke.sh`), und das WIP-Limit lässt ohnehin einen
  Slice zugleich zu.
- Je Slice: die ADR des Architect für diese Sprache steht `Accepted`, bevor der Slice
  `in-progress/` betritt (Start-Bedingung in §4 des Slice-Plans, kein Start-Trigger der Welle).
- Blockiert: keine Welle. Wird blockiert von: keiner Welle.

## 6. Out-of-Scope für diese Welle

- **Ein Release** (Tag, Release-Text, Handbuch-Nachzug) — gehört in einen eigenen Release-Schnitt,
  wie bei `welle-kotlin-skelett`; die Welle liefert Fähigkeit im Quellbaum, keine Veröffentlichung.
- **Weitere Sprachen** über `java`, `python`, `csharp` hinaus — das Lastenheft nennt keine
  weiteren; ein siebtes Profil bräuchte eine Anforderung.
- **Layouts, die die ADR der jeweiligen Sprache nicht festlegt** — insbesondere `hexagonal`; ohne
  ADR wäre es ein Skelett ohne getragene Entscheidung.
- **Der Handbuch-Sprachbaum und seine Messung in `full-smoke`**
  (`handbuch-sprachbaum-ohne-sensor-in-full-smoke`) — anderer Vorgang als das Skelett, bleibt Bestand.
- **Die ADRs selbst** — der Architect schreibt sie; die Welle plant, entscheidet nicht.

## 7. Closure-Notiz

<!-- Erst nach Welle-Abschluss füllen. -->
