# Review slice-archiv-wird-nach-dem-schreiben-gelesen-und-geprueft

**Rolle:** Reviewer · **Datum:** 2026-10-20 · **Diff:** 62fd6c95..1f8e4600 (L1 1ef4781b, L3 559d1b5d, L2 a9fafe34, Lint f0c5b9a8, Docker-Leseprobe 1f8e4600) · **Plan:** `slice-archiv-wird-nach-dem-schreiben-gelesen-und-geprueft` (in-progress, wellenlos) · **Gegen:** ADR-0033, AGENTS.md §3.2/3.3/3.6/3.7/3.9, MR-071, Reviewer-Skill 2.3.0.

## Summary

0 HIGH, 0 MEDIUM, 2 LOW, 2 INFO. Wiederkehrende Klasse: keine neue.

## Findings

1. **LOW** · quelle: AGENTS.md §3.7 · pfad: `test/mutations/772-archiv-zip-abgeschnitten-und-probe-ausgehebelt.sh:9-11` · befund: der Kopf nennt `unzip -tq`; `archiv_gueltig` (`harness/tools/full-smoke.sh:~110`) ruft `unzip -t` und `unzip -lq`. Die Aufrufform im Kommentar stimmt nicht mit dem Code. · verifizierbar: nein (`make comment-claims` prüft nur Sensor-Namen) · klasse: Kommentar nennt eine Aufrufform, die der Code nicht führt.

2. **LOW** · quelle: AGENTS.md §3.6 (mehrteilige Zusage) · pfad: `internal/archive/anwenden.go:~375-380` (Doc von `pruefeArchiv`) · befund: der Kommentar sagt Befund bei „fremdem oder doppeltem Namen" zu. Kein Unterfall von `TestAnwendenBrichtVorDemKuerzenAb` baut ein Zip mit fremdem oder doppeltem Eintrag (vier Fälle: abgeschnitten, Bytes verfälscht, gültig-aber-andere-Bytes, Eintrag fehlt, gelesen am Test). Die zwei Zweige `!erwartet[...]` und `gesehen[...]` können ohne roten Test wegfallen. Praktisch erreichbar nur über einen Schreiber-Fehler, daher LOW. · verifizierbar: ja (Zweig entfernen, `make test`) — von mir nur gelesen, nicht gefahren · klasse: Teil-Grenze einer Zusage ohne bindenden Fall.

3. **INFO** · quelle: AGENTS.md §3.6 · pfad: `test/mutations/772-*.sh`, `773-*.sh` · befund: Beide Fälle brauchen Netz (`full-smoke`); ich habe sie nicht gefahren. Belegt ist nur der Baustein: BusyBox-`unzip -t` im gepinnten `BATS_IMAGE` liefert Exit 1 für ein abgeschnittenes Zip (`short read`), für ein Zip mit verfälschten Datenbytes (`crc error`) und für ein Zip ohne Zentralverzeichnis (`short read`) und Exit 0 für das intakte (Proben über `git archive --format=zip`, nicht über ein von Go geschriebenes Zip mit Data-Descriptor). Ob das Go-Zip ohne `zw.Close()` dieselbe Meldung ergibt, ist damit ungemessen; `# expect: besteht die Leseprobe nicht` setzt es voraus. Träger: der CI-Branch-Lauf, den der Auftraggeber freigibt. · verifizierbar: ja (`make mutate-auswahl` / CI-Branch) · klasse: Fall ohne gesehenes Rot an der realen Quelle.

4. **INFO** · quelle: AGENTS.md §3.6 · pfad: `harness/tools/full-smoke.sh` (dritte Stelle, `fetch_grund`) · befund: ohne Mutationsfall; die Lücke steht am Ort (`harness/sensors/full-smoke.md` Absatz „Leseprobe der Archivierungs-Stufe" und Kopf von 773). Kein Befund, nur festgehalten, dass die Benennung nicht im Skript selbst steht. · klasse: —

## Geprüft, ohne Befund

- **Schwerpunkt 1, `pruefeArchiv`/Abbruch:** Aufruf steht in `inhaltsSchritt` direkt hinter `schreibeZip` und vor `schreibeStubs` und `g.Rm` (`anwenden.go` gelesen). Die Zusage im Doc nennt den Zeitpunkt, nicht die Haltbarkeit. Fehlertexte nennen Archiv und Eintrag. `anwenden(..., schreibeZip)` und `export_test.go` ändern das Produktverhalten nicht (`Anwenden` reicht `Zip` durch, Signatur gleich `zipSchreiber`). Der Test misst den Baum nach dem Abbruch (Original, Report, `rm`, `add`, Commit-Zahl, Zip liegt) und pinnt je Unterfall die Ursache.
- **Eigene Mutation:** `MUTATE_CASES=771-archiv-rueckleseprobe-ausgehebelt make mutate` → `ok  771-… -> TestAnwendenBrichtVorDemKuerzenAb rot`, `1 ok, 0 Befund(e)`. Baum danach sauber. Die Skip-Gegenprobe (zweiter Test mitgefärbt?) habe ich nicht gefahren; im Paket nutzt nur dieser Test den Defekt-Hook (gelesen).
- **Schwerpunkt 2, `archiv_gueltig`:** Docker-only gewahrt (`docker run --network none`, `BATS_IMAGE` aus dem Makefile gelesen, kein neuer Pin, Mount read-only). Fehler sind rot, nie grün: Pin nicht lesbar, Datei fehlt, `unzip -t` rot. Die Kurzbeschreibung in `docs/user/e2e-abdeckung.md` (Stufe 7) bleibt unverändert und behauptet keine Validität; die Grenze „nicht Byte-Gleichheit, Datei bleibt nicht zwingend lesbar" steht im Skript-Kopf und in `sensors/full-smoke.md`.
- **Schwerpunkt 3, Mutations-Fälle:** `make mutate-greift` → `759 Fall/Faelle, 759 greifen, 0 Befund(e)`; die sed-Anker aus 771–773 greifen im Quellbestand. `# expect:` von 771 ist ein Testname, von 772/773 ein Meldungstext der Stufe; `# verify:` passt (`test-go` bzw. `full-smoke`).
- **Schwerpunkt 4, MR-089:** die fünf Commit-Messages tragen keine Laufzeit-, Image- oder Kostenaussage; der Handoff-Text lag mir nicht vor, nicht geprüft.
- **Schwerpunkt 5, Lint:** `git diff 62fd6c95 HEAD | grep -E '^\+.*(nolint|shellcheck disable)'` → keine Treffer.
- **Plan:** L1–L3 im Diff abgedeckt; Rückführungs-Trigger nicht berührt; keine ADR-0033-Festlegung geändert. Keine Slice-Moves und keine Closure im Diff (§3.10).
