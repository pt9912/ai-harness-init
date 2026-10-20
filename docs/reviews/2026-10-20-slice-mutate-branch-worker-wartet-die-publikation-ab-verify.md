# Verifier-Bericht slice-mutate-branch-worker-wartet-die-publikation-ab

Stand HEAD fd995102 (Basis 4c0b56bf). Rolle Verifier. Gegen DoD, LH-QA-02, ADR-0058, MR-014, MR-091 und Verdikt V-2.
Gefahren = von mir ausgefuehrt; Gelesen = nur am Text/Diff gehalten.

## Verdikte je DoD-Punkt

- **L1 Warte-Schritt: bestaetigt (Verdrahtung), Wirkung nicht belegt.**
  Gelesen: `git diff 4c0b56bf..HEAD -- .github/workflows/mutate-branch.yml` — eigener Schritt `make release-warten` im Job `plan` nach `lauf`, `if: steps.lauf.outputs.laufen == 'true'`, nicht in `lauf`; Ortswahl (einmal im Plan) und Messwert (Shards starten innerhalb 2 s, plan 6-7 s) im Kommentar, Grenze (Runner-Last/kalter Pull ungemessen) benannt. `make ci-lint` (actionlint) Exit 0 (gefahren).
  Messwerte aus dem Kommentar (gh run view ...) von mir nicht nachgemessen (Stichprobe entfaellt: Hauptkontext-Messung 488 s/38 Faelle uebernommen, nicht selbst gefahren).
- **L2 Waechter und Zahn: bestaetigt.**
  Gefahren: `SMOKE_ARTIFACT_TARGET=artifact-host MUTATE_CASES=775-mutate-branch-worker-ohne-release-warten MUTATE_JOBS=1 make mutate` -> `1 ok, 0 Befund(e)` (102 s); dito 776-mutate-branch-warte-schritt-ohne-bedingung -> `1 ok, 0 Befund(e)` (107 s). "ok" heisst: der in `# expect:` gepinnte Test wird rot (Treiber-Semantik, `make mutate`-Kopf gelesen nicht; Ergebnis des Laufs gelesen). Arbeitsbaum danach sauber (`git status --short` leer).
  `make mutate-greift` (mit GNU-sed im PATH): `762 Fall/Faelle, 762 greifen, 0 Befund(e)`. Ohne GNU-sed meldet es 755 Befunde (BSD-sed `-i` der Fall-Skripte) — Host-Umgebung, kein Slice-Befund.
  Test 22 und 23 (nicht in GITHUB_OUTPUT; shard needs plan) haben keinen eigenen Mutationsfall. Gefahren auf Kopien im Scratchpad: Entfernen von `needs: plan` -> die awk-Pruefung liefert Exit 1; `release-warten >> "$GITHUB_OUTPUT"` -> die Pruefzeile von Test 22 erkennt es. Das ist die Logik der Tests, nicht der bats-Lauf selbst; Luecke: kein Mutations-Zahn fuer 22/23 (Plan verlangt nur einen Fall, daher kein Befund).
  Wirkungs-Grenze: Plan verlangt Branch-Lauf mit `TRAEGER_WARTEN_GRENZE=0`. Vom Hauptkontext gemessen (uebernommen, nicht von mir gefahren): Schritt laeuft im Job `plan`, `release-warten: GRENZE ERREICHT ... Grenze 0s`, Job success. Dass der Worker ein spaeter publiziertes Release **abwartet**, ist nicht belegt; Grenze im Plan benannt, §7-Eintrag steht beim Planner aus.
  Der Branch-Lauf lief auf 272597fc; Test 24, Fall 776, Pflichtzeile und Kommentar sind darin nicht enthalten (der Workflow-Schritt selbst ist unveraendert seit L1, `git diff` des Workflows nur L1-Inhalt).
- **L3 Pflichtzeile und Kommentar: bestaetigt (bedingt auf Hinweis unten).**
  Pflichtzeile: `docs/user/releasing.md` Schritt 6. Gegen das Format der echten Ergebnisdatei gehalten: `harness/tools/mutate-auswahl.sh` Z. 288-299 gelesen (`printf '%-8s %-56s Shard %s\n'` mit `BEFUND (kein Ergebnis im Log)`, `echo "FEHLT    $f"`, `echo "Shard $i: KEIN BELEG"`). Gefahren: Eingabe mit `ok`-Zeile, `BEFUND (kein Ergebnis im Log) 445-traeger-... Shard 1`, `BEFUND b` (mit Ergebnis), `FEHLT    c`, `UNERWARTET d`, `Shard 1: KEIN BELEG` -> `grep -cE '^(FEHLT|BEFUND \(kein Ergebnis im Log\))'` = 2, trifft genau die BEFUND-(kein-Ergebnis)-Zeile und die FEHLT-Zeile; `KEIN BELEG`, normales `BEFUND` und `UNERWARTET` zaehlen nicht. Echte Ergebnisdatei nicht gefahren (kein Branch-Lauf; die Zeilenform stimmt mit dem vom Hauptkontext gesehenen Beispiel ueberein); die Zeile benennt diese Grenze selbst.
  Hinweis (kein Befund): ein Fall mit `BEFUND` (Ergebnis im Log, rot) und `UNERWARTET` zaehlen in der Pflichtzeile nicht mit — die Zeile sagt "ohne Ergebnis" und ist damit korrekt eng; der Bericht sollte sie nicht als Gesamtzahl der Befunde lesen. `harness/sensors/mutate.md` nennt den Warte-Schritt am Ort der Grenze (Diff gelesen).
  STALL_SECONDS: `git diff 4c0b56bf..HEAD -- harness/tools/mutate.sh` aendert nur Kommentarzeilen (+9/-1 in Kommentar); Wert 900 und Schranke unveraendert. Der Kommentar steht im Indikativ, nennt Sensor/Beobachtungskennung als Beleg, keine Chronik; er sagt "Ein full-smoke-Fall ... kann sie erreichen" statt Fall 445/444-Zahlen — gegenueber dem Plantext (Fall 445, 862 s) enger, aber wahr. Die 148,97 s "s. oben" nicht nachgemessen.
- **Abgrenzungen: bestaetigt.** `git diff --stat 4c0b56bf..HEAD -- harness/tools/release-warten.sh harness/tools/mutate-auswahl.sh` leer; STALL_SECONDS-Wert unveraendert; Diffstat der 8 Dateien nennt nichts ausserhalb des Plans (Workflow, bats, 2 Faelle, mutate.sh-Kommentar, releasing.md, mutate.md, Slice-Datei). Gebautes ohne Plan: Test 22-24 und Fall 776 (Nachbesserungen aus dem Review, innerhalb L2).
- **Review-Befunde MEDIUM-1/LOW-1/LOW-2/INFO-1:** Zustand am Text bestaetigt (Pflichtzeile nennt beide Zeilenarten; if-Bedingung durch Test 24 + Fall 776 gehalten; Kommentar ohne Branch-Name).
- **`make gates`:** siehe unten.
- Review-/Closure-/Register-/Risiko-/Paarungs-Punkte: Planner-Arbeit, nicht bewertet; keine Haken gesetzt.

## Plan vs Code
- Plan: Warten einmal im `plan`; Code: ebenso. Plan nennt Test "vor dem Vorlauf"; Code haelt Reihenfolge lauf < warten < shard-Job und `needs: plan` (indirekt ueber den Job, GitHub-Ausfuehrung nicht gemessen — im Test benannt).
- Plan §1 nennt "Fall 445 riss die Schranke"; der Kommentar fuehrt es als "kann", ohne Falldaten — kein Widerspruch.
- Nicht belegt: Wirkung "wartet spaeteres Release ab"; Messung "Startzeiten unter Runner-Last"; Nachbesserungen nicht in einer CI-Probe.

## Offene Punkte fuer Planner
1. §7 muss die Wirkungs-Luecke (Grenze 0 belegt nur Laufen und Melden) benennen.
2. Kein Mutations-Zahn fuer die Tests `needs`/`GITHUB_OUTPUT` (nur Logik an Kopien gehalten).
3. Mutate-greift auf Darwin nur mit GNU-sed gruen.
