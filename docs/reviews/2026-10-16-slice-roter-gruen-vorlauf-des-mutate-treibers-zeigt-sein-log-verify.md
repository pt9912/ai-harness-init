# Verifikation slice-roter-gruen-vorlauf-des-mutate-treibers-zeigt-sein-log (HEAD ef34622a)

Rolle Verifier. Frage: bauen wir es richtig, gegen Plan und DoD. Diff `5b4ac962^..ef34622a`: `harness/tools/mutate.sh` (`show_failures`,
Aufruf in `green_prerun`), `test/mutate-driver.bats` (zwei Fälle), `harness/sensors/mutate.md` (Abschnitt „Meldung eines roten Grün-Vorlaufs“),
die Slice-Datei. `test/mutations/` unberührt (`git diff --stat` leer), 653 Fälle. Closure, Register, Paarungen und Häkchen sind Planner-Arbeit
(`AGENTS.md` §3.10). Von Hand gebrochen in einem `git worktree` unter `~/.colima-tmp` (danach entfernt).

## Verdikte je DoD-Punkt

- **D1 Meldung nennt jede Fehlschlag-Zeile samt Diagnose, nicht auf zwölf begrenzt — erfüllt, eingeschränkt auf bats.**
  - `show_failures` (awk): bats `not ok` + folgende `#`-Zeilen, Go `--- FAIL`; Aufruf nur, wenn `grep -qE '^(not ok |--- FAIL)'` trifft.
  - Wortlaut §2 verlangt „jede fehlgeschlagene Zeile (`not ok`) samt Diagnose“: das hält der Code für bats. Go zeigt nur die `--- FAIL`-Zeile
    (Folgezeilen/Ursache bleiben beim Tail) — mehr als §2/§1 verlangt, und Kommentar wie `mutate.md` benennen die Grenze.
- **D2 Rot gesehen — erfüllt (selbst gefahren).**
  - Unverändert: `make test-bats BATS_TARGET=test/mutate-driver.bats` → `1..78`, alle ok (Fälle 18/19 ok).
  - (a) Aufruf `show_failures "$log"` gelöscht → `not ok 18 … nennt ein fruehes not ok trotz spaeterer ok-Zeilen`,
    `` `grep -qF 'not ok 2 FRUEHER-FEHLSCHLAG' <<<"$output"' failed `` (Zeile 323) — behaupteter Grund. Fall 19 fällt mit (Guard-Grep ohne Ausgabe).
  - (b) nur den Go-Zweig `/^--- FAIL/ { print }` gelöscht → ausschließlich `not ok 19 … Go-Fehlschlagzeile …`
    (`grep -qF -- '--- FAIL: TestX (0.00s)'` failed, Zeile 348); Fall 18 bleibt ok. Der Go-Fall misst also den Zweig selbst.
  - Der „alte `tail -n 12`“-Zustand ist damit abgedeckt: die Meldung der alten Fassung (siehe D4) enthält das `not ok` nicht.
- **D3 `make gates` grün — erfüllt.** `make gates` Exit 0 auf HEAD; `d-check: 2737 Datei(en) geprüft, 0 Befund(e)`; `.harness/state/gates-passed.head`
  == `git rev-parse HEAD` == `ef34622aa14814860adc5bda53f981a796dfa1a5`; `git status --short` leer.
- **D4 (Review liegt vor)** — Report `docs/reviews/…` aus `cb60d28f` existiert; Inhalt nicht Gegenstand dieses Berichts. Closure-Punkte offen (Planner).

## Die Aussage „vorher/nachher“

- Reales `green_prerun` beider Fassungen (`git show 5b4ac962^:harness/tools/mutate.sh` vs. HEAD), gleicher `make`-Stub
  (`1..30`, `ok 1`, `not ok 2 FRUEHER-FEHLSCHLAG`, `# DIAGNOSE-A`, `ok 3`..`ok 30`, Exit 1):
  - alt: „Die letzten Zeilen von make test:“ + `ok 19`..`ok 30` — kein `not ok`, keine Diagnose.
  - neu: „Die Fehlschlaege von make test (jedes 'not ok' samt Diagnose, jedes '--- FAIL'):“ + `| not ok 2 FRUEHER-FEHLSCHLAG`, `| # DIAGNOSE-A`,
    danach unverändert dieselben zwölf `ok`-Zeilen.
- **Ehrlich:** der Stub ist kein echter CI-Lauf; er belegt die Form der Meldung, nicht dass der echte Fehlschlag oben im Log steht.
- Echtes Log: Run 38865723125, Job `mutate (2)`: Meldung `Gruen-Vorlauf 'make test-bats' ist in SEINER Kopie ohne Mutation rot` mit nur
  `ok 524..533` im Tail; `gh run view … --log | grep 'not ok'` für den Job liefert **keine** Zeile. Die Annahme „das `not ok` steht oben im
  bats-Output“ ist damit **nicht bestätigt, nicht widerlegt** (der Tail ist alles, was das Log hält; Hart-beendet-Prozess ebenso möglich —
  §6 Risiko 1 führt das als weiter offen). Der Slice liefert Sicht für den nächsten roten Lauf, keine Ursache (§5).

## Treiber-Verhalten und Gates

- `git diff 5b4ac962^ ef34622a -- harness/tools/mutate.sh`: `if [ "$rc" -ne 0 ]` und `return 1` im Abbruch unverändert (nur Kontextzeilen);
  neu ist allein der bedingte Block vor `show_tail`. Grün-Vorlauf bleibt hart.
- `make shell-lint` läuft in `make gates` grün; `grep 'nolint\|shellcheck disable' harness/tools/mutate.sh` leer (§3.2).
- `make mutate-greift`: `653 Fall/Faelle, 653 greifen, 0 Befund(e)`.
- `make mutate-auswahl` ohne `SLICE=` → „keine Slice-Kennung“ (Exit 2); mit `SLICE=<Kennung>` → „CI-Branch … mutate/…-ef34622a“, `Error 10`, kein Push.
  **Nicht belegt dadurch:** dass irgendein Mutations-Fall `mutate.sh` hier deckt — der Slice legt keinen Fall an (§1/§2 verlangen keinen;
  `test/mutations/` unberührt), MR-071 greift nicht. Die Zähne tragen allein die zwei bats-Fälle (Rot oben selbst gesehen). Es gibt keinen
  CI-Branch-Befund zu lesen und keinen Branch zu löschen (`git ls-remote origin 'refs/heads/mutate/*'` leer).

## Ausschlüsse §1 (Plan-vs-Code)

- Kein Wiederholungslauf, kein Artefakt-Upload (`.github/` nicht im Diff), keine Änderung an Tag-Kollision oder Klassifikation; Docker-Aussetzer
  wird nicht von Test-Fehlschlag unterschieden — `mutate.md` sagt das ausdrücklich. Gebautes ohne Plan: der Go-Zweig samt Fall (nach Review
  LOW-1) — §2 nennt nur `not ok`; vertretbar als Teil von „Fehlschlag-Zeilen“ (§1 Ziel), nicht im Wortlaut von D1.

## §3.6/§3.7 der Doku

- `mutate.md` und der Kommentar an `show_failures` sagen nur, was der Code hält: bats `not ok`+`#`-Diagnose, Go nur `--- FAIL`, Build-Fehler,
  hart beendeter Prozess, Sensor ohne TAP → Tail; keine Ursache, kein Umgebungs-/Testfehler-Unterschied. Indikativ, keine Befund-Kennung/Chronik.
- Reviewer-LOW-1 (Go-Zweig ungebunden): behoben, Fall 19, Rot (b) gesehen. LOW-2 („samt Diagnose“ nur bats): behoben in Kommentar und `mutate.md`.

## Befunde / offen für Planner

- Kein blockierender Befund. Offen: (1) echte Ursache des Runner-Rots weiter unbelegt (Beobachtung der Folgezeit, §5); (2) ob das `not ok`
  im echten Log steht, zeigt erst der nächste rote Lauf; (3) Docker-Tag-Kollision/Fehlklassifikation bleiben §6-Beobachtungen.
