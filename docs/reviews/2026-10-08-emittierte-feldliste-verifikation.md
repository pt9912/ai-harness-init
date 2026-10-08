# Verifikation: slice-emittierte-feldliste-traegt-verfuegbarkeit-und-aufbewahrung — 2026-10-08

**Rolle:** Verifier (Modul 11) · **Gegenstand:** `294af852`, `eb893ef1` · **Review:**
`docs/reviews/2026-10-08-emittierte-feldliste-review.md` (F-1..F-3 in `eb893ef1`, F-4 an den Planner)
· **Bezug:** `LH-FA-13`, `LH-FA-16`, `LH-QA-01` · **Modell:** claude-opus-5-5

Stichproben statt Vollnachlese: der Review hat den Diff vollständig gelesen und die inhaltliche Wahrheit
der vier Sätze gegen Spec und Code geprüft; nachgemessen sind hier Sensoren, Rot-Belege und die
Plan-vs-Code-Richtung.

## Verdikte je DoD-Punkt

- **Liefer-Punkt 1 — bestätigt (Eigenschaft); Abnahme-Lesart beim Planner (Review F-4).**
  `internal/span/fieldlist.go` trägt die vier Sätze unter `## Verfügbarkeit und Aufbewahrung`, keiner
  gibt ein Datum als Zustand aus. Die Quelle steht als *Werkzeug · Abschnitt · Gegenstand-Zelle* bzw.
  *Titel des Adaptions-Eintrags*, nicht als Kennung. Die Eigenschaft „nennt die Quelle" hält das, sofern
  der Gegenstand die Zeile eindeutig bestimmt: `awk -F' \| ' '/^\| `SPEC-/{print $2}' spec/spezifikation.md | sort | uniq -d`
  → nur `` `agent_role` ``, keine der zitierten Zellen (`Cache-Status (Quelle)`, `Kennzeichnung *nicht bekannt*`,
  `PR-Nummer (Abweichung 2)`, `Haupt-Kontext ohne Zahl (Abweichung 6)`, `Altbestände (Abweichung 4)`).
  Gekoppelt an die reale Quelle sind Gegenstand und Abschnittsnummer (Fälle 608, 609 rot, s. u.); der
  Wortlaut der übrigen Zeile nicht — das sagt der Kommentar seit `eb893ef1` selbst. Eine Kennung löste im
  Ziel nicht auf (`LH-QA-01`), die gewählte Form ist darum nicht schwächer als die im DoD-Text genannte.
  `MR-081` wird nicht genannt: er hebt eine Abweichung auf, es gibt keine zu begründen — der Bezug-Satz
  des Plans („die Abweichungen, deren Begründung die Feldliste nennt") trifft auf ihn nicht zu.
- **Liefer-Punkt 2 — bestätigt.** `MUTATE_CASES='604-… 605-… 606-… 607-… 608-… 609-… 390-…' make mutate`
  → `7 ok, 0 Befund(e)`, EXIT 0; je Fall der benannte Test rot (604 → `…CacheStatusNurAusSubagentImVordergrund`,
  605 → `…PRNummerBewusstNichtImSchema`, 606 → `…HauptKontextTraegtKeineZahl`, 607/608/609 →
  `…BestandNurAusdruecklichGeraeumt`, 390 → `TestFeldliste_OhneMarkdownLink`). Die Meldung je gestrichener
  Wendung und die Gegenprobe (Bindung je Test) hat der Review gefahren; nicht wiederholt.
- **Liefer-Punkt 3 — bestätigt (vom Implementer nicht gefahren, hier nachgetragen).**
  `make full-smoke` → EXIT 0 in 189 s; Zeile `full-smoke: Feldliste im Ziel (--lang go) traegt die vier Saetze
  ueber Verfuegbarkeit und Aufbewahrung.`; die Stufe `feldliste_im_ziel` mit dem geänderten Grenz-Satz
  „Über den Schutz des Bestands ist nichts zugesagt" lief davor grün. **Rot an der realen Quelle:** lokaler
  Klon im Scratchpad, in `internal/span/fieldlist.go` der Kopf `**Der Bestand wird nie nebenbei geräumt.**`
  gestrichen, `make full-smoke` → EXIT 2 mit
  `full-smoke: FEHLER — --lang go: die Feldliste im Ziel fuehrt einen Satz ueber Verfuegbarkeit oder Aufbewahrung nicht: [**Der Bestand wird nie nebenbei geräumt.**]`
  — die behauptete Ursache. `make e2e-abdeckung` → EXIT 0, `git status --short` leer (Sicht byte-gleich);
  Zeile `LH-FA-13, LH-FA-16 … Stufe 3 … harness/tools/full-smoke.sh:466`.
- **`make gates` grün — bestätigt.** `.harness/state/gates-passed.head` = `eb893ef1…` = `git rev-parse HEAD`;
  nicht erneut gefahren, dieser Lauf ändert nur den Bericht.
- **Review — bestätigt.** Report liegt vor, F-1..F-3 in `eb893ef1` behandelt.
- **Doku-Update — bestätigt.** `grep -rln 'fieldlist\|Feldliste' docs/user` → `docs/user/e2e-abdeckung.md`
  (erzeugte Sicht, s. o.). Breiter `grep -rln 'span-clean\|Erfassungsschicht\|erfassung.md\|PR-Nummer' docs/user`
  → zusätzlich `benutzerhandbuch.md` (Zeile 418, `span-clean` nur ausdrücklich — deckungsgleich mit dem
  neuen Satz) und `rollen-laeufe.md`; keines beschreibt das Feldlisten-Dokument, kein Nachzug fällig.
- **Closure-Notiz, Register, Risiko-Ausgänge, Paarungen — offen**, Planner (`AGENTS.md` §3.10).

## Spezifikation unverändert

`git diff --stat 05da44e2 HEAD -- spec/` und `git diff --stat 294af852^ HEAD -- spec/` → leer; letzter
Commit an `spec/spezifikation.md` ist `79e0c4b9` (Vorgänger-Slice). Die Panne im Implementer-Lauf hat
keinen Stand hinterlassen.

## Plan-vs-Code

- **Gebaut ohne Plan-Zeile:** `eb893ef1` formuliert den bestehenden emittierten Grenz-Satz `limitStore`
  von „Über den Bestand ist nichts zugesagt" auf „Über den Schutz des Bestands ist nichts zugesagt" um
  (mit Anker-Nachzug in `internal/emit/fieldlist_test.go`, `full-smoke.sh`, Fall 390) und legt Fall 609 an;
  §3 des Plans führt weder die Datei `internal/emit/fieldlist_test.go` noch 609. Bedeutung: verengt auf das,
  was `LH-FA-16`/Lastenheft-Historie 0.19.0 meint („kein Schutz des Bestands"); löst den Widerspruch zum
  neuen Aufbewahrungs-Satz (Review F-2). Kein Defekt — Nachtrag in §3 ist Sache des Planners.
- **Plan ohne Code:** keiner. Aussage 1 stützt sich auf `SPEC-055`/`SPEC-087` statt `SPEC-024`/`SPEC-087`
  (Plan §1); `SPEC-055` ist die Quellen-Zeile des Cache-Status, `SPEC-024` die Feld-Zeile — sachlich die
  richtige Wahl, in §3 „Fortgeschrieben" nicht genannt.

## Offene Punkte für Planner

- F-4 / Liefer-Punkt 1: Abnahme der Lesart „Gegenstand/Titel statt Kennung" — aus Verifier-Sicht trägt sie
  die Eigenschaft (Eindeutigkeit gemessen, Kopplung rot gesehen).
- Risiko §6/1 (Wortlaut-Abweichung Feldliste ↔ Spec-Zeile): weiter offen, jetzt auch im Code-Kommentar
  benannt; Kandidat für das Register `feldnotiz-traeger-und-spec-koennen-in-der-kernaussage-abweichen-ohne-sensor`.
- Risiko §6/2 (emittierte Zusage weiter als im Ziel): die E2E-Stufe ist gefahren und rot gesehen; sie misst
  den Text im Ziel, nicht das Verhalten — so deklariert.
- Risiko §6/3 (Feld-Bedeutung ohne Fassungs-Angabe): kein Feld, kein Schema, keine Erfassungsregel geändert
  (`git show --stat 294af852 eb893ef1` berührt `internal/span/span.go`, `response.go`, `notknown.go` nicht).

## Negativbefunde

- Kennungs-Freiheit des emittierten Dokuments: nicht separat gemessen; getragen von
  `TestEmittierteDateienTragenNurImZielAufloesendeKennungen` im gestempelten `make gates`.
- Sensoren dieses Laufs: `make mutate` (Teillauf, 7 Fälle), `make full-smoke` (grün und rot), `make e2e-abdeckung`;
  `make gates` nicht, Stempel deckt HEAD.
