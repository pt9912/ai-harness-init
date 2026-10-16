# Review: slice-roter-gruen-vorlauf-des-mutate-treibers-zeigt-sein-log

**Range:** Implementer `5b4ac962` (`harness/tools/mutate.sh`: `show_failures`, im Abbruch von `green_prerun` vor `show_tail`; `test/mutate-driver.bats`: Fall 18; `harness/sensors/mutate.md`: Abschnitt „Meldung eines roten Grün-Vorlaufs") · **Plan:** `slice-roter-gruen-vorlauf-des-mutate-treibers-zeigt-sein-log` (§1, §3) · **Bezug:** LH-QA-02, MR-090, MR-071, AGENTS.md §3.2/§3.3/§3.5/§3.6/§3.7/§3.10 · Reviewer-Skill (Stand HEAD). Nicht geprüft: DoD (Verifier).

**Summary:** 0 HIGH · 0 MEDIUM · 2 LOW · 2 INFO — annahmefähig. Ergebnis zu (a): der bats-Fall misst die Eigenschaft für die bats-Form; Rot-Beleg reproduziert. Der Go-Zweig (`--- FAIL`) trägt keinen Zahn (LOW-1). Ergebnis zu (b): Grenzfälle am Quelltext und am realen bats-Lauf gelesen, kein Defekt.

## Findings

### LOW-1 — der Go-Zweig (`--- FAIL`) von `show_failures` ist ohne bindenden Fall; die Doku sagt „Gehalten wird das von …"

- `kategorie`: LOW
- `quelle`: AGENTS.md §3.6 (mehrteilige Zusage, ein Teil ohne eigenen Fall), `harness/sensors/mutate.md` Abschnitt „Meldung eines roten Grün-Vorlaufs"
- `pfad`: `harness/tools/mutate.sh:697` (`/^--- FAIL/ { print }`), `test/mutate-driver.bats:306-326`
- `befund`: Gemessen in einer Kopie: Löschung der Zeile `/^--- FAIL/ { print }` lässt `test/mutate-driver.bats` vollständig grün (`1..77`, kein `not ok`). Doku und Kommentar sagen die Go-Zeile zu und nennen den bats-Fall als Halter; der Fall sieht nur `not ok`. Die Go-Stufe ist ein realer Modus von `make test`.
- `verifizierbar`: ja (Kopie, Zeile entfernen, `make test-bats BATS_TARGET=test/mutate-driver.bats`)
- `klasse`: Teil-Zusage ohne eigenen Fall

### LOW-2 — „samt Diagnose" gilt nur für die bats-Form; bei Go zeigt die Meldung die `--- FAIL`-Zeile, nicht deren Ursache

- `kategorie`: LOW
- `quelle`: Plan §1 (Ziel: „die Zeilen, die ihn rot gemacht haben"), `mutate.md`
- `pfad`: `harness/tools/mutate.sh:693-699`
- `befund`: Der Go-Testlauf druckt die Ursache als eingerückte Folgezeilen (`    datei_test.go:N: …`) nach der `--- FAIL`-Zeile; sie gehören nicht zum Muster `^--- FAIL` und stehen nur im Tail, wenn sie unter den letzten zwölf Zeilen liegen. Die Doku formuliert „jede Go-Zeile `--- FAIL`" und ist wörtlich wahr; das Ziel „Diagnose nennen" ist für Go nicht erreicht, und die Grenze in `mutate.md` nennt das nicht. Ein Go-Build-Fehler (`FAIL pkg [build failed]`, keine `--- FAIL`-Zeile) bleibt ebenfalls beim Tail; die Doku führt als Tail-Fall nur den hart beendeten Prozess.
- `verifizierbar`: ja (Lesen des Awk-Programms; Ausgabeform des Go-Testlaufs)
- `klasse`: Zusage in der Doku enger als das Ziel, Grenze nicht benannt

### INFO-1 — Der „Vorher"-Beleg ist am Stub-Log gemessen; Repräsentativität für bats belegt, für Go nicht

- `kategorie`: INFO
- `quelle`: AGENTS.md §3.6 (Fixture gegen reale Quelle)
- `pfad`: `test/mutate-driver.bats:306-326`
- `befund`: Ein realer bats-Lauf (Docker, `make test-bats`, Kopie mit entfernter Zeile) druckt `not ok 18 driver: …` gefolgt von `# (in test file test/mutate-driver.bats, line 323)` und `#   \`grep …\` failed` — dieselbe Form (`^not ok N name`, `^#`-Folgezeilen) wie der Stub. Für Go liegt kein echtes rotes Log im Beleg. Kein Mangel des Slice (Plan §1 nimmt die Ursache aus), aber der Beleg bleibt für Go eine Annahme.
- `verifizierbar`: ja
- `klasse`: Fixture gegen reale Quelle nur teilweise gehalten

### INFO-2 — `make mutate-auswahl` → Exit 10 belegt nichts über den Slice

- `kategorie`: INFO
- `quelle`: MR-090, MR-071
- `pfad`: Implementer-Bericht
- `befund`: Exit 10 ist die vorgesehene Ausgabe des CI-Branch-Wegs (Push-Anweisung, kein Lauf; `harness/README.md` Werkzeuge-Tabelle), weder Probe noch Fehler. Der Slice legt keinen Mutations-Fall an (§1/§3 nennen keinen; der Diff berührt `test/mutations/` nicht), die MR-071-Anlagepflicht greift nicht. Den Zahn des Falls 18 belegt der hier reproduzierte Rot-Beleg, nicht `make mutate`.
- `verifizierbar`: ja
- `klasse`: Werkzeug-Exit ohne Beleg-Gehalt

## Reproduzierter Rot-Beleg (a)

Kopie per `git worktree` unter `~/.colima-tmp` (entfernt), Docker-Weg `make test-bats BATS_TARGET=test/mutate-driver.bats`:

- Unverändert: `1..77`, `ok 18 driver: der abgebrochene Gruen-Vorlauf nennt ein fruehes not ok trotz spaeterer ok-Zeilen`.
- Aufruf `show_failures "$log"` gelöscht: `not ok 18 …` / `# (in test file test/mutate-driver.bats, line 323)` / `#   \`grep -qF 'not ok 2 FRUEHER-FEHLSCHLAG' <<<"$output"' failed` — die behauptete Meldung, rot aus dem richtigen Grund (der Stub druckt 28 `ok`-Zeilen nach dem `not ok`; die letzten zwölf Zeilen enthalten es nicht).
- Zeile `/^--- FAIL/ { print }` gelöscht: 77 Fälle grün (LOW-1).

## Geprüft, ohne Befund

- (b) `show_failures`: Muster `^not ok ` verlangt Zeilenanfang; Diagnose beginnt im TAP-Strom mit `#`, ein „not ok" im Testnamen oder in der Diagnose trifft nicht; der Awk-Block endet an der ersten Nicht-`#`-Zeile; ohne Treffer keine Ausgabe, Exit 0 (die Pipeline endet mit `sed`); der Guard `grep -qE` im `if` trägt unter `set -e`. Ein Zeilenlimit fehlt bewusst (Plan §2); bei vielen Fehlschlägen wächst die Meldung mit ihnen, kein Defekt. Worker-Pfad: `worker_main` leitet `green_prerun` in `prerun.<id>.log` und gibt es bei Abbruch komplett aus; die neue Ausgabe steht im Abbruch-Block in der Reihenfolge Kopf, Fehlschläge, Tail.
- (c) `mutate.md`: nennt die Grenze „Ursache vs. Umgebungsfehler" und „Absturz ohne TAP-Zeile bleibt bei Tail"; Indikativ, keine Chronik oder Befund-Kennung. Offen nur LOW-2.
- (d) Kommentar `show_failures` und der geänderte Absatz über `green_prerun`: Klassen Zusage/Kopplung/Grenze, Indikativ, keine Herkunftserzählung.
- (e) Commit-Zuschnitt: `5b4ac962` berührt drei Arbeits-Dateien, keine Closure-Artefakte (§3.10), keine Norm-Artefakte (§3.8), kein Move (§3.3); `make shell-lint` ohne Ausgabe, keine Suppression (§3.2).
- (§3.5) Keine Lockerung: Der Exit-Test `rc -ne 0` und `return 1` im Abbruch sind unverändert; der Diff fügt nur Ausgabe hinzu, kein Wiederholen, keine Schwelle.
