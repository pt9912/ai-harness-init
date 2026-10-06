# Review-Report: slice-release-schnitt-v028-loest-den-slice-mv-block — 2026-10-06

**Review-Art:** Code — gegen Slice-Plan, [`releasing.md`](../user/releasing.md),
[`ADR-0058`](../plan/adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md),
[`ADR-0059`](../plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md),
`AGENTS.md` §3, Setzung „Handbuch nur Ist-Zustand".
**Gegenstand:** `77f2d3dd` (Pin, Vorlage, Kopplungs-Test) · `2270efaa` (Benutzerhandbuch).
**Skill:** `.harness/skills/reviewer.md` @ 2.3.0
**Modell:** claude-opus-5-5 · **Datum:** 2026-10-06

## Findings

### F-1 — LOW — Sensor-Datei nennt einen überholten Pin

- `quelle`: [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) / Maintainability
- `pfad`: `harness/sensors/traeger-fetch.md:5`
- `befund`: Die Datei nennt das gepinnte Release `v0.2.1`; der Pin steht nach diesem Diff auf `v0.2.8`.
  Die Prozedur in `releasing.md` (Schritte 1–2) führt diese Stelle nicht, sie wandert darum bei
  keinem Schnitt mit. Nicht im Diff, außerhalb des Plans — **Übergabe an den Planner**, bestätigt
  (Implementer-Fund).
- Beleg: `git grep -n -E 'v0\.2\.[0-7]\b' -- ':!docs/plan' ':!docs/reviews' ':!.harness/baseline'`
  → einzige lebende Pin-Aussage ist `harness/sensors/traeger-fetch.md:5`; alle übrigen Treffer
  sind Test-Fixtures (`TRAEGER_TAG=v0.2.1` per `env`), Beispiele oder §Belegbasis in `releasing.md`.
- Failure-Szenario: ein Leser des Werkzeug-Index folgt dem Link und hält `v0.2.1` für den Stand,
  den `make traeger-fetch` holt.
- `verifizierbar`: nein (kein Gate hält Prosa-Pins gegen das `Makefile`)
- `klasse`: Pin-Aussage außerhalb der Release-Prozedur driftet

### F-2 — INFO — die Kennung der `slice-mv`-Commits trägt bereits das Präfix

- `quelle`: Maintainability
- `pfad`: `internal/emit/templates/enforce/commit-msg-traceability.sh:65`; `docs/user/benutzerhandbuch.md` §Kennungen in Commit-Messages
- `befund`: `named_slice` trifft `slice-mv` am Zeilenanfang selbst; jede Werkzeug-Message
  `slice-mv: …` geht durch, unabhängig vom Dateinamen. Die Handbuch-Aussage („nennen den
  Dateinamen … und tragen damit eine solche Kennung") ist wahr, aber nicht der einzige Grund des
  Grüns; der Hook-Kopf nennt die Klasse allgemein (`"a slice-wise fix" zaehlt`), nicht diesen Fall.
  Der Satz in `hooks-install.mk:27–29` („trägt er keine Kennung …, fällt der Commit") kann für
  `slice-mv` nicht eintreten — Bestand, nicht im Diff.
- Beleg: `bash internal/emit/templates/enforce/commit-msg-traceability.sh <datei mit 'slice-mv: x'>` → Exit 0.
- `verifizierbar`: ja (Probe oben)
- `klasse`: Wortgrenzen-Muster trifft den Werkzeug-Namen

### F-3 — INFO — Handbuch-Zeile `slice-mv` verschweigt die Bindestrich-Grenze

- `quelle`: Maintainability
- `pfad`: `docs/user/benutzerhandbuch.md` §Betriebs-Operationen, Zeile `make slice-mv`
- `befund`: „Nur ohne exakten Treffer gilt ein Präfix" — das Skript nimmt den Präfix nur bis zu
  einer Bindestrich-Grenze (`slice-y` trifft `slice-yz.md` nicht). Unvollständig, nicht falsch;
  der Fehlfall endet mit klarer Meldung „kein Slice".
- Beleg: `quelle_finden` aus `slice-mv.sh` gesourct, Scratch-Baum: `slice-a` → exakte Datei trotz
  `slice-a-b.md`/`slice-a-c.md`; `slice-x` bei zwei Präfix-Treffern → Exit 2 „mehrdeutig";
  `slice-y` gegen `slice-yz.md` → Exit 2 „kein Slice".
- `verifizierbar`: ja
- `klasse`: Anleitung kürzt die Erkennungsgrenze

## Negativbefunde

- (a) Pins: `grep -rn 'v0\.2\.7' Makefile internal test docs/user harness` → leer; Vorlage, Kopplungs-Test und `Makefile` stehen auf `v0.2.8`; der `v0.2.4`-Satz in §Ein geschichtetes Grundgerüst ist Aussage über den damaligen Stand — geprüft, ohne Befund außer F-1.
- (b) Digests: Schleife über die sechs `TRAEGER_SHA256_*` gegen `awk` über `dist/SHA256SUMS` → sechsmal `OK`; `sha256sum -c` und `release-sums.sh verify dist` → Exit 0; im Linux-amd64-Binary steht eingebettet `TRAEGER_TAG ?= v0.2.8` (`grep -a`), der Bau trägt also die gezogene Vorlage — geprüft, ohne Befund. Den Neubau aus dem Commit-Baum fährt der Verifier.
- (c) Handbuch gegen Code: `slice-mv`-Zeile gegen `slice-mv.sh`/`slice-mv.mk` (Move-Commit, Nachzug als zweiter Commit nur bei Anfall, sauberer Baum = keine getrackten Änderungen, exakter Name gewinnt, Mehrdeutigkeit bricht ab, kein Träger/Docker — Rezept ruft `bash` + `git`); `harness/sensors/.gitkeep` emittiert (`enforce.go:163`, SkipIfPresent); Zellenregel gegen den `structure:`-Block der emittierten `d-check.yml` (200/200, `Bindung` ohne Grenze, `structure` in `modules:`, Block am Dateiende) — Rot im Ziel gelesen, nicht gefahren (E2E-Stufe `zellenlaenge_im_ziel` in `full-smoke.sh`); Kennungs-Satz gegen `named_slice=`; Zahlwörter gezählt: Tabelle fünf Zeilen, „zwei der fünf", „Alle fünf", „Von den vier übrigen" stimmen — geprüft, ohne Befund außer F-2/F-3.
- Ist-Zustand: keine Chronik, keine Prognose im Diff; „das veröffentlichte `v0.2.8`" gilt ab Tag-Push, der laut Plan unmittelbar nach dem `main`-Push folgt — geprüft, ohne Befund.
- (d) Abgrenzung: Diff berührt genau die vier Dateien aus Plan §3, kein Funktionsinhalt — geprüft, ohne Befund.
- Hard Rules: keine Suppression, kein Kommentar geändert außer Tag-Wert; ADR-0058 Festlegung 2 (Pin und Vorlage im selben Commit) gehalten — geprüft, ohne Befund.

## Summary

**Finding-Klassen dieses Laufs:** Pin-Aussage außerhalb der Release-Prozedur driftet · Wortgrenzen-Muster trifft den Werkzeug-Namen · Anleitung kürzt die Erkennungsgrenze

## Verdikt

**Merge-blockierend:** nein — kein HIGH, kein MEDIUM.
**Übergabe:** F-1 an den Planner (außerhalb des Plans); F-2/F-3 zur Kenntnis an Implementer bzw. Planner.
