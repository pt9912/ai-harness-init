# ADR-0010: Hexagonal als zweite Layout-Realisierung der Architektur-Achse

**Status:** Accepted

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

**Genau drei Festlegungen.**

**Festlegung 1 — emittiert wird die gelebte Familien-Konvention, nicht das Gate-Gerüst.**
`--arch hexagonal` erzeugt

| Rolle | Verzeichnis | Schicht | `role:` in der Config |
|---|---|---|---|
| Kern (Use-Case **und** Domäne) | `internal/hexagon/core/**` | `core` | **`app`** — explizit, denn die Namens-Inferenz gäbe `domain` |
| Ports | `internal/hexagon/port/**` | `ports` | `port` — **importfrei** |
| getriebene Adapter | `internal/adapter/driven/**` | `driven` | `adapter` — explizit, der Name inferiert nichts |
| treibende Adapter | `internal/adapter/driving/**` | `driving` | `adapter` — explizit, der Name inferiert nichts |
| Verdrahtung + Einstiegspunkt | `cmd/**` | — | **Composition Root**, einziger befreiter Bereich |

Die emittierte `.a-check.yml` führt **vier** Kanten — `core→ports`, `driven→ports`, `driven→core`,
`driving→core` — und `composition_root: ["cmd/**"]`. Drei naheliegende Kanten fehlen **mit je
eigenem Grund**: `ports→core`, `driving→ports`, `driving→driven` (unten).

Begründung: ein Adopter soll ein Layout bekommen, das in dieser Werkzeug-Familie **real gebaut und
real geprüft** wird — nicht das Minimalbeispiel der Werkzeug-Doku. Die Kante `driven→core` ist Teil
der Festlegung, weil Adapter Domänentypen abbilden (im ersten Referenz-Repo real geführt, im Gerüst
nur auskommentiert); sie sieht wie ein Überschuss aus und braucht deshalb einen eigenen Wächter.

**Zu den Rollen** (ergänzt in Runde 4): Rollen sind nicht dekorativ, sie schalten **kategorische**
Regeln, die keine Kante aufhebt. `driven` und `driving` inferieren **keine** Rolle (die Inferenz
kennt nur `core`/`ports`/`adapters`/`application`/`app`) — ohne den expliziten Eintrag wären beide
Schichten bloß kanten-geprüft. Der Kern trägt bewusst `app` statt des inferierten `domain`: eine
`domain`-Schicht darf **keinen** Port importieren (`core-impurity`, kategorisch), der Kern könnte
seine getriebenen Ports also nicht aufrufen, und die Use-Case-Logik müsste in den **befreiten**
`cmd/**`-Bereich ausweichen — Strenge auf dem Papier, Stille in der Praxis. Mit `role: app` bleibt
die Use-Case in einer **geprüften** Schicht, in der `app-impurity` weiterhin jeden Adapter- und
Tech-Import verbietet. Verworfen: den Kern aufteilen (`model` = `domain` + `app` = `app`) wie das
zweite Referenz-Repo — das ist dort durch eine gewachsene Kern-Größe begründet und macht aus drei
Schichten fünf; für ein Skelett mit einer Use-Case trägt es nichts (Re-Evaluierungs-Trigger unten).

**Warum es keine Kante `ports→core` gibt** (Runde 4): mit **einer** Kern-Schicht wären `core→ports`
und `ports→core` zusammen ein **Import-Zyklus** — die Sprache selbst schließt das aus, nicht erst
das Gate. Es ist also eine echte Richtungswahl, und die beiden Referenzen wählen verschieden: das
zweite hält die Ports importfrei und lässt den Kern sie importieren; das erste hält den Kern rein
(`ports→core`) und orchestriert dafür in seiner **exemten** CLI. Der zweite Weg ist uns seit
Festlegung 1/Runde 3 verschlossen (die CLI ist eine geprüfte Schicht), also wählen wir den ersten:
**Ports sind importfrei**, der Kern importiert sie.

**Wo verdrahtet wird** (Runde 4, und die eine Stelle, an der wir der Familie nicht folgen):
**in `cmd/**`.** Dort entsteht der getriebene Adapter, wird in die Use-Case injiziert, und die
Use-Case wird an die treibende CLI übergeben. Gemessen an beiden Referenzen ist das **nicht** ihre
Form: beide konstruieren ihre getriebenen Adapter **in der CLI** (vier bzw. fünf Import-Zeilen; im
zweiten Repo importiert `cmd/**` keinen einzigen Adapter). Seit Runde 3 ist die CLI bei uns eine
`role: adapter`-Schicht, und ein Adapter, der einen anderen importiert, ist `lateral-adapter` —
**kategorisch und kanten-unabhängig**: die Regel greift vor allen Richtungs-Regeln, eine Kante
`driving→driven` würde sie **nicht** aufheben. Festlegung 1 übernimmt damit die **Pfade** der
Familie, nicht ihre **Verdrahtungsstelle**; das ist der konkrete Preis von Runde 3 und gehört
ausgesprochen, nicht impliziert.

**Warum es keine Kante `driving→ports` gibt** (Runde 4): die CLI bekommt die Use-Case, nicht den
Port — sie braucht ihn im emittierten Skelett nicht. Wir emittieren keine Kante auf Vorrat: greift
ein Adopter dort doch nach einem Port, meldet sich das Gate beim ersten Lauf, und er trägt eine
Zeile nach (Festlegung 3). Eine ungenutzte erlaubte Kante meldet sich nie.

**Nicht genutzt: die `direction:`-Dimension** (Runde 4). Das Gate kennt eine eigene, zweckgebaute
Achse `driving|driven` für Schichten; sie steuert **ausschließlich** `port-direction-mismatch` und
verlangt auf **beiden** Seiten einen gesetzten Wert. Sie bewertet damit, ob ein Adapter den *falschen*
Port anfasst — das setzt **geteilte** Ports (treibende und getriebene) voraus. Unser Skelett führt
**eine** `ports`-Schicht und gar keine Kante von `driving` dorthin; die Dimension hätte nichts zu
graden. Sie bleibt leer — als Entscheidung, nicht aus Versehen (Trigger unten).

**Zur treibenden Seite** (ergänzt in Runde 2, verschärft in Runde 3): Beide Referenz-Repos haben
eine, an **verschiedenen** Orten — `internal/cli` beim einen, `internal/adapter/driving/cli` beim
anderen —, und **beide behandeln sie als Composition Root**, also als prüffreien Bereich.

Wir übernehmen den **Ort** (`internal/adapter/driving/**`, weil *driving*/*driven* das
Ports-und-Adapter-Vokabular durchhält; `internal/cli` verworfen, weil es das Vokabular genau dort
verlässt, wo die Architektur ihren Namen hat) — aber **nicht die Prüffreiheit**. Bei uns ist
`driving` eine **Schicht**. Zwei Gründe:

1. **Runde 2 hat gezeigt, was die Prüffreiheit kostet:** deckt man nur `driving/cli` ab, fällt
   jeder weitere treibende Adapter (`driving/http`, `driving/grpc` …) unter **keinen** Glob und ist
   für das Gate unsichtbar. Deckt man `driving/**` als Composition Root ab, ist die ganze treibende
   Seite ungeprüft. Beides sind **stille** Zustände. Was die Strenge stattdessen kostet, steht oben
   unter *Wo verdrahtet wird* — sie ist bezahlt, nicht geschenkt.
2. **Wir kennen die Adopter nicht** — und genau deshalb ist die Wahl entscheidbar (siehe
   Festlegung 3): ein zu strenger Default meldet sich beim ersten Lauf und kostet eine Zeile in der
   adopter-eigenen Config; ein zu lascher meldet sich nie.

**Festlegung 2 — `hexagonal` und `hexslice` sind getrennte Layouts, nicht zwei Strenge-Grade.**
Sie teilen die Idee (Kern innen, Adapter außen), aber **nicht die Verzeichnisnamen**: `core` gegen
`domain`, `port` gegen `application/**/ports`, `adapter/driven` gegen `adapters/outbound`. Ein
gemeinsames Layout mit zwei Kanten-Mengen wäre nicht sparsamer, sondern **unbewachbar**: die
Regeln, die HexSlice ausmachen (Slice-Lokalität, laterale Trennung), hängen an literalen
Verzeichnis-Präfixen. Konsequenz: der Generator führt zwei Rollen-Sätze, und ein Test hält die
**Disjunktheit der Verzeichnisnamen** fest.

**Festlegung 3 — bei Unkenntnis der Adopter ist der Default fail-closed.**
Die emittierte `.a-check.yml` ist ein **Startpunkt**, kein Vertrag: sie ist *skip-if-present*, der
Adopter darf sie ändern. Damit ist unsere Wahl ein Default, und Defaults für **unbekannte** Nutzer
entscheidet man nicht nach vermuteter Präferenz, sondern nach dem **Fehlerbild**:

| Default | wenn falsch | merkt es der Adopter? | Korrektur |
|---|---|---|---|
| zu streng | Gate wird rot auf etwas Legitimes | **sofort**, beim ersten Lauf | eine Glob-Zeile |
| zu lasch | Bereich bleibt ungeprüft | **nie** | — |

**Laut falsch schlägt leise falsch.** Diese Regel gilt über diese ADR hinaus für jeden emittierten
Prüfbereich; sie ist dieselbe, nach der der Command-Guard einen gebackenen Boden trägt und der
Mutations-Sensor im Zweifel beide Stufen fährt. Für die Referenz-Repos heißt das: **die Familie ist
Referenz für das Layout, nicht für die Prüfschärfe.**

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
| E — eine dritte Achse (`--flavour`) für die Platzierung der treibenden Seite | jede beobachtete Variante wäre abbildbar, ohne die Arch-Achse mit Werten zu füllen | die Achse trägt **zwei** weitere Voll-E2E-Kombinationen (je Sprache eine), dazu je Kombination Mutations-Fälle und einen Zahn-Block; belegt sind heute vier Kombinationen in `harness/tools/full-smoke.sh`, und der Zuwachs von vier auf sechs gehört **dieser** ADR, nicht der Achse. *(Runde 4: die Runde-3-Fassung nannte hier „gemessen" samt Sekunden-Zahlen ohne auffindbaren Fundort und rechnete beide Zuwächse der Achse zu — beides zurückgenommen.)* Der Anlass wäre **eine** Pfad-Abweichung in zwei Repos derselben Familie, die ein Adopter mit einem `git mv` und einer Glob-Zeile selbst löst. Verworfen, bis die Achse **mehr als eine Frage** beantwortet |

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
- **Negativ, und bewusst in Kauf genommen:** wir prüfen die treibende Seite **strenger als beide
  Referenzen**. Dort ist sie Composition Root, bei uns eine Schicht mit eigenen Kanten. Ein Adopter,
  der seine Referenz danebenlegt, sieht eine Abweichung und muss sie einordnen können — deshalb
  steht sie in der emittierten Config und in der Nutzer-Doku (Folgepflichten 4 und 5). Wer die
  Prüffreiheit der Referenzen will, trägt `internal/adapter/driving/**` in seinen
  `composition_root` ein: **eine Zeile**, in seiner eigenen, nie überschriebenen Datei.
  *(Dieser Absatz ersetzt die Runde-2-Fassung, die das Gegenteil festlegte — die Begründung dort
  ist mit Festlegung 3 hinfällig geworden und wird nicht stehengelassen.)*
- **Negativ, konkret (Runde 4):** die Strenge verschiebt die **Verdrahtung** aus der CLI nach
  `cmd/**`. Das emittierte Skelett sieht damit an einer Stelle anders aus als die Repos, auf die
  sich Festlegung 1 beruft — und `cmd/**` ist der befreite Bereich, die Verdrahtung also
  ungeprüft. Das ist vertretbar, solange dort **nur** Konstruktion steht: Konstruktion ist die
  Aufgabe des Composition Root, Orchestrierung nicht. Genau deshalb trägt der Kern `role: app` und
  behält die Use-Case (siehe Festlegung 1) — sonst wanderte mit der Verdrahtung auch die Logik in
  den ungeprüften Bereich.
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
- **Folgepflicht 5:** die Nutzer-Doku benennt, dass `hexagonal` die treibende Seite **strenger**
  prüft als die Referenz-Repos, und wie man sie auf deren Niveau lockert. Ohne das liest sich die
  Abweichung als Fehler statt als Entscheidung.
- **Folgepflicht 6:** Festlegung 3 gilt über diese ADR hinaus, steht aber in einer Layout-ADR. Sie
  bekommt einen **Zeiger** aus dem Adaptions-Block der Konventionen, damit sie findet, wer nach der
  Default-Regel für emittierte Prüfbereiche sucht — nicht nach dem hexagonalen Go-Layout.
- **Folgepflicht 7:** der Voll-Smoke bekommt einen **Zahn für `lateral-adapter`**: ein Import von
  `driving/**` nach `driven/**` im emittierten Repo muss rot werden. Ohne ihn ist die tragende
  Regel dieser Fassung nur behauptet — und sie ist keine Kante, also fängt sie kein
  Kanten-Wächter.

## Fitness Function (falls maschinell prüfbar)

<!--
Wenn die Entscheidung sich in einer prüfbaren Eigenschaft des Codes
niederschlägt: hier die konkrete Regel benennen. Beispiel:
"depguard verbietet Import von internal/runtime aus internal/service."
-->

| Tooling | Regel | Make-Target |
|---|---|---|
| a-check (im Ziel) | Ein Import von `core` nach `driven` färbt das Gate rot — als **`app-impurity`** (die Kern-Schicht trägt `role: app` und darf keinen Adapter sehen), **mit** Regel-Namen im Befund, nicht nur Exit ≠ 0 | `make a-check-<modul>` im emittierten Repo, gefahren im `make full-smoke` |
| Go-Test (hier) | Jede schichten-tragende (Sprache, Architektur) hat eine Arch-Gate-Config — die Erkennung ist **strukturell**, nicht namensbasiert | `make test` (`TestArchGateConfig_CoversEveryLayeredCombo`) |
| Go-Test (hier) | Die Verzeichnisnamen von `hexagonal` und `hexslice` sind **disjunkt**; die Namen werden aus den Renderern abgeleitet, nicht aus einer Liste | `make test` |
| `make mutate` | Die Kante `driven→core` wird entfernt → der zugehörige Wächter muss rot werden | `make mutate` |
| a-check (im Ziel) | Ein Import von `driving` nach `driven` färbt das Gate rot — als **`lateral-adapter`** (zwei `role: adapter`-Schichten), nicht wegen einer fehlenden Kante | `make a-check-<modul>`, im `make full-smoke` |
| Go-Test (hier) | Die emittierte Kanten-Menge ist **zyklenfrei** — sonst wäre das Skelett in der Zielsprache nicht übersetzbar (der Grund, aus dem `ports→core` fehlt) | `make test` |

## Re-Evaluierungs-Trigger

- Wenn das Arch-Gate seine Standardform **erzwingt** (statt sie vorzuschlagen) — dann kippt die
  Annahme, auf der Festlegung 1 steht.
- Wenn ein Repo der Familie das Layout ändert — die Referenz ist die gelebte Praxis, nicht ein
  eingefrorener Snapshot. **Ehrlich eingeordnet:** diesen Trigger feuert **kein Sensor**. Die
  Referenz-Repos liegen außerhalb dieses Repos; kein Gate und kein Nachtlauf sieht sie. Er lebt
  rein im *inferential-feedforward*-Quadranten und wirkt nur, wenn ihn jemand liest.
- Wenn das emittierte Skelett seine Ports **teilt** (treibende neben getriebenen) — dann bekommt die
  `direction:`-Dimension etwas zu graden, und ihr Weglassen ist neu zu bewerten.
- Wenn der emittierte Kern über eine Use-Case hinauswächst — dann ist die verworfene Teilung
  (`model` = `domain` neben `app`) erneut zu prüfen, weil `role: app` auf dem ganzen Kern die
  Domänen-Reinheit nicht mehr abbildet.
- Wenn eine **vierte** Architektur hinzukommt und sich zeigt, dass drei getrennte Rollen-Sätze den
  Kompositions-Kern verbiegen — dann ist Option B erneut zu prüfen, diesmal mit Messung statt
  Vermutung.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-07-27 | Proposed | slice-058 §3a (Plan-Review F-2 verlangte die Entscheidung) — auf die Slice-**ID** verwiesen, nicht auf den Pfad: der wandert durch die Lifecycle-Ordner, diese ADR darf ihm nach der Annahme nicht mehr folgen |
| 2026-07-27 | Überarbeitet (Runde 2), weiter Proposed | Proposed-Review `docs/reviews/2026-07-27-adr-0010-proposed-review.md`: F-1 (treibende Seite fehlte, Familie uneinheitlich) und F-2 (`composition_root` zu eng) aufgelöst, F-4 (Trigger ohne Sensor) eingeordnet, F-5 als Folgepflicht 4 ergänzt |
| 2026-07-27 | Überarbeitet (Runde 3), weiter Proposed | Proposed-Review Runde 2 `docs/reviews/2026-07-27-adr-0010-proposed-review-runde-2.md`: N-1 (ungedeckter Bereich unter `driving/`) als **Schicht** aufgelöst statt als Ausnahme; daraus **Festlegung 3** (fail-closed bei unbekannten Adoptern) und die Rücknahme des Runde-2-Absatzes zur „Familien-Treue bei der Prüfschärfe"; N-2 als Folgepflicht 5; Alternative E (`--flavour`-Achse) ergänzt (die dort genannten Kosten-Zahlen nimmt Runde 4 zurück) |
| 2026-07-27 | Überarbeitet (Runde 4), weiter Proposed | Proposed-Review Runde 3 `docs/reviews/2026-07-27-adr-0010-proposed-review-runde-3.md`: N-1 (Verdrahtungsort) und N-2 (Rolle des Kerns) in Festlegung 1 entschieden — Verdrahtung in `cmd/**`, Kern `role: app`, Ports importfrei, `ports→core` als Zyklus ausgeschlossen; N-3 (`direction:` nicht genutzt) und N-5 (Wirkmechanismus `lateral-adapter`) benannt; N-4 (unbelegte Sekunden-Zahlen, doppelt gezählter Zuwachs) zurückgenommen; N-6 als Folgepflicht 6, dazu Folgepflicht 7 (Zahn für `lateral-adapter`) |
| 2026-07-27 | **Accepted** | Vier Proposed-Runden (Reviews `docs/reviews/2026-07-27-adr-0010-proposed-review.md`, `…-runde-2.md`, `…-runde-3.md`), alle blockierenden Befunde entschieden; Annahme durch den Auftraggeber. Ab hier **immutabel** ([`AGENTS.md`](../../../AGENTS.md) §3.4) — spätere Schärfungen als neue ADR mit *Supersedes* |

<!--
Nach Accepted: NICHT mehr inhaltlich überschreiben (Hard Rule aus
c-hsm-doc, siehe Kurs Modul 4). Spätere Schärfungen als neue ADR mit
"Supersedes ADR-NNNN" anlegen.
-->
