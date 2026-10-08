# Verifikation — Closure-Trigger `welle-erfassungsschicht-im-ziel`

**Rolle:** Verifier · **Gegenstand:** Welle-Closure Schritt 1 (`.claude/commands/close-welle.md`),
Trigger aus §3 der Welle-Datei `docs/plan/planning/welle-erfassungsschicht-im-ziel.md`
· **Commit:** `e66fec9d838a599b7e893e437d38ebcc12c839f3` (HEAD, Baum sauber vor und nach beiden Läufen)
· **Bezug:** `LH-FA-13`

## Verdikte je Trigger-Punkt

- **Alle vier Slices aus §4 liegen in `done/` — bestätigt.**
  `ls docs/plan/planning/done/<slice>.md` für
  `slice-span-traegt-die-fassung-seiner-erfassungsregel`, `slice-agent-role-traegt-nicht-bekannt`,
  `slice-emittierte-feldliste-traegt-verfuegbarkeit-und-aufbewahrung`,
  `slice-107-inhalts-hash-traegt-eine-entscheidung` → alle vier vorhanden.
  `slice-205` steht nicht in §4; er liegt in `done/` mit
  `**Gegenstand:** entfallen: Auftraggeber-Entscheidung vom 2026-10-08 …` (Zeile 288).
- **Keine Datei außerhalb `done/` nennt die Welle im Kopffeld — bestätigt.**
  `git grep -ln '^\*\*Welle:\*\*.*welle-erfassungsschicht-im-ziel' | grep -v '^docs/plan/planning/done/'`
  → leer, rc 1. Innerhalb `done/` fünf Treffer: die vier Slices aus §4 und `slice-205`.
- **`make gates` grün auf HEAD — bestätigt.** Selbst gefahren, rc ohne Pipe:
  `make gates > gates.log 2>&1; echo $?` → `0`. Auszug: `comment-claims: 86 Datei(en) geprueft, 0 Befund(e)`,
  `span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert`.
  Stempel `.harness/state/gates-passed.head` → `e66fec9d…`.
- **`make full-smoke` grün auf demselben Commit — bestätigt.** Direkt nach `gates`, HEAD unverändert
  (`git rev-parse HEAD` vor/zwischen/nach → dreimal `e66fec9d…`, `git status --porcelain` leer):
  `make full-smoke > fs.log 2>&1; echo $?` → `0`. Die Stufen, die das Welle-*Mehr* tragen, melden OK:
  - `Feldliste im Ziel (--lang go) traegt die vier Saetze ueber Verfuegbarkeit und Aufbewahrung.`
  - `Feldliste deckt die Zeile (golang): alle 20 Feldnamen der geschriebenen Span-Zeile haben ihre Zeile in harness/erfassung-feldliste.md.`
  - `Rolle im Ziel (golang): 8 Payloads … ein fremder Typ die Kennzeichnung "nicht bekannt: agent_type" (LH-FA-15).`
  - `OK — golang: … der Hook schrieb einen Span mit voller Pflicht-Spalte …`
- **CI auf dem Commit — grün.** `gh run list --commit e66fec9d…` → Lauf `37794593496` `ci` `success`;
  Jobs `gates`, `smoke`, `full-smoke`, `adr-immutable` je `success`.
- **Closure-Notiz `welle-erfassungsschicht-im-ziel-results.md`** — nicht Gegenstand von Schritt 1
  (Schritt 3, Planner); nicht geprüft.

## Grenze der Deckung

- Die Abdeckungs-Zeilen von `full-smoke` benennen ihre Teilmessung selbst (Stufe ab Zeile 474:
  *„die Erfassung ist nur teilweise gemessen (FA-13: Pflichtfeld-Schlüssel und Feldlisten-Abgleich; …)"*;
  Stufe ab Zeile 464: *„gemessen ist der Text im Ziel, nicht das Verhalten, das er beschreibt"*). Das
  Grün belegt das Zusammenspiel in diesem Umfang, nicht mehr.
- Kein Rot-Beleg gefahren: Schritt 1 prüft den Trigger, keine DoD-Testbehauptung; die Rot-Belege der
  Slices liegen in deren Verifikationen.

## Offene Punkte für den Planner

- `slice-205` (in `done/`, `Gegenstand: entfallen`) trägt weiter `**Welle:** welle-erfassungsschicht-im-ziel`.
  Er hat §4 verlassen (Modul 5, Bedingung 3, erfüllt); die Archivierung in Schritt 4 sammelt nach
  dem `Welle:`-Feld ein und nimmt ihn damit mit. Ob das gewollt ist (Stub mit `Gegenstand:`-Zeile) oder
  das Feld geändert werden muss, entscheidet der Planner vor Schritt 4.

## Ergebnis

Closure-Trigger aus §3 (Slice-Teil und Gate-Teil) **erfüllt** auf `e66fec9d`.
