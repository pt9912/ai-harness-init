# ADR-0060: Die Adapter- und Ports-Ordner des hexslice-Skeletts folgen ihren Rollen-Namen — `driving`/`driven`, die Ports gegliedert

**Status:** Proposed

**Datum:** 2026-09-19

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0009](0009-hexslice-arch-realisierung.md) (**Accepted** — der Gegenstand der Teil-Ablösung:
seine Festlegung 2 trägt die Ordner-Namen, die flachen Ports und die Kanten-Menge; die
Schichten-Tragung, die inward-only-Logik und die Gate-Mechanik binden fort — §Supersedes (Teil)
zählt den Gegenstand wörtlich auf. **Der Autor dieses ADR-0009 ist der Auftraggeber** und hat die
Richtung gesetzt — §Kontext),
[ADR-0008](0008-arch-achse-emittiertes-skelett.md) (**Accepted** — die Arch-Achse und ihre
Mechanik: die Bau-/Toolchain-Gerüstung bleibt arch-invariant, `hexslice` ersetzt nur den
Code-Teil),
[ADR-0010](0010-hexagonal-arch-realisierung.md) (**Accepted** — Festlegung 1 hält die
`direction:`-Dimension leer *„als Entscheidung"*; ihr Re-Evaluierungs-Trigger *„wenn das Skelett
seine Ports teilt"* feuert mit dieser Entscheidung — die Neubewertung steht in Festlegung 3, und
sie fällt anders als die erste Fassung: die Adapter-Schichten tragen die Richtung),
[ADR-0007](0007-bootstrap-phasen.md) (**Accepted** — die konvergente Emission: ein Re-Lauf
schreibt die Skelett-Ordner kanonisch neu; die Heilung eines Ziels ist ein Re-Lauf),
[ADR-0005](0005-ziel-repo-distribution.md) (**Accepted** — Tool-als-Quelle: die hexSlice-Referenz
ist die kanonische Quelle des Go-Renderers; die gemessene Referenz-Form steht in §Kontext),
[`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) (das
Arch-Gate-Config wandert mit — der Glob, die Kanten und die Rollen-Zuordnungen sind der Punkt, an
dem die Ordner-Namen in die geprüfte Schicht wirken),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (das
hexslice-Layout trägt reale Schichten; ein nicht-leerer Prüfbereich bleibt),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert)

**Schärft:** [`ARC-009`](../../../spec/architecture.md#1-komponenten-übersicht) — die hexslice-Skelett-Struktur
ist hier verbindlich gemacht: die Adapter- und Ports-Ordner des Generator-Outputs **und die
Kanten-Menge, die das emittierte Gate deklariert**. Die Spec-Stellen, die den Ist-Output
beschreiben (die `ARC-009`-Zelle der Komponenten-Sicht und die Prosa über die Arch-Achse mit
*„`adapters` (`driving`/`driven`)"*), ziehen mit dem Implementer-Vollzug nach — **Folgepflicht 3**;
der Spec-Text beschreibt den Output, den der Generator nach dem Vollzug legt.

**Supersedes (Teil):**
[ADR-0009](0009-hexslice-arch-realisierung.md) Festlegung 2 — dort genau **drei Gegenstände**:
(i) die Adapter-Ordner-Namen — *„`internal/adapters/inbound/<typ>/<area>/` Use-Case-Entrypoint
(CLI · API · Messaging)"* und *„`internal/adapters/outbound/<typ>/<area>/` Port-Implementierung
(Persistenz · Notify · …)"* werden zu `driving`/`driven`; (ii) die **flachen** `ports`-Ordner der
drei Ebenen bekommen die `inbound`/`outbound`-Gliederung; (iii) die **fünf-Kanten-Menge verbatim**
wird durch das Referenz-Kanten-Set ersetzt — `driving_adapters→ports` kommt, die `adapters→app`-
Kante fällt in der Teilung (Festlegung 4). Alles andere jener Festlegung bindet unverändert fort:
die Schichten-Tragung (`domain`, `application` als vertikale Use-Case-Slices mit
`command`/`query`/`handler`/`validator`/`result`), die **inward-only-Logik**, der
Composition-Root-Status von `cmd/**`, und die arch-invariante Bau-Gerüstung. Festlegungen 1
(Achsen-Wert `hexslice`), 3 (a-check-Pin + `.a-check.yml`-Schema) und die C++-Toolchain-Kette
binden unverändert fort. Diese ADR ändert, **wie die Ordner heißen, wie die Ports liegen und
welche Kanten das emittierte Gate deklariert** — nicht, welche Schichten geprüft werden.

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
(`slice-adapter-und-ports-ordner-folgen-ihren-rollen-namen`), dessen §4-Grund und §6-Übergabe in
der Plandatei stehen.

### Die Konkurrenz und ihre Auflösung — die kanonische Referenz, Ende-zu-Ende gemessen

Die erste Fassung dieser Entscheidung trug zwei Festlegungen, die um dieselbe Struktur
konkurrierten: Festlegung 2 materialisierte den CLI-Use-Case-Port als inbound
(„Die Gliederung existiert dann im Baum"), Festlegung 4 band die fünf Kanten aus
[ADR-0009](0009-hexslice-arch-realisierung.md) verbatim fort — `adapters→ports` abwesend,
`adapters→app` erlaubt. Ein materialisierter inbound-Port verlangt genau die fehlende Kante.
Die Reviewer-Runde 1 zum blockierten Fix-Slice
(`docs/reviews/2026-09-19-slice-adapter-und-ports-ordner-folgen-ihren-rollen-namen-runde-1.md`,
F-1, merge-blockierend am Accept-Übergang dieses ADR) hat den Konflikt gemessen und die
kanonische Referenz als Beleg benannt; die Messung steht hier mit eigenen Kommandos
(`lab/examples/go` im Referenz-Repo `hexslice-architecture`, der ADR-0009-Quelle — fremdes Repo,
nur gelesen):

- **Das Kanten-Set der Referenz** (`lab/examples/go/.a-check.yml`, Zeilen 55–59): `app→domain`,
  `app→ports`, `ports→domain`, **`driving_adapters→ports`** (*„the CLI speaks the slices' inbound
  ports"*), **`driven_adapters→domain`** (*„adapters map to/from domain objects"*).
- **`driving_adapters→app` ist bewusst nicht deklariert** (Zeilen 65–67): *„The driving adapter
  reaches the use cases exclusively through their inbound ports. Add the edge in the same commit
  as an adapter that imports a slice directly."*
- **`driven_adapters→ports` bleibt ohne Kante** (Zeilen 60–63): driven Adapter *implementieren*
  die outbound Ports — über Go-Interface-Erfüllung, strukturell, kein Import — und brauchen
  darum keine Kante zu `ports`; die Verdrahtung geschieht im Composition Root.
- **Der treibende Adapter importiert ausschließlich `ports/inbound`** —
  `grep -rn 'ports/inbound' <referenz>/internal/adapters/driving` nennt die Import-Zeilen des
  CLI-Adapters (`:15`, `:16`), und keinen Import der Use-Case-Slices. **Der Port trägt die
  request/result-Typen**, die der Adapter baut und liest.
- **Der Ports-Baum trägt die Gliederung je Ebene**: `order/ports/outbound/` (business-area),
  `createorder/ports/{inbound,outbound}/`, `cancelorder/ports/inbound/` (use-case-lokal) —
  gemessen über den Baum der Referenz.

Die erste Fassung dieser Entscheidung hatte die Gegenrichtung gesetzt (beide Ports outbound,
CLI importiert die Use-Case direkt); der emittierte Stand des Implementer-Diffs ist zu ihr
und zu [ADR-0009](0009-hexslice-arch-realisierung.md) verbatim konsistent — die Materialisierung
des inbound-Ports ist als Übergabe deklariert, nicht still. Die Korrektur vor dem Accept ist
legal; sie zieht die Kanten-Menge der Referenz nach.

### Die Rollen sind im Bestand — und ihre Bindung ist Ziel, nicht Bestand

Die Rollen-Namen existieren bereits (`grep -n 'hexagonal-driving\|hexagonal-driven'
internal/gen/arch.go` → `:50`/`:54`); die Ordner folgen ihnen. **Gelesen, nicht gebunden** — die
Ordner-Segmente und Layer-Namen stehen heute als Literale, und ein Test, der sie an die
Konstanten bindet, existiert noch nicht (gemessen in der Runde 1, F-3); die Bindung ist
Folgepflicht 6, nicht Bestand.

## Entscheidung

**Die Adapter-Ordner des hexslice-Skeletts tragen ihre Rollen-Namen — `driving`/`driven` statt
`inbound`/`outbound` —, die Ports tragen die `inbound`/`outbound`-Gliederung mit
materialisiertem inbound-Port, und das emittierte Gate deklariert das Referenz-Kanten-Set.**
Sechs Festlegungen.

**1. Die Adapter-Ordner.** Go: `internal/adapters/{driving,driven}/<typ>/<area>/`; C++:
`src/adapters/{driving,driven}/<typ>/<area>/`. `driving` trägt den Use-Case-Entrypoint (CLI ·
API · Messaging), `driven` die Port-Implementierung (Persistenz · Notify · …) — dieselben
Inhalte, dieselbe `<typ>/<area>`-Tiefe, neue Namen aus der Rollen-Zuordnung des Generators. Der
Arch-Gate-Glob und die Rollen-Zuordnung wandern mit (der Punkt, an dem der Fix in die geprüfte
Schicht wirkt — [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)).

**2. Die Ports-Achse mit materialisiertem inbound-Port.** Die flachen `ports`-Ordner bekommen
`ports/{inbound,outbound}/` — je Ebene (use-case-lokal, business-area, application-weit), nach
derselben Rollen-Zuordnung: der **Repository-Port ist outbound** (er wird von einem driven
Adapter erfüllt), der **Use-Case-Port der CLI ist inbound — und er liegt im Baum**. Der
treibende Adapter **importiert den inbound-Port und nicht die Slices**: der Port trägt die
request/result-Typen, die der Adapter baut und liest — die Referenz-Form (gemessen in §Kontext).
Der Skeleton bekommt den inbound-Port-File als Bestandteil; ein Bootstrap nach dieser
Entscheidung legt beide Hälften an.

**3. Die `direction:`-Dimension: die Adapter-Hälfte wird gesetzt, das Grading bleibt inert.**
[ADR-0010](0010-hexagonal-arch-realisierung.md) Festlegung 1 hielt sie leer, und ihr Trigger
feuert mit der Ports-Teilung. **Die Neubewertung misst die Referenz-Form:** die
Adapter-Schichten tragen `direction: driving`/`direction: driven` — die Hälfte, die ausdrückbar
ist; die **Ports-Schicht kann keine Richtung tragen**, weil ihr Slice beide Seiten hält
(inbound und outbound), und der Port-Locality-Scoping-Grund der Referenz hält das fest: die
Port-Globs enden **bewusst am `ports`-Segment, nicht am Richtungs-Ordner** — sonst schob der
Scoping-Strich die letzte Ebene ab und `port-locality` würde still inert. Darum bleibt
`port-direction-mismatch` für dieses Skelett **inert — opt-in**, und die Adapter-Richtungen
werden enforceable in dem Moment, in dem eine Ports-Schicht ihre Richtung tragen kann. Die
Kante `driving_adapters→ports` ist damit **deklariert und nicht gegrade** — die Semantik steht
in den Ordner-Namen, das Grading opt-in.

**4. Das Referenz-Kanten-Set.** Das emittierte Go-Gate deklariert fünf Kanten in der
Referenz-Form: `app→domain`, `app→ports`, `ports→domain`, `driving_adapters→ports`,
`driven_adapters→domain`. **`driving_adapters→app` ist bewusst nicht deklariert** — der
treibende Adapter erreicht die Use-Cases ausschließlich über ihre inbound-Ports; die Kante
kommt im selben Commit wie ein Adapter, der einen Slice direkt importiert (die Referenz-Formel).
**`driven_adapters→ports` bleibt ohne Kante** — Interface-Erfüllung, strukturell, kein Import;
die Verdrahtung geschieht im Composition Root. **Die Kanten-Menge ist sprach-abhängig:** die
C++-Fassung trägt die Vererbungs-Kante `driven_adapters→ports` (der Adapter bindet den
Port-Header ein — dieselbe Sprach-Abhängigkeit, die die Komponenten-Sicht trägt); die Layer-Namen
der C++-Config folgen derselben Form. Die Adapter-Schicht ist in **zwei** Schichten geteilt
(`driving_adapters`, `driven_adapters`) — die ADR-0009-Form mit der einen `adapters`-Schicht
fällt mit der Kanten-Teilung.

**5. Die C++-Hälfte folgt derselben Achse.** `src/adapters/{driving,driven}/...` samt
Namespaces in den drei Quelldateien und der Ports-Gliederung — dieselbe Rollen-Zuordnung, dieselbe
Grenze: der Renderer-Output beider Sprachen ändert sich in einem Vorgang, nicht getrennt.

**6. Verhältnis zu [ADR-0009](0009-hexslice-arch-realisierung.md): Teil-Ablösung.** Die Form
steht im Kopf (*Supersedes (Teil)*); die drei Gegenstände sind dort wörtlich benannt. Der
Index-Zusatz an der
[ADR-0009](0009-hexslice-arch-realisierung.md)-Zeile wird **im selben Commit wie der
Accept-Übergang** gesetzt (Folgepflicht 2) — nicht davor.

## Verglichene Alternativen

Regeln dieser Sektion: **mindestens drei Optionen mit Pro/Contra** — „nichts tun" ist eine davon
(Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR)).

| Option | Pro | Contra |
|---|---|---|
| **A — Ordner folgen den Rollen-Namen, Ports gegliedert mit materialisiertem inbound-Port, Referenz-Kanten-Set (gewählt)** | die gemessene Referenz-Form: der treibende Adapter konsumiert den Port, den der Kern exponiert — keine Use-Case-Importe, keine Kante auf Vorrat; ein Namensraum: Ordner und Gate-Zuordnung lesen dieselben Konstanten; die Kanten-Menge trägt die Port-Kante, die die Materialisierung braucht | ein Umbau des Renderer-Outputs über beide Sprachen samt Tests und Gate-Config; ein Ziel, das aus dem alten Release gebootstrappt wurde, trägt die alten Ordner bis zum Re-Lauf; die `adapters→app`-Kante fällt — ein Adopter, der einen Slice direkt importieren will, trägt sie in demselben Commit nach |
| B — inbound-Port materialisieren, Kanten-Menge von ADR-0009 verbatim fortbinden | die Port-Datei existiert im Baum | unerfüllbar — genau die Konkurrenz, die F-1 mißt: ein materialisierter inbound-Port verlangt die fehlende Kante; das Gate meldete `wrong-direction` am ersten echten Import, und die Doku verspräche einen Import, der vom Gate verworfen wird |
| C — die Ports als eigenständige gegrade Schichten (`direction:` auf beiden Seiten) | der `port-direction-mismatch` wäre enforced | die Ports-Schicht kann **keine** Richtung tragen, weil ihr Slice beide Seiten hält — der Port-Locality-Scoping-Grund der Referenz (der Glob endet am `ports`-Segment; sonst strippt der Scoping-Strich die Slice-Ebene und die Regel geht still inert, gegen einen echten Cross-Slice-Import gemessen); die Referenz trägt genau die Adapter-Hälfte als ausdrückbar |
| D — bei `inbound`/`outbound` bleiben, Ports flach | keine Änderung; der Bestand läuft | zwei Namensräume für dieselbe Familie; die Ports-Semantik bliebe Kommentar; der blockierte Fix-Slice bliebe stehen, und der Upstream-Nachzug des ADR-0009-Autors driftet gegen die Emission |

## Konsequenzen

- **Positiv:** Ein Namensraum für die Adapter-Familie — Ordner und Gate-Zuordnung lesen dieselben
  Konstanten; die Übersetzung entfällt, die sie heute braucht.
- **Positiv:** Die treibende Seite konsumiert die Ports, die der Kern exponiert — die
  Use-Case-Importe entfallen, und die Kante, die der Import braucht, ist deklariert. Die
  Doku-Stellen (Spec, Handbuch), die die volle Gliederung beschreiben, sind mit der
  Materialisierung wahr.
- **Negativ:** Das published Release `v0.2.1` emittiert die alten Ordner und den alten
  Kanten-Set — wie geschnitten, unberührt; Ziele heilen über einen Re-Lauf mit der neuen
  Fassung, nicht über einen Re-Publish.
- **Negativ:** Die Umbau-Kaskade über beide Renderer samt Tests, Gate-Config und dem
  inbound-Port-File ist der Preis — der Implementer trägt sie in einem Vorgang.
- **Negativ:** Die `port-direction-mismatch`-Regel bleibt inert — die Adapter-Richtung ist die
  ausdrückbare Hälfte; das Grading wird erst enforceable, wenn eine Ports-Schicht ihre Richtung
  tragen kann (benannt, mit der Bedingung, nicht verhindert).
- **Folgepflicht 1 — der Implementer setzt die Mechanik nach dieser Entscheidung.** Der
  blockierte Fix-Slice liest diese Entscheidung als Constraint für die hexagonal-Achse; die
  hexslice-Achse ist ein eigener Vorgang im Planning-Lifecycle — sein Schnitt ist
  Planner-Arbeit, und seine Kennung löst dort auf. Dazu der inbound-Port-File: der
  Use-Case-Entrypoint der CLI importiert den Port, nicht die Slices (Festlegung 2).
- **Folgepflicht 2 — der Index-Zusatz an der
  [ADR-0009](0009-hexslice-arch-realisierung.md)-Zeile wird im selben Commit wie der
  Accept-Übergang gesetzt** (Form-Vorbild:
  [ADR-0032](0032-eingefrorene-referenz-folgt-ihrem-rumpf.md) Folgepflicht 2,
  [ADR-0055](0055-abgeschaffte-kennung-verlaesst-die-fitness-function-als-teil-abloesung.md)): die
  Zelle trägt den Umfang der Ablösung (die drei Gegenstände der Festlegung 2) und die
  revidierende ADR.
- **Folgepflicht 3 — die Spec-Stellen ziehen mit dem Vollzug nach:** die `ARC-009`-Zelle der
  Komponenten-Sicht und die Prosa-Stelle über die Adapter-Ordner und die Kanten-Menge nennen die
  neuen Ordner, die Ports-Gliederung und die Port-Kante, sobald die Implementation sie legt —
  der Spec-Text beschreibt den Output des Generators und zieht mit ihm, nicht vor ihm.
- **Folgepflicht 4 — die Tests tragen die Erwartungen mit:** die Renderer-Tests halten die
  neuen Ordner, die Ports-Gliederung und den materialisierten inbound-Port fest, mit der
  Rot-Gegenprobe, die der Slice-Plan für seine Achsen bereits benennt — ein Skelett, das
  `inbound`-Adapter anlegt, einen Port ohne Gliederung legt oder den inbound-Port ohne die
  Port-Kante importiert, färbt rot.
- **Folgepflicht 5 — der Upstream-Nachzug ist derselben Entscheidung gekoppelt:** der Autor
  passt hexslice im Kurs an; driftet die Form, ist der Auslöser der nächsten Neubewertung
  (Trigger unten).

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| `make test` (Renderer-Tests) | **Die Ordner folgen den Rollen:** legt das hexslice-Skelett einen Adapter unter `inbound`/`outbound` an, färbt der Renderer-Test rot — die Namen kommen aus der Rollen-Zuordnung des Generators | `make test` |
| `make test` (Renderer-Tests) | **Die Ports tragen die Gliederung, und der inbound-Port liegt:** ein Port ohne `inbound`/`outbound`-Zuordnung färbt rot; der Skelett trägt den inbound-Port-File, den der treibende Adapter importiert | `make test` |
| `make test` (Gate-Test) | **Die Config trägt das Referenz-Kanten-Set:** `driving_adapters→ports` deklariert, `driving_adapters→app` abwesend; hält die Config die alte Kante oder läßt die Port-Kante fallen, färbt der Gate-Test rot | `make test` |
| `make test` (Gate-Test) | **Die Ordner-Segmente sind an die Rollen-Konstanten gebunden** — ein Test hält die Ordner-Namen der Skelett-Erzeugung gegen die `arch.go`-Konstanten; driftet einer, färben beide rot (die Bindung, die der Kontext zusagt, und die Runde 1 (F-3) als fehlend mißt) | `make test` |
| `make full-smoke` | **E2E am realen Ziel:** das `hexslice`-Skelett trägt die neuen Ordner, den materialisierten inbound-Port und das Referenz-Kanten-Set; `make a-check` ist Exit 0 | `make full-smoke` |

## Re-Evaluierungs-Trigger

- **Wenn der Upstream-Nachzug des ADR-0009-Autors eine andere Form wählt** (die hexSlice-Referenz
  ist die kanonische Quelle, Tool-als-Quelle): die Ordner-Namen, die Ports-Achse oder die
  Kanten-Menge sind gegen die Referenz neu zu wägen, und der Abstand zwischen Kurs und Emission
  ist zu schließen oder zu benennen.
- **Wenn das hexslice-Gate die `port-direction-mismatch`-Grading einschaltet** — der Moment, in
  dem eine Ports-Schicht ihre Richtung tragen kann (ein single-direction Slice, oder der
  a-check scopet das Richtungs-Segment weg): dann wird die Adapter-Hälfte aus Festlegung 3
  enforceable, und die Inert-Entscheidung ist neu zu fassen.
- **Wenn die `adapters→app`-Kante gebraucht wird** — ein Adapter importiert einen Slice direkt:
  sie kommt **im selben Commit** (die Referenz-Formel), und der Abstand zur Referenz-Form ist neu
  zu benennen.
- **Wenn die Rollen-Namen im Bestand sich ändern** (`internal/gen/arch.go`) — dann folgen die
  Ordner-Namen ihnen; die Bindung trägt der Test aus der Fitness-Tabelle.
- **Wenn ein drittes hexslice-Layout hinzukommt** (ein zweiter Renderer oder eine zweite
  Plattform-Form), ist die Achse je Fassung neu zu belegen — die Festlegung 5 trägt die
  Zwei-Sprachen-Grenze.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-19 | **Proposed** | Architect-Lauf zur hexslice-Skeleton-Struktur, ausgelöst durch die Setzung des Auftraggebers (der ADR-0009-Autor) — die Ordner folgen ihren Rollen-Namen, die Ports tragen die Gliederung statt flach zu liegen. Die Teil-Ablösung von [ADR-0009](0009-hexslice-arch-realisierung.md) Festlegung 2 ist auf die zwei Gegenstände geschnitten |
| 2026-09-19 | **Überarbeitet, weiter Proposed** | Reviewer-Runde 1 zum blockierten Fix-Slice, Befund F-1 (HIGH, merge-blockierend am Accept-Übergang): Festlegung 2 (inbound materialisiert) und Festlegung 4 (fünf Kanten verbatim) konkurrierten, und die kanonische Referenz löst den Konflikt in der Gegenrichtung. Ende-zu-Ende gemessen (`lab/examples/go`): das Kanten-Set, die abwesende `driving_adapters→app`-Kante, der Port-Import des treibenden Adapters, die Ports-Gliederung und die inert bleibende `direction:`-Hälfte. Festlegungen 2, 3 und 4 sind gegen die Referenz neu geschnitten; der Supersedes-Gegenstand trägt die Kanten-Menge als dritten Gegenstand. Der Accept-Übergang geht gegen einen neuen Review-Lauf |

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