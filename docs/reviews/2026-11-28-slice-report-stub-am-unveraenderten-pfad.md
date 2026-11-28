# Review — slice-report-stub-am-unveraenderten-pfad (Der Review-Report-Stub am unveränderten Pfad)

**Reviewer-Lauf:** frisch, frischer Kontext (Code nicht selbst geschrieben)
**Diff:** `c701d1bf..9eec64f0` — 7 Implementer-Commits auf dem Move-Commit
`0a77ed09`: Kern LP1–LP3 (`c701d1bf`), Fall 310 am Apparat / Fall 504 entfällt
/ e2e-Deklaration (`2eb492cb`), Schreibzug-Fassung (`74844310`),
Sperren-Probe einzeln (`9fdf0f64`), e2e-Tabellen-Nacherzeugung (`bd51d357`),
Kommentar-Zusagen am Ist (`d17cda6f`, `9eec64f0`).
**Umfang:** `internal/archive/` (anwenden/stub/collect/vorschau + Tests),
`cmd/ai-harness-init/` (Träger + drei Test-Dateien), `internal/emit/`
(Vorlage + Träger + d-check-Fassung), `docs/plan/planning/archive-stub-report.template.md`,
`test/archiv-stub-vorlagen.bats`, `test/mutations/{251,310,504}`,
`harness/tools/full-smoke.sh`, `harness/sensors/archive-welle.md`,
`docs/user/e2e-abdeckung.md`, `.d-check.yml`, Plan-§3 (in `c701d1bf`).
**Gegenstand laut Plan §1/§3:** ADR-0061 Festlegungen 1–3 — Stub am
unveränderten Pfad `docs/reviews/<datei>.md`, repo-eigene Vorlage, Fähigkeit
als Erweiterung (kein neuer Mechanismus); LP3 löst den Report-Anteil der
`[haenger]`-Sperre auf.

**Abgrenzung dieses Reviews:** Code gegen Plan §1/§3/§4/§6 und ADR-0061
(Festlegungen 1–4) / ADR-0033 (Träger) / ADR-0041 Festlegung 4 / ADR-0042
Festlegung 4 / MR-041, MR-071, MR-072, MR-025. DoD-Abhakung, Closure-Notiz,
Register-Fortschreibung und Paarungen sind nicht Teil dieses Berichts
(Modul-10-Grenze).

---

## Findings

Keine HIGH. Kein Rollenwiderspruch-Fall (Modul-8-Konflikt-Pfad läuft nicht
an — der Implementer hat gegen keine ADR und keine Hard Rule gearbeitet).
Zwei MEDIUM, zwei LOW, ein INFO.

### F-1 — MEDIUM

- `kategorie`: MEDIUM
- `quelle`: `AGENTS.md` §3.5 („Eine Ausnahme nennt ihren ganzen Gegenstand“)
  und §3.7 („Ein Kommentar beschreibt, was da ist“); Wächter-Grenze benannt in
  `AGENTS.md` §3.5 (`internal/ausnahmegrund/`)
- `pfad`: `.d-check.yml:6-11` (Kommentar zum `scan.ignore`-Eintrag
  `**/*.template.md`)
- `befund`: Die ergänzte Begründung sagt „Getroffen werden sie unter
  .harness/baseline/ und seit ADR-0061 Festlegung 2 unter
  internal/emit/templates/ — … `git ls-files '*.template.md'` nennt beide
  Baeume“. Am Ist nennt das Kommando **drei** Baum-Wurzeln: neben den beiden
  genannten auch `docs/plan/planning/` — dort liegt die repo-eigene
  Report-Stub-Vorlage des LP1. Die dogfood-Begründung widerspricht damit
  ihrer eigenen emittierten Kopie
  (`internal/emit/templates/d-check.yml`: „Getroffen sind sie unter
  .harness/baseline/ und unter docs/plan/ — die Report-Stub-Vorlage
  (docs/plan/planning/archive-stub-report.template.md, ADR-0061
  Festlegung 2) ...“). Der Wächter
  (`TestRepoKonfiguration_BegruendungNenntJedenBaum`, in `make test`) fängt
  das nicht — gemessen wird nur, ob ein Pfad `docs/plan/` *genannt* wird, und
  das ist er, über die tiefere Nennung eines **anderen** Eintrags desselben
  Blocks (`docs/plan/adr/0013-technik-stratum-als-zielort.md`, Zeile 24);
  die Grenze „prüft … nicht ob sie stimmt“ steht im Kopf von
  `internal/ausnahmegrund/ausnahmegrund.go` und ist hier der Grund.
- `verifizierbar`: ja — `git ls-files '*.template.md' | sed 's|/[^/]*$||' | sort -u`
  → 11 Verzeichnisse über `docs/plan/planning`, `.harness/baseline/v7.0.0/templates…`,
  `internal/emit/templates/planning`; der Wächter läuft grün (belegt).
- `klasse`: „Ausnahme-Begründung zählt den getroffenen Bestand nicht nach —
  der messende Satz (‚nennt beide Bäume‘) ist am Ist falsch, der Wächter
  liest nur die Nennung“

### F-2 — MEDIUM

- `kategorie`: MEDIUM
- `quelle`: Skill „Mehrteilige Regel-Zusage im Kommentar ohne
  Mutations-Deckung je Teil“ · `AGENTS.md` §3.6
- `pfad`: `internal/archive/anwenden.go:330-334` (Kommentar über
  `schreibeReportStubs`)
- `befund`: Der Kommentar am **neuen** Report-Zweig sagt: „FormOK VOR dem
  Schreibzugriff, damit ein form-widriger Report-Stub den Baum nicht erreicht;
  der Lauf bricht zwischen den zwei Commits ab und nennt den Rueckweg.
  Gedeckt von denselben Faellen (TestAnwendenBrichtBeiVerletzterStubFormAb,
  test/mutations/243).“ Die genannten Fälle brechen den form-widrigen Stub
  aber über die **Slice**-Vorlage an —
  `TestAnwendenBrichtBeiVerletzterStubFormAb` füttert
  `archive-stub-slice.template.md` ohne Archiv-Zeiger; der Lauf bricht schon
  in `schreibeStubs`, BEVOR `schreibeReportStubs` überhaupt betreten wird.
  Auch die Fall-Anlage 243 ersetzt die Zeile an beiden Stellen (`sed`-Muster
  ohne Range, `anwenden.go:295` **und** `:346`), das Roten trägt allein die
  Slice-Hälfte. Die FormOK-Verdrahtung am Report-Zweig ist von keinem Test
  und keinem Fall gebunden. Bruchprobe: nur die Report-Zeile (`anwenden.go:346`)
  auf `FormOK(text); false {` gesetzt — `make test-go` bleibt **komplett grün**
  (Protokoll unten). Der Kommentar behauptet eine Deckung, die der genannte
  Fall nicht misst.
- `verifizierbar`: ja — `sed -i '346s/…' internal/archive/anwenden.go` +
  `make test-go` (grün, belegt); umgekehrt greift Fall 243 (MUTATE_CASES
  310/251-Teillauf-Form: `make mutate` mit 251/310 beide ok — 243 nicht im
  Teillauf gefahren, Behauptung geprüft am Sed-Muster, das beide Stellen
  ersetzt).
- `klasse`: „Zusage der Verdrahtung am neuen Zweig ohne eigenen bindenden
  Fall; Kommentar nennt einen Fall, der den Zweig nicht betritt“

### F-3 — LOW

- `kategorie`: LOW
- `quelle`: `AGENTS.md` §3.7 (Kommentar-Klassen — Grenzfahrt)
- `pfad`: `internal/archive/vorschau_test.go:214` (Kommentar über
  `TestAltbestandTraegtKeineReportVerweisSperre`)
- `befund`: Der Kommentar sagt „… am ehemaligen Vorschau-Gegenstand von von
  ADR-0041 Festlegung 4: die Verweis-Sperre **lag immer** ausserhalb der
  Schluesse-Aufhebung …“. „Ehemaliger Gegenstand“ und „lag immer“ beschreiben
  die vorige Fassung — die hält `git`; die geltende Zusage (die Sperren-
  Verdrahtung bleibt stehen, ihre Report-Ziele tragen keinen Fall mehr,
  Herkunfts-Anker `seit ADR-0061 Festlegung 1`) steht daneben und trägt. Der
  Kommentar-Klassen-Anteil ist Chronik, nicht Zustand.
- `verifizierbar`: nein — kein Sensor liest Kommentar-Klassen (benannt in
  `AGENTS.md` §3.7); Träger ist dieser Review.
- `klasse`: „Test-Kommentar trägt Chronik-Anteil neben der geltenden Zusage“

### F-4 — LOW

- `kategorie`: LOW
- `quelle`: Maintainability (latente Wartungsfalle)
- `pfad`: `internal/archive/vorschau.go:129-133` (Grund- und Zeilen-Text der
  `[haenger]`-Sperre in `sperren`)
- `befund`: Die Sperre ist am produktiven Weg unerreichbar — die Vorschau
  übergibt `Haenger(root, dateien, nil, b.Verschwindend())` mit leerer
  Ziel-Menge, der Zweig ist nur über die Test-Kante (`SperrenFuerTest`)
  erreichbar; dass der Wächter als Apparat bleibt, ist im Kommentar über
  `Vorschau` und in der Sensor-Doku (§Grenze Punkt 6) benannt. Der
  Sperren-Text selbst bleibt in der Welt vor ADR-0061 stehen: „ein
  Review-Report soll verschwinden, auf den noch verwiesen wird“ und die
  Beratung „… oder die Referenz im Doku-Gate ausnehmen, mit einer ADR …“.
  Führt eine künftige Klasse wieder echte Ziele an `Haenger` an, meldet die
  einzige je geschriebene Instanz dieses Texts einen Zustand, den der Report-
  Weg überlebt — der Lauf spricht von verschwindenden Reports, wo keine
  verschwinden.
- `verifizierbar`: nein — keine Stufe meldet einen Meldungstext gegen den
  Aufruf; Träger ist der Lauf, der den Zweig beim nächsten Mal anfasst.
- `klasse`: „Apparat-Zweig trägt Meldungs-Text der abgelösten Welt“

### I-1 — INFO

- `kategorie`: INFO
- `quelle`: Maintainability (Rollen-Grenze, transparent)
- `pfad`: `docs/plan/planning/in-progress/slice-report-stub-am-unveraenderten-pfad.md:141-149`
  (Plan-§3 geändert in `c701d1bf`)
- `befund`: Der Implementer-Zug schreibt die Plan-§3-Tabelle um (Makefile-Zeile
  entfällt je ADR-0033 Festlegung 1 „die Logik liegt in internal/archive“,
  Träger-/E2E-/Doku-Zeilen ergänzt) — eine Plan-Korrektur im
  Implementations-Commit statt im Planning-Kontext. Transparent und je Zeile
  gegen den Ist begründet, keine Norm-Fassung berührt; notiert, weil derselbe
  Weg den Plan still mit dem Code kongruent halten könnte, ohne dass der
  Planner die Korrektur je gegen den Plan gelesen hat.
- `verifizierbar`: nein — kein Sensor liest die Rollen-Zugehörigkeit eines
  Plan-Diffs (§3.10-Grenze, benannt).
- `klasse`: „Implementer-Zug schreibt die Plan-Tabelle selbst um (transparent,
  gegen den Ist begründet)“

---

## Bruchproben (Kopie-Pflicht erfüllt: Mutations-Treiber in Isolations-Kopien; Quell-Mutationen mit `git checkout --` zurückgesetzt, kein Rest im Baum)

1. **Festlegung 1 je Zeile — Report-Stub-Zeiger um ein Verzeichnis verbogen.**
   `sed 's|{"<pfad-im-archiv>", review},|{"<pfad-im-archiv>", "warp/" + review},|' internal/archive/anwenden.go`
   → rot: `TestAnwendenSchreibtBeideStubArtenAusDerVorlage`,
   `TestAnwendenSchreibtDenStubEinesBenanntenSlice` (die zwei genannten
   Go-Wächter) und `TestArchiveWelleAltbestandSchreibtDieMengeDerVorschau`
   (der echte Träger-Lauf). Zurückgesetzt. **Kein Befund.**
2. **LP3-Rot-Zug — Hänger-Ziele zurückgeholt.**
   `sed 's|Haenger(root, dateien, nil, b.Verschwindend())|Haenger(root, dateien, b.Reviews, b.Verschwindend())|' internal/archive/vorschau.go`
   → rot je Form, **drei** Wächter: `TestArchiveWelleEchtArchiviertMitReportVerweisAusFremdemRang`,
   `TestVorschauFuehrtKeineReportZieleMehr`, `TestAltbestandTraegtKeineReportVerweisSperre`.
   Deckt die Implementer-Aussage („Hänger-Ziele zurückgeholt … je Faellen rot“).
   Zurückgesetzt. **Kein Befund.**
3. **FormOK am Report-Zweig unwirksam** (F-2-Beweis): Nur `anwenden.go:346`
   auf `false` → `make test-go` grün: `ok  …/internal/archive`, `ok …/cmd/ai-harness-init`,
   alle weiteren Pakete ok. Zurückgesetzt. **Befund F-2.**
4. **Mutations-Fälle über make** — `MUTATE_CASES='310-…mit-auf 251-…suchraum-leer' make mutate`
   → `2 ok, 0 Befund(e)`: 310 → `TestAltbestandBehaeltHaengerSperre` rot
   (Anker über der echten `sperren`-Quelle, Listenaufbau über der Test-Kante —
   Apparat-Form in der Sensor-Doku benannt), 251 →
   `TestArchiveWelleEchtArchiviertMitReportVerweisAusFremdemRang` rot.
   **Kein Befund.**
5. **Exklusivitäts-Gegenprobe zum geänderten Fall 251** (Skill-Pflicht): die
   Fall-Mutation manuell angewandt → **genau ein** Test färbt (der benannte);
   `t.Skip`-Gegenprobe entfällt — der Fall färbt exklusiv, trägt ein eigenes
   Rot (die neue Eigenschaft, der Report-Verweis aus Rang 1 überlebt den
   Lauf am Stub). Zurückgesetzt. **Kein Befund.**

## Sensoren und Messungen

- `make test-go` (Baseline) → Exit 0, alle Pakete ok (`make test-go`, Protokoll
  oben unter Bruchprobe 3).
- `make test-bats BATS_TARGET=test/archiv-stub-vorlagen.bats` → 6/6 ok
  (drei Vorlagen-Orte, Byte-Gleichheit repo-eigen ↔ mitgetragen,
  Block→Vorlage-Zuordnung je Block, Form-Zusatz „H1, Archiv-Zeiger,
  Feld-Block“).
- `make mutate MUTATE_CASES='310-… 251-…'` → 2 ok / 0 Befunde (Bruchprobe 4).
- `make host-bin` + `.harness/state/bin/ai-harness-init archive-welle --vorschau altbestand`
  am realem Bestand, Exit 0: `Sperren: keine — der schreibende Lauf liefe.`;
  `Verweise: 315 Datei(en) betroffen (1015 Praefix-, 29 geschwister-relative,
  0 aufsteigende Fundstelle(n))`; `Review-Reports (mit Stub): 399`;
  `wellenlos …: 239`. Der 107er-Befund (Report-Anteil) ist am Bestand
  aufgelöst — die Sperre trägt keinen Report-Ziel-Fall mehr, die übrige
  Verweis-Luft (bewegte Slice-/Welle-Ziele des Altbestand-Laufs) bleibt je
  Quelle sichtbar ohne still Einschreiben (LP3-Form, gemessen).
- `make gates` (einmal am Ende, vor dem Report-Commit) → Exit 0.

## Geprüft, ohne Befund

- **Festlegung 1 (Stub am unveränderten Pfad) je Zeile** — `reportStub`/
  `schreibeReportStubs` schreiben an `docs/reviews/<datei>.md` ohne Weg; je
  Go-Wächter (TestAnwendenSchreibtDenStubEinesBenanntenSlice,
  TestArchiveWelleEchtArchiviertMitReportVerweisAusFremdemRang,
  TestArchiveWelleAltbestandSchreibtDieMengeDerVorschau) je Bruchprobe
  gefahren (oben 1 und 2); Staging je geänderte Datei im aufgezaehlten
  `ZuStagen` (Fall-241-Mechanik bleibt). Kein Befund.
- **Festlegung 3 (Zip voll, Reihenfolge Zip → Rückleseprobe → Stubs) und die
  3-Operationen-Schnittstelle** — die Zip-Fassung schreibt, BEVOR
  Stub-Emission oder Report-Kürzung; ein defektes Zip bricht VOR der Kürzung
  (`TestAnwendenBrichtVorDemKuerzenAb`: Report bleibt in der Probe Volltext,
  kein `add`, kein Commit 2); die Probe vergleicht das Zip byte-gleich gegen
  die Quellen **einschließlich** der Reports. `Rm` aus dem `Git`-Interface und
  aus allen vier Test-Verdrahtungen entfernt; drei statt vier schreibende
  Aufrufe, Grenze („Add/Commit … nur ihr Zusammenspiel“) im
  Träger-Kommentar gegen den Ist-gezogen (`d17cda6f`). Kein Befund.
- **Festlegung 2/LP1 (repo-eigene Vorlage, Bootstrap-Träger, Byte-Gleichheit
  der zwei Fäßer)** — Vorlage liegt repo-eigen; `cmp` byte-gleich zur
  mitgetragenen (bats-Fall 3, grün); Bootstrap trägt sie skip-if-present in
  `docs/plan/planning/` (emittierte-Baum-Tests der zwei Fassungen ergänzt);
  ohne Vorlage bricht `AusVorlage` mit „Vorlage fehlt“ (fail-closed, dieselbe
  Setzung wie bei den zwei vendored). Kein Befund.
- **Fall-Entfall-Fassung (504 gelöscht, 310 am Apparat)** — die Begründung
  folgt dem Objekt (der schreibende Lauf liest dieselbe Liste, deren
  Report-Fall entfällt); die Fall-Anlage 310 bindet die Sperren-Verdrahtung
  am Quell-Satz (`if len(haenger) > 0 {`), nicht an einem Stellvertreter
  (MR-071-Form am Test-Kanten-Anker benannt). Kein Befund.
- **e2e-Deklaration und `full-smoke`-Stufe** — die Deklaration nennt, was die
  Stufe misst (Report-Stub am Pfad + Verweis aus `bleibt.md` löst unverändert
  auf; kein `[haenger]`-Auslöser mehr), der Lauf-Code misst beide; Sperren-
  Probe einzeln statt über ein Ein-Wort-Loop (SC2041-Zug gelesen). Kein Befund.
- **Doku-Update des öffentlichen Verlags** — `main.go`-Hilfe und
  `harness/sensors/archive-welle.md` §Vertrag/§Grenze Punkt 4/6 nennen den
  Stub am unveränderten Pfad statt der Löschung, halten Herkunfts-Anker je
  `ADR-0061` und die Zahl 107 am Messdatum. Kein Befund.
- **Kein Nachzug, kein Ventil, ADR unverändert** — kein `ignore-refs`-Paar
  neu; keine der 399 Report-Verweis-Adressen wird vom Code umgeschrieben
  (`Bewegte()` enthält Reports nie — geprüft Alt/Neu); ADR-0061,
  ADR-0041, ADR-0042 bleiben im Range unberührt. Kein Befund.
- **Gelesen, nicht gefahren:** die Formen-Probe der 3-Orte-Aufzählung in
  `test/archiv-stub-vorlagen.bats` (kein Fall für eine Vorlage an einem
  dritten Ort — die Aufzählung ist der laut-fallende Rückweg, kein
  erkennendes Muster); die Exklusivität von Fall 310 (nur 251 ist geändert
  und darum pflichtig).
