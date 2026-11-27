# Review — slice-stamp-records-konsum-v1 (Konsum des Mutations-Result-Files in Fall-Form)

**Reviewer-Lauf:** frisch, frischer Kontext (Code nicht selbst geschrieben)
**Diff:** `d50bca93..90699185` — 6 Implementer-Commits auf dem Claim-Commit
`eb7619e2`: Plan-Fortschreibung §3 (`d50bca93`), LP1/LP2 (`a9e71fac`),
Posten (a)/(b) (`d25a2e74`), LP3 (`b0812d39`), Anker-Links (`8ef4e328`),
shell-lint-Züge (`90699185`).
**Umfang:** `harness/tools/mutate.sh` (+231), `harness/tools/gates-keys.sh`
(+80/−16), `test/stamp-records-mechanik.bats` (neu, 187), `test/gates-keys.bats`
(+76/−7), `test/mutations/810-…` / `811-…` (neu), `harness/sensors/mutate.md`
(+43), Plan-Datei (+50/−4).
**Gegenstand laut Plan §1/§3:** ADR-0107 Festlegungen 1–5 — das
Treiber-Unterkommando `--stamp-records`, die Fall-Files unter
`.harness/stamp/mutate/`, der Wächter-Zug über dem realen Werkzeug; dazu die
zwei übernommenen Design-Posten aus `slice-gates-pruefgegenstand-stempel-v1`
je ADR-0108 Abwägung E (Aufnahme-Form für die test-Menge, deklarierter
Zuordnungs-Rest `MENGE_REST`).

**Abgrenzung dieses Reviews:** Code gegen Plan §1/§3/§6 und ADR-0107
(Festlegungen 1–5) / ADR-0108 Abwägung E / ADR-0103 (Ablageort, Hash-Ausnahme)
/ ADR-0083 / ADR-0035 Festlegung 3 / MR-059, MR-051, MR-071, MR-090,
MR-017. DoD-Abhakung, Closure-Notiz und Register-Fortschreibung sind nicht
Teil dieses Berichts (Modul-10-Grenze).

---

## Findings

Keine HIGH. Kein Rollenwiderspruch-Fall (Modul 8 Konflikt-Pfad läuft nicht an).

### F-1 — MEDIUM

- `kategorie`: MEDIUM
- `quelle`: `AGENTS.md` §3.6 (das Rot trägt die behauptete Ursache, nicht
  irgendeine) · MR-071/MR-090 (Anlagen-Form)
- `pfad`: `test/mutations/810-stamp-records-konsum-bricht-mit-meldung.sh:15`
  (Zeile `sed -i '/stamp_records_abbruch "Result-File fehlt:/d'`)
- `befund`: Die Anlage löscht nur die Mitte des dreizeiligen if-Blocks; das
  mutierte Werkzeug ist ab da gar nicht mehr parsbar. Bruchprobe auf Kopie
  (Scratchpad, kein Rest im Baum): nach dem sed ergibt `bash -n` „syntax error
  near unexpected token `fi'" (Exit 2; Minimal-Form bestätigt: ein if-Body mit
  leerem List-Ast ist in bash 5.3 ein Parse-Fehler), und der Lauf gegen ein
  fehlendes Result-File bricht sofort am Parse — der im Fall-Kopf behauptete
  Nach-Mutations-Mechanismus („der Konsum liest ein fehlendes oder leeres
  Result-File dann ohne die `stamp-records: ABBRUCH`-Meldung (der Lesefehler
  des bash-Redirects bzw. der `gepruefter Commit:`-Abbruch treten an ihre
  Stelle)") tritt nie ein. Das Rot der benannten Tests 1+2 ist echt, trägt aber
  nicht die behauptete Ursache: es kommt aus dem globalen Parse-Bruch
  (deterministisch: unter dem Mutant färben alle 10 Fälle der Datei, auch die
  Happy-Form). Die Anlagen-Kommentar-Zusage über das Nach-Mutat-Verhalten ist
  damit falsch; der Kopf beschreibt einen erreichbaren Zustand, den die Zeile
  unmöglich macht. Die erste Fassung des Falls (a9e71fac, Bereichs-Löschung
  des ganzen if-Blocks) hatte den behaupteten Mechanismus; der lint-Zug
  90699185 hat sie gegen die Mitten-Löschung getauscht.
- `verifizierbar`: ja — `sed` auf Kopie + `bash -n` +
  `bash <kopie> --stamp-records <fehlt>` (Protokoll unten). Ein Bereichs-Anker
  (`if [ ! -f …` bis `fi` in der lint-clean-Form) würde den
  Zusage-Mechanismus und das Rot in denselben Fall setzen.
- `klasse`: „Mutations-Anlage beschreibt einen Nach-Mutations-Mechanismus, der
  unter ihrer eigenen Mitten-Löschung nicht eintritt — Rot aus Parse-Bruch
  statt aus der entfernten Prüfung"

### F-2 — MEDIUM

- `kategorie`: MEDIUM
- `quelle`: Skill „fehlende Negativtests bei neuem öffentlichem Vertrag" ·
  `AGENTS.md` §3.6 · Plan §2 LP2 („jede fail-closed-Grenze bricht mit Meldung")
- `pfad`: `harness/tools/mutate.sh:1065` (`kein Fall-Verzeichnis`), `:1085`
  (zwei `gepruefter Commit:`-Zeilen), `:1109` (keine Commit-Zeile), `:1112`
  (keine Fall-Urteil-Zeile), `aufgeloest`-Doppelung in
  `stamp_records_main` (zwei Result-Zeilen verschiedener Form lösen auf
  dieselbe Fall-Datei); Argument-Schutz (`--run`/`--attempt` ohne Wert,
  `attempt < 1`, falscher `--qualifikator`) im Kopf von `stamp_records_main`
- `befund`: `test/stamp-records-mechanik.bats` trägt alle drei
  durch ADR-0107 Festlegung 3 deklarierten Grenz**Klassen** (je Klasse
  mindestens ein rot gesehener Fall: fehlend/leer/unlesbar 1–3, doppelte
  Bestimmung 4+7, Kennung 5+6), aber mehrere *Zweige* innerhalb dieser Klassen
  tragen keinen eigenen Wächter und keinen rot gesehene Beleg: (a) doppelte
  Commit-Zeile, (b) keine Commit-Zeile, (c) keine Fall-Urteil-Zeile (mit dem
  realen Vorgang erreichbar: ein Ergebnis-Sweep, in dem jeder Shard ohne Beleg
  bleibt und alle Fälle als FEHLT stehen), (d) die Formen-Varianten der
  doppelten Bestimmung („810-foo-bar" und „foo-bar" in einem Result-File —
  Probrach: die Meldung `… loesen beide auf …` ist aktiv, aber kein Fall misst
  sie; über die `ergebnis_schreiben`-Fassung nicht produzierbar, über ein
  bearbeitetes/fremdes Result-File erreichbar, das der Konsum laut liest),
  (e) Aufruf-Vorbedingungen. Alle brachen im Bruchprobe-Lauf fail-closed mit
  Meldung — das Verhalten ist da; die LP2-Zusage „jede fail-closed-Grenze
  bricht mit Meldung" wird vom Wächter nur über seine selbst aufgezählte
  Untermenge gemessen, und ein Regress an genau diesen Zeilen (etwa eine
  umgestellte Reihenfolge, die die (b)-Abfangung vor der Lesung verliert)
  bleibt grün.
- `verifizierbar`: ja — je Zweig eine Fixture-Bruchprobe (Protokoll unten);
  je ein Negative-Test würde den Zweig binden.
- `klasse`: „Fail-closed-Zweig ohne eigenen rot gesehene Beleg — Klasse
  getragen, Zweig ungebunden"

### F-3 — LOW

- `kategorie`: LOW
- `quelle`: `AGENTS.md` §3.7 (Herkunft als **ein** auflöbares Feld;
  Beleg/Protokoll eines Laufs gehört in die Closure/ADRs, nicht in einen
  Skript-Kommentar); Geltungsbereich: Skripte
- `pfad`: `harness/tools/gates-keys.sh:46`
- `befund`: Die Kopf-Zeile des deklarierten Zuordnungs-Rests trägt als Beleg
  den Vorgang eines Laufs („Mess-Beleg: der Stop-Hook-Mischform-Zug — approve
  an der deklarierten Form") und löst nach keinem Rang auf: „der
  Stop-Hook-Mischform-Zug" ist kein Sensor-Name (keine Datei, kein
  Make-Target) und „approve" ist dessen Ausgang — die Herkunft der
  Rest-Deklaration trägt der Plan (`slice-stamp-records-konsum-v1` §3)
  und als Anker-Form `· seit slice-…`; das Skript-Kommentar nennt sonst nur
  auflösbare Zeiger (Plan-Verweis mit Kennung). Wartungsrisiko: die Zeile
  liest sich als Beleg, den `git` an den Commits des Zugs schon trägt.
- `verifizierbar`: nein; kein Sensor liest Kommentar-Evidenz
  (`make comment-claims` prüft Sensor-Namen, nicht Beleg-Formen).
- `klasse`: „Beleg eines Laufs als Skript-Kommentar — Herkunft ohne auflöbares
  Anker-Feld"

### F-4 — INFO

- `kategorie`: INFO
- `quelle`: Maintainability (Plan §1/LP3-Konsistenz)
- `pfad`: `harness/sensors/mutate.md` (Aufruf-Form im Doku-Block der
  Fall-Granularität)
- `befund`: Die Doku-Form des Unterkommandos nennt `--run`/`--attempt`/
  `--qualifikator`, nicht aber die Option `--wurzel <dir>` (Plan §1 und der
  Wächter-Kopf tragen sie — die hermetische Lesart, die
  `test/stamp-records-mechanik.bats` fährt). Grenzen-Aufzählung sonst
  vollständig (Ort, Zeilen-Form, Kopf-Form, drei Grenzklassen,
  KEIN-Anhang-Form, Reihenfolge). Anregung: die Doku-Form nennt die Option
  mit ihrer Grenze (nur für die hermetische Fixtur-Lesart, im CI-Aufruf
  entfällt sie).
- `verifizierbar`: nein.
- `klasse`: „Aufruf-Form in der Doku-Stelle unvollständig gegen die Plan-Form"

---

## Bruchproben (Scratchpad `/tmp/rev-konsum`, kein Rest im Baum)

Alle Proben an Kopien; `git status` danach clean, `make gates` am Lauf-Ende.

### Fall 810 (F-1)

```sh
cp harness/tools/mutate.sh /tmp/rev-konsum/mutate-ohne-fehlt.sh
sed -i '/stamp_records_abbruch "Result-File fehlt:/d' /tmp/rev-konsum/mutate-ohne-fehlt.sh
bash -n /tmp/rev-konsum/mutate-ohne-fehlt.sh
# /tmp/…/mutate-ohne-fehlt.sh: line 1070: syntax error near unexpected token `fi'
# Minimal-Form (if-Body leer): derselbe Parse-Fehler → Mitten-Löschung selbst bricht
bash /tmp/rev-konsum/mutate-ohne-fehlt.sh --stamp-records /tmp/…/nicht-da.txt --run 42 --attempt 1 --wurzel /tmp/…/wurzel
# → nur der Parse-Fehler, keine `stamp-records: ABBRUCH`-Meldung, kein `gepruefter Commit:`-Abbruch
```
Das Fall-810-Kopf-Verhalten („liest … dann ohne die ABBRUCH-Meldung, der
Lesefehler des bash-Redirects … tritt an seine Stelle") ist unter der Anlage
nicht erreichbar — F-1.

### Fall 811 (kein Befund)

```sh
cp harness/tools/gates-keys.sh /tmp/rev-konsum/gates-keys-ohne-rest.sh
sed -i '/ist_rest_zeile "$f" && continue/d' /tmp/rev-konsum/gates-keys-ohne-rest.sh
bash /tmp/rev-konsum/gates-keys-ohne-rest.sh rest
# → Liste der 15 deklarierten Klassen-Dateien, Exit 1 (auch ohne pipe nachgemessen)
# der Wächter „keys: der Walk liegt ganz in der Tafel-Vereinigung oder einer deklarierten
# Rest-Klasse …" (Test 7) färbt an der `rest`-leer-Zusage rot; die Anker-Zeile steht
# genau einmal im Bestand (MR-071 gemessen)
```

### Konsum-Grenzen (F-2-Klassen, kein Befund je Klasse, F-2-Befund je fehlendem Beleg)

Fixtures im Scratchpad (Fall-Verzeichnis `810-foo-bar.sh`/`811-bar.sh`);
`bash harness/tools/mutate.sh --stamp-records <file> --run 1 --attempt 1 --wurzel <fix>`:

| Probe | Ergebnis |
|---|---|
| fehlendes Result-File | ABBRUCH „Result-File fehlt“ (Wächter-Test 1, Mutations-Fall 810) |
| leeres Result-File | ABBRUCH „Result-File ist leer“ (Test 2, Fall 810) |
| unlesbare Zeile (`ok 810-foo-bar Wobble 0`) | ABBRUCH „unlesbare Result-File-Zeile …" (Test 3) |
| derselbe Fall zweimal im Result-File | ABBRUCH „steht zweimal im Result-File“ (Test 4) |
| unbekannte Kennung `999-gib-es-nicht` | ABBRUCH „kein Treffer (unbekannt)" (Test 5) |
| mehrdeutige Kennung `foo-bar` | ABBRUCH „ist mehrdeutig (8-foo-bar 810-foo-bar)“ (Test 6) |
| Paar `(fall, run, attempt)` im Fall-File | ABBRUCH „steht bereits in …", Bestand byte-gleich (Test 7) |
| zwei Kennungs-Formen → dieselbe Fall-Datei | ABBRUCH „… loesen beide auf …" — **kein Test** (F-2 d) |
| keine `gepruefter Commit:`-Zeile | ABBRUCH „traegt keine 'gepruefter Commit:'-Zeile" — **kein Test** (F-2 b) |
| keine Fall-Urteil-Zeile | ABBRUCH „traegt keine Fall-Urteil-Zeile (ok|BEFUND)" — **kein Test** (F-2 c) |
| kein Fall-Verzeichnis | ABBRUCH „kein Fall-Verzeichnis" — **kein Test** (F-2 e) |

### Kennungs-Formen (MR-059 — gefahrene Formen, kein Befund)

Alle drei zugelassenen Formen gefahren, je aufgelöst: **voller Fall-Name**
(Test 8, Fixture `810-foo-bar`/`811-bar`), **Slug-Form** (Tests 5/6 mit
`foo-bar`/`999-gib-es-nicht`), **reine Nummer** (eigene Probe:
Result-File mit `ok 810`/`BEFUND 811` → `810-foo-bar.txt`/`811-bar.txt`
angelegt, Exit 0, Zeilen- und Kopf-Form je ADR-0107 Festlegung 1/5). Keine
vierte Form gefunden, gegen die die Drei-Formen-Aufzählung fehlt; die
Grenz-Sonde am Nummern-Zweig: `810` löst nicht auf `811-bar`-Formen und `81`
nicht auf `810-foo-bar` — der Präfix-Vergleich (`$kennung-*`) verweigert ohne
Trenner-Verwechslung.

---

## Negativbefunde (geprüft, ohne Befund)

- **Konsum-Vertragsform je ADR-0107 Festlegungen 1–5:** alle drei
  fail-closed-Klassen brechen mit `stamp-records: ABBRUCH`-Meldung vor dem
  ersten Anhang und der Fall-File-Bestand bleibt unverändert (Tabelle oben +
  Wächter-Tests 1–7, die Suite in diesem Review unabhängig grün); FEHLT-/
  UNERWARTET-/kein-Ergebnis-Zeilen bekommen keinen Anhang (Test 8 asserts die
  fehlenden Files); der Kopf je neuem Fall-File trägt Run, Attempt und
  geprüften Commit in der MR-051-Form (je Zahl ein Kommando, Test 8 und
  eigene Probe).
- **Result-File-Lesung gegen den realen Vorgang:** die Regex-Mengen des
  Konsums fassen jede Zeilenform von `ergebnis_schreiben`
  (`harness/tools/mutate-auswahl.sh:264-311`) — Kopfzeilen (inkl. `Shard i:
  KEIN BELEG` über `^Shard [0-9]+: `), Fall-Zeilen der drei Status-Formen
  (`ok`, `BEFUND`, `BEFUND (kein Ergebnis im Log)`), `FEHLT`/`UNERWARTET`,
  `Fallmenge:`/`Wanduhr`/`Urteil:` — der Wächter-Fixture ist byte-genau in
  dieser Fassung; keine Form-Abweichung zwischen Konsum und Produzent.
- **Posten (a), deklarierter Rest:** `bash harness/tools/gates-keys.sh rest`
  leer, Exit 0; je der 10 `MENGE_REST`-Klassen mindestens ein Treffer im
  Ist-Bestand (Verdrahtung 2, VCS 2, `.viper.sh`, LICENSE, 3 gitkeeps,
  `docs/user/images/*` 2, 3 awk-Helper, Homebrew-Formular); die Vereinigung
  der deklarierten Klassen deckt genau die 15 unzugeordneten Dateien des Zugs
  am Kopf (List-Lauf = genau 15 Zeilen) — die Deklaration ist **nicht größer**
  als der Ist-Bestand; der fail-closed Gap-Detektor bleibt (Test 7,
  Fixture `neu-beliebig.txt` → List-Zeile und Exit 1).
- **Posten (a), test-Menge-Zuschlag:** `//go:embed all:templates/{enforce,
  agents,commands}` + `templates/d-check.yml`/`templates/baseline-verify.sh`/
  `templates/observations/README.md` lesen die Vorlagen beim Kompilieren;
  `internal/emit/testdata/raw-print-mk.txt` wird in
  `internal/emit/emit_test.go:391/537` per `os.ReadFile` gelesen — die
  Tafel-Lesart („erreicht zuerst den test-Check; lint und build urteilen über
  Vorlagen-Inhalt nicht") trägt am Quelle-Skript; der Vorlagen-Edit dreht den
  test-Key (Wächter-Test 8, Fixture-Probe). `./.dockerignore` liegt am
  Bestand und liegt seit `d25a2e74` in lint/build.
- **LP3-Granularitäts-Zeile:** trägt Ort, Zeilen-Form, Unterkommando samt
  fail-closed-Grenzen, Kopf-Form-Verweis und KEIN-Anhang-Form; nennt ihre zwei
  Wächter (`test/stamp-records-mechanik.bats`, Fall 810) mit MR-071/MR-090 —
  kein Behauptungspunkt ohne Mess-Form.
- **Record-only-Vertrag (Posten b):** `menge` und `rest` tragen die
  Record-Ablage nicht (Test 6 asserts beide Leaks leer) — beide Richtungen am
  selben Fixture gemessen.
- **Mutations-Fall 811 (`test/mutations/811-deklarierter-rest-entzaubert.sh`):**
  Anlage misst den Anker gegen den Quell-Bestand (die continue-Zeile steht
  genau einmal), Anker am Commit; Bruchprobe in Kopie rot (oben).
- **Fall-810-Anlage (außer F-1):** die Anker-Zeile steht genau einmal
  (`stamp_records_abbruch "Result-File fehlt:`); die `# files:`/`# expect:`-Form
  ist ok; der `sed`-Anker greift auf der Kopie (MR-071-Fähigkeit der Anlage
  selbst).
- **CI-Branch-Form:** das Unterkommando committe nicht und räumt nicht
  (keine git-Aufrufe im Konsum-Zweig; der Hinweis auf die
  Aufrufer-Reihenfolge steht im Ausgabe-Text und Kopf-Kommentar) — kein Rest
  im Baum über alle Bruchproben.

## Gate-Läufe

- `make test-bats BATS_TARGET=test/stamp-records-mechanik.bats` → 10/10 grün
- `make test-bats BATS_TARGET=test/gates-keys.bats` → 13/13 grün
- `make gates` → SKIP über dem vollständig gedeckten je-Check-Satz (13 Checks,
  ADR-0108 Festlegung 3; der Arbeitsbaum deckt den Stempel des
  Implementer-Laufs); die beiden neuen Wächter-Dateien standen in den beiden
  unabhängigen bats-Läufen oben.

## Verifier-Empfehlungen / Übergänge

- **Erster realer Stamp:** die Lesung des Konsums ist an der
  `ergebnis_schreiben`-Fassung nachgelesen, aber der erste Stamp an einem
  echten `mutate-ergebnis.txt` eines CI-Laufs (Commit + `git show FETCH_HEAD`)
  ist der Lauf-Beleg, der den nachgebauten Fixture-Fall schließt — Verifier-
  Seite messen und in der Closure benennen.
- **CI-Branch-Push-Posten:** `mutate/slice-stamp-records-konsum-v1-90699185`
  als Push-Ziel für `make mutate-auswahl` (Fälle 810/811) benannt; der
  lokale Mutations-Lauf wurde in diesem Review über die Anlagen-Kopien
  geführt, nicht über den CI-Zweig.
- **Rest-Klassen-Debatte:** die Deklaration ist zum Ist-Bestand genau (15/15);
  die Zahl 34 in Plan §1 (Übernimmt) ist die datierte Messung des
  Geber-Stands — bei Closure frisch messen
  (`bash harness/tools/gates-keys.sh rest`) und die Messung im Beleg führen.
- **Closure-Form der Risiko-Ausgänge (Plan §6):** Risiko 2 (Umbenennung) trägt
  der Bestand durch Wächter-Test 10 — Ausgang *entfallen* mit Test-Beleg
  möglich; Risiko 3 (Retry-Doppelung) durch Test 9 (Kopf trägt den Commit) —
  ebenfalls *entfallen* mit Test-Beleg; Risiko 1 (Abbruch hinterlässt
  Teilbestand) trägt kein Test im neuen Bestand — prüfen, ob der
  Test-Lauf-Durchlauf (bats über kopiertem Bestand) den Ausgang *entfallen*
  zeigt, sonst *weiter offen* ins Register (Plan-Closure nennt die
  Belegzeilen je Fall).
- **F-1/F-2 an den Implementer:** je Entscheidung (Anker-Form der 810,
  Negative je Zweig) vor der Closure klären; F-3/F-4 sind nice-to-fix.
