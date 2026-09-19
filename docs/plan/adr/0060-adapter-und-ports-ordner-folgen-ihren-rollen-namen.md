# ADR-0060: Die Adapter- und Ports-Ordner des hexslice-Skeletts folgen ihren Rollen-Namen — `driving`/`driven`, die Ports gegliedert

**Status:** Proposed

**Datum:** 2026-09-19

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0009](0009-hexslice-arch-realisierung.md) (**Accepted** — der Gegenstand der Teil-Ablösung:
seine Festlegung 2 trägt die Ordner-Namen und die flachen Ports; die Schichten-Tragung, die
Kanten-Menge, die Gate-Mechanik und die C++-Hälfte binden fort — §Supersedes (Teil) zählt den
Gegenstand wörtlich auf. **Der Autor dieses ADR-0009 ist der Auftraggeber** und hat die Richtung
gesetzt — §Kontext),
[ADR-0008](0008-arch-achse-emittiertes-skelett.md) (**Accepted** — die Arch-Achse und ihre
Mechanik: die Bau-/Toolchain-Gerüstung bleibt arch-invariant, `hexslice` ersetzt nur den
Code-Teil),
[ADR-0010](0010-hexagonal-arch-realisierung.md) (**Accepted** — Festlegung 1 hält die
`direction:`-Dimension leer *„als Entscheidung"*; ihr Re-Evaluierungs-Trigger *„wenn das Skelett
seine Ports teilt"* feuert mit dieser Entscheidung — die Neubewertung steht in Festlegung 3),
[ADR-0007](0007-bootstrap-phasen.md) (**Accepted** — die konvergente Emission: ein Re-Lauf
schreibt die Skelett-Ordner kanonisch neu; die Heilung eines Ziels ist ein Re-Lauf),
[ADR-0005](0005-ziel-repo-distribution.md) (**Accepted** — Tool-als-Quelle: die hexSlice-Referenz
ist die kanonische Quelle des Go-Renderers; der Upstream-Nachzug folgt derselben Linie),
[`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) (das
Arch-Gate-Config wandert mit — der Glob und die Rollen-Zuordnungen sind der Punkt, an dem die
Ordner-Namen in die geprüfte Schicht wirken),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (das
hexslice-Layout trägt reale Schichten; ein nicht-leerer Prüfbereich bleibt),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert)

**Schärft:** [`ARC-009`](../../../spec/architecture.md#1-komponenten-übersicht) — die hexslice-Skelett-Struktur
ist hier verbindlich gemacht: die Adapter- und Ports-Ordner des Generator-Outputs. Die
Spec-Stellen, die den Ist-Output beschreiben (die `ARC-009`-Zelle der Komponenten-Sicht und die
Prosa über die Arch-Achse mit *„`adapters` (`inbound`/`outbound`)"*), ziehen mit dem
Implementer-Vollzug nach — **Folgepflicht 4**; dieser Norm-Zug berührt den Code nicht, und der
Spec-Text beschreibt den Output, den der Generator heute legt.

**Supersedes (Teil):**
[ADR-0009](0009-hexslice-arch-realisierung.md) Festlegung 2 — dort genau **zwei Gegenstände**:
(i) die Adapter-Ordner-Namen — *„`internal/adapters/inbound/<typ>/<area>/` Use-Case-Entrypoint
(CLI · API · Messaging)"* und *„`internal/adapters/outbound/<typ>/<area>/` Port-Implementierung
(Persistenz · Notify · …)"* werden zu `driving`/`driven`; (ii) die **flachen** `ports`-Ordner der
drei Ebenen bekommen die `inbound`/`outbound`-Gliederung. Alles andere jener Festlegung bindet
unverändert fort: die Schichten-Tragung (`domain`, `application` als vertikale Use-Case-Slices mit
`command`/`query`/`handler`/`validator`/`result`), die **fünf erlaubten Kanten** (verbatim),
das Fehlen der `adapters→ports`-Kante samt ihrem Grund (Interface-Erfüllung statt Import,
verdrahtet im Composition Root), der Composition-Root-Status von `cmd/**`. Festlegungen 1
(Achsen-Wert `hexslice`), 3 (a-check-Pin + `.a-check.yml`-Schema) und die C++-Toolchain-Kette
binden unverändert fort. Diese ADR ändert, **wie die Ordner heißen und wie die Ports liegen** —
nicht, welche Schichten geprüft werden und welche Kanten gelten.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR) und §Hard Rule für Accepted-ADRs.

---

## Kontext

### Was die Entscheidung auslöst

Die Richtung ist gesetzt: der Auftraggeber — **der Autor von
[ADR-0009](0009-hexslice-arch-realisierung.md)** — hat am 2026-09-19 gesetzt: *„Ich werde auch
hexslice anpassen. Bitte hier wie bestellt umsetzen."* Die Setzung trägt zwei Hälften: die
Umsetzung **hier** (diese Entscheidung formt sie aus) und den **Upstream-Nachzug im Kurs** — der
Autor passt hexslice an der Quelle an; der Verweis steht als Kennung, nicht als Pfad-Link. Diese
Entscheidung ist das Übergabe-Artefakt für den blockierten Fix-Slice
(`slice-adapter-und-ports-ordner-folgen-ihren-rollen-namen`, `open/`), dessen §4-Grund und §6-
Übergabe in der Plandatei stehen; der laufende Architektur-Lauf liest sie dort.

### Die Rollen sind im Bestand — kein zweiter Namensraum

Die Rollen-Namen, auf die die Ordner künftig zeigen, existieren bereits:

```sh
grep -n 'hexagonal-driving\|hexagonal-driven' internal/gen/arch.go
#   :50 — roleHexagonalDriven  = "hexagonal-driven"
#   :54 — roleHexagonalDriving = "hexagonal-driving"
```

Der Generator führt sie als Rollen-Bezeichner; der Fix richtet die **Ordner** auf dieselben
Namen. Ein zweiter Namensraum — etwa `entry`/`persistence` neben den Rollen — entsteht nicht:
die Ordner-Namen und die Arch-Gate-Zuordnung lesen dieselben Konstanten.

### Die Ports-Gliederung existiert heute nur im Kommentar

Die inbound/outbound-Zuordnung der Ports ist heute Code-Kommentar, nicht Baum: der
Repository-Port ist outbound (der C++-Kommentar sagt es wörtlich —
`grep -n 'erfuellt den Area-Port durch VERERBUNG' internal/gen/cpp.go` → `:339`), und der
CLI-Adapter treibt die Use-Case und konsumiert einen inbound-Port. Diese Achse zieht die
Zuordnung aus dem Kommentar in die Ordner — sie ist dann an der Stelle geprüft, an der die
Ordner entstehen, nicht in einem Kommentar.

## Entscheidung

**Die Adapter-Ordner des hexslice-Skeletts tragen ihre Rollen-Namen — `driving`/`driven` statt
`inbound`/`outbound` — und die Ports tragen die `inbound`/`outbound`-Gliederung statt flach zu
liegen.** Sechs Festlegungen.

**1. Die Adapter-Ordner.** Go: `internal/adapters/{driving,driven}/<typ>/<area>/`; C++:
`src/adapters/{driving,driven}/<typ>/<area>/`. `driving` trägt den Use-Case-Entrypoint (CLI ·
API · Messaging), `driven` die Port-Implementierung (Persistenz · Notify · …) — dieselben
Inhalte, dieselbe `<typ>/<area>`-Tiefe, neue Namen aus der Rollen-Zuordnung des Generators. Der
Arch-Gate-Glob und die Rollen-Zuordnung wandern mit (der Punkt, an dem der Fix in die geprüfte
Schicht wirkt — [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)).

**2. Die Ports-Achse.** Die flachen `ports`-Ordner bekommen `ports/{inbound,outbound}/` — je
Ebene der drei Ports-Stufen aus
[ADR-0009](0009-hexslice-arch-realisierung.md) Festlegung 2 (use-case-lokal, business-area,
application-weit), nach derselben Rollen-Zuordnung: der **Repository-Port ist outbound** (er wird
von einem driven Adapter erfüllt — Interface-Erfüllung, kein Import), der **Use-Case-Port der
CLI ist inbound** (der driving Adapter treibt die Use-Case und konsumiert ihn). Die Gliederung
existiert dann im Baum, nicht im Kommentar.

**3. Die `direction:`-Dimension bleibt leer — neu bewertet nach dem gefeuerten Trigger.**
[ADR-0010](0010-hexagonal-arch-realisierung.md) Festlegung 1 hält sie leer *„als Entscheidung"*
und trägt den Trigger *„wenn das emittierte Skelett seine Ports teilt — dann bekommt die
`direction:`-Dimension etwas zu graden"*. Der Trigger **feuert mit dieser Entscheidung**: die
Ports teilen sich in `inbound`/`outbound`. Die Neubewertung fällt so aus: die Dimension bleibt
leer, weil das hexslice-Gate weiterhin **keine** `adapters→ports`-Kante emittiert
([ADR-0009](0009-hexslice-arch-realisierung.md) Festlegung 2 — *„Wir emittieren keine Kante auf
Vorrat"*, [ADR-0010](0010-hexagonal-arch-realisierung.md) Runde 4) — ohne Kante dorthin gibt es
keinen `port-direction-mismatch` zu graden. Die Gliederung ist strukturell (die Ordner-Namen
tragen die Semantik), nicht gegrade. **Der Umfang dieser ADR ist darum: die Ordner-Gliederung
kommt, die `direction:`-Kante bleibt leer** — und der Trigger bleibt stehen für den Fall, dass
eine Kante dorthin kommt (unten).

**4. Die Kanten-Menge bleibt.** Die fünf erlaubten Kanten aus
[ADR-0009](0009-hexslice-arch-realisierung.md) Festlegung 2 binden fort — verbatim, unverändert;
auch das Fehlen der `adapters→ports`-Kante und der Composition-Root-Status von `cmd/**` bleiben.
Die Bau-/Toolchain-Gerüstung bleibt arch-invariant
([ADR-0008](0008-arch-achse-emittiertes-skelett.md)).

**5. Die C++-Hälfte folgt derselben Achse.** `src/adapters/{driving,driven}/...` samt
Namespaces in den drei Quelldateien und der Ports-Gliederung — dieselbe Rollen-Zuordnung, dieselbe
Grenze: der Renderer-Output beider Sprachen ändert sich in einem Vorgang, nicht getrennt.

**6. Verhältnis zu [ADR-0009](0009-hexslice-arch-realisierung.md): Teil-Ablösung.** Die Form
steht im Kopf (*Supersedes (Teil)*); die zwei Gegenstände sind dort wörtlich benannt. Der
Index-Zusatz an der
[ADR-0009](0009-hexslice-arch-realisierung.md)-Zeile wird **im selben Commit wie der
Accept-Übergang** gesetzt (Folgepflicht 2) — nicht davor.

## Verglichene Alternativen

Regeln dieser Sektion: **mindestens drei Optionen mit Pro/Contra** — „nichts tun" ist eine davon
(Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR)).

| Option | Pro | Contra |
|---|---|---|
| **A — Ordner folgen den Rollen-Namen, Ports gegliedert (gewählt)** | ein Namensraum: die Ordner heißen wie die Rollen, die das Gate ihnen zuordnet — die Zuordnung liest dieselben Konstanten statt eigener Strings; die inbound/outbound-Semantik steht bei den Ports, wo sie liegt, statt bei den Adaptern, wo sie nur historisch lag; die Ports-Gliederung zieht aus dem Kommentar in den Baum | ein Umbau des Renderer-Outputs über beide Sprachen samt Tests und Gate-Config; ein Ziel, das aus dem alten Release gebootstrappt wurde, trägt die alten Ordner bis zum Re-Lauf |
| B — bei `inbound`/`outbound` bleiben | keine Änderung; der Bestand läuft | zwei Namensräume für dieselbe Familie: das Gate ordnet die Schichten als `driving`/`driven` zu, die Ordner heißen `inbound`/`outbound` — die Zuordnung hängt an einer Übersetzung, die jeder Lauf liest; die Ports-Gliederung bliebe Kommentar, nicht Baum |
| C — die Ports als eigenständige gegrade Schichten (`direction:` gesetzt) | die `direction:`-Dimension bekäme ihren Gegenstand; der inbound/outbound-Unterschied wäre gegrade | setzt die `adapters→ports`-Kante voraus, die
  [ADR-0009](0009-hexslice-arch-realisierung.md) bewusst **nicht** emittiert — *„Wir emittieren keine Kante auf Vorrat"*; ohne sie hat die Dimension nichts zu graden, und ein zweites Kanten-Set wäre genau die Verschmelzung zweier Layouts, die die Komponenten-Sicht ausschließt |
| D — nichts tun: die Zuordnung bleibt im Kommentar | keine Änderung; der Bestand läuft | die Ports-Gliederung ist nicht an der Stelle geprüft, an der die Ordner entstehen; der blockierte Fix-Slice bleibt stehen, und der Upstream-Nachzug des ADR-0009-Autors driftet gegen die Emission dieses Werkzeugs |

## Konsequenzen

- **Positiv:** Ein Namensraum für die Adapter-Familie — Ordner und Gate-Zuordnung lesen dieselben
  Konstanten; die Übersetzung entfällt, die sie heute braucht.
- **Positiv:** Die Ports-Semantik steht im Baum, nicht im Kommentar; die Zuordnung ist an der
  Stelle geprüft, an der die Ordner entstehen.
- **Negativ:** Das published Release `v0.2.1` emittiert die alten Ordner — wie geschnitten,
  unberührt ([ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 2); Ziele
  heilen über einen Re-Lauf mit der neuen Fassung (konvergente Emission), nicht über einen
  Re-Publish.
- **Negativ:** Die Umbau-Kaskade über beide Renderer samt Tests und Gate-Config ist der Preis —
  der Implementer trägt sie in einem Vorgang
  ([`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)).
- **Folgepflicht 1 — der Implementer setzt die Mechanik nach dieser Entscheidung.** Der
  blockierte Fix-Slice (`slice-adapter-und-ports-ordner-folgen-ihren-rollen-namen`, `open/`)
  liest diese Entscheidung als Constraint für die hexagonal-Achse; die hexslice-Achse ist ein
  eigener Vorgang im Planning-Lifecycle — sein Schnitt ist Planner-Arbeit, und seine Kennung
  löst dort auf.
- **Folgepflicht 2 — der Index-Zusatz an der
  [ADR-0009](0009-hexslice-arch-realisierung.md)-Zeile wird im selben Commit wie der
  Accept-Übergang gesetzt** (Form-Vorbild:
  [ADR-0032](0032-eingefrorene-referenz-folgt-ihrem-rumpf.md) Folgepflicht 2,
  [ADR-0055](0055-abgeschaffte-kennung-verlaesst-die-fitness-function-als-teil-abloesung.md)): die
  Zelle trägt den Umfang der Ablösung (die zwei Gegenstände der Festlegung 2) und die
  revidierende ADR.
- **Folgepflicht 3 — die Spec-Stellen ziehen mit dem Vollzug nach:** die `ARC-009`-Zelle der
  Komponenten-Sicht und die Prosa-Stelle über die Adapter-Ordner nennen die neuen Ordner und die
  Ports-Gliederung, sobald die Implementation sie legt — der Spec-Text beschreibt den Output des
  Generators und zieht mit ihm, nicht vor ihm. Wer diese ADR ändert, zieht von hier die
  betroffenen Spec-Stellen nach.
- **Folgepflicht 4 — die Tests tragen die Erwartungen mit:** die Renderer-Tests
  (`internal/gen/hexslice_test.go`, `internal/gen/cpp_test.go`) halten die neuen Ordner und die
  Ports-Gliederung fest, mit der Rot-Gegenprobe, die der blockierte Slice-Plan für seine Achsen
  bereits benennt — ein Skelett, das `inbound`-Adapter anlegt oder einen Port ohne
  inbound/outbound-Zuordnung legt, färbt rot.
- **Folgepflicht 5 — der Upstream-Nachzug ist derselben Entscheidung gekoppelt:** der Autor
  passt hexslice im Kurs an; driftet die Form, ist der Auslöser der nächsten Neubewertung
  (Trigger unten).

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| `make test` (Renderer-Tests) | **Die Ordner folgen den Rollen:** legt das hexslice-Skelett einen Adapter unter `inbound`/`outbound` an, färbt der Renderer-Test rot — die Namen kommen aus der Rollen-Zuordnung des Generators, kein zweiter Namensraum | `make test` |
| `make test` (Renderer-Tests) | **Die Ports tragen die Gliederung:** ein Port ohne `inbound`/`outbound`-Zuordnung färbt rot — die Zuordnung ist an der Stelle geprüft, an der die Ordner entstehen, nicht im Kommentar | `make test` |
| `make test` (Gate-Test) | **Die Config wandert mit:** der Arch-Gate-Glob und die Rollen-Zuordnung tragen die neuen Ordner; hält die Config am alten Glob, färbt der Gate-Test rot | `make test` |
| `make full-smoke` | **E2E am realen Ziel:** das `hexslice`-Skelett trägt die neuen Ordner, `make a-check` ist Exit 0 — die Schichten sind geprüft, wo sie liegen | `make full-smoke` |

## Re-Evaluierungs-Trigger

- **Wenn der Upstream-Nachzug des ADR-0009-Autors eine andere Form wählt** (die hexSlice-Referenz
  ist die kanonische Quelle, Tool-als-Quelle): die Ordner-Namen oder die Ports-Achse sind gegen
  die Referenz neu zu wägen, und der Abstand zwischen Kurs und Emission ist zu schließen oder
  zu benennen.
- **Wenn das hexslice-Skelett eine `adapters→ports`-Kante bekommt** — dann bekäme die
  `direction:`-Dimension etwas zu graden, und die Entscheidung in Festlegung 3 ist neu zu fassen
  (der ADR-0010-Trigger trägt denselben Moment).
- **Wenn die Rollen-Namen im Bestand sich ändern** (`internal/gen/arch.go`) — dann folgen die
  Ordner-Namen ihnen; die Zuordnung liest die Konstanten, und ein Drift zwischen Rolle und
  Ordner ist die Klasse, die diese Entscheidung schließt.
- **Wenn ein drittes hexslice-Layout hinzukommt** (ein zweiter Renderer oder eine zweite
  Plattform-Form), ist die Achse je Fassung neu zu belegen — die Festlegung 5 trägt die
  Zwei-Sprachen-Grenze.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-19 | **Proposed** | Architect-Lauf zur hexslice-Skeleton-Struktur, ausgelöst durch die Setzung des Auftraggebers (der ADR-0009-Autor) — die Ordner folgen ihren Rollen-Namen, die Ports tragen die Gliederung statt flach zu liegen. Die Teil-Ablösung von [ADR-0009](0009-hexslice-arch-realisierung.md) Festlegung 2 ist auf die zwei Gegenstände geschnitten; der blockierte Fix-Slice liest die Entscheidung als Constraint. Der Acceptance-Trigger steht unten |

**Acceptance-Trigger:** Diese Entscheidung wird `Accepted`, wenn eine Reviewer-Runde sie gegen
[ADR-0009](0009-hexslice-arch-realisierung.md),
[ADR-0010](0010-hexagonal-arch-realisierung.md) und
[ADR-0008](0008-arch-achse-emittiertes-skelett.md) auf Konsistenz geprüft hat und ihr Report
ohne blockierenden Befund in `docs/reviews/` liegt — Beleg nach
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md). Bis dahin ist sie ein
Architect-Verdikt und als solches das Übergabe-Artefakt, das der blockierte Fix-Slice als
Constraint liest.

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0060` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).