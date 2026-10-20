# Verifier-Report: slice-traeger-pins-werden-nach-der-publikation-gegen-die-sha256sums-gehalten

- **Rolle:** Verifier (frischer Kontext) · **Datum:** 2026-10-20 · **Gepruefter Stand:** HEAD `0779f3fc` (Basis `3ea59b26`)
- **Bezug:** LH-QA-02, ADR-0058, ADR-0059, ADR-0064, ADR-0066, Architect-Verdikt V-1 (`2026-10-20-welle-sprachprofile-java-python-csharp-architect-verdikt`), Review `2026-10-20-slice-traeger-pins-werden-nach-der-publikation-gegen-die-sha256sums-gehalten`
- **Ergebnis:** alle Liefer-Punkte L1-L3 **bestaetigt**; keine Findings mit Wirkung auf die Abnahme; zwei Hinweise fuer den Planner (unten). Haken und Schliessen sind Planner-Arbeit.

## Gefahren vs. gelesen

- **Gefahren (selbst):** `make traeger-pins-check` am echten `v0.10.0` (Netz, Docker) gruen und mit zwei verfaelschten Nicht-Host-Pins rot; Tag `v9.9.9` (404); `make test-bats` 15/15; drei bewusste Brueche auf einer Kopie ausserhalb des Arbeitsbaums; `make mutate` Fall 774; `make mutate-greift`; `make gates` (siehe Ende).
- **Gelesen (nicht gefahren):** Skript-Kopf und -Koerper, Makefile-Block, `releasing.md` Schritt 2/5/8, `harness/README.md`-Zeile, Sensor-Seite, `.d-check.yml`, Slice-Diff. Das Ergebnis der Mutations-CI-Probe (Branch `mutate/...-0779f3fc`) habe ich **nicht** gelesen; es kommt vom Auftraggeber und ist hier nicht uebernommen.

## DoD-Punkte

### L1 Werkzeug — bestaetigt

- `make traeger-pins-check TAG=v0.10.0` -> `traeger-pins-check: gleich — alle 6 Pins halten gegen die SHA256SUMS von v0.10.0.`, Prozess-Exit 0 (`echo $?` -> 0).
- Verfaelscht `TRAEGER_SHA256_WINDOWS_ARM64=0...01` (Make-Variablen-Override, Makefile unberuehrt): Ausgabe `traeger-pins-check: TRAEGER_SHA256_WINDOWS_ARM64 weicht ab — Pin 0...01, SHA256SUMS von v0.10.0 fuehrt f87b07b4...1002 fuer ai-harness-init-windows-arm64.exe`, dann `Unterschied bei 1 von 6 Plattformen`, `traeger-pins-check: Exit 1`, `make: *** [traeger-pins-check] Error 1`; **Prozess-Exit von make = 2**. Nur diese Plattform genannt.
- Zweite Probe `TRAEGER_SHA256_LINUX_ARM64=0...02`: genau `LINUX_ARM64` genannt, gleiche Exit-Lage.
- `TAG=v9.9.9`: `curl: (22) ... 404`, `SHA256SUMS ... nicht abrufbar (docker Exit 22) — es wurde nichts verglichen`, `traeger-pins-check: Exit 2`, `Error 2` (Klasse 2 des Skripts).
- Zusage-Wortlaut an `make` gemessen: Klasse des Skripts in der Zeile `traeger-pins-check: Exit <N>` (letzte Skript-Zeile, GNU Make schreibt danach), make-Exit immer 2 — Plan, Makefile-Kommentar, `releasing.md`, Sensor-Seite stimmen ueberein (V-1: „Klasse des Skripts steht in der Meldung, nicht im make-Exit"). Beobachtung am Rande: die lokale Make-Meldung traegt `Error <n>` (englische Locale), die Doku nennt `Error <n>` bzw. `Fehler <n>`; stimmt.
- Transport: Skript liest den Bild-Pin aus `traeger-fetch.sh` (kein zweiter Pin), `docker run` im digest-gepinnten Bild, Netz nur an diesem Aufruf; Paarung `awk '$2 == a'` nach Name, 0 oder >1 Treffer = Klasse 2. Alle sechs werden verglichen, bevor das Ergebnis feststeht.

### L2 Waechter ueber der Paarung — bestaetigt (Rot-Beleg nachgetragen)

- `make test-bats BATS_TARGET=test/traeger-pins-check.bats` -> `1..15`, 15 `ok` (Fall 15 „name exakt" und Fall 14 „kein gate" eingeschlossen).
- Bewusstes Brechen auf einer **Kopie** (`git archive HEAD` nach `$HOME/verifycopy`, danach geloescht; Docker/colima teilt `/private/tmp` nicht, ein erster Versuch dort lief gar nicht — ich habe das gelesen und nicht als gruen gewertet):
  - **Paarung nach Position** (Zeile 123 durch `NR == i`): rot Faelle 1 (Exit 0 verlangt), 2, 3, 4 (Plattformnamen), 8, 9, 12, 15 — der gepinnte Fall 1 „gleiche Pins in anderer Zeilenfolge enden mit Exit 0" ist darunter, Ursache wie behauptet.
  - **`$2 ~ a` statt `$2 == a`**: genau Fall 15 „name exakt: ein Fremd-Eintrag, dessen Name den Asset-Namen enthaelt, stoert die Paarung nicht" rot (`status -eq 0` failed), sonst nichts — F-2 des Reviews ist damit am richtigen Grund gedeckt.
  - **Abbruch nach dem ersten Unterschied** (`; break` Zeile 135): rot Fall 2 (`TRAEGER_SHA256_WINDOWS_ARM64 weicht ab` fehlt) und Fall 8; Zusage „alle sechs verglichen, jede abweichende Plattform genannt" haelt.
  - Unveraenderte Kopie (B0): 15 ok.
- Fall 774: `SMOKE_ARTIFACT_TARGET=artifact-host MUTATE_CASES=774-traeger-pins-paarung-nach-position MUTATE_JOBS=1 make mutate` -> `ok 774-... -> paarung nach name rot`, `1 ok, 0 Befund(e)`, `TEILLAUF 1 von 760 — kein Beleg`; Arbeitsbaum danach sauber.
- `make mutate-greift` -> `760 Fall/Faelle, 760 greifen, 0 Befund(e)`.
- Grenze am Ort: Der Wächter haelt allein die Paarungs-Logik ueber nachgebauter `SHA256SUMS` und `docker`-Stub (Skriptkopf, Sensor-Seite §Wächter-Lage). Den realen Pin haelt er nicht, das steht dort benannt.

### L3 Rot an der realen Quelle, Bindepunkt — bestaetigt

- Gruen und rot am echten `v0.10.0` von mir selbst gefahren (siehe L1); die verfaelschten Plattformen sind Nicht-Host (Host darwin-arm64). Die Plan-Form „Probe-Klon" ist durch den Make-Override ersetzt (Auftrag des Aufrufers); der Wert des realen Makefile reist unveraendert im Gruen-Lauf. Der Beleg beider Laeufe in §7 des Slice ist Aufgabe der Closure (Planner), steht dort noch nicht.
- `docs/user/releasing.md`: Schritt 2 auf „fuer die Plattform des Aufrufers `make traeger-fetch` ... Alle sechs Pins haelt `make traeger-pins-check` nach Schritt 5" eingeschraenkt; Absatz nach Schritt 5 vor Schritt 6, in Schritt 8 Meldung nur bei Exit 0 beider Werkzeuge (`traeger-pins-check`, `tap-check`) und mit deren Ausgabezeilen als Beleg; Grenze (kein Bau-gegen-Bau, nicht die Menge der Assets, Wächter haelt nur die Paarung, realer Pin nur durch den Lauf am Release) am selben Ort.
- `harness/README.md` Zeile 92: `kein Gate` in der Zeile selbst, Bindung `LH-QA-02`, `ADR-0059`; `harness/sensors/traeger-pins-check.md` (Vertrag, Grenze, Wächter-Lage); `.d-check.yml` `exempt-targets` fuehrt `traeger-pins-check` (Z. 224, Kommentar Z. 181).
- **(d) `.PHONY` Z. 55:** `traeger-fetch release-warten traeger-pins-check tap-check tap-nachzug vendor-baseline` — drei getrennte Namen, F-1 behoben.
- `grep -c 'd-check:ignore'` im Slice-Plan -> 0.

## Pruefungen 1 bis 3

1. **Sensor gelaufen:** ja (siehe oben; `make gates` am Ende).
2. **Deckt der Sensor die Zusage:** die Exit-Zusage ist an `make` gemessen und an der realen Quelle gelaufen (Rot an `v0.10.0`); die Paarung deckt bats + 774 mit gelesenem Rot der gepinnten Faelle. Nicht gedeckt und so benannt: realer Pin im Dauerbetrieb (nur Lauf am Release-Schnitt), Bau gegen Bau, Menge der Assets, Kanal, der Asset und SHA256SUMS gemeinsam ersetzt.
3. **Plan vs. Code:** Plan §3 „Skript in die `shell-lint`-Liste": das Makefile hat keine Aenderung dort, weil `shell-lint` `harness/tools/*.sh` und `test/mutations/*.sh` per Glob faehrt — das Skript ist gedeckt, der Planwortlaut „Liste" ist nur formal nicht eingetreten (kein Befund). Gebautes ohne Plan: Fall 15 („name exakt") und Fall 14 („kein gate") gehen ueber die Plan-Faelle hinaus, beide gedeckt; Bild-Pin wird per `TRAEGER_IMAGE` ueberschreibbar gelesen (Skriptkopf genannt). Der Diff am Slice-Plan seit der Basis entfernt nur drei `d-check:ignore`-Marker; keine DoD-Aenderung.

## Offene Punkte

- Fuer den **Planner:** §7 braucht die beiden Laeufe (gruen/rot am echten `v0.10.0`) samt Ausgabe als Beleg (DoD L3); die Ausgaben stehen oben. Das Ergebnis der Mutations-CI-Probe fuer `0779f3fc` ist vom Auftraggeber noch einzutragen.
- Fuer den **Architect (Uebergabe laut Plan §1):** Zeile in `AGENTS.md` §3.6 nach der Closure, eigener Commit — nicht Gegenstand dieses Slice.
- Weiter offen (Plan §6, dritter Ausgang): der Sensor laeuft nur, wenn der Release-Schnitt ihn faehrt.
