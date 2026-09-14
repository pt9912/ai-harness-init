# Review-Report: slice-vorlauf-waechter-geht-ins-ziel — Runde 2 — 2026-09-14

**Review-Art:** Code-Review gegen **Plan + Hard Rules** (Modul 10 §Drei Review-Arten). **Zweiter
Lauf** am selben Gegenstand, geprüft ist das **Delta** seit Runde 1. **Kein DoD-Review** —
DoD-/Spec-Konformität prüft der Verifier (Modul 11, anderer Eingabe-Kontext).

**Gegenstand:** die zwei Commits nach dem Runde-1-Stand `493d4fff` — `fa00e736` (Erstfassung der
Behebung, laut Umsetzer **rot**: `gochecknoglobals` + ein `shellcheck`-SC2016) und `1e6f9e4b` (die
Spitze). Beide sind geprüft, weil der rote Zwischenstand eigener Befundstoff ist (§1).
**Geprüfter Stand:** `1e6f9e4b`; `main` ist seither um Planner-Commits weitergerückt
(`0092870f`, `a278359d`, `138c7a2e`, `f342bdf9`, `7159a52c`), von denen keiner eine hier geprüfte
Datei berührt. Runde-1-Report: `docs/reviews/2026-09-14-slice-vorlauf-waechter-geht-ins-ziel.md`
— **sein Urteil ist nicht übernommen**: jeder Befund ist in diesem Lauf einzeln nachgemessen
(§1–§10), keiner abgeschrieben.

**Kein Self-Review (Negativ-Aussage):** dieser Lauf hat an `fa00e736` und `1e6f9e4b` **nicht
geschrieben** — kein Kommentar, kein Test, kein Fragment, keine Mutations-Datei dieses Deltas
stammt aus diesem Kontext. Aus der Commit-Message und aus dem Implementer-Bericht ist **nichts**
als Befund oder als Negativbefund übernommen; die dort behaupteten Rot-Belege sind einzeln
nachgefahren (§2, §5, §7, §8).

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

- Slice-Plan `slice-vorlauf-waechter-geht-ins-ziel` (§1 Ziel und Abgrenzung, §2 DoD, §3 Plan)
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules; tragend hier §3.6, §3.7, §3.9)
- [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [`LH-FA-06`](../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)
- [`MR-005`](../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption) ·
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed) ·
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
- Baseline `v6.8.0` · `regelwerk/modul-11-verification.md` §Bewusstes Brechen für
  DoD-Testbehauptungen
- Vorherige Findings am **selben Gegenstand**: Runde 1 dieses Laufs (1 HIGH · 3 MEDIUM · 1 LOW ·
  2 INFO); am **selben Modul**: `2026-08-27-slice-106-review.md`, `2026-09-10-slice-073-emittierte-doc-gate-module-runde-5.md`

---

## Eigene Messungen

Jedes Kommando dieses Abschnitts ist in diesem Lauf gefahren. Wo eine Zahl steht, steht das
Kommando daneben, das sie liefert; **keine Erwartungswerte**
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).

### 1. Der rote Zwischenstand `fa00e736` — was er war, und was die Spitze daran zieht

| Frage | Messung |
|---|---|
| War der Zwischenstand wirklich rot? | **ja, in zwei Gates.** Der SC2016 ist gefahren: `docker run … koalaman/shellcheck:… old.sh new.sh` → `old.sh` (Stand `fa00e736`) meldet `SC2016 (info)` auf dem `sed`-Operanden, EXIT 1; `new.sh` (Stand `1e6f9e4b`) meldet **nichts**, EXIT 0 (`shell-lint` deckt `test/mutations/*.sh` — Rezept des Targets). Der `gochecknoglobals`-Verstoß ist am Diff sichtbar (`var vorbindungsTargets = []string{…}` → `func vorbindungsTargets() []string`). |
| Zieht die Spitze etwas **stillschweigend** glatt? | **nein.** Beide Reparaturen sind in der Message der Spitze benannt (`gochecknoglobals-konform`, „Dollar in einer Klammer-Klasse, shellcheck-konform"), und die zweite ist inhaltlich nachgemessen: der neue Operand führt **dieselbe** Mutation aus — `sed -i 's/git rev-list --count "[$]range"/…/'` trifft genau **eine** Zeile, die Code-Zeile 89 der Vorlage (`diff` gegen die Sicherung: nur `89c89`), die Prosa bleibt stehen. |
| Hat der Zwischenstand eine Zusage abgelegt, die die Spitze zurücknehmen musste? | **die halbe F-2-Zusage ja, und sie ist in der Spitze explizit nachgezogen, nicht still.** `fa00e736` hatte `AdaptMK` als Antwort auf F-2 gebaut und im Sensor-Doc „Die Emission prüft die Voraussetzung der Bindung … fail-closed" geschrieben — das **emittierte** Fragment machte in diesem Commit aus einem fehlenden Rezept weiter einen stillen Erfolg. `1e6f9e4b` sagt das im Klartext („Die erste Fassung pruefte die Voraussetzung der Vorbindung nur in der Emission") und legt die zweite Schicht dazu. |

### 2. F-1 — die Anker des Go-Tests, an der Quelle gezählt und rot gesehen

```sh
grep -cF 'git rev-list --count "$range"'      internal/emit/templates/enforce/history-range-guard.sh  # 1  (Code, Zeile 89)
grep -cF '[ "$range" = "--staged" ]'          internal/emit/templates/enforce/history-range-guard.sh  # 1  (Code, Zeile 77)
grep -cF 'ist aufloesbar, aber LEER (0 Commits)' internal/emit/templates/enforce/history-range-guard.sh # 1 (Code, Zeile 45)
```

Die Prosa nennt dasselbe Kommando **ohne** Argument (`:34` · `` `git rev-list --count` ``) — der
Anker ist damit **nicht** aus dem Kopfkommentar erfüllbar, und die drei Zeilen sind die
**aufgerufenen Formen**, nicht ihre Stichworte.

Die Code-only-Mutation selbst gefahren (Operand des Falls `326`, von Hand auf den Baum gelegt und
mit `git checkout`/Kopie zurückgenommen, `git status --porcelain` danach leer):

```text
$ make test-go
#14 1.926 --- FAIL: TestEnforce_HistoryRangeGuardZaehltDieRangeMitGit (0.00s)
#14 1.926     enforce_test.go:248: der Vorlauf-Waechter traegt "git rev-list --count \"$range\"" nicht:
TESTGO_EXIT=2
```

**Der benannte Wächter fällt, und die Meldung trägt die behauptete Ursache** (der Anker, nicht
irgendein Fehlschlag). Über dem **unveränderten** Baum läuft dieselbe Stufe grün
(`TESTGO_EXIT=0`) — die zweite Richtung des Paares ist damit auch gefahren.

### 3. F-2 — das emittierte Fragment, verbatim aus der Quelle, gegen ein echtes `make`

Das Fragment wurde **verbatim** aus `docGateMk` gezogen (`awk` zwischen den Backticks), in ein
Wegwerf-Verzeichnis gelegt, daneben ein `d-check.mk`-Ersatz und ein Root-Makefile mit
`-include harness/mk/doc-gate.mk`:

| Lage | `make doc-immutable RANGE=HEAD~1..HEAD` |
|---|---|
| `d-check.mk` führt beide Ziele | EXIT 0, Kette `history-range-guard` → Modul-Rezept (`make -n` zeigt den Wächter **vor** dem Modul) |
| Ziel-Zeile **fehlt** | **EXIT 2**, Meldung `harness/mk/doc-gate.mk: d-check.mk fuehrt 'doc-immutable' nicht — die Vorbindung des Vorlauf-Waechters haette dort kein Rezept (LH-QA-01).` — kein Modul-Lauf |
| dasselbe für `doc-commits` | EXIT 2 mit derselben Meldung für sein Ziel |

**Die erste Schicht** (`requireVorbindungsTargets` in `AdaptMK`) ist im Go-Test bewacht
(`TestAdaptMK_BrichtBeiFehlendemVorbindungsTarget`; der Operand des Falls `327` trifft genau
einmal), **die zweite** ist hier und in §6 gemessen. Der Abbruch ist **laut** (Meldung + Exit 2) —
nicht nur „Exit ≠ 0".

### 4. F-2 — die Voraussetzung der neuen Bedingung: zwei `make`-Auflösungen, ein File

`include d-check.mk` (Zeile 69) und `grep … d-check.mk` (Zeilen 91/99) sind **beide CWD-relativ** —
an zwei Kandidaten gemessen (Fragment-Verzeichnis vs. Aufruf-CWD): gelesen wird die Datei der CWD,
in beiden Fällen dieselbe. Die Bedingung liest also die Datei, die das `include` einbindet, wie
der Kommentar sagt. Und `$(.PHONY)` ist wirklich leer (GNU Make 4.3: `$(info PHONY=[$(.PHONY)])`
→ `PHONY=[]`) — die Begründung des Sensor-Docs trägt.

### 5. F-3 — beide Hälften der Zusage, an **beiden** Zielen, in der emittierten Konfiguration

`make full-smoke` → **FULLSMOKE_EXIT=0**; die neue Sektion druckt:

```text
full-smoke: Waechter greift (golang): make doc-immutable RANGE=HEAD..HEAD bricht ab, ohne ein Modul zu fahren.
full-smoke: Waechter greift (golang): make doc-commits RANGE=HEAD..HEAD bricht ab, ohne ein Modul zu fahren.
full-smoke: OHNE den Waechter meldet dasselbe Modul ueber derselben leeren Range gruen (doc-immutable) …
full-smoke:   d-check: 20 Datei(en) geprüft, 0 Befund(e)
full-smoke: OHNE den Waechter meldet dasselbe Modul ueber derselben leeren Range gruen (doc-commits) …
full-smoke:   d-check: 20 Datei(en) geprüft, 0 Befund(e)
full-smoke: F-2-Fall (golang): make doc-immutable bricht ueber einem d-check.mk ohne Ziel-Definition LAUT ab …
full-smoke: F-2-Fall (golang): make doc-commits bricht ueber einem d-check.mk ohne Ziel-Definition LAUT ab …
full-smoke: F-2-Fall (golang): derselbe Aufruf ueber dem unverfaelschten d-check.mk bleibt gruen (doc-commits), der Modul-Lauf fand statt.
```

**Trifft die Messung die emittierte Konfiguration?** Ja: gefahren wird im Klon des frisch
gebootstrappten tmp-Repos (Log: `make[1]: Verzeichnis „/tmp/tmp.RVg276tqcw" wird verlassen`), und
dessen `.d-check.yml` ist die emittierte Vorlage — `grep -c 'commits' internal/emit/templates/d-check.yml`
→ **0**, während der Dogfood-Block `commits:` in `.d-check.yml` die `id-patterns`-Liste trägt. Der
Unterschied, den Runde 1 als Kern benannt hat, ist damit **gemessen und nicht mehr behauptet**; er
steht jetzt auch im Sensor-Doc (§Grenze).

### 6. Die neuen Fälle `325`–`329`: Trifft jeder seinen Wächter, und färbt er ihn?

| Fall | Operand trifft | Rot-Beleg dieses Laufs |
|---|---|---|
| `325` (`test-go`) | 1× (die Zeile `doc-immutable: history-range-guard` steht im `else`-Zweig und wird von `^…$` getroffen) | abgeleitet: derselbe String ist genau der, den `TestDocGateMk_BindetDenVorlaufWaechter` fordert |
| `326` (`test-go`) | 1× | **selbst gefahren**: `make test-go` EXIT 2, `--- FAIL: TestEnforce_HistoryRangeGuardZaehltDieRangeMitGit`, §2 |
| `327` (`test-go`) | 1× | abgeleitet: leert die Liste → `requireVorbindungsTargets` fordert nichts mehr, der benannte Test ist ihr einziger |
| `328` (`test-go`) | 1× | abgeleitet: derselbe Literal ist der `dst`-Eintrag; der benannte Test ist der neue |
| `329` (`full-smoke`) | 1× (nur die `doc-immutable`-Zeile; die `doc-commits`-Zeile trägt ein anderes Muster) | **Erwartung selbst nachgestellt**: Fragment ohne die Bedingung (Operand angewandt) über demselben verfälschten `d-check.mk` → `make doc-immutable RANGE=HEAD~1..HEAD` endet **EXIT 0** und fährt nur den Wächter — genau die Zeile, die `f2_ohne_rezept_def` als FEHLER formuliert (`full-smoke: FEHLER` + `OHNE die Ziel-Definition GRUEN`). Der Fall würde also den **benannten** Wächter rot färben und nicht irgendeinen. |

**Kein voller `make mutate` in diesem Lauf** (Weisung: Post-Integration-Stufe; der Treiber kennt
noch keine Fall-Auswahl) — die Einzel-Belege oben und §2 treten an seine Stelle, und die drei
`sed`-Operanden sind zusätzlich auf Eindeutigkeit gezählt (`grep -cF` → je 1).

### 7. F-6 — ist der neue Test regel-generisch, oder eine Momentaufnahme?

`TestEnforce_ZielpfadeImEmittiertenLayout` läuft über `emit.EnforcePaths()`, und diese Funktion ist
**abgeleitet**, nicht gepflegt: `EnforcePaths()` bildet die `dst`-Felder von `enforceFiles()` ab
(`internal/emit/enforce.go:166-173`). Jeder **künftige** Eintrag dieser Menge fällt damit unter den
Test, ohne Nachzug — die Prüfung ist strukturell generisch. **Reichweite, benannt:** sie gilt für
`enforceFiles()`/`EnforcePaths()`; `captureFiles()` (Traeger-Zweig), `blocked/<lang>` und die
Skelett-Vorlagen liegen außerhalb dieser Menge und sind von diesem Test nicht erfasst.

### 8. F-7 — der Hilfetext gegen die zwei Rezepte

`d-check.mk:98` (`doc-immutable`) führt `$(if $(STAGED),--staged,--range $(RANGE))`, `d-check.mk:102`
(`doc-commits`) führt allein `--range $(RANGE)`. Der neue Hilfetext
`(STAGED=1 prueft den Index; den STAGED-Zweig fuehrt nur doc-immutable)` nennt genau das, und das
Sensor-Doc wiederholt es (§Grenze). Der Grund ist damit nicht mehr aus dem Text, sondern aus der
Quelle lesbar — **trägt**.

### 9. `make gates` und `make full-smoke` dieses Laufs

| Lauf | Ergebnis |
|---|---|
| `make gates` | **EXIT 0**; entscheidende Zeile `d-check: 1390 Datei(en) geprüft, 0 Befund(e)` — der Lauf **dieses Reports** (der erste Lauf dieses Reviews stand bei 1389, ohne diesen Report); bats `ok`-Zeilen **280**; `golangci-lint`-Stufe und Go-Tests grün |
| `make full-smoke` | **EXIT 0** (§5) |
| `make test-go` | **EXIT 0** unverändert / **EXIT 2** über der Code-only-Mutation (§2) |
| `make mutate` | **nicht gefahren** (§6) |

*Keine Erwartungswerte* — Datei- und Testzahlen wandern mit dem Baum.

---

## Runde 1 — je Befund ein Verdikt

| Runde-1-ID | Verdikt | Kommando / Beleg |
|---|---|---|
| **F-1** (HIGH) | **behoben** | `grep -cF` auf die drei Anker → je 1, Prosa trägt sie nicht; Code-only-Mutation → `make test-go` EXIT 2 mit dem Anker in der Meldung (§2) |
| **F-2** (MEDIUM) | **behoben für den benannten Fall** — die Klasse lebt in zwei Randlagen weiter: **N-1**, **N-2** | Fragment verbatim gegen echtes `make`: Abbruch EXIT 2 + Meldung an beiden Zielen (§3); E2E in `make full-smoke` (§5) |
| **F-3** (MEDIUM) | **behoben** | `make full-smoke` druckt die blinde Grün-Hälfte für **beide** Ziele, gefahren über der emittierten Konfiguration (§5) |
| **F-4** (MEDIUM, Plan) | **nicht geprüft — nicht Gegenstand** | vom Planner gezogen (`0092870f`), Runde 1 hatte sie an den Planner übergeben |
| **F-5** (LOW, Plan) | **nicht geprüft — nicht Gegenstand** | vom Planner gezogen (`a278359d`) |
| **F-6** (INFO) | **behoben** | `TestEnforce_ZielpfadeImEmittiertenLayout` über der abgeleiteten Menge `EnforcePaths()` (§7) |
| **F-7** (INFO) | **behoben** | Hilfetext gegen `d-check.mk:98`/`:102` gelesen (§8) |

**Keine Runde-1-Befund ist durch die Behebung neu entstanden**; die zwei neuen Befunde dieses Laufs
sind Randlagen derselben Klasse (N-1, N-2), eine Form-Frage der neuen Texte (N-4) und eine offene Struktur-Frage (N-3) — siehe unten.

## Findings (neu in diesem Lauf)

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der verbindlichen Single Source of
Truth. Die Spalten sind nur **gespiegelt**, nicht neu definiert; bei Abweichung gilt der Skill bzw.
dessen Quelle `v6.8.0` · `regelwerk/modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill.

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| N-1 | MEDIUM | Die fail-closed-Bedingung des Fragments beantwortet „führt `d-check.mk` das Ziel?" mit `ifeq ($(shell grep -c … 2>/dev/null \|\| true),0)` — ein **unbekannter** Ausgang (leere Shell-Ausgabe, z. B. weil `grep` auf dem PATH fehlt; die Ausgabe verbirgt den Grund) ist **nicht** `0` und wählt darum den **permissiven** Zweig: gemessen wählt dasselbe `d-check.mk` ohne Ziel-Zeile mit `grep` den Abbruch und ohne `grep` die Bindung (`make -n` druckt die Wächter-Zeile), und der Aufruf endet dann EXIT 0 ohne Modul-Lauf — die Klasse, gegen die die Bedingung steht. | [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed) · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) | `internal/emit/emit.go:91` und `:99` | ja — `env PATH=/nonexistent make -n doc-immutable` über einem `d-check.mk` ohne Ziel-Zeile (gemessen §10) | fail-closed-bedingung-waehlt-bei-unbekanntem-ausgang-den-permissiven-zweig |
| N-2 | LOW | Die Bedingung (und `AdaptMK`s `strings.Contains(mk, "\n"+ziel+":")`) liest eine Ziel-**Zeile** als Nachweis; eine Definition **ohne Rezept** unterläuft sie: gemessen greift die Bindung über `doc-immutable: ## …` ohne Rezept, `make doc-immutable RANGE=HEAD~1..HEAD` endet EXIT 0, der Wächter läuft, das Modul nicht — derselbe stille Erfolg, nur über einen anderen Auslöser. | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) · [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed) | `internal/emit/emit.go:91` (Fragment) · `:130` (`requireVorbindungsTargets`) | ja — Ziel-Zeile ohne Rezept in ein `d-check.mk` setzen, `make doc-immutable RANGE=HEAD~1..HEAD` (gemessen §10) | ziel-definition-ohne-rezept-unterlaeuft-die-fail-closed-pruefung |
| N-4 | MEDIUM | Neue Zeilen dieses Deltas führen eine **Befund-Kennung aus einem Review-Report als Namen**: `full-smoke.sh` benennt zwei Helfer `f2_ohne_rezept_def`/`f2_mit_rezept_def`, seine Sektion `(f) DER F-2-FALL` und **seine Ausgabe** `full-smoke: F-2-Fall (…)`; `test/mutations/329` schreibt „die Klasse aus dem Review-Befund F-1". Der Grund steht jeweils im Satz daneben — die Kennung löst aber nach `docs/reviews/**` auf, einem Zeitdokument in keinem Rang, und wird als Beleg gelesen (ihre Auflösung ist ein Lauf-Beleg, der über Läufe hinweg nicht gelesen wird). | [`AGENTS.md`](../../AGENTS.md) §3.7 (Quellen-Klausel, Cutoff 2026-08-30) | `harness/tools/full-smoke.sh:362,385` (Namen, `:358`/`:383` ihre Kopfzeilen) · `:509` (die Sektion `(f) DER F-2-FALL`) · `:380,:401` (Ausgabe) · `test/mutations/329-doc-gate-fragment-ohne-fail-closed.sh:17` | nein — kein Gate liest die Herkunft eines Kommentars | befund-kennung-als-name-in-neuem-skript |
| N-3 | INFO | Dieselben zwei Ziel-Namen stehen jetzt in **drei literalen Nennungen** (Bindungs-Zeile, `ifeq`-Zeile im Fragment-Text, `vorbindungsTargets()`), dazu im `want`-Feld des Doc-Gate-Tests — ohne Ableitung zwischen ihnen. Beide Drift-Richtungen enden laut (Bootstrap-Abbruch bzw. weiterhin gedeckte Bindung), **kein stiller Pfad**; notiert als undokumentierte Annahme, nicht als Defekt. | Maintainability · [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed) | `internal/emit/emit.go:96,104` gegen `:123` · `internal/emit/emit_test.go:175` | nein | dieselbe-menge-in-drei-literalen-nennungen-ohne-ableitung |

### Messung zu N-1 und N-2 (nachgetragen, weil beide am selben Konstrukt hängen)

```text
$ env PATH=/nonexistent make -f probe.mk          # nur die Bedingung, isoliert
ZWEIG=bindet
$ make -f probe.mk
ZWEIG=fehlt

$ make -n doc-immutable RANGE=HEAD~1..HEAD        # d-check.mk OHNE die Ziel-Zeile
echo "… d-check.mk fuehrt 'doc-immutable' nicht …" >&2 ; exit 2
$ env PATH=/nonexistent make -n doc-immutable …   # derselbe Baum, ohne grep
bash tools/harness/history-range-guard.sh "HEAD~1..HEAD"

$ make doc-immutable RANGE=HEAD~1..HEAD           # Ziel-Zeile OHNE Rezept
history-range-guard: Range 'HEAD~1..HEAD' aufgeloest, 1 Commit(s) — OK.
RC=0
```

Der Auslöser von N-1 ist eine **Umgebungs-Randlage** (ein Host ohne `grep` — mit `bash` daneben
maskiert die Wächter-Zeile den Fall nicht, sie steht dann als einzige Kette da), nicht der
Normallauf; §3.9 nennt als Host-Minimum `git`, `docker`, `make`, und der Zuwachs an Host-Werkzeug
wird von diesem Fragment **nicht** gemeldet.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **Der rote Zwischenstand** (Auftrag dieses Laufs) | geprüft, ohne Befund: beide Reds nachgemessen (SC2016 am `old.sh`-Operanden, `gochecknoglobals` am Diff), beide in der Message der Spitze benannt, nichts stillschweigend gezogen (§1) |
| **F-1, zweite Richtung** | geprüft, ohne Befund: der **unveränderte** Baum läuft grün, die Code-only-Mutation rot mit dem richtigen Grund (§2); Grenze: die *Verwendung* des Zählwerts (`decide "$range" "$count"`) ist text-seitig nicht verankert — sie hängt aber an `make full-smoke` (b), dessen Abbruch über der leeren Range nur eintritt, wenn der gezählte Wert die Entscheidung erreicht (abgeleitet, nicht eigens gefahren) (§5) |
| **`include` vs. `grep` — zwei Auflösungen derselben Datei** | geprüft, ohne Befund: beide CWD-relativ, an zwei Kandidaten gemessen (§4) |
| **`$(.PHONY)` als Alternative** | geprüft, ohne Befund: GNU Make 4.3 expandiert `$(.PHONY)` leer — die im Sensor-Doc genannte Messung trägt (§4) |
| **F-6-Reichweite** | geprüft, mit benannter Grenze: der Test ist über `EnforcePaths()` generisch, nicht über den ganzen Emit (captureFiles/blocked/Skelette außerhalb) (§7) |
| **Layout der emittierten Fassung (`MR-005`)** | geprüft, ohne Befund: Zielpfad `tools/harness/history-range-guard.sh`, `shell-lint` deckt `internal/emit/templates/enforce/*.sh` mit; die emittierte Fassung trägt die zwei `--decide`-Zweige der Dogfood-Kopie bewusst nicht (im Sensor-Doc §Im gebootstrappten Ziel benannt), `decide()` ist in beiden Fassungen identisch; der kommentar-bereinigte `diff` zeigt als Unterschiede allein die zwei `--decide`-Einstiege samt Usage-Zeile und die Meldung des im Ziel unerreichbaren `--staged`-Fehlerzweigs |
| **Die emittierte Fassung im Unit-Test** | geprüft, mit benannter Grenze: die Fixture-Tests (`--decide`, `test/history-range-guard.bats`) laufen über die **Dogfood**-Kopie; für die emittierte Fassung tragen Textanker (Go) + E2E (`make full-smoke`) |
| **Die blinde Grün-Hälfte für `doc-commits`** | geprüft, mit benannter Grenze: sie ist jetzt gefahren und gelesen (§5); ob dort die **leere Range** der Anlass ist und nicht die unkonfigurierte `commits`-Sektion der emittierten `.d-check.yml` (beide Läufe melden `0 Befund(e)`), unterscheidet diese Messung nicht — dieselbe Grenze gilt für `doc-immutable` |
| **`AGENTS.md` §3.2 (Lint-Suppression)** | geprüft, ohne Befund: kein `//nolint`, kein `# shellcheck disable` im Delta — die zwei Lint-Verstöße der Erstfassung sind behoben, nicht unterdrückt |
| **`AGENTS.md` §3.9 (Docker-only)** | geprüft, ohne Befund im Delta: kein Rezept ruft ein Host-Werkzeug in der Befehlsposition; das Fragment arbeitet mit `bash` + `git` + `grep`, das Bild kommt aus `d-check.mk` |
| **`AGENTS.md` §3.7 über allen neuen Texten (außer N-4)** | geprüft, mit Befund N-4 und sonst ohne: keine Slice-Nummer als Erzählung, kein Lauf-Protokoll, kein abwesender Text, kein abgebrochener Satz; die zwei kontrafaktischen Formulierungen der Erstfassung („waere die schmalere Stufe") tragen ihre Klasse im selben Satz |
| **`MR-025` (Zahl neben Kommando)** | geprüft, ohne Befund: die neuen Texte führen keine Zahl als Erwartungswert; `"0 Befund(e)"` ist zitierte Programm-Ausgabe, `20 Datei(en)` steht als gelesene Zeile dieses Laufs |
| **Gate-Lockerung ohne ADR (§3.5)** | geprüft, ohne Befund: das Delta nimmt einen stillen Erfolgspfad weg und fügt keinen hinzu (N-1/N-2 sind Reste einer Bedingung, keine neue Senkung); keine Schwelle, kein Modul, keine Strenge gesenkt |
| **Mutations-Fälle `325`–`329`** | geprüft, mit den Belegen aus §6: alle Operanden treffen eindeutig, `326` ist selbst gefahren, die Erwartung von `329` ist nachgestellt und trägt; **kein** voller `make mutate` in diesem Lauf (offener Punkt) |
| **Der E2E-Sensor selbst (Stilles-Grün)** | geprüft, ohne Befund: `waechter_bricht_ab`, `blind_gruen_ohne_waechter`, `f2_ohne_rezept_def` und `f2_mit_rezept_def` prüfen je **beide** Richtungen (Exit **und** Meldung **und** „kein Modul-Lauf") und beenden sich im Zweifel mit `exit 1`; die Fenster-/Abdeckungs-Gleichung läuft in `make gates` grün (bats `ok 280`) |
| **`harness/sensors/full-smoke.md`** | geprüft, ohne Befund: das Dokument beschreibt die Abdeckung über ein **Kriterium** („jeder Abschnitt, der ein Bild anfordern kann"), keine Fundstellen-Liste — die neuen Abschnitte brauchen keinen Nachzug |
| **Traceability der zwei Commit-Messages** | geprüft, ohne Befund: `LH-FA-06`/`LH-QA-01` genannt, Rolle im Betreff |
| **Rollentrennung (§3.8/§3.10)** | geprüft, ohne Befund: kein Commit berührt Hard Rule, Adaptions-Eintrag, ADR oder Closure-Artefakt |
| **Fremd-Verkehr auf `main`** | zur Kenntnis, **nicht diesem Slice zugeschrieben**: `138c7a2e` (Planner) zieht den Mutations-Job aus dem Push-Pfad in den Nacht-Workflow und berührt `.github/workflows/*` + `harness/README.md`; für diesen Gegenstand ohne Wirkung (kein geprüfter Pfad), und der `mutate`-Punkt ist darum als offener Punkt geführt, nicht als Befund. **Grenze der Messung:** der abschließende `make gates`-Lauf dieses Reports hat einen Baum geprüft, der zusätzlich eine **uncommittete fremde** Änderung an `.claude/commands/implement-slice.md` trug (mtime 20:51, also **vor** dem Lauf und über ihn hinweg unverändert); sie ist nicht diesem Slice zugeschrieben und nicht von diesem Lauf angefasst |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 (N-1, N-4) |
| LOW | 1 (N-2) |
| INFO | 1 (N-3) |

**Finding-Klassen dieses Laufs:** fail-closed-bedingung-waehlt-bei-unbekanntem-ausgang-den-permissiven-zweig ·
ziel-definition-ohne-rezept-unterlaeuft-die-fail-closed-pruefung ·
befund-kennung-als-name-in-neuem-skript ·
dieselbe-menge-in-drei-literalen-nennungen-ohne-ableitung

Die Runde-1-Klasse `test-anker-aus-der-prosa-erfuellbar` ist **geschlossen**; die zwei Klassen
`abdeckungs-zusage-ohne-rot-beleg-fuer-die-zweite-haelfte` und
`vorbedingung-an-ein-fremdes-target-macht-es-still` sind in ihrer benannten Form geschlossen und
leben nur als Randlage (N-1/N-2) weiter. Ob das den Zähler bewegt, entscheidet die Slice-Closure §7
— dieser Report zählt nicht.

## Verdikt

**Merge-blockierend: ja** — zwei MEDIUM (N-1, N-4); das ist die Vorgabe der Vorlage, und die zwei
sind mechanisch klein: N-1 betrifft eine Zeile je Ziel, N-4 eine Umbenennung plus zwei
Ausgabe-Strings. **Kein HIGH:** die Klasse dieses Slice (stiller Erfolg über leerem Prüfbereich)
ist an **allen in Runde 1 benannten** Stellen geschlossen und je einzeln rot gesehen; N-1 und N-2
sind Randlagen derselben Bedingung, N-4 ist eine Form-Frage.

**Was dieser Lauf zu den zwei Auftrags-Fragen sagt.** (1) Der rote Zwischenstand `fa00e736` hat
**nichts** abgelegt, das die Spitze stillschweigend glattzieht: beide Reds sind nachgemessen, beide
sind in der Message der Spitze benannt, und die einzige inhaltliche Nacharbeit an einer Zusage
(AdaptMK allein reicht nicht) ist dort im Klartext ausgesprochen (§1). (2) Die vier
Behauptungen zu F-1, F-2, F-3, F-6 und F-7 tragen einzeln: F-1 über die selbst gefahrene
Code-only-Mutation mit gelesener Meldung, F-2 zweischichtig und an beiden Zielen, F-3 über die
**emittierte** Konfiguration (das emittierte `.d-check.yml` führt keinen `commits:`-Block), F-6
über eine abgeleitete Menge, F-7 gegen die zwei Rezepte.

**Grenze der Klassifikation, benannt statt still entschieden:** N-4 ist die Quellen-Klausel einer
Hard Rule (also formal ein §3.7-Verstoß) und trotzdem nicht HIGH — die Sätze tragen ihren Grund
selbst, die Kennung ist verzichtbare Dekoration, und die gelebte Praxis des Repos
(`2026-09-04-slice-180-mutations-sensor-verify-runde-2.md` führt „Befund-Kennung … im Kommentar"
als MEDIUM). Die Klassifikations-Grenze bleibt Architect-Sache: wer die *Kennung als Namen* schon
bei der ersten Zeile verboten sehen will, hat in §3.7 ein HIGH und braucht dort einen schärferen
Satz.

**Offen geblieben in diesem Lauf** (was dieser Report **nicht** geprüft hat): (a) ein **eigener**
voller `make mutate` — die Weisung stellt den Satz auf die Post-Integration-Stufe, und der Treiber
kennt noch keine Fall-Auswahl; an seine Stelle treten vier Einzel-Belege (§6); (b) F-4 und F-5 —
sie sind Plan-Punkte und vom Planner gezogen, nicht Gegenstand dieser Runde; (c) ob die leere
Range der Anlass der blinden Grün-Hälfte ist oder die Sektion der emittierten `.d-check.yml`
(dieselbe Grenze für beide Ziele, §5/Negativbefunde); (d) die span-/Telemetrie-Achse und die
CI-Workflow-Änderung `138c7a2e` liegen außerhalb dieses Gegenstands.

**Übergabe:** N-1, N-2, N-4 gehen an den **Implementer**. N-3 ist eine Struktur-Frage ohne
stillen Pfad und geht als offene Frage an den **Architect**. Die Finding-Klassen gehen in die
Slice-Closure §7 und von dort in das Beobachtungs-Register.

Dieser Report ist ein **Lauf-Beleg** (Audit: dieses Delta, dieser Skill, dieses Modell, dieses
Verdikt) — er wird über Läufe hinweg nicht wieder gelesen und muss es nicht. Er ersetzt keine
Verifikation: DoD-/Spec-Konformität prüft der Verifier separat (Modul 11).
