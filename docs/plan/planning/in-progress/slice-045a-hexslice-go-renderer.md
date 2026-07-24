# Slice slice-045a: hexSlice-Arch-Layout + Go-Rollen-Renderer

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-07-arch-achse](../welle-07-arch-achse.md).

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [ADR-0009](../../adr/0009-hexslice-arch-realisierung.md), [ADR-0008](../../adr/0008-arch-achse-emittiertes-skelett.md).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-24.

---

## 1. Ziel

Der Generator kann das **hexSlice-Code-Layout** in Go erzeugen: `archLayout("hexslice")`
liefert die Rollen-Menge, und der **Go-Rollen-Renderer** (`goRole`) rendert sie in die
kanonischen Verzeichnisse (`internal/hexagon/{domain,application}`, `internal/adapters/{inbound,outbound}`,
`cmd/<binary>`) — abgeleitet aus der kanonischen `hexslice-architecture`-Referenz
([ADR-0009](../../adr/0009-hexslice-arch-realisierung.md)). Reine Generator-Erweiterung an der
Kompositions-Seam aus slice-044; **noch ohne** CLI-Flag (das ist slice-045b) und **ohne** a-check
(slice-046). Das flache Layout bleibt **byte-identisch**.

## 2. Definition of Done

- [ ] [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) (Arch-Achse, Layout-Teil): `composeSkeleton(goScaffolding, goRole, version, "hexslice")` erzeugt das vollständige hexSlice-Go-Skelett (domain/application/ports/adapters + `cmd/`) plus die arch-invariante Bau-Gerüstung; ein `gen`-Test verankert die exakte Datei-Menge + Verzeichnis-Struktur gegen die kanonische Referenz.
- [ ] [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (`flat` byte-identisch): `composeSkeleton(…, "flat")` bleibt bit-für-bit unverändert (kein Content-Konstant der flat-Rollen berührt); der bestehende `flat`-Test grün, `git diff` zeigt keine Änderung an flat-Content.
- [ ] `archLayout("hexslice")` liefert die hexSlice-Rollen-Menge; `archLayout(<unbekannt>)` bleibt `nil` (der Exit-2-Pfad ist slice-045b, hier nur die Renderer-seitige Grundlage).
- [ ] `make gates` grün (`go test ./...` inkl. der neuen Renderer-Tests).
- [ ] `make mutate` grün — der neue Layout-/Renderer-Wächter je rot gesehen (die rot-färbende Mutation benannt und als `test/mutations/`-Fall abgelegt).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

Vor Code den Ist-Stand messen: `archLayout`/`goRole`/`composeSkeleton` aus slice-044 lesen
(`internal/gen/arch.go`, `golang.go`), und die kanonische Referenz `hexslice-architecture/lab/examples/go`
als Rollen-Quelle spiegeln (Tool-als-Quelle, [ADR-0009](../../adr/0009-hexslice-arch-realisierung.md)).
Die a-check-Config (`.a-check.yml`/`a-check.mk`) und das CLI-Flag sind **nicht** hier.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/gen/arch.go` — `archLayout("hexslice")` | update | den `hexslice`-Zweig ergänzen: liefert die hexSlice-Rollen-Menge (Entrypoint + Test + die Schicht-Rollen); `flat` und `unknown→nil` unverändert |
| `internal/gen/golang.go` — `goRole` (hexslice-Zweig) | update | die Rollen in die kanonischen Go-Pfade rendern (`internal/hexagon/domain/<area>`, `internal/hexagon/application/<area>/<usecase>/{command,handler,validator,result,ports}`, `application/<area>/ports`, `internal/adapters/{inbound,outbound}/<typ>/<area>`, `cmd/<binary>/main.go`) mit minimalem, kompilierendem Inhalt aus der Referenz |
| `internal/gen/*_test.go` | neu | exakte Datei-Menge + Struktur des hexSlice-Skeletts verankern; `flat`-Byte-Identität separat |
| `test/mutations/NN-hexslice-*.sh` | neu | rot-färbende Mutation für den Layout-/Renderer-Wächter (z. B. eine Schicht-Datei aus der Menge entfernen → Test rot) |

## 4. Trigger

- **Beginn (`next` → `in-progress`):** slice-044 **done** (Kompositions-Seam existiert) — erfüllt.
- **`in-progress` → `next` (zu groß):** falls die ~25 Rollen-Dateien plus Byte-Identitäts-Beweis
  eine Slice sprengen, den Renderer je Schicht (domain → application → adapters → cmd) zerlegen.
- **`in-progress` → `open` (blockiert):** falls die kanonische Referenz für eine Rolle keine
  eindeutige minimal-kompilierende Form hergibt — Carveout (Modul 7) + Rückfrage.

## 5. Closure-Trigger

DoD vollständig (alle Häkchen), `make gates` + `make mutate` grün mit rot-gesehener Mutation,
Review konform + Verifier bestätigt die DoD, Closure-Notiz mit Steering-Loop-Eintrag geschrieben.

## 6. Risiken und offene Punkte

- **Byte-Identität `flat`:** die additive `hexslice`-Erweiterung darf keinen flat-Content-Konstant
  berühren (slice-044-Lehre: additive Erweiterung schützt die Sensoren) — separat mit `git diff` belegen.
- **Renderer-Inhalt vs. Referenz:** minimal-kompilierend genügt; keine Über-Nachbildung der
  Referenz-Business-Logik (Order/CreateOrder) — die Struktur ist das Vertrag, nicht die Domäne.
- **a-check-Konformität** des gerenderten Layouts wird erst in slice-046 mit `make a-check` bewiesen;
  hier nur strukturell gegen die 5-Kanten-Erwartung aus [ADR-0009](../../adr/0009-hexslice-arch-realisierung.md) geplant.

## 7. Closure-Notiz (nach `done/`)

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): die Änderung ist eine
**additive Generator-Erweiterung** (`internal/gen`, neue Renderer-Zweige + neue Tests) an der bereits
in slice-044 etablierten Kompositions-Seam — kein Bestandscode wird umgeschrieben, das flat-Layout
bleibt byte-identisch. Kein Inventur-/Diskrepanz-Risiko, kein Reconciliation-Aufwand.
