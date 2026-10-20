# Review slice-mutate-branch-worker-wartet-die-publikation-ab (wellenlos)

**Rolle:** Reviewer · **Diff:** Basis `4c0b56bf` bis `272597fc` (`37b1831f` L1, `d5e182f0` L2, `272597fc` L3) ·
**Geprüft gegen:** Slice-Plan, Architect-Verdikt V-2 (`2026-10-20-welle-sprachprofile-java-python-csharp-architect-verdikt`),
`AGENTS.md` §3.2/§3.6/§3.7/§3.9, `MR-014`, `MR-071`, `MR-089`, `ADR-0058`, `.harness/skills/reviewer.md`.

**Summary:** 0 HIGH · 1 MEDIUM · 2 LOW · 2 INFO. Wiederkehrende Klasse: *Zusage über die Ergebnisdatei nennt nur einen von
zwei Zuständen „ohne Ergebnis"*.

## Findings

### MEDIUM-1 — `grep -c '^FEHLT'` zählt den Fall nicht, den die Pflichtzeile und der Kommentar meinen

- `kategorie`: MEDIUM
- `quelle`: `AGENTS.md` §3.6 (Zusage ohne rot gesehenes Gegenbeispiel), `LH-QA-02`
- `pfad`: `docs/user/releasing.md` Schritt 6 (Pflichtzeile); `harness/tools/mutate.sh:1231`
- `befund`: Die Pflichtzeile sagt, die Ergebnisdatei führe „einen Fall ohne Beleg als `FEHLT`", und liefert die Zahl über
  `grep -c '^FEHLT'`. In `ergebnis_schreiben` (`harness/tools/mutate-auswahl.sh:253-300`) steht `FEHLT` aber nur für einen
  Fall der erwarteten Menge, der in **keiner** Shard-`faelle`-Datei vorkommt (Shard `KEIN BELEG`, Matrix-Lücke). Ein Fall, den
  ein Shard gezogen hat (`faelle` wird in `shard_lauf` vor dem Lauf geschrieben) und der kein `mutate: ok`/`mutate: BEFUND`
  im Log trägt, steht als `BEFUND (kein Ergebnis im Log)` (Zeile 289). Das ist genau der Zustand von Fall 445
  (Worker Status 137 an der Zeitschranke) und, soweit das Log des Vorlaufs fehlt, der der 404-Fälle. Der Befehl der
  Pflichtzeile liefert für diese Klasse 0, und der Satz am `STALL_SECONDS`-Kommentar („Der Fall hat kein Ergebnis … führt
  einen Fall ohne Beleg als `FEHLT`") koppelt den Fall 445 an die falsche Zeilenart. Ein Bericht, der „0 Fälle ohne
  Ergebnis" meldet, ist über dem Ausschnitt grün, den die Zeile erfassen soll. `grep -rn 'kein Ergebnis im Log' test`
  findet keinen Test; kein Sensor bindet die Zeilenart.
- `verifizierbar`: ja (Lesen der Zeilen 285-300; ein Lauf von `ergebnis_schreiben` über einem Shard-Beleg mit `faelle` und
  einem Log ohne Ergebniszeile; nicht gefahren, Lauf braucht git-Push-Stub — Befund aus dem Code gelesen)
- `klasse`: Zusage nennt von zwei Ergebnis-Zuständen einen

### LOW-1 — der `if:`-Zusatz des Warte-Schritts ist von keinem Wächter gebunden

- `kategorie`: LOW
- `quelle`: `AGENTS.md` §3.6 (mehrteilige Zusage, Teil-Grenze ohne bindenden Fall)
- `pfad`: `.github/workflows/mutate-branch.yml:73-74`, `test/mutations/775-…`
- `befund`: Der Kommentar sagt „Ein Tip ohne Lauf wartet nicht" und trägt es allein an `if: steps.lauf.outputs.laufen == 'true'`.
  Test 21-23 prüfen Lage, Trennung von `lauf` und `needs`, nicht die Bedingung. Bruchprobe: die `if:`-Zeile durch
  `- name: w` ersetzt (Schritt läuft unbedingt) lässt 21, 22, 23 grün (gefahren, unten). Ein Ergebnis-Tip (`laufen=false`)
  zahlte damit bis zur Grenze, ohne dass ein Sensor rot wird.
- `verifizierbar`: ja
- `klasse`: Teil-Zusage ohne eigenen Zahn

### LOW-2 — der Kommentar an `STALL_SECONDS` ist das Protokoll eines Laufs und nennt eine Ursache, die die Messung nicht trägt

- `kategorie`: LOW
- `quelle`: `AGENTS.md` §3.7 (Protokoll eines Laufs, Perfekt, nicht auflösbare Herkunft), §3.6
- `pfad`: `harness/tools/mutate.sh:1225-1233`
- `befund`: (a) „im Worker der Mutations-Probe auf `mutate/…-7cc9f961` riss Fall 445 sie … Fall 444 brauchte im selben Lauf 862 s"
  ist ein Lauf-Protokoll im Perfekt; die genannte Quelle (Branch) ist gelöscht und löst in keinem Rang auf; die Beobachtung
  im Register trägt dasselbe als Beleg. Die Plan-DoD (L3) verlangt Fälle und Messort, deshalb nicht HIGH; die
  Beschriftung „Messung dieses einen Laufs" mildert, hebt die Form nicht auf. (b) Der Satz steht unter „NICHT gedeckt: ein Fall,
  der langsamer als die Schranke, aber endlich ist" und ordnet Fall 445 dieser Klasse zu. Status 137 und „kein
  Ergebnis" belegen nur, dass die Schranke fiel — Hänger und langsamer Fall sind daran nicht unterscheidbar. Dass Fall 444
  mit 862 s endlich war, ist ein Hinweis, kein Beleg für 445; „in der CI nahe an der Schranke und darüber" liest sich als
  Befund über die Stille, gemessen ist eine Falldauer. Die Zusagen der Zeilen 1237-1238 (Wert 900 bleibt) hält der Code
  (`git diff` ändert Wert und Schranke nicht).
- `verifizierbar`: nein (Quelle gelöscht)
- `klasse`: Lauf-Protokoll im Kommentar

### INFO-1 — Messwerte im Workflow-Kommentar sind für den Leser nicht nachzufahren

- `kategorie`: INFO
- `quelle`: `AGENTS.md` §3.7 / Plan L1
- `pfad`: `.github/workflows/mutate-branch.yml:61-72`
- `befund`: „Shards starten innerhalb von 2 s (Job-Zeiten zweier mutate-branch-Läufe)" nennt weder Lauf-Kennung noch
  Kommando; ich konnte sie nicht nachfahren (Hauptkontext-Messung). „3 s Wanduhr lokal" ist als lokal beschriftet und gilt
  nicht für den kalten Bild-Pull auf dem Runner (der Schritt zieht das gepinnte Bild im Job `plan`, der Kommentar
  sagt das nicht). Die Zusage „kein Grün-Vorlauf beginnt vor dem Ende" ist über `needs: plan` strukturell wahr; `make ci-lint`
  läuft in `make gates` (unten).
- `verifizierbar`: nein
- `klasse`: Messwert ohne Nachfahr-Kommando

### INFO-2 — Wirkung nicht belegt (benannte Grenze)

- `kategorie`: INFO
- `quelle`: Plan L2, `AGENTS.md` §3.6
- `pfad`: `test/mutate-auswahl.bats:285-312`, `docs/user/releasing.md`
- `befund`: Test 21-23 und Fall 775 halten die Verdrahtung im Text; „wartet ein später veröffentlichtes Release ab" ist
  weder gemessen noch behauptet, der Test-Kopf, Fall 775 und `mutate.md` sagen es. Der Wegwerf-Branch-Lauf mit Grenze 0
  lag mir nicht vor; ich habe ihn nicht bewertet.
- `verifizierbar`: nein
- `klasse`: Wirkung ungemessen, benannt

## Schwerpunkte

1. **Workflow (L1):** Eigener Schritt im Job `plan` hinter `lauf`, `shard` hat `needs: plan` (gelesen, Test 23 und M3 rot). Ortswahl
   `plan` statt je Shard trägt: ein Warten je Shard wäre mehrfach bezahlt, die Shards beginnen erst nach `plan`. Der
   Schritt steht nicht in `lauf`; sein stdout erreicht `$GITHUB_OUTPUT` nicht. Kommentar im Indikativ, ohne Chronik; Befund INFO-1.
2. **Tests 21-23, Fall 775:** Die Tests messen Reihenfolge und Verdrahtung über Text, nicht die Implementierung der Schritte.
   Fall 775: `make mutate-greift` → `761 Fall/Faelle, 761 greifen, 0 Befund(e)`; `MUTATE_CASES=775-mutate-branch-worker-ohne-release-warten
   make mutate` → `1 ok, 0 Befund(e)` (der Fall färbt Test 21 rot; ein `MUTATE_CASES=775` mit bloßer Nummer bricht mit „unbekannter Fall" ab,
   Name ist Pflicht). Eigene Mutationen im Baum, danach `git checkout`, Baum sauber, Test-Lauf `make test-bats BATS_TARGET=test/mutate-auswahl.bats`:
   M1 `release-warten` in die `lauf`-Zeile → 21 und 22 rot; M2 Schritt vor `lauf` → 21 rot; M3 `needs: plan` entfernt → 23 rot;
   M4 `if:` entfernt → alle drei grün (LOW-1); M5 Schritt in den Job `shard` → 21 rot. `# expect:` (Test 21) pinnt die Ursache; Test 22 und 23
   haben keinen eigenen Fall (Plan verlangte einen).
3. **L3:** Wert und Schranke unverändert (`git diff`). `grep -c '^FEHLT'`: Format stimmt für den Teilfall der fehlenden
   Shard-Belege, nicht für den Fall mit Shard ohne Ergebniszeile (MEDIUM-1). Satz in `harness/sensors/mutate.md` trägt die
   Verdrahtung und nennt, dass die Wirkung nicht gehalten ist; konsistent mit dem Code. Kommentar: LOW-2.
4. **Abgrenzungen:** `harness/tools/release-warten.sh` und `harness/tools/mutate-auswahl.sh` stehen nicht im Diff, `STALL_SECONDS`-Wert
   unverändert, keine Hard Rule und kein `MR` — eingehalten.
5. **Grenzen:** Benannt in Workflow-Kommentar, Test-Kopf, Fall 775, `mutate.md`, `releasing.md` („Ein Wächter existiert nicht", Träger Release-Schnitt).

## Negativbefunde

- §3.2 (Suppression), §3.9 (Docker-only): keine Suppression, keine Host-Toolchain im Diff.
- `MR-014`: der Workflow ruft nur `make release-warten`, kein `${{ … }}` im `run:`-Text.
- `MR-071`: der `sed`-Anker von Fall 775 trifft den Quell-Bestand (Fall färbt Test 21 rot, s. o.).
- `MR-089`: keine Laufzeit-Aussage über einen emittierten Lauf im Ziel; die 3-s-Messung ist als lokal beschriftet.
- Grenz-Aufzählung ohne Formen-Probe: Test 21-23 zählen keine Grenzen auf; „gefahren" sind die fünf Mutationen oben, YAML-Form (Flow- statt Block-Schreibweise, `run: |` mit mehreren Zeilen) nur gelesen, nicht gefahren.
- Exklusivität des `# expect:` von Fall 775: der Kopf behauptet keine; die Gegenprobe (Test 21 allein übersprungen) ist nicht gefahren, gelesen ist: Test 22 und 23 färben unter dem Entfernen des Schritts nicht mit (M5-Lauf zeigt 22 und 23 grün).

## Sensoren

`make test-bats BATS_TARGET=test/mutate-auswahl.bats` → `ok 21`–`ok 23`; `make mutate-greift` → 0 Befund(e); `MUTATE_CASES=775-… make mutate` → `1 ok, 0 Befund(e)`;
`make gates` siehe Commit des Reports.
