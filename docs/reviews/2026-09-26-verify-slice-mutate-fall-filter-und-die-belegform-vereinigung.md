# Verifikationsbericht: slice-mutate-fall-filter-und-die-belegform-vereinigung — 2026-09-26

**Rolle:** Verifier (Modul 8/11), frischer Kontext — Frage: *Bauen wir es richtig?* gegen Plan, DoD und
normative Quellen. Nicht die Frage des Reviewers (Diff gegen Plan, ADR, Hard Rules) und nicht die des
Validators.

**Gegenstand:** Slice `slice-mutate-fall-filter-und-die-belegform-vereinigung` (Kennung, nicht Pfad —
`AGENTS.md` §3.11) am Stand `main` = `a5542c2e`, Baum sauber (`git status --short | wc -l` → 0 zu
Beginn). Implementer-Commits `070af9f5`, `20878b5d`, `d20ebcfc` (vom Reviewer gelesen) und `219fc551`,
`b40b06ed`, `a5542c2e` (**nach** dem Review, von keinem Reviewer gelesen — hier selbst gegen Läufe
geprüft). Review-Report vom 2026-09-26 (0 HIGH · 2 MEDIUM · 3 LOW · 4 INFO). Nichts gepusht. Der Slice
ist **nicht** geschlossen; dieser Bericht setzt kein DoD-Häkchen und ändert weder Slice noch Code, Test,
Doku noch ADR (`AGENTS.md` §3.10).

**Bezug:** `AGENTS.md` §3.6, §3.7, §3.9, §3.10, §3.11 · `LH-QA-02` · `ADR-0035` (**`Proposed`** — hier
nicht als `Accepted` behandelt; Fitness-Zeile *„Ein Lauf mit mindestens einem Befund hinterlässt keinen
Beleg"*, Festlegung 4) · `MR-071` · `MR-025`.

**Methode:** Alle Läufe hermetisch über Docker (bats im `BATS_IMAGE` des Makefiles, `--network none`,
Repo-Kopie read-only eingehängt). Alle Mutationen in Scratchpad-Kopien von `git archive HEAD` — nie im
Repo-Baum. Kein Host-Go, keine Host-Toolchain. **Kein voller `make mutate`.** Der Kopie-Artefakt-Fall
`7 driver: die Kopie traegt den Sensor-Bedarf inklusive .git` ist in jeder `git archive`-Kopie rot (kein
`.git`) und wird unten nie mitgezählt.

---

## Gesamturteil

**Filter und Teillauf tun am echten Lauf, was der Plan sagt; die Vereinigungsregel trägt, was sie
zusagt, ohne mehr als `ADR-0035` Festlegung 4 zu behaupten. Die DoD-Liefer-Punkte 1 und 2 sind bestätigt,
Liefer-Punkt 3 ist bestätigt mit Vorbehalt** (zwei Wortlaut-Unschärfen im Sensor-Doc, V-1 und V-2, beide
LOW; die Prüf-Bedingung 1 ist für einen vollen Lauf mit Befund jetzt erfüllbar, gemessen in einer
bats-Kopie und gelesen im Code). **Kein Befund der Klasse HIGH oder MEDIUM.** Alle sechs von mir
angesetzten neuen Schwächungen und alle Fälle 453 bis 458 färben ihren Wächter rot, jeweils mit
gelesener, zur Schwächung passender Meldung; fünf Gegenproben („grün heißt bindet") binden.

Die Werkzeug-Änderung für R-1 des Reviews (`report_key` im vollen Lauf) ist **Gebaut-nicht-Geplant**
und liegt im Rahmen von §1 und Punkt 3 (i) — sie verändert keine Verdikt-Funktion und nicht die
Belegform —, gehört aber als Plan-Nachzug an den Planner (V-7). Übergaben unten.

---

## Gelaufene Sensoren (Kommando und Ausgang)

**Beleg-Slot** (`.harness/state/mutate-passed.key`, gitignoriert): **vorher fehlend**
(`ls`-Fehler „Datei oder Verzeichnis nicht gefunden"). Ich habe zur Messung einen Platzhalter
(`verifier-dummy-slot`, sha256 `7fd1b18e…80d91d`) gelegt, zwei echte Teilläufe gefahren (`cmp` gegen die
Vorher-Kopie: **byte-gleich** nach jedem) und den Platzhalter wieder entfernt: **nachher fehlend**, wie
vorher. Ich habe keinen Lauf ohne `MUTATE_CASES` gestartet; die acht Sperren-Läufe brachen vor dem
Schlüssel ab, die zwei Teilläufe berühren den Slot nie.

| Sensor | Ergebnis |
|---|---|
| `git archive HEAD` → Kopie, `docker run … bats test/mutate-driver.bats`, keine Mutation | `1..68`, einziges `not ok`: `7 … inklusive .git` (Kopie-Artefakt); `grep -c '^not ok'` → 1 |
| `make mutate MUTATE_JOBS=1 MUTATE_CASES=…` mit `gibt-es-nicht`, leer, `10-ci-workflow-syntax 10-ci-workflow-syntax`, `../mutations/10-ci-workflow-syntax`, `*`, `-x`, `10-ci-workflow-syntax.sh`, `10-ci-workflow-syntax  nope` (mit `TMPDIR` auf ein leeres Verzeichnis) | je `mutate: ABBRUCH — MUTATE_CASES …` mit Namen (leer: `gelesen: ''`; doppelt: `nennt '…' mehrfach`; Pfad-Form: Meldung mit Punkt am Ende, der Pfad-Zweig), Skript-Exit 1, über `make` **2** (`Makefile:200: mutate] Fehler 1`); `ls -A` des `TMPDIR` danach → 0 Einträge; Slot fehlend geblieben. `MUTATE_CASES` erreicht das Skript ohne Änderung am Makefile (`make` exportiert Kommandozeilen-Variablen; auch der leere Wert kommt als *gesetzt, leer* an) |
| **Echter Teillauf** `make mutate MUTATE_JOBS=1 MUTATE_CASES=10-ci-workflow-syntax` (Platzhalter-Slot gelegt) | Exit **0**, `real 0m9,559s`; `MUTATE_CASES waehlt 1 von 446 Faellen — Teillauf.`, `Vollstaendigkeit — 1 von 1 Fall-Dateien …`, `mutate: 1 ok, 0 Befund(e)`, `mutate: TEILLAUF 1 von 446 — kein Beleg (der Beleg-Slot bleibt unberuehrt).`, `mutate: Pruefgegenstand 93cca2c6…07876ec`, `mutate: ok-Faelle: 10-ci-workflow-syntax` — `cat -A` zeigt `$` unmittelbar hinter dem Namen (kein Leerzeichen am Ende); Slot `cmp` **byte-gleich** |
| Zweiter identischer Teillauf | derselbe Schlüssel `93cca2c6…07876ec` (Bedingung 1 der Regel ist über zwei Läufe am selben Baum reproduzierbar); Slot byte-gleich |
| Fälle 453, 454, 455, 456, 457, 458, 263, 264 je einzeln in einer Kopie angewandt, dann bats über `test/mutate-driver.bats` | je rot im `# expect:`-Test, s. §Bewusstes Brechen |
| Die übrigen 25 der 33 Fälle mit `# files:` auf `harness/tools/mutate.sh` (`grep -l '^# files:.*harness/tools/mutate\.sh' test/mutations/*.sh \| wc -l` → **33**), je einzeln in einer Kopie, dann bats | **25 von 25** rot im jeweils benannten `# expect:`-Test; jede Mutation ändert `mutate.sh` (`diff`: 1 bis 5 Zeilen je Richtung, bei 197 nur eine Einfügung) |
| Sechs neue Schwächungen + drei Varianten (Katalog unten) | alle rot, Meldung gelesen |
| Fünf Gegenproben (Test-Assertion geschwächt, Mutation aktiv) | fünf grün am geschwächten Test — die Assertion **bindet** |
| `grep -n 'report_key' harness/tools/mutate.sh` | Kopfkommentar, Definition, zwei Aufrufe (`report_partial` und Zweig des vollen Laufs); `on_signal` und die Abbruch-Pfade rufen ihn nicht |
| `git diff 09159a4a..HEAD --stat -- Makefile docs/plan/adr harness/conventions.md harness/conventions AGENTS.md \| wc -l` | **0** — kein Makefile-, ADR-, Hard-Rule- oder Konventions-Eingriff |
| `grep -n 'ADR-0035' harness/README.md \| wc -l` → 0; `grep -n 'ADR-0035' harness/sensors/mutate.md harness/tools/mutate.sh` | die Treffer stehen ohne Statusaussage (`Festlegung 3/4`, Link); nirgends als `Accepted` behauptet |
| `make gates`, `make record-gates` | s. Nachlauf am Ende |

---

## DoD, Punkt für Punkt

### Liefer-Punkt 1 — der Filter, fail-closed: **bestätigt**

| DoD-Aussage | Urteil | Beleg |
|---|---|---|
| `MUTATE_CASES=<Namen…>` fährt nur die genannten Fälle; Name = Fall-Name aus `mutate: BEFUND  <fall>` | bestätigt | Echter Lauf: `waehlt 1 von 446`, nur der genannte Fall in `ok`; Test 63/66 lesen `03-ungewaehlt` nicht in der Ausgabe |
| unbekannter, leerer, doppelter Name enden mit `mutate: ABBRUCH — …` und dem Namen, **bevor** eine Isolationskopie entsteht; Skript 1, über `make` 2 | bestätigt | acht echte `make`-Läufe (Tabelle): Skript-Exit 1 / `make` 2, `TMPDIR` leer, Slot unberührt; zusätzlich `../…`, `*`, `-x`, `….sh` |
| (a) je Form ein Fall mit Exit 1, Meldung nennt den Namen, keine Kopie | bestätigt | Tests 58 (unbekannt), 59 (Pfad), 61 (leer), 62 (doppelt). Die Kopie-Freiheit ist jetzt **gebunden**: Schwächung m5 (`mktemp -d` vor `select_cases`) färbt 58, 59, 61, 62 mit der Ausgabe *„vor der Pruefung wurde kopiert oder ein Verzeichnis angelegt; Aufrufe: mktemp -d"* — der PATH-Wrapper-Nachweis (Test 60 als Gegenprobe der Sonde: sie sieht `mktemp`/`tar` bei einem gültigen Lauf) |
| Mutation *Filter überspringt unbekannte Namen still* färbt den Fall *unbekannt* rot | bestätigt | Fall 457: rot **58** mit `[ "$status" -eq 1 ]' failed` — der Name ging durch |
| (b) Teillauf fährt **trotz** stehendem Beleg zum aktuellen Schlüssel; Mutation *Übersprung greift auch mit Filter* rot | bestätigt | Fall 456: rot **63** mit `[ "$(grep -cF 'Kein Fall-Lauf' <<<"$output")" -eq 0 ]' failed` |

### Liefer-Punkt 2 — Teillauf erkennbar kein Beleg, berührt den Slot nie: **bestätigt**

| DoD-Aussage | Urteil | Beleg |
|---|---|---|
| Ausgabe nennt `TEILLAUF <n> von <total> — kein Beleg`, den Schlüssel (oder *nicht berechenbar*), die `ok`-Namen | bestätigt | Echter Lauf wörtlich (Tabelle): alle drei Zeilen, `ok-Faelle:` ohne Leerzeichen am Zeilenende. Test 66 prüft zwei Namen mit einfachem Leerzeichen dazwischen und ohne Ende (`grep -qxF`) |
| schreibt den Slot nie (auch bei grün), löscht ihn nie (auch bei Befund), keine Sofort-Entwertung; Exit wie ein Lauf | bestätigt | Echter Teillauf: Platzhalter byte-gleich (`cmp`), Exit 0; Test 65 (Befund, Exit 1, `cmp` byte-gleich) |
| (c) Mutation *`finalize_belief` schreibt im Teillauf* und *Sofort-Entwertung im Teillauf* färben je ihren Fall rot | bestätigt | 453: rot **64** (`[ ! -e …key ]`) und **65** (der Befund-Zweig von `finalize_belief` löscht den stehenden Slot); 454: rot **65** (`cmp` — Slot weg) |
| (d) Mutation *Meldung sagt „Beleg"*; gelesene Meldung nennt das fehlende „kein Beleg" | bestätigt | 455: rot **66** und **65**; die fd-3-Ausgabe des Tests lautet wörtlich `die Ausgabe nennt kein 'TEILLAUF 1 von 3 — kein Beleg'; sie lautet: … mutate: TEILLAUF 1 von 3 — Beleg (der Beleg-Slot bleibt unberuehrt).` |

### Liefer-Punkt 3 — die Regel der Vereinigung: **bestätigt mit Vorbehalt**

| DoD-Aussage | Urteil | Beleg |
|---|---|---|
| Regel nennt (i) gleicher Schlüssel, (ii) gelesene, fall-fremde Ursache und im Teillauf `ok`, (iii) Aussage im Bericht, nie im Slot | bestätigt | `harness/sensors/mutate.md` §Zwei Läufe, eine Aussage: drei Bedingungen, Wortlaut deckt (i)–(iii) und grenzt Befunde des Falls selbst aus (`blieb GRUEN`, falscher Grund am Wächter) |
| Bedingung 1 ist für den **Hauptlauf** erfüllbar | bestätigt | Vorher (Review R-1): voller Lauf mit Befund druckte keinen Schlüssel. Jetzt: `report_key` im Zweig des vollen Laufs, gemessen in der bats-Kopie — Test 67 (voller Lauf **mit** Befund nennt `mutate: Pruefgegenstand <TL_KEY>`, Slot bleibt weg) und 68 (grün, schreibt den Slot mit demselben Schlüssel). Schlüssel-Gleichheit Teil/Voll: derselbe `isolation_key` (`belief_key`) in beiden Zweigen, gelesen `main()` |
| „Endet der volle Lauf vorher (Sperre, Grün-Vorlauf, Signal), steht keine Zeile da" | **bestätigt mit Vorbehalt** | Sperren (`exit 1` vor `report_key`), Signal (`on_signal` ruft ihn nicht) und der Vorlauf **vor** dem Fork (`green_prerun test-go \|\| exit 1`) enden ohne Zeile — gelesen. **Aber:** der Grün-Vorlauf **im Worker** (`abort_run` setzt nur eine Flagge, `worker_done 1`) lässt `main()` bis zum Bericht weiterlaufen; `report_key` steht dann da (gelesen, **nicht** gefahren) — V-1 |
| Zustandsform, keine Chronik, Zahlen mit Kommando | bestätigt | Doc-Text der Regel und des Absatzes *Teillauf*: Indikativ, kein Konjunktiv über verworfene Fassungen; keine Zahl im neuen Text (`453 bis 458` ist eine Aufzählung; `Skript 1, über make 2` ein Exit-Code, belegt durch die acht `make`-Läufe) |
| **Grenze:** Ausschnitt jedes Laufs, nicht ein einzelner grüner Vollauf; Docker-Cache-Rest `ADR-0035` Festlegung 4 gilt weiter; Kosten nennt `report_times`, keine Zahl im Text | bestätigt | Grenze-Absatz vorhanden; Festlegung 4 wörtlich verlinkt und ohne Zusage darüber hinaus (Cache-Zustand und Host-Werkzeuge bleiben Rest); Kosten im Absatz *Teillauf* (`report_times`), keine Zahl. Unschärfe: V-3 |
| Absatz zum Filter (Aufruf, Sperren) | bestätigt | §Sperren (`MUTATE_CASES …` mit `make`-Exit 2) und §Teillauf; jede Aussage dort ist oben am echten Lauf gemessen, ausgenommen die Ordnung der Ausgabe (sortiert, gelesen: `for cf in "${cases[@]}"`) |
| (e) `make docs-check` grün | siehe Nachlauf (Gate) | Prosa; kein Doku-Modul hält den Inhalt — der Träger ist die Rolle, das steht im Absatz |
| README-Zeile `make mutate` nennt den Filter, bleibt *kein Gate* | bestätigt | `git diff` auf `harness/README.md`: eine Zeile, Bindung unverändert `kein Gate · AGENTS.md §3.6` |

**Trägt die Regel die frühere Praxis, ohne mehr zuzusagen, als `ADR-0035` Festlegung 4 trägt?** Sie trägt
sie sinngemäß: das Muster *ein Lauf endet an der Infrastruktur, die Fälle ohne Verdikt laufen einzeln
nach* ist Hauptlauf + Teillauf über denselben Schlüssel. **Wörtlich** deckt sie die beiden vollen Läufe
der Beobachtung (`425 ok, 8 Befund(e)` und `432 ok, 1 Befund(e)`) nicht — dort war der zweite Lauf voll,
nicht ein Teillauf (V-2). Mehr als die ADR sagt die Regel nicht zu: sie nennt den Cache-Rest, macht die
Aussage zum Bericht-Inhalt und keinen Beleg, und benennt die Rolle als Träger.

### Übrige DoD-Zeilen

| Zeile | Urteil |
|---|---|
| `make gates` grün | am Endstand: s. Nachlauf |
| Review durchgeführt, Report liegt vor | Report vom 2026-09-26 liegt vor; er deckt `070af9f5`…`d20ebcfc`. Die drei Commits danach hat **kein** Reviewer gelesen — Vorbehalt, hier durch eigene Läufe gedeckt, ersetzt keinen Review-Durchgang (Übergabe) |
| Closure-Notiz, Beobachtungs-Register, Risiko-Ausgänge, Paarungen, DoD-Häkchen | **Planner-Arbeit** (`AGENTS.md` §3.10) — von mir weder geprüft noch gesetzt; Ausgangs-Vorschläge unten |

---

## Bewusstes Brechen (Rot gesehen, Meldung gelesen)

Jede Zeile: Schwächung in einer `git archive`-Kopie, bats über `test/mutate-driver.bats`, Meldung
gelesen (die bats-Zeile `... failed` unter dem `not ok`), ob die Begründung zur Schwächung passt.

### Fälle 453 bis 458, 263, 264

| Fall | rot in | Meldung / Passung |
|---|---|---|
| 453 (`finalize_belief` im Teillauf) | 64, 65 | `[ ! -e …mutate-passed.key ]' failed` bzw. Slot verändert — passt: der Teillauf schreibt/löscht den Slot |
| 454 (Sofort-Entwertung im Teillauf) | 65 | `cmp` gegen die Vorher-Kopie schlägt an — passt |
| 455 (Meldung ohne „kein") | 65, 66 | `grep -qF 'mutate: TEILLAUF 2 von 3 — kein Beleg'` bzw. die Test-eigene Meldung mit der geänderten Zeile — passt |
| 456 (Übersprung greift mit Filter) | 63 | `[ "$(grep -cF 'Kein Fall-Lauf' …)" -eq 0 ]' failed` — passt |
| 457 (unbekannter Name still) | 58 | `[ "$status" -eq 1 ]' failed` — passt |
| 458 (`report_key` im vollen Zweig gestrichen) | 67, 68 | `grep -qxF "mutate: Pruefgegenstand $TL_KEY"` bzw. die Test-eigene Meldung — passt; zwei Tests binden ihn |
| 263 (Anker nachgezogen) | 56 | Fall greift am neuen Stand; `diff`: genau die Zeile `[ -n "$partial" ] \|\| clear_belief` gelöscht |
| 264 | 57, 67 | 57 wie erwartet; 67 zusätzlich (der Test legt einen stehenden Beleg und fährt voll) — Nebenwirkung, kein Mangel |

### Neue Schwächungen (nicht die des Reviews wiederholt, außer wo genannt)

| Schwächung | rot in | Meldung / Passung |
|---|---|---|
| m2 — leerer Wert fällt auf den vollen Lauf zurück (`${MUTATE_CASES:-}` statt `+x`) | 61 | `grep -qF 'mutate: ABBRUCH — MUTATE_CASES ist gesetzt, nennt aber keinen Fall'` fehlt — passt |
| m3 — doppelter Name durchgelassen (`*" $name "*)`-Zweig tot) | 62 | Meldung `… nennt '01-ok' mehrfach` fehlt — passt |
| m4 — Filter wählt alle Fälle | 60, 63, 64, 65, 66 | `[ "$status" -eq 0 ]' failed` (`02-befund` läuft mit und färbt den Lauf), 65 an der TEILLAUF-Zeile — passt für *die Menge wächst*; **die `03-ungewaehlt`-Zeile allein ist nicht einzeln belegt** (V-5) |
| m5 — `mktemp -d` vor `select_cases` (Reviewer-Mutation R-2) | 58, 59, 61, 62 | `vor der Pruefung wurde kopiert …; Aufrufe: mktemp -d` — passt; **die Lücke aus R-2 ist geschlossen** |
| m6 — Pfad-Zweig `*/*` auf `""` (Reviewer-Mutation R-3) | 59 | `false' failed` nach der Test-eigenen Meldung des Pfad-Zweigs — passt; **R-3 geschlossen** |
| m7 — Teillauf mit Befund ohne „kein Beleg" (`[ "$fail_count" -ne 0 ] \|\| report_partial …`, Reviewer-Mutation R-4) | 65 | `grep -qF 'mutate: TEILLAUF 2 von 3 — kein Beleg'` fehlt — passt; **R-4 geschlossen** |
| m8a — `report_key` nur bei grün | 67 | Schlüssel fehlt im vollen Lauf **mit Befund** — passt |
| m8b — `report_key` nur bei Befund | 68 | Schlüssel fehlt im grünen vollen Lauf — passt |
| m9 — `report_partial` ohne `report_key` | 66 | `grep -qF "mutate: Pruefgegenstand $TL_KEY"` fehlt — passt |

### Gegenprobe „grün heißt bindet" (Assertion des Tests geschwächt, Mutation aktiv)

| Mutation + Schwächung des Tests | Test danach | Urteil |
|---|---|---|
| 453 + letzte `[ ! -e …key ]`-Zeile aus Test 64 gestrichen | **64 grün** (65 bleibt rot: eigener Zahn) | die gestrichene Zeile bindet |
| 454 + `cmp`-Zeile aus Test 65 gestrichen | **65 grün** | `cmp` bindet |
| 455 + `if ! grep … TEILLAUF 1 von 3 …`-Block aus Test 66 gestrichen | **66 grün** (65 bleibt rot: eigener Zahn) | der Block bindet |
| 456 + beide Zeilen (`Kein Fall-Lauf`, `ok +01-ok`) aus Test 63 gestrichen | **63 grün** | die Zeilen binden; sie sind zu zweit redundant gegeneinander |
| 458 + `if ! grep -qxF "…Pruefgegenstand…"`-Block aus Test 67 gestrichen | **67 grün** (68 bleibt rot: eigener Zahn) | der Block bindet |

### Emulation der 33 Bestandsfälle auf `harness/tools/mutate.sh`

Alle 33 (8 in der Tabelle oben, 25 in einem Stapel): **33 von 33** färben den `# expect:`-Test rot; kein
Fall lässt die Datei unverändert. MR-071-Anker: die Zahl der geänderten Zeilen je Fall (`diff`) ist bei
263, 458 genau 1 gelöschte, bei 453 genau 1 eingefügte, bei 454 bis 457 und 264 genau 1 ersetzte Zeile; der
Anker trifft also je genau eine Zeile (gemessen an der Wirkung, nicht mit `grep -c` je Muster).
Der Auftrag nannte 32 Fälle — das ist die Zahl des Reviews vor Fall 458; am Stand `HEAD` liefert
`grep -l '^# files:.*harness/tools/mutate\.sh' test/mutations/*.sh | wc -l` **33**.

---

## Plan-vs-Code-Diff

**Geplant und gebaut:** Filter (`select_cases`, Aufruf in `main()` vor `belief_key`), Teillauf-Zweige an
genau den **drei** Stellen des Plans (Übersprung, Sofort-Entwertung, Schluss), `TEILLAUF`-Zeile
(`report_partial`); Sperren-, Slot- und Meldungs-Tests in `test/mutate-driver.bats`; Fälle für *schreibt*,
*entwertet*, *sagt „Beleg"*; Sensor-Doc mit Filter, Sperren, Regel, Grenze; README-Zeile. Das Makefile
blieb unberührt (Plan: *nur falls nötig* — gemessen: nicht nötig).

**Gebaut, nicht geplant (§3-Tabelle und DoD nennen es nicht):**

- Fälle **456** (Übersprung mit Filter) und **457** (unbekannter Name still) — beide binden; Plan nannte
  drei Fälle.
- Fall **458** und `report_key` im Zweig des **vollen** Laufs (`harness/tools/mutate.sh`, `main()`), samt
  Tests 67 und 68. Das ändert die Ausgabe des vollen Laufs um **eine Zeile**; Verdikt-Funktion, Slot,
  Exit und Bezugsmenge des Schlüssels bleiben unberührt (`git diff` zeigt nur die Einfügung im
  `else`-Zweig). Lösung des Review-Befunds R-1 **durch Werkzeug** statt durch den Wortlaut der Regel.
- PATH-Wrapper-Sonde (`tl_probe`, `tl_ohne_kopie`, Test 60) und die Tests 58 bis 68 insgesamt — 11 Tests;
  der Plan nennt Fälle (a) bis (d) je Form, nicht ihre Zahl.
- Anker von Fall 263 nachgezogen (nötig, weil die Zeile durch die Bedingung wanderte — gemessen: 263 ist
  rot in Test 56).
- Ausgabe `ok-Faelle:` ohne Leerzeichen am Ende (Review R-9 a), Kommentar von `select_cases` in
  Zustandsform (R-5).

**Geplant, nicht gebaut:** nichts. Die Closure-Bestandteile (Notiz, Register, Risiko-Ausgänge, Häkchen,
Ruhe-Marker) stehen dem Planner zu.

**Bewertung der R-1-Lösung gegen §1 und die Abgrenzung (zur Entscheidung des Planners, nicht umgeschrieben):**
Punkt 3 (i) der DoD setzt voraus, dass **beide** Läufe den Schlüssel nennen; der volle Lauf tat es nicht,
also war entweder der Wortlaut der Regel oder die Ausgabe zu ändern. §1 schließt weder eine Ausgabezeile
am vollen Lauf aus noch führt es die Beleg-Prüfung ohne Lauf und die Verengung der Bezugsmenge — beides
gehört dem Schwester-Slice `slice-mutate-beleg-gilt-ueber-rollen-dokumente-und-ist-ohne-lauf-lesbar`, und
beides ist hier unberührt (dessen Datei ist nur durch den Verweis-Nachzug von `09159a4a` berührt: zwei
Zeilen `next/` → `in-progress/`, Werkzeug-Mechanik von `make slice-mv`; `git diff cbd0ffdf..HEAD --stat`
auf `open/` nennt genau diese Datei mit 2 Einfügungen und 2 Löschungen). Die Rückführungs-Bedingung
`in-progress → open` (Regel ohne Änderung der Belegform nicht entscheidbar) tritt nicht ein: der Slot
und seine Semantik sind unverändert. **Aber:** `report_key` wird ein Bestandteil des Ausgabe-Vertrags des
vollen Laufs, den der Schwester-Slice in Punkt 2 (Meldung *gilt / gilt nicht* samt Schlüssel-Grund)
mitliest — der Planner gleicht beide Pläne ab (Übergabe P-4). Größe: drei Liefer-Punkte, Schichten
Werkzeug + Test und Doku (zwei); `git diff 09159a4a..HEAD --stat` nennt `harness/tools/mutate.sh` +117,
`test/mutate-driver.bats` +223, `harness/sensors/mutate.md` +55 — der Reviewer hat den Teil bis
`d20ebcfc` in einer Sitzung geprüft; die Rückführung `in-progress → next` ist nicht ausgelöst.

Eingefrorene Zeitdokumente nicht umgeschrieben: `git diff cbd0ffdf..HEAD --stat -- docs/plan/adr docs/plan/planning/done docs/reviews`
nennt allein den Review-Report des Reviewers (1 Datei, 95 Einfügungen, keine Löschung); ADRs, `done/`, Hard Rules, `harness/conventions*` und `Makefile` sind
unberührt (Tabelle oben: 0). Der Ruhe-Marker *Nichts in Arbeit* steht in der Roadmap nicht mehr
(`grep -n 'Nichts in Arbeit' docs/plan/planning/in-progress/roadmap.md` → kein Treffer), solange der
Slice in `in-progress/` liegt.

---

## Befunde

| Id | Klasse | Sev. | Befund |
|---|---|---|---|
| V-1 | Zusage breiter als ihr Beleg (Klammer-Aufzählung) | LOW | Doc §Zwei Läufe, Bedingung 1: *„Endet der volle Lauf vorher (Sperre, Grün-Vorlauf, Signal), steht keine Zeile da"*. Für den Grün-Vorlauf **vor dem Fork** stimmt das (`green_prerun test-go \|\| exit 1`); der Vorlauf **im Worker** (`abort_run`, `worker_done 1`) lässt den Lauf bis `report_key` weiterlaufen — er ist der Fall *„Infrastruktur, bevor der Fall urteilt"*, den die Regel gerade tragen soll, und druckt den Schlüssel (**gelesen, nicht gefahren**; kein Test hält die Zeile für diesen Zweig). Belegt ist die Klammer für Sperre und Signal; für *Grün-Vorlauf* nur zur Hälfte. |
| V-2 | Wortlaut-Lücke gegen den Anlass | LOW | Die Regel spricht von *Hauptlauf und Teillauf*; der Anlass (`425 ok, 8 Befund(e)` / `432 ok, 1 Befund(e)`, zwei **volle** Läufe) fällt wörtlich nicht darunter. Der Plan (Punkt 3) formuliert dieselbe Zweiteilung — kein Bruch gegen den Plan, aber die zitierte frühere Praxis ist mit der Regel nur über eine Auslegung (*der zweite Lauf ist ein Teillauf über die Befund-Fälle*) gedeckt. |
| V-3 | Unscharfer Begriff | LOW | Grenze-Satz: *„ihre Schnittmenge"* — der Bericht trägt die **Vereinigung der `ok`-Mengen**; die Schnittmenge (die im Teillauf wiederholten Fälle) ist das, was Bedingung 2 prüft. Der Plan-Wortlaut der Grenze nennt sie nicht. Lesbar, aber missverständlich. |
| V-4 | §3.7 (Konjunktiv über die verworfene Alternative) | LOW | In neu geschriebenen Kommentaren von `test/mutate-driver.bats`: *„Ohne den Zweig loeste `../mutations/01-ok` … zu einer echten Datei auf"* und *„ohne diesen Test bewiese ein leeres Protokoll nichts"*. Ferner sagt der Kommentar in `main()` weiter *„darum wird hier bedingungslos geloescht"*, gefolgt von der neuen Zeile *„Ein Teillauf entwertet nicht …"* — ohne die Bedingung im Satz davor lesbar als Widerspruch. Cutoff (§3.7): gebunden ist, was geschrieben oder geändert wurde. |
| V-5 | Zahn nicht einzeln belegt | INFO | Unter *„Filter wählt alle"* färbt Test 63 über den Status (`02-befund` läuft mit), nicht über die Zeile *„`03-ungewaehlt` steht nicht in der Ausgabe"*. Die Zeile ist nicht einzeln gegengeprobt; die Eigenschaft *„der Filter verkleinert"* ist über `TEILLAUF 2 von 3` (Test 65) und die Status-Assertions gehalten. |
| V-6 | Zahl im Auftrag | INFO | 33 statt 32 Fälle auf `mutate.sh` (Fall 458 ist hinzugekommen; Kommando oben). |
| V-7 | Plan-vs-Code | INFO | `report_key` im vollen Lauf (und Fälle 456 bis 458, Tests 58 bis 68) sind gebaut, nicht geplant — s. Plan-vs-Code-Diff. |
| V-8 | Ungelesen | INFO | Die drei Commits `219fc551`, `b40b06ed`, `a5542c2e` haben keinen Reviewer-Durchlauf. |

Der Reviewer-Befund **R-6** (Fitness-Zeile *„Ein Lauf mit mindestens einem Befund hinterlässt keinen
Beleg"* gegen *„ein Teillauf mit Befund lässt den Beleg des letzten vollen Laufs stehen"*) besteht
unverändert und geht an den Architect. Bestätigt habe ich: der Wortlaut des Sensor-Docs und des Plans
verlangt das Stehenlassen (§Teillauf: *„löscht ihn nie — auch bei einem Befund nicht"*), Test 65 hält es,
die Fitness-Zeile bezieht sich nach ihrem Wortlaut auf den Schreibpunkt hinter der Bedingung, unter der
`main()` seinen Exit bildet — der Teillauf **schreibt nicht**; ob ein Teillauf ein *Lauf* im Sinne der
Zeile ist, ist eine Formulierungsfrage der ADR.

---

## Ehrlich: nur gelesen oder nicht gemessen

- **`on_signal` druckt keinen Schlüssel:** nur `grep -n 'report_key'` (3 Fundstellen, keine in
  `on_signal`); kein Signal-Lauf gefahren.
- **Worker-Grün-Vorlauf-Abbruch mit `report_key` (V-1):** aus dem Code gelesen; kein Test, kein Lauf.
- **Ordnung der `ok`-Namen** (*sortiert wie das Verzeichnis, nicht wie die Anfrage*): gelesen
  (`for cf in "${cases[@]}"`); Test 66 nennt zwei Namen in Verzeichnis-Reihenfolge, nicht in umgekehrter.
- **Reale Kosten des Teillaufs:** einmal gemessen für einen `ci-lint`-Fall (`real 0m9,559s`, Isolationskopie
  und Grün-Vorlauf eingeschlossen). Kosten eines `test`-Modus-Falls (Docker-Stage) und ein Lauf mit **echtem**
  Befund am echten Treiber sind nicht gemessen; der Befund-Zweig ist über das Fake-Repo der bats-Tests
  gemessen (65, 67).
- **Kein voller `make mutate`:** deshalb ist die Aussage *„ein grüner voller Lauf schreibt den Slot mit
  dem Schlüssel"* nur am Fake-Repo gemessen (Test 68), nicht am echten Satz; das Verhalten des vollen
  Laufs außerhalb der einen neuen Zeile ist Bestand.
- **Docker-Cache-Rest** (`ADR-0035` Festlegung 4): von keinem Sensor dieses Slice gedeckt und nicht behauptet.
- **Beobachtung `sensor-lauf-endet-rot-an-der-infrastruktur-bevor-der-fall-urteilt`:** ich habe in diesem
  Lauf keinen Infrastruktur-Ausfall erlebt; für sie fällt aus meinem Lauf kein Beleg an.

---

## Übergaben

### An den Planner

- **P-1 — Risiko-Ausgänge (Vorschläge, das Urteil ist deins):**
  R1 (grüner Teillauf als Beleg zitiert) → *weiter offen*, Register: Zeile und Regel sind der Wächter, Test
  66 hält die Zeile (rot gesehen), der Leser, der die Ausgabe nicht liest, wird nicht erreicht.
  R2 (Teillauf mit Befund lässt den Slot stehen) → *weiter offen*, verbunden mit R5 und R-6 beim Architect.
  R3 (Fall-Name veraltet) → *entfallen* mit Begründung: der Filter bricht mit dem Namen ab, gemessen
  (acht echte `make`-Läufe, Test 58).
  R4 (Teillauf spart weniger als er verspricht) → *weiter offen*: ein Messwert (`ci-lint`, 9,559 s), kein
  Wert für `test`-Modus-Fälle.
  R5 (`ADR-0035` `Proposed`) → *weiter offen*, bis die Annahme die Fitness-Zeile festlegt.
- **P-2 — Beobachtungs-Register, Klassen-Kandidaten:**
  (a) `negation-mitten-im-bats-fall-ohne-wirkung` (heute `ls docs/plan/planning/observations/BEO-ALL/negation-mitten-im-bats-fall-ohne-wirkung/evidence | wc -l`
  → 1): der Bestand von `test/mutate-driver.bats` trägt die Form weiter —
  `grep -c '^  ! grep' test/mutate-driver.bats` → **19**, davon nicht als letzte Anweisung ihres Tests
  `awk '/^  ! grep/{getline n; if (n != "}") c++} END{print c+0}' test/mutate-driver.bats` → **12** (der
  Review nannte 13 mit einem anderen Zählmuster; keine Erwartungswerte); die **neuen** Tests meiden die
  Form (`git diff 09159a4a..HEAD -- test/mutate-driver.bats | grep -c '^+  ! grep'` → **0**). Ein Beleg
  aus diesem Vorgang ist zulässig; Bestand ist kein Auftrag dieses Slice.
  (b) Klasse *Leer-Probe nach einem Aufräum-Trap* (Review R-2, jetzt durch die PATH-Wrapper-Sonde gedeckt):
  Beleg-Kandidat für `zusicherung-ueber-der-leeren-menge-wahr` oder eine neue Beobachtung — Zuordnung ist
  dein Urteil.
  (c) Klasse *Regel verlangt einen Beleg, den die Ausgabe des Werkzeugs nicht liefert* (Review R-1, durch
  Werkzeug-Änderung gelöst).
- **P-3 — Ruhe-Marker:** `in-progress/` trägt den Slice; der Marker *Nichts in Arbeit* steht deshalb
  nicht. Bei der Closure (Slice nach `done/`) ist er wieder zu setzen; die `roadmap`-Kopplung hält ein
  Doku-Sensor in beide Richtungen.
- **P-4 — Schwester-Slice `slice-mutate-beleg-gilt-ueber-rollen-dokumente-und-ist-ohne-lauf-lesbar`:**
  `report_key` ist neuer Bestand im vollen Lauf; sein Punkt 2 (*gilt / gilt nicht*, Grund *Schlüssel nicht
  berechenbar*) und seine Verengung der Bezugsmenge (Punkt 1) ändern den Schlüssel, nicht die Zeile. Plan
  und Meldungs-Wortlaut sind abzugleichen, bevor er in `next/` geht. Die Datei ist hier unberührt.
- **P-5 — Plan-Nachzug:** §3-Tabelle (Zeile `mutate.sh`: die Ausgabezeile des vollen Laufs) und Punkt 2/3
  der DoD nennen `report_key` nicht; ob der Nachzug ein Plan-Update oder ein Hinweis in §7 ist, entscheidest
  du (die ausführende Rolle schreibt ihr Abnahmekriterium nicht um, `AGENTS.md` §3.10).
- **P-6 — V-1 bis V-4** (Wortlaut der Regel und Kommentare) sind LOW und ändern keine DoD-Aussage; ob sie
  im Slice oder als Folge behandelt werden, ist deine Entscheidung. Ein weiterer Review-Durchgang über
  `219fc551`, `b40b06ed`, `a5542c2e` ist nicht durchgeführt (V-8).
- **P-7 — `ADR-0035` `Proposed`:** keine Bedingung des Slice (Plan §4); die Annahme ist Architect-Arbeit
  und darf den Slice nicht blockieren.

### An den Architect

- **R-6 (unverändert aus dem Review):** bei der Annahme von `ADR-0035` die Fitness-Zeile *„Ein Lauf mit
  mindestens einem Befund hinterlässt keinen Beleg"* gegen die Slice-Entscheidung *„ein Teillauf mit Befund
  lässt den Beleg des letzten vollen Laufs stehen"* formulieren — z. B. *voller Lauf* statt *Lauf*, oder der
  Teillauf als eigener Fall. Ein Test hält die Slice-Entscheidung schon (Test 65, Fälle 453/454); nach
  der Annahme sollte die Fitness-Tabelle ihn nennen.
- **Bestätigung ohne Änderungswunsch:** die Vereinigungsregel sagt über den Docker-Cache-Rest (Festlegung
  4) nicht mehr zu, als die ADR trägt; sie erwähnt die ADR und behauptet ihren Status nicht.

---

## Nachlauf: Gate und Stempel

Wird nach diesem Bericht gefahren (`make gates`, `make record-gates`); das Ergebnis steht in der
Rückmeldung des Laufs an den Aufrufer, nicht hier — dieser Bericht ist ab dem Commit eingefroren.
