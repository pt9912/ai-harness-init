# ADR-0059: Die Prüfsummen reisen als SHA256SUMS neben die Assets — der emittierte Pin trägt nur den Tag

**Status:** Proposed

**Datum:** 2026-09-19

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) (**Accepted** — der Gegenstand
der Teil-Ablösung: ihre Festlegung 1 trägt zwei Hälften, und die Emissions-Hälfte ist an die
Selbstreferenz-Wand gelaufen. Ihre Festlegungen 2 bis 5, die Dogfood-Hälfte von Festlegung 1,
ihr Fehlt-Fall und ihre E2E-Zusage binden unverändert fort — §Supersedes (Teil) zählt den
Gegenstand wörtlich auf),
[ADR-0055](0055-abgeschaffte-kennung-verlaesst-die-fitness-function-als-teil-abloesung.md)
(**Accepted** — die Form der Teil-Ablösung in ihrer zweiten Anwendung),
[ADR-0032](0032-eingefrorene-referenz-folgt-ihrem-rumpf.md) (**Accepted** — der Präzedenzfall
der Form: Teil-`Supersedes` auf einen wörtlich genannten Gegenstand einer `Accepted`-ADR, samt
des Index-Zusatzes, der Umfang und revidierende ADR nennt),
[ADR-0007](0007-bootstrap-phasen.md) (**Accepted** — das emittierte Fragment ist konvergent;
der Re-Lauf ist der Weg, mit dem ein Ziel die neue Fassung des Pins bekommt),
[`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(das Vorbild im Haus: die vendored Baseline trägt `SHA256SUMS`, und `make baseline-verify` hält
den Baum dagegen — das Manifest reist mit dem Gelieferten; dazu das Pin-Muster: Netz nur bei dem
einen Aufruf, kein Gate),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert; keine ist ein Erwartungswert),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Pin trägt Version +
Prüfsumme, fail-closed gekoppelt),
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (die Netz-Grenze:
das Netz gehört an den Fetch, nicht an den Bootstrap),
[`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (die sechs Assets der Matrix)

**Schärft:** `—` — Prozess- und Werkzeug-Entscheidung ohne Spec-Stratum. Keine Festlegung unten
bewegt eine `ARC-*`-Zeile und keine Anforderung des Lastenhefts; die Prüfsummen-Kette, die sie
formt, ist Werkzeug-Ebene.

**Supersedes (Teil):**
[ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 1 — dort genau die
**Emissions-Hälfte**: die Spiegelung der sha256-Werte als Default in der emittierten
Fragment-Vorlage (*„der emittierte Fragment-Default führt dieselben Werte als überschreibbare
Variablen"*), samt der Digest-Beine ihrer Pin-Kopplung in der §Fitness Function (die Stellen
„Emitter-Default" und „Fragment-Default" der ersten Zeile) und der Reichweite ihrer Folgepflicht 1
über dieselben Stellen. Alles andere jener Datei bindet unverändert fort: die **Dogfood-Hälfte**
von Festlegung 1 (das kanonische Makefile-Paar, fail-closed gekoppelt), Festlegung 2 (kein Stempel
— hier bestätigt und mit der Messung der Wand verschärft), Festlegung 3 (eigenes Fragment
`harness/mk/traeger.mk` <!-- d-check:ignore (der Pfad entsteht erst im gebootstrappten Ziel) --> mit eigenem Target `traeger-fetch`, kein Prerequisite), Festlegung 4
(Transport im gepinnten Docker-Bild), Festlegung 5 (Verhältnis zu
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md)), der gemessene Fehlt-Fall und die
E2E-Zusage am realen Ziel. Diese ADR ändert, **woher** die Prüfsummen im Ziel kommen — nicht, dass
und wie der Fetch prüft.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR) und §Hard Rule für Accepted-ADRs.

---

## Kontext

### Die Wand, Ende-zu-Ende gemessen

[ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 1 verlangt, dass die
Emission die sha256-Werte der sechs Release-Assets als Default führt. Die Fragment-Vorlage ist
aber Text **im Binary** — der Enforce-Emitter bettet sie ein:

```sh
grep -n 'go:embed' internal/emit/enforce.go            # :28 — //go:embed all:templates/enforce
grep -c 'TRAEGER_SHA256' internal/emit/templates/enforce/traeger.mk   # 7 — sechs Digest-Variablen, exportiert in einer siebten Zeile
```

Daraus folgt die Selbstreferenz: die Digests sind Funktionen des Bau-Ergebnisses, und das
Bau-Ergebnis enthält die Digests. Schreibt man die gemessenen Digests in die Vorlage und baut,
ändert das die Binary, und die gepinnten Werte passen nicht mehr zum veröffentlichten Bau — nicht
konvergent, keine Iteration hilft. Der Release-Lauf hat denselben Unterschied am Bau gemessen:
Neubau aus dem Baum mit geschriebenen Digests gegen das Release-Asset, `cmp -l`, **453**
abweichende Bytes bei gleicher Dateigröße — die Binary ist eine andere, bei Werten derselben
Länge.

Die Wand ist am Release `v0.2.0` **real getroffen**, Ende-zu-Ende an drei Stellen gemessen —
die Kommandos unten sind je die meinen, die dritte liest das veröffentlichte Binary selbst:

```sh
gh release view v0.2.0 --json assets --jq '.assets | length'          # 6 — die Matrix ist vollständig
git show v0.2.0:internal/emit/templates/enforce/traeger.mk | grep -m1 'LINUX_AMD64'
#   → TRAEGER_SHA256_LINUX_AMD64 ?= 0a5851f40be317aa42394678253de99bfd1267a84218b85900b59f8031a42f5b
sha256sum <v0.2.0-Asset linux-amd64>
#   → 0a5851f40be317aa42394678253de99bfd1267a84218b85900b59f8031a42f5b
grep -oa 'TRAEGER_SHA256_LINUX_AMD64 ?= [0-9a-f]\{64\}' <dasselbe Asset>
#   → TRAEGER_SHA256_LINUX_AMD64 ?= 37c67efae72661b809ccf44de36ed14e72073238e4dcbf67e0324a4578f38cd3
```

Der Tag-Baum trägt die korrekten Werte, das Asset hasht zu ihnen — und das **veröffentlichte
Binary** bettet die ersten, abweichenden Digests ein. Ein Ziel, das aus dem `v0.2.0`-Fragment
fetcht, verifiziert gegen `37c67efa…` und bricht fail-closed an seinem eigenen Release, ohne den
Träger zu legen — die Zusage aus [ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
Festlegung 1 ist an dieser Fassung nicht einlösbar.

### Die Eingangslage

`v0.2.0` ist published mit korrekten Assets (Messung oben); sein Repo-Baum am Tag ist defekt
(ein 23-Zeilen-Makefile; die Reparatur liegt vor dem Commit `e34ef1de`), und die CI auf der
reparierten Spitze ist grün. Der `v0.2.1`-Schnitt pausiert auf dem Entscheidungs-Bezug dieser
Datei. Die Dogfood-Hälfte trägt derweil: das Makefile führt den Tag und die sechs Digests
kanonisch (`grep -n '^TRAEGER_TAG' Makefile` → `:42`, `grep -c '^TRAEGER_SHA256' Makefile` →
**6**) — sie sind schreibbar, ohne die Binary zu bewegen, denn das Makefile ist nicht embedded.

**Die Richtung ist gesetzt:** Variante (a) ist die Setzung des Auftraggebers vom 2026-09-19; diese Entscheidung formt sie aus und trägt die zwei verworfenen Varianten samt ihrem Grund in §Verglichene Alternativen — die Abwägung ist damit gefallen, nicht offen.

## Entscheidung

**Wir legen die Prüfsummen als `SHA256SUMS` neben die Assets — das Manifest reist als
Release-Asset, der emittierte Pin trägt nur den Tag, und das Binary führt keinen Wert, der vom
Bau-Ergebnis abhängt.** Sechs Festlegungen.

**1. `SHA256SUMS` reist als Release-Asset.** Jeder Release-Schnitt, der den Fetch trägt, erzeugt
und publiziert `SHA256SUMS` — eine Zeile je Asset, `<sha256>  <name>` — als Asset desselben
Releases. Der Fetch im Ziel lädt Manifest und gewähltes Asset vom selben Release und verifiziert
das Asset gegen seinen Manifest-Eintrag **vor** der Ablage; eine Abweichung bricht fail-closed,
ohne den Träger zu legen. Das Vorbild im Haus ist die vendored Baseline: sie trägt `SHA256SUMS`,
und `make baseline-verify` hält den Baum dagegen
([`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache))
— das Manifest reist mit dem Gelieferten, und ein zweiter Wächter hält die Herkunft, wo einer
existiert.

**Die SUMS-Datei hält ihre Integrität über den Release selbst.** Sie ist ein Asset desselben
Releases wie die Assets, die sie beschreibt — ihr Träger ist der Release-Kanal, dieselbe Klasse
wie für jedes Asset. Der Doppel-Check Asset↔Manifest fängt, was ein Prüfsummen-Check an dieser
Stelle je gefangen hat: beschädigte und abgebrochene Downloads, Verwechslung der Assets
untereinander und ein gegen das gemessene Manifest falsch hochgeladenes Asset. Was er nicht
fängt: einen Kanal, der Manifest und Asset **gemeinsam** ersetzt — dieselbe Grenze, die der
Slice-Plan als Bestand benennt (*„der Fetch prüft den Digest, nicht die Signatur"*) und
[ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Trigger 3 trägt. **Der Preis ist
real und wird benannt:** die eingebetteten Digests reisten über den Git-Kanal (zwei Kanäle), das
Manifest reist über den Release-Kanal — die Emissions-Hälfte verliert den Kanal-Split, die
Dogfood-Hälfte behält ihn (Festlegung 3).

**2. Das Binary trägt keinen Wert, der vom Bau-Ergebnis abhängt.** Der emittierte Fragment-Pin
trägt nur `TRAEGER_TAG ?= v0.2.0` — und das Kriterium dahinter: Ein Wert im Binary darf eine
**Release-Entscheidung** benennen (der Tag wird geschnitten, nicht berechnet — ändert man die
Tag-Zeile der Vorlage und schneidet den neuen Tag, bleibt alles konsistent), aber keine Funktion
des **Bau-Ergebnisses** sein. Digests und SUMS-Digests sind Funktionen des Bau-Ergebnisses; sie
reisen nicht im Binary. Damit ist die Wand **strukturell geschlossen**, nicht umgangen — der
emittierte Pin kann nicht mehr inkonsistent mit den Assets werden, weil er nichts mehr über sie
behauptet. Der Tag-Pin wandert mit dem Release-Schnitt (`v0.2.0` am Tag,
`grep -n '^TRAEGER_TAG' internal/emit/templates/enforce/traeger.mk`); [ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
nannte `v0.1.1` als den Stand, an dem ihre Entscheidung fiel — die Stelle, an der der Tag steht,
ist die des Release-Schnitts, nicht eine eingefrorene Konstante.

**3. Die Dogfood-Hälfte von [ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
Festlegung 1 bleibt — sie trägt, und sie trifft die Wand nicht.** Das Makefile ist nicht
embedded: es trägt den Tag und die sechs Digests kanonisch, der Dogfood-Fetch verifiziert gegen
den Makefile-Pin, und das sind **zwei Kanäle** — das Makefile reist in git, das Asset über den
Release-Kanal —, dieselbe Klasse wie `BASELINE_TAG`/`BASELINE_ZIP_SHA256` beim
`vendor-baseline`. Seine Werte sind zur Schnitt-Zeit schreibbar, ohne die Binary zu bewegen. **Die Einzeldigests bleiben, statt auf die `SHA256SUMS` zu verweisen.** Der Grund ist der Kanal-Split: der Dogfood-Fetch verifiziert gegen den Makefile-Pin in einem Schritt aus dem Git-Kanal; würde er das Manifest vom Release holen, um es gegen das Asset zu halten, reisten beide über denselben Kanal wie im Ziel — die zwei-Kanal-Eigenschaft, die die Dogfood-Hälfte trägt, fiele. Die Kopplung Makefile-Digests↔`SHA256SUMS` aus Folgepflicht 2 hält die zwei Fassungen gegeneinander.

**4. Kein Stempel — bestätigt und verschärft.** Die Stempel-Alternative fällt aus demselben
Grund wie [ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 2, jetzt mit
der Messung der Wand: die Bootstrap-Ausführung hat keine Quellen-Fläche für die Digests ihrer
eigenen Assets. Das laufende Binary kann sie weder aus sich ableiten (die Wand — es *ist* das
Bau-Ergebnis) noch ohne Netz holen (das Manifest liegt im Release, und Netz gehört an den Fetch,
nicht an den Bootstrap — [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten),
[`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).
Der Stempel scheitert an derselben Wand wie die Emission, nur einen Lauf später.

**5. Ein-Release-Verzug — ernsthaft geprüft, verworfen.** Die Option trägt mechanisch: die
Digests des Vorgänger-Releases sind beim Schnitt von `N` bekannt und von `N`s Bau unabhängig —
die Wand gilt für sie nicht, und die Pin-Form (Tag und Digests im Binary) bliebe unverändert.
Verworfen wird sie über die Kopplung, die sie bricht. [ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
Festlegung 2 trägt den Fassungs-Fit **prozedural**: der Release-Schnitt koppelt Pin und Fassung
im selben Commit, und der laut-Bruch (Sperren im Dispatch) greift ab dem gepinnten Stand. Mit
Verzug pinnt jede Fassung `N` den Träger `N-1`: ein Ziel, das von `N` gebootstrapped wurde,
bekommt einen Träger, der ein in `N` neu hinzugekommenes Unterkommando **per Konstruktion** nicht
führt — das laut-Bruch-Fenster aus jener Festlegung wird zum Normalzustand jedes Releases mit
neuem Unterkommando statt zum Ausnahmefall einer schlechten Kopplung. Dazu zwei Preise: die
gemessene E2E-Kette (*frischer Klon → `traeger-fetch` → `archive-welle` läuft*) belegt am Ziel
die **Vorgänger**-Fassung statt die emittierte Zusage, und die Heilung eines falschen Digests
kostet einen vollen Release-Zyklus, während der Abstand zwischen Werkzeug-Fassung und
Träger-Fassung konstruiert maximal statt zufällig klein bleibt. Der Verzug ist eine konsistente
Antwort, die die falsche Frage beantwortet: er rettet die Pin-Form und bezahlt dafür genau die
Kopplung, um deretwillen die Pin-Form existiert.

**6. Verhältnis zu [ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md):** die
Teil-Ablösung steht im Kopf (*Supersedes (Teil)*); alles Übrige bindet fort. Der Fetch bleibt
eigenes Target in eigenem Fragment ohne Prerequisite, der Transport bleibt im gepinnten
Docker-Bild, der Fehlt-Fall bleibt Exit 0 mit Meldung, die E2E-Stufe bleibt am realen Ziel.

## Verglichene Alternativen

Regeln dieser Sektion: **mindestens drei Optionen mit Pro/Contra** — „nichts tun" ist eine davon
(Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR)).

| Option | Pro | Contra |
|---|---|---|
| **A — SHA256SUMS als Release-Asset, emittierter Pin trägt nur den Tag (gewählt)** | die Wand ist strukturell geschlossen — der emittierte Pin behauptet nichts über das Bau-Ergebnis; der Release-Schnitt kann die Makefile-Digests zur Schnitt-Zeit korrekt schreiben, ohne die Binary zu bewegen; das Manifest reist mit dem Gelieferten wie bei der vendored Baseline ([`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)); die E2E-Kette misst die Fassung, die bootstrappt | die Emissions-Hälfte verliert den Kanal-Split — Manifest und Asset reisen über denselben Kanal, ein gemeinsamer Ersatz beider geht durch (die Dogfood-Hälfte behält zwei Kanäle); ein Release-Artifact mehr, das der Schnitt erzeugt und publiziert |
| B — Stempel zur Emissions-Zeit | der Ziel-Bestand bekäme die Werte ohne einen zweiten Release-Artikel | keine Quellen-Fläche: das laufende Binary kann die Digests seiner Assets weder ableiten (Wand — gemessen) noch ohne Netz holen (das Manifest liegt im Release); ein Netz-Hol beim Bootstrap verletzt die Netz-Grenze (Netz am Fetch, nicht am Bootstrap); scheitert einen Lauf später an derselben Wand |
| C — Ein-Release-Verzug (die Emission trägt die Digests des Vorgänger-Releases) | mechanisch konsistent — die Vorgänger-Assets sind beim Schnitt eingefroren, die Wand gilt nicht; keine neue Artefakt-Klasse, die Pin-Form bleibt | die Kopplung bricht **per Konstruktion**: jede Fassung `N` pinnt den Träger `N-1`, ein neu hinzugekommenes Unterkommando ist im Ziel bis zum nächsten Release nicht lauffähig, das laut-Bruch-Fenster aus [ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 2 wird zum Normalzustand; die E2E-Kette misst am Ziel die Vorgänger-Fassung; die Heilung eines falschen Digests kostet einen vollen Release-Zyklus; der Abstand Werkzeug↔Träger ist konstruiert maximal |
| D — nichts tun: die Emission trägt weiter Digest-Defaults | keine Änderung; der Bestand läuft | die Wand ist gemessen und real getroffen: jedes Ziel, das aus dem `v0.2.0`-Fragment fetcht, bricht fail-closed an seinen eigenen Werten — die Zusage aus [ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 1 ist an jeder künftigen Fassung nicht einlösbar, und der `v0.2.1`-Schnitt kann sie nicht umgehen, nur wiederholen |

## Konsequenzen

- **Positiv:** Die Wand ist geschlossen. Der emittierte Pin kann nicht mehr inkonsistent mit den
  Assets werden, weil er nichts mehr über sie behauptet; der Release-Schnitt schreibt die
  Makefile-Digests zur Schnitt-Zeit aus der Messung, ohne die Binary zu bewegen.
- **Positiv:** Die Prüf-Kette im Ziel prüft das Asset gegen das Manifest desselben Releases —
  beschädigte Downloads, Asset-Verwechslung und ein falsch hochgeladenes Asset gegen das
  gemessene Manifest brechen fail-closed, ohne den Träger zu legen.
- **Negativ, und das ist der Preis:** die Emissions-Hälfte verliert den Kanal-Split. Manifest
  und Asset reisen über denselben Kanal; die zwei-Kanal-Eigenschaft bleibt in der Dogfood-Hälfte
  und geht in der Emission verloren. Die Grenze (kein Signier-Schritt, kein Kanal-Trust) bleibt
  benannt und trägt denselben Ausgang wie bisher: ein Signier-Schritt am Release ist der
  Re-Evaluierungs-Trigger.
- **Negativ:** Ziele, deren Fragment von `v0.2.0` emittiert wurde, bleiben gebrochen, bis ein
  Re-Lauf mit der nächsten Fassung das konvergente Fragment heilt — die Heilung ist ein Re-Lauf,
  kein Patch am Ziel.
- **Folgepflicht 1 — der Release-Schnitt erzeugt und publiziert `SHA256SUMS`** ab dem ersten
  Schnitt, der die neue Emission trägt (`v0.2.1`); die SUMS des gepinnten Tags ist der
  Prüfgegenstand des Ziel-Fetches.
- **Folgepflicht 2 — die Pin-Kopplung wird neu geschnitten.** Aus drei Beinen werden zwei: das
  Makefile-Tag hält gegen das Fragment-Tag (Text-Kopplung, Test-Klasse `test/traeger-fetch.bats` (Zeilen 118–128)),
  und die Makefile-Digests halten gegen die `SHA256SUMS` des gepinnten Tags — wo ein Lauf das
  Release erreicht (CI mit Netz); im netzlosen Gate unprüfbar, benannt. Die Digest-Beine
  „Emitter-Default" und „Fragment-Default" aus [ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  §Fitness Function fallen mit der Teil-Ablösung.
- **Folgepflicht 3 — das emittierte Fragment führt nur noch `TRAEGER_TAG`;** seine sechs
  Digest-Default-Variablen und ihr Export entfallen, und der Fetch-Helfer liest die Prüfsummen
  aus der `SHA256SUMS` des gepinnten Tags statt aus den Variablen. Die Fehlermeldung, die heute
  den fehlenden Plattform-Pin nennt, nennt den fehlenden Manifest-Eintrag.
- **Folgepflicht 4 — die Doku-Zeilen tragen die neue Kette.** Die Werkzeuge-Tabelle in
  [`harness/README.md`](../../../harness/README.md) und der Kopf des Fragments nennen die
  Verifizierung gegen die `SHA256SUMS`; der Netz-Bedarf ändert sich nicht (eine Adresse, der
  Fetch).
- **Folgepflicht 5 — der `v0.2.1`-Schnitt vollzieht die Umstellung und heilt den `v0.2.0`-Defekt.**
  Dessen Binary bettet die abweichenden Digests ein (Messung in §Kontext); der Re-Lauf mit
  `v0.2.1` schreibt das konvergente Fragment kanonisch neu, und das Ziel fetcht gegen die
  `SHA256SUMS` seines gepinnten Tags.

- **Folgepflicht 6 — der Index-Zusatz an der
  [ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md)-Zeile wird im selben Commit wie
  der Accept-Übergang gesetzt** (Form-Vorbild:
  [ADR-0032](0032-eingefrorene-referenz-folgt-ihrem-rumpf.md) Folgepflicht 2,
  [ADR-0055](0055-abgeschaffte-kennung-verlaesst-die-fitness-function-als-teil-abloesung.md)): die
  Zelle trägt den Umfang der Ablösung (die Emissions-Hälfte von Festlegung 1) und die revidierende
  ADR. Vor dem Übergang gesetzt, führt der Index einen Zusatz an einem `Proposed`-Artefakt, dem
  der Übergang noch fehlt — gemessen (F-2). Dieser Zug trägt den Übergang und den Zusatz in
  einem Commit; für künftige Teil-Ablösungen gilt: der Zusatz steht erst mit dem
  Übergangs-Commit.


## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| Release-Asset-Lese-Lauf (kein Gate — die Sonde liest das veröffentlichte Binary, derselbe Lese-Zug wie in §Kontext) | **Das Binary trägt keinen Bau-abhängigen Wert und den Tag:** die Zuweisungs-Form der Digests — `grep -oaE 'TRAEGER_SHA256[A-Z_]*=[0-9a-f]{64}' <Binary>` → **0** —, die `TRAEGER_TAG`-Zuweisungs-Zeile steht (**1**, value-frei: der Tag ist die Release-Entscheidung, nicht ein gemessener Wert), und bare Treffer der Fetch-Logik sind kein Verstoß — sie tragen Variablennamen ohne Zuweisung, gemessen: **5** solche Namen im eingebetteten Text (`grep -oaE 'TRAEGER_SHA256[A-Z_]*' <Binary> | wc -l`). Die Vorlagen-Sonde (`grep -c 'TRAEGER_SHA256' internal/emit/templates/enforce/traeger.mk` → **0**) bleibt die Vor-Bau-Stufe: die Wand lebt im Binary, und die `v0.2.0`-Vorlage war korrekt, während ihr Binary nicht war (§Kontext) | — |\
| `make test` (bats) | **Der Ziel-Fetch ist fail-closed gegen das Manifest:** eine Abweichung des Assets von seinem `SHA256SUMS`-Eintrag bricht ohne Ablage; der Fehlt-Fall bleibt Exit 0 mit Meldung, die das Fehlende nennt | `make test` |
| `make test` (bats) | **Der Dogfood-Fetch bleibt fail-closed gegen den Makefile-Pin** — zwei Kanäle, unverändert | `make test` |
| `make full-smoke` | **E2E am realen Ziel, unverändert in der Kette, neu im Prüfgegenstand:** frischer Klon ohne Träger → `traeger-fetch` → Manifest-Verifizierung → `archive-welle` läuft | `make full-smoke` |

## Re-Evaluierungs-Trigger

- **Wenn das Release einen Signier-Schritt bekommt**, ist der Kanal-Split neu zu wägen: eine
  Signatur trägt die Herkunft über den Kanal hinaus, und die Manifest-Hälfte der Prüf-Kette
  wäre gegen sie neu zu ordnen.
- **Wenn die Kopplung Makefile↔Manifest driftet** (ein Schnitt, der die Makefile-Digests stehen
  lässt, während die `SHA256SUMS` neue Werte trägt), trägt der Release-Schnitt-Vorgang die
  Kopplung aus Folgepflicht 2 nicht — dann ist er zu verschärfen oder die Kopplung konstruktiv
  zu bauen.
- **Wenn die Emission Netz bekommen soll**
  ([`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) erweitert), ist
  der Stempel aus Alternative B neu zu wägen — die Bootstrap-Ausführung könnte das Manifest
  holen und stempeln; der tragende Grund von Festlegung 4 entfiele.
- **Wenn der Release-Kanal wechselt** (anderer Host, anderer Artefakt-Begriff), ist die Form des
  Manifests und seine Erzeugung im Schnitt neu zu stellen.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-19 | **Proposed** | Architect-Lauf zum `v0.2.1`-Schnitt, ausgelöst durch die Selbstreferenz-Wand: das `v0.2.0`-Binary bettet Digests ein, die nicht zu seinen eigenen Assets passen (Ende-zu-Ende gemessen: Tag-Baum, Asset-Hash, eingebetteter Wert). Die Emissions-Hälfte von [ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 1 wird als Teil-Ablösung gezogen; die Dogfood-Hälfte trägt und bleibt. Der Acceptance-Trigger steht unten |

**Acceptance-Trigger:** Diese Entscheidung wird `Accepted`, wenn eine Reviewer-Runde sie gegen
[ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md),
[ADR-0055](0055-abgeschaffte-kennung-verlaesst-die-fitness-function-als-teil-abloesung.md) und
[`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
auf Konsistenz geprüft hat und ihr Report ohne blockierenden Befund in `docs/reviews/` liegt —
Beleg nach [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md). Bis dahin ist
sie ein Architect-Verdikt und als solches das Übergabe-Artefakt, das der `v0.2.1`-Schnitt als
Constraint liest.

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0059` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).