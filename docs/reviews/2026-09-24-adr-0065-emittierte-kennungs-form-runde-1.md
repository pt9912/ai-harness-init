# Review-Report: ADR-0065 (emittierte Kennungs-Form folgt dem Regelwerk), Runde 1 — 2026-09-24

**Review-Art:** Design — Erstrunde eines Design-Reviews einer `Proposed`-ADR gegen das Regelwerk `v6.9.0`
(Original, nicht Zusammenfassung), gegen `ADR-0007`, `ADR-0053`, `ADR-0054`, `MR-054`, `MR-055`, `MR-057`,
`MR-032`, `MR-046`, `LH-QA-02`, `LH-FA-01` und gegen den Baum. Das ist die Reviewer-Runde, die der
Acceptance-Trigger der ADR verlangt.

**Gegenstand:** Commit `f1b3da6f` (lokal, nicht gepusht) —
`docs/plan/adr/0065-emittierte-kennungs-form-folgt-dem-regelwerk.md`, die Index-Zeile in
`docs/plan/adr/README.md` und die Kopf-Marke an
`harness/conventions/MR-057-kennungs-form-fuer-neue-slices-und-wellen-ist-der-name.md`.

**Rolle:** Reviewer, frischer Kontext. Keine Einschätzung des Architects wurde ungeprüft übernommen; jede
Messung der ADR, die sich fahren ließ, ist nachgefahren (§Messungen).

**Belegt am HEAD:** `make host-bin` baut aus dem Baum ein Binär mit demselben sha256 wie das vorhandene
`.harness/state/bin/ai-harness-init` (`b8d5c9b9…f83b2`); alle Emit-Läufe unten fuhren dieses Binär in
Scratchpad-Kopien, nichts im Repo.

## Gesamturteil

**Nach Korrektur.** Kein HIGH. Die Substanz der Festlegungen 1, 2(a), 3 und 5 trägt und ist am frischen
Ziel reproduzierbar grün; vier MEDIUM betreffen aber Zusagen, die die ADR macht und der Baum nicht hält
(Commit-Menge, Festlegung 4 gegen 5, „kein Ausweg in den Spec-Straten", die Begründung von 2(b)).

**Acceptance-Trigger.** Der Wortlaut in der ADR ist *„`Accepted` setzt der Auftraggeber nach einer
Reviewer-Runde über Kontext und Festlegungen"*. Die Formel „ohne blockierenden Befund an der Substanz"
steht in dieser ADR **nicht** (sie steht in `ADR-0064`). Nach dem Wortlaut der ADR ist der Trigger mit
dieser Runde erfüllt, unabhängig von ihren Befunden; im Sinn der Nachfrage („ohne blockierenden Befund an
der Substanz") ist er es **nicht sicher**: es gibt keinen HIGH, aber vier MEDIUM, die an der Substanz der
Festlegungen 2(b), 4 und 5 hängen und vor `Accepted` zu entscheiden sind (siehe F-8 zur Trigger-Form).
Die Annahme bleibt beim Auftraggeber.

## Findings

### F-1 — MEDIUM — Die Commit-Menge nimmt jede Zeichenfolge `slice-<Wort>` als Kennung an; die Fehl-Akzeptanz steht nirgends

- `kategorie`: MEDIUM · `quelle`: ADR-0053 Festlegung 4 (offene Lücke), `AGENTS.md` §3.6, Reviewer-Skill
  „Stilles-Grün-Pfad in einem Gate-Skript" (Kontext-Eskalation nicht angewandt: Festlegung, nicht Code)
- `pfad`: `docs/plan/adr/0065-…md:150-156` (Festlegung 4), `:189`, `:201`; `harness/README.md` §Traceability
  (Tabellenzeile „Commit aus einem Repo-Werkzeug")
- `befund`: Die Menge nimmt `slice-`/`welle-` „mit Namen **oder** Nummer" an; ein Werkzeug-Betreff wie
  `slice-mv: …` trägt das Präfix und geht durch, ohne dass eine Kennung im Sinn von §Vergabe darin steht.
  Gemessen am Bestand: `git log --format=%s | grep -c '^slice-mv:'` → **608**, davon ohne Kennung nach der
  heutigen Menge `grep -vcE 'ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+'` → **190** — alle
  190 würden die neue Prüfung passieren. Die ADR benennt als Kosten des Präfixes nur den **Fehlalarm** der
  Matrix; die Fehl-Akzeptanz im Commit-Pfad (die entgegengesetzte Richtung) fehlt in Konsequenzen, Grenze
  und Fitness Function. Die Annahme-Liste führt `slice-mv-verweise` (ein Name, der mit dem Werkzeug-Namen
  beginnt) und keine Ablehnung für `slice-mv:`. Die Tabellenzeile in `harness/README.md`, die diese Commits
  als „am Träger brechend" beschreibt, wird mit der Dogfood-Fassung unwahr.
- `verifizierbar`: ja — `make test` (bats gegen die Prüfung) mit einem Fall `slice-mv: …` ohne weitere
  Kennung
- `klasse`: Präfix-Muster erweitert die Akzeptanz-Menge eines Anwesenheits-Gates, Gegenrichtung des
  Fehlalarms nicht benannt

### F-2 — MEDIUM — Festlegung 5 („die eigene `.d-check.yml` zieht nicht mit") widerspricht Festlegung 4 („Dogfood-Fassung zieht mit")

- `kategorie`: MEDIUM · `quelle`: ADR-0053 (Träger am Commit), `MR-051`/`AGENTS.md` §3.1 (keine
  unbelegte Zusage)
- `pfad`: `docs/plan/adr/0065-…md:156-158`, `:165-168`; `test/commit-msg-hook.bats:141-157`;
  `.d-check.yml:484-490`
- `befund`: Der bats-Fall `kopplung: Traeger und Config tragen dieselbe Muster-Menge` verlangt
  **Mengen-Gleichheit** zwischen `patterns=` der Dogfood-Prüfung und `commits.id-patterns` der eigenen
  `.d-check.yml`. Ändert Festlegung 4 die Dogfood-Menge, färbt der Fall rot, sofern nicht auch der
  `commits:`-Block der eigenen Konfiguration wandert — das Gegenteil von Festlegung 5, die die Kopplung in
  Festlegung 4 sogar selbst nennt („hält die dritte"). Der `commits`-Block liest zudem die Historie
  (Grenze der Werkzeug-Ebene), die Wirkung des Wechsels auf den Bestand (siehe F-1) ist nicht benannt.
- `verifizierbar`: ja — `make test`
- `klasse`: Reichweite-Aussage schneidet eine gekoppelte Konfiguration ab

### F-3 — MEDIUM — „In den Spec-Straten gibt es keinen Ausweg" gilt für das Regelwerk, nicht für die emittierte Konfiguration

- `kategorie`: MEDIUM · `quelle`: `grundlagen-referenz-richtung.md` §Prüfung (*„ohne ausgenommene Sektion"*,
  Marker nur „ehrlich" gesetzt), `LH-QA-01`
- `pfad`: `docs/plan/adr/0065-…md:117-120`, `:189`, `:201`, Grenze `:209-214`
- `befund`: Am frisch emittierten Ziel (Präfix-Token, Regel `spec-straten → welle` gesetzt) meldet
  `spec/spezifikation.md` mit dem Wort `slice-mv` und `welle-cache-warmup` **2 Befunde**, und die Meldung
  selbst empfiehlt den Marker (`Provenance via <!-- d-check:status-provenance --> deklarieren`). Setzt man
  den Marker ans Zeilenende in der Spec, ist die Zeile **0 Befunde**: der Marker ist auch mit einem
  Spec-Stratum als Quellklasse wirksam. Der Ausweg, den die ADR verneint, besteht also mechanisch; das
  Regelwerk nennt seine Nutzung dort ein Umgehen (*„hat die Regel nicht erfüllt, sondern umgangen"*). Die
  Grenze führt nur „der Marker ist nicht Ziel-spezifisch" für ADR → Welle und nicht diese Lücke; die
  Zusage „kein Ausweg" trägt am emittierten Gate nichts.
- `verifizierbar`: ja — reproduziert am Scratchpad-Ziel (§Messungen, G1/G2)
- `klasse`: Zusage über eine Grenze, die das Werkzeug nicht hält

### F-4 — MEDIUM — Die Begründung von 2(b) trägt Dogfood-Normen in die emittierte Ebene, und die Regel färbt das Regelwerk-konforme Muster rot

- `kategorie`: MEDIUM · `quelle`: `AGENTS.md` §3.8/§3.11 (Geltungsbereich „dieses Repo"),
  `grundlagen-traceability.md` §Herkunfts-Anker, Dogfood-vs-emittiert
- `pfad`: `docs/plan/adr/0065-…md:125-132`, `:190-192`
- `befund`: Die Erweiterung wird aus `AGENTS.md` §3.8 (Block „normativ wie eine ADR") und §3.11 (Adressen in
  einfrierenden Artefakten) begründet. Beide Regeln gelten „dieses Repo"; die emittierte `AGENTS.md`
  trägt weder §3.8 noch §3.11 (gemessen: `grep -nE '3\.8|3\.11' AGENTS.md` am Ziel → 0 Treffer, sie führt
  nur eine Regel „ADRs sind nach `Accepted` immutable") und die emittierte `conventions.md` sagt nichts
  über nachträgliche Änderung. Für ein Ziel steht der Grund also nicht da, aus dem die Regel entsteht.
  Zugleich sagt das Regelwerk, der Adaptions-Block „trägt das Muster bereits über sein Feld *Begründung*"
  (`seit slice-<Kennung>`): jeder Eintrag, der das Muster so führt, wie das Regelwerk es beschreibt, ist mit
  den zwei neuen Regeln rot, bis der Adopter jede Zeile einzeln markiert. Das ist die Kostenlage von
  Option D, die die ADR gerade wegen dieser Kosten verwirft; Option F verschiebt sie auf den Marker je
  Zeile. „Erlaubt ausdrücklich" in 2(b) überzieht die Stelle („trägt bereits").
- `verifizierbar`: nein (Begründungsfrage); die Rotfärbung ist mechanisch belegt (§Messungen, C)
- `klasse`: Norm des eigenen Repos als Grund für einen emittierten Vertrag

### F-5 — LOW — Ein Messinstrument der ADR ist blind: `grep -rniE 'adaptionsblock'` → 0

- `kategorie`: LOW · `quelle`: `AGENTS.md` §3.6 (Instrument), `MR-055`
- `pfad`: `docs/plan/adr/0065-…md:52`, `:56-58`
- `befund`: Das Regelwerk schreibt „Adaptions-Block" mit Bindestrich: `grep -rniE 'adaptions-?block'
  .harness/baseline/v6.9.0 | wc -l` → **26**, `adaptionsblock` (ADR-Schreibweise) → **0**. Die
  Null ist damit bei jeder Lage null und trägt die Aussage nicht. Die Aussage selbst stimmt, aber aus
  anderem Grund: die Matrix-Tabelle führt keinen Block als Zeile oder Spalte (`grundlagen-referenz-richtung.md`
  nennt ihn einmal, Z. 343, als Ort der Stratum-Deklaration).
- `verifizierbar`: ja
- `klasse`: Zählung mit einer Schreibweise, die das Original nicht führt

### F-6 — LOW — Zuschreibungen ans Regelwerk, die enger oder weiter reichen als die Stelle

- `kategorie`: LOW · `quelle`: `grundlagen-referenz-richtung.md`, `.harness/baseline/v6.9.0/templates/.d-check.yml`
- `pfad`: `docs/plan/adr/0065-…md:77-79`, `:113-115`
- `befund`: (a) *„wörtlich der Gate-Text"* für `welle-`: der Gate-Text nennt `ADR-` und `slice-`, nicht
  `welle-`; `welle-` folgt aus der Matrix-Spalte, nicht aus dem Gate-Text. (b) *„bildet die dortige Setzung
  nur ab"* steht in der Vorlage am Satz über `exclude-sections`, nicht über die Token; als Quelle für
  „Text vor Vorlage" trägt sie nur den Analogieschluss. (c) Der Selbstwiderspruch des Regelwerks ist
  größer als die ADR sagt: `conventions.template.md` führt auch `slice-<KUERZEL>-NNN` und verlangt für
  `slice-*`/`welle-*` bei mehreren Schreibern ein Bereichssegment, während §Vergabe die Namens-Form
  „unabhängig von der Schreiberzahl" setzt. Die wörtlichen Zitate der ADR stimmen (geprüft: *„Welle- und
  Slice-Kennungen sind Namen, nicht Nummern"*, *„Welche Form gilt, deklariert das Repo"*, *„enthält `ADR-`
  oder `slice-` → fail, ohne ausgenommene Sektion"*, *„bewusst nur die grep-Variante"*, *„die Ausnahme wird
  am Ort deklariert"*).
- `verifizierbar`: ja
- `klasse`: Zuschreibung überzieht die zitierte Stelle

### F-7 — LOW — Die Messung des grünen Starts liest eine andere Stelle als die, die das Ziel bekommt

- `kategorie`: LOW · `quelle`: `MR-055`, `MR-054` Setzung 1 Kriterium 2
- `pfad`: `docs/plan/adr/0065-…md:81-87`
- `befund`: `cat .harness/baseline/v6.9.0/templates/spec/*.md | grep -cE '(slice|welle)-'` → 0 liest die
  Vorlagen des Regelwerks; das Ziel bekommt die emittierten Spec-Dateien, die von den Vorlagen abweichen
  (`diff -q` an allen drei Dateien: verschieden). Das Ergebnis stimmt trotzdem (emittiert: 0 Treffer, am
  Ziel 0 Befunde, sprach-agnostisch und `--lang go --arch hexslice`), aber die ADR stützt sich auf die
  falsche Stelle. `--lang cpp` und die übrigen Sprachen habe ich nicht gefahren.
- `verifizierbar`: ja
- `klasse`: Messung liest Vorlage statt emittiertem Bestand

### F-8 — LOW — Acceptance-Trigger ohne „ohne blockierenden Befund"

- `kategorie`: LOW · `quelle`: `ADR-0040`, Vergleich `ADR-0064` §Der Acceptance-Trigger
- `pfad`: `docs/plan/adr/0065-…md:247-248`
- `befund`: Der Trigger verlangt *„eine Reviewer-Runde"*; er nennt weder die Bedingung „Report ohne
  blockierenden Befund" noch den Beleg, den die Accept-Zeile tragen soll. Ein Report mit HIGH erfüllte ihn
  nach dem Wortlaut. `ADR-0040` verlangt, dass der Trigger den Beleg benennt, den der Accept-Übergang
  nennt.
- `verifizierbar`: nein
- `klasse`: Acceptance-Trigger ohne Beleg-Form

### F-9 — LOW — Kopf-Marke an `MR-057`: kein Präzedenzfall, Ziel ist eine `Proposed`-ADR

- `kategorie`: LOW · `quelle`: `MR-032` Setzung 1/3, `MR-046`, `MR-057` §Geltungsbereich
- `pfad`: `harness/conventions/MR-057-…md:5`, `:16`, `:106-108`
- `befund`: `MR-032` bindet die Form auf einen Eintrag, dessen Aussage ein späterer **Eintrag** ablöst, und
  nennt als `<Ziel>` die Anker-Adresse des ablösenden Eintrags; hier zeigt die Marke mit einem Pfad auf
  eine ADR (ortsfest, §3.11 unberührt), die noch `Proposed` ist. Bliebe die ADR unangenommen, stünde
  `ÜBERHOLT` auf einen Nachfolger, den es nicht gibt. Außerdem sagt der Geltungsbereich von `MR-057`
  weiter, was ein Zielrepo an Form bekomme, *„entscheidet der Slice, der die Tool-Ebene entscheidet"*;
  die Marke lässt den Geltungsbereich „unberührt". Die ADR behauptet die Form „nach `MR-032`", ohne zu
  sagen, dass es dafür keinen Präzedenzfall gibt. Die Marke trägt sonst nur die Aussage, die die ADR
  ihr zuschreibt: Setzungen 1 bis 3, Geltungsbereich und Trigger bleiben unberührt (gelesen).
- `verifizierbar`: nein
- `klasse`: Kopf-Marke ohne Norm-Grundlage für den Zieltyp

### F-10 — LOW — „Nicht Gegenstand: Werkzeug-Nachzüge für benannte Slices in `slice-mv` und im Archiv-Stub"

- `kategorie`: LOW · `quelle`: `MR-057` §Grenze, `MR-025`/`MR-033`
- `pfad`: `docs/plan/adr/0065-…md:220-223`
- `befund`: Die ADR beruft sich auf den Grenz-Satz aus `MR-057`, dessen Kommando
  (`git grep -lE 'slice-(\[0-9\]|\\d)' -- harness/tools internal cmd Makefile d-check.mk ':!internal/emit'`)
  am HEAD nur noch `harness/tools/commit-msg-traceability.sh` nennt, nicht mehr `slice-mv.sh` und
  `internal/archive/stub.go`. Der Zustand ist gemischt: `internal/emit/templates/enforce/slice-mv.sh` und
  `sliceRE` im Archiv kennen benannte Kennungen, `kennungRE` (`internal/archive/stub.go:149`) streift
  eine Titel-Kennung nur in Ziffernform. Was die ADR als offen ausschließt, ist nicht gemessen; für das
  Ziel ist es relevant, weil `make slice-mv` und `make archive-welle` emittiert werden, während die
  Voreinstellung die Namens-Form ist.
- `verifizierbar`: ja
- `klasse`: Ausschluss stützt sich auf einen ungemessenen Zustand

### F-11 — LOW — Vollständigkeit der Zell-Prüfung: nicht alle ❌-Zellen der Matrix haben eine Regel, und die Grenze nennt nur die Spec-Zeilen

- `kategorie`: LOW · `quelle`: `grundlagen-referenz-richtung.md` Matrix-Tabelle, ADR-Beleg-Pflicht 6(i)
- `pfad`: `docs/plan/adr/0065-…md:60-70`, `:212-214`
- `befund`: Die Tabelle setzt zusätzlich ADR → Carveout, ADR → Roadmap und Slice → Roadmap auf ❌; keine
  Regel der Vorlage nach der ADR deckt sie (`aussen` ist Quelle-frei für `adr` und `slice`, und darf es sein:
  die ADR-Zeile linkt legitim in Code und `harness/`). Die Grenze spricht nur über die Spec-Zeilen.
  Bestätigt ist, was sie dort sagt: am Ziel fängt `aussen` einen **Link** auf `docs/plan/carveouts/…` und
  auf `docs/plan/planning/in-progress/roadmap.md` (Roadmap liegt unter keiner Klassen-Glob und fällt
  First-Match an `aussen`); eine blanke `CO-001` und ein Pfad im Code-Span fängt niemand.
- `verifizierbar`: ja
- `klasse`: Grenzen-Aussage enger als die Lücke

### F-12 — LOW — Die Commit-Menge ist in Prosa formuliert, und die Prosa ist an zwei Stellen unvereinbar mit ihrer Ablehnungs-Liste und dem Regelwerk-Muster

- `kategorie`: LOW · `quelle`: `grundlagen-source-precedence.md` §ID-Schema, `grundlagen-traceability.md`
- `pfad`: `docs/plan/adr/0065-…md:149-156`, `:144`
- `befund`: „Großbuchstaben-Präfix, ein bis mehrere Segmente, zwei bis vier Ziffern" lässt nach dem
  Wortlaut `SHA-256` zu (Präfix, eine Ziffernfolge), obwohl die Liste es ablehnt; das Muster in Z. 144
  (`<PREFIX>-[A-Z]{2}(-[A-Z]+)?-\d{2,3}`) lehnt es ab und führt 2–3 statt 2–4 Ziffern; es lehnt außerdem
  `HSM-LESE-004` ab, das Beispiel in §ID-Schema. Die ADR gibt keinen ERE. Das freie Präfix nimmt jede
  Form `AAA-XX-NN` an (`AES-CB-128`). Das Weglassen von `SPEC-`/`ARC-` ist vom Regelwerk gedeckt
  (*„Die Klammer trägt die Anforderungs-ID, nicht jede Kennung"*), die ADR zitiert die Stelle nicht;
  `MR-`, `CO-`, `slice-`, `welle-` in der Commit-Menge sind dagegen Setzung dieses Repos (das Regelwerk
  nennt „die Anforderung und die ADR-Nummer") — das trägt der Titel „folgt dem Regelwerk" nicht ohne
  Einschränkung.
- `verifizierbar`: ja — `make test` mit den Annahme-/Ablehnungs-Fällen
- `klasse`: Muster in Prosa, nicht als prüfbare Form

### F-13 — LOW — Der Nachzug bestehender Ziele bekommt die Neutralisierung nicht mit

- `kategorie`: LOW · `quelle`: `ADR-0007` Festlegung 3 (`harness/conventions.md` und `.d-check.yml`
  beide skip-if-present)
- `pfad`: `docs/plan/adr/0065-…md:160-164`
- `befund`: Ein bestehendes Ziel, das die Regeln aus 2(b) nach der Positions-Liste per Handarbeit übernimmt,
  hat den ursprünglichen `harness/conventions.md` mit den vier Platzhalter-Zeilen und dem Emitter-Satz
  ohne Marker (skip-if-present); es färbt sofort rot. Ob die Positions-Liste diese Vorbedingung nennen wird,
  legt die ADR nicht fest. Und die Prüfung wird bei bestehenden Zielen stillschweigend um die Fehl-Akzeptanz
  aus F-1 erweitert, in Konsequenzen steht nur die Konfigurations-Differenz.
- `verifizierbar`: nein
- `klasse`: Reichweite nennt die Nebenwirkung der konvergenten Hälfte nicht

### F-14 — INFO — Die Fitness Function ist mit der Repo-Konvention formulierbar

- `befund`: Der Aufbau hat Vorbilder: `test/mutations/295-…`, `297-…`, `298-…`, `372-…`, `374-…`, `375-…`
  greifen bereits die emittierte Matrix an; `failure_form()` in `harness/tools/mutate.sh` kennt `test`,
  `test-go`, `test-bats` und `full-smoke`. Nicht formuliert in der ADR, aber für den Slice nötig: je ein
  Schwächungs-Fall, unter dem das Gegenbeispiel grün würde (Präfix wieder Ziffern-Form; Welle-Regel gestrichen;
  Marker ohne Wirkung als Quellklasse; Commit-Menge ohne Namens-Alternative), und der Fall für F-1. Eine
  `full-smoke`-Stufe braucht ihre Kopfzeile, sonst fällt sie aus der `make e2e-abdeckung`-Sicht.
  Ein Wert, den erst der erste reale Lauf zeigt, ist in der Grenze nicht benannt: die Meldung des Werkzeugs
  an einem `--lang`-Ziel außer `go` (siehe F-7).

## Messungen (nachgefahren)

Alle am Binär des HEAD, in `/tmp/claude-1000/-Development-KI-ai-harness-init/b6fa9e1c-542b-49f2-a93d-7f2eb8905fec/scratchpad/t1`
(sprach-agnostisch) und `…/t2` (`--lang go --arch hexslice`); `make docs-check` am Ziel, Image
`ghcr.io/pt9912/d-check@sha256:3f84502b…`.

| Zusage der ADR | Ergebnis |
|---|---|
| Z. 53/54 der emittierten Vorlage tragen `slice-\d{3}`/`welle-\d{2}` | bestätigt (`grep -nE "token: '(slice\|welle)-"`) |
| unveränderte Vorlage, frisches Ziel | `20 Datei(en) geprüft, 0 Befund(e)` |
| B: Präfix-Token + `spec-straten → welle` | 0 Befunde, sprach-agnostisch und `go`/`hexslice` |
| C: + `adaptionsblock → slice/welle` | **6 Befunde in 5 Zeilen** (`harness/conventions.md` Z. 124, 162, 167 (zwei), 204, 212); 4 aus der Vorlage, 1 aus dem Emitter-Satz mit `make slice-mv` — bestätigt |
| D: Marker an diesen 5 Zeilen | 0 Befunde: der Marker wirkt mit dem Block als Quellklasse (2(c) ist am Baum schon erfüllbar) |
| E: `ADR-([A-Z]+-)?\d{4}` + Glob `[A-Z]*-[0-9]*.md`, Datei `IDX-0004-x.md`, Link `ADR-IDX-0004` | 0 Befunde; die Glob-Erweiterung ändert die Klassifikation der Datei (Quelle für `adr → …`, Meldung `→ adr` statt `→ aussen`), nicht ob ein Link aus der Spec rot wird; blank `ADR-IDX-0004` → `id-unlinked` |
| G: Spec mit `slice-mv`/`welle-cache-warmup` | 2 Befunde; mit Marker am Zeilenende **0** (F-3) |
| G3: Spec mit blanker `CO-001`, Roadmap-Pfad im Text, Links auf Carveout-/Roadmap-Ort | nur die Links werden gefangen (`→ aussen`) |
| Dogfood: `grep -cE '(^\|[^A-Za-z-])slice-[a-z0-9]' harness/conventions.md harness/conventions/*.md harness/conventions/done/*.md` | Summe **113** in **54** Dateien — bestätigt |
| Lastenheft: `grep -cE '(slice\|welle)-'` / `grep -c 'slice-lokal'` | **10** / **1**, neun der zehn ab Z. 539 in §7 (beginnt Z. 532) — bestätigt |
| eigene `.d-check.yml`: `name: (welle\|adaptionsblock)` in `matrix:` | **0**, Klasse `slice` ohne `token:` — bestätigt |
| `grep -ci 'zielrepo' harness/migration.md` | **0** — bestätigt |
| zweiter Lauf am Ziel, angehängte Adopter-Zeile | bleibt stehen; die Ausgabe nennt `.githooks/commit-msg`, nicht `.d-check.yml` — bestätigt |
| `grep -rniE 'adaptionsblock' .harness/baseline/v6.9.0 \| wc -l` | **0**, aber leer aussagend (F-5): `adaptions-?block` → 26 |

## Geprüft, ohne Befund

- **Zitate und Zuschreibungen am Original:** `grundlagen-referenz-richtung.md` (Matrix, Prüfung, „umgekehrter
  Default", Regel 5), `grundlagen-source-precedence.md` (ID-Schema, Vergabe), `grundlagen-traceability.md`:
  alle wörtlichen Zitate stimmen (Liste in F-6). „Präfix-Treffer in Kauf nehmen" steht **nicht** im
  Regelwerk; die ADR schreibt es in Festlegung 1 ausdrücklich als eigene Setzung aus (*„Das Regelwerk sagt
  über den Fehlalarm nichts; diese Festlegung nimmt ihn nicht aus."*) — das trägt.
- **Matrix-Zeilen:** `Welle` ist in allen drei Straten-Zeilen ❌, `spec-straten → welle` fehlt heute und
  greift nicht über `aussen` (Klassen-Reihenfolge, First-Match) — bestätigt. ADR → Welle ❌ ohne Ausnahme im
  Regelwerk, der Marker nimmt sie in der Emission trotzdem aus, und die Grenze sagt das.
- **Präfix als Obermenge:** `slice-\d{3}` und `welle-\d{2}` sind Teilmengen von `slice-` und `welle-`.
- **Adaptions-Block als Quellklasse:** die Klasse `adaptionsblock` besteht (Quelle nur aus `spec-straten`),
  der Marker wirkt (D).
- **ADR-0007 Festlegung 3:** `.d-check.yml` und `harness/conventions.md` skip-if-present — stimmt. **ADR-0054
  Festlegung 1:** Prüfung konvergent, Träger skip-if-present — „bestehende Ziele bekommen die Prüfung"
  passt (Nebenwirkung F-13).
- **`docs/plan/adr/README.md`:** Zeile 0065 vorhanden, Status `Proposed`, Bezüge nur Kennungen, Anker
  auflösbar. Vorlagen-Gliederung: die obersten `##`-Abschnitte sind die der Vorlage; `Grenze` steht als
  `###` unter `Konsequenzen` (die Abweichung aus dem Review zu ADR-0064 tritt nicht auf).
- **Ablage-Regeln:** die ADR nennt den Bestands-Slice `slice-werkzeug-commits-tragen-eine-kennung` nicht
  (`grep -c` → 0), trägt keine Slice-Kennung als Adresse, keine Pfad-Adresse auf ein wanderndes Artefakt
  (§3.11); Zeilen mit Zahl tragen ihr Kommando (`MR-025`), der Tag `v6.9.0` steht (`MR-033`).
- **Commit-Erweiterung der Dogfood-Fassung:** die zwei Fassungen (`internal/emit/templates/enforce/…` und
  `harness/tools/…`) tragen heute dieselbe `patterns=`-Zeile — bestätigt.
- **`MR-063`:** betrifft Gegenmessungen bei d-check-Pin-Sprüngen; hier nicht einschlägig.
- **`MR-057` selbst:** die Marke ändert kein Zeichen des Rumpfs; die Setzungen 1 bis 3 bleiben unberührt.
- **Schreib-Grenzen:** `git show --stat f1b3da6f` berührt nur ADR, ADR-Index und einen MR (Architect-Artefakte,
  Rolle in der Message, §3.8); kein Code, kein Slice, keine ADR verändert.

## Zeilen für den Steering-Loop-Zähler

- Präfix-Muster erweitert die Akzeptanz-Menge eines Anwesenheits-Gates, Gegenrichtung des Fehlalarms nicht benannt (F-1)
- Zusage über eine Grenze, die das Werkzeug nicht hält (F-3)
- Norm des eigenen Repos als Grund für einen emittierten Vertrag (F-4)
- Zählung mit einer Schreibweise, die das Original nicht führt (F-5)
- Messung liest Vorlage statt emittiertem Bestand (F-7)
