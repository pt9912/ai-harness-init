# Review-Report: slice-emittierte-dateien-behalten-lf-im-autocrlf-klon — 2026-09-25

**Review-Art:** Code — Implementations-Diff gegen Plan, ADR und Hard Rules (Modul 10). Nicht gegen die DoD (das ist der Verifier).

**Gegenstand:** `git diff bd76d800..HEAD` — acht Commits: `d691beb5` (Lifecycle-Move, reiner Move), `7a031289` (Roadmap-Ruhe-Marker entfernt),
`46730987` (`full-smoke`-Stufe `zeilenenden_im_klon`, Liefer-Punkt 1), `1b482a15` (Emission, Liefer-Punkt 2), `14592003` (Wurzel-`.gitattributes`,
Liefer-Punkt 3), `6fc08d5e` (Modus der Fälle), `fefd3b29` (Exit-Codes der Stufe als `if … then rc=0; else rc=$?; fi`), `984f6dd8` (Stufen-Kommentar).
Berührt: `harness/tools/full-smoke.sh`, `docs/user/e2e-abdeckung.md`, `internal/emit/zeilenenden.go`, `internal/emit/templates/enforce/gitattributes`,
`internal/emit/enforce.go`, `internal/emit/enforce_test.go`, `internal/emit/baumaussage_test.go`, `internal/emit/zeilenenden_test.go`,
`test/mutations/446-zeilenenden-eintrag-entfaellt.sh` bis `test/mutations/450-zeilenenden-klasse-wird-konvergent.sh`, `.gitattributes`, `roadmap.md`
(`git diff --stat bd76d800..HEAD` → 16 Dateien, 507 Zeilen hinzu, 11 entfernt).

**Plan-Bezug:** Slice `slice-emittierte-dateien-behalten-lf-im-autocrlf-klon` (§1 Setzungen 1 bis 4, Liefer-Punkte 1 bis 3, §4, §6, §8) — Kennung, nicht
Pfad: der Plan liegt in `in-progress/` und wandert nach `done/`. **Constraint:** `ADR-0067` (`Accepted`; Festlegungen 1 bis 5 und Fitness-Zeilen),
`ADR-0007` (Klassen), `ADR-0054` (Bedeutung von skip-if-present), `LH-QA-04`, `LH-FA-06`, `LH-FA-01`.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13)
**Modell:** Sonnet 5 · **Datum:** 2026-09-25

**Eingangs-Kontext:** Diff · Slice-Plan · `ADR-0067` vollständig · `ADR-0007`/`ADR-0054` (als Klassen-Grundlage) · `internal/emit/enforce.go` samt
`enforce_test.go` · `AGENTS.md` §3.4, §3.6, §3.7, §3.8, §3.9, §3.10, §3.11 · `test/full-smoke-ausgang.bats` (Zählung der Abschnitte). Der Implementer-Bericht
war Behauptung; Code, Tests und Sonden sind selbst gelesen und gefahren.

**Eigene Sensor-Läufe dieses Laufs** (kein Host-Go, kein `make mutate`, Prüfgegenstand unberührt; alle Sonden in Scratchpad-Kopien ohne `.git`):

- **`make test-go` unmutiert** auf einer Kopie: EXIT 0, `internal/emit` `ok`.
- **Fälle 446 bis 450 emuliert, nicht über `make mutate`:** je frische Kopie, das Skript des Falls dort angewandt (Anker ändert die Datei: bei allen fünf ja),
  `make test-go`, Meldung gelesen.
  **446** → rot `TestZeilenenden_JederKonsumentLiegtUnterEinerZeile` (Meldung nennt `.claude/hooks/pretooluse-command-guard.sh`, `span-emit.sh`,
  `stop-require-gates.sh` ohne Vorfahr-Zeile), zusätzlich `TestZeilenenden_BelegterPfadBleibtUndWirdGemeldet` und die zwei Hook-Inventare in `enforce_test.go`;
  **447** (`eol=crlf`) → rot `TestZeilenenden_JederKonsumentLiegtUnterEinerZeile` an jedem Konsumenten unter allen fünf Verzeichnissen;
  **448** (Endungs-Glob `*.sh`) → rot ebenda, die Meldung nennt `tools/harness/blocked/go`, `tools/harness/blocked/cpp` und `.githooks/commit-msg` — genau die
  endungslosen Dateien des stillen Mischzustands;
  **449** (Meldung nur mit Pfad) → rot `TestZeilenenden_BelegterPfadBleibtUndWirdGemeldet` mit *„nennt \"core.autocrlf=true\" nicht"* und *„nennt \"CRLF\" nicht"*
  je Pfad;
  **450** (`harness/mk/.gitattributes` konvergent) → rot `TestZeilenenden_BelegterPfadBleibtUndWirdGemeldet` mit *„wurde ueberschrieben (skip-if-present
  verletzt)"* und *„die Meldung nennt den belegten Pfad … nicht"*. Jedes `# expect:` ist ein Test, der im Lauf rot wurde.
- **Gegenproben (grün heißt „bindet"):** **450** mit entfernter Meldungs-Prüfung des Tests (`if zeile == ""` auf `if false`) → weiter rot allein durch
  *„wurde ueberschrieben"*: die Zusicherung „skip-if-present nicht überschrieben" bindet **allein**, und die Meldungs-Zusicherung trägt unabhängig (zwei
  Träger, wie der Implementer sagt). Umgekehrte Richtung, `.harness/.gitattributes` als `SkipIfPresent` (Sonde, nicht gelistet) → rot *„wurde nicht kanonisch
  neu geschrieben (konvergent verletzt)"* und *„der Lauf meldet den konvergenten Pfad"*: der Test hält beide Klassen-Richtungen an seiner **eigenen** Liste.
- **Vorbedingung „alle sechs Klassen im Baum vertreten"** (Sonde: die Schleife über `BlockedFragment` im Test-Emit leer) → rot *„der emittierte Baum traegt
  keinen Konsumenten unter /blocked/ — die Richtung dieser Klasse misst nichts"*.
- **Zusätzliche Zeile in der Vorlage** (Sonde: `*.sh eol=crlf` unter die Zeile gehängt) → `make test-go` **grün** (EXIT 0) — siehe LOW-1.
- **`full-smoke`-Stufe einzeln gefahren** (Funktionskörper aus `harness/tools/full-smoke.sh` gegen ein Binary aus der Scratchpad-Kopie, `make host-bin`):
  **mit Emission** → EXIT 0, Ausgabe *„… kein CR im autocrlf-Klon, Kontrollklon (core.autocrlf=false) ebenso; Restmenge ausserhalb: 28 Datei(en) mit CR
  (nicht zugesagt)"*, je oberstem Segment aufgeschlüsselt (`Makefile`, `d-check.mk`, `.d-check.yml`, `Dockerfile`, `.claude` 10, …). **Rot vor der Emission**
  (Stand-in-Binary, das nach dem Bootstrap die fünf `.gitattributes` löscht) → EXIT 1, je Verzeichnis *„der Klon mit core.autocrlf=true traegt CR in .harness
  (58 Datei(en)); … Erste Dateien:"* mit Dateinamen, dann die Konsumenten: `/usr/bin/env: »bash\r“: Datei oder Verzeichnis nicht gefunden` (Exit 127),
  `set: pipefail: Ungültiger Optionsname` (Exit 2) für `baseline-verify.sh` und für den Guard. Das Rot nennt die CR-tragende Datei.
- **Bootstrap-Sonde über vier Varianten** (`--lang go`, `--arch hexslice`, `--arch hexagonal`, `--lang cpp --arch hexslice`): Interpreter-Konsumenten
  (Shebang, `.sh`/`.awk`/`.mk`, `blocked/`) ohne Vorfahr-`.gitattributes` unterhalb der Wurzel: **keiner**; ungedeckt bleiben allein `d-check.mk` und
  `a-check.mk` in der Wurzel (die benannte Ausnahme). Die fünf Dateien liegen in jeder Variante; kein `.gitattributes` in `docs/` oder `spec/`.
- **Adopter-Wurzel-Sonde** (Wurzel-`.gitattributes` `* text eol=crlf` bzw. `*.sh eol=crlf` vor dem Bootstrap, Klon mit `-c core.autocrlf=true`): in allen fünf
  Verzeichnissen **0** Dateien mit CR, das Wurzel-`Makefile` trägt 23 — die genestete Zeile gewinnt, wie `ADR-0067` Festlegung 5 sagt. **Zweiter Lauf** über
  diesem Ziel: die drei skip-if-present-Pfade werden je mit Pfad und Aussage gemeldet (*„… liegt bereits — die Datei bleibt unberuehrt (skip-if-present).
  Traegt sie die Zeile `* text=auto eol=lf` nicht, tragen die Dateien in harness/mk/ im Klon mit core.autocrlf=true CRLF."*), Exit 0.
- **Dogfood-Wurzel:** `git ls-files --eol | awk '{print $1,$2}' | sort | uniq -c` **identisch** (i/lf 2599 · i/none 11 · i/-text 2 · ohne Angabe 10);
  im Wegwerf-Klon mit `core.autocrlf=false`: `git add --renormalize . && git diff --cached --name-only | grep -vc '^\.gitattributes$'` → **0**; Klon von HEAD mit
  `-c core.autocrlf=true`: `grep -c $'\r'` in `SHA256SUMS` **0**, im Guard **0**, `grep -rlI $'\r' --exclude-dir=.git . | wc -l` **0**, die zwei PNG unter
  `docs/user/images/` byte-gleich zu `git show HEAD:<pfad>` (sha256).
- **`make comment-claims`:** `77 Datei(en) geprueft, 0 Befund(e)`. **`make e2e-abdeckung`:** *„unverändert — docs/user/e2e-abdeckung.md (22 Stufen, 22
  Deklarationen)"*, `git status --short` danach leer (die Datei ist von Hand nicht abweichend).
- **Nicht gefahren:** `make mutate` (verboten; der Beleg hängt am Baum-Hash, Verifier), ein ganzer `make full-smoke` (lang; die Stufe ist einzeln mit und ohne
  Emission gefahren), `make smoke` (der Diff berührt die Doku-Gate-Konfiguration des Ziels nicht; kein Befund verlangt ihn), ein Windows-Git (Grenze der
  Messmethode, `LH-QA-04`). `make gates` — siehe Ende.

---

## Findings

### MEDIUM-1

- `kategorie`: MEDIUM
- `quelle`: `AGENTS.md` §3.7 (Konjunktiv über die verworfene Alternative); Wiederholung eines Musters, das in `docs/reviews/2026-09-14-slice-vorlauf-waechter-geht-ins-ziel-runde-3.md` (N-6) und `docs/reviews/2026-09-16-slice-commit-traeger-wird-skip-if-present.md` (F-5) je als LOW stand — zwei Vorläufer, damit MEDIUM nach der Skill-Regel
- `pfad`: `harness/tools/full-smoke.sh:3158` (*„Ohne sie waere \"kein CR\" eine Aussage ueber einen Klon, der nie CR bekommen kann."*);
  `internal/emit/zeilenenden_test.go:126-127` (*„Ueber einer Klasse ohne Vertreter waere ihre Richtung still gruen."*);
  `test/mutations/450-zeilenenden-klasse-wird-konvergent.sh:6` (*„der Lauf ueberschriebe dort eine Datei"*);
  `test/mutations/446-zeilenenden-eintrag-entfaellt.sh:6-7` (*„lagen sie mit CRLF, und ihre Shebang-Zeile lautete `bash\r`"*, Präteritum über einen Zustand, der nicht besteht);
  `test/mutations/449-zeilenenden-meldung-ohne-aussage.sh:7` (*„Ohne die Aussage ist die Meldung eine Ortsangabe."*)
- `befund`: Vier in diesem Diff geschriebene Kommentare begründen ihre Zusage durch die Alternative, die nicht besteht („Ohne X wäre/ist …", Konjunktiv II, Präteritum), statt
  den geltenden Zustand indikativ zu nennen; die Zeile im Stufen-Kopf und im Test-Kommentar sind Vorbedingungs-Begründungen, die Fall-Kommentare beschreiben die Mutation im Irrealis. Die
  Vorbedingung selbst ist gut (rot gesehen, siehe Sensor-Läufe); es ist die Formulierung, die §3.7 als *falsch* führt.
- `verifizierbar`: nein — kein Gate fängt das (`make comment-claims` prüft Sensor-Namen, nicht die Zeitform).
- `klasse`: Begründungsklausel im Konjunktiv über die verworfene Alternative

### LOW-1

- `kategorie`: LOW
- `quelle`: `ADR-0067` Fitness-Zeile 1 / `AGENTS.md` §3.6 (ein Test, dessen Name eine Eigenschaft behauptet, muss die Eigenschaft messen, nicht ihre heutige Implementierung)
- `pfad`: `internal/emit/zeilenenden_test.go:96-108` (`zeilenendenTraegtDieZeile`) und `:128-182` (`TestZeilenenden_JederKonsumentLiegtUnterEinerZeile`)
- `befund`: Der Test prüft, dass die Zeile `* text=auto eol=lf` **als eine Zeile der Datei** steht, nicht, welchen Wert Git dem Pfad am Ende zuweist. Hängt eine Zeile mit späterer
  Wirkung (`*.sh eol=crlf`) unter die Zeile der Vorlage, bleibt `make test-go` grün (Sonde: EXIT 0), obwohl Git die Skripte dann mit CRLF ausliefert; erst die `full-smoke`-Stufe
  färbte rot. Die drei geforderten Rot-Beweise (Eintrag streichen, `eol=crlf`, Endungs-Glob) tragen; die Eigenschaft „legt LF fest" auf Go-Ebene trägt nur die Präsenz.
- `verifizierbar`: ja — Sonde: an `internal/emit/templates/enforce/gitattributes` eine Zeile `*.sh eol=crlf` anhängen, `make test-go` (bleibt grün).
- `klasse`: Eigenschafts-Test prüft die Anwesenheit einer Zeile statt ihrer Wirkung

### LOW-2

- `kategorie`: LOW
- `quelle`: Maintainability (Commit-Aussage gegen Bestand, `git ls-files -s test/mutations`)
- `pfad`: Commit `6fc08d5e` (Message: *„Modus der fuenf neuen Mutations-Faelle an den Bestand angeglichen (0644)"*); `test/mutations/446-…` bis `450-…`
- `befund`: Die fünf Fälle standen nach `1b482a15` auf `100755` und wurden auf `100644` gestellt; die 42 unmittelbar vorausgehenden Fälle (404 bis 445) tragen alle `100755`
  (`git ls-files -s test/mutations | awk '{n=$4; sub(/.*\//,"",n); split(n,a,"-"); if (a[1]+0>=404 && a[1]+0<446) print $1}' | sort | uniq -c` → 42 × `100755`); `100644` tragen
  nur ältere Fälle (Gesamtbestand 119 zu 319). Die Message nennt „den Bestand" als Maßstab, ohne zu sagen, welchen. Funktional folgenlos (`harness/tools/mutate.sh` ruft `bash "$case_file"`); ein
  direkter Aufruf `./test/mutations/446-….sh` fällt mit *Permission denied*.
- `verifizierbar`: ja — `git ls-files -s test/mutations`.
- `klasse`: Angleichung an „den Bestand" ohne benannten Maßstab

### INFO-1

- `kategorie`: INFO
- `quelle`: `ADR-0067` Fitness-Zeile 2; Slice §2 Liefer-Punkt 2 (*„Die bestehende Klassen-Kopplung … trägt die neuen Pfade"*)
- `pfad`: `internal/emit/enforce_test.go:366` (`TestEnforce_IdempotenzKlasseJePfad`) gegen `internal/emit/zeilenenden_test.go:197`
- `befund`: `TestEnforce_IdempotenzKlasseJePfad` liest die Klasse je Pfad aus `PathClass` — derselben Aufzählung, die die Emission fährt; er trägt die neuen Pfade als
  Aufzählung, **nicht** ihre Klasse (ein Pfad mit falscher Klasse besteht ihn). Die Klassen-Bindung je Pfad hält allein `TestZeilenenden_BelegterPfadBleibtUndWirdGemeldet` mit
  seiner eigenen Liste — gemessen: 450 und die umgekehrte Sonde färben ihn rot, die Klassen-Kopplung bleibt grün. Der Plan-Satz stimmt für die Pfad-Menge, nicht für die Klasse.
  Zuständige Rolle: Verifier (DoD-Formulierung).
- `verifizierbar`: ja — 450 emulieren: `TestEnforce_IdempotenzKlasseJePfad` bleibt grün.
- `klasse`: Klassen-Kopplung liest die Klasse aus der Aufzählung, die sie prüft

### INFO-2

- `kategorie`: INFO
- `quelle`: `ADR-0067` Festlegung 1 (Wurzel-Ausnahme), Fitness-Zeile 1
- `pfad`: `internal/emit/zeilenenden_test.go:67-71`, `:144-146`
- `befund`: Das Test-Ziel enthält `Makefile` und `d-check.mk`, aber kein `a-check.mk` (es entsteht nur mit `--arch hexslice`/`hexagonal`). Die Wurzel-Ausnahme selbst trägt
  `!strings.Contains(rel, "/")` für jede Wurzel-Datei; `Makefile` ist nach dem eigenen Kriterium des Tests (Shebang, `.sh`/`.awk`/`.mk`) ohnehin kein Konsument, die Ausnahme also allein an `d-check.mk` sichtbar.
  Die Bootstrap-Sonde über vier Varianten zeigt für `a-check.mk` dasselbe Bild (ungedeckt, Wurzel, benannt). Kein Bruch der Zusage; die Aussage „`a-check.mk` im Test behandelt" gilt durch die Wurzel-Regel, nicht durch eine Datei.
- `verifizierbar`: ja.
- `klasse`: Wurzel-Ausnahme im Test nicht an allen genannten Dateien sichtbar

### INFO-3

- `kategorie`: INFO
- `quelle`: `AGENTS.md` §3.6 (Zusage im Kommentar), `ADR-0067` Festlegung 2 und 5
- `pfad`: `internal/emit/templates/enforce/gitattributes:1-3`
- `befund`: Der Vorlagen-Kommentar (geht in fünf Ziele) sagt zu, die Zeile gelte *„unabhaengig von core.autocrlf und von einer .gitattributes in der Wurzel des Repos"*. Die Aussage
  ist wahr (Adopter-Wurzel-Sonde oben, zwei Formen, 0 CR in den fünf Verzeichnissen) und in `ADR-0067` §Kontext von Hand gemessen; ein wiederholbarer Sensor im Repo hält die
  Wurzel-Hälfte nicht — die Stufe fährt keine Adopter-Wurzel. Kein Kennungs-Bezug dieses Repos im Kommentar (geprüft).
- `verifizierbar`: nein.
- `klasse`: Zusage im emittierten Kommentar ohne wiederholbaren Sensor

### INFO-4

- `kategorie`: INFO
- `quelle`: Slice §2 (Doku-Update-Pflicht), `AGENTS.md` §3.1
- `pfad`: `docs/user/benutzerhandbuch.md:203`, `:547`, `:462-467`
- `befund`: Das Handbuch nennt die Zeilenenden der Emission nicht. Keine seiner Aussagen wird falsch: der zweite Lauf *„lässt Ihre eigenen Dateien unangetastet"* bleibt wahr, und der Baum-Ausschnitt führt
  Verzeichnisse, keine Einzeldateien. Eine neue Aussage über Windows-Klone gehört nach der Setzung des Auftraggebers (Nutzerdoku trägt den Ist-Zustand) in den Release-Schnitt, nicht in diesen Slice.
- `verifizierbar`: nein.
- `klasse`: Emission ohne Handbuch-Aussage, Release-Schnitt zuständig

---

## Negativbefund — geprüft, ohne Befund

| Bereich | Ergebnis |
|---|---|
| Emission deckt `ADR-0067` Festlegung 1 (fünf Verzeichnisse, Wurzel-Ausnahme), 2 (Zeile `* text=auto eol=lf`), 3 (Klasse je Pfad), 4 (Meldung mit Pfad **und** Aussage), 5 (keine Wurzel-Datei) | geprüft, ohne Befund — Bootstrap-Sonde über vier Varianten, fünf Dateien je Variante, keine in `docs/`/`spec/`/Wurzel; Meldung am realen zweiten Lauf gelesen |
| Klassen `.harness/`, `tools/harness/` konvergent; `harness/mk/`, `.claude/hooks/`, `.githooks/` skip-if-present mit Meldung | geprüft, ohne Befund — Einträge in `internal/emit/zeilenenden.go` gegen die Tabelle in `ADR-0067` Festlegung 3; `PathClass`/`EnforcePaths()` führen sie (`enforce.go` hängt `zeilenendenFiles()` an); Klassen-Bindung durch die eigene Liste des Meldungs-Tests, nicht durch die Aufzählung |
| Eigenschafts-Test leitet die Menge aus dem emittierten Baum ab, nicht aus der Verzeichnis-Liste der Emission | geprüft, ohne Befund — `filepath.WalkDir` über das Emit, Konsument nach Shebang/Endung/`blocked/`/Präfix; die sechs Klassen sind Vorbedingung und wurden rot gesehen; Rot aus dem behaupteten Grund (446, 447, 448 mit gelesener Meldung) |
| Fälle 446 bis 450: Anker treffen (`MR-071`), erwarteter Test rot, Gegenprobe | geprüft, ohne Befund — je Fall rot mit der Meldung der behaupteten Ursache; 450: zwei unabhängige Träger, jeder allein rot; 448 nennt genau die endungslosen Dateien |
| `full-smoke`-Stufe: Kopfzeile, Deklaration `LH-FA-01 LH-FA-06` (nicht `LH-QA-04`), Kontrollklon mit gesetztem `=false`, Vorbedingungen (Wert im Klon, fünf Verzeichnisse tragen Dateien, Wurzel-`Makefile` trägt CR im autocrlf-Klon), Konsumenten-Läufe, Restmenge | geprüft, ohne Befund — Stufe einzeln mit und ohne Emission gefahren; Rot nennt Verzeichnis, Anzahl und Dateien, dann die vier Konsumenten mit ihrer Ausgabe; die Restmenge (28) wird ausgegeben und als „nicht zugesagt" benannt |
| Wortwahl „laut"/„still" | geprüft, ohne Befund — „still" steht im Diff nur in der Test-Vorbedingung (`still gruen`, gewöhnlicher Sprachgebrauch für ein Grün ohne Aussage), nicht für den Guard im gewöhnlichen Klon; Kopfzeile, Meldungen und Deklaration nennen den Ausfall nicht „still"; der Mischzustand ist als solcher benannt |
| `fefd3b29`: `if … then rc=0; else rc=$?; fi` statt `\|\| x=$?` | geprüft, ohne Befund — `git diff bd76d800..HEAD -- test/full-smoke-ausgang.bats` ist leer; die Zählung des Falls (`abschnitte`, `einordnen`-Fenster) greift nur auf Zeilen mit `\|\| x=$?`; die vier Konsumenten-Aufrufe rufen weder `make` noch `docker` (Zeilen gelesen: `commit-msg`, `commit-msg`, `bash tools/harness/baseline-verify.sh`, `bash .claude/hooks/pretooluse-command-guard.sh`), der Bootstrap-Aufruf steht in `if ! out="$( "$tmpbin/ai-harness-init" … )"` — die Bindung ist nicht gelockert, die Zeilen fordern kein Bild an; dieselbe Form trägt der Bestand an `blind_gruen_ohne_waechter` |
| `docs/user/e2e-abdeckung.md` | geprüft, ohne Befund — `make e2e-abdeckung` unverändert, 22 Stufen/22 Deklarationen; die Stufe 17 nennt `LH-FA-01`, `LH-FA-06`, die Folgestufen sind um eins gerückt |
| Dogfood-Wurzel | geprüft, ohne Befund — `--eol`-Bilanz gleich, `--renormalize` → 0, PNG byte-gleich, `SHA256SUMS`/Guard im autocrlf-Klon ohne CR; `docs/reviews/`-Zeitdokumente tragen im autocrlf-Klon LF wie im Index (die Wurzel-Datei stellt den Index-Zustand her, ändert keinen Index-Blob) |
| Ausgeschlossenes (Renormalisierung im Ziel, `.gitattributes` in `docs/`/`spec/`, Adaptions-Eintrag, Hard-Rule-Änderung, ADR-0067) | geprüft, ohne Befund — `git diff bd76d800..HEAD -- docs/plan/adr` 0 Zeilen; kein Eintrag unter `harness/conventions/`, keine Änderung an `AGENTS.md`; keine Wurzel-Datei im Ziel |
| Kommentare in Go, Vorlage, Skript (§3.7): Klassen, Befund-Kennungen, Slice-Nummern als Erzählung | geprüft, mit Ausnahme MEDIUM-1 ohne Befund — keine Befund-Kennung, keine Runde, keine Slice-Kennung; der Vorlagen-Kommentar trägt keine Kennung dieses Repos; `984f6dd8` ersetzt „belegt" durch „faehrt … ueber den abgelegten Bytes" — die Stufe ist selbst der Sensor, die Umformulierung nimmt die Aussage nicht zurück, sondern nennt den Sensor (ehrliche Korrektur, keine Umgehung) |
| `baumaussage_test.go`: zwei gepinnte Listen um `.gitattributes` ergänzt; Zellen in `internal/emit/baumaussage.go` | geprüft, ohne Befund — die Abwesenheits-Zellen (`tools/harness/`: kein Freshness-Sensor; `harness/mk/`: kein Replay-Gate) bleiben wahr, eine `.gitattributes` widerlegt sie nicht; die Pin-Anpassung ist der Blick, den der Test verlangt |
| Größe, Abgrenzung, Reihenfolge | geprüft, ohne Befund — Liefer-Punkt 2 (Emission 32 Zeilen, Test 261, fünf Fälle) in einer Sitzung prüfbar; Punkt 1 vor Punkt 2 committet (`46730987` vor `1b482a15`), das Rot ist in diesem Lauf reproduziert; drei Liefer-Punkte, zwei Schichten |
| Roadmap-Marker-Commit `7a031289` | geprüft, ohne neuen Befund — entfernt drei Zeilen (Ruhe-Marker) beim Beanspruchen des Slice, dieselbe bekannte Form, die Quelle für die schreibende Rolle fehlt und steht im Register (kein neuer Befund) |
| `git mv` `d691beb5` | geprüft, ohne Befund — reiner Move (100 % Ähnlichkeit, Inhalt `0` Zeilen) |
| Lint-Suppression (§3.2), Docker-only (§3.9) | geprüft, ohne Befund — keine `nolint`/`shellcheck disable` im Diff; Stufe und Test rufen keine Host-Toolchain |
| Handbuch/README | siehe INFO-4 |

## Summary

**0 HIGH · 1 MEDIUM · 2 LOW · 4 INFO.** Klassen für den Steering-Loop-Zähler: *Begründungsklausel im Konjunktiv über die verworfene Alternative* (MEDIUM-1, drittes Vorkommen),
*Eigenschafts-Test prüft die Anwesenheit einer Zeile statt ihrer Wirkung* (LOW-1), *Angleichung an „den Bestand" ohne benannten Maßstab* (LOW-2), *Klassen-Kopplung liest die Klasse aus
der Aufzählung, die sie prüft* (INFO-1). Die Emission trägt `ADR-0067` an allen fünf Festlegungen, die fünf Fälle färben aus dem behaupteten Grund rot, und die Stufe ist ohne die
Emission rot mit gelesener Meldung; merge-blockierend ist nichts. **Empfehlung:** MEDIUM-1 vor Merge klären (vier Kommentare umschreiben), LOW-1/LOW-2 nach Ermessen des Implementers.
