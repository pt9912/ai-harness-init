# Review-Report: slice-046 Runde 2 (Fix-Diff) — 2026-07-25

**Review-Art:** Code — geprüft wird **ausschließlich der Fix-Diff** der
ersten Runde: (a) ist jedes Finding F-1…F-10 aufgelöst, (b) hat der Fix
**neue** Probleme eingeführt (fix-induzierte Regressionen). Keine
Wiederholung der ersten Runde.

**Gegenstand:** slice-046, Fix-Commit `c868f08` gegen den von Runde 1
bewerteten Stand `b853f73`

**Skill:** `.harness/skills/reviewer.md` @ 1.3.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-25

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- Runde-1-Report [`2026-07-25-slice-046-impl-review.md`](2026-07-25-slice-046-impl-review.md) (F-1…F-10)
- Verifikations-Report [`2026-07-25-slice-046-verification.md`](2026-07-25-slice-046-verification.md) (DoD BESTÄTIGT, R-1 == F-1, R-2/R-3 offen)
- Slice-Plan [`slice-046-arch-gate-emitter.md`](../plan/planning/done/slice-046-arch-gate-emitter.md)
- aktive ADRs: [ADR-0009](../plan/adr/0009-hexslice-arch-realisierung.md), [ADR-0008](../plan/adr/0008-arch-achse-emittiertes-skelett.md), [ADR-0007](../plan/adr/0007-bootstrap-phasen.md), [ADR-0003](../plan/adr/0003-go-native-binaries.md)
- berührte IDs: [`LH-FA-07`](../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
- [`AGENTS.md`](../../AGENTS.md) (Hard Rules §3.1–§3.6), [`harness/conventions.md`](../../harness/conventions.md)

**Betriebsmodus:** read-only. **Keine `make`-Läufe** (Gate-Stempel),
keine Host-Toolchain. Sensor-Ausgaben aus dem Implementer-Lauf
übernommen, nicht nachgefahren: `make gates` grün (169 Dateien, 0
Befunde) · `make mutate` 67 ok/0 (70/71 rot gesehen) · `make full-smoke`
Exit 0, Log gelesen (Zeilen 1834–1838 tragen den Zwei-Modul-Beleg,
1825–1827 den Zähne-Beleg).

---

## Status der Findings aus Runde 1

| Finding | Kategorie R1 | Status | Beleg |
|---|---|---|---|
| F-1 include-once keyt auf `A_CHECK_IMAGE` | MEDIUM | **aufgelöst** | `internal/emit/archgate.go:50,71-72` — tool-eigener Sentinel `ARCH_GATE_MK_INCLUDED`; `A_CHECK_IMAGE` kommt im Wächter nicht mehr vor. Beide Zweige tragen jetzt denselben Kopf **und** dieselbe Konsequenz unter dem Override. Verhaltens-Beleg `harness/tools/full-smoke.sh:428-444` (`A_CHECK_IMAGE=<pin> make a-check` am Root-Modul, rc==0 erzwungen), Rot-Gegenbeispiel `test/mutations/70-archgate-waechter-nutzervariable.sh` (rot gesehen). |
| F-2 include-once ohne rot gesehenes Gegenbeispiel | MEDIUM | **aufgelöst** | Genau die in F-1/F-2 `verifizierbar` benannte Messung ist gebaut: `harness/tools/full-smoke.sh:446-483` bootstrappt `apps/hex2` als zweites hexSlice-Modul, erzwingt `make -j -Otarget gates` Exit 0, die Abwesenheit von `overriding recipe` und **beide** Mount-Zeilen; Log 1836-1838 zeigt `apps/hex2":/src:ro` und `apps/hex":/src:ro`. Dazu Unit-Test `internal/emit/archgate_test.go:105-118` + Mutation 70. Restpunkt zum Rot-Pfad s. N-5 (INFO). |
| F-3 Kommentar-Zusage übersteigt den Code | MEDIUM | **aufgelöst** | `internal/gen/golang.go:456-468` ersetzt die Selbst-Schärfungs-Zusage durch die gegenteilige, gemessene Aussage (skip-if-present, das Tool zieht nie nach; nicht eingetragene zweite Slice → Exit 1); die emittierte Anleitung `internal/gen/golang.go:482-489` nennt jetzt **beide** Fälle (UMBENANNT und HINZUGEFÜGT). Die Messung ist außerhalb des Repos reproduziert (Experiment-Baum mit `application/example/farewell` ohne Glob-Eintrag). Über die Formulierung s. N-2 (LOW). |
| F-4 Fitness-Function nur zur Hälfte (Kanten ungekoppelt) | MEDIUM | **aufgelöst** | `internal/gen/archgate_test.go:141-176` koppelt die `edges` **bidirektional** an die realen Importe; nachgerechnet: alle fünf deklarierten Kanten werden von je mindestens einem realen Import benutzt (`ports->domain` 2×, `app->domain`, `app->ports` 2×, `adapters->app`, `adapters->domain` 2×) — keine Kante wird nur zufällig getroffen. Mutation 71 rot gesehen. |
| F-5 `make -n … \| grep -q` unter pipefail | MEDIUM | **teilweise** | Die benannte Instanz ist weg (`harness/tools/full-smoke.sh:423-424`, Here-String; Marker `:/src:ro` ist im Ziel a-check-exklusiv — d-check mountet `/repo:ro`, die Go-Gates sind `docker build`, im Lauf-Log 4× `:/src:ro`, alle a-check). Eine **zweite Instanz derselben Klasse aus demselben Slice** blieb stehen — s. N-1 (LOW). |
| F-6 Adopter-Kopf behauptet Digest-Pin | LOW | **aufgelöst** | `internal/emit/archgate.go:37-40` sagt „auf die Referenz gepinnt … (Digest, sonst Tag)"; deckt sich mit `Options.RunRef()` (`internal/emit/emit.go:80-89`). |
| F-7 Mutations-Beschreibung 69 ≠ `sed`-Wirkung | LOW | **aufgelöst** | `test/mutations/69-archgate-mount-scope.sh:5-10` beschreibt jetzt „Trenner gekappt, `<repo>apps/hex`" statt „Scope geweitet"; deckt sich mit dem `sed` in Zeile 12. |
| F-8 „rot gesehen" deckt nur `core-impurity` | LOW | **aufgelöst** | `internal/gen/golang.go:465-468` trennt sauber: `core-impurity` = rot gesehen (full-smoke), `wrong-direction` = Messung. Tippfehler „Richtungsprueefung" ist mit entfallen. |
| F-9 Teil-geschriebener Modulzustand | INFO | **bewusst offen** | Commit-Message benennt es als Restrisiko; Aufnahme in die Closure-Notiz steht aus. |
| F-10 Namensraum-Kollision `arch-<modul>.mk` | INFO | **bewusst offen** | wie F-9. |

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der
verbindlichen Single Source of Truth. Die Felder unten sind nur
**gespiegelt** (Bequemlichkeit beim Ausfüllen), nicht neu definiert; bei
Abweichung gilt der Skill bzw. dessen Quelle
[Kurs Modul 10 §Output-Schema](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/04-qualitaet/modul-10-review-harness.md#worked-example-eine-reviewer-skill-datei-schreiben).

<!-- Kein Fließtext, kein Lösungsvorschlag im Befund. Nummerierung N-* für
     die NEUEN Findings dieser Runde, damit sie nicht mit F-1…F-10 kollidiert. -->

### N-1 — F-5-Klasse: zweite Instanz im selben Slice blieb stehen

- `kategorie`: LOW
- `quelle`: [`MR-014`](../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) / Steering-Eintrag in `harness/tools/full-smoke.sh:68-73`
- `pfad`: `harness/tools/full-smoke.sh:393`
- `befund`: `grep -E 'core-impurity|wrong-direction' <<<"$teeth_out" | head -2 | sed …` ist dieselbe Konstruktion wie die in F-5 beanstandete: `head -2` schließt die Pipe nach zwei Zeilen, der Produzent `grep` bekommt SIGPIPE, unter `set -euo pipefail` propagiert dessen Nonzero und `full-smoke` bricht ohne Meldung ab — größenabhängig, schlägt erst zu, wenn die Treffermenge den Pipe-Puffer überschreitet. Die Zeile stammt aus `b853f73`, also aus slice-046 selbst; der Fix hat die Klasse an der einen genannten Stelle beseitigt (`:418`) und die neue analoge Stelle korrekt gebaut (`:483`, `sort` als drainender Konsument), diese aber nicht.
- `verifizierbar`: ja — `make full-smoke` mit einem a-check-Lauf, dessen Befundmenge über den Pipe-Puffer wächst (mehrere verbotene Importe im Zähne-Schritt).

### N-2 — neue Ist-Behauptung über a-check-Verhalten: im Repo unbelegt, von keinem Sensor gehalten, und als kategorische Zusage in die EMITTIERTE Datei geschrieben

- `kategorie`: LOW
- `quelle`: Hard Rule [`AGENTS.md` §3.6](../../AGENTS.md), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- `pfad`: `internal/gen/golang.go:459-463` (Quellkommentar), `internal/gen/golang.go:485-489` (emittierter Text)
- `befund`: Der Fix ersetzt die überdehnte Zusage aus F-3 durch eine **neue** Ist-Behauptung über fremdes Werkzeug-Verhalten („GEMESSEN (a-check v0.15.0 …): Exit 1, `wrong-direction`"). Im Repo existiert dazu kein Artefakt — kein Log, keine Report-Zeile, kein Test, kein Mutations-Fall; der Beleg liegt nur in einem Wegwerf-Experimentbaum außerhalb des Repos (dort real nachvollzogen: zweite Slice `application/example/farewell` mit Domain-Import, nicht in den Globs). Damit hält kein Sensor die Aussage, obwohl der a-check-Pin über den `upstream-drift`-Nachtlauf bewegt wird. Zusätzlich ist die in die **emittierte** Datei geschriebene Fassung kategorisch („Vergisst du es … a-check meldet seine Importe als wrong-direction (Exit 1) — laut, nicht still. Der Gate-Lauf sagt dir also Bescheid."), während die Messung nur den Fall mit schicht-übergreifendem Import deckt: eine zweite Slice ohne solchen Import (z. B. zuerst nur `command.go`/`result.go`) fällt unter keine Schicht und bleibt still grün.
- `verifizierbar`: ja — eine zweite Slice ohne Cross-Layer-Import ins hexSlice-Ziel legen und `make a-check-apps-hex` fahren: Exit 0 trotz ungedecktem Produktionscode.

### N-3 — Sentinel entkoppelt von `A_CHECK_IMAGE`, bleibt aber umgebungs-koppelbar

- `kategorie`: INFO
- `quelle`: Maintainability / [`LH-FA-07`](../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)
- `pfad`: `internal/emit/archgate.go:71-74`, `internal/emit/archgate_test.go:112-118`
- `befund`: `ifndef` sieht auch Umgebungs-Variablen, nicht nur Makefile-Zuweisungen. Trägt die Umgebung ein nicht-leeres `ARCH_GATE_MK_INCLUDED`, entfällt der `include` weiterhin und der Root-Zweig läuft in „No rule to make target 'a-check'". Die Fehlerklasse aus F-1 ist damit nicht getilgt, sondern von einer **dokumentierten** Adopter-Variablen auf einen **tool-privaten, nirgends beworbenen** Namen verschoben; der Restfall ist fail-loud (im Unterverzeichnis-Zweig läuft `docker run … $(A_CHECK_IMAGE)` mit leerem Image auf einen Fehler), nicht fail-open. Der neue Unit-Test verbietet spiegelbildlich genau **einen** Variablennamen (`ifndef A_CHECK_IMAGE`), nicht die Eigenschaft „keyt auf keine nutzer-sichtbare Variable".
- `verifizierbar`: ja — `ARCH_GATE_MK_INCLUDED=1 make -C <hexslice-Root-Ziel> gates`.

### N-4 — neuer Dry-Run-Aufruf ohne Rückgabe-Auffangen: `set -e` beendet full-smoke ohne Diagnose

- `kategorie`: INFO
- `quelle`: Maintainability (Diagnostizierbarkeit der Sensor-Skripte)
- `pfad`: `harness/tools/full-smoke.sh:423`
- `befund`: `dryrun_out="$( make -n -C "$tmprepo_hex" gates 2>&1 )"` fängt den Rückgabewert nicht ab (anders als die drei Nachbar-Aufrufe `roothex_out`/`override_out`/`two_out`, die `|| rc=$?` plus eigene Fehlermeldung tragen). Scheitert `make -n`, greift `set -e`, die make-Diagnose steckt in der verworfenen Variablen, und `full-smoke` endet ohne Ausgabe. Die Vorgänger-Form (`if ! make -n … | grep -q`) war gegen diesen Abbruch unempfindlich, weil sie in einer `if`-Bedingung stand.
- `verifizierbar`: ja — im Ziel-Repo ein Makefile-Syntaxfehler, dann `make full-smoke`: Abbruch ohne Meldung.

### N-5 — Rot-Pfad des include-once-Sensors nicht demonstriert

- `kategorie`: INFO
- `quelle`: Hard Rule [`AGENTS.md` §3.6](../../AGENTS.md)
- `pfad`: `harness/tools/full-smoke.sh:461-478`
- `befund`: Der Zwei-Modul-Block ist fail-safe verdrahtet (`overriding recipe`-Grep, Mount-Marker beider Module), aber die Beobachtung ist eine **grüne**: der Lauf zeigt, dass der Wächter heute wirkt, nicht dass der Sensor bei entferntem Wächter rot würde. `make mutate` erreicht ihn bauartbedingt nicht (`# verify:` kennt nur `test`/`smoke`/`ci-lint`, `harness/tools/mutate.sh:103-110`). Rot gesehen wurde Mutation 70, die eine andere Eigenschaft trägt (Wächter keyt nicht auf die Nutzer-Variable), nicht die include-once-Eigenschaft selbst.
- `verifizierbar`: ja — den `ifndef`/`endif`-Rahmen in `ArchGateMk` einmalig entfernen und `make full-smoke` fahren: der `overriding recipe`-Zweig muss feuern.

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der
verbindlichen Single Source of Truth. Die Felder unten sind nur
**gespiegelt** (Bequemlichkeit beim Ausfüllen), nicht neu definiert; bei
Abweichung gilt der Skill bzw. dessen Quelle
[Kurs Modul 10 §Output-Schema](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/04-qualitaet/modul-10-review-harness.md#worked-example-eine-reviewer-skill-datei-schreiben).

<!-- Kein Fließtext, kein Lösungsvorschlag im Befund. -->

## Negativbefunde

<!--
Eine Zeile pro betrachtetem Bereich. Ohne diesen Block ist "keine
Findings" nicht von "nicht geprüft" unterscheidbar (Modul 10
§Reviewer berichtet auch, was er nicht gefunden hat).
-->

Gezielt auf **fix-induzierte Regressionen** geprüft, entlang der fünf
Verdachtsachsen des Auftrags:

- geprüft, ohne Befund: **Sentinel-Semantik in beiden Zweigen** (`internal/emit/archgate.go:65-84`) — der Kopf ist für Root und Unterverzeichnis identisch, die Zuweisung `ARCH_GATE_MK_INCLUDED := 1` steht **vor** dem `include` (die umgekehrte Reihenfolge machte den Wächter wirkungslos), und der `include` wirkt beim Parsen sofort. Bei zwei Fragmenten in Glob-Reihenfolge (`arch-apps-hex.mk` vor `arch-apps-hex2.mk` vor `arch-go.mk`) bindet das erste `a-check.mk` ein, die späteren überspringen es — das vom Root-Fragment gebrauchte Target `a-check` und die Variable `A_CHECK_IMAGE` sind unabhängig davon definiert, welches Fragment den `include` ausgeführt hat. Kein reihenfolge-abhängiges Verhalten. `ifndef` behandelt leere Werte als undefiniert; der Sentinel wird auf `1` gesetzt, nie auf leer. Die verbleibende Umgebungs-Kopplung ist als N-3 (INFO) geführt.
- geprüft, ohne Befund: **`TestArchGateConfig_EdgesMatchSkeleton` ist nicht vakuös** — `archEdges` bricht bei leerer Kantenmenge ab (`internal/gen/archgate_test.go:186-188`), `archGlobs` bei leerer Glob-Menge (`:52-54`). Fände der Import-Regex nichts, bliebe `used` leer und Richtung (b) färbte **alle fünf** Kanten rot; lieferte `mostSpecific` für die Quelldatei `""`, entstünde die undeklarierte Kante `->…` und Richtung (a) färbte rot. Beide Vakuums-Wege sind damit geschlossen. Die Schicht-Zuordnung eines Import-**Pfads** über `m[1]+"/x.go"` trägt, weil `matchGlob` ausschließlich die Form „literales Verzeichnis-Präfix + `/**`" akzeptiert (`:218-224`) — Verzeichnis-Präfixe sind auf Datei- und Import-Pfaden derselbe Raum; eine Glob-Form, die das bräche, fiele bereits in `TestArchGateConfig_MatchesSkeleton` (Eigenschaft (c)) durch. Die Verschachtelung `…/greet/ports/**` (51) über `…/greet/**` (45) löst `mostSpecific` korrekt zugunsten der Port-Schicht auf; Längen-Gleichstände zwischen zwei auf denselben Pfad passenden Globs existieren im heutigen Satz nicht.
- geprüft, ohne Befund: **Vorbedingungen und Reihenfolge der neuen full-smoke-Fälle** — der `A_CHECK_IMAGE`-Override-Fall (`:428-444`) sitzt hinter dem Root-Bootstrap und dem grünen `make a-check`, liest den Pin aus dem realen `a-check.mk` (`sed -n 's/^A_CHECK_IMAGE ?= //p'`, deckt sich mit dem von `AdaptArchMK` erzeugten Anker `internal/emit/archgate.go:130,141`) und bricht bei leerem Pin **vor** dem Lauf ab; die Variable ist auf die eine Kommando-Substitution begrenzt, nichts wird exportiert. Der Zwei-Modul-Fall (`:446-483`) sitzt hinter allen LH-QA-01-Abwesenheits-Prüfungen für die flachen Module (`:357-367`) — hätte er davorgestanden, prüften jene gegen ein verändertes Repo. Der hinterlassene Zustand (`apps/hex2` + `harness/mk/arch-apps-hex2.mk` in `tmprepo_doc`) berührt die nachfolgenden slice-038-Prüfungen nicht: die Idempotenz-Prüfung läuft auf `tmprepo`, die kein-Prune-Prüfung listet nur `apps/api`/`apps/web`/`apps/engine`-Fragmente.
- geprüft, ohne Befund: **EPIPE-Freiheit der NEU eingeführten Greps** — `:424`, `:467`, `:473` sind Here-Strings ohne Produzenten-Prozess; `:483` (`grep -oE … | sort -u | sed …`) hat mit `sort` einen Konsumenten, der die Eingabe vollständig liest, also keinen frühen Pipe-Schluss. Die verbliebene Instanz der Klasse ist als N-1 geführt; die älteren `printf … | grep -q`-Stellen (`:110,122,130,174,189,239,285`) stammen aus früheren Slices und sind nicht Gegenstand dieses Diffs.
- geprüft, ohne Befund: **Marker-Spezifität `:/src:ro`** — im emittierten Ziel mountet nur a-check nach `/src:ro`; d-check mountet `/repo:ro` (Log-Zeilen 59/244/1104), die Go-/C++-Gates sind `docker build` ohne Bind-Mount. Im gesamten full-smoke-Log tragen genau 4 Zeilen `:/src:ro`, alle a-check. Der Marker nennt a-check zwar nicht namentlich, ist im Ziel aber eindeutig — dieselbe Marker-Wahl, die das Skript für `apps/hex` schon vorher begründet (`:346-352`).
- geprüft, ohne Befund: **Mutationen 70/71 brechen Verhalten, nicht das Kompilat** — 70 tauscht den Wert einer String-Konstanten (`archIncludeSentinel`), 71 fügt eine Zeile in ein Raw-String-Literal ein; beide Anker sind eindeutig (`archIncludeSentinel = "ARCH_GATE_MK_INCLUDED"` und `  - {from: ports,    to: domain}` je genau einmal im Repo) und dollar-frei (SC2016). Die eingefügte Kante `{from: adapters, to: ports}` wird vom Parser `archEdges` erfasst (`\{from:\s*…\}` trifft die Emitter-Form). Die Köpfe treffen die tatsächliche Wirkung (F-7-Klasse geprüft): 70 beschreibt den abgeschalteten Root-`include`, 71 die Erlaubnis auf Vorrat. Dass 70 zusätzlich `TestArchGateMk_RootAndScoped` rötet, ist unschädlich — `mutate.sh` verlangt den **erwarteten** Wächter in der Fehlschlag-Ausgabe, nicht dessen Alleinstellung.
- geprüft, ohne Befund: **F-6-Korrektur gegen den Code** — `Options.RunRef()` (`internal/emit/emit.go:80-89`) liefert `repo@digest` nur bei gesetztem Digest, sonst die Tag-Referenz; der neue Kopf-Wortlaut „Referenz … (Digest, sonst Tag)" deckt beide Fälle, ohne einen dritten zu behaupten. `A_CHECK_DIGEST` ist in `cmd/ai-harness-init/main.go:62-63` als Override dokumentiert.
- geprüft, ohne Befund: **Hard Rules am Fix-Diff** — §3.1 (`make gates` unverändert), §3.2 (kein `//nolint`, kein `# shellcheck disable`, kein neues `d-check:ignore`), §3.3 (kein `git mv`), §3.4 (keine ADR-Datei angefasst), §3.5 (keine Schwelle gesenkt; der Fix ist additiv plus zwei Wortlaut-Ersetzungen). Der Diff berührt genau die zehn im Commit gelisteten Dateien; keine Kollateral-Änderung an `cmd/`, `internal/fetch/` oder den Gate-Fragmenten.
- geprüft, ohne Befund: **Sensor-Lage nach dem Fix** — `make mutate` 67 ok/0 mit 70/71 neu rot gesehen (das Set wuchs um genau zwei, keine bestehende Mutation entfernt oder umgehängt), `make gates` 169 Dateien/0 Befunde, `make full-smoke` Exit 0 mit 11 OK-Zeilen und beiden neuen Belegen sichtbar im Lauf-Output (Log 1836-1838). Keine Zusage im Diff ohne zugehörigen Sensor außer den unter N-2/N-5 benannten.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 2 |
| INFO | 3 |

## Verdikt

**KONFORM** (merge-reif).

Alle fünf MEDIUM der ersten Runde sind aufgelöst; F-5 ist an der
benannten Stelle aufgelöst, seine Klasse hat aber eine zweite,
unberührte Instanz im selben Slice (N-1). Die drei LOW sind
Wortlaut-Korrekturen und halten dem Code stand. Keine der fünf
Verdachtsachsen des Regressions-Auftrags trägt einen Defekt: der
Sentinel ist in beiden Zweigen gleich und reihenfolge-unabhängig, der
Kanten-Test ist in beiden Richtungen nicht-vakuös und trifft alle fünf
Kanten über reale Importe, die neuen full-smoke-Fälle sitzen hinter
ihren Vorbedingungen und hinterlassen keinen verfälschenden Zustand,
die neuen Greps sind EPIPE-frei, und die Mutationen brechen Verhalten
mit eindeutigen Ankern und zutreffenden Köpfen.

**Merge-blockierend:** nein — kein HIGH, kein MEDIUM. N-1/N-2 (LOW)
sind Nachzieh-Punkte, keine Defekte am gelieferten Verhalten; N-3/N-4/N-5
(INFO) sind benannte Restrisiken. Empfehlung an die Closure-Notiz: N-1
bis N-5 zusammen mit den bewusst offenen F-9/F-10 und den
Verifier-Punkten R-2/R-3 als Restrisiken führen.

**Übergabe:** Findings gehen an die Implementation (Rückkante
Review → Plan bei Plan-Defekt). Der Report ersetzt keine
Verifikation — DoD-/Spec-Konformität prüft der Verifier separat
(Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
