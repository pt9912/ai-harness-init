# Review: slice-aktivierung-reist-nicht-mit-dem-klon — Stufe „Aktivierung im Klon"

- **Rolle:** Reviewer (Modul 10, `.harness/skills/reviewer.md`), frischer Kontext
- **Gegenstand:** Commit `0cf73557` (Claim `1063b00c`, `1d46f7b7`, `66800f6e`)
- **Plan:** slice-aktivierung-reist-nicht-mit-dem-klon (in `in-progress/`)
- **Bezug:** [`LH-FA-06`](../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), `AGENTS.md` §3.6/§3.7, `MR-071`
- **Datum:** 2026-10-08

## Zusammenfassung

HIGH 0 · MEDIUM 0 · LOW 0 · INFO 1. Wiederkehrende Klasse: *Mehrteilige Zusage, ein gelisteter Zahn*.

## Findings

### INFO-1 — (c) und (d) der Stufe haben keinen gelisteten Zahn

- `kategorie`: INFO
- `quelle`: `AGENTS.md` §3.6
- `pfad`: `harness/tools/full-smoke.sh:4507-4536`, `test/mutations/588-aktivierung-ohne-traeger-pruefung.sh`
- `befund`: Die Stufe sagt vier Teile zu ((a) unaktivierter Commit, (b) fehlt, (c) Verzeichnis,
  (d) `HOOKS_DIR`); `make mutate` bindet nur (b). Die Prüfungen für (c) und (d) haben Zähne
  (Sonde unten), aber kein Fall in `test/mutations/` hält sie gegen ein späteres Aufweichen.
- `verifizierbar`: ja — ein Fall je Teil unter `make mutate`.
- `klasse`: zusage-nennt-zwei-kanten-der-sensor-deckt-eine

Einordnung nach Skill §LOW/INFO mit Eskalation: INFO, weil die Stufe selbst die Regression meldet
(kein stilles Grün) und der Plan in DoD (3) ausdrücklich nur die `test -f`-Kante als Zahn verlangt.

## Sonden

Nachgebaut im Scratchpad: ein `git init`-Repo mit `harness/mk/hooks-install.mk` (Kopie des
Fragments) und die Schleife (b)–(d) der Stufe mit derselben Prüflogik (host `make`/`git`).

| Fragment | Ergebnis |
|---|---|
| unverändert | (b), (c), (d): rc=2, `core.hooksPath` leer, Zeile `hooks-install: <pfad> liegt nicht …` → alle ok |
| Fall 588 (sed aus dem Fall, gegen den Quell-Bestand: `diff` → genau Zeile 48 entfernt) | (b): rc=2, Ausgabe nur `chmod: … '.githooks/commit-msg' …` → **„keine Zeile nennt .githooks/commit-msg"** = `# expect` |
| Fall 588, Prüfung **ohne** Anker `^hooks-install: ` | (b) grün (die `chmod`-Zeile nennt den Pfad), erst (c) rot mit „aktiviert ohne Traeger-Datei" — `# expect` träfe nicht |
| `test -f` → `test -e` | (c): rc=0, `core.hooksPath=.githooks` → rot „aktiviert ohne Traeger-Datei" |
| Meldung mit festem `.githooks/commit-msg` statt `$(HOOKS_DIR)` | (d) rot an der Pfad-Prüfung („keine Zeile nennt leer-hooks/commit-msg") |

`make e2e-abdeckung` neu erzeugt → `git status --porcelain` leer (Datei byte-gleich mit dem Commit).

## Negativbefunde (geprüft, ohne Befund)

- **Vorbedingungen:** Ziel-Aktivierung, leerer `core.hooksPath` im Klon (`git config --get`, alle
  Ebenen) und Träger als ausführbare Datei werden aus git/Dateisystem gelesen und brechen mit Exit 1 ab.
- **(a)–(d):** jeder Fall prüft rc **und** den aus git zurückgelesenen `core.hooksPath`; (a) liest
  zusätzlich den entstandenen Commit über `git log`.
- **Kurzbeschreibung (`e2e_abdeckung`):** nennt nur Gemessenes; die NICHT-gemessen-Grenze ist wahr —
  Klon-Reise ist Vorbedingung, Dogfood-Rezept nicht gefahren, der `chmod +x`-Zweig in keinem Fall erreicht.
- **Zahn 588:** `sed`-Muster trifft im Quell-Bestand genau eine Zeile (`MR-071`); `# expect` trifft
  die behauptete Ursache (fehlende Träger-Prüfung), nicht irgendeinen Abbruch.
- **Abweichung „Zeilenanfang `hooks-install: `":** gerechtfertigt — ohne den Anker bindet (b) die
  Mutation nicht (Sonde Zeile 3); gelesen wird der Zielname, nicht der Satz der Meldung.
- **§3.7:** neue Kommentare in `full-smoke.sh` und im Fall tragen Zusage/Kopplung/Grenze, keine Chronik.
- **Abdeckungs-Gleichung:** neue Aufrufe in der `if out=…; then rc=0; else rc=$?; fi`-Form.
