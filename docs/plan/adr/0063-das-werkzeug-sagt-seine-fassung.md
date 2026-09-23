# ADR-0063: Das Werkzeug sagt seine Fassung — die Fassung reist per `ldflags` aus dem Tag am Release-Bau, der Fehlt-Fall ist laut

**Status:** Proposed

**Datum:** 2026-09-23

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) (**Accepted** — ihre
Festlegung 2 verworfen die Fassungs-Fläche; ihr Re-Evaluierungs-Trigger 1 ist der Anlass dieser
Neuwägung, und diese Entscheidung ist seine Antwort; ihre Festlegung 1 in der Dogfood-Hälfte und
ihre Festlegungen 3 bis 5 binden unverändert fort, und diese ADR trägt darum kein `Supersedes`),
[ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
(**Accepted** — ihre Festlegung 2 trägt das Kriterium, das die Injektion trägt: *Release-Entscheidung* ja,
*Bau-Ergebnis* nein; ihre Festlegung 3 trägt die zwei Kanäle, die unten unberührt bleiben),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Digest und die Fassung
identifizieren denselben Schnitt),
[`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (der Release-Bau läuft über
die Plattform-Matrix; die Injektion läuft in denselben Bau),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (der Beleg des
Accept-Übergangs ist die Runde der prüfenden Rolle, genannt bei ihrer Kennung),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (Festlegung 3 — der
Slice-Plan, den der Prozess bewegt, steht unten bei seiner Kennung, nicht unter seiner Adresse),
[`MR-048`](../../../harness/conventions.md#mr-048--der-reproduzierbarkeits-anker-ist-die-rezept-form-die-emittierten-skelette-pinnen-per-tag)
(die Rezept-Form ist der Reproduzierbarkeits-Anker der Bau-Rezepte),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert; keine ist ein Erwartungswert),
[`MR-051`](../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
(Setzung 2 — die Messung in §Kontext ist eine datierte Messung),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)

**Schärft:** `—` — Prozess- und Werkzeug-Entscheidung ohne Spec-Stratum. Die Fassungs-Angabe der
Bedienoberfläche wird in keinem Spec-Stratum geschrieben; berührt ist der Release-Bau-Rezept-Bestand
([`MR-048`](../../../harness/conventions.md#mr-048--der-reproduzierbarkeits-anker-ist-die-rezept-form-die-emittierten-skelette-pinnen-per-tag)
Rezept-Form). Keine Festlegung unten bewegt eine `ARC-*`-Zeile und keine Anforderung des
Lastenhefts.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR) und §Hard Rule für Accepted-ADRs.

---

## Kontext

### Was die Entscheidung auslöst

Zwei Anlässe, beide benannt:

**Der Re-Evaluierungs-Trigger 1 von
[ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) ist eingetreten.** Sein Wortlaut
(verbatim):

> ***„Wenn das Werkzeug eine Fassungs-Fläche bekommt*** *(ein `version`-Flag oder eine
> Fassungs-Konstante, die der Bootstrap-Lauf lesen kann), ist der Stempel aus Alternative A gegen
> diese Entscheidung neu zu wägen — der tragende Grund von Festlegung 2 entfiele."*

**Die Setzung des Auftraggebers vom 2026-09-23.** Der Anlass ist gemessen: ohne brew und ohne
`--version` gibt es keinen Weg, eine installierte Fassung zu erkennen — der Download-Weg bleibt
fassungs-spurlos, wenn die Datei bewegt wird. Die Richtung ist gesetzt: das Werkzeug meldet seine
Fassung (`ai-harness-init --version`), injiziert per `ldflags` aus dem Tag am Tag-Bau; diese
Entscheidung formt sie aus und trägt die verworfenen Varianten samt ihrem Grund in
§Verglichene Alternativen — dieselbe Lage wie in
[ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
§Kontext (*„Die Richtung ist gesetzt …; diese Entscheidung formt sie aus"*). Die Abwägung ist
damit gefallen, nicht offen.

Der Vorgang, der die Arbeit trägt, ist der Slice-Plan `slice-das-werkzeug-sagt-seine-fassung`
(Kennung statt Adresse,
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 3 — der Plan
wandert im Planning-Lifecycle); er liest diese Entscheidung als Bindung, und die Zitate unten
messen gegen seinen Kopf.

### Die Fassungs-Lage, gemessen

Zwei Messungen tragen die Lage, beide datiert (2026-09-23) und neben ihrem Kommando:

- **Das Werkzeug führt heute kein `version`-Flag und keine Fassungs-Konstante** — dieselbe
  Messung, die [ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) §Kontext trug,
  immer noch wahr:

  ```sh
  grep -rcE '"version"|--version' cmd/ai-harness-init/main.go   # 0
  ```

- **Der Pin trägt den Tag kanonisch, und der Release-Bau liest ihn von dort** — die Reihenfolge,
  unter der die Fassung bekannt ist, **bevor** der Tag geschnitten wird: der Pin-Zug (Makefile und
  emittierte Vorlage) geht dem Bau voraus, der Bau liest denselben Wert:

  ```sh
  grep -nE '^TRAEGER_TAG' Makefile                              # :45 — TRAEGER_TAG ?= v0.2.2
  grep -nE 'release-artifacts DEST' .github/workflows/release.yml   # :56 — make release-artifacts DEST=dist
  ```

Beide Zahlen sind **keine** Erwartungswerte
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)):
die Zeile wandert mit jedem Pin-Sprung, der Aufruf wandert mit dem Workflow.

### Die Achsen-Lage

Der Pin trägt nur den Tag — die Dogfood-Hälfte von
[ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 1 in Kraft, die
Emissions-Hälfte von
[ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
festgelegt. Der Zahn, der die Pin-Achse hält, ist der pin-kopplung-Test in
[`test/traeger-fetch.bats`](../../../test/traeger-fetch.bats) — der Tag hält an beiden Stellen
(Makefile und Fragment), das Fragment führt keinen Digest; sein Kommentar nennt die
Selbstreferenz-Wand aus [ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md).

Das Kriterium, das die Neuwägung trägt, steht in
[ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
Festlegung 2 — verbatim:

> *„Ein Wert im Binary darf eine **Release-Entscheidung** benennen (der Tag wird geschnitten,
> nicht berechnet — ändert man die Tag-Zeile der Vorlage und schneidet den neuen Tag, bleibt alles
> konsistent), aber keine Funktion des **Bau-Ergebnisses** sein."*

Die Fassung ist eine Release-Entscheidung: sie wird geschnitten, nicht berechnet. Die Wand
(Bau-Ergebnis im Binary) geht sie nicht an — die Digests reisen weiter nicht im Binary. Der
Stempel aus Alternative A von
[ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) ist damit gegen ein anderes
Kriterium zu wägen als am 2026-09-18: nicht mehr gegen *„das Werkzeug kennt seine Fassung nicht"*
(der tragende Grund, der entfällt), sondern gegen die zwei Gründe, die von der Fläche unabhängig
sind (§Verglichene Alternativen, Option B).

**Die Kernfrage des Vorgangs:** was meldet ein **Bau ohne Release-Injektion** — lokal
`make artifact` am Quellstand, ein plain `go build`, ein Bau im brew-Tap? Der Pin-Wert des Builds
ist die letzte Fassung, nicht die gebaute Quelle — eine erfundene Zahl wäre eine Lüge, eine leere
Ausgabe wäre still. Die Abwägung steht in §Verglichene Alternativen.

## Entscheidung

**Wir bauen die Fassungs-Fläche, die
[ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 2 verworfen hat — auf
der Binary-Achse, am Tag-Bau, und lassen die Pin-Achse und den verworfenen Stempel unberührt.**
Die Neuwägung fällt so: der Stempel aus Alternative A bleibt verworfen — der tragende Grund von
Festlegung 2 (das Werkzeug kennt seine Fassung nicht) fällt, aber die zwei Gründe, die von der
Fläche unabhängig sind, tragen weiter (konvergente Datei, zweite Quelle, §Verglichene
Alternativen); die Fassungs-Fläche entsteht als Binary-Achse und macht den prozeduralen
Fassungs-Fit aus Festlegung 2 **belegbar**. Drei Festlegungen.

**1. Die Fassungs-Fläche: `ai-harness-init --version` meldet den Tag, den der Release-Bau per
`ldflags` aus dem Tag-Kontext injiziert.** Das Werkzeug führt eine Fassungs-Variable, Default
**leer**; der Release-Bau — `release-artifacts` und die `artifact`-Ziele — trägt den
Injektions-Schritt, und der Release-Workflow übergibt den Tag, den der Pin-Zug vor dem Bau
gesetzt hat: derselbe Wert, denselben Schnitt
([`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Die Injektion liest den
**übergebenen** Wert, nicht den unveränderten Pin-Default des Makefiles (`?=`): der Default ist
der Stand des letzten Schnitts, nicht der des Bau-Moments — ihn zu injizieren, wäre die erfundene
Zahl. Wie „übergeben" von „Default" unterschieden wird (Origin-Prüfung auf `TRAEGER_TAG`, oder
ein eigener Injektions-Name, den der Workflow auf denselben Wert setzt), ist Werkzeug-Entscheidung;
die Semantik — **ein Bau ohne übergebenen Fassungs-Wert injiziert nicht** — bindet Festlegung 2.
Der injizierte Wert ist eine **Release-Entscheidung** — genau die Klasse, die
[ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
Festlegung 2 als die einzige im Binary zulässige benennt; die Wand bleibt geschlossen, die
Digests reisen weiter nicht im Binary, und die Sonden-Probe jener ADR bleibt unberührt (sie liest
die eingebettete Vorlage, nicht die injizierte Variable).

**2. Der Fehlt-Fall laut: ein Bau ohne Injektion meldet die abwesende Fassung, nicht den
Pin-Stand.** Ein Binary ohne Injektion meldet auf `--version` einen klaren Wortlaut — die Fassung
wurde nicht injiziert, der Bau trägt keinen geschnittenen Tag — und bricht mit **Exit 2**. Nicht
leer, nicht der Pin-Wert des Builds: der Pin-Wert ist die letzte Fassung, nicht die gebaute
Quelle; ihn zu melden, wäre eine erfundene Zahl, und eine leere Ausgabe wäre still —
ununterscheidbar von einem kaputten Flag. Der Fehlt-Fall ist ein **geführter** Ausgang im
Dispatch, kein Fall in den Init-Pfad — dieselbe Sperren-Klasse, die
[ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 2 an den
Release-Schnitt übergab und die mit diesem Flag gebaut ist. Der Fehlt-Fall ist der laut-Befund
über den Zustand des Binary, kein Fehler des Repos — dieselbe Lesart, unter der der Fehlt-Fall
des Trägers Exit 0 mit Meldung trägt
([ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 3). Der Wortlaut wird
dokumentiert (Folgepflicht 3); die zwei Kanäle — die Formel und der Digest gegen die
`SHA256SUMS` ([ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
Festlegung 3) — bleiben die Prüf-Kette für die Herkunft, das Flag ist der dritte, belegende Ort
am Binary.

**3. Abgrenzung: die Pin-Achse und die zwei Kanäle bleiben, wie sie sind.** Der Pin trägt weiter
nur den Tag — der Zahn an der Pin-Achse (der pin-kopplung-Test in
[`test/traeger-fetch.bats`](../../../test/traeger-fetch.bats)) bleibt unverändert. Kein Weg
dieses Slices greift in die Formel oder die `SHA256SUMS` ein: die zwei Kanäle
([ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
Festlegung 3) bleiben, die Formel liest die Fassung weiter aus dem Release, und es entsteht kein
zweiter Weg in die Formel-Nachzug-Form. Die byte-identische Eigenschaft des Default-Pfads — die
Kommentar-Zeile am `artifact-host`-Rezept des [`Makefile`](../../../Makefile) nennt sie,
[`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix); der Reproduzierbarkeits-Anker
der Rezepte ist die Rezept-Form
([`MR-048`](../../../harness/conventions.md#mr-048--der-reproduzierbarkeits-anker-ist-die-rezept-form-die-emittierten-skelette-pinnen-per-tag))
— bleibt für denselben Injektions-Wert: gleiche Injektion, gleiche Bytes; der Vergleich am selben
Tag hält. Die emittierte Ebene bleibt unberührt: das Fragment-Default trägt nur den Tag
([ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
Festlegung 2), die Injektion ist Release-Bau-Ebene dieses Repos.

## Verglichene Alternativen

Regeln dieser Sektion: **mindestens drei Optionen mit Pro/Contra** — „nichts tun" ist eine davon
(Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR)).

| Option | Pro | Contra |
|---|---|---|
| A — **nichts tun**: die Fläche bleibt verworfen, der Fassungs-Fit bleibt prozedural | keine neue Oberfläche; der Bestand läuft | der gefeuerte Trigger 1 von [ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) bliebe stehengeblieben — ein stiller Trigger; der Bedarf ist gesetzt (Setzung 2026-09-23: eine installierte Fassung ist ohne brew nicht erkennbar) |
| B — **der Stempel aus Alternative A zurückgeholt**: der Bootstrap-Lauf schreibt seine eigene Fassung als Pin ins Ziel | der Fassungs-Fit am Pin wäre konstruktiv statt prozedural | die zwei Gründe, die von der Fläche unabhängig sind, tragen weiter: der Stempel schreibt in eine **konvergente** Datei und überlebt den nächsten Re-Lauf nicht; ein adopter-eigener Nebensortierer wäre eine zweite Quelle für denselben Zustand — [ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 2 bleibt in diesen zwei Beinen richtig |
| C — **der Pin-Wert mit einem Quellstand-Zusatz** (Kandidat b des Vorgangs): der Bau liest den Pin-Wert und qualifiziert ihn | jede Ausgabe trägt eine Zahl | die Zahl ist die letzte Fassung, nicht die gebaute Quelle — der Zusatz kann den Quellstand nur mit Bau-Metadaten ehrlich benennen, und die Ausgabe wird eine Funktion des Makefile-Stands am Bau-Moment; die Pin-Achse (welcher Tag wird gefetcht) und die Binary-Achse (was dieses Binary ist) fallen in einer Ausgabe zusammen — genau die Trennung, die [ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) hält; und der Fehlt-Fall wird unauffindbar, weil er nie eintritt |
| D — **Fassungs-Konstante im Quelltext**, am Release-Schnitt fortgeschrieben | der plain build meldet immer etwas; keine Injektions-Mechanik | der Wert im Quelltext sagt für einen Nicht-Tag-Stand immer eine falsche Fassung — vor dem Schnitt zu hoch, danach zu niedrig, die erfundene Zahl nur verlagert; je Schnitt ein Quelltext-Edit, dessen Vergessen die Lüge still macht |
| E — **der Fehlt-Fall still** (leere Ausgabe, Exit 0) | billig; kein Wortlaut zu pflegen | still heißt ununterscheidbar von einem kaputten Flag — der Aufruf misst nichts; dieselbe Lesart, unter der [ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 2 den stillen Start am gepinnten Stand als den Bruch benennt, den der laut-Bruch ablöst |
| **F — der Fehlt-Fall laut (gewählt)** | ehrlich — das Binary sagt, was es nicht trägt; der dokumentierte Exit macht den Zustand skript-bar; die Pin-Achse und die zwei Kanäle bleiben unberührt; der Injektions-Wert ist die Release-Entscheidung, die [ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) Festlegung 2 als einzige im Binary zulässige Klasse benennt | eine neue öffentliche Oberfläche — das genaue Contra von [ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 2; die Setzung vom 2026-09-23 wiegt es auf; jeder Vertriebsweg ohne Injektion meldet den Fehlt-Fall, bis sein Bau den Schritt trägt (Re-Evaluierungs-Trigger 3) |

## Konsequenzen

- **Positiv:** Der Fassungs-Fit bekommt einen belegenden Ort am Binary. Der prozedurale Fit aus
  [ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 2 — der
  Release-Schnitt koppelt Pin und Fassung im selben Zug — behält seine Aussage und bekommt die
  Prüfbarkeit: ein Adopter hält `ai-harness-init --version` gegen den Pin seines Ziels, statt den
  Bruch still laufen zu lassen.
- **Positiv:** Der Digest und die Fassung identifizieren denselben Schnitt
  ([`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)); die zwei Kanäle
  bleiben die Prüf-Kette, das Flag ist der dritte, belegende Ort.
- **Negativ:** Eine neue öffentliche Oberfläche — das genaue Contra von
  [ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 2; die Setzung vom
  2026-09-23 wiegt es auf.
- **Negativ:** Der Injektions-Wert ist ein Eingang, kein Herkunfts-Nachweis — ein Bau, dem ein Tag
  übergeben wurde, meldet ihn, gleichgültig, aus welchem Quellstand er gebaut ist. Die Herkunft
  tragen die zwei Kanäle weiter; das Flag meldet die Injektion, nicht die Provenienz.
- **Negativ:** Jeder Vertriebsweg ohne Injektion meldet laut keine Fassung — ein brew-Tap, der
  ohne Injektion baut, bleibt solange im Fehlt-Fall, bis seine Formel den Schritt trägt
  (Re-Evaluierungs-Trigger 3).
- **Folgepflicht 1 — die zwei Mutations-Fälle:** der Fehlt-Fall (ohne Injektion → Wortlaut und
  Exit 2) und der abweichende Injektions-Wert; jeder mit dem Rot-Beleg nach
  [`AGENTS.md`](../../../AGENTS.md) §3.6, der seine behauptete Ursache trägt.
- **Folgepflicht 2 — der Injektions-Schritt in den Release-Bau-Rezepten** (`release-artifacts`
  und die `artifact`-Ziele); die byte-identische Eigenschaft des Default-Pfads bleibt für
  denselben Injektions-Wert (gleiche Injektion, gleiche Bytes).
- **Folgepflicht 3 — der Handbuch-Nachzug** (Weg A, B und C) nennt das Flag, den Fehlt-Fall-Wortlaut
  samt Exit und die zwei Kanäle daneben — Ist-Zustand, keine Chronik
  ([`AGENTS.md`](../../../AGENTS.md) §3.7).
- **Folgepflicht 4 — kein `Supersedes`.** [ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  bleibt in Kraft; diese ADR beantwortet ihren Re-Evaluierungs-Trigger 1, ohne eine ihrer
  Festlegungen anzutasten — der Stempel bleibt verworfen, der Fassungs-Fit wird belegbar.
  [ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
  Festlegung 2 bleibt; ihre Klassen-Grenze (Release-Entscheidung ja, Bau-Ergebnis nein) wird
  genutzt, nicht geändert.
- **Folgepflicht 5 — die emittierte Ebene bleibt unberührt.** Das Fragment-Default trägt nur den
  Tag ([ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
  Festlegung 2); was ein erzeugtes Ziel an Fassungs-Aussage bekommt, entscheidet der Slice, der
  die Tool-Ebene entscheidet.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| `make test` (Go) | **mit Injektion:** der Bau mit übergebenem Fassungs-Wert meldet exakt diesen Wert auf `--version`; ein abweichender Wert färbt den Wächter rot | `make test` |
| `make test` (Go) | **Fehlt-Fall laut:** ohne Injektion meldet `--version` den dokumentierten Wortlaut und Exit 2; unter der geschwächten Zusicherung (leere Ausgabe, Pin-Wert statt Meldung, Exit 0) bleibt der Fall rot | `make test` |
| `make test` (bats) | **Pin-Achse unverändert:** der Tag hält an beiden Stellen, das Fragment führt keinen Digest — der Zahn an der Selbstreferenz-Wand bleibt, wie er ist | `make test` |
| `make mutate` | der Injektions-Schritt entfernt oder auf einen falschen Operanden gestellt → der Wächter fällt (kuratiertes Set; kein Gate) | `make mutate` |

## Re-Evaluierungs-Trigger

- **Wenn ein Bau ohne Injektion still oder mit einer Zahl antwortet** *(beobachtbar am
  Mutations-Fall des Fehlt-Falls)*: der Fehlt-Fall laut ist die Zusage; bricht sie, trägt der Ort
  den Befund, nicht die Wiederholung.
- **Wenn der `ldflags`-Weg die byte-identische Eigenschaft des Default-Pfads bricht**
  *(beobachtbar am Vergleich, den die `artifact-host`-Kommentar-Zeile des
  [`Makefile`](../../../Makefile) benennt)*: die Reproduzierbarkeits-Aussage ist neu zu schneiden,
  nicht das Flag zu verweichlichen — dieselbe Rückführung, die der Slice-Plan vorab benennt.
- **Wenn ein Vertriebsweg eine Fassung melden soll, die sein Bau nicht injiziert** *(beobachtbar
  am installierten Binary — brew-Tap, Dritt-Bau)*: die Injektion gehört in den Bau des Wegs; bis
  dahin meldet er den Fehlt-Fall laut. Grenze benannt, kein Handlungszwang dieses Repos.
- **Wenn der Stempel (Alternative A von
  [ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md)) erneut angefragt wird**
  *(beobachtbar an einem Plan, der den Pin konstruktiv setzen will)*: die zwei
  flächen-unabhängigen Gründe tragen weiter; nur ein dritter Ort, der weder konvergent noch eine
  zweite Quelle ist, öffnet die Neuwägung neu.

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`. Sie wird `Accepted`, **wenn eine Reviewer-Runde sie gegen
[ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) (Festlegung 2 samt Alternative A
und Re-Evaluierungs-Trigger 1),
[ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
(Festlegungen 2 und 3) und
[`MR-048`](../../../harness/conventions.md#mr-048--der-reproduzierbarkeits-anker-ist-die-rezept-form-die-emittierten-skelette-pinnen-per-tag)
auf Konsistenz geprüft hat und ihr Report ohne blockierenden Befund an der **Substanz** der drei
Festlegungen in `docs/reviews/` liegt.**

**Drei Fächer, nicht zwei** — dieselbe Dreiteilung, die
[ADR-0062](0062-eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-nicht-beantwortet.md)
§Der Acceptance-Trigger mit derselben Beobachtung übernommen hat. Ein blockierender Befund an der
**Darstellung** — Adressform, Zahl ohne Kommando, Zitat-Stelle — wird behoben und hindert die
Annahme nicht; dasselbe gilt für einen Befund an **jedem Abschnitt, der mit dem Accept einfriert,
ohne eine Festlegung zu tragen**. Tragend ist die Kennzeichnung: bei Zweifel geht die Kennzeichnung
vor, nicht die Aufzählung. Die drei Abschnitte, die **nicht** einfrieren, sind §Kontext samt
seiner Messungen, die Re-Evaluierungs-Trigger und **dieser Trigger-Abschnitt selbst** — ein
Befund dort wird behoben, solange die Datei `Proposed` ist und solange die Behebung keine der drei
Festlegungen ändert; ändert sie eine, ist es ein Substanz-Befund und blockiert.

Der Beleg ist eine Runde der prüfenden Rolle; die Nachmessung durch den Kontext, der einen Befund
aufgelöst hat, ist keine
([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2) — nach einem
blockierenden Verdikt ist es die **nächste** Runde derselben Rolle. Die Accept-Zeile der
§Geschichte nennt ihn als **Kennung**, nicht als Pfad-Link (ebenda, Festlegung 1).

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-23 | **Proposed** | Architect-Lauf zu `slice-das-werkzeug-sagt-seine-fassung`, ausgelöst durch den Re-Evaluierungs-Trigger 1 von [ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) und die Setzung des Auftraggebers vom 2026-09-23 (`ai-harness-init --version`). Die Neuwägung: der Stempel aus Alternative A bleibt verworfen (die zwei flächen-unabhängigen Gründe tragen), die Fassungs-Fläche entsteht auf der Binary-Achse — injiziert am Tag-Bau aus `TRAEGER_TAG`, Fehlt-Fall laut mit Exit 2. Der Acceptance-Trigger steht unten |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0063` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).