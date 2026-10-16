# Review: slice-span-sperre-haelt-den-test-unter-last

**Range:** Implementer `11f921a8` (`internal/span/emit.go`: `lockTries` 200 auf 750, `lockWait` 2 ms, Kommentar der Klasse Grenze an den Konstanten; `span_test.go` unverändert, n = 8) · **Plan:** `slice-span-sperre-haelt-den-test-unter-last` (§1 Architect-Verdikt A2, §2, §4) · **Bezug:** SPEC-060, SPEC-063, LH-FA-16, LH-QA-02, AGENTS.md §3.3/§3.5/§3.6/§3.7/§3.8/§3.10 · Reviewer-Skill (Stand HEAD). Nicht geprüft: DoD (Verifier).

**Summary:** 0 HIGH · 2 MEDIUM · 2 LOW · 1 INFO — annahmefähig mit Nachbesserung am Kommentar bzw. in §7. Ergebnis zu (a): die Erhöhung ist eine begründete Vermutung, kein Beweis; der Kommentar behauptet das Gegenteil nicht, bindet aber mehr, als der Test hält (MEDIUM-1). Ergebnis zu (b): Rot-Beleg und Grün-Lauf reproduziert. Ergebnis zu (c): keine weitere Stelle kennt 200 oder 400 ms.

## Findings

### MEDIUM-1 — „TestConcurrentEmittersGetDistinctSeq bindet das Budget" überzieht: der Test bindet nur „mehr als ein Versuch", nicht 750

- `kategorie`: MEDIUM
- `quelle`: AGENTS.md §3.6 (ein Test, dessen Name/Kommentar eine Eigenschaft behauptet, muss sie messen), §3.7 (Klasse Zusage)
- `pfad`: `internal/span/emit.go:32-40`
- `befund`: Gemessen: mit `lockTries = 1` 5/5 rot (`1 Zeilen, erwartet 8`), mit 750 10/10 grün. Der Test fällt aber auch bei jedem Wert, den ein 8-Goroutinen-Lauf ohne Stall erträgt, nicht erst bei 200 oder 750; er unterscheidet 200 von 750 nicht, und die CI-Ursache (ein Halter, der länger als 400 ms hält) ist lokal nicht reproduziert (Implementer: 100/100, 60/60, 40/40 unter Last mit 200 grün). „bindet das Budget" liest sich als „fällt, wenn das Budget unter das Nötige sinkt". Wahr ist: er fällt, wenn das Budget praktisch null ist. Dass 750 die CI-Flanke schließt, ist eine Vermutung (Stall des Halters < 1,5 s), die der Kommentar nicht benennt; ebenso nicht, dass der Anlass am Konstanten gar nicht mehr stehen soll (§3.7 Herkunft), aber die Grenze „Wirkung der Erhöhung am Anlass ungemessen" ist eine Grenze und gehört in die Klasse Grenze oder in §7.
- `verifizierbar`: ja (Lauf mit `lockTries = 1`: rot; mit 750: grün, siehe unten)
- `klasse`: Zusage nennt einen Zahn, der nur die Untergrenze trägt

### MEDIUM-2 — Closure-Kriterium „zehn Läufe unter Last grün" und „Ursache gemessen" sind nicht diskriminierend; §7 muss „nicht reproduziert" sagen

- `kategorie`: MEDIUM
- `quelle`: AGENTS.md §3.6, Slice §2 Punkt 1 und 2, §5
- `pfad`: Slice §2/§5; Implementer-Bericht
- `befund`: Die zehn Läufe waren vorher (mit 200) ebenfalls grün; sie unterscheiden Vorher und Nachher nicht und belegen die Wirkung der Änderung nicht. Der einzige diskriminierende Beleg ist die Gegenrichtung (1 Versuch rot), und die belegt nur, dass der Test das Budget überhaupt liest. Der Punkt „Ursache gemessen und benannt" ist damit nicht erfüllt: gemessen ist nicht, *warum* ein Halter die Sperre über 400 ms hält (Scheduling-Stall unter vier parallelen Workern vs. etwas anderes). Das ist keine Vorwegnahme der Closure, sondern ein Beleg-Mangel; Ausgang ist ehrliche Benennung in §7 (Planner) und gegebenenfalls Rückführung nach `open`, falls die Fehlerklasse im CI wiederkehrt. `make mutate-auswahl` → Exit 10 (CI-Branch-Weg ohne Push) belegt für die CI-Klasse nichts. Schweregrad MEDIUM, nicht HIGH: die Änderung ist harmlos (siehe LOW-1), der Mangel ist die Zusage „Ursache behoben", die nur als Vermutung gilt.
- `verifizierbar`: ja (Implementer-Messreihe; eigener Grün-Lauf unten)
- `klasse`: Kriterium, das vorher schon erfüllt war

### LOW-1 — Das Budget verdreifacht die spürbare Verzögerung im Haltefall, die Rechnung gilt nur dem Kill

- `kategorie`: LOW
- `quelle`: ADR-0011 Festlegung 6 (nie spürbar verzögern), `internal/span/emit.go:26-30` (maxHash-Kommentar), Slice §2 Punkt 1
- `pfad`: `internal/span/emit.go:32-41`
- `befund`: Rechnung stimmt: 750 × 2 ms = 1,5 s nominal = 30 % von 5 s (`.claude/settings.json:74/86/98`, `"timeout": 5`; weitere Event-Einträge gleich). Der Kommentar nennt „fail-open, bevor der Hook beendet wird"; fail-open sitzt im Aufrufer (`cmd/ai-harness-init/span_emit.go`, `mustEmit`: Meldung nach stderr, Exit 0), `acquire` gibt nur den Fehler zurück — die Aussage ist wahr für die Kette, nicht für `acquire` allein. Der Preis ist im Kommentar nicht genannt: bei gehaltener Sperre wartet jeder Tool-Call bis zu 1,5 s statt 0,4 s. Der Slice hat das ausdrücklich gegen den Kill-Timeout, nicht gegen „unmerklich" gerechnet; die Grenze „nominal, `time.Sleep` kann länger" ist korrekt und genannt. Beide Seiten sind Abwägung, kein Fehler.
- `verifizierbar`: ja (`sed -n 349,374p internal/span/emit.go`; `grep -n timeout .claude/settings.json`)
- `klasse`: Kosten der Änderung am Konstanten nicht benannt

### LOW-2 — Satz „(er läuft unter Last nicht)" im Kommentar ist unverständlich elliptisch

- `kategorie`: LOW
- `quelle`: AGENTS.md §3.7
- `pfad`: `internal/span/emit.go:35-36`
- `befund`: Die Klammer „er läuft unter Last nicht" beschreibt, was der Halter nicht tut; lesbar ist sie nur mit dem Slice im Kopf. Der Kommentar soll an den Ändernden schreiben; der Satz trägt keine der fünf Klassen eindeutig. (Inhaltlich: der Halter hält die Sperre nur kurz; er wird gestört, nicht langsam.)
- `verifizierbar`: nein
- `klasse`: Kommentar mit Verweis auf unbenannten Kontext

### INFO-1 — Stellen mit 200 / 400 ms gemessen: keine

- `kategorie`: INFO
- `befund`: `git grep -n -E 'lockTries|lockWait|400 ?ms|200 Versuche|Sperr-Budget' -- . ':!.harness/baseline' ':!docs/reviews'` nennt neben `emit.go` und `lock_unix.go:11` (Verweis auf die Namen, keine Zahl) nur die Slice-Datei (Anlass-Satz „~400 ms", als Chronik des Anlasses zulässig). Spec, Handbuch, `harness/sensors/hook-overhead.md` führen weder 200 noch 400 ms. Kein Nachzug nötig.

## Ergebnisse zu den Schwerpunkten

**(a)** Rechnung: 750 × 2 ms = 1,5 s, 30 % von 5 s: stimmt; Timeout-Zeilen 74/86/98 tragen `"timeout": 5`. fail-open: wahr für die Kette (`mustEmit`), nicht in `acquire` selbst (LOW-1). Der Kommentar behauptet nicht, dass 750 den CI-Fehler behebt, und nennt die Grenze (Halter über dem Budget verliert den Span). Er bindet aber den Test breiter als gemessen (MEDIUM-1). Die Erhöhung ist damit begründete Vermutung.

**(b)** Reproduziert im Docker-Weg (`docker build --target test`, Image-Tag aus `GO_VERSION ?= 1.27.1`, `docker run --network none … go test`), `lockTries = 1` lokal, danach `git checkout internal/span/emit.go`, Images entfernt, `git status` sauber:

```text
# lockTries = 1, 5 Läufe, je:
    span_test.go:820: 1 Zeilen, erwartet 8
FAIL	github.com/pt9912/ai-harness-init/internal/span	0.004s
# (5 von 5 rot)
# lockTries = 750 (HEAD), go test -count=10 -run TestConcurrentEmittersGetDistinctSeq ./internal/span/
ok  	github.com/pt9912/ai-harness-init/internal/span	0.200s
```

Anmerkung: die Meldung am Test ist „1 Zeilen, erwartet 8" (Zeile 820, `Errorf("Emit: span: Sperre nicht erhalten")` geht dem voraus, im `tail -4` abgeschnitten, vom Implementer als CI-Meldung berichtet); das Rot kommt aus dem Sperr-Fehler.

**(c)** Siehe INFO-1: keine weitere Stelle falsch.

**(d)** SPEC-060/SPEC-063 (`spec/spezifikation.md:199/202`) führen Nebenläufigkeit und Lock-Verzeichnis, aber kein Budget (`grep -n -iE 'lockTries|Sperr-Budget|lockWait' spec/spezifikation.md` → keine Zeile); MR-075 (Spalte „Präzisiert") bindet Festlegungen an LH-Elemente, ein Implementierungswert ohne Spec-Zeile verletzt sie nicht. Eine Budget-Erhöhung senkt keine Gate-Schwelle (§3.5): `make hook-overhead` ist kein Gate, `make test-go` wird nicht gelockert. Verdikt A2 trägt. Auflagen: n bleibt 8 (erfüllt, `span_test.go` unberührt); Beleg ist die Worst-Case-Rechnung (erfüllt); Zahl und Grenze als Kommentar (erfüllt, mit MEDIUM-1/LOW-2).

**(e)** Commit-Zuschnitt: `git show --stat 11f921a8`: nur `internal/span/emit.go`; Message nennt Rolle und Kennung; keine Closure-Artefakte, kein Norm-Text, kein Move — §3.3/§3.8/§3.10 gewahrt.

**(f)** Siehe MEDIUM-2.

## Geprüft, ohne Befund

- **Zusage-Schärfe der Konstanten:** `lockWait` unverändert 2 ms; `for range lockTries` (emit.go:369) liest die Konstante, die Rechnung folgt dem Code.
- **Test nicht geschwächt:** `span_test.go` unverändert, n = 8, Prüfung auf Zeilenzahl und doppelte `seq` unberührt.
- **Baum nach dem Lauf:** sauber, keine Kopie, Images entfernt.
