# Review — Benutzerhandbuch auf den Ist-Zustand (Commit `0ea32fa5`)

- **Gegenstand:** `docs/user/benutzerhandbuch.md`, Commit `0ea32fa5` (Implementer)
- **Bezug:** Auftraggeber-Setzung „Handbuch = Ist-Zustand", [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- **Rolle:** Reviewer, frischer Kontext; Skill `.harness/skills/reviewer.md`
- **Datum:** 2026-10-06

## Findings

### F-1 — MEDIUM — Die Empfehlung für eigene Targets nennt keinen tragfähigen Ort

- `quelle`: Maintainability (Zusage an den Anwender); Kurs v6.16.0 `grundlagen-harness-dateien.md` §Verzeichnisbaum
- `pfad`: `docs/user/benutzerhandbuch.md:227`
- `befund`: Der Satz „Sichern Sie sie vorher und tragen Sie sie danach als eigene Datei ein" nennt keinen Ort. Der emittierte Aggregator (`internal/emit/makefile.go:27`) bindet allein `include harness/mk/*.mk` ein; ein anderer Einhängepunkt existiert nicht, und eine `include`-Zeile in der `Makefile` selbst überschreibt der nächste Lauf (`Makefile()` schreibt bedingungslos). Der einzige funktionierende Ort ist damit `harness/mk/`, den der Kurs als „Make-Fragmente von Werkzeugen" führt und den das Handbuch selbst (Z. 356) als kanonisch, „jedes Mal neu geschrieben" einstuft.
- **Failure-Szenario:** Der Anwender folgt dem Rat, legt die Targets als eigene Datei im Wurzelverzeichnis ab (`make` sieht sie nicht) oder ergänzt eine `include`-Zeile in der `Makefile` — der nächste Re-Lauf, den Z. 203 als „normalen, sicheren Weg" empfiehlt, löscht sie wortlos. Wer `harness/mk/` wählt, folgt einem Ort, den Handbuch und Kurs dem Werkzeug zuschreiben.
- **Gefahren (Scratch-Ziel, Host-Träger aus HEAD):** `Makefile` mit Target `eigen` → Bootstrap `--lang go` → `grep -c eigen Makefile` → `0`, Lauf-Ausgabe nennt `Makefile` nicht (`grep -ci makefile run1.log` → `0`). Danach `harness/mk/eigen.mk` angelegt → `make eigen` → `EIGEN-LAEUFT`; Re-Lauf → Datei bleibt, `make eigen` weiter grün, `make docs-check` → `0 Befund(e)`. Technisch trägt `harness/mk/`, regelseitig ist es der Werkzeug-Ort.
- `verifizierbar`: nein (kein Gate liest Handbuch-Anleitungen gegen den Emitter)
- `klasse`: Anleitung nennt keinen Ort, den das emittierte Ziel trägt

### F-2 — LOW — Eingefügte Ausnahme verkehrt den Bezug des Folgesatzes

- `quelle`: Maintainability
- `pfad`: `docs/user/benutzerhandbuch.md:597`
- `befund`: Die Ausnahme ist vor „ebenso bleiben die anpassbaren mitgelieferten Dateien wie `.d-check.yml` unberührt" eingeschoben; „ebenso" bezieht sich nun auf „sie wird ersetzt … gehen verloren" statt auf „werden nie überschrieben".
- **Failure-Szenario:** Ein Leser der FAQ liest, `.d-check.yml` verhalte sich „ebenso" wie die ersetzte `Makefile`, und sichert sie unnötig oder misstraut der Aussage in Z. 357.
- `verifizierbar`: nein
- `klasse`: Einschub verschiebt den Bezug eines Anschlusswortes

## Negativbefund

- **(a) Gekürzte Zeile 3:** jede gestrichene Ist-Aussage steht weiter im Handbuch — Zielsprachen `go`/`cpp` (Z. 413, 579), `hexagonal` nur Go (Z. 320), idempotenter Re-Lauf (Z. 201, 203, 342 ff.), Mono-Repo per `add-lang` (Z. 263, 426, 454, 591), `driving`/`driven` und `ports_inbound`/`ports_outbound` (Z. 296, 318); geprüft, ohne Befund.
- **(b) Chronik-Stellen** Z. 297, 318, 320, 413, 517, 531/533, 579: neue Fassung gegen Code gehalten — `cpp --arch hexagonal` am Scratch: `unbekannte Architektur "hexagonal"; verfuegbar: flat, hexslice`; Z. 517 bezieht sich auf die direkt darüber beschriebene Form, die emittierte `.d-check.yml` trägt sie (`ADR-([A-Z]+-)?\d{4}`, `slice-`/`welle-`); geprüft, ohne Befund.
- **(c) Makefile-Hinweis als Tatsachen-Aussage:** wahr — `Makefile()` schreibt bedingungslos, Ersetzung und fehlende Meldung am Scratch gemessen (s. F-1); nur die Empfehlung ist Befund.
- **(d) Repo-Kennungen:** `grep -nE 'ADR-[0-9]{4}|MR-[0-9]{3}|LH-[A-Z]{2}-[0-9]{2}|SPEC-[0-9]{3}' docs/user/benutzerhandbuch.md` → kein Treffer, Exit 1.
- **(e) Z. 194 `Baseline v6.13.0`:** gilt für das ausgelieferte `v0.2.8`; der HEAD-Träger meldet am Scratch bereits `Baseline v6.16.0` — ab dem nächsten Release nachzuziehen, kein Befund.

## Gate

`make gates` am Ende des Laufs — Ergebnis im Commit dieses Reports belegt durch den Stop-Hook-Stempel.
