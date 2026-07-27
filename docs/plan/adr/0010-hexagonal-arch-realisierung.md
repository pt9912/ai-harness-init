# ADR-0010: Hexagonal als zweite Layout-Realisierung der Architektur-Achse

**Status:** Proposed

**Datum:** 2026-07-27

**Autor:** ai-harness-init-Team (pt9912)

**Bezug:** [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [ADR-0008](0008-arch-achse-emittiertes-skelett.md), [ADR-0009](0009-hexslice-arch-realisierung.md)

**Schärft:** [`architecture.md §5`](../../../spec/architecture.md) — die Beschreibung der
Fragment-Assembly und der Arch-Achse führt bislang **ein** schichten-tragendes Layout; diese ADR
macht das zweite verbindlich. Wer sie ändert, zieht §5 nach.

---

## Kontext

[ADR-0008](0008-arch-achse-emittiertes-skelett.md) hat die Architektur-Achse eingeführt,
[ADR-0009](0009-hexslice-arch-realisierung.md) ihre erste Realisierung (**HexSlice** = hexagonal +
Vertical Slice) festgelegt. Mit CR **0.17.0** führt
[`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) eine dritte
Architektur: **`hexagonal`** — die drei klassischen Schichten ohne Use-Case-Slices.

Der Bedarf ist **belegt, nicht angenommen** (die Setzung „weitere nur mit belegtem Bedarf, kein
spekulatives Layout" verlangt das):

1. Das gepinnte **Arch-Gate liefert die hexagonale Form als Standard-Gerüst**
   (`a-check --print-config` → `core` / `ports` / `adapters`, Kanten `adapters→ports`,
   `ports→core`). Wer dieses Gerüst in ein Ziel-Repo legt, bekommt ein Layout, das unser Generator
   bislang **nicht erzeugen kann**.
2. **Zwei reale Repos derselben Werkzeug-Familie** bauen so — gemessen an ihren `.a-check.yml`.

Und genau dort entsteht die Entscheidung, denn die beiden Belege sind **nicht deckungsgleich**:

| | Gate-Gerüst (`--print-config`) | gelebte Familien-Konvention |
|---|---|---|
| Kern | `internal/core/**` | `internal/hexagon/core/**` |
| Ports | `internal/ports/**` | `internal/hexagon/port/**` |
| Adapter | `internal/adapters/**` | `internal/adapter/driven/**` |
| Kante `adapters→core` | nur **auskommentiert** | **real geführt** |

**Annahme, auf der diese ADR steht:** die gelebte Konvention der Familie ist die verlässlichere
Referenz, weil sie an realen Repos erprobt ist, während das Gerüst ein Minimalbeispiel der
Werkzeug-Dokumentation ist. Kippt diese Annahme — etwa weil das Gate seine Standardform künftig
erzwingt —, kippt die Entscheidung.

## Entscheidung

**Genau zwei Festlegungen.**

**Festlegung 1 — emittiert wird die gelebte Familien-Konvention, nicht das Gate-Gerüst.**
`--arch hexagonal` erzeugt

| Rolle | Verzeichnis | im Arch-Gate |
|---|---|---|
| Kern | `internal/hexagon/core/**` | Schicht `core` |
| Ports | `internal/hexagon/port/**` | Schicht `ports` |
| getriebene Adapter | `internal/adapter/driven/**` | Schicht `adapters` |
| **treibende Seite** | **`internal/adapter/driving/cli/**`** | **Composition Root** (von den Schichtregeln befreit) |
| Einstiegspunkt | `cmd/**` | **Composition Root** |

Die emittierte `.a-check.yml` führt die Kanten `adapters→ports`, `ports→core` **und
`adapters→core`** sowie `composition_root: ["cmd/**", "internal/adapter/driving/cli/**"]`.

Begründung: ein Adopter soll ein Layout bekommen, das in dieser Werkzeug-Familie **real gebaut und
real geprüft** wird — nicht das Minimalbeispiel der Werkzeug-Doku. Die Kante `adapters→core` ist
Teil der Festlegung, weil Adapter Domänentypen abbilden; sie sieht wie ein Überschuss aus und
braucht deshalb einen eigenen Wächter.

**Zur treibenden Seite** (ergänzt in Runde 2, nachdem der Proposed-Review sie als Lücke fand):
Beide Referenz-Repos haben eine, an **verschiedenen** Orten — `internal/cli` beim einen,
`internal/adapter/driving/cli` beim anderen —, und **beide behandeln sie als Composition Root**.
Die Familie ist hier also nicht einheitlich; gewählt wird `internal/adapter/driving/cli`, weil es
die Ports-und-Adapter-Sprache konsequent durchhält (*driving* und *driven* als Paar) und den
Adapter-Begriff nicht auf halbem Weg verlässt. Verworfen: `internal/cli` — kürzer, aber es
verlässt das Vokabular genau dort, wo die Architektur ihren Namen hat.

**Festlegung 2 — `hexagonal` und `hexslice` sind getrennte Layouts, nicht zwei Strenge-Grade.**
Sie teilen die Idee (Kern innen, Adapter außen), aber **nicht die Verzeichnisnamen**: `core` gegen
`domain`, `port` gegen `application/**/ports`, `adapter/driven` gegen `adapters/outbound`. Ein
gemeinsames Layout mit zwei Kanten-Mengen wäre nicht sparsamer, sondern **unbewachbar**: die
Regeln, die HexSlice ausmachen (Slice-Lokalität, laterale Trennung), hängen an literalen
Verzeichnis-Präfixen. Konsequenz: der Generator führt zwei Rollen-Sätze, und ein Test hält die
**Disjunktheit der Verzeichnisnamen** fest.

## Verglichene Alternativen

<!--
Mindestens drei Optionen mit Pro/Contra. Alternativ "nichts tun" ist
auch eine Option.
-->

| Option | Pro | Contra |
|---|---|---|
| A — Gate-Gerüst emittieren (`internal/core` …) | deckungsgleich mit `a-check --print-config`; ein Adopter, der beides vergleicht, sieht keine Abweichung | **kein Repo der Familie ist so gebaut**; die real geführte Kante `adapters→core` fehlt dort; wir würden ein Minimalbeispiel zur Konvention erheben |
| B — `hexagonal` als Modus von `hexslice` (dieselben Verzeichnisse, weniger Regeln) | ein Layout weniger im Generator; scheinbar sparsamer | die HexSlice-Regeln hängen an literalen Verzeichnis-Präfixen — ein gemeinsames Layout mit zwei Kanten-Mengen ist **nicht bewachbar**; die Namen (`domain` vs `core`) passen nicht |
| C — gar nicht liefern, Adopter schreibt sein Layout selbst | kein Aufwand; maximale Freiheit | der belegte Bedarf bliebe unbedient; der Generator könnte die Form, die das Gate als Standard vorschlägt, weiterhin nicht erzeugen |
| **D — gelebte Familien-Konvention als eigenes Layout (gewählt)** | erprobt an zwei realen Repos; die Kanten-Menge stimmt mit der Praxis; getrennte Layouts bleiben bewachbar | Abweichung vom `--print-config`-Gerüst muss erklärt werden; zwei Rollen-Sätze im Generator; die `.a-check.yml` wächst weiter N×M (je Sprache × Architektur) |

## Konsequenzen

<!--
Was folgt aus der Entscheidung? Sowohl Positives als auch Schmerzen.
Was wird leichter, was schwerer.
-->

- **Positiv:** ein Adopter bekommt ein Layout, das in der Familie real gebaut wird — inklusive der
  Kante, die das Gerüst nur andeutet. Die beiden Layouts bleiben getrennt bewachbar; HexSlice
  behält seine Slice-Regeln unverändert.
- **Negativ:** die Abweichung vom `--print-config`-Gerüst ist erklärungsbedürftig — wer beides
  nebeneinander legt, sieht unterschiedliche Pfade. Der Generator trägt zwei Rollen-Sätze; die
  Menge der Arch-Gate-Configs wächst weiter mit **Sprache × Architektur** (der Renderer nicht).
- **Negativ, und der Preis der Familien-Treue:** die treibende Seite ist **Composition Root** und
  damit von den Schichtregeln **befreit**. Ein treibender Adapter darf dort am Port vorbei direkt
  in den Kern greifen, ohne dass das Gate etwas meldet. Bei `hexslice` ist das anders — dort ist
  der Inbound-Adapter eine echte Schicht mit der Kante `adapters→app`. Wir übernehmen die
  schwächere Prüfung bewusst, weil beide Referenzen es so halten und der Composition Root
  konstruktionsbedingt alles verdrahten darf; wer mehr Strenge will, wählt `hexslice`. Diese
  Asymmetrie zwischen den beiden Layouts ist eine **Eigenschaft**, kein Versehen — sie gehört in
  die Nutzer-Doku, sonst liest sie sich als Inkonsistenz.
- **Folgepflicht 1 (blockierend für die Umsetzung):** die Geschichtet-Erkennung ist heute an
  HexSlice-Namen verdrahtet (`archLayered` prüft `roleDomain`; der Kopplungs-Wächter prüft
  `hexagon/domain/`). Sie wird auf eine **strukturelle** Bedingung gehoben, sonst entsteht ein
  geschichtetes Modul **ohne** Arch-Gate, während der Wächter grün bleibt
  ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Folgepflicht 2:** [`architecture.md §5`](../../../spec/architecture.md) beschreibt bislang ein
  schichten-tragendes Layout und wird nachgezogen.
- **Folgepflicht 3:** die zweite Sprache (C++) erbt die Achse, **nicht** die Kanten-Menge — dort
  erfüllt ein Adapter seinen Port durch Vererbung und braucht zusätzlich `adapters→ports` (in
  slice-053 gemessen). Eigener Zuschnitt.
- **Folgepflicht 4:** die emittierte `.a-check.yml` nennt in ihrem Kopf-Kommentar, **warum** die
  Pfade vom `--print-config`-Gerüst abweichen. Der Adopter liest zuerst die Config; ohne den Satz
  hält er die Abweichung für einen Werkzeug-Fehler.

## Fitness Function (falls maschinell prüfbar)

<!--
Wenn die Entscheidung sich in einer prüfbaren Eigenschaft des Codes
niederschlägt: hier die konkrete Regel benennen. Beispiel:
"depguard verbietet Import von internal/runtime aus internal/service."
-->

| Tooling | Regel | Make-Target |
|---|---|---|
| a-check (im Ziel) | Ein Import von `core` nach `adapter` verletzt die Richtung und färbt das Gate rot — **mit** Richtungs-Befund, nicht nur Exit ≠ 0 | `make a-check-<modul>` im emittierten Repo, gefahren im `make full-smoke` |
| Go-Test (hier) | Jede schichten-tragende (Sprache, Architektur) hat eine Arch-Gate-Config — die Erkennung ist **strukturell**, nicht namensbasiert | `make test` (`TestArchGateConfig_CoversEveryLayeredCombo`) |
| Go-Test (hier) | Die Verzeichnisnamen von `hexagonal` und `hexslice` sind **disjunkt**; die Namen werden aus den Renderern abgeleitet, nicht aus einer Liste | `make test` |
| `make mutate` | Die Kante `adapters→core` wird entfernt → der zugehörige Wächter muss rot werden | `make mutate` |

## Re-Evaluierungs-Trigger

- Wenn das Arch-Gate seine Standardform **erzwingt** (statt sie vorzuschlagen) — dann kippt die
  Annahme, auf der Festlegung 1 steht.
- Wenn ein Repo der Familie das Layout ändert — die Referenz ist die gelebte Praxis, nicht ein
  eingefrorener Snapshot. **Ehrlich eingeordnet:** diesen Trigger feuert **kein Sensor**. Die
  Referenz-Repos liegen außerhalb dieses Repos; kein Gate und kein Nachtlauf sieht sie. Er lebt
  rein im *inferential-feedforward*-Quadranten und wirkt nur, wenn ihn jemand liest.
- Wenn eine **vierte** Architektur hinzukommt und sich zeigt, dass drei getrennte Rollen-Sätze den
  Kompositions-Kern verbiegen — dann ist Option B erneut zu prüfen, diesmal mit Messung statt
  Vermutung.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-07-27 | Proposed | `docs/plan/planning/open/slice-058-hexagonal-go.md` §3a (Plan-Review F-2 verlangte die Entscheidung) |
| 2026-07-27 | Überarbeitet (Runde 2), weiter Proposed | Proposed-Review `docs/reviews/2026-07-27-adr-0010-proposed-review.md`: F-1 (treibende Seite fehlte, Familie uneinheitlich) und F-2 (`composition_root` zu eng) aufgelöst, F-4 (Trigger ohne Sensor) eingeordnet, F-5 als Folgepflicht 4 ergänzt |

<!--
Nach Accepted: NICHT mehr inhaltlich überschreiben (Hard Rule aus
c-hsm-doc, siehe Kurs Modul 4). Spätere Schärfungen als neue ADR mit
"Supersedes ADR-NNNN" anlegen.
-->
