# Re-Review-Report: slice-026 (Mutations-Sensor `make mutate`) — 2026-07-20

**Review-Art:** Code — geprüft wird der Diff gegen **Plan + ADR + Hard Rules**
(Modul 10 §Drei Review-Arten). **Nicht** geprüft: die DoD-Abhakung — das ist
die Verifikation (Modul 11, getrennter Kontext, anderes Prüf-Artefakt).

**Gegenstand:** `git diff e86aa7c..HEAD` — `129ad38` (Findings F-1…F-6 aufgelöst)
+ `5d13404` (F-5 vollständig + Modul-11-Lücke). `e86aa7c` war der Stand, den
[der erste Review](2026-07-20-slice-026-review.md) sah.

**Skill:** `.harness/skills/reviewer.md` @ v1.2.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-4-8[1m] · **Datum:** 2026-07-20

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- Slice-Plan: [`docs/plan/planning/in-progress/slice-026-mutations-sensor.md`](../plan/planning/done/slice-026-mutations-sensor.md) (§2 DoD, §3 **zweimal** nachgeführt, §6 Risiken — insb. „der Reviewer sollte den Sensor gegen sich selbst wenden")
- aktive ADRs: [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) (Docker-only), [`ADR-0005`](../plan/adr/0005-ziel-repo-distribution.md) (der Kurs ist die eine Quelle)
- berührte `LH-*`-IDs: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
- [`AGENTS.md`](../../AGENTS.md) Hard Rules §3.1–§3.6 (§3.6 auch **auf diesen Diff selbst** angewandt)
- [`harness/conventions.md`](../../harness/conventions.md) (MR-Block, insb. [`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache), [`MR-008`](../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert))
- Regelwerk Modul 9 (Hard-Rule-Quadranten), Modul 10 (Review-Harness), Modul 11 (§Pre-completion, `verify:`-Sensoren)
- vorherige Findings am gleichen Modul: [`2026-07-20-slice-026-review.md`](2026-07-20-slice-026-review.md) (F-1/F-2 HIGH, F-3…F-6 MEDIUM, F-7…F-13 LOW, F-14…F-16 INFO) — der Ausgangspunkt dieses Laufs; davor [`-022a-review`](2026-07-20-slice-022a-review.md), [`-022a-re-review`](2026-07-20-slice-022a-re-review.md), [`-022b-review`](2026-07-20-slice-022b-review.md), [`-022b-re-review`](2026-07-20-slice-022b-re-review.md)

**Ausgeführte Sensors (echte Ausgabe, kein Behaupten):**

| Lauf | Ergebnis |
|---|---|
| `make gates` | **EXIT=0** |
| `make test` | **EXIT=0** |
| `make mutate` | **EXIT=0** — `8 ok, 0 Befund(e)`, 1 m 13,6 s (Grün-Vorlauf `test` + `smoke` gefahren) |
| `make smoke` | **EXIT=0** — `d-check: 10 Datei(en) geprüft, 5 Befund(e)` (erwartet, slice-005) |

**Messumgebung.** Alle Läufe in einem isolierten `git clone --no-hardlinks`
desselben Commits (`5d13404`); `make mutate` in einem **zweiten** Klon, damit
kein paralleler Lauf im selben Arbeitsbaum misst (F-12 des Vorreviews). Der
Arbeitsbaum des Nutzers wurde nicht verändert; nach jeder Sonde war
`git status --porcelain` im jeweiligen Klon leer.

**Sonden dieses Laufs** (Rezepturen, damit der Lauf nachfahrbar ist):

| Sonde | Zweck | Ergebnis |
|---|---|---|
| **P1** | F-1-Wiederholung: Go-Mutation (aus Fall 01) + bats-Testname als `# expect:` | `BEFUND … faellt nicht — falscher Grund`, `EXIT=2` |
| **P5** | `grep -E … \| grep -qF` unter `pipefail` bei 5,9 MB FAIL-Zeilen (SIGPIPE-Verdacht) | `PIPESTATUS=0 0` — **kein** Falsch-Befund |
| **P6** | Vorfahren-Wurzelung **mit** in-scope-Template an der Vorfahren-Wurzel | `err=<nil>`, emittiert `[CHANGELOG.md templates/AGENTS.md templates/spec/lastenheft.md]` |
| **P6b** | Nachfahren-Wurzelung mit Templates auf **beiden** Ebenen | `err=<nil>`, emittiert `roadmap.md` in den Ziel-**ROOT** |
| **P6c** | realer Vorfahren-Fall `<tag>/` (Kontrolle) | korrekt abgewiesen (`… eine Ebene zu hoch?`) |
| **P7** | `case atRoot == 0:` → `case false:` (die **nicht** mutierte `checkRoot`-Hälfte) | `make test` rot an `TestTemplates_FalscheWurzelung` |
| **P8** | smoke-Modus, rot am **falschen** Wächter | `BEFUND … falscher Grund`, `EXIT=2` |
| **P9a/b** | Grün-Vorlauf auf rotem `make test` / rotem `make smoke` | beide `ABBRUCH`, `EXIT=2` |
| **P12** | `failure_form`-Arm `smoke)` entfernt, Modus weiter erlaubt | **`ok`, `EXIT=0`** (Kontrolle mit Arm: `BEFUND`) |
| **P-08** | Fall 08 direkt gefahren + `make smoke` | `smoke: FEHLER — out-of-scope-Artefakt emittiert: README.md.md` |

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der
verbindlichen Single Source of Truth. Die Felder unten sind nur
**gespiegelt** (Bequemlichkeit beim Ausfüllen), nicht neu definiert; bei
Abweichung gilt der Skill bzw. dessen Quelle
[Kurs Modul 10 §Output-Schema](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/04-qualitaet/modul-10-review-harness.md#worked-example-eine-reviewer-skill-datei-schreiben).

### A — Status der Findings des Vorreviews

Zusammenfassung vorab; die **nicht** geschlossenen sind unten als N-* neu
ausgeschrieben, soweit sich ihr Befund gegenüber dem Vorreview verändert hat.

| Vorreview | Kategorie | Urteil | Beleg |
|---|---|---|---|
| **F-1** (Bedingung 4 für bats-Fälle inert) | HIGH | **geschlossen** | Sonde P1 meldet jetzt `falscher Grund`, `EXIT=2` (vorher `ok`, `EXIT=0`) |
| **F-2** (smoke-Gegenprobe prüft Quell-Namen) | HIGH | **geschlossen** | Sonde P-08: `smoke: FEHLER — out-of-scope-Artefakt emittiert: README.md.md`; Fall 08 fährt sie im Set |
| **F-3** (`checkRoot` lässt Falsch-Wurzelung durch) | MEDIUM | **teilweise offen** → **N-1** | Sonden P6/P6b: beide Richtungen weiter offen |
| **F-4** (`perl`-Zusage vs. Abdeckung) | MEDIUM | **geschlossen**, Restklasse → **N-3** | kein `perl`-Aufruf mehr im Repo; alle acht Fälle auf `sed` |
| **F-5** (kein Fall für die neu gebauten Wächter; `smoke` bauartbedingt aus) | MEDIUM | **geschlossen** | `# verify:`-Modus + Fälle 07/08; Grün-Vorlauf fährt `make smoke` |
| **F-6** (kein Grün-Vorlauf) | MEDIUM | **geschlossen** | Sonden P9a/P9b: Abbruch bei rotem `test` **und** rotem `smoke` |
| **F-7** (mehrere `# files:`-Pfade / zweiter `# files:`-Kopf) | LOW | **offen, unverändert** | `harness/tools/mutate.sh:104` unverändert `read -r -a file_list <<<"$files"` |
| **F-8** (BEFUND zeigt auf gelöschtes Log) | LOW | **halb geschlossen** → **N-5** | Mutations-Ausgabe inline; `$BACKUP/verify.log` weiter ungezeigt gelöscht |
| **F-9** (Verweis auf „Schritt-18-Haken") | LOW | **geschlossen** | `mutate.sh:17` nennt jetzt Schritt 19, was dem gelieferten Schritt 19 entspricht |
| **F-10** (Closure-Trigger in zwei Fassungen) | LOW | **offen, unverändert** | `roadmap.md:25-28` zählt weiter nur `gates` + `smoke` + Carveout-Audit + Closure-Notiz |
| **F-11** (slice-027 beruft sich auf Roadmap-Sequenzierung) | LOW | **offen, unverändert** | Diff berührt weder `roadmap.md` noch `slice-027-ci.md` |
| **F-12** (kein Lock / geteilter Arbeitsbaum) | LOW | **offen, unverändert** | `run_case` mutiert weiter direkt in `$REPO`, keine Lock-Datei, kein Sauberkeits-Check |
| **F-13** (Anker am Hash-Präfix) | LOW | **geschlossen** | Fall 01 matcht jetzt `[0-9a-f]\{64\}` statt `123e` |
| **F-14** (Grund für „nicht in gates") | INFO | **offen, unverändert** | `mutate.sh:39-41` nennt weiter nur die Laufzeit, nicht das Mutieren des Arbeitsbaums |
| **F-15** („jeden Wächter") | INFO | **teilweise** | die zweite, bauartbedingte Grenze ist mit F-5 real entfallen; `AGENTS.md:100-104` unverändert |
| **F-16** (Plan sagt Schritt 18, geliefert Schritt 19) | INFO | **offen** → **N-6** | DoD-Zeile 41 unverändert; §3 nachgeführt, aber für eine **andere** Änderung an Schritt 18 |

### N-1 — `checkRoot` lässt nach dem F-3-Fix **beide** Falsch-Wurzelungs-Richtungen weiter durch; die im Vorreview namentlich vorgelegte Sonde ist unverändert grün

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (Zusage weiter als Abdeckung) · [`ADR-0005`](../plan/adr/0005-ziel-repo-distribution.md) · Reviewer-Skill §MEDIUM (Spec-Treue-Lücke einer Messmethode) · Vorreview F-3, 022b N-4
- `pfad`: `internal/emit/templates.go:56-82` (`checkRoot`) · `internal/emit/templates_test.go:249-268` (Teilfall (b))
- `befund`: Die neue Regel „in-scope-Templates auf **beiden** Ebenen" ist eine Verteilungs-, keine Wurzel-Aussage; sie unterscheidet nicht Wurzelung, sondern Baumform. **(a) Vorfahren-Wurzelung** — die Sonde F-3 (b) des Vorreviews, `{CHANGELOG.template.md, SHA256SUMS, regelwerk/README.md, templates/AGENTS.template.md, templates/spec/lastenheft.template.md}`: `err=<nil>`, emittiert `[CHANGELOG.md templates/AGENTS.md templates/spec/lastenheft.md]` (Sonde P6) — unverändert gegenüber dem Stand vor dem Fix. **(b) Nachfahren-Wurzelung** — `{roadmap.template.md, plan/adr/NNNN-titel.template.md, plan/planning/slice.template.md}`, die Form von `templates/docs/`: `err=<nil>`, emittiert `roadmap.md` in den Ziel-**ROOT** statt nach `docs/plan/planning/in-progress/` (Sonde P6b). Gefangen ist nur die **flache** Nachfahren-Form (F-3 (a), etwa `templates/spec/`); der Teilfall (b) des neuen Tests besteht aus demselben Grund wie der alte Test: seine Fixture ist zufällig flach. Der Doc-Kommentar `templates.go:42-43` behauptet zudem weiterhin, eine Ebene über `templates/` stünden „nur die Verzeichnisse regelwerk/ und templates/" — dort liegt auch die Datei `SHA256SUMS`; die Begründung des Guards trägt also nicht, obwohl sein Ergebnis für den realen Baum stimmt (Sonde P6c).
- `verifizierbar`: **ja** — die drei Sonden P6/P6b/P6c als temporäre `_test.go` in `internal/emit/` + `make test`.

### N-2 — Die Zulassungs-Liste der `# verify:`-Modi und `failure_form` sind zwei unabhängige Literal-Listen; fehlt einem zugelassenen Modus sein Arm, liefert `failure_form` einen **leeren** Regex und Bedingung 4 ist wieder vollständig inert

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 · Reviewer-Skill §LOW (latente Wartungsfalle) **+ §Kontext-Eskalation** (Sensorpfad ⇒ eine Stufe höher) · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- `pfad`: `harness/tools/mutate.sh:72-77` (`failure_form`, `case` ohne `*)`-Zweig) · `:97-100` (Zulassungs-`case`) · `:149`
- `befund`: `failure_form` hat keinen Default-Zweig; für ein Argument ohne `case`-Arm gibt sie nichts aus. `grep -E -- '' "$out"` matcht dann **jede** Zeile (gemessen: Exit 0), womit Bedingung 4 auf den Zustand zurückfällt, den F-1 als HIGH beschrieb — der Vergleich sieht wieder die gesamte Ausgabe statt nur die Fehlschlag-Zeilen. Real gemessen (Sonde P12): mit entferntem `smoke)`-Arm, aber unverändert erlaubtem Modus, meldet ein Fall, dessen `# expect:` nur in einer **Fortschritts**-Zeile von `smoke` steht (`Skelett gestaged`), `mutate: ok … -> Skelett gestaged rot`, `EXIT=0`; mit Arm meldet derselbe Fall `BEFUND … falscher Grund`, `EXIT=2`. Die beiden Listen stehen rund 70 Zeilen auseinander, kein Test und kein Fall koppelt sie, und `harness/tools/mutate.sh` steht in keinem `# files:`-Kopf des Sets — der Treiber ist der einzige Wächter im Repo, den `make mutate` nicht bewacht (Slice-Plan §6 verlangt genau diese Selbstanwendung).
- `verifizierbar`: **ja** — `failure_form`s `smoke)`-Zeile entfernen, einen Fall mit `# verify: smoke` und `# expect: Skelett gestaged` fahren: `make mutate` bleibt grün.

### N-3 — Der neue Abhängigkeits-Satz im Skript-Kopf sagt „POSIX garantiert es" zu, während die acht Fälle GNU-/BSD-abhängige Erweiterungen benutzen

- `kategorie`: **LOW**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (Zusage weiter als Abdeckung) · [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) · Vorreview F-4 (dieselbe Klasse, in deren Korrektur)
- `pfad`: `harness/tools/mutate.sh:23-26` · `test/mutations/01…08-*.sh` (je `sed -i`) · `test/mutations/05-fixture-drift.sh:8` (`\t` in einer BRE)
- `befund`: Der Kopf begründet den Wechsel von `perl` auf `sed` damit, dass „POSIX es garantiert". POSIX garantiert `sed`, aber weder die Option `-i` (in POSIX.1 nicht vorhanden) noch `\t` als Escape in einer Basic Regular Expression — Fall 05 nutzt beides (`sed -i '/^\t\t"Makefile":/d'`). Auf einer BSD-/macOS-`sed` verlangt `-i` ein Suffix-Argument und schluckt das folgende Skript; alle acht Fälle scheitern dann über Bedingung 1 — fail-closed, aber die Aussage des Sensors ist dann null, und die Ursache steht nicht in der Doku. Gegenprobe auf dieser Maschine: GNU-`sed` und BusyBox-`sed` führen Fall 05 identisch korrekt aus; die Divergenz liegt allein bei BSD.
- `verifizierbar`: **nein** auf diesem Host (Linux/GNU) — **ja** auf einem BSD-/macOS-Host: `make mutate` meldet 8× „Mutations-Skript scheiterte".

### N-4 — Der Grün-Vorlauf fährt `make <modus>` für jeden Kopf-String, ohne ihn gegen die Zulassungs-Liste zu prüfen; ein fehlerhafter Kopf wird als „Baum ist rot" gemeldet

- `kategorie`: **LOW**
- `quelle`: Reviewer-Skill §LOW (latente Wartungsfalle) · [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- `pfad`: `harness/tools/mutate.sh:178-188` (`modes=…`; `for m in test $modes`) gegen `:97-100` (Zulassungs-`case` in `run_case`)
- `befund`: Der Vorlauf sammelt die Modi roh (`sed -n 's/^# verify: //p'`) und ruft `make "$m"` ungeprüft auf; die Zulassungs-Prüfung sitzt erst in `run_case`, also **nach** dem Vorlauf. Gemessen an Fixtures: `# verify: smoke extra` zerfällt beim Word-Splitting in `smoke` und `extra`, der Vorlauf fährt `make extra` und bricht mit „ABBRUCH — make extra ist schon ohne Mutation rot" ab — die Meldung beschuldigt den Arbeitsbaum, nicht den fehlerhaften Kopf. Ein Kopf `# verify:` ohne Wert wird still zu `test` (die leere Zeile fällt beim Word-Splitting weg); `# verify: smoke ` (mit Leerzeichen), ein zweiter `# verify:`-Kopf und ein zweiwortiger Wert werden von `run_case` korrekt abgewiesen. Fail-closed in allen Fällen, aber mit falscher Diagnose.
- `verifizierbar`: **ja** — einen Fall mit `# verify: smoke extra` anlegen, `make mutate` fahren.

### N-5 — Die Sensor-Ausgabe, die einen Befund nach Bedingung 3 oder 4 belegt, wird weiterhin ungesehen gelöscht

- `kategorie`: **LOW**
- `quelle`: [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) · Reviewer-Skill §LOW · Vorreview F-8 (zweite Hälfte)
- `pfad`: `harness/tools/mutate.sh:136` (`out="$BACKUP/verify.log"`) · `:139-153` (beide `report_fail`) · `:55` (`rm -rf "$BACKUP"`)
- `befund`: Der dangling Pfad-Zeiger aus F-8 ist weg — die Mutations-Ausgabe steht jetzt inline in der Meldung. Für Bedingung 3 und 4 gilt die Beobachtung unverändert: `$BACKUP/verify.log` trägt den vollen `make test`- bzw. `make smoke`-Lauf, wird an keiner Stelle ausgegeben und von `restore` gelöscht. Gemessen an Sonde P12: die Meldung „rot, aber 'Skelett gestaged' faellt nicht — falscher Grund" nennt den Schluss, nicht die Zeilen, aus denen er folgt; wer den Befund nachvollziehen will, muss den Fall von Hand nachfahren.
- `verifizierbar`: **ja** — einen Fall mit falschem `# expect:` fahren und versuchen, die Sensor-Ausgabe aus dem Lauf zu lesen.

### N-6 — Schritt 18 verlangt die Nicht-Gate-Sensoren, „die den Slice **betreffen**", ohne Fehl-Semantik und ohne durchsetzenden Sensor; die Nachbarschritte sind an dieser Stelle präziser

- `kategorie`: **LOW**
- `quelle`: Regelwerk Modul 11 §Pre-completion (`verify:`-Sensoren) · Slice-Plan §2 (Feedforward-Hälfte) · Reviewer-Skill §LOW · [`AGENTS.md`](../../AGENTS.md) §3.6
- `pfad`: `.claude/commands/implement-slice.md:85-89` (Schritt 18) gegen `:91-99` (Schritt 19) · `.claude/hooks/stop-require-gates.sh:2-4,15`
- `befund`: Die Ermessensformel ist durch die Klammer („`make mutate` immer, wenn Wächter neu/geändert sind; `make smoke`, wenn der Emit-Pfad berührt ist") auf zwei benannte Auslöser verengt und trägt insofern. Was fehlt, ist die Fehl-Seite: Schritt 19 schließt mit „**Keine Antwort ist ein Befund**, kein Formfehler", Schritt 18 sagt nicht, was gilt, wenn der Agent „betrifft nicht" urteilt. Und die Durchsetzung ist asymmetrisch: `stop-require-gates.sh` gibt den Stop nur mit abgedecktem `make gates`-Lauf frei, für `mutate`/`smoke` existiert kein Äquivalent — die Zusage in Schritt 18 hängt allein am Selbsturteil derselben Rolle, deren Selbsturteil §3.6 als unzuverlässig ausweist. Der Slice verschiebt die Lücke aus F-5 damit von „bauartbedingt" nach „ermessensabhängig", schließt sie aber nicht. Zusätzlich unverändert: der Plan-DoD (Zeile 41) verlangt weiterhin den Mutations-Haken **in** Schritt 18, geliefert ist er als Schritt 19 — die §3-Nachführung dokumentiert eine **andere** Änderung an Schritt 18 (Vorreview F-16).
- `verifizierbar`: **nein** — Prozess-/Prosa-Grenze; kein Gate misst sie.

### N-7 — Der Skript-Kopf beschreibt die Bedingungen 3 und 4 weiterhin auf `make test`, obwohl der Rumpf seit dem F-5-Fix `make "$verify"` fährt

- `kategorie`: **LOW**
- `quelle`: Reviewer-Skill §LOW (Doku-Drift) · [`AGENTS.md`](../../AGENTS.md) §3.6 (der Kopf ist die Zusage)
- `pfad`: `harness/tools/mutate.sh:35-37` gegen `:134-153`
- `befund`: Der Kopf wurde in diesem Diff zweimal umgeschrieben; die Falsch-Aussage „bauartbedingt nicht abdeckbar" ist raus. Der Vier-Bedingungen-Block darunter blieb stehen: „3. `make test` bleibt GRUEN" / „4. `make test` wird rot, aber der ERWARTETE Test steht nicht in der Ausgabe". Beides ist seit `# verify:` nicht mehr der Wortlaut des Codes — der Rumpf meldet „make $verify blieb GRUEN" und prüft nicht mehr „steht in der Ausgabe", sondern „fällt" (die Fehlschlag-Form). Für den einzigen smoke-Fall (08) beschreibt der Kopf damit weder den gefahrenen Sensor noch die tatsächliche Prüfform.
- `verifizierbar`: **nein** — Kopf-vs-Rumpf-Vergleich; kein Gate misst ihn.

### N-8 — Fall 07 bewacht nur die in diesem Slice **hinzugekommene** `checkRoot`-Hälfte; für die zweite gibt es keinen Fall

- `kategorie`: **INFO**
- `quelle`: Slice-Plan §3 (Nachführung: „der in diesem Slice geänderte Wächter `checkRoot` … bekommt seine Mutation") · [`AGENTS.md`](../../AGENTS.md) §3.6
- `pfad`: `test/mutations/07-checkroot-wurzelung.sh:10` (`s/case deeper == 0:/case false:/`) · `internal/emit/templates.go:76` (`case atRoot == 0:`)
- `befund`: `checkRoot` wurde in diesem Diff vollständig neu geschrieben; beide `switch`-Zweige sind neuer Code. Fall 07 mutiert nur `deeper == 0`. Sonde P7 zeigt, dass der andere Zweig nicht unbewacht ist — `case atRoot == 0:` → `case false:` färbt `TestTemplates_FalscheWurzelung` (a) rot —, er steht aber nicht im kuratierten Set und ist damit nicht gegen künftigen Zahnverlust gesichert. Die Fälle 07 und 08 sind im Übrigen **keine** Selbstbestätigung: 07 belegt, dass der in diesem Slice geschriebene Teilfall (b) greift (ohne ihn bliebe die Zusage unbelegt), und 08 fährt dieselbe Mutation wie 04 gegen einen **anderen** Sensor — das ist eine neue Achse, keine Wiederholung.
- `verifizierbar`: **ja** — `sed -i 's/case atRoot == 0:/case false:/' internal/emit/templates.go`, dann `make mutate`: bleibt grün.

## Negativbefunde

- geprüft, ohne Befund: **F-1-Fix (Bedingung 4)** — Sonde P1 mit unverändertem Treiber, Go-Mutation aus Fall 01 und bats-Testname als `# expect:`: `mutate: BEFUND  p1-falscher-grund  rot, aber 'emittiert: eingelegter SYMLINK' faellt nicht — falscher Grund`, `EXIT=2`. Derselbe Fall meldete vor dem Fix `ok`, `EXIT=0`. Die Fehlschlag-Formen sind korrekt gewählt: `--- FAIL:` und `not ok [0-9]+` treten in `go test`- bzw. `bats`-Ausgabe ausschließlich bei Fehlschlag auf; die grüne bats-Zeile `ok 21 …` matcht `not ok [0-9]+` nicht.
- geprüft, ohne Befund: **F-2-Fix (smoke-Gegenprobe)** — die fünf Namen sind die vom Emitter **wirklich** geschriebenen: `singletonTarget` liefert `README.md`→`README.md.md`, `Makefile`→`Makefile.md`, `.d-check.yml`→`.d-check.yml.md`, `project-readme.template.md`→`project-readme.md`, `.harness/skills/reviewer.template.md`→`.harness/skills/reviewer.md`. Unter der Mutation aus Fall 04/08 sind die ersten drei erreichbar (die beiden anderen hängen an zwei weiteren `inScope`-Zweigen, die diese Mutation nicht anfasst — als Vorrat legitim); gemessen feuert `README.md.md`: `smoke: FEHLER — out-of-scope-Artefakt emittiert: README.md.md`, `SMOKE_EXIT=2`. `-e` statt `-f` deckt auch versehentlich emittierte Verzeichnisse.
- geprüft, ohne Befund: **F-5-Fix (`# verify:`-Erweiterung, Modus-Abdeckung)** — der Grün-Vorlauf sammelt die Modi aus **derselben** Glob-Menge, die `run_case` fährt; ein deklarierter Modus ohne Vorlauf ist damit strukturell ausgeschlossen. Beide heute erlaubten Modi (`test`, `smoke`) haben einen `failure_form`-Arm. Mehrfache, leerzeichenbehaftete und zweiwortige `# verify:`-Köpfe werden von `run_case` abgewiesen (gemessen an fünf Fixtures); die Restrisiken sind N-2 und N-4.
- geprüft, ohne Befund: **F-6-Fix (Grün-Vorlauf), beide Modi** — Sonde P9a (absichtlich roter Go-Test): `ABBRUCH — make test ist schon ohne Mutation rot`, `EXIT=2`, **vor** dem ersten Fall. Sonde P9b (`make test` grün, `make smoke` rot): `ABBRUCH — make smoke …`, `EXIT=2`. Der Vorlauf ist damit nicht auf den Default-Modus verengt.
- geprüft, ohne Befund: **Bedingung 4 im smoke-Modus** — Sonde P8: `make smoke` rot am **falschen** Wächter (Template-Schicht statt out-of-scope) ⇒ `BEFUND … falscher Grund`, `EXIT=2`. `smoke: FEHLER` steht in `harness/tools/smoke.sh` ausschließlich in Fehler-Zweigen (Zeilen 39, 51, 63, 71); scheitert `smoke` vor jeder eigenen Prüfung (Build/Fetch), fehlt die Form ganz und der Fall wird ebenfalls Befund — fail-closed.
- geprüft, ohne Befund: **`pipefail` + SIGPIPE in Bedingung 4** — Verdacht, dass `grep -qF` beim frühen Treffer das vorgelagerte `grep -E` per SIGPIPE beendet und `pipefail` daraus einen Falsch-Befund macht. Gegenprobe mit 5,9 MB FAIL-Zeilen und einem Treffer in der **ersten** Zeile: `PIPESTATUS=0 0`, Pipeline-Exit 0. **REFUTED.**
- geprüft, ohne Befund: **`restore`-/Sauberkeits-Pfad über alle Sonden** — nach jedem der Sonden-Läufe (darunter zwei mit Abbruch am Vorlauf und vier mit BEFUND) war `git status --porcelain` im Klon leer. Der `trap 'restore' EXIT INT TERM` trägt auch, wenn der Lauf vor dem ersten `run_case` abbricht.
- geprüft, ohne Befund: **F-4-Fix (Abhängigkeiten)** — kein `perl`-Aufruf mehr im Repo (die verbliebenen Treffer sind erklärender Prosa-Text in `mutate.sh:110` und die Review-Reports); `git` steht nicht mehr in der Zusage und wird weiterhin nicht aufgerufen — die Zeile ist damit konsistent. Restklasse s. N-3.
- geprüft, ohne Befund: **F-13-Fix (Fall 01) und Patch-Robustheit** — der Patch matcht jetzt `^\(const DefaultBaselineSHA256 = "\)[0-9a-f]\{64\}"`; ein Re-Pin nach [`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) lässt ihn greifen. Fall 04 hängt nach dem Umbau an einem benannten `case`-Ausdruck statt an einem mehrzeiligen Kontext-Patch (robuster als zuvor); die übrigen Fälle behalten ihre Symbol-Anker.
- geprüft, ohne Befund: **Zitat-Treue der Modul-11-Belege** — die beiden Zitate in Schritt 18 („der Implementation-Agent läuft `make verify-*` **selbst** vor der ‚fertig'-Meldung", „Behauptung ohne Bestätigung ist die häufigste Verifier-Lücke") stehen wörtlich in `.harness/baseline/v3.5.0/regelwerk/modul-11-verification.md:70` bzw. `:13`. Kein kondensiertes oder fabriziertes Zitat.
- geprüft, ohne Befund: **`make mutate` Grundlauf** — im isolierten Klon `8 ok, 0 Befund(e)`, `EXIT=0`, 1 m 13,6 s; alle acht Fälle färben ihren benannten Wächter tatsächlich rot, der Grün-Vorlauf für `test` **und** `smoke` lief. Die Laufzeit hat sich gegenüber dem Vorreview (41,7 s / 6 Fälle) rund verdoppelt — zwei Fälle mehr plus zwei Vorläufe, davon einer mit Netz-Fetch. Die Tier-Frage aus Slice-§6 bleibt damit richtig beantwortet (Nicht-Gate).
- geprüft, ohne Befund: **`TestTemplates_MinimalQuelle`** — die Verschärfung ist konsistent nachgezogen: „minimal gültig" heißt jetzt Templates auf beiden Ebenen, Name, Kommentar und Rumpf sagen dasselbe. Der reale Baum (`templates/`) erfüllt die Bedingung; `make smoke` belegt end-to-end, dass der Bootstrap dadurch nicht bricht.
- geprüft, ohne Befund: **Hard Rule 3.1 / [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)** — `mutate` steht weiterhin **nicht** in `gates:` (`baseline-verify docs-check lint build test shell-lint record-gates`), ist in `.PHONY` geführt und läuft real. Kein behaupteter Gate; `make gates` **EXIT=0**.
- geprüft, ohne Befund: **Hard Rule 3.2** — kein `//nolint` und kein `# shellcheck disable` im Diff; die beiden neuen `test/mutations/07`, `08` fallen unter das bestehende `test/mutations/*.sh`-Glob in `shell-lint`, der Gate ist grün.
- geprüft, ohne Befund: **Hard Rules 3.3 / 3.4 / 3.5** — kein `git mv` im Diff, keine ADR berührt, keine Schwelle gesenkt. Die `checkRoot`-Verschärfung und der zusätzliche `# verify:`-Modus sind Anhebungen und brauchen nach §3.5 kein ADR.
- geprüft, ohne Befund: **Ablage dieses Reports** — per `cp` aus `.harness/baseline/v3.5.0/templates/docs/reviews/review-report.template.md`, nicht modelliert; neue Datei, der Vorreview bleibt unangetastet.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 5 |
| INFO | 1 |

*(Zusätzlich weiterhin offen aus dem Vorreview, im Befund unverändert und
darum oben nur in der A-Tabelle geführt: F-7, F-10, F-11, F-12 (LOW), F-14,
F-15 (INFO).)*

## Verdikt

**Merge-blockierend:** **ja** — N-1 und N-2 (MEDIUM) blockieren nach
Reviewer-Skill §Ablage. Beide HIGH-Findings des Vorreviews sind **belegbar
geschlossen**; der Stand ist deutlich besser, aber nicht fertig.

**(A) Die Auflösung ist überwiegend echt.** F-1, F-2, F-4, F-5, F-6, F-9 und
F-13 sind mit rot gesehenen Gegenbeweisen zu — F-1 und F-2 sogar mit exakt den
Sonden, die sie aufgedeckt haben (P1 kippt von `ok`/`EXIT=0` auf
`BEFUND`/`EXIT=2`; die smoke-Gegenprobe feuert real auf `README.md.md`). Das
ist die Sorte Nachweis, die §3.6 verlangt. **F-3 ist die Ausnahme:** die im
Vorreview namentlich vorgelegte Sonde (b) läuft unverändert grün durch (N-1) —
adressiert wurde nur Sonde (a).

**(B) Die Fixes haben eine neue Instanz derselben Klasse eingeführt.** N-2 ist
der schwerwiegendere der beiden neuen Befunde, und zwar wegen seiner Herkunft:
der F-1-Fix führt zwei nicht gekoppelte Literal-Listen ein, und fehlt einer
zugelassenen Modus-Angabe ihr `failure_form`-Arm, fällt Bedingung 4 **exakt in
den F-1-Zustand zurück** — gemessen, nicht hergeleitet (Sonde P12: `ok`,
`EXIT=0`). Dass ausgerechnet `harness/tools/mutate.sh` in keinem `# files:`-Kopf
steht, macht diese Regression unbemerkbar: der Sensor bewacht jeden Wächter im
Set außer sich selbst. Slice-Plan §6 verlangt genau diese Selbstanwendung
(„eine Mutation am Treiber, die unbemerkt bliebe, wäre der aussagekräftigste
Befund") — sie ist der einzige §6-Punkt ohne Umsetzung. Die drei Fragen, die
der Implementer selbst offen nannte, sind damit beantwortet: die
Modus-Abdeckung des Vorlaufs ist **dicht** (gleiche Glob-Menge; Restrisiken
N-2/N-4), die Fälle 07/08 sind **keine** Selbstbestätigung (07 belegt einen neu
geschriebenen Teilfall, 08 öffnet eine neue Sensor-Achse — s. N-8), und
Schritt 18 **trägt teilweise**: die Klammer verengt das Ermessen, aber die
Fehl-Semantik und der durchsetzende Sensor fehlen (N-6).

**(C) §3.6 auf diesen Diff selbst.** Gemischt. Positiv und ausdrücklich
festzuhalten: die Falsch-Aussage „bauartbedingt nicht abdeckbar" ist nicht
wegdefiniert, sondern durch echte Abdeckung ersetzt worden, und der Kopf sagt
das offen — genau die von §3.6 verlangte Form. Vier der neuen Zusagen tragen
einen rot gesehenen Gegenbeweis (F-1→Fall-Umbau, F-2→Fall 08, F-5→`# verify:`,
F-6→Vorlauf; die beiden nachgeholten smoke-Sonden decken, was sie decken
sollen). Drei tun es nicht: der `checkRoot`-Kommentar behauptet eine
Erkennungsleistung, die zwei Sonden widerlegen (N-1); der neue
Abhängigkeits-Satz sagt POSIX zu und benutzt GNU (N-3); und der
Vier-Bedingungen-Block spricht weiter von `make test`, wo der Rumpf
`make "$verify"` fährt (N-7). Der Kopf wurde zweimal umgeschrieben und ist
beim zweiten Mal an seiner ältesten Stelle stehen geblieben.

**Steering-Loop-Signal (Reviewer-Skill §Kontext-Eskalation).** Die Klasse
„ein Wächter besteht nur, weil seine Fixture zufällig die passende Form hat"
tritt mit N-1 zum **vierten** Mal in Folge auf (022a N2 → 022b F-1 →
slice-026 F-2 → hier N-1) — diesmal im Test, der die Korrektur der dritten
Instanz belegen soll. Nach der Skill-Regel ist das kein Melde-, sondern ein
Nachzieh-Fall. Die naheliegende Nachzieh-Kante ist die aus N-2: solange
`harness/tools/mutate.sh` selbst nicht im Set steht, kann der zweite Quadrant
zu §3.6 still seine Zähne verlieren, und die Klasse fällt weiter dem Review
statt dem Sensor zu. Das gehört in den Steering-Loop-Lerneintrag der
Closure-Notiz.

**Übergabe:** Findings gehen an die Implementation (Rückkante
Review → Plan bei Plan-Defekt — hier N-6 und, unverändert aus dem Vorreview,
F-10/F-11). Der Report ersetzt keine Verifikation — DoD-/Spec-Konformität
prüft der Verifier separat (Modul 11; anderes Prüf-Artefakt, anderer
Eingabe-Kontext).
