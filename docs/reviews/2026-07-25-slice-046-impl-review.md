# Review-Report: slice-046 (konditionaler Arch-Gate-Emitter) — 2026-07-25

**Review-Art:** Code — geprüft wird der fertige Diff gegen Slice-Plan,
aktive ADRs und Konventionen (Modul 10 §Drei Review-Arten). **Nicht**
geprüft: die DoD-Abhakung (Verifier, Modul 11).

**Gegenstand:** slice-046, Commit `b853f73` (Basis `4186c20`)

**Skill:** `.harness/skills/reviewer.md` @ 1.3.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-25

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- Slice-Plan [`slice-046-arch-gate-emitter.md`](../plan/planning/done/slice-046-arch-gate-emitter.md)
- aktive ADRs: [ADR-0009](../plan/adr/0009-hexslice-arch-realisierung.md) (Realisierung), [ADR-0008](../plan/adr/0008-arch-achse-emittiertes-skelett.md) (Mechanik), [ADR-0007](../plan/adr/0007-bootstrap-phasen.md) (Idempotenz-Klassen), [ADR-0003](../plan/adr/0003-go-native-binaries.md) (Docker-only)
- berührte IDs: [`LH-FA-07`](../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
- [`AGENTS.md`](../../AGENTS.md) (Hard Rules §3.1–§3.6), [`harness/conventions.md`](../../harness/conventions.md) (MR-Block)
- kanonische Referenz zum Abgleich: `hexslice-architecture` `lab/examples/go/.a-check.yml` (lokal, außerhalb des Repos)
- vorherige Findings am gleichen Modul: slice-045b (INFO-1 sprach×arch), slice-044 (F-1 Mutations-Deckung), slice-038 (MEDIUM datei-granulare Idempotenz-Klasse), slice-037 (M-1 Containment)

**Betriebsmodus:** read-only. Keine `make`-Läufe (Gate-Stempel/Stop-Hook),
keine Host-Toolchain. Sensor-Ausgaben wurden aus dem Implementer-Lauf
übernommen (`make gates` grün · `make mutate` 65 ok/0 · `make full-smoke`
Exit 0, Log gelesen), nicht nachgefahren.

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der
verbindlichen Single Source of Truth. Die Felder unten sind nur
**gespiegelt** (Bequemlichkeit beim Ausfüllen), nicht neu definiert; bei
Abweichung gilt der Skill bzw. dessen Quelle
[Kurs Modul 10 §Output-Schema](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/04-qualitaet/modul-10-review-harness.md#worked-example-eine-reviewer-skill-datei-schreiben).

<!-- Kein Fließtext, kein Lösungsvorschlag im Befund. -->

### F-1 — include-once-Wächter hängt an der nutzer-überschreibbaren `A_CHECK_IMAGE`

- `kategorie`: MEDIUM
- `quelle`: [`LH-FA-07`](../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) (Happy Path „`make gates` fährt das Arch-Gate mit")
- `pfad`: `internal/emit/archgate.go:56-60`
- `befund`: Das emittierte Root-Fragment schließt `include a-check.mk` in `ifndef A_CHECK_IMAGE` ein und hängt danach unbedingt `GATE_CHECKS += a-check` an. `A_CHECK_IMAGE` ist genau die Variable, die das tool-generierte `a-check.mk` per `?=` zum Überschreiben anbietet: setzt der Adopter sie in der Umgebung oder als `make A_CHECK_IMAGE=… gates`, ist sie für `ifndef` definiert, der `include` entfällt, das Target `a-check` existiert nicht mehr — und `make gates` bricht mit „No rule to make target 'a-check'" ab, statt das Image zu überschreiben. Im Unterverzeichnis-Zweig tritt der Fall nicht auf (das Target steht dort im Fragment selbst), die beiden Zweige verhalten sich unter demselben Override also gegensätzlich.
- `verifizierbar`: ja — `make full-smoke` mit gesetztem `A_CHECK_IMAGE` (bzw. `make A_CHECK_IMAGE=… gates` im Root-hexslice-Ziel `tmprepo_hex`) zeigt den Abbruch; heute deckt kein Lauf diesen Pfad ab.

### F-2 — Zusage „include-once" ohne rot gesehenes Gegenbeispiel

- `kategorie`: MEDIUM
- `quelle`: Hard Rule [`AGENTS.md` §3.6](../../AGENTS.md)
- `pfad`: `internal/emit/archgate.go:49-51`, `internal/emit/archgate_test.go:76,99`
- `befund`: Der Kommentar sagt zu, der Wächter verhindere, dass „ein zweites hexSlice-Modul dieselben Targets ein zweites Mal definiert (`overriding recipe`)". Kein Sensor misst diese Eigenschaft: `make full-smoke` bootstrappt genau ein hexSlice-Modul (`apps/hex`) plus das Root-Ziel in einem getrennten Repo, es gibt keinen Mutations-Fall zum Wächter, und `TestArchGateMk_RootAndScoped` prüft die Anwesenheit des Literals `"ifndef A_CHECK_IMAGE\ninclude a-check.mk\nendif\n"` — also die heutige Implementierung, nicht die behauptete Eigenschaft. F-1 ist die konkrete Fehlfunktion desselben Konstrukts, die ein solcher Sensor sichtbar gemacht hätte.
- `verifizierbar`: ja — ein zweites hexSlice-Modul im `full-smoke`-Mono-Repo (`add-lang go apps/hex2 --arch hexslice`) fährt `make gates` real gegen beide Fragmente.

### F-3 — Kommentar-Zusage „der Präfix hält sie scharf, sobald der Adopter seine zweite Slice anlegt" übersteigt den Code

- `kategorie`: MEDIUM
- `quelle`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), Hard Rule [`AGENTS.md` §3.6](../../AGENTS.md) (ADR-0007-H2-Klasse: Ist-Behauptung > Code)
- `pfad`: `internal/gen/golang.go:455-456`, emittierte Config `internal/gen/golang.go:482-487`
- `befund`: Die `app`- und `ports`-Globs zählen die eine generierte Slice **literal** auf (`…/example/greet/**`, `…/example/greet/ports/**`). Legt der Adopter eine zweite Slice an, fällt deren Code unter keinen Schicht-Glob, und `lateral-slice`/`port-locality` bleiben genauso inert wie vorher — scharf werden sie erst, wenn der Adopter zusätzlich die Config erweitert. Die Config ist skip-if-present, das Tool zieht sie also nie nach; die in die emittierte Datei geschriebene Anleitung (`golang.go:469-470`) nennt nur den Umbenennungs-Fall („beim Umbenennen der Area/Slice also die Globs mitziehen"), nicht das Hinzufügen. Der Kommentar sagt eine Selbst-Schärfung zu, die nicht eintritt.
- `verifizierbar`: ja — im `full-smoke`-hexSlice-Ziel eine zweite Slice anlegen und `make a-check-apps-hex` fahren: das Gate bleibt grün, obwohl neuer Produktionscode außerhalb jedes Schicht-Globs liegt.

### F-4 — ADR-0009-Fitness-Function nur zur Hälfte umgesetzt (Kanten ungekoppelt)

- `kategorie`: MEDIUM
- `quelle`: [ADR-0009](../plan/adr/0009-hexslice-arch-realisierung.md) §Fitness Function („die emittierte `.a-check.yml` deklariert genau die **Schichten/Kanten**, die das emittierte Skelett trägt … eine Drift färbt rot")
- `pfad`: `internal/gen/archgate_test.go:71-140`
- `befund`: `TestArchGateConfig_MatchesSkeleton` koppelt ausschließlich die Schicht-**Globs** an die generierten Rollen-Pfade; der `edges`-Block der Config wird von keinem Test und keiner Mutation berührt. Der emittierte 5-Kanten-Satz stimmt heute verbatim mit der kanonischen Referenz überein (geprüft, s. Negativbefunde) — eine spätere Erweiterung, etwa eine `adapters→ports`-Kante, lockerte das emittierte Gate jedoch ohne rot werdenden Sensor, obwohl ADR-0009 die Nicht-Kante ausdrücklich begründet und die Fitness-Function sie mit abdecken soll.
- `verifizierbar`: ja — ein Mutations-Fall, der eine Kante in `goHexArchConfig` hinzufügt/entfernt, bleibt heute grün (`make mutate`).

### F-5 — neuer `make | grep -q`-Pipe unter `pipefail` (EPIPE-Klasse, im selben Skript dokumentiert)

- `kategorie`: MEDIUM
- `quelle`: [`MR-014`](../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) / Steering-Eintrag in `harness/tools/full-smoke.sh:68-73`
- `pfad`: `harness/tools/full-smoke.sh:418`
- `befund`: `make -n -C "$tmprepo_hex" gates 2>&1 | grep -qF -- "a-check"` ist die Konstruktion, gegen die dasselbe Skript 350 Zeilen weiter oben explizit steuert: unter `set -o pipefail` schließt `grep -q` die Pipe beim ersten Treffer, der Produzent (`make -n`) bekommt EPIPE, und dessen Nonzero propagiert — der `if !`-Zweig meldet dann „Root-Arch-Gate hängt nicht in make gates", obwohl der Marker gefunden wurde. Der Fehlschlag ist größenabhängig (CI-rot/lokal-grün) und schlägt erst zu, wenn die `make -n`-Ausgabe über den Pipe-Puffer wächst; alle anderen Marker-Greps dieses Slices nutzen korrekt Here-Strings.
- `verifizierbar`: ja — `make full-smoke` (CI-Lauf) bei gewachsener Gate-Menge im Ziel; heute grün, weil die Ausgabe klein ist.

### F-6 — Adopter-Kopf behauptet einen Digest-Pin, den `AdaptArchMK` nicht garantiert

- `kategorie`: LOW
- `quelle`: [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), Hard Rule [`AGENTS.md` §3.6](../../AGENTS.md)
- `pfad`: `internal/emit/archgate.go:34-37` vs. `internal/emit/archgate.go:113-130`
- `befund`: Der in jedes emittierte `a-check.mk` geschriebene Kopf sagt „`A_CHECK_IMAGE` auf den Digest gepinnt, der das Fragment ERZEUGT hat". Gepinnt wird `opts.RunRef()`; bei leer gesetztem `A_CHECK_DIGEST` (dokumentierter Env-Override, `cmd/ai-harness-init/main.go:63`) ist das die **Tag**-Referenz, und der Kopf behauptet dann einen Digest-Pin, den die Datei nicht trägt. Das Doc-Gate-Gegenstück unterscheidet diesen Fall explizit (`AdaptMK`, `internal/emit/emit.go:145`: `case digest != "" && …`).
- `verifizierbar`: ja — `A_CHECK_DIGEST=` gesetzt, Bootstrap mit `--arch hexslice`, das emittierte `a-check.mk` lesen.

### F-7 — Mutations-Beschreibung 69 beschreibt eine andere Wirkung als der `sed`

- `kategorie`: LOW
- `quelle`: Hard Rule [`AGENTS.md` §3.6](../../AGENTS.md) (Mutation als benanntes Gegenbeispiel)
- `pfad`: `test/mutations/69-archgate-mount-scope.sh:6-11`
- `befund`: Der Kopf sagt, die Mutation weite den Mount „vom Modul-Verzeichnis auf das ganze Ziel-Repo" und a-check liefe dann „mit der Config des einen Moduls über allen anderen". Der `sed` entfernt nur den Schrägstrich und erzeugt `"$(CURDIR)apps/hex"` — einen ungültigen Pfad, nicht den Repo-Root. Die Mutation färbt den benannten Test korrekt rot; das benannte Gegenbeispiel ist aber ein anderes als das beschriebene.
- `verifizierbar`: ja — `make mutate` (Fall 69 rot, aber aus dem im Kopf nicht genannten Grund).

### F-8 — „einmal rot gesehen" deckt nur einen der beiden genannten Befund-Typen

- `kategorie`: LOW
- `quelle`: Hard Rule [`AGENTS.md` §3.6](../../AGENTS.md)
- `pfad`: `internal/gen/golang.go:456-457`
- `befund`: Der Kommentar schreibt „Was hier und heute REAL feuert, ist die Richtungsprueefung (core-impurity/wrong-direction) — einmal rot gesehen". Rot gesehen wurde im `full-smoke`-Lauf ausschließlich `core-impurity` (Log-Zeile „core-impurity: Kern importiert app/internal/adapters/outbound/notify"); für `wrong-direction` existiert kein Beleg im Diff oder im Lauf. (Nebenbei: Tippfehler „Richtungsprueefung".)
- `verifizierbar`: ja — `make full-smoke`-Log (Zähne-Abschnitt) zeigt nur `core-impurity`.

### F-9 — Teil-geschriebener Modulzustand, wenn `--print-mk` auf dem hexSlice-Pfad fällt

- `kategorie`: INFO
- `quelle`: Maintainability / [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
- `pfad`: `cmd/ai-harness-init/main.go:241-256`
- `befund`: `wireLang` platziert Skelett und Code-Gate-Fragment, ruft danach `emit.ArchGate` und erst danach `emit.BlockedFragment`. Fällt der Docker-Lauf (kein Docker auf dem `add-lang --arch hexslice`-Pfad), bleibt das Modul mit Skelett und Code-Gate, aber ohne `blocked/<lang>`-Fragment zurück. `ArchGate` selbst ist sauber all-or-nothing, und ein Wiederholungslauf konvergiert — an keiner Stelle wird Atomarität für `wireLang` zugesagt, deshalb kein Verstoß, nur eine undokumentierte Annahme.
- `verifizierbar`: nein — kein bestehender Lauf deckt den Docker-losen hexSlice-Pfad ab.

### F-10 — Namensraum-Kollision `harness/mk/arch-<modul>.mk` mit einem Modul unter `arch/<lang>`

- `kategorie`: INFO
- `quelle`: Maintainability (Fortsetzung der slice-037-Fragment-Namensraum-Klasse)
- `pfad`: `internal/emit/archgate.go:42`, `cmd/ai-harness-init/main.go:233`
- `befund`: Das Arch-Fragment eines Root-Go-Moduls heißt `harness/mk/arch-go.mk`; das **Code**-Gate-Fragment eines Moduls unter dem Pfad `arch/go` heißt nach `gen.ModuleName` ebenfalls `harness/mk/arch-go.mk`. Beide sind konvergent geschrieben, der zweite Emitter überschriebe den ersten also stillschweigend. Konstruierter, aber erreichbarer Pfad; kein Test grenzt den Namensraum ab.
- `verifizierbar`: nein — kein Lauf bootstrappt ein Modul unter `arch/<lang>`.

## Negativbefunde

<!--
Eine Zeile pro betrachtetem Bereich. Ohne diesen Block ist "keine
Findings" nicht von "nicht geprüft" unterscheidbar (Modul 10
§Reviewer berichtet auch, was er nicht gefunden hat).
-->

- geprüft, ohne Befund: **ADR-0009-Treue der emittierten `.a-check.yml`** (`internal/gen/golang.go:458-511`) gegen die kanonische Referenz `lab/examples/go/.a-check.yml` — `version: 1`, `languages: go: ["**/*.go"]`, die vier Layer mit `role: domain|port|app|adapter`, der **vollständige 5-Kanten-Satz** (`app→domain`, `app→ports`, `ports→domain`, `adapters→app`, `adapters→domain`), die **korrekt fehlende** `adapters→ports`-Kante samt Begründung, `composition_root: ["cmd/**"]`, `exclude: ["**/*_test.go"]`. Einziger Unterschied zur Referenz ist der Fachbezug (`example/greet` statt `order/createorder|cancelorder`) — von [ADR-0009](../plan/adr/0009-hexslice-arch-realisierung.md) Entscheidung 4 als adaptierbarer Marker gedeckt.
- geprüft, ohne Befund: **Glob-Form gegen die „still inert"-Warnung** — alle Slice-/Port-Globs tragen literale Verzeichnis-Präfixe, kein `…/**/ports/**`-Wildcard-in-der-Mitte; `matchGlob` (`internal/gen/archgate_test.go:142-149`) erzwingt die Form aktiv (andere Formen fallen im Kopplungstest durch).
- geprüft, ohne Befund: **LH-QA-01, nicht-leerer Prüfbereich** — jede generierte Produktions-Go-Datei fällt unter genau einen spezifischsten Glob, und jeder deklarierte Glob trifft mindestens eine reale Datei (`TestArchGateConfig_MatchesSkeleton`, Eigenschaften (a)/(c)); die beiden Verzeichnisse `application/example/ports/` und `application/example/greet/ports/` existieren im generierten Skelett (`internal/gen/golang.go:61-63`). Dass `lateral-slice`/`port-locality` mit einer Slice noch nicht feuern können, ist im emittierten Kommentar wie im Quellkommentar offen benannt — das ist die §3.6-konforme Einschränkung der Zusage, nicht ihre Verletzung (die daran hängende Fehl-Zusage ist separat als F-3 geführt).
- geprüft, ohne Befund: **Konditionalität** — `archLayered` leitet „trägt Schichten" strukturell aus `archLayout` ab (keine zweite Namensliste), `ArchGateConfig` schließt zusätzlich sprach-fremde Kombinationen über `archSupported` aus, `wireLang` ist der einzige Aufrufort für beide Eintrittspunkte (`--lang`-One-Shot und `add-lang`). `TestArchGateConfig_OnlyLayered` deckt `{go,cpp} × {flat,hexslice,"",onion}` ab, `TestRun_AddLangArchFlatEmitsNoArchGate` die Artefakt-Abwesenheit im Ziel, `harness/tools/full-smoke.sh:353-366` zusätzlich für die flachen Mono-Repo-Module und das flache `--lang go`-Ziel.
- geprüft, ohne Befund: **Idempotenz-Klassen ([ADR-0007](../plan/adr/0007-bootstrap-phasen.md)/slice-038)** — je emittierte Datei genau eine Klasse: `<pfad>/.a-check.yml` skip-if-present (Adopter-Boden, `writeSkipIfPresent`), `a-check.mk` und `harness/mk/arch-<modul>.mk` konvergent (`writeFileMode`); `TestArchGate_IdempotenzKlassen` misst beide Richtungen (kein Clobbern / Drift geheilt). Keine datei-granulare Mischklasse wie in slice-038 übersehen.
- geprüft, ohne Befund: **[`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)-Re-Pin** — `AdaptArchMK` ersetzt die `A_CHECK_IMAGE ?=`-Zeile durch `opts.RunRef()` und bricht bei fehlendem Anker, fehlendem Zeilenende oder nicht greifendem Pin hart ab (`internal/emit/archgate.go:113-130`); `TestAdaptArchMK_PinsProducingRef` prüft beide Richtungen (erzeugender Pin da, gedruckter Pin weg), `TestAdaptArchMK_UnknownFormat` den Abbruch. Der Default-Digest `sha256:6425c93a…` stimmt mit dem in [ADR-0009](../plan/adr/0009-hexslice-arch-realisierung.md) §Kontext 1 gepinnten überein.
- geprüft, ohne Befund: **Fehler-Reihenfolge in `ArchGate`** — erst `--print-mk` + Adaption (fallierbar), dann die drei Schreibvorgänge; `TestArchGate_PrintFehlerSchreibtNichts` belegt das leere Zielverzeichnis nach Fehlschlag.
- geprüft, ohne Befund: **`internal/fetch/baseline.go` 0700→0755** — `os.Chmod(tmp, 0o755)` sitzt vor `unpackTrees`, ist umask-unabhängig, und die darunter angelegten Verzeichnisse entstehen über `writeFile` bereits mit `MkdirAll(…, 0o755)` (`internal/fetch/baseline.go:414`); der Modus überlebt das Rename ins `<tag>`-Verzeichnis. `TestBaseline_TagDirTraversierbar` misst die Eigenschaft (`perm&0o055`), nicht die Konstante, Mutation 67 färbt sie rot.
- geprüft, ohne Befund: **Mutations-Set 65–68** — jede Mutation bricht Verhalten, nicht das Kompilat (65: `cfg`/`ok` bleiben benutzt; 66: `s`, `i`, `nl` bleiben benutzt; 67/68 sind reine Wert-/String-Änderungen), jeder Anker ist eindeutig (`return "", false` kommt in `internal/gen/arch.go` genau einmal vor) und `$`-frei bzw. escaped (SC2016). Fall 69 färbt seinen Test korrekt rot — nur die Beschreibung weicht ab (F-7).
- geprüft, ohne Befund: **Hard Rules** — §3.1 (`make gates` unverändert, a-check wird im Dogfood **nicht** als Gate behauptet), §3.2 (kein `//nolint`, kein `# shellcheck disable`, kein neues `d-check:ignore` im Diff), §3.3 (kein `git mv` im Commit), §3.4 (keine ADR-Datei angefasst), §3.5 (keine Schwelle gesenkt; die Emission ist additiv).
- geprüft, ohne Befund: **Doku-Nachzug `AGENTS.md:127` / `harness/README.md:49`** — beide Sätze sagen dasselbe, behaupten a-check **nicht** als Dogfood-Gate, benennen den flachen Dogfood als Grund und verweisen für den Beleg auf `make full-smoke`; die Belege dahinter existieren real (Log-Zeilen 1100, 1831, 1836). Keine Ist-Behauptung über den Code hinaus.
- geprüft, ohne Befund: **[`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)** — der `flat`-Pfad erreicht den Docker-Aufruf nie (die Bedingung sitzt vor dem `context`/`ArchGate`-Block), `add-lang <lang> <pfad>` bleibt netzlos; das emittierte Gate läuft `--network none` + `:ro`, das Zielrepo braucht nichts über `git + docker` hinaus.
- geprüft, ohne Befund: **`full-smoke.sh` Zähne-Abschnitt** — der verbotene Import wird auf einer Kopie-Sicherung angebracht und danach zurückgenommen; greift der `sed` nicht, bleibt das Gate grün und das Skript meldet fail-safe rot; der Befund wird sichtbar gedruckt statt nur behauptet.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 5 |
| LOW | 3 |
| INFO | 2 |

## Verdikt

**NICHT KONFORM** (noch nicht merge-reif) — keine HIGH, aber fünf MEDIUM.

**Merge-blockierend:** ja — F-1 bis F-5. Keines der MEDIUM stellt die
gelieferte Mechanik in Frage: die konditionale Emission, die
ADR-0009-Treue der Config, die Idempotenz-Klassen und der Digest-Re-Pin
sind konform (s. Negativbefunde). Die fünf MEDIUM betreffen (a) den
include-once-Wächter, der an einer nutzer-überschreibbaren Variablen
hängt und dessen zugesagte Eigenschaft von keinem Sensor gemessen wird
(F-1/F-2 — dasselbe Konstrukt, einmal als Defekt, einmal als
§3.6-Lücke), (b) zwei Abdeckungs-/Zusage-Lücken an der LH-QA-01- bzw.
ADR-0009-Fitness-Kante (F-3/F-4) und (c) eine neu eingeführte Instanz
der im selben Skript dokumentierten EPIPE-Klasse (F-5). Die LOW/INFO
blockieren nicht.

**Übergabe:** Findings gehen an die Implementation (Rückkante
Review → Plan bei Plan-Defekt). Der Report ersetzt keine
Verifikation — DoD-/Spec-Konformität prüft der Verifier separat
(Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
