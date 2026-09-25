# Verifikations-Report: slice-emittierte-dateien-behalten-lf-im-autocrlf-klon — 2026-09-25

**Verifikations-Art:** DoD-/ADR-Konformität und Plan-vs-Code-Diff (Modul 11): „Bauen wir es richtig?" — gegen Plan, DoD und `ADR-0067`.
Nicht die Frage des Validators (das Richtige) und nicht die des Reviewers (Diff gegen Plan, ADR, Hard Rules).

**Gegenstand:** `git diff bd76d800..HEAD` bei `HEAD` `10561b46` — zwölf Commits, 18 Dateien. Slice `slice-emittierte-dateien-behalten-lf-im-autocrlf-klon`
(§1 Setzungen 1 bis 4, Liefer-Punkte 1 bis 3, §5, §6, §8) — Kennung, nicht Pfad: der Plan liegt in `in-progress/` und wandert nach `done/`.
**Constraint:** `ADR-0067` (`Accepted`), `ADR-0007`, `ADR-0054`, `LH-QA-04`, `LH-FA-06`, `LH-FA-01`.

**Eingang:** DoD-Bestätigung und Sensor-Belege des Implementers sowie der Review-Report vom selben Tag — beides **Behauptung, keine Quelle**. Gelesen wurden
Plan, Code, Tests, Stufe, Mutations-Fälle und der Treiber (`harness/tools/mutate.sh`: `narrow_sensor`, `failure_form`, `run_case`). **Kein Selbst-Verifizieren:**
frischer Kontext; der Verifier hat keinen Code dieses Slice geschrieben.

**Modell:** Sonnet 5 · **Datum:** 2026-09-25

**Was dieser Lauf selbst gefahren hat** (Docker-only, kein Host-`go`/`python3`, kein `make mutate`, Prüfgegenstand unberührt; alle Sonden in Scratchpad-Kopien
eines frischen `git clone` von `HEAD`, Träger per `make host-bin` in der Kopie gebaut):

- Messweg Punkt 1 an zwei echten Klonen und ohne Emission (Abschnitt Punkt 1), die Stufe `zeilenenden_im_klon` einzeln (Funktionskörper aus `full-smoke.sh`
  gegen das gebaute Binary), grün und dreimal rot (Wrapper-Binary, das die Emission zurücknimmt).
- `make test-go` unmutiert (rc 0) und in je einer eigenen Kopie eine Mutation: die sechs neuen Fälle 446 bis 451, die 19 übrigen der 22 bestehenden, noch nicht gefahrenen Fälle,
  sechs Gegenproben mit geschwächter Zusicherung, zwei Sonden außerhalb der Fall-Liste, dazu der Lauf ohne `git` im Test-Image.
- Dogfood Punkt 3 (`git add --renormalize`, `git ls-files --eol` vorher/nachher, autocrlf-Klon, PNG-Hashes).
- `make e2e-abdeckung` in der Kopie: „unverändert — 22 Stufen, 22 Deklarationen".
- **Nicht gefahren:** `make mutate` (verboten, Beleg-Slot), `make full-smoke` ganz. Die Stufe lief einzeln; die 21 übrigen `full-smoke`-Stufen sind für diesen Slice
  nicht der Gegenstand.

## Verdikt

**Bestätigt** — für alle drei Liefer-Punkte, mit den benannten Grenzen unten (Abschnitt Grenzen der Bestätigung). **Kein DoD-Punkt ist verletzt.** Zwei Befunde
niedriger Klasse (LOW-V1, LOW-V2) berühren keine Zusage der DoD, sondern die Tiefe eines Wächters; sie gehen als Übergabe an den Planner.

## DoD-Punkte: Deckung und Beleg

### Liefer-Punkt 1 · Messweg (Stufe `zeilenenden_im_klon`)

**Was deckt ihn:** die Stufe in `harness/tools/full-smoke.sh` (Kopfzeile `echo "full-smoke: Zeilenenden — …"` und `e2e_abdeckung "LH-FA-01 LH-FA-06" …`), im
Ergebnis-Block `docs/user/e2e-abdeckung.md` (Stufe 17 von 22, Zeile trägt `LH-FA-01` und `LH-FA-06`, nicht `LH-QA-04`: `grep -c 'LH-QA-04' docs/user/e2e-abdeckung.md`
→ **0**).

**Selbst nachgefahren** (`--lang go`, committet, zwei Klone; **Momentaufnahme, keine Erwartungswerte**):

| Bestand | `.harness` | `.claude/hooks` | `.githooks` | `harness/mk` | `tools/harness` |
|---|---|---|---|---|---|
| Klon `core.autocrlf=true`, **mit** Emission | 0 | 0 | 0 | 0 | 0 |
| Kontrollklon `core.autocrlf=false`, mit Emission | 0 | 0 | 0 | 0 | 0 |
| Klon `core.autocrlf=true`, **ohne** die fünf `.gitattributes` | 58 | 3 | 1 | 11 | 11 |

Damit stimmt die Momentaufnahme des Auftrags (58/3/1/11/11) Byte für Zahl. Konsumenten im autocrlf-Klon mit Emission: `.githooks/commit-msg` mit Kennung Exit 0, ohne
Kennung Exit 1 mit der Meldung der Prüfung; `bash tools/harness/baseline-verify.sh` → `baseline-verify: v6.9.0 OK — 54 Dateien`; der Guard blockt
`staticcheck` (`"decision": "block"`). Restmenge ausserhalb der fünf Verzeichnisse: **28** Dateien mit CR (Wurzel-Dateien des Adopters, `.claude/` außerhalb der Hooks,
`docs`, `spec`, `harness/*.md`, `cmd`, `go.mod`) — gleich der Zahl des Auftrags, von der Stufe ausgegeben statt verschwiegen (DoD (d)).

**Rot ohne Emission mit gelesener Meldung** (Kopie ohne die fünf `.gitattributes`, Konsumenten auf den realen Bytes):

- `/usr/bin/env: »bash\r“: Datei oder Verzeichnis nicht gefunden` — `.githooks/commit-msg`, Exit **127**;
- `tools/harness/baseline-verify.sh: Zeile 29: set: pipefail: Ungültiger Optionsname.` — Exit **2**; derselbe Text für den Guard
  (`.claude/hooks/pretooluse-command-guard.sh: Zeile 27`), Exit **2**.

Die Stufe selbst färbt in diesem Zustand rot und nennt je Verzeichnis die Zahl der Dateien und die ersten zehn Pfade
(`FEHLER — Zeilenenden: der Klon mit core.autocrlf=true traegt CR in .claude/hooks (3 Datei(en)); … .claude/hooks/pretooluse-command-guard.sh …`) und je Konsument die
Ausgabe. Zwei Teilzustände zusätzlich, weil die Zusage „das Rot nennt die CR-tragende Datei" an ihnen hängt:

- **nur `.claude/hooks` ohne Emission** → die Stufe nennt die drei Hook-Dateien und den Guard-Ausfall (Exit 2, `pipefail`), sonst nichts: das Rot ist auf das
  Verzeichnis lokalisiert.
- **Endungs-Glob `*.sh` statt `*`** (der Mischzustand aus §1 Setzung 1) → die Stufe nennt `harness/mk/*.mk`, `tools/harness/blocked/go`, `extract-command.awk`,
  `commit-msg` mit Exit 127, `baseline-verify` mit `FEHLER: Baseline v6.9.0 weicht von SHA256SUMS ab` (Exit 1) und — **das ist der stille Fall** — `der Command-Guard
  blockt 'staticcheck' … nicht (Exit 0)`: der Guard läuft (LF), seine Wortliste hat CRLF, das letzte Wort geht verloren. Genau dafür ist der Guard der dritte Konsument;
  ohne ihn bliebe dieser Zustand unsichtbar.

**Wortwahl:** Kopfzeile, Fehlermeldungen und `e2e_abdeckung`-Text sagen für den gewöhnlichen Klon „laut" (Exit 2) und führen „still" nur für den Mischzustand
(Kommentar der Stufe); `grep -n -i 'still'` über den Stufenkörper (Zeilen 3075 bis 3215 von `full-smoke.sh`) → **kein Treffer**. Die DoD-Auflage ist erfüllt.

**Vorbedingung der Stufe trägt aus dem richtigen Grund:** sie verlangt, dass das Wurzel-`Makefile` im autocrlf-Klon CR trägt (der Klon bekommt überhaupt CR) und dass
jedes der fünf Verzeichnisse Dateien führt; ein Klon ohne CR wäre sonst grün aus falschem Grund. Der Kontrollklon setzt `core.autocrlf=false` ausdrücklich und prüft den
gesetzten Wert im Klon (`git config --get`), erbt ihn nicht vom Runner.

**Verdikt Punkt 1:** bestätigt. Rot wird die Stufe aus dem behaupteten Grund (CR im Verzeichnis ohne Zeile), und die Meldung nennt die Datei.
**Grenze:** die Stufe belegt den Smudge-Filter von git unter Linux, keinen Windows-Lauf (`LH-QA-04`, Grenze der Messmethode) — als benannte Grenze in Plan §6 und
`ADR-0067` Festlegung 5; keine unbelegte Zusage.

### Liefer-Punkt 2 · Emission

**Was deckt ihn:** `internal/emit/zeilenenden.go` (fünf Einträge mit Klasse und Meldung), `internal/emit/templates/enforce/gitattributes` (eine Zeile
`* text=auto eol=lf`, Kommentar nennt Zustand), Anhängen an `enforceFiles()`, Tests `TestZeilenenden_JederKonsumentLiegtUnterEinerZeile` und
`TestZeilenenden_BelegterPfadBleibtUndWirdGemeldet`, Fälle 446 bis 451.

**Selbst nachgefahren:**

- **Fünf Einträge, Klasse je Pfad:** konvergent `.harness/`, `tools/harness/`; skip-if-present mit Meldung `harness/mk/`, `.claude/hooks/`, `.githooks/`
  (Quelltext gelesen; zweiter Lauf gefahren, s. u.). Jede der fünf Varianten (`go`, `go --arch hexslice`, `go --arch hexagonal`, `cpp --arch hexslice`, sprachlos):
  **genau fünf** `.gitattributes` im Index, dieselben fünf Pfade.
- **Keine Interpreter-Datei außerhalb:** über alle fünf Varianten je Datei mit Shebang, Endung `.sh`/`.awk`/`.mk` oder unter `blocked/`: sie liegen ausschließlich in
  den fünf Verzeichnissen und, für die `.mk`, in der Wurzel (`d-check.mk`, `a-check.mk`; `Makefile` trägt keinen Shebang). Die Suche ist an einer Positivkontrolle
  geprüft (sie zählt in `v_go` 3 + 1 + 11 + 10 + 1 Dateien und meldet für „ausserhalb" nichts — sie ist also nicht leer, sondern findet die erwarteten Dateien).
  Das ist die Anwendung des Kriteriums aus §1 Setzung 2 auf den vollständigen Emit; die Rückführungs-Bedingung aus §4 (ein sechstes Verzeichnis) ist **nicht** eingetreten.
- **Zweiter `init`-Lauf** (Ziel mit verstellten Dateien: konvergente auf `* text eol=crlf`, skip-if-present auf einen Adopter-Inhalt): Exit 0; die zwei konvergenten
  sind wieder die Werkzeug-Fassung (Kommentar plus `* text=auto eol=lf`), die drei skip-if-present unverändert (`# adopter\n* text=auto`); die Meldung nennt je Pfad
  Pfad **und** Aussage — Beispielzeile:
  `harness/mk/.gitattributes liegt bereits — die Datei bleibt unberuehrt (skip-if-present). Traegt sie die Zeile '* text=auto eol=lf' nicht, tragen die Dateien in harness/mk/ im Klon mit core.autocrlf=true CRLF.`
  Für die zwei konvergenten Pfade keine Meldung. (`grep -c gitattributes` über das Log: 3.)
- **Adopter-Wurzel `* text eol=crlf`:** `git check-attr eol` → `Makefile`, `README.md` = `crlf`; `.claude/hooks/pretooluse-command-guard.sh`, `tools/harness/blocked/go`,
  `.harness/baseline/v6.9.0/SHA256SUMS`, `.githooks/commit-msg`, `harness/mk/baseline.mk` = `lf` — die genesteten gewinnen. Im Klon (`autocrlf=false`) trägt der Guard 0
  CR, `blocked/go` 0, das Wurzel-`Makefile` 23; `commit-msg` Exit 0 und `baseline-verify` OK. Das belegt die Aussage aus `ADR-0067` Festlegung 5 am Ziel — und damit
  auch den Kommentar der Vorlage („unabhängig von einer `.gitattributes` in der Wurzel", Review INFO-3), **von Hand gemessen**, nicht von einem Sensor gehalten (s. Offene Punkte).

**Eigenschafts-Test — Rot-Belege selbst gesehen** (`make test-go` in der Kopie, Meldung gelesen; Anker trifft jeweils, Bedingung 2 des Treibers):

| Mutation | Fall | rot | gelesene Meldung |
|---|---|---|---|
| ein Eintrag entfällt (`.claude/hooks`) | 446 | `TestZeilenenden_JederKonsumentLiegtUnterEinerZeile` | `.claude/hooks/pretooluse-command-guard.sh hat einen Interpreter- oder Byte-Konsumenten, aber git weist ihr eol=unspecified zu (verlangt: lf)` (und `span-emit.sh`, `stop-require-gates.sh`) |
| `eol=crlf` | 447 | dasselbe | `… git weist ihr eol=crlf zu (verlangt: lf) …` für alle Konsumenten in fünf Verzeichnissen |
| Endungs-Glob `*.sh` | 448 | dasselbe | `.githooks/commit-msg … eol=unspecified`, `.harness/… eol=unspecified` — auch die Dateien **ohne Endung** |
| später hängt `*.sh eol=crlf` an | 451 | dasselbe | `… tools/harness/baseline-verify.sh … eol=crlf zu (verlangt: lf)` |

Die vier Zähne treffen dieselbe Assertion (`wert[rel] != "lf"`, Wert von `git check-attr -z --stdin eol`) und **keinen** Zweig, der die Zeile sucht. Das ist die
Verschärfung gegen den Plantext („eine emittierte `.gitattributes`, die die Zeile trägt"): der Test misst die Wirkung aller Zeilen in git-Reihenfolge, nicht die Anwesenheit
einer. Fall 451 ist deshalb **gebaut, aber nicht geplant** und trägt — er ist der Fall, den die Zeilen-Suche nicht sehen konnte.

**Gegenprobe — grün heißt „bindet"** (Test entwaffnet, dieselbe Mutation): Assertion `wert[rel] != "lf"` → `false && …`: der erwartete Test **fällt bei 446/447/448/451 nicht mehr**
(der Lauf bleibt bei 446/447/448 rot, aber nur über *andere* Tests — Meldungs-Test und Hook-Inventare —; bei 451 ist er **grün**). Die vier Fälle binden also an diese
Assertion; sie färben nicht rot, weil irgendein Zweig irgendwie fällt.

**Meldungs-Test (b):**

| Mutation | Fall | rot | gelesene Meldung |
|---|---|---|---|
| Meldung verliert die Aussage | 449 | `TestZeilenenden_BelegterPfadBleibtUndWirdGemeldet` | `die Meldung zu harness/mk/.gitattributes nennt "core.autocrlf=true" nicht — sie sagt dann nicht, was gilt: …` (ebenso `"CRLF"`) |
| `harness/mk/` skip-if-present → konvergent | 450 | dasselbe | `harness/mk/.gitattributes wurde ueberschrieben (skip-if-present verletzt)` und `die Meldung nennt den belegten Pfad … nicht` |

Gegenprobe 449: die drei Aussage-Strings (`Zeile`, `core.autocrlf=true`, `CRLF`) aus der Prüfliste genommen → **grün** (bindet). Gegenprobe 450: die Überschreibe-Prüfung **und** die
Meldungs-Existenz entwaffnet → der erwartete Test **bleibt rot** (über die Aussage-Schleife über der leeren Zeile). Der Fall 450 ist also von **drei** Assertions getragen; das ist
Redundanz, keine Lücke, aber die Gegenprobe ist damit nicht sauber isolierbar (kein Befund).

**Klassen-Treue je Pfad gegen die ADR:** `TestEnforce_IdempotenzKlasseJePfad` läuft über `EnforcePaths()`/`PathClass` und trägt die fünf neuen Pfade (die Aufzählung enthält
sie — die Pfade fehlen dort nicht), **hält aber die Klasse nicht gegen die Festlegung der ADR**: Fall 450 färbt sie *nicht* (nur `TestZeilenenden_BelegterPfad…` fällt;
Befund: `--- FAIL:`-Liste des Laufs = genau ein Test). Das ist Review INFO-1 und **kein** DoD-Bruch: die Klasse je Pfad hält der neue Meldungs-Test aus einer **eigenen**
Aufzählung (`skip`/`konvergent`), nicht aus `PathClass`. Zusatzsonde: `.harness/` konvergent → skip-if-present → `TestZeilenenden_BelegterPfad…` rot
(`.harness/.gitattributes wurde nicht kanonisch neu geschrieben (konvergent verletzt)`), also greift auch die andere Richtung.

**Bricht der Test ab, wenn `git` fehlt?** Ja. Im Test-Image `git` entfernt (Sonde im Scratchpad, `docker run` auf dem gebauten Test-Image):
`--- FAIL: TestZeilenenden_JederKonsumentLiegtUnterEinerZeile … zeilenenden_test.go:127: git init -q: exec: "git": executable file not found in $PATH` — der Test besteht
nicht still, er fällt (`t.Fatalf` im Helfer).

**Verdikt Punkt 2:** bestätigt. **Beleg trägt aus dem richtigen Grund** (Meldung gelesen, Gegenprobe gefahren). Ein Rest: LOW-V1 (unten).

### Liefer-Punkt 3 · Dogfood

**Was deckt ihn:** die Wurzel-`.gitattributes` (`* text=auto eol=lf`, Kommentar nennt Zustand) — Konfiguration, keine dritte Schicht.

**Selbst nachgefahren** (Wegwerf-Klons von `HEAD` und `bd76d800`, `core.autocrlf=false`; **Momentaufnahme**):

- `git ls-files --eol | awk '{print $1,$2}' | sort | uniq -c` vorher `2590 i/lf w/lf`, `11 i/none w/none`, `2 i/-text w/-text`, `10` ohne Angabe; nachher `2601 i/lf w/lf`, sonst
  gleich — die **zwei `i/-text` bleiben**. Der Pfad-Diff (`i`-/`w`-Spalte plus Pfad) nennt ausschließlich die neuen Dateien und den Move des Slice (`next/` → `in-progress/`):
  `.gitattributes`, `internal/emit/{templates/enforce/gitattributes,zeilenenden.go,zeilenenden_test.go}`, `test/mutations/446…451`, der Review-Report. **Kein Bestand ändert seine
  Zeilenenden-Spalten.**
- `git add --renormalize . && git diff --cached --name-only | grep -vc '^\.gitattributes$'` → **0**. Gegenprobe der verworfenen Alternative (`* text eol=lf`): **2** (beide PNG) —
  die Begründung von `text=auto` steht damit am Bestand.
- Klon von `HEAD` mit `-c core.autocrlf=true`: `SHA256SUMS` **0** CR (Plan: „heute 54"), `pretooluse-command-guard.sh` **0** CR (Plan: „heute 119"); `harness/tools`, `.claude/hooks`, `.githooks`
  ohne CR-Datei; `bash harness/tools/baseline-verify.sh` → `OK — 54 Dateien`. Beide PNG haben in Arbeitsbaum, autocrlf-Klon und `bd76d800`-Stand **denselben** sha256 (zwei Hashes, je dreimal).
- Doku-Gate: siehe `make gates` (Übergabe-Nachricht).

**Grenze:** die Zeile ist Konfiguration; ein Sensor hält sie nicht — die DoD verlangt ausdrücklich „die Messung steht in der Closure-Notiz; sie ist kein Gate". Die drei Kommandos oben
sind für den Planner das Material dafür.

**Verdikt Punkt 3:** bestätigt.

## Zähne 446 bis 451 und die betroffenen bestehenden Fälle

**Ehrlich vorab:** es gab **keinen** vollen `make mutate`-Lauf für diesen Stand. Ein Lauf mit `MUTATE_JOBS=6` (439 Fälle) wurde nach 151 `ok` und 0 Befunden kontrolliert abgebrochen; der repo-weite
Satz läuft nächtlich (`mutate.yml`). Die folgende Emulation ist **kein Ersatz** für einen grünen Vollauf.

**Emulationsweg.** Je Fall eine frische Kopie von `HEAD` (ohne `.git`, ohne `.harness/state`); `# files:`/`# expect:` gelesen, Skript des Falls angewandt, Bedingung 2 (Datei-Hash
ändert sich — der **Anker trifft**), dann `make test-go` (`narrow_sensor` wählt für einen `Test…`-Namen `test-go`, `failure_form` ist `--- FAIL:`), Bedingung 4: `grep '--- FAIL:'`
nennt den erwarteten Testnamen. Der Grün-Vorlauf (`make test-go` unmutiert) ist rc 0. Kopf-Form der sechs neuen Fälle gegen den Treiber: ein `# files:`, ein `# expect:` mit Go-Testnamen,
kein `# verify:` (`narrow_sensor` → `test-go`); Modus `100755` wie der Bestand (`git ls-files -s`).

**Ergebnis: 25 von 25 emulierten Fällen `ok`** (Anker trifft, erwarteter Test rot, aus dem behaupteten Grund):

| Gruppe | Fälle | Ergebnis |
|---|---|---|
| neu | 446, 447, 448, 449, 450, 451 | je **ok** (Meldungen oben gelesen) |
| bestehend, noch nicht gefahren (22 laut Auftrag; 446, 449, 450 davon sind die neuen Fälle) | 34, 49, 50, 52, 56, 155, 156, 157, 158, 159, 170, 183, 328, 334, 344, 348, 354, 365, 382 (19) | je **ok** — kein Anker verschoben, kein Fall grün geblieben |


**Unabhängige Kontrolle der Menge.** Ich habe die Liste der „betroffenen" Fälle selbst berechnet: `# files:` enthält `harness/tools/full-smoke.sh`, `internal/emit/enforce.go`,
`enforce_test.go`, `baumaussage_test.go`, die Vorlage oder `zeilenenden*.go` → **29 Fälle**. Jeder von ihnen ist entweder von mir emuliert (25) oder steht im `ok`-Log des abgebrochenen Laufs
(4). **Kein betroffener Fall ist ungefahren.**

**Restmenge, ehrlich benannt (Klasse „erwartet einen Test in einer geänderten Testdatei, mutiert aber eine andere Datei"):** **13** Fälle, deren `# expect:` ein Test aus `enforce_test.go`
oder `baumaussage_test.go` ist, deren `# files:` aber keine der geänderten Dateien nennt (`31`, `32`, `39`, `42`, `43`, `162`, `326`, `361`, `364`, `368`, `369`, `383`, `384`). Die Änderung
an diesen Testdateien sind zwei Listen-Erwartungen (`.gitattributes` im Hook-Inventar) und zwei gepinnte Bestände; eine Verschiebung des Ankers ist damit **nicht** zu erwarten, aber **von niemandem
gefahren** — nicht von mir (Budget), nicht im abgebrochenen Lauf (keiner steht im `ok`-Log). Der nächtliche Lauf fängt sie.

**Was der Vollauf zusätzlich zeigt** und diese Emulation nicht: das Wechselspiel der Worker (`MUTATE_JOBS`), den Beleg-Slot nach `ADR-0035` (`Proposed`), die Zeit-Bilanz — Eigenschaft des
Laufs, nicht der Zähne. Die 151 `ok` des abgebrochenen Laufs habe ich **nicht** nachgeprüft (Zeilenzahl des Logs 151; als Behauptung übernommen).

## Gegenproben und Sonden (Zusammenfassung)

| Probe | Ergebnis | Lesart |
|---|---|---|
| 446/447/448/451, Assertion `wert[rel] != "lf"` entwaffnet | erwarteter Test fällt **nicht** | bindet an die Wert-Assertion |
| 449, drei Aussage-Strings entwaffnet | grün | bindet an die Aussage |
| 450, Überschreibe-Prüfung und Meldungs-Existenz entwaffnet | bleibt rot | von drei Assertions getragen, kein Befund |
| `.harness/` konvergent → skip-if-present | rot, `nicht kanonisch neu geschrieben` | andere Klassen-Richtung gedeckt |
| Meldung des `.githooks`-Eintrags nennt im Aussage-Teil ein falsches Verzeichnis (`"x"`) | **grün** | **LOW-V1** |
| `git` fehlt im Test-Image | Test fällt (`git init -q: exec: "git" … not found`) | bricht ab, besteht nicht still |

## Befunde

**LOW-V1 — eine Assertion im Meldungs-Test kann unter keiner Mutation rot werden.** In `TestZeilenenden_BelegterPfadBleibtUndWirdGemeldet` prüft die Aussage-Schleife
`path.Dir(rel) + "/"` gegen die Meldungszeile, die den Pfad `rel` selbst trägt (`rel` = `.githooks/.gitattributes` enthält bereits `.githooks/`). Sonde: die Meldung des Eintrags
`.githooks` nennt im Aussagesatz `x/` statt `.githooks/` → `make test-go` **grün** (rc 0, `TestZeilenenden_BelegterPfad…` besteht). Die Zusage der DoD („die Meldung nennt den Pfad **und** die
Aussage, was dann gilt") hält an den drei übrigen Strings (`Zeile`, `core.autocrlf=true`, `CRLF`) und am Pfad-Treffer; nicht gehalten ist, dass die Aussage das **richtige Verzeichnis** nennt.
Nach `AGENTS.md` §3.6: der Test-Bestandteil beansprucht (Kommentar: „nennt den Pfad UND die Aussage … `path.Dir(rel)/`"), was er nicht messen kann. **Berührt keinen DoD-Punkt**; Abhilfe wäre, die
Aussage-Zeile ohne den Pfad-Präfix zu prüfen (Teilstring `in <verzeichnis>/ im Klon`).

**LOW-V2 — Klasse je Pfad: `TestEnforce_IdempotenzKlasseJePfad` deckt die neuen Pfade nicht gegen die ADR (Review INFO-1, bestätigt).** Plan §2 sagt „trägt die neuen Pfade, sobald sie in der Aufzählung stehen" — das
stimmt, die Prüfung hält aber `PathClass` gegen das Verhalten, nicht gegen `ADR-0067` Festlegung 3; ein Klassenwechsel färbt sie nicht (Fall 450: einziger roter Test ist der neue). Die Klassen-Treue hält der neue Meldungs-Test aus
eigener Aufzählung; die Zusage ist damit **gehalten, aber an einer anderen Stelle als der Plantext sagt**. Kein DoD-Bruch.

## Plan-vs-Code-Diff (beide Richtungen)

**Geplant und gebaut:** die sieben Zeilen der Tabelle in Plan §3 — Stufe in `full-smoke.sh`, regenerierte `e2e-abdeckung.md`, Vorlage, Einträge (fünf), Tests (a) und (b), Fälle, Wurzel-`.gitattributes`.
Reihenfolge nach Plan: Punkt 1 vor Punkt 2 committet (`46730987` vor `1b482a15`), Punkt 3 danach (`14592003`); das Rot der Stufe hatte damit einen Stand.

**Gebaut, nicht geplant (vollständig):**

- `internal/emit/zeilenenden.go` als **eigene Datei** — der Plan nennt `enforce.go` als Ort der fünf Einträge; sie stehen in `zeilenendenFiles()`, das `enforceFiles()` anhängt (`return append(files, zeilenendenFiles()...)`).
  Die Klasse steht damit nur dort, aber nicht in `enforceFiles()` selbst. Wirkungslos für die DoD, aber eine Abweichung vom Ortsplan.
- Fälle **450 und 451** (Plan nannte: Eintrag streichen, `eol=crlf`, Endungs-Glob, Meldung ohne Aussage). 450 = Klassenwechsel (hält die Klasse je Pfad), 451 = spätere überstimmende Zeile. **Verschärfung, kein Verstoß.**
- Test (a) fragt `git check-attr eol` statt die Zeile zu suchen (Commit `613f63d5`): stärker als die Plan-Formulierung („liegt eine `.gitattributes`, die die Zeile trägt").
- Stufe führt als dritten Konsumenten den **Command-Guard** (`staticcheck`), Plan nannte `commit-msg` und `baseline-verify`. Deckt den stillen Mischzustand aus §1; Verschärfung.
- Anpassungen in `enforce_test.go` (Hook-Inventar erwartet `.gitattributes`) und `baumaussage_test.go` (gepinnter Bestand) — im Plan §3 als „Betroffen … prüft beide Richtungen" angekündigt, Umfang klein (2 + 2 Zeilen).
- Roadmap: der Ruhe-Marker ist entfernt (Handgriff des Anspruchs, `7a031289`); `Wiederherstellen` ist Planner-Closure.
- `full-smoke.sh`: die neue Stufe ist die **17.**, spätere Stufen verschieben sich um eins in `e2e-abdeckung.md`; regeneriert (`make e2e-abdeckung`: „unverändert — 22 Stufen, 22 Deklarationen").

**Geplant, nicht gebaut:** nichts. `harness/sensors/full-smoke.md` zählt keine Stufen namentlich auf (§Deklaration der Stufen beschreibt den Mechanismus) → keine Änderung nötig; `internal/emit/baumaussage.go` nennt weder
`.gitattributes` noch Zeilenenden → keine Änderung nötig (`grep` leer).

## Abgrenzung und DoD-Kopplungen

| Punkt | Befund |
|---|---|
| kein Adaptions-Eintrag, keine Hard-Rule-Änderung | `git diff bd76d800..HEAD -- harness/conventions.md harness/conventions AGENTS.md` → **leer** |
| `ADR-0067` unberührt | `git diff bd76d800..HEAD -- docs/plan/adr` → **leer** |
| `test/full-smoke-ausgang.bats` nicht gelockert | `git diff bd76d800..HEAD -- test/full-smoke-ausgang.bats` → **leer** |
| `make e2e-abdeckung` unverändert | „22 Stufen, 22 Deklarationen"; Beleg-Klausel der Stufe `LH-FA-01 LH-FA-06`, nicht `LH-QA-04` |
| Wortwahl laut/still | laut im gewöhnlichen Klon, still nur im Mischzustand; kein „still" im Stufenkörper |
| Größe | 3 Liefer-Punkte (≤ 3); zwei Schichten (`internal/emit/`, `harness/tools/full-smoke.sh`); Wurzel-`.gitattributes` ist Konfiguration — Größenregel eingehalten |
| Handbuch | nicht berührt (`git diff --name-only bd76d800..HEAD -- docs/user` → nur `e2e-abdeckung.md`); Ist-Änderung ist der Release-Schnitt (Review INFO-4) |

## Offene Punkte, bewertet, nicht geschlossen

| Punkt | Berührt die DoD? |
|---|---|
| Review INFO-1 (Klasse aus der Aufzählung im Test) | **Nein** — LOW-V2 oben; die Klassen-Treue ist an anderer Stelle gehalten |
| Review INFO-3 (Vorlagen-Kommentar-Zusage „unabhängig von einer Wurzel-`.gitattributes`" nur von Hand gemessen) | **Nein** — von mir am Ziel gemessen (Adopter-Wurzel `* text eol=crlf`, genestete gewinnen); **kein Sensor hält sie**: der Eigenschafts-Test baut keine Adopter-Wurzel, die Stufe ebenso wenig. Die Zusage ist wahr und ungehalten — eine benannte Lücke |
| Review INFO-4 (Handbuch/Release-Schnitt) | **Nein** — Nutzerdoku trägt den Ist-Zustand, das Update gehört in den Release-Schnitt |
| Restmenge 28 Dateien außerhalb der fünf Verzeichnisse, Windows-`make`/BuildKit | **Nein** — Plan §1 „Ausdrücklich NICHT" und §6 mit Ausgang *weiter offen*; die Stufe gibt die Restmenge aus (`28`) |
| `slice-mv` schreibt Verweise in `docs/reviews/` um (Werkzeug-Konflikt mit §3.11) | **Nein** — trat beim Anspruch nicht auf (`git status` sauber, Verweise im Review-Report nennen die Kennung); Werkzeug-Frage, kein Gegenstand dieser DoD |
| `ADR-0035` `Proposed` | **Nein** — der Beleg-Slot ist Eigenschaft des Vollaufs `make mutate`; ein grüner Vollauf steht aus |
| Roadmap-Ruhe-Marker entfernt | **Nein** — Wiederherstellen bei der Closure ist Planner-Arbeit (§3.10) |
| **Kein voller `make mutate`-Lauf** für diesen Stand | **Ja, als Grenze der Bestätigung**: die DoD verlangt keinen; die 13-Fälle-Restmenge oben bleibt unbelegt bis zum nächtlichen Lauf |

## Grenzen der Bestätigung

- Windows: nicht gemessen und nicht behauptet (`LH-QA-04`); die Stufe belegt git unter Linux.
- Ein Vollauf `make full-smoke` wurde **nicht** gefahren; die Stufe lief einzeln. Ein Wechselspiel mit den übrigen Stufen ist unbelegt.
- Der Emulationsweg ersetzt den Treiber nicht: Isolation, Fingerabdruck, Bedingungen 5 und 6 des Treibers sind nicht gemessen.
- 13 Fälle der Klasse „erwartet Test in geänderter Testdatei, mutiert andere Datei" von niemandem gefahren.

## Übergaben an den Planner

1. **Bestätigung:** alle drei Liefer-Punkte bestätigt; das Rot der Stufe vor Punkt 2 ist von diesem Lauf **erneut** gesehen (Meldungen oben), nicht nur übernommen. Closure-Kriterium 1 und die Messung aus Punkt 3 (drei Kommandos)
   sind belegt; **`make gates` grün auf dem Stand** trägt die Übergabe-Nachricht (Kriterium 2 gehört der Closure).
2. **Register (Lese-Schritt):** die Klasse *„Wächter-Aussage trägt eine Assertion, die sich selbst erfüllt"* (LOW-V1: `path.Dir(rel)/` im Meldungs-Test) ist ein Fall für den Zähler; zuerst zu prüfen, ob eine bestehende
   Beobachtung dieselbe Klasse trägt, bevor eine neue angelegt wird.
3. **Register:** *Vorlagen-Kommentar-Zusage, die ein Sensor nicht hält* (INFO-3) und *Klassen-Kopplung nimmt die Klasse aus der Aufzählung, die sie prüfen soll* (INFO-1/LOW-V2) — dieselbe Klasse `emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`
   (Zähler 2 laut Plan §8); erreicht sie mit diesem Slice 3×, ist sie laut Plan-Text „keine Notiz mehr, sondern eine Lücke" — Entscheidung des Lese-Schritts.
4. **Closure-Schritte, die der Planner behält:** Roadmap-Ruhe-Marker wiederherstellen; §7 mit dem Lerneintrag; Risiko-Ausgänge nach §6 (die zwei Neuanlagen im Register); DoD-Häkchen; `git mv` nach `done/`.
5. **Nächtlicher `make mutate`-Lauf** ist der Träger der 13 Restfälle und des Beleg-Slots; erst ein grüner Vollauf ersetzt die Emulation.

## Was dieser Bericht nicht ist

Kein Review (Diff gegen Plan/ADR/Hard Rules — der Report vom selben Tag), keine Validierung (kein realer Bedarf geprüft), keine Closure. Der Verifier hat nichts am Prüfgegenstand geändert; berührt ist allein diese Datei.
