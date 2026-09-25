# Review — ADR-0067 (Zeilenenden der emittierten Dateien), Runde 1

**Gegenstand:** `docs/plan/adr/0067-emittierte-zeilenenden-ein-attribut-je-verzeichnis-mit-interpreter-konsument.md`
(Status `Proposed`, Architect-Commit `004e5bc3`: die ADR und die Index-Zeile in `docs/plan/adr/README.md`).

**Rolle / Skill:** Reviewer, `.harness/skills/reviewer.md` 2.0.0; Baseline-Regelwerk `modul-10-review-harness.md`,
`modul-04-adrs.md`, `modul-08-agentenrollen.md` (Reviewer prüft ADR-Änderungen auf Konsistenz).

**Geprüft gegen:** ADR-0007 (Festlegung 3, Tabelle, Zweifelsregel), ADR-0054 (Festlegung 1 bis 4),
ADR-0065 (nur als Klassen-Nachbar), `spec/lastenheft.md` `LH-QA-04`, `spec/architecture.md` `ARC-003`,
`AGENTS.md` §3.4/§3.5/§3.6/§3.8/§3.11, `harness/sensors/adr-immutable.md`, `internal/emit/enforce.go` (Klassen,
`PathClass`, `EnforcePaths`, Writer), `internal/emit/enforce_test.go`, den Slice
`slice-emittierte-dateien-behalten-lf-im-autocrlf-klon` (nur Kontext, nicht Prüfgegenstand).

**Nicht Gegenstand:** die Zweckmäßigkeit der Entscheidung und die Annahme (`Accepted`) — beides Sache des
Auftraggebers. Der Reviewer prüft Konsistenz und die Belegkraft der Messungen.

**Summary:** 0 HIGH · 4 MEDIUM · 3 LOW · 3 INFO. Klassen: *Messung deckt nicht das behauptete Fehlerbild* ·
*Kriterium und Ausnahme in derselben Festlegung widersprechen sich* · *Begründung widerspricht der eigenen
Fitness-Zeile* · *Klassen-Kriterium ungleich angewandt, Zusage „Zweifelsregel angewandt" überzogen*.
**Empfehlung zum Accept: bedingt** — die vier MEDIUM sind Text-Korrekturen an einer noch änderbaren `Proposed`-ADR;
die Messungen selbst tragen (Abschnitt Nachgefahren). Nach der Korrektur ist eine zweite Runde derselben Rolle der
Beleg des Accept-Übergangs (`ADR-0040`).

Alle Zahlen unten sind Momentaufnahmen vom 2026-09-25 an einem frisch gebootstrappten Wegwerf-Ziel im Scratchpad
(`ai-harness-init --lang go`, committet, geklont) und an diesem Repo; keine Erwartungswerte.

---

## Findings

### M-1 — MEDIUM · Der Guard-Befund beschreibt einen konstruierten Mischzustand, nicht den Klon, den die Alternativen F und E meinen

- `quelle`: `LH-QA-01`, `AGENTS.md` §3.6 (Messung trägt, was sie behauptet), `MR-055`
- `pfad`: `docs/plan/adr/0067-…md:47` (dritte Probe), `:116` (Alternative F, Contra), `:49`
- `befund`: Die Probe setzt einen Klon voraus, „dessen Guard LF trägt und dessen `blocked/go` CRLF trägt". Ein
  gewöhnlicher Klon mit `core.autocrlf=true` (der Fall, den Alternative F „nichts tun" beschreibt) trägt den Guard
  **auch** mit CRLF: dort endet `bash .claude/hooks/pretooluse-command-guard.sh` mit `set: pipefail: Ungültiger
  Optionsname`, Exit 2 (gemessen, unten) — der Guard fällt **laut** und blockt jeden Aufruf, er lässt `staticcheck`
  nicht still durch. Die Aussage in F („der Guard kann ohne Meldung an einem Listenwort aufhören zu blocken") gilt für
  keinen Zustand, den Alternative F erzeugt; sie gilt für den Mischzustand, den Alternative E (Endungs-Globs)
  erzeugte. Das stützt die Ablehnung von E, nicht die von F, und die Kontext-Zeile „fail-open ohne
  Fehlermeldung" hängt am Halbsatz vor dem Komma.
- `verifizierbar`: ja (Probe unten, Punkt d).
- `klasse`: Messung deckt einen konstruierten Zustand, Folgerung nennt den gewöhnlichen.

### M-2 — MEDIUM · Kriterium „Interpreter (bash, awk, make)" und der Ausschluss der Wurzel widersprechen sich; die erste Fitness-Zeile wäre damit nicht erfüllbar

- `quelle`: `AGENTS.md` §3.6, `LH-QA-01`
- `pfad`: `…0067-…md:77` (Kriterium), `:87` (Ausschluss der Wurzel), `:136` (Fitness-Zeile 1), `:114` (Alternative D)
- `befund`: Festlegung 1 nennt make ausdrücklich als Interpreter und macht jedes Verzeichnis mit einer Datei
  davon zur Menge; die Wurzel trägt aber `Makefile`, `d-check.mk` und (mit `--arch`) `a-check.mk`
  (Sonde unten: außerhalb der fünf Verzeichnisse liegen genau `Makefile`, `d-check.mk`, `Dockerfile`, bei `--arch`
  zusätzlich `a-check.mk`, in `go` und `cpp`). Der Ausschluss steht als Setzung neben dem Kriterium, nicht als seine
  Folge; Fitness-Zeile 1 verlangt „für jede emittierte Datei … Endung `.mk` … liegt in einem Vorfahr-Verzeichnis eine
  emittierte `.gitattributes`" und wäre für `d-check.mk` in der Wurzel rot, oder der Test führt still eine Ausnahme,
  die im Text nicht steht. Der Grund, der die Wurzel trägt (Alternative D: GNU Make 4.3 ohne gemessenen Bruch), ist
  wahr — gemessen: ein Makefile mit CRLF-Rezept läuft unter 4.3 und liefert `hi\n` —, gehört aber in das
  Kriterium („eine Datei, an deren Bytes ihr Konsument bricht"), nicht daneben.
- `verifizierbar`: ja (Sonde der Erfassungsmenge; Test der Fitness-Zeile 1, sobald er existiert).
- `klasse`: Kriterium und Ausnahme in derselben Festlegung ohne Ableitung.

### M-3 — MEDIUM · Die Begründung „kein Change Request" widerspricht der eigenen Fitness-Zeile

- `quelle`: `AGENTS.md` §3.6, `MR-015`, `LH-QA-04`
- `pfad`: `…0067-…md:126` (Konsequenz „Kein Change Request"), `:103` (Festlegung 5), `:138` (Fitness-Zeile 3)
- `befund`: Die Konsequenz sagt, ein Lastenheft-Satz über die Zeilenenden im Klon „sagte etwas zu, dessen
  Gegenbeispiel auf den Runnern nicht herstellbar ist". Fitness-Zeile 3 stellt genau dieses Gegenbeispiel unter Linux
  her (Klon mit `-c core.autocrlf=true`, Kontrolle mit `=false`), und Festlegung 5 sagt selbst, gemessen werde, „was
  der Smudge-Filter von Git unter Linux mit den Bytes tut". Nicht herstellbar ist allein die Aussage über einen
  **Windows**-Git. Die Behauptung ist damit weiter, als die ADR sie trägt; dass die Spec zu dem Gegenstand schweigt
  (`grep -rniE 'crlf|autocrlf|gitattributes' spec/ | wc -l` → 0, bestätigt) bleibt richtig, und ob der Auftraggeber
  eine Zeile will, bleibt seine Entscheidung — die Begründung, warum keine vorgeschlagen wird, trägt so nicht.
- `verifizierbar`: nein (Lesart; die Gegenprobe ist der Text der Fitness-Zeile 3).
- `klasse`: Begründung widerspricht der eigenen Fitness-Zeile.

### M-4 — MEDIUM · Das Klassen-Kriterium „legitimer Adopter-Zustand" ist an drei Verzeichnissen angewandt und an zwei unterlassen; „Zweifelsregel angewandt" trägt nur für die drei

- `quelle`: `ADR-0007` Festlegung 3 (Zweifelsregel), `ADR-0054` Festlegung 2, `MR-055`
- `pfad`: `…0067-…md:71` (die Urteils-Frage), `:95` und `:96` (die zwei konvergenten Zeilen), `:97` bis `:99`
  (die drei skip-if-present-Zeilen), `:121` („angewandt, nicht übergangen")
- `befund`: Die Frage aus §Kontext — kann an diesem Pfad ein legitimer Adopter-Zustand bestehen, in dem die Datei
  nicht die des Werkzeugs ist? — wird für `harness/mk/` mit einer Adopter-Fläche beantwortet, die ADR-0007 an
  `*.mk`-Dateien nennt (Zeile 100 dort: „Adopter-`local.mk` unberührt"; im Code steht `local.mk` nirgends), und dann
  auf eine `.gitattributes` übertragen. Für `.harness/` und `tools/harness/` fällt die Frage weg, weil die Tabelle
  „keine Adopter-Fläche" nenne — ein Schluss aus der Abwesenheit einer Nennung, dieselbe Form von Stellen-Messung,
  die `MR-055` und ADR-0054 Festlegung 4 nicht tragen lassen. Eine eigene `.gitattributes` in `tools/harness/`
  (der Adopter legt dort eigene Skripte ab und führt eine Zeile `*.ps1 eol=crlf`) ist nicht weniger plausibel als in
  `harness/mk/`; der konvergente Lauf ersetzte sie, die Kosten sind die der Alternative A. Für die zwei
  konvergenten Zeilen wird die Zweifelsregel also nicht angewandt, sondern durch ein ungemessenes „Werkzeug bestimmt,
  was dort liegt" überstimmt; die Konsequenz „ist **angewandt**, nicht übergangen" gilt nur für drei Zeilen.
  Hinzu: die Spalte „Herkunft" nennt für alle fünf „neu festgelegt", obwohl Zeile 96 selbst schreibt, die Tabelle
  „deckt `tools/harness/*` samt `blocked/` vollständig" — ADR-0054 Festlegung 1 nannte denselben Fall „bestätigt".
  (Die Ableitung für `.claude/hooks/` — Festlegung 4 aus ADR-0054 lässt die Zeilen ungewogen, also greift die
  Zweifelsregel — ist dagegen wörtlich gedeckt: dort steht „nicht mitgezogen … nicht gemessen".)
- `verifizierbar`: nein (Urteilsfrage; der Nachweis wäre die Stichprobe aus Re-Evaluierungs-Trigger 2).
- `klasse`: Klassen-Kriterium ungleich angewandt; Zusage „Zweifelsregel angewandt" überzogen.

### L-1 — LOW · Die Zusage von Festlegung 5 und die „Positiv"-Konsequenz stehen unbedingt, gelten aber nicht in den belegten Pfaden

- `quelle`: `AGENTS.md` §3.6 (Zusage einschränken auf das, was der Code hält)
- `pfad`: `…0067-…md:103` („kommen … mit LF an"), `:120` („Eine Adopter-Wurzel kann das nicht mehr aufheben")
- `befund`: In den drei skip-if-present-Verzeichnissen bleibt bei belegtem Pfad die Datei des Adopters stehen; ob dort
  LF ankommt, hängt an ihr. Festlegung 4 nennt das, der Satz in Festlegung 5 und die Positiv-Konsequenz nicht;
  Fitness-Zeile 3 misst nur den freien Pfad.
- `verifizierbar`: ja (Klon mit belegter `.githooks/.gitattributes` ohne `eol=lf`).
- `klasse`: unbedingte Zusage über einen bedingten Pfad.

### L-2 — LOW · Zwei Re-Evaluierungs-Trigger benennen keinen Träger

- `quelle`: Baseline-Regelwerk „ein Trigger ohne Wächter ist eine Absichtserklärung mit Verfallsdatum"
- `pfad`: `…0067-…md:145` (Stichprobe gebauter Ziele), `:146` (Windows-`make`/BuildKit bricht nachweislich)
- `befund`: Trigger 1 hängt an einem Runner-Ereignis, Trigger 4 an der Fitness-Zeile 1; für 2 und 3 nennt weder die
  Fitness-Tabelle noch der Text, wer die Stichprobe zieht oder die Messung nimmt. Eine benannte Lücke wie in der
  „kein Gate"-Zeile der Fitness-Tabelle fehlt hier.
- `verifizierbar`: nein.
- `klasse`: Trigger ohne benannten Träger.

### L-3 — LOW · Die Index-Zeile trägt `MR-005` nicht, das die ADR im Kopf führt

- `quelle`: `ADR-0024` (derivatives Register), `AGENTS.md` §5
- `pfad`: `docs/plan/adr/README.md:74` gegen `…0067-…md:14`
- `befund`: Der Kopf der ADR nennt `MR-005`; die Bezug-Spalte des Index nennt die Kennung nicht. Alle übrigen Bezüge
  und der Status `Proposed` stimmen.
- `verifizierbar`: ja (Vergleich der zwei Zeilen).
- `klasse`: Index-Zeile trägt nicht den vollen Kopf-Bezug.

### I-1 — INFO · Die ADR weicht von Setzung 3 des Slice ab, ohne es zu sagen

- `pfad`: `…0067-…md:97`, `:98` gegen Setzung 3 des Slice `slice-emittierte-dateien-behalten-lf-im-autocrlf-klon`
- Der Slice setzt `harness/mk/` und `.claude/hooks/` konvergent und `.githooks/` skip-if-present und stellt die Klassen
  ausdrücklich als Übergabepunkt an den Architect. Die ADR entscheidet anders (`harness/mk/`, `.claude/hooks/`,
  `.githooks/` skip-if-present) — legitim als Verdikt, und die Begründung steht (Zweifelsregel, ADR-0054
  Festlegung 4). Genannt wird die Abweichung nicht; nach `Accepted` ist Setzung 3 des Slice überholt und ist
  Planner-Arbeit (Übergabe-Artefakt: die ADR). Kein Änderungswunsch an der ADR.

### I-2 — INFO · Der Fall „CRLF schon im Index" ist ungemessen und ungenannt

- `pfad`: `…0067-…md:124` (benanntes Negativ nur für ein ausgechecktes Arbeitsverzeichnis)
- Eine Datei, die ein Adopter bereits mit CRLF im Index führt, bleibt trotz `text=auto eol=lf` `i/crlf w/crlf`
  (gemessen, Punkt e2); `git status` bleibt sauber. Die ADR sagt darüber nichts. Für ein Ziel, das ein Adopter in ein
  bestehendes Repo bootstrappt, ist das der Rest, der zu „ungemessen" gehört.

### I-3 — INFO · Dogfood-Folgerung für den Planner (kein Finding an der ADR)

- Dieses Repo trägt keine `.gitattributes`. Ein Klon mit `-c core.autocrlf=true` trägt in `.claude/hooks`,
  `.githooks`, `harness/tools` 36 CR-Dateien; der Guard endet dort mit Exit 2 (`set: pipefail`) — laut, nicht still:
  sein Wortlisten-Boden ist im Skript fest verdrahtet (`BLOCKED=…` in Zeile 44), es gibt kein `blocked/`. Der stille
  Ausfall aus dem Kontext der ADR kann im Dogfood nicht entstehen. Der Slice deckt den Fall mit seiner
  Dogfood-Lieferung (Wurzel-Datei; DoD-Punkt 3); ein weiterer Befund an den Planner folgt daraus nicht. Genannt sei
  nur, dass die Formulierung „still" dort nicht zutrifft und nicht in den Slice wandern sollte.

---

## Nachgefahrene Messungen (Ergebnis je Punkt)

Wegwerf-Ziel unter dem Scratchpad des Laufs; Träger `.harness/state/bin/ai-harness-init`; nur `git`, `docker`
(über `make docs-check`), `make`, bash-Builtins.

| Punkt | Ergebnis |
|---|---|
| a — CR je Verzeichnis | Kommando der ADR wörtlich gefahren: `.harness 58 0`, `.claude/hooks 3 0`, `.githooks 1 0`, `harness/mk 11 0`, `tools/harness 11 0` (autocrlf=true \| false, Kontrolle ausdrücklich gesetzt). **Deckt sich.** Zusätzlich der ganze Baum: CR tragen auch `.claude/agents`, `.claude/commands`, `.claude/settings.json`, `docs/`, `spec/`, `harness/*.md` und alle Wurzel-Dateien — die ADR nennt diesen Rest als nicht gemessen und nicht zugesagt (Festlegung 1). |
| b — Shebang bricht | `./.githooks/commit-msg /dev/null` → `env: »bash\r“ nicht gefunden`, Exit 127; `bash tools/harness/baseline-verify.sh` → `set: pipefail: Ungültiger Optionsname`. **Deckt sich.** |
| c — Prüfsummen | `tr -d '\r' < SHA256SUMS \| sha256sum -c` im autocrlf-Klon: `grep -vc ': OK$'` → 54, `grep -c ': OK$'` → 0, `wc -l SHA256SUMS` → 54. **Deckt sich.** |
| d — Guard | Mit dem Guard-Skript des Ziels und der Eingabeform der Guard-Tests des Repos: bei CRLF-`blocked/go` und LF-Guard blocken `go`, `gofmt`, `golangci-lint` (je 1), `staticcheck` → **0**; mit LF-Liste `staticcheck` → 1. **Der Mischzustand trägt wie beschrieben.** Im echten autocrlf-Klon (Guard mit CRLF) endet der Guard dagegen mit Exit 2 und `set: pipefail`-Meldung, bei direktem Aufruf mit 127 — siehe M-1. |
| e — Wirkung der Zeile | Fünf `.gitattributes` mit `* text=auto eol=lf`, Adopter-Wurzel `* text eol=crlf`: im autocrlf-Klon null CR in allen fünf Verzeichnissen (Kontrolle ebenfalls null), `baseline-verify: v6.9.0 OK — 54 Dateien`, `.githooks/commit-msg` läuft über die Shebang-Zeile (Exit 1 mit der Kennungs-Meldung, also gelaufen), Ausführungsbit `-rwxrwxr-x`. **Deckt sich.** |
| e2 — Binär, CRLF im Index | Frisches Ziel: `git ls-files --eol \| grep -c 'i/-text'` → 0 (alle Dateien `i/lf` oder leer `i/none`). Ein zufälliges Binär in `.githooks/` bleibt mit der Zeile `-text` und byte-identisch im Klon. Ein CRLF schon im Index bleibt CRLF (I-2). Der vendored Baum dieses Repos trägt 0 `i/-text` (`git ls-files --eol .harness`); die zwei `-text` des Repos sind PNG unter `docs/user/images`. **Deckt „kein getrackter Binärbestand".** |
| f — Verschachtelung | `git check-attr eol text`: `.githooks/commit-msg`, `tools/harness/blocked/go`, `SHA256SUMS`, `harness/mk/go.mk`, `.claude/hooks/pretooluse-command-guard.sh` → `eol: lf`; `Makefile`, `d-check.mk`, `.claude/settings.json` → `eol: crlf` (Wurzel `* text eol=crlf`). Im Klon tragen `Makefile`, `d-check.mk`, `Dockerfile` weiter CR. **Deckt sich.** |
| g — Dogfood | Die ADR macht keine Dogfood-Aussage; eine Wurzel-Datei ist Lieferung des Slice. Gemessen zur Einordnung: dieses Repo trägt keine `.gitattributes`; Index `2586 i/lf`, `11 i/none`, `2 i/-text`, `10` Einträge ohne Angabe; Klon mit autocrlf: 36 CR-Dateien in Hooks und `harness/tools`, Guard Exit 2. **Nicht gefahren:** `git add --renormalize .`, `git ls-files --eol` vor/nach und `working-tree-hash.sh`-Unabhängigkeit — sie hängen an der Wurzel-Datei, die es noch nicht gibt (Slice-Lieferung). |
| Erfassungsmenge | Ziel `--lang go`, `--lang go --arch hexslice`, `--lang cpp --arch hexslice`, `--lang go --arch hexagonal`: Dateien mit Shebang, `.sh`/`.awk`/`.mk`/`Makefile`/`Dockerfile` außerhalb der fünf Verzeichnisse — in allen Varianten nur in der Wurzel (`Makefile`, `d-check.mk`, `Dockerfile`, mit `--arch` zusätzlich `a-check.mk`). Kein sechstes Verzeichnis mit Interpreter-Konsument. **Vollständig gegen die Emission**, mit dem Vorbehalt aus M-2 (Wurzel). |
| make 4.3 | Makefile mit CRLF-Rezept läuft und liefert `hi\n` — die Aussage in Alternative D („unter GNU Make 4.3 keinen gemessenen Bruch") trägt. |
| Textbelege | `grep -c 'local.mk' …0007…` → 2, `grep -c '\.gitattributes' …0007…` → 0, `grep -rniE 'crlf\|autocrlf\|gitattributes' spec/ \| wc -l` → 0, `Zeilenende` in `spec/spezifikation.md` einmal (SPEC-031, Kommandozeilen-Ende). **Deckt sich.** |
| Sensor-Realität | `TestEnforce_IdempotenzKlasseJePfad` existiert in `internal/emit/enforce_test.go` und liest `EnforcePaths()`/`PathClass`; die übrigen Sensoren (Test „Eigenschaft statt Verzeichnis-Liste", `full-smoke`-Stufe, `mutate`-Fall) sind in der ADR als **zu bauen** benannt, nicht als vorhanden (`LH-QA-01` gewahrt). |
| Writer | `writeSkipIfPresentTold` (`internal/emit/enforce.go`) meldet bei jedem belegten Pfad, ohne Byte-Vergleich — deckt Festlegung 4 („der Lauf unterscheidet nicht, wessen Datei liegt") und ADR-0054 Festlegung 3. |
| Doku-Gate, Immutabilität | `make docs-check` → `1898 Datei(en) geprüft, 0 Befund(e)`. `make history-range-guard` löste `004e5bc3~1..004e5bc3` auf (1 Commit); `make adr-immutable RANGE=004e5bc3~1..004e5bc3` → 0 Befunde (erwartungsgemäß leer: die ADR ist neu und `Proposed`). |

## Geprüft, ohne Befund (Negativbefund-Pflicht)

- **Form:** Kontext, Entscheidung, Verglichene Alternativen (sechs Optionen, „nichts tun" dabei), Konsequenzen,
  Fitness Function, Re-Evaluierungs-Trigger, Geschichte, Status-Zeile — Reihenfolge der Vorlage; Geschichte
  einzeilig und in Zustandsform. Größe: 158 Zeilen, fünf Festlegungen.
- **Erfassung nach Verzeichnis statt Endung:** Alternative E ist ehrlich verworfen — `blocked/<sprache>` und
  `commit-msg` tragen keine Endung; das ist an der Probe (d) reproduziert.
- **Wurzel-Datei (Alternative D):** die Begründung trägt — genestete Dateien gewinnen gegen eine Adopter-Wurzel
  (Punkt f); eine skip-if-present-Datei in der Wurzel schützte ein Ziel mit eigener Wurzel-Datei nicht.
- **Akzeptiertes Negativ (Meldung über der eigenen Datei):** deckt sich mit ADR-0054 Festlegung 3 und dem Writer; die
  Begründung gegen eine Byte-Gleichheits-Ausnahme (neuer Pfad im Writer für drei Zeilen Ausgabe) ist tragfähig.
- **Zweifelsregel-Richtung:** ADR-0007 sagt „im Zweifel skip-if-present" (nie Adopter-Inhalt clobbern); die ADR wendet
  sie für drei Pfade in dieser Richtung an. (Für die zwei anderen siehe M-4.)
- **`.claude/hooks/` skip-if-present:** die Ableitung aus ADR-0054 Festlegung 4 ist wörtlich gedeckt (Zeilen „nicht
  mitgezogen", „nicht gemessen").
- **`ARC-003`:** die Sicht führt die Idempotenz-Klassifikation je Datei; „Schärft ARC-003" und „keine Spec-Aussage
  ändert sich" sind konsistent; das Fehlerbild „im Zweifel konvergent klassifizieren" der Architektur stützt die
  Richtung der Zweifelsregel.
- **Kein `Supersedes`:** ADR-0007 und ADR-0054 werden nicht überschrieben; die Begründung („spätere, nicht abweichende")
  trägt — beide nennen `.gitattributes` nicht.
- **§3.4/§3.5/§3.8:** der Commit `004e5bc3` berührt nur die ADR und ihre Index-Zeile, nennt die Rolle; keine
  Gate-Lockerung (die Entscheidung fügt Prüfbereich hinzu).
- **§3.11:** Verweise auf ADR-0007/ADR-0054/`MR-*`/`LH-*` sind ortsfest (Anker, eingefrorene ADR-Dateien); der Slice
  steht in der Geschichte mit seiner Kennung, nicht als Pfad; die Pfade `harness/mk/…` tragen den d-check-Marker.
- **MR-025:** jede Zahl in Kontext und Festlegungen steht neben ihrem Kommando; die Sonden liefern die genannten
  Werte (Punkte a, c, e2, Textbelege).
- **Prosa-Zustandsform:** keine Befund-Kennungen als Erzählung, keine Slice-Nummern als Adresse.

## Empfehlung zum Accept

**Bedingt.** Die Entscheidung ist in sich schlüssig, die Messungen (a) bis (f) tragen bis auf die Einordnung in M-1,
und es gibt kein HIGH. Vor dem Accept zu klären: M-1 (Guard-Fehlerbild an den gewöhnlichen Klon anpassen oder den
Mischzustand als den nennen, der er ist), M-2 (Kriterium und Wurzel-Ausschluss in eine Ableitung bringen, Fitness-
Zeile 1 danach ausrichten), M-3 (die Begründung des Verzichts auf einen Change Request an die eigene Fitness-Zeile
angleichen), M-4 (Kriterium für die Klasse einheitlich anwenden oder die Ungleichheit als Urteil ausweisen und die
Zusage „angewandt" auf drei Zeilen begrenzen). L-1 bis L-3 und die INFO sind zusammen mit der Korrektur oder danach
zu ziehen. Ob die ADR angenommen wird, entscheidet der Auftraggeber.
