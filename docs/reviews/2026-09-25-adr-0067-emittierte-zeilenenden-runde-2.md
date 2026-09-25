# Review — ADR-0067 (Zeilenenden der emittierten Dateien), Runde 2

**Gegenstand:** `docs/plan/adr/0067-emittierte-zeilenenden-ein-attribut-je-verzeichnis-mit-interpreter-konsument.md`
(Status `Proposed`), Diff `94498b1f..3c74c101` über `docs/plan/adr/` — Architect-Commit `3c74c101`, der die
Befunde aus `docs/reviews/2026-09-25-adr-0067-emittierte-zeilenenden-runde-1.md` einarbeitet (die ADR und die
Index-Zeile in `docs/plan/adr/README.md`).

**Rolle / Skill:** Reviewer, `.harness/skills/reviewer.md` 2.0.0; Baseline-Regelwerk `modul-10-review-harness.md`,
`modul-04-adrs.md`, `modul-08-agentenrollen.md`.

**Art der Runde:** Konsistenz-Runde nach der Überarbeitung — jeder Runde-1-Befund gegen den neuen Text, dazu die
Urteilsaussagen, die kein Zweitkontext gesehen hat, und die Frage, ob die Überarbeitung neue Widersprüche erzeugt.
Die Annahme (`Accepted`) ist Entscheidung des Auftraggebers und nicht Gegenstand; mit ihr wird die Datei
immutabel, darum stehen die Darstellungsbefunde unten vor der Annahme.

**Geprüft gegen:** ADR-0007 (Festlegung 3, Tabelle, Zweifelsregel), ADR-0054 (Festlegung 1 bis 4),
`spec/lastenheft.md` `LH-QA-04`, `AGENTS.md` §3.1/§3.6/§3.7/§3.11, `MR-025`/`MR-055`,
`internal/emit/enforce.go` (`writeSkipIfPresentTold`, Klassen je Pfad), `internal/emit/enforce_test.go`
(`TestEnforce_IdempotenzKlasseJePfad`), `internal/emit/selbstpruefung.go`, Baseline `modul-04-adrs.md`.

**Summary:** 0 HIGH · 0 MEDIUM · 6 LOW · 4 INFO. Klassen: *Menge mit Vorsorge-Zweig, Alternative fehlt* ·
*Definition der Herkunft überzogen gegenüber der Anwendung* · *Wirkungs-Aussage über ungemessene Lesart* ·
*Zusage ohne Sensor-Zeile (Meldungsinhalt)* · *„immer" gegen eigenes Negativ* · *Geschichte erzählt Korrekturen*.
Alle vier MEDIUM aus Runde 1 sind eingearbeitet, die drei LOW ebenfalls; die Überarbeitung erzeugt keinen Widerspruch
zwischen Kontext, Festlegungen, Alternativen und Konsequenzen, der die Entscheidung trüge.
**Empfehlung zum Accept: unbedingt an der Substanz** — kein HIGH, kein MEDIUM; die sechs LOW sind Wortlaut und
Vollständigkeit einer noch änderbaren `Proposed`-ADR und blockieren nicht, sollten aber **vor** der Immutabilität
mitgenommen werden (L-2, L-3, L-5, L-6 sind reine Textkorrekturen; L-1 und L-4 sind Wahl des Architect).

Alle Zahlen unten sind Momentaufnahmen vom 2026-09-25 an einem frisch gebootstrappten Wegwerf-Ziel im Scratchpad
(`ai-harness-init --lang go <ziel>`, committet, geklont) und an diesem Repo; keine Erwartungswerte.

---

## Status je Runde-1-Befund

| Befund | Status | Beleg |
|---|---|---|
| M-1 Guard-Fehlerbild | **behoben** | Kontext trennt jetzt den gewöhnlichen autocrlf-Klon (laut, Exit 2) vom Mischzustand (still). Beide Zustände nachgefahren (Sonde 2 und 3): der Guard endet im echten autocrlf-Klon für `go build` und für `ls` mit `set: pipefail: Ungültiger Optionsname`, Exit 2; im Mischzustand (Adopter-Wurzel `*.sh text eol=lf`) trägt der Guard 0 CR, `blocked/go` 1, und `grep -c '"block"'` liefert `staticcheck` → 0, `gofmt` → 1, `go build` → 1. Alternative F ist auf „laut" umgestellt, Alternative E trägt den stillen Fall. Rest: L-3. |
| M-2 Kriterium gegen Wurzel-Ausschluss | **behoben** | Kriterium zweigeteilt (bricht gemessen / make als **Vorsorge**), die Wurzel steht als „ausdrückliche Ausnahme vom Kriterium" mit Grund (keine der zwei Klassen trägt, Alternative D, Bruch unter GNU Make 4.3 nicht gemessen), Fitness-Zeile 1 sagt „unterhalb der Wurzel" und nennt `Makefile`/`d-check.mk`/`a-check.mk` als Ausnahme. Widerspruchsfrei, Sonde 5. Rest: L-1. |
| M-3 Begründung ohne Change Request | **behoben** | Konsequenz trennt „herstellbar unter Linux" (Fitness-Zeile 3) von „nicht herstellbar unter Windows" (Grenze der Messmethode, Festlegung 5). Der Schluss trägt: der Verzicht auf einen Vorschlag hängt an der fehlenden Windows-Lesart, nicht an einer Unherstellbarkeit der Linux-Aussage; die Entscheidung des Auftraggebers bleibt offen benannt (`MR-015`). |
| M-4 Klassen-Kriterium | **behoben mit Rest L-2** | „neu festgelegt" kommt nicht mehr vor (`grep -c 'neu festgelegt'` → 0); je Zeile steht „abgeleitet aus der Tabelle" bzw. „Zweifelsregel", und Konsequenz sagt „angewandt" nur für die drei skip-if-present-Pfade. Die Ableitung für `tools/harness/` trägt wörtlich, die für `.harness/` trägt über Unterbäume plus Nachbar — die Definition in Festlegung 3 ist dafür zu eng gefasst (L-2). |
| L-1 unbedingte Zusage | **behoben** | Festlegung 5 unterscheidet „immer" (konvergent) und „solange der Pfad frei war" (skip-if-present), mit Sonde für den belegten Pfad; die Positiv-Konsequenz nennt den bedingten Pfad. Neuer Rest: das „immer" selbst (L-5). |
| L-2 Trigger ohne Träger | **behoben** | Absatz „Träger der Trigger": Trigger 1 an das Runner-Ereignis, Trigger 4 an die erste Fitness-Zeile; Trigger 2 und 3 ausdrücklich „kein Wächter … benannt, nicht geschlossen". Ehrlich formuliert (Punkt 2d). |
| L-3 Index ohne `MR-005` | **behoben** | Die Bezug-Spalte der Index-Zeile trägt `MR-005` (`grep -n 'MR-005' docs/plan/adr/README.md` nennt Zeile 74). |
| I-1 Abweichung von Setzung 3 des Slice | **unverändert, Planner-Arbeit** | Die ADR nennt sie nicht und muss es nicht; nach `Accepted` ist die Setzung im Slice zu ziehen (Übergabe-Artefakt: die ADR). |
| I-2 CRLF schon im Index | **eingearbeitet** | Konsequenz-Negativ nennt den Fall mit Sonde. Nachgefahren: `git ls-files --eol .githooks` → `i/crlf w/crlf attr/text=auto eol=lf`, im Klon mit `-c core.autocrlf=true` `grep -c $'\r' .githooks/commit-msg` → 21. Deckt sich. |
| I-3 Dogfood-Hinweis | **nicht Gegenstand der ADR** | keine Änderung nötig. |

---

## Findings

### L-1 — LOW · Die Menge trägt einen Vorsorge-Zweig, und die Alternative „vier Verzeichnisse" fehlt in den Alternativen

- `quelle`: `modul-04-adrs.md` §Verglichene Alternativen, `AGENTS.md` §3.6
- `pfad`: `…0067-…md:79` (Kriterium, Vorsorge), `:89` (Wurzel-Ausnahme), `:109` bis `:118` (Alternativen)
- `befund`: Nach der Überarbeitung ist die Menge durch das Kriterium **nicht mehr allein** begründet: der zweite Zweig
  („oder ein make-Fragment") ist eine Vorsorge ohne gemessenen Bruch (GNU Make 4.3 verträgt CR, nachgefahren:
  `make -f crlf.mk | od -c` → `h i \n`, und `make baseline-verify` läuft mit CRLF in `Makefile`, `d-check.mk` und
  `harness/mk/*.mk` durch), und die Wurzel mit derselben Datei-Art steht daneben als Ausnahme. Beides benennt die ADR
  ehrlich. Die Wahl „`harness/mk/` mit Vorsorge dabei" hat aber einen Preis, den keine Alternative wägt: eine
  skip-if-present-Zeile samt Meldung bei jedem Lauf für eine Absicherung, die den Fall (ein make, das CR nicht
  verträgt) nicht erreicht, solange `Makefile` in der Wurzel — die Datei, die ein make zuerst liest und die
  `harness/mk/*.mk` einbindet — CRLF trägt. Die Alternative „nur nach gemessenem Bruch, also vier Verzeichnisse"
  steht nirgends; Alternative E und D wägen Erfassungsart und Wurzel, nicht diesen Zweig.
  **Empfehlung an den Architect (keine Entscheidung):** die Vorsorge mit einer Zeile in den Alternativen wägen
  (Pro: eine Datei-Art wird einheitlich behandelt, Kosten eine Zeile; Contra: Klasse und Meldung ohne gemessenen
  Anlass, Absicherung endet an der Wurzel), oder `harness/mk/` streichen. Beides ist mit dem Text vereinbar; ohne die
  Zeile ist die Entscheidung nach der Annahme nicht mehr nachvollziehbar wägbar.
- `verifizierbar`: ja (Sonde 5).
- `klasse`: Kriterium mit Ausnahme benannt, Gegenoption nicht gewogen.

### L-2 — LOW · Die Definition von „abgeleitet aus der Tabelle" verlangt „das Verzeichnis selbst"; für `.harness/` steht dort nur ein Unterbaum-Paar plus ein Nachbar

- `quelle`: `ADR-0007` Festlegung 3 (Tabelle), `MR-055`
- `pfad`: `…0067-…md:93` (Definition), `:97` (Zeile `.harness/.gitattributes`)
- `befund`: Festlegung 3 definiert *abgeleitet* als „ihre Zeile führt das Verzeichnis selbst als reine tool-erzeugte
  Infrastruktur". Die Tabellenzeile in ADR-0007 nennt für `.harness/` aber nur `.harness/baseline/<tag>/` und
  `.harness/skills/*` (Unterbäume) — nicht das Verzeichnis, und keinen Namen `.gitattributes`. Getragen wird die Zeile
  zusätzlich vom Nachbarn `.harness/.gitignore` (Code-Aufzählung, konvergent): eine Analogie an einer zweiten Stelle,
  keine Ableitung aus der Tabelle. Die Zelle sagt das offen (Unterbäume, Nachbar, „eine Adopter-Fläche nennt die
  Tabelle in diesem Verzeichnis nicht" — nachgeprüft, trifft zu), die Definition darüber deckt es nicht.
  Für `tools/harness/` trägt die Definition dagegen wörtlich (`tools/harness/*` samt `blocked/`).
- `verifizierbar`: ja (Vergleich Definition mit Zeile; `sed -n '100p' docs/plan/adr/0007-bootstrap-phasen.md`).
- `klasse`: Definition enger gefasst als ihre Anwendung.

### L-3 — LOW · „das Ziel ist also unbenutzbar" folgt aus einer Lesart, die in derselben Zelle als ungemessen steht

- `quelle`: `AGENTS.md` §3.6 (Zusage auf das einschränken, was gemessen ist)
- `pfad`: `…0067-…md:118` (Alternative F, Contra); vgl. `:48`
- `befund`: Gemessen ist: Guard endet mit Exit 2 und der `set`-Fehlermeldung, für jeden Aufruf (Sonde 2). Nicht gemessen
  ist, ob Claude Code diesen Exit 2 als blockierend liest — das steht im Kontext und am Ende derselben Zelle. Der
  Zwischensatz „das Ziel ist also unbenutzbar" ist genau die Wirkung, die davon abhängt; liest Claude Code den Exit
  nicht als blockierend, wäre der Guard wirkungslos **mit** Fehlermeldung — laut, aber ohne Halt. Die Ablehnung von F
  trägt auch ohne den Satz (der git-eigene Träger endet mit 127, der vendored Baum fällt durch), er ist aber die
  einzige Stelle, an der eine ungemessene Wirkung unbedingt steht.
- `verifizierbar`: ja (Wortlaut; die Wirkung selbst nur mit einem Lauf von Claude Code).
- `klasse`: Wirkungs-Aussage über eine ungemessene Lesart.

### L-4 — LOW · Festlegung 4 sagt zu, die Meldung nenne, was dann gilt — keine Fitness-Zeile bindet den Meldungsinhalt

- `quelle`: `AGENTS.md` §3.6, `ADR-0054` Festlegung 3
- `pfad`: `…0067-…md:103` (Zusage), `:139` (Zeile 2: „der Lauf nennt sie"), `:140` (Zeile 3: „die Meldung nennt die Datei")
- `befund`: Die Zusage geht über ADR-0054 hinaus: die Meldung soll auch **sagen, was dann gilt** (Zeile fehlt →
  CRLF im Klon). Die Fitness-Zeilen binden nur, dass der Lauf den Pfad nennt. Was passieren müsste, damit die Zusage
  bricht — eine Meldung ohne den Satz —, färbt keine Zeile rot; auch der `make mutate`-Fall benennt sie nicht. Machbar
  ist sie am vorhandenen Writer ohne neuen Pfad (`writeSkipIfPresentTold` hängt `f.meldung` je Eintrag an), es fehlt
  allein die Zeile.
- `verifizierbar`: ja (Test auf den Meldungstext je Pfad).
- `klasse`: Zusage ohne rot gesehenes Gegenbeispiel.

### L-5 — LOW · Festlegung 5 sagt „in den zwei konvergenten Verzeichnissen immer", die Konsequenz nimmt eine Datei mit CRLF im Index davon aus

- `quelle`: `AGENTS.md` §3.6
- `pfad`: `…0067-…md:105` („immer"), `:126` (Negativ: CRLF schon im Index bleibt CRLF)
- `befund`: Eine Datei, die ein Adopter mit CRLF im Index führt, bleibt trotz `text=auto eol=lf` CRLF, auch in den
  konvergenten Verzeichnissen (nachgefahren, I-2 oben). „Immer" gilt damit für die Dateien, die das Werkzeug ablegt und
  der Adopter nicht mit CRLF neu einträgt; das Negativ in der Konsequenz sagt es, der Satz in der Entscheidung nicht.
  Kein Widerspruch in der Sache, aber zwei Stellen mit unterschiedlicher Reichweite für dieselbe Zusage.
- `verifizierbar`: ja.
- `klasse`: unbedingte Zusage neben eigenem bedingendem Negativ.

### L-6 — LOW · Die Geschichte-Zeile der Überarbeitung zählt die eingearbeiteten Korrekturen auf

- `quelle`: `AGENTS.md` §3.7 (Beschrieben wird die Stelle, nicht der Vorgang; Zustandsfelder), Memory-Linie „Artefakt beschreibt die Sache"
- `pfad`: `…0067-…md:158`
- `befund`: Die Zeile nennt fünf Korrekturen („Guard-Fehlerbild … angepasst, Kriterium und Wurzel-Ausnahme in Deckung,
  Begründung ohne Change Request, Herkunft der zwei konvergenten Klassen, Träger der Trigger"). Das ist der Vorgang,
  der den Text erzeugt hat, und er wird mit der Annahme immutabel — für jeden späteren Leser der Text einer Fassung,
  die es nicht mehr gibt. Zustand und Beleg genügen (`Proposed überarbeitet | Review Runde 1`); was sich geändert hat,
  hält `git`. Die erste Zeile (Anlass des Architect-Laufs) ist Herkunft und unproblematisch.
- `verifizierbar`: ja (Lesen).
- `klasse`: Chronik der Textentstehung in einem Zustandsfeld.

### I-1 — INFO · Grammatik in Alternative A

- `pfad`: `…0067-…md:113` — „ein von Hand geänderte Datei" (gemeint: eine). Darstellungsfehler, vor der Immutabilität
  mitzunehmen; kein Bedeutungsträger.

### I-2 — INFO · Der Trigger-Audit ist ein schwacher Träger für Trigger 2 und 3, und die ADR nennt ihn nicht

- `pfad`: `…0067-…md:151`
- Baseline Modul 6 §Wellen-Closure-Prozedur, Schritt 2 (ohne Wellen die Slice-Closure) prüft jede ADR gegen ihren
  Re-Evaluierungs-Trigger. Für Trigger, die eine Messung voraussetzen, sieht der Audit sie nicht, wenn keiner sie
  nimmt — die ADR sagt das mit „kein Wächter" richtig. Sie könnte den Audit als den vorhandenen, aber blinden Träger
  nennen; ein Änderungswunsch ist das nicht. Die Formulierung „Absichtserklärung, kein bewachter Trigger" ist mit dem
  Regelwerk (*ein Trigger ohne Wächter ist eine Absichtserklärung mit Verfallsdatum*) deckungsgleich und nicht
  beschönigt.

### I-3 — INFO · `make selbstpruefung` ist als Nachmessung der Wurzel-Frage nicht aussagekräftig

- Die Sonde lief grün (Exit 0), klont aber den **committeten** Stand (`git clone -q "file://$quelle"` in
  `tools/harness/selbstpruefung.sh`, Zeile 142 im Ziel), nicht das mit `sed` verstellte Arbeitsverzeichnis. Als Beleg
  für „Wurzel-Dateien mit CRLF laufen" trägt allein `make baseline-verify` (Arbeitsverzeichnis, `OK`). Die ADR stützt
  sich nur auf Letzteres (`:79`) und behauptet nichts über `selbstpruefung` — kein Befund, ein Hinweis an künftige Sonden.

### I-4 — INFO · Übernommen aus Runde 1, weiter Planner-Arbeit

- Setzung 3 des Slice `slice-emittierte-dateien-behalten-lf-im-autocrlf-klon` (Klassen je Verzeichnis) ist nach
  `Accepted` durch die ADR überholt; Übergabe an den Planner, nicht an die ADR.

---

## Neue Urteilsaussagen (Punkt 2 des Auftrags)

**(a) `harness/mk/` als Vorsorge.** Die Menge ist danach durch das Kriterium **nicht mehr allein** begründet, sondern
durch „Kriterium plus benannte Vorsorge, Wurzel als benannte Ausnahme" — die ADR sagt das an der richtigen Stelle
(`:79`, `:89`), es ist also ein ehrliches Kriterium mit Ausnahme, kein verstecktes. Nicht ehrlich erwähnt ist die
Gegenoption „vier Verzeichnisse": keine der sechs Alternativen wägt sie (L-1). **Empfehlung:** Zeile in den
Alternativen ergänzen, `harness/mk/` kann dabei bleiben — die Entscheidung darüber ist Sache des Architect und des
Auftraggebers.

**(b) Herkunft der zwei konvergenten Zeilen gegen ADR-0007 Festlegung 3 an der Quelle.** Die Tabellenzeile in ADR-0007
(Zeile 100) führt `.harness/baseline/<tag>/ (regelwerk + templates)`, `.harness/skills/*`, `harness/mk/*.mk`,
`.claude/hooks/*.sh`, `tools/harness/*` und `tools/harness/blocked/<sprache>` als konvergent, „reine tool-erzeugte
Infrastruktur … prunt nie". Für `tools/harness/` trägt die Ableitung wörtlich. Für `.harness/` trägt sie über die zwei
Unterbäume, die ADR-0054 Festlegung 2 gedeckte Lesart („ein Verzeichnis, das die Emission anlegt … das Werkzeug
bestimmt, was liegt") und den Nachbarn `.harness/.gitignore` (konvergent in `internal/emit/enforce.go`); im Baum des
Wegwerf-Ziels liegen in `.harness/` nur `baseline` (55 Dateien), `.gitignore` (1) und `skills` (2)
(`git ls-files .harness | sed 's#^\(\.harness/[^/]*\).*#\1#' | sort | uniq -c`), also keine Adopter-Fläche neben ihnen.
Die Substanz trägt; nur die Definition in Festlegung 3 ist enger als ihre Anwendung (L-2).

**(c) `local.mk` gegen `vorgaben.mk`.** Beide Aussagen stimmen. `grep -rl 'local\.mk' internal cmd | wc -l` → 0;
`grep -c 'local.mk' docs/plan/adr/0007-bootstrap-phasen.md` → 2 (Tabellenzeile und eine Geschichte-Zeile);
`SelbstpruefungVorgabeOrt = "harness/mk/vorgaben.mk"` in `internal/emit/selbstpruefung.go` mit dem zitierten
Halbsatz „das kein Lauf dieses Werkzeugs schreibt". Die ADR liest `local.mk` richtig als Namen der Tabelle, nicht als
Pfad eines Emitters, und benennt den realen Adopter-Ort. `grep -c '\.gitattributes' docs/plan/adr/0007-bootstrap-phasen.md`
→ 0 ebenfalls bestätigt.

**(d) Trigger 2 und 3.** „Kein Wächter, benannt, nicht geschlossen" ist ehrlich und regelwerkkonform: das Regelwerk
nennt einen Trigger ohne Wächter eine Absichtserklärung mit Verfallsdatum, die ADR nennt sie genauso und schreibt
beides in die Zeile. Beide Trigger sind beobachtbar formuliert (Stichprobe gebauter Ziele; nachgewiesener Bruch am
Windows-`make`/BuildKit). Kein Befund; I-2 nur als Ergänzung.

---

## Nachgefahrene Sonden (Ergebnis je Punkt)

Wegwerf-Ziel unter dem Scratchpad des Laufs, Träger `.harness/state/bin/ai-harness-init` dieses Repos (`--lang go`,
ein Commit, 119 Dateien); nur `git`, `make`, bash-Builtins, `docker` über die Make-Ziele.

| Nr | Sonde | Ergebnis |
|---|---|---|
| 1 | CR je Verzeichnis, Kommando der ADR (Kontrolle `-c core.autocrlf=false` ausdrücklich) | `.harness 58 0 · .claude/hooks 3 0 · .githooks 1 0 · harness/mk 11 0 · tools/harness 11 0` — deckt sich wörtlich mit dem Text. `git ls-files --eol \| grep -c 'i/-text'` → 0. |
| 2 | Guard im gewöhnlichen autocrlf-Klon, Aufruf wie in `settings.json` (`bash …/pretooluse-command-guard.sh`, Eingabe als JSON auf stdin) | `go build ./...` → `set: pipefail: Ungültiger Optionsname`, Exit 2; `ls` → dasselbe, Exit 2. Laut, jeder Aufruf. |
| 3 | Mischzustand: Adopter-Wurzel `printf '*.sh text eol=lf\n' > .gitattributes`, Klon mit autocrlf | `grep -c $'\r'` → Guard 0, `blocked/go` 1; `grep -c '"block"'`: `staticcheck` **0**, `gofmt` 1, `go build` 1. Der stille Fall trägt wie beschrieben. |
| 4 | Fünf `.gitattributes` mit `* text=auto eol=lf`, Adopter-Wurzel `* text eol=crlf`, Klon mit autocrlf | CR-Dateien je Verzeichnis 0; `bash tools/harness/baseline-verify.sh` → `OK — 54 Dateien`; `.githooks/commit-msg` läuft über die Shebang-Zeile (gibt die Kennungs-Meldung aus); Ausführungsbit `-rwxrwxr-x`; `Makefile` trägt weiter CR (23 Zeilen). Deckt Kontext, zweite Messung. |
| 5 | Wurzel-Dateien mit CRLF (`sed -i 's/$/\r/' Makefile d-check.mk harness/mk/*.mk` im LF-Klon), danach `make baseline-verify`, `make selbstpruefung` | `baseline-verify: v6.9.0 OK — 54 Dateien`, Exit 0 (GNU Make 4.3). `selbstpruefung` Exit 0 — aber klont den committeten Stand, kein Beleg für CRLF (I-3). `make -f crlf.mk \| od -c` → `h i \n`. |
| 6 | Erfassungsmenge: getrackte Dateien mit Shebang, `.sh`/`.awk`/`.mk`, `Makefile`, `Dockerfile` **außerhalb** der fünf Verzeichnisse | genau `Dockerfile`, `Makefile`, `d-check.mk` (alle Wurzel; mit `--arch` zusätzlich `a-check.mk`, Runde 1). Kein sechstes Verzeichnis. |
| 7 | CRLF schon im Index, danach `.githooks/.gitattributes` mit der Zeile | `git ls-files --eol .githooks` → `i/crlf w/crlf attr/text=auto eol=lf`; Klon mit autocrlf: `grep -c $'\r' .githooks/commit-msg` → 21. |
| 8 | Textbelege | `grep -c 'local.mk'` an ADR-0007 → 2; `grep -c '\.gitattributes'` → 0; `grep -rniE 'crlf\|autocrlf\|gitattributes' spec/ \| wc -l` → 0; `grep -rn 'Zeilenende' spec/ \| wc -l` → 1; `grep -rl 'local\.mk' internal cmd \| wc -l` → 0; `grep -c 'neu festgelegt'` an der ADR → 0. |
| 9 | Sensor-Realität | `TestEnforce_IdempotenzKlasseJePfad` existiert (`internal/emit/enforce_test.go`) und prüft das Verhalten je Klasse gegen `PathClass`/`EnforcePaths()`; er trägt neue Pfade, sobald sie in der Aufzählung stehen, **bindet aber die Zuordnung nicht** (ein Pfad mit der falschen Klasse besteht ihn) — dafür ist Fitness-Zeile 2 („zu bauen") zuständig. Der Text behauptet nur die Kopplung, keine Zuordnung; kein Befund. Alle übrigen Zeilen stehen als „zu bauen", die Präambel deckt es (`LH-QA-01`). |
| 10 | Doku-Gate | `make docs-check` vor dem Report: `1899 Datei(en) geprüft, 0 Befund(e)`. `make history-range-guard RANGE=94498b1f..3c74c101` → aufgelöst, 1 Commit, OK; `make adr-immutable RANGE=94498b1f..3c74c101` → `0 Befund(e)` (die ADR ist `Proposed`, der Sensor also ohne Gegenstand — kein Beleg für Immutabilität, nur für „nichts Accepted berührt"). |

## Geprüft, ohne Befund (Negativbefund-Pflicht)

- **Status-Zeile und Kopf:** `**Status:** Proposed`; Bezug führt `MR-005` und die `LH-*`-Kennungen wie die Index-Zeile
  (Vergleich Kopf gegen `docs/plan/adr/README.md:74`); Ankerziele löst `make docs-check` auf.
- **Alternativen:** sechs Optionen, „nichts tun" (F) dabei, Pro/Contra je Zeile; nach der Umstellung passen E und F
  zum Kontext (E erzeugt den stillen Fall, F den lauten).
- **Querverweise auf Festlegungs-Nummern:** Festlegung 3 in Kontext, Kopf und Konsequenzen, Festlegung 4 in Kontext und
  Alternative B, Festlegung 5 in Kopf, Wurzel-Ausnahme und Alternative D, Festlegung 1 in Alternative D und Trigger 4
  zeigen jeweils auf die Festlegung mit dem genannten Inhalt. Kein Widerspruch zwischen Kontext, Festlegungen,
  Alternativen und Konsequenzen nach der Umformulierung: die Herkunfts-Definition (L-2) und das „immer" (L-5) sind
  Reichweiten-Unterschiede, keine Gegensätze.
- **Zahlen mit Kommando (`MR-025`):** jede Zahl im Kontext und in den Festlegungen steht neben ihrem Kommando; die Sonden
  1, 3, 7 und 8 liefern die genannten Werte. Alle Zahlen tragen „keine Erwartungswerte", wo sie wandern.
- **Kein `Supersedes`, kein Change Request:** ADR-0007 und ADR-0054 werden angewandt, nicht überschrieben; keine
  `LH-*`-Aussage ändert sich (Sonde 8, Spec schweigt zum Gegenstand).
- **Sensoren nur als vorhanden benannt, wenn vorhanden (§3.1):** einziger real existierender Sensor ist
  `TestEnforce_IdempotenzKlasseJePfad`; Fitness-Zeilen 1 bis 3 tragen „zu bauen" über die Präambel und in der Zeile;
  die Zeile 5 („kein Gate") benennt die Windows-Lücke, statt einen Sensor zu behaupten.
- **Rot-Zusage der Fitness-Zeile 1:** Streichen eines Eintrags und `eol=crlf` färben den Test der Zeile rot — beide Mutationen
  sind benannt, der `mutate`-Fall trägt sie; die Kopplung ist Eigenschaft statt Verzeichnis-Liste (Folgepflicht 2).
- **§3.4/§3.5/§3.8:** der Commit `3c74c101` berührt nur die ADR und ihre Index-Zeile und nennt die Rolle Architect;
  keine Gate-Lockerung.
- **§3.11:** keine Pfad-Adresse eines wandernden Artefakts; der Slice steht als Kennung in der Geschichte, Reports und
  ADRs als Kennung bzw. Anker; Pfade im Ziel-Baum tragen den d-check-Marker. Der vorliegende Report nennt den
  Runde-1-Report und die ADR mit ihrem ortsfesten Dateinamen als Code-Span und trägt keinen Markdown-Link in
  `.harness/baseline/**`.
- **Größe:** 163 Zeilen gegen 158 in Runde 1, fünf Festlegungen; das Wachstum steckt in der Präzisierung, nicht in
  neuen Festlegungen (`wc -l` an der ADR).

## Nicht gefahren

- `make mutate` (Auftrag verbietet es; der Fall ist „zu bauen").
- Ein echter Windows-Git-Lauf und Claude Code als Konsument des Guard-Exit-2 (L-3 hängt daran).
- Die Emission mit `--arch hexslice`/`hexagonal` und `--lang cpp` (Erfassungsmenge stammt dafür aus Runde 1, die
  Emission ist unverändert).
- `git add --renormalize` und der Dogfood (gehören zur Lieferung des Slice, nicht zur ADR).

## Empfehlung zum Accept

**Unbedingt an der Substanz.** Die vier MEDIUM aus Runde 1 sind eingearbeitet und tragen nachgemessen; die
Überarbeitung führt keinen neuen Widerspruch ein; die Sonden 1 bis 7 reproduzieren jede Zahl und jede Wirkungs-Aussage
des Textes, die sich unter Linux herstellen lässt. Es bleiben sechs LOW und vier INFO. **Vor der Immutabilität**
mitzunehmen, weil sie nach der Annahme nur noch per `Supersedes` korrigierbar sind: L-2, L-3, L-5, L-6 und I-1
(Wortlaut, je ein Satz); L-1 und L-4 sind Vollständigkeit (eine Alternativen-Zeile, eine Fitness-Zeile) und liegen im
Ermessen des Architect. Ob die ADR angenommen wird, entscheidet der Auftraggeber; als Beleg des Accept-Übergangs
(`ADR-0040` Festlegung 2) trägt diese Runde, wenn die Überarbeitung nach den LOW erneut nur Text berührt.
