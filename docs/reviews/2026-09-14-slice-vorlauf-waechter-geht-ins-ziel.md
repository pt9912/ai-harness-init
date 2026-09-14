# Review-Report: slice-vorlauf-waechter-geht-ins-ziel — 2026-09-14

**Review-Art:** Code-Review gegen **Plan + Hard Rules** (Modul 10 §Drei Review-Arten). Gegenstand
sind eine Go-Emissions-Vorlage, ein emittiertes Shell-Skript, ein E2E-Abschnitt, zwei Go-Tests und
zwei Mutations-Fälle. **Kein DoD-Review** — DoD-/Spec-Konformität prüft der Verifier (Modul 11,
anderer Eingabe-Kontext).

**Gegenstand:** ein Commit `59fd546c` (Rolle Implementer), 10 Dateien, +431/−6. **Geprüfter Stand:**
der Inhalt von `59fd546c` — beim Lesen dieses Laufs HEAD; `main` ist **während** des Laufs um sechs
Commits weitergerückt (eine parallele Planner-/`slice-mv`-Sequenz bis `cd4b2c4c`, 19:23), von denen
keiner eine geprüfte Datei berührt (`git diff --name-only 59fd546c cd4b2c4c` → nur
`docs/plan/planning/**`). **Kein Self-Review:** dieser Lauf hat an dem Commit nicht geschrieben; kein
Befund dieses Reports ist aus der Commit-Message oder aus dem Implementer-Bericht übernommen — die
dort als strittig gemeldeten Punkte sind einzeln nachgemessen (§1 bis §8).

**Skill:** `.harness/skills/reviewer.md` @ `0565f274` (2.0.0) · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** deepseek-v4.1-flash:cloud[1m] · **Datum:** 2026-09-14

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis; die `<Platzhalter>` darin sind Formbeispiele)*. Dieser
> Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link
> (`v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt>). Der vendored Baum trägt
> genau einen Tag; der Sprung löscht den alten, und ein Link darauf färbt beim
> nächsten Bump ein Artefakt rot, das niemand mehr anfassen darf. Ein `pfad`-Feld
> auf den **geprüften Gegenstand** ist davon nicht betroffen — es zitiert den
> Stand des Laufs und darf ihn festhalten.

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- Slice-Plan `slice-vorlauf-waechter-geht-ins-ziel` (§1 Ziel und Abgrenzung, §2 DoD, §3 Plan,
  §4 Trigger, §5 Closure-Trigger, §6 Risiken)
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules; tragend hier §3.6, §3.7, §3.9)
- [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) ·
  [`LH-FA-06`](../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) ·
  [`LH-FA-03`](../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7)
- [`MR-005`](../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption) ·
  [`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
  Setzung 3 · [`MR-010`](../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) ·
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
- Baseline `v6.8.0` · `regelwerk/modul-11-verification.md` §Bewusstes Brechen für
  DoD-Testbehauptungen · `regelwerk/modul-13-quality-gates.md` §Vorhanden ≠ behauptet
- Vorherige Findings am **selben Modul** (Voll-E2E-Sensor, Abdeckungs-Zusage, emittierte
  Doc-Gate-Module): `2026-08-27-slice-106-review.md` (F-1, F-2, F-3) ·
  `2026-08-26-slice-098-review.md` · `2026-09-10-slice-073-emittierte-doc-gate-module-runde-5.md`
  — daraus die zwei wiederkehrenden Klassen `abdeckungs-zusage-ohne-rot-beleg` und
  `akzeptanzkriterium-nennt-eine-sonde-die-nie-gruen-wird`

---

## Eigene Messungen

Jedes Kommando dieses Abschnitts ist in diesem Lauf gefahren. Wo eine Zahl steht, steht das
Kommando daneben, das sie liefert; **keine Erwartungswerte**
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).

### 1. Das emittierte Fragment, verbatim, gegen ein echtes `make` — die Rezepte bleiben

Das Fragment wurde **verbatim aus der Quelle gezogen** (`awk` zwischen den Backticks von
`docGateMk`, `internal/emit/emit.go`), in ein Wegwerf-Verzeichnis gelegt, daneben ein
`d-check.mk`-Ersatz mit je einem Rezept für `doc-immutable`/`doc-commits` und ein Root-Makefile mit
`include harness/mk/doc-gate.mk`:

```text
$ make -n doc-immutable RANGE=HEAD..HEAD
bash tools/harness/history-range-guard.sh "HEAD..HEAD"     <- Vorbedingung zuerst
echo "MODUL-LAUF doc-immutable RANGE=HEAD..HEAD"           <- Rezept aus d-check.mk, nicht ersetzt
```

Dasselbe für `doc-commits`. **Kein „overriding recipe"-Warnhinweis**, das Rezept der zwei Targets
bleibt das des eingebundenen Fragments, die Vorbedingung läuft davor. **Die Behauptung des
Umsetzers trägt** — am echten `make`, nicht an der Leseart.

Der reale Lauf im gebootstrappten Ziel bestätigt die Kante zusätzlich: der Abbruch nennt **keine**
geprüften Dateien (`full-smoke: Waechter greift …` in beiden Zweigen), der Modul-Container startet
also nicht — die Ordnung ist nicht nur eine Zeilenordnung im `-n`-Text.

### 2. Der Fehlt-Fall des Wächters sagt etwas — zwei Randlagen, am Fragment gefahren

| Aufruf | Ergebnis |
|---|---|
| `make history-range-guard` (ohne `RANGE`) | EXIT 2, `Usage: history-range-guard.sh <base>..<head> \| --staged` |
| `make history-range-guard STAGED=1` (Index leer) | EXIT 0, `--staged ohne gestagte Aenderung — nichts zu pruefen.` |

Der DoD-Satz „der Fehlt-Fall sagt etwas, statt still zu bleiben" trägt (§2 DoD Punkt 3).

### 3. Der blinde Grün-Pfad aus dem Implementer-Bericht — gemessen, in beiden Zuständen

Derselbe Wegwerf-Baum, mit zwei Commits (damit die Range nicht leer ist) und einem `d-check.mk`
**ohne** `doc-immutable` — die Lage, die ein künftiges `--print-mk` herstellen würde:

| Zustand | `make doc-immutable RANGE=HEAD~1..HEAD` |
|---|---|
| **Mit** der Vorbindungs-Zeile (dieser Commit) | **EXIT 0** — `history-range-guard: Range 'HEAD~1..HEAD' aufgeloest, 1 Commit(s) — OK.` und **nichts weiter**; kein Modul, keine Meldung über ein fehlendes Rezept |
| **Ohne** die Vorbindungs-Zeile (Zustand davor) | **EXIT 2** — `make: *** Keine Regel, um „doc-immutable" zu erstellen. Schluss.` |

Der Commit wandelt in dieser Lage einen **lauten** Fehlschlag in einen **stillen Erfolg**. Siehe F-2.

Für `doc-immutable` fängt der neue full-smoke-Abschnitt (a) die Lage: über dem fehlenden Rezept
druckt `make -n` nur die Wächter-Zeile, `grep -F 'docker run'` trifft nichts → `FEHLER — … die
Kette des Ziels ist nicht die zugesagte: [doc-immutable nennt den Modul-Lauf nicht]`. Für
`doc-commits` prüft derselbe Abschnitt **nur**, ob der Wächter in der Kette steht
(`harness/tools/full-smoke.sh:357-359`) — kein `docker run`-Anker, also keine Deckung. Siehe F-2.

### 4. `make full-smoke` — der Exit gelesen, nicht abgeleitet

Der Umsetzer hat den Gesamt-Exit als „endet mit dem letzten `echo`, unter `set -e`" **abgeleitet**.
Dieser Lauf hat ihn gelesen: `make full-smoke` → **`FULLSMOKE_EXIT=0`**, und die neue Sektion
druckt beide Richtungen:

```text
full-smoke: Waechter greift (golang): make doc-immutable RANGE=HEAD..HEAD bricht ab, ohne ein Modul zu fahren.
full-smoke: Waechter greift (golang): make doc-commits RANGE=HEAD..HEAD bricht ab, ohne ein Modul zu fahren.
full-smoke: Waechter greift (golang): make doc-immutable RANGE=HEAD~1..HEAD bricht ab, ohne ein Modul zu fahren.
full-smoke: OHNE den Waechter meldet dasselbe Modul ueber derselben leeren Range gruen — die Klasse 'blind und gruen', gegen die der Waechter steht:
full-smoke:   d-check: 20 Datei(en) geprüft, 0 Befund(e)
full-smoke: Gegenprobe (golang): dieselbe Range auf dem vollstaendigen Klon bleibt gruen —
full-smoke:   history-range-guard: Range 'HEAD~1..HEAD' aufgeloest, 1 Commit(s) — OK.
full-smoke:   d-check: 20 Datei(en) geprüft, 0 Befund(e)
```

**Zum strittigen Punkt 1:** Die Herleitung war zulässig (unter `set -euo pipefail` ist „der letzte
`echo` wurde erreicht" äquivalent zu Exit 0), aber sie war eine Herleitung. Mit dem hier gelesenen
Exit ist der DoD-(1)-Beleg vollständig — kein Befund.

### 5. Die Abdeckungs-Gleichung im Kopf von `full-smoke.sh` — nachgerechnet

```sh
A=$(grep -cE '\|\| [a-z_0-9]+=\$\?$' harness/tools/full-smoke.sh)                       # 43
B=$(… | grep -cE ' -n |span-clean|bash "\$wrapper"')                                    #  7
C=$(… | grep -c 'tmpbin/ai-harness-init')                                               #  6
D=$(grep -cE '^[[:space:]]*einordnen "' harness/tools/full-smoke.sh)                    # 32
# A-B-C = 30  ==  D-2 = 30
```

Die Gleichung **hält**; der neue Abschnitt trägt fünf neue `|| …=$?`-Zeilen, davon zwei
`make -n`-Zeilen (über B ausgenommen) und drei Einordnungen. Der Fenster-Fall
(`test/full-smoke-ausgang.bats`: jede Stufe mit eigenem Exit-Code trägt innerhalb ihres Fensters
eine Einordnung) läuft in `make gates` grün — die zwei `make -n`-Zeilen liegen in einem Fenster
ohne Einordnung und sind über dieselbe B-Ausnahme gedeckt.

### 6. Der Zuschnitt der zwei Mutations-Fälle

Beide `# files:`-Angaben lösen eindeutig auf, beide `# expect:`-Namen sind Go-Testnamen — der
Treiber wählt damit `test-go` (`narrow_sensor`), nicht den vollen Satz.
`grep -cE '^doc-immutable: history-range-guard$' internal/emit/emit.go` → **1** (der `sed`-Operand
trifft genau einmal). `grep -c 'git rev-list --count' internal/emit/templates/enforce/history-range-guard.sh`
→ **2** — der `sed`-Operand von Fall 326 trifft **Code und Prosa**; siehe F-1.

### 7. Der Gegenbeleg zu F-1 — eine Code-only-Mutation, die die Go-Stufe **nicht** rot färbt

Angesetzt wurde **nur die Code-Zeile** des emittierten Wächters
(`sed -i '89s/git rev-list --count/git rev-list --max-count/'`), die Kopfkommentar-Zeile 34 blieb
stehen:

```text
#15 3.980 ok  	github.com/pt9912/ai-harness-init/internal/emit	0.155s
TESTGO_EXIT=0
```

`make test-go` bleibt **grün**, obwohl das Skript die Commit-Zahl der Range nicht mehr zählt (die
Zahlungs-Messung ist weg, die Meldungen blieben). Die Datei wurde danach per
`git checkout --` zurückgenommen (`git status --porcelain` leer).

### 8. `doc-commits` im Dogfood, über einer **nicht** leeren Range

```text
$ make doc-commits RANGE=HEAD~1..HEAD
d-check: error: Range-Basis-Vorfahren nicht lesbar: object not found
make: *** [d-check.mk:103: doc-commits] Fehler 2
```

Im Dogfood ist `doc-commits` über **jeder** Range laut rot, nicht still grün — das steht so auch
in `harness/sensors/history-range-guard.md` (Abschnitt Grenze) und in `.d-check.yml` §commits. Die
Zusage des neuen Fragments über **beide** Targets ist damit für die zweite Hälfte nicht nur
unbewiesen, sondern in dieser Repo-Lage widerlegt. Siehe F-3.

### 9. Gate-Läufe dieses Review-Laufs

| Lauf | Ergebnis |
|---|---|
| `make gates` | **EXIT 0**; `d-check: 1386 Datei(en) geprüft, 0 Befund(e)`; bats `ok 280`; Go-Stufen aller Pakete `ok` |
| `make full-smoke` | **EXIT 0** (Host-Docker/Netz, nicht in `gates`) |
| `make mutate` | **EXIT 0**, `mutate: 312 ok, 0 Befund(e)` — der volle Fall-Satz des Zyklus-Laufs (START 18:41:39, Protokoll `/tmp/mutate2.log`, kein Repo-Artefakt); die zwei neuen Fälle stehen darin mit ihrer Zeile `-> TestDocGateMk_BindetDenVorlaufWaechter rot` bzw. `-> TestEnforce_HistoryRangeGuardZaehltDieRangeMitGit rot`. Ein zweiter Lauf über denselben Satz wurde in diesem Review gestartet und nach **86 von 312** Fällen abgebrochen — der Treiber meldet den Abbruch selbst als „keine vollstaendige Messung" und nicht als Grün; die Aussage über die zwei neuen Fälle trägt darum der Zyklus-Lauf (offene Punkte im Verdikt). |

*Keine Erwartungswerte* — Datei- und Testzahlen wandern mit dem Baum.

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der
verbindlichen Single Source of Truth. Die Spalten unten sind nur
**gespiegelt** (Bequemlichkeit beim Ausfüllen), nicht neu definiert; bei
Abweichung gilt der Skill bzw. dessen Quelle
`v6.8.0` · `regelwerk/modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill.

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | Der Text-Anker des neuen Go-Tests ist **aus der Prosa erfüllbar**: `git rev-list --count` steht einmal im Kopfkommentar und einmal im Code, geprüft wird `strings.Contains` über die ganze Datei. Eine Regression, die nur die Code-Zeile trifft, lässt `make test-go` grün (§7 gemessen) — der Testname behauptet dann eine Eigenschaft, die die Datei nicht mehr hält. | `AGENTS.md` §3.6 | `internal/emit/enforce_test.go:234` (Anker) gegen `internal/emit/templates/enforce/history-range-guard.sh:34` (Prosa) und `:89` (Code) | ja — Code-only-Mutation, `make test-go` bleibt grün (gemessen, §7) | test-anker-aus-der-prosa-erfuellbar |
| F-2 | MEDIUM | Die zwei Vorbindungs-Zeilen machen ein **fehlendes** Target still: fehlt `doc-immutable`/`doc-commits` in einem künftigen `d-check.mk`, läuft der Wächter, das Target hat kein Rezept mehr und `make` endet **EXIT 0** — vor diesem Commit endete dieselbe Lage mit EXIT 2 („Keine Regel", gemessen §3). Gedeckt ist die Hälfte `doc-immutable` durch die Ketten-Prüfung des neuen full-smoke-Abschnitts; für `doc-commits` prüft sie nur die Anwesenheit des Wächters. | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) · `AGENTS.md` §3.6 | `internal/emit/emit.go:83-84` · `harness/tools/full-smoke.sh:357-359` (Gegenstelle `:350-356`) | ja — `make -C <ziel> doc-immutable RANGE=HEAD~1..HEAD` gegen ein `d-check.mk` ohne den Target (gemessen) | vorbedingung-an-ein-fremdes-target-macht-es-still |
| F-3 | MEDIUM | Die Zusage des Fragments über **die zwei** history-lesenden Targets ist nur zur Hälfte rot gesehen: „OHNE den Wächter meldet dasselbe Modul gruen" wird allein für `doc-immutable` gefahren (`make -f d-check.mk doc-immutable`, `harness/tools/full-smoke.sh:412`); für `doc-commits` zeigt keine Stelle den blinden Grün-Fall, und die Repo-eigene Messung sagt das Gegenteil (`doc-commits` bricht im Dogfood über jeder Range mit EXIT 2 ab). | `AGENTS.md` §3.6 · baseline `v6.8.0` · `regelwerk/modul-11-verification.md` §Bewusstes Brechen für DoD-Testbehauptungen | `internal/emit/emit.go:71` · `harness/tools/full-smoke.sh:412` · `harness/sensors/history-range-guard.md:27-31` | ja — `make doc-commits RANGE=HEAD~1..HEAD` im Dogfood: EXIT 2, „Range-Basis-Vorfahren nicht lesbar" (gemessen §8) | abdeckungs-zusage-ohne-rot-beleg-fuer-die-zweite-haelfte |
| F-4 | MEDIUM | Der DoD-Punkt 2 verlangt wörtlich, „dieselbe Sonde auf einem vollständigen Klon bleibt grün" — mit dieser Sonde (leere Range) **kann** sie das nicht: der Wächter bricht über einer leeren Range unabhängig von der Klon-Tiefe ab, und genau das schreibt `harness/sensors/history-range-guard.md` als Vertrag fest („Geprüft wird die Range, nicht die Klon-Tiefe"). Der Umsetzer weicht korrekt auf dieselbe Sonde mit anderer Range aus (Gegenprobe `HEAD~1..HEAD`), zieht den Plan-Text aber nicht nach — die gelieferte Sonde und das Abnahmekriterium stehen jetzt auseinander. | Slice-Plan §2 DoD Punkt 2 · `AGENTS.md` §3.6 | `slice-vorlauf-waechter-geht-ins-ziel` §2 DoD Punkt 2 (Zeilen 108–111), gegen `internal/emit/templates/enforce/history-range-guard.sh:9-13` · `harness/sensors/history-range-guard.md:19-21` | nein — kein Gate liest eine DoD-Formulierung | akzeptanzkriterium-nennt-eine-sonde-die-nie-gruen-wird |
| F-5 | LOW | §1 schließt „**Der Produkt-Code** — `internal/` wird von ihr nicht angefasst" aus, §3 desselben Plans führt `internal/emit/emit.go` als Änderung (und der Diff ändert fünf Dateien unter `internal/emit/`). Der §3-Zuschnitt ist der einzig kohärente (DoD 1 verlangt die Fragment-Bindung, die dort lebt); das Ausschluss-Bullet steht damit falsch. | `AGENTS.md` §3.7 (Zustands-/Bestandsfelder in lebenden Artefakten) · Maintainability | `slice-vorlauf-waechter-geht-ins-ziel` §1 (Zeile 90) gegen §3 (Zeile 135) | nein | plan-abschnitt-widerspricht-dem-eigenen-schnitt |
| F-6 | INFO | Für `MR-005` („emittiertes Layout ist `tools/harness/`, nie `harness/tools/`") gibt es **keinen** generischen Wächter über `enforceFiles()`: der neue Eintrag wird an drei Stellen geprüft (kuratierte Pfad-Liste, Ausführbarkeits-Liste, zwei String-Checks im neuen Test), ein künftiges Skript am lokalen Pfad fiele aber erst auf, wenn jemand seinen Check nachzieht. | [`MR-005`](../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption) · Maintainability | `internal/emit/enforce.go:45-72` · `internal/emit/enforce_test.go:29-66`, `:244` | ja — ein Eintrag mit `harness/tools/…` als `dst` einsetzen; kein Test nennt die Regel generisch | layout-regel-ohne-generischen-sensor |
| F-7 | INFO | Der Hilfetext der Vorbindung wirbt mit `STAGED=1` für **beide** Targets; das Rezept von `doc-commits` führt keinen `STAGED`-Zweig (es übergibt `--range $(RANGE)`), ein Aufruf `make doc-commits STAGED=1` läuft also am Index vorbei in einen leeren Range-Wert. Der Wächter selbst prüft dann den Index, das Modul danach nicht. | Maintainability · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) | `internal/emit/emit.go:80-81` gegen `d-check.mk:101-103` (tool-generierte Form) | ja — `make doc-commits STAGED=1` im Ziel; der Fehlschlag kommt aus der CLI von d-check, nicht aus dem Index | hilfetext-verspricht-einen-modus-den-das-partner-rezept-nicht-fuehrt |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **Bindung als Vorbedingung** (strittiger Punkt, §1) | geprüft, ohne Befund: Fragment verbatim gegen ein echtes `make` gefahren — das Rezept der zwei Targets bleibt das des eingebundenen `d-check.mk`, kein „overriding recipe", die Vorbedingung läuft davor |
| **Reihenfolge Wächter → Modul-Lauf** (§2 Liefer-Punkt 1) | geprüft, ohne Befund: `make -n` zeigt die Ordnung, der reale Abbruch im Ziel nennt **keine** geprüften Dateien — der Modul-Lauf findet nicht statt |
| **`GATE_CHECKS`-Freiheit und ihre Begründung** | geprüft, ohne Befund: die Begründung trägt (die Range setzt der Aufrufer, ohne sie ist der Prüfbereich nicht hermetisch — dieselbe Linie wie `vcs` nicht in `modules:`, bats `ok 270`) und ist als Zusage bewacht (der neue Go-Test weist eine `GATE_CHECKS`-Zeile zurück) |
| **`MR-005`-Layout des neuen Skripts** | geprüft, ohne Befund: `dst` = `tools/harness/history-range-guard.sh`, ausführbar emittiert, das Skript nennt keinen lokalen Pfad — an drei Stellen geprüft (Grenze der Prüfung: F-6) |
| **Mutations-Fälle 325/326** | geprüft, ohne Befund zum Zweck: beide `sed`-Operanden treffen, beide `# expect:`-Namen sind Go-Testnamen und wählen die Go-Stufe; Fall 325 trennt die zwei Bindungs-Zeilen (nur `doc-immutable` geht) — die schwächere Auflösung von Fall 326 ist als F-1 benannt | Der Zyklus-Lauf führt beide mit der Zeile `mutate: ok … -> <Testname> rot` (§9) — der benannte Wächter fällt also, und Fall 326 fällt dabei über die Prosa (F-1).
| **`AGENTS.md` §3.6 für den Gesamtlauf-Beleg** (strittiger Punkt 1) | geprüft, ohne Befund **im Nachhinein**: die Ableitung des Umsetzers war zulässig, und dieser Lauf hat den Gesamt-Exit zusätzlich **gelesen** (`make full-smoke` → EXIT 0, §4) |
| **Abdeckungs-Gleichung des E2E-Sensors** | geprüft, ohne Befund: A−B−C = 30 == D−2 = 30 und der Fenster-Fall der Einordnungen laufen in `make gates` grün (§5) |
| **`AGENTS.md` §3.7 über allen geänderten Texten** | geprüft, mit den Befunden F-5 (Plan-Prosa) und F-7 (Hilfetext) und sonst ohne Befund: keine Befund-Kennung als Begründung, keine Slice-Nummer als Erzählung, kein Lauf-Protokoll, kein abgebrochener Satz in den neuen Kommentaren — die zwei kontrafaktischen Formulierungen („ein zweites Rezept hier waere … weg", „ein String-Grep darauf waere bruechig") sind als Kopplungs-/Abgrenzungs-Aussage eingeordnet und haben Vorbilder im Bestand, eines wörtlich in derselben Datei (`TestEnforce_GuardBashAwkOnly`), eines in `test/mutations/17`; die Klassifikations-Grenze bleibt Architect-Sache |
| **Sensor-Doc `harness/sensors/history-range-guard.md`** | geprüft, ohne Befund: der neue Abschnitt beschreibt die Stelle, seine eine Mess-Aussage über die abweichende Ziel-Fassung ist am Diff bestätigt (die zwei `--decide`-Zweige fehlen dort tatsächlich), die Links lösen auf (`make docs-check` 1386/0) |
| **`AGENTS.md` §3.2 (Lint-Suppression)** | geprüft, ohne Befund: kein `//nolint`, kein `# shellcheck disable` im Diff |
| **`AGENTS.md` §3.9 (Docker-only)** | geprüft, ohne Befund: das emittierte Skript läuft mit `bash + git` (kein Image, kein Netz), der neue Abschnitt fordert kein Bild an den git-Schritten |
| **Gate-Lockerung ohne ADR (§3.5)** | geprüft, ohne Befund: keine Schwelle, kein Modul, keine Strenge gesenkt — die Änderung nimmt einen grünen Pfad weg; die Modul-Zusammensetzung der emittierten Konfiguration ist unberührt |
| **`MR-017` / Init-Invariant-Menge** | geprüft, ohne Befund in der Richtung dieses Diffs: `doc-immutable`/`doc-commits` kommen jetzt über die Vorbindungs-Zeilen in `InitInvariantTargets()` und sind damit aus der Neutralisierung genommen; die Aussage „die zwei Targets schreibt jeder Bootstrap" ist an der tool-generierten Form gedeckt (`d-check.mk:97-103`) — die *Mechanik* dieser Zeilen ist F-2, die *Beleg-Hälfte* für `doc-commits` F-3 |
| **`MR-025` (Zahl neben Kommando)** | geprüft, ohne Befund: die neuen Texte führen keine Zahl als Erwartungswert; die zwei Zeichenketten `"0 Befund(e)"` sind zitierte Programm-Ausgabe |
| **Traceability der Commit-Message** | geprüft, ohne Befund: `LH-FA-06` und `LH-QA-01` sind genannt, die Rolle steht im Betreff |
| **Rollentrennung (§3.8/§3.10)** | geprüft, ohne Befund: der Commit berührt keine Hard Rule, keinen Adaptions-Eintrag, keine ADR, keinen Closure-Artefakt-Zuschnitt |
| **Parallele Commits auf `main` während dieses Laufs** | geprüft, ohne Befund für den Gegenstand: sechs Commits (19:22–19:23, Planner/`slice-mv`) berühren ausschließlich `docs/plan/planning/**` — keine der geprüften Dateien (`harness/`, `internal/`, `test/`, `Makefile`, `d-check.mk`, `.d-check.yml`) ist darunter. Grenze: die Zeilennummern der Fundstellen zitieren `59fd546c`, für die geprüften Dateien identisch mit dem fortgeschrittenen Stand. |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 (F-1) |
| MEDIUM | 3 (F-2, F-3, F-4) |
| LOW | 1 (F-5) |
| INFO | 2 (F-6, F-7) |

**Finding-Klassen dieses Laufs:** test-anker-aus-der-prosa-erfuellbar ·
vorbedingung-an-ein-fremdes-target-macht-es-still ·
abdeckungs-zusage-ohne-rot-beleg-fuer-die-zweite-haelfte ·
akzeptanzkriterium-nennt-eine-sonde-die-nie-gruen-wird ·
plan-abschnitt-widerspricht-dem-eigenen-schnitt ·
layout-regel-ohne-generischen-sensor ·
hilfetext-verspricht-einen-modus-den-das-partner-rezept-nicht-fuehrt

Zwei davon sind **wiederkehrend**: `abdeckungs-zusage-ohne-rot-beleg-fuer-die-zweite-haelfte` und
`akzeptanzkriterium-nennt-eine-sonde-die-nie-gruen-wird` standen schon in
`2026-08-27-slice-106-review.md` (F-2 bzw. F-1) am selben Modul. Ob das den Zähler bewegt,
entscheidet die Slice-Closure §7 — dieser Report zählt nicht.

## Verdikt

**Merge-blockierend: ja, F-1.** Der Test, der den emittierten Wächter auf Go-Ebene bewachen soll,
lässt eine Code-only-Regression grün (§7, gemessen) — `make gates` meldet dann grün über einer
Eigenschaft, die die Datei nicht mehr hält. Der Fix ist klein und gehört dem Implementer, nicht diesem Report.

**Die vier strittigen Punkte, je ein Satz.** (1) Der abgeleitete Gesamt-Exit war zulässig und ist
mit dem hier gelesenen `FULLSMOKE_EXIT=0` vollständig — kein Befund. (2) Der DoD-Punkt 2 ist
wörtlich unerfüllbar; die Auslegung des Umsetzers ist die einzig kohärente, aber die Abweichung
gehört in den Plan nachgezogen (F-4) — keine Umgehung der Zusage. (3) Der blinde Grün-Pfad ist ein
**offener Defekt**, keine bloß benannte Grenze: er entsteht mit diesem Commit (gemessen: vorher
EXIT 2, jetzt EXIT 0), er ist an der Fehlerstelle in keinem Artefakt benannt, und eine der zwei
Hälften hat gar keinen Sensor (F-2) — die Weitergabe an den Planner ist der richtige Weg, braucht
aber ein Artefakt (diesen Report) und einen der drei Ausgänge:
schließen · als benannte Grenze an die Stelle schreiben, an der sie entsteht · Folge-Slice schneiden. (4) Der §3-Zuschnitt trägt
(die Lieferung ist ohne `internal/emit/` nicht möglich, DoD 1 verlangt genau dort die Bindung); das
§1-Bullet steht falsch (F-5).

**Offen geblieben in diesem Lauf** (was dieser Report NICHT geprüft hat): (a) ein **eigener** voller `make mutate`-Lauf — gestartet und nach 86 von 312 Fällen abgebrochen (der Treiber meldet das selbst als unvollständige Messung); die zwei neuen Fälle stützen sich auf das Protokoll des Zyklus-Laufs (§9), nicht auf einen Lauf dieses Reports; (b) die blinde-Grün-Hälfte im **emittierten Ziel** für `doc-commits` — `make full-smoke` räumt seine tmp-Ziele beim EXIT weg, ein gebootstrappter Baum lag danach nicht mehr vor; F-3 stützt sich darum auf die Dogfood-Messung (§8) und den Sensor-Vertrag, nicht auf einen eigenen Ziel-Lauf; (c) die wörtliche DoD-Sonde aus F-4 ist nicht fahrbar, weil sie in keiner Umgebung grün werden kann; (d) die span-/Telemetrie-Achse liegt außerhalb dieses Gegenstands.

**Übergabe:** F-1, F-2, F-5, F-7 gehen an den **Implementer**. F-3 und F-4 sind **Plan**-Punkte und
gehen an den **Planner** (DoD-Text nachziehen bzw. die zweite Hälfte entweder messen lassen oder die
Zusage auf ein Target einschränken). F-6 ist eine Struktur-Frage am Test-Layout und geht als offene
Frage an den **Architect** — sie ist kein Implementer-Punkt dieses Diffs. Die Finding-Klassen gehen
in die Slice-Closure §7 und von dort in das Beobachtungs-Register.

Dieser Report ist ein **Lauf-Beleg** (Audit: dieser Diff, dieser Skill, dieses Modell, dieses
Verdikt) — er wird über Läufe hinweg nicht wieder gelesen und muss es nicht. Er ersetzt keine
Verifikation: DoD-/Spec-Konformität prüft der Verifier separat (Modul 11).
