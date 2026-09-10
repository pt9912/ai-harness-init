# Verifikation — slice-073: Welche Doc-Gate-Module ein frisch gebootstrapptes Ziel bekommt

**Rolle:** Verifier (Modul 11, frischer Kontext) · **Datum:** 2026-09-10

## Eingang

- **Slice-Plan:** [`docs/plan/planning/in-progress/slice-073-emittierte-doc-gate-module.md`](../plan/planning/in-progress/slice-073-emittierte-doc-gate-module.md)
  — alle fünf DoD-Häkchen `[ ]` (korrekt, §3.10: Closure ist Planner-Arbeit).
- **Fünf Review-Reports:** [Runde 1](2026-09-10-slice-073-emittierte-doc-gate-module.md) (2 HIGH/2 MEDIUM,
  blockierend) · [Runde 2](2026-09-10-slice-073-emittierte-doc-gate-module-runde-2.md) (1 HIGH/1 MEDIUM/2 LOW,
  blockierend) · [Runde 3](2026-09-10-slice-073-emittierte-doc-gate-module-runde-3.md) (1 HIGH/2 MEDIUM/3 INFO,
  blockierend) · [Runde 4](2026-09-10-slice-073-emittierte-doc-gate-module-runde-4.md) (1 HIGH/3 MEDIUM/2 INFO,
  blockierend) · [Runde 5](2026-09-10-slice-073-emittierte-doc-gate-module-runde-5.md) (0 HIGH/1 MEDIUM/2 LOW/2
  INFO, **nicht** blockierend, „kann an den Verifier übergeben werden").
- **Commit-Kette (Plan-Umfang):** `bcf652b9` (erster Slice-Commit) … `71f3fd9b` (letzter von Runde 5 geprüfter
  Commit). **Danach, außerhalb der Review-Kette, auf Auftraggeber-Weisung:** `5a3108d4`, `f4b900bf`
  (§3.7-Kommentar-Bereinigung in `internal/emit/`). **Dazwischen, in Planner-Rolle, nicht Gegenstand dieser
  Verifikation:** `b9774fbb` (§1-Korrektur), `3ec90d11` (§6-Ergänzung + slice-208).
- **Baum bei Prüfungsbeginn:** `git status --porcelain` leer, `HEAD` = `f4b900bf`, `origin/main` deckungsgleich.
- **Betriebsauflage dieser Verifikation:** kein `make gates`/`mutate`/`full-smoke`/`test`/`docker build` selbst
  gefahren — ein `make mutate`-Lauf (lokal, `MUTATE_JOBS=2`, seit 18:58) und ein CI-Lauf für `HEAD` teilen sich
  Docker-Tags. Evidenz stattdessen über: den vorhandenen `record-gates`-Stempel (reiner Hash-Vergleich, kein
  Docker), `gh run view` (read-only) gegen den laufenden CI-Lauf für genau diesen Commit, und einen einzelnen
  `docker run --network none` gegen den gepinnten Digest gegen eine Kopie außerhalb des Repos.

## 1. DoD Punkt für Punkt — Sache statt Häkchen

**(1) Emittierte Konfiguration führt die entschiedene Modul-Liste, frisches Ziel grün.**

- `internal/emit/templates/d-check.yml`: `modules: [links, anchors, ids, matrix, spans]` — gelesen, exakt.
  `ids` trägt nur `{regex: 'ADR-\d{4}', target: docs/plan/adr/, link-policy: always}`, das Requirement-Muster
  bleibt als `#`-Zeile mit `<PREFIX>`. `matrix` trägt vier Klassen (`spec-straten` mit `order:`/
  `direction: no-downward`, `adr`, `slice` mit `token: 'slice-\d{3}'`, `welle` mit `token: 'welle-\d{2}'`),
  die Regeln `{from: spec-straten, to: adr|slice, allow: false}`, `{from: adr, to: slice|welle, allow: false}`,
  `status: {forbidden: [superseded, deprecated]}`, `exclude-sections: [Geschichte]`. Der Kommentar über der
  `{from: adr, to: slice}`-Regel nennt den Zeilen-Marker `<!-- d-check:status-provenance -->` als „**der
  vorgesehene** Ausweg" — Wortlaut deckungsgleich mit der DoD-Forderung.
- **Autoritäts-Block selbst nachgemessen** (nicht aus Runde 5 übernommen):
  `T=.harness/baseline/v6.5.0/templates/.d-check.yml; grep -cF 'order:' "$T"` → 1,
  `grep -cF 'direction: no-downward' "$T"` → 1, `grep -cF "token: 'slice" "$T"` → 1,
  `grep -cF 'from: adr, to: slice' "$T"` → 1, `grep -cF 'welle' "$T"` → 0. Deckt die im Plan behauptete
  Ziel-Form-Autorität exakt.
- **`make full-smoke` grün, beide Bootstrap-Formen — belegt über den laufenden CI-Lauf, nicht behauptet:**
  `gh run view 34508265558` (Push auf `main`, `HEAD` = `f4b900bf`) zeigt Job `full-smoke` **✓ success**
  (4m9s), neben `gates` ✓, `smoke` ✓, `adr-immutable` ✓. `harness/tools/full-smoke.sh` fährt intern beide
  Formen (`--lang go` → `$tmprepo`, sprachlos → `$tmprepo_doc`); die vier neuen ids/matrix/spans-Zähne
  (Zeilen 297–420) und der Kausalitäts-Rückfall auf `modules: [links, anchors]` laufen dabei mit — ein
  Fehlschlag dort hätte den Job rot gefärbt. **Erfüllt, aktuell belegt.**
- **Erfüllt.**

**(2) Jedes neu aktivierte Modul im Ziel rot gesehen, mit heutiger Config grün.**

- Vier Befund-Arten (`matrix-forbidden`, `matrix-downward`, `id-unlinked`, `span-unclosed`) stehen als eigene
  Zähne in `harness/tools/full-smoke.sh` — gelesen, mit Rücknahme nach jedem Zahn
  (`modul_zahn_alte_module_gruen`) und der expliziten Kausalitäts-Gegenprobe (dieselbe Verletzung bleibt unter
  dem *alten* `modules: [links, anchors]` grün, Zeilen 297–314). Der `links`-Feldlisten-Zahn (Zeile 275 ff.)
  ist eigenständig (slice-098) und läuft ebenfalls in `full-smoke` — auch dieser Job ist grün (s. o.).
- **Netzloser Wächter** `TestDCheckConfig_EntschiedeneModulListe` (`internal/emit/emit_test.go:25`) bindet die
  eingebettete `.d-check.yml` byte-genau — `DCheckConfig()` ist reines `//go:embed`, keine Transformation
  (`internal/emit/emit.go:43`), der Fehlerfall aus §3.6 („Test prüft Quelle, Code liefert transformiertes
  Ziel") kann hier strukturell nicht eintreten.
- **Vier Mutations-Fälle** `test/mutations/295–298` — gelesen, alle vier `sed`-Patches treffen exakt die
  Zeilen, die der Test bindet (Modul-Liste, `{from: adr, to: welle}`, `order:`/`direction:`,
  `exclude-sections:`), `# expect: TestDCheckConfig_EntschiedeneModulListe` in allen vieren. Fall 298 wurde
  in Runde 5 durch einen echten `docker build --target test`-Lauf (isolierte Kopie) einzeln rot gesehen — von
  mir nicht wiederholt (Docker-Sperre dieser Verifikation), aber Fall 298s `sed`-Ziel selbst geprüft: Nur
  Zeile 59 der Vorlage trägt `exclude-sections: [Geschichte]` exakt (Zeile 30 ist Fließtext), die Mutation
  trifft sie eindeutig.
- **Erfüllt.**

**(3) Nicht-Emissionen + Reichweite mit Auflösungs-Trigger in `harness/conventions.md`.**

- **NICHT erfüllt — unabhängig vom offenen `mutate`-Sensor.** `ls harness/conventions/ | grep -oE 'MR-[0-9]{3}'
  | sort -u | tail -1` → `MR-053`; kein Eintrag zu slice-073 existiert. `git diff bcf652b9~1..HEAD --stat --
  harness/conventions.md harness/conventions/` → leer. Dies ist explizit Architect-Arbeit
  ([`AGENTS.md`](../../AGENTS.md) §3.8), und der Plan trägt seit Runde 2 (behoben aus Runde-1-MEDIUM-1) ein
  vollständiges Übergabe-Artefakt dafür (§3 *Übergabe an den Architect*, mit der Messung, warum es **zwei**
  Nicht-Emissionen sind und nicht drei) — aber der Architect-Lauf selbst hat noch nicht stattgefunden. Das
  DoD-Häkchen ist entsprechend unverändert `[ ]`. **Dieser Punkt blockiert die Closure eigenständig, auch
  wenn der `mutate`-Sensor grün zurückkommt.**

**Unbenannter vierter Punkt — `make gates` grün; `make full-smoke` grün; `make mutate` grün über die CI.**

- **`make gates`: grün, belegt ohne Docker-Lauf.** `.harness/state/gates-passed.diffsha` = `7921096…258dd`;
  `bash harness/tools/working-tree-hash.sh` (reiner Hash über den Arbeitsbaum, kein Docker) liefert
  **denselben** Wert für den aktuellen, sauberen Baum. `record-gates` (= `baseline-verify docs-check lint
  build test shell-lint ci-lint comment-claims host-bin span-check`) ist damit für exakt diesen Commit
  gestempelt vorhanden — unabhängig vom Implementer-Bericht. CI bestätigt dasselbe für den Job `gates` (✓, s.
  o.).
- **`make full-smoke`: grün** — s. DoD (1) oben, live über CI belegt.
- **`make mutate` grün über die CI: OFFEN.** Siehe Abschnitt 3.

## 2. Plan-vs-Code-Diff

`git diff bcf652b9~1..HEAD --stat -- internal/ test/ harness/`:

| Plan sagt (§3) | Code tut | Deckung |
|---|---|---|
| `internal/emit/templates/d-check.yml` update | Modul-Liste + `ids`/`matrix`-Block wie oben | ✅ |
| `internal/emit/emit_test.go` update | `TestDCheckConfig_EntschiedeneModulListe` bindet die entschiedene Liste | ✅ |
| `harness/tools/full-smoke.sh` update | 125 Zeilen: vier Zähne + Kausalitäts-Rücknahme | ✅ |
| `test/mutations/` neu | vier Fälle (295–298), je auf `TestDCheckConfig_EntschiedeneModulListe` verdrahtet | ✅ |
| `harness/conventions.md`/`harness/conventions/` update (Architect) | **nicht geschehen** | ❌ — s. DoD (3) |

`git diff bcf652b9~1..HEAD --stat` über den vollen Pfadraum trifft **keine** weitere Datei außerhalb der
Plan-Tabelle und der zwei Zusatz-Commits — kein Scope-Leck in Implementer-Commits `bcf652b9`…`71f3fd9b`.

**Was der Plan nicht sagt, der Code aber tut — die zwei Zusatz-Commits `5a3108d4`/`f4b900bf`.** Beide liegen
vollständig außerhalb von Plan-§1, DoD (1)–(3) und Plan-§3: Sie ändern `internal/emit/emit.go`,
`internal/emit/archgate.go`, `internal/emit/baseline.go`, `internal/emit/templates/d-check.yml` (eine andere
Stelle als DoD (1)), `internal/emit/templates/enforce/enforce.mk`. Kein Liefer-Punkt dieses Slice verlangt
Kommentar-Bereinigung in `emit.go`. Das ist **Gebautes-aber-nicht-Geplantes** im wörtlichen Sinn — unter dem
Label `slice-073` committet, aber sachlich eine eigene, vom Auftraggeber direkt angewiesene Aufgabe
(§3.7-Konformität), die keine Review-Runde geprüft hat. Näheres in Abschnitt 4.

**Was der Plan sagt, der Code aber noch nicht auflöst:** DoD (3) (s. o.); die vier §6-Risiken haben noch
keinen zugewiesenen Ausgang (erwartungsgemäß — das ist Closure-Zeitpunkt, nicht Implementierungszeitpunkt);
§6 Risiko „Der Plan misst gegen einen überholten Stand" bleibt offen (Dogfood führt inzwischen `planning` als
achtes Modul, außerhalb der Ist-Messungstabelle in §1 — vom Plan selbst benannt, kein neuer Fund).

## 3. Der eine offene Sensor — `make mutate`, Abnahme-Kriterium statt Urteil

**Zwei parallele Läufe, keiner abgeschlossen zum Zeitpunkt dieser Verifikation:**

- **Lokal:** `MUTATE_JOBS=2 make mutate`, gestartet 18:58, Log wächst (`.../scratchpad/mutate-clean.log`),
  bei Prüfungsende bei Fall ~86 von 284 (Prozesse laut `ps aux` aktiv, kein Absturz).
- **CI:** Lauf `34508265558` (Push von `f4b900bf`), Job `mutate` (ID `102975693665`) läuft noch — die vier
  übrigen Jobs (`adr-immutable`, `smoke`, `gates`, `full-smoke`) sind bereits **✓ success**.

**Vorgeschichte (Auftrag):** Ein vorheriger Vollauf zog alle 284 Fälle einzeln `ok`, meldete aber einen
`BEFUND` der Klasse `host-baum` — die fail-closed-Mitten-Prüfung schlug an, weil während des Laufs auf
fingerabdruckte Dateien committet wurde. Betriebsfehler der Orchestrierung, kein Wächter-Defekt, aber
**kein grüner Lauf** (`fail_count` war 1, nicht 0).

**Abnahme-Kriterium — was „grün" hier bedeutet, gegen den Code von `harness/tools/mutate.sh`:**

Erfüllt ist DoD-Punkt 4 (`mutate`-Hälfte) genau dann, wenn der **CI-Job `mutate`** für den Commit `f4b900bf`
(Run `34508265558`, oder ein erneuter Push-Lauf auf demselben oder einem grün gebliebenen Baum) **alle** vier
folgenden Bedingungen zeigt:

1. Exit-Code des Rezepts `make mutate` = **0** (`main()` in `harness/tools/mutate.sh` gibt genau dann 0
   zurück, wenn `[ "$fail_count" -eq 0 ]`).
2. Die Bilanz-Zeile lautet exakt `mutate: 284 ok, 0 Befund(e)`.
3. Die Vollständigkeits-Zeile lautet `mutate: Vollstaendigkeit — 284 von 284 Fall-Dateien mit Ergebnis, jede
   Fall-ID genau einmal gezogen.` (284 = `ls test/mutations/*.sh | wc -l`, hier gemessen).
4. **Keine** Zeile der Form `mutate: BEFUND  …` im vollständigen Log — unabhängig von der Klasse. Insbesondere
   zählt ein `host-baum`-Befund (Bedingung 5 in `main()`, Fingerabdruck-Mismatch der Mutations-Zieldateien
   nach dem Lauf) **nicht** als „grün", auch wenn alle 284 Einzelfälle selbst `ok` sind — genau der Fall, der
   im vorherigen Vollauf eintrat.

**Verfehlt** ist das Kriterium bei jeder Abweichung von 1–4, einschließlich: Exit ≠ 0, jede `BEFUND`-Zeile
(Wächter- oder Betriebs-Klasse), einer Bilanz-Zeile mit anderer Zahl als `284 ok, 0 Befund(e)`, einer
Vollständigkeits-Zeile mit anderem Verhältnis als `284 von 284`, oder einem durch `MUTATE_STALL_SECONDS`
selbst-terminierten Lauf (Log nennt dann die noch laufenden Worker statt einer Bilanz).

Da CI mit `fetch-depth`/frischem Runner **und** ohne den lokalen Nebenlauf-Konflikt fährt, ist der CI-Job die
im Plan-§5-Closure-Trigger wörtlich verlangte Instanz („`make mutate` mit `0 Befund(e)` … CI-Vollauf … auf
frischem Runner") — nicht der lokale Lauf. Der lokale Lauf ist Zusatz-Diagnose, kein Abnahme-Beleg.

**Ich behaupte kein Ergebnis.** Bei Abschluss dieser Verifikation zeigt weder der lokale noch der CI-Lauf ein
Endergebnis.

## 4. Die zwei ungeprüften Commits — Zusagen-Schaden geprüft, nicht nur Diff gelesen

**Umfang bestätigt eng.** `git show --stat 5a3108d4 f4b900bf` berührt ausschließlich fünf Dateien unter
`internal/emit/` (`emit.go`, `archgate.go`, `baseline.go`, `templates/d-check.yml`,
`templates/enforce/enforce.mk`) — kein Pfad außerhalb des in dieser Verifikation geprüften Bereichs.

**Keine tote Referenz erzeugt — selbst geprüft, nicht nur behauptet.** Fünf Klassen von verbleibenden
`slice-NNN`-Referenzen in `internal/` (`archgate.go:9,19`, `baseline.go:24,27,44`, `enforce.go:52`,
`makefile.go:6`, `internal/fetch/baseline.go:187`, `internal/gen/arch.go:100,129`,
`internal/gen/golang.go:467`, `internal/wire/wire.go:2`) blieben unangetastet — außerhalb des vom
Auftraggeber benannten engen Umfangs (Go-Kommentare über eigenen Code vs. Content-Klasse), kein Bruch der
§3.7-Cutoff-Regel („Bestand ist kein Arbeitsauftrag"). Fünf Mutations-Fälle, die dieselben Nummern in ihren
*erklärenden* Kopfkommentaren tragen (`test/mutations/{18,40,67,75,94}-*.sh`), wurden einzeln gelesen: keiner
patcht eine der fünf geänderten Zeilen — ihre `sed`-Ziele liegen an anderen Stellen (`DefaultGoVersion`,
`GATE_CHECKS +=`, `os.Chmod`, `dest=`, `block_sensor`). Kein Test bricht, kein Mutations-Fall verliert seine
Zähne durch diese zwei Commits.

**Die LH-QA-01-Deckungsaussage ist ersatzlos verschwunden — und das geht über die Weisung hinaus.** Vor
`5a3108d4` trug `emit.go` einen present-tense-Absatz: „*Die LH-QA-01-Garantie traegt nicht Minimalitaet: fuer
ids, matrix (zwei Regeln) und spans haelt je ein benannter Gegenbeispiel-Zahn in
harness/tools/full-smoke.sh … links traegt seinen eigenen Zahn im selben Skript (Feldlisten-Zahn, slice-098,
target-missing); anchors bleibt ohne Gegenbeispiel-Zahn.*" Das ist **kein** Chronik-/Forensik-Satz im Sinne
von §3.7 — er steht im Indikativ über einen **aktuellen Zustand** (Zusage- bzw. Grenz-Klasse), nicht im
Perfekt/Konjunktiv über einen Vorgang. Einzig `slice-098` darin war die tatsächlich unzulässige
Herkunfts-Form (von Runde 5 als LOW-2 benannt).

Nachgeprüft, wo dieser Zustand jetzt lebt:

```sh
grep -rn "Gegenbeispiel-Zahn\|target-missing.*links\|Feldlisten-Zahn" harness/README.md internal/emit/   # kein Treffer
grep -n "anchors" harness/tools/full-smoke.sh internal/emit/templates/d-check.yml   # nur die modules:-Zeile
                                                                                      # und drei full-smoke-Fundstellen ohne Bezug zur Deckungsfrage
```

**Nirgends.** Die konkrete Mechanik (die vier full-smoke-Zähne, der Feldlisten-Zahn) bleibt selbstdokumentiert
in `harness/tools/full-smoke.sh` — aber die **zusammenfassende Aussage**, dass `anchors` als einziges der
fünf aktiven Module **ohne** Gegenbeispiel-Beleg läuft, stand nur in diesem einen Absatz und ist mit ihm
verschwunden. Das ist eine genuine LH-QA-01-relevante Grenze, keine Forensik über deren Entstehung — die
Commit-Message begründet die Streichung mit „Landkarte fremder Gegenbeispiel-Zähne … gehört nicht hierher",
was für die reine Ortsangabe zutrifft, aber nicht erklärt, warum die Aussage selbst an keiner anderen Stelle
neu entstanden ist. Der korrekte engere Schnitt (Auftraggeber-Weisung + §3.7 exakt angewandt) wäre gewesen,
nur `slice-098` zu entfernen und den Rest — insbesondere „anchors bleibt ohne Gegenbeispiel-Zahn" — stehen zu
lassen oder nach `harness/tools/full-smoke.sh` zu verschieben.

**Einordnung:** Kein DoD-Punkt dieses Slice verlangt diese Aussage; ihr Verschwinden bricht kein Häkchen und
keinen Sensor (kein Gate liest Go-Package-Kommentare auf diese Eigenschaft). Es ist ein Befund **über** die
zwei Zusatz-Commits, keiner **gegen** die DoD von slice-073 — ich nenne ihn hier, weil er sonst in keiner
Rolle je geprüft wird (die Review-Kette hat diese Commits explizit nicht gesehen). Empfehlung an den Planner:
als eigene Beobachtung führen oder mit einem Satz an geeigneter Stelle (`harness/tools/full-smoke.sh`-Kopf)
nachtragen — kein Blocker für die Closure von slice-073 selbst.

## 5. ADR-/Hard-Rule-Konformität

- **[ADR-0004](../plan/adr/0004-durchsetzungs-emission.md) / [ADR-0006](../plan/adr/0006-durchsetzung-commands-tool-als-quelle.md).**
  Beide betreffen die Durchsetzungsschicht- bzw. Workflow-Command-Emission (Picker vs. Tool-als-Quelle),
  keiner berührt den Doc-Gate-Modul-Umfang. Der Slice ändert an der Emissions-**Herkunft** (Tool-als-Quelle,
  `internal/emit/templates/d-check.yml` embedded) nichts — kein Konflikt.
- **[ADR-0007](../plan/adr/0007-bootstrap-phasen.md) (Idempotenz-Klassen).** `.d-check.yml` ist laut ADR-0007
  Zeile 101 *skip-if-present* — der Plan zieht daraus korrekt die Reichweiten-Grenze für DoD (3) („ein
  bestehendes Ziel bekommt nichts davon"). Konform.
- **[MR-017](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  (fail-closed = strengerer Default).** Der Plan aktiviert `matrix`/`ids`(ADR-Muster)/`spans`, lässt
  `codepaths` und das `ids`-Requirement-Muster aus — beide würden im frischen Ziel **rot starten**
  (2 Befunde), nicht aus Adopter-Inhalt, sondern aus der **emittierten Vorlagen-Prosa selbst**
  (Platzhalter-Zeile in `AGENTS.md`, Formverweis in `harness/conventions.md`). MR-017 erlaubt einen zu
  strengen Default, wenn er „eine Glob-Zeile in einer Datei kostet, die dem Adopter gehört" — hier trüge der
  Adopter einen dauerhaften, durch das Tool selbst erzeugten Fehlalarm, den er nicht durch eine Zeile beheben
  kann, ohne die Vorlage zu verstehen. Das ist der von MR-017 selbst benannte Fall, in dem „strenger" **nicht**
  automatisch richtig ist („kein Freibrief für Regeln ohne belegten Nutzen … LH-QA-01"). Die Entscheidung ist
  konform, nicht bloß vertretbar — Kriterium 2/3 aus Plan-§1 sind explizit als MR-017-Anwendung für diesen
  Prüfbereich benannt und tragen.
- **§3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel).** Vier von vier neu aktivierten Befund-Arten haben
  einen Zahn; der neue Go-Wächter hat einen Mutations-Fall. Kein Modul ohne Gegenbeispiel wird als geprüft
  behauptet — im Gegenteil, DoD (2) benennt „vier Befund-Arten, nicht drei" gerade um diese Lücke zu
  schließen.
- **§3.7 (Kommentar beschreibt, was da ist).** Innerhalb des Plan-Umfangs (`bcf652b9`…`71f3fd9b`) konform,
  von Runde 5 selbst geprüft (N-9). Für die zwei Zusatz-Commits: teilweise Über-Anwendung, s. Abschnitt 4 —
  kein Regelbruch (nichts Verbliebenes trägt Chronik/Forensik), aber eine Zusage ist ersatzlos entfallen statt
  umgeschrieben.
- **§3.8 (Hard Rules/Adaptions-Block nur Architect).** Kein Commit dieser Kette (Plan-Umfang **oder** die
  zwei Zusatz-Commits) berührt `AGENTS.md` oder `harness/conventions.md`/`harness/conventions/` — konform,
  und das ist zugleich der Grund, warum DoD (3) offen ist (s. o.).
- **§3.9 (Docker-only).** Kein Host-Toolchain-Aufruf in den geprüften Diffs.
- **§3.10 (Closure ist Planner-Arbeit).** Alle DoD-Häkchen unverändert `[ ]`; §7 (Closure-Notiz) trägt den
  Platzhalter-Kommentar; kein `git mv` erfolgt. Konform.
- **Kein Gate gelockert (§3.5).** `modules:` wächst (Anhebung), kein Ausnahme-Schlüssel wird geweitet.

## 6. Zusammenfassung — was noch fehlt, unabhängig von `mutate`

1. **DoD (3): der `harness/conventions.md`-Eintrag (Architect-Arbeit) fehlt.** Blockiert die Closure
   eigenständig — unabhängig vom `mutate`-Ergebnis.
2. **`make mutate` über CI: Ergebnis noch offen.** Abnahme-Kriterium in Abschnitt 3.
3. Die vier §6-Risiken brauchen bei Closure ihren Ausgang (Standard-Closure-Arbeit, kein Sonderbefund).
4. Der LH-QA-01-Deckungssatz aus `emit.go` ist ersatzlos entfallen (Abschnitt 4) — kein Blocker, aber ein
   Kandidat für die Closure-Notiz bzw. das Beobachtungs-Register.

## Verdikt

**Ist die DoD erfüllt? Nur bis auf den laufenden Sensor — UND ein zweiter, vom Sensor unabhängiger Punkt.**

DoD (1) und (2) sind in der Sache erfüllt, real belegt (Gate-Stempel-Hash ohne Docker-Lauf, `make full-smoke`
grün über den laufenden CI-Lauf für exakt diesen Commit, vier Mutations-Fälle strukturell verdrahtet). DoD (3)
ist **nicht** erfüllt — der geforderte `harness/conventions.md`-Eintrag existiert nicht, das ist Architect-
Arbeit, die noch aussteht, und hat mit dem laufenden `mutate`-Sensor nichts zu tun. Der Closure-Trigger-Punkt
„`make mutate` grün über die CI" ist offen; das Abnahme-Kriterium dafür steht in Abschnitt 3 und ist ohne
zweiten Verifikations-Durchgang gegen den CI-Job-Output prüfbar.

**Kann der Planner den Slice schließen, sobald der Sensor grün zurückkommt? Nein — nicht allein deswegen.**
Selbst wenn der CI-Job `mutate` mit `284 ok, 0 Befund(e)` zurückkommt, fehlt weiterhin die Architect-Arbeit
aus DoD (3). Der Planner kann nach grünem `mutate` **einen** der beiden verbleibenden Blocker abhaken, nicht
beide; ein Architect-Lauf für den `harness/conventions.md`-Eintrag (Plan-§3, „Übergabe an den Architect")
bleibt in jedem Fall Voraussetzung für den `git mv` nach `done/`.

**Zwei Nebenbefunde, keiner blockierend:** Die zwei Implementer-Commits außerhalb der Review-Kette
(`5a3108d4`, `f4b900bf`) sind eng geschnitten, brechen nichts Bestehendes und liegen vollständig außerhalb
von Plan/DoD — sie gehören sachlich nicht zu slice-073 und sollten in Closure-Notiz oder Commit-Historie klar
als das ausgewiesen bleiben, was sie sind (Auftraggeber-Weisung, kein Liefer-Punkt). Und der in `emit.go`
gestrichene LH-QA-01-Deckungssatz für `anchors` ist ersatzlos verschwunden, ohne dass eine Zusage
missachtet oder ein Test gebrochen wurde — ein Fall für die Closure-Notiz, kein DoD-Verstoß.

---

**Sensor-Belege dieser Verifikation** (keiner davon ein Docker-Lauf durch mich):

- `bash harness/tools/working-tree-hash.sh` → `79210963fc5c0f063ff5466db3d4c6d3b7d980acac4d13bbb50defa7482258dd`,
  deckungsgleich mit `.harness/state/gates-passed.diffsha`.
- `gh run view 34508265558` → `adr-immutable` ✓, `smoke` ✓, `gates` ✓, `full-smoke` ✓, `mutate` * (offen).
- `T=.harness/baseline/v6.5.0/templates/.d-check.yml` — Autoritäts-Grep wie in Abschnitt 1 (1/1/1/1/0).
- `ls harness/conventions/ | grep -oE 'MR-[0-9]{3}' | sort -u | tail -1` → `MR-053` (kein slice-073-Eintrag).
- `git diff bcf652b9~1..HEAD --stat -- internal/ test/ harness/` sowie `git show --stat 5a3108d4 f4b900bf`.
