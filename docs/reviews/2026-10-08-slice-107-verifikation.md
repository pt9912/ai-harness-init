# Verifikation: slice-107-inhalts-hash-traegt-eine-entscheidung — 2026-10-08

**Rolle:** Verifier (Modul 11) · **Modell:** claude-opus-5-5 · **Datum:** 2026-10-08

**Gegenstand:** Ausgang (a) — `ADR-0087` (Accepted, `ea669014`) samt Index-Vermerken an `ADR-0011`/`ADR-0022`;
Stand `HEAD` = `710c8edf`. Gegen §2 DoD und §3 Plan des Slice; `LH-FA-14`, `SPEC-018`/`SPEC-029`, `ADR-0011`,
`ADR-0022`. Review-Report `2026-10-08-adr-0087-review.md` (0 HIGH, 1 MEDIUM, 2 LOW, 1 INFO; eingearbeitet in
`d75764fd`).

**Messweg:** Rot-Probe in einer Scratchpad-Kopie per `git clone`, Host-Baum unberührt, `make test-go` dort.
`make gates` nicht gefahren: Stempel `.harness/state/gates-passed.head` = `710c8edf` = `HEAD`, dieser Lauf
ändert nur den Bericht. Den Urteils-Teil von DoD (1) trägt nach Plan der Review; hier Stichprobe der
abgelösten Stellen gegen ihren Wortlaut.

## Verdikte je DoD-Punkt

- **DoD 1 — genau ein Ausgang, am auffindbaren Ort: bestätigt.**
  - Ausgang (a) im Entscheidungs-Stratum (`docs/plan/adr/0087-…`), nicht in `done/`; (b) und (c) nicht
    zusätzlich gewählt — `ADR-0087` §Entscheidung 3: kein Code, keine Spezifikation, Lastenheft unberührt.
  - Die `Supersedes (Teil):`-Zeile trifft jede Stelle, die den Hash an die Ebene bindet, gegen den Wortlaut
    geprüft: `ADR-0011` Z. 100 (Überschrift „Schärfe ist je Ebene verschieden"), Z. 106 (Tabellenzelle
    „im Repo zusätzlich ein Inhalts-Hash"), Z. 142–145 („und ohne Inhalts-Hash", Orakel-Satz), Z. 216
    (F5 „ohne Inhalts-Hash"); `ADR-0022` Z. 498 (F6). `grep -n -i hash` über beide Dateien findet daneben
    nur Gate-Nachweis-Hashes und den sha256-Pin des Fetch — kein weiterer Hash-Satz der Erfassung.
- **DoD 2 — am lebenden Artefakt messbar: bestätigt.**
  - `grep -l 'Supersedes (Teil):.*0011-telemetrie-erfassung-policy' docs/plan/adr/*.md | wc -l` → **1**
    (vorher 0 laut Plan); die Zeile nennt beide abgelösten Sätze (0011 F2/F5, 0022 F6).
  - Index `docs/plan/adr/README.md` Z. 18 und Z. 29: Status-Vermerk „teilweise superseded durch ADR-0087"
    an `ADR-0011` und `ADR-0022`; Z. 94 führt `ADR-0087` als Accepted.
- **DoD 3 — die zwei Accepted-ADRs unangetastet: bestätigt.**
  - `git diff --stat 80b6154a^ HEAD -- docs/plan/adr/0011-… docs/plan/adr/0022-…` → leer.
    Letzter Commit an 0011: `0fb1db82` (Accept), an 0022: `2046fda0` (Accept).

## Fitness Function — Rot-Beleg nachgefahren

- Kopie: `internal/span/emit.go` Z. 166 `s.Sha256Prefix = hex.EncodeToString(...)` durch `_ = h` ersetzt
  (kompiliert weiter, `hex` bleibt in Z. 221 benutzt). `make test-go` → **rc=2**, genau ein `--- FAIL`:
  `TestWriteToolGetsFingerprintFromFilesystem`, `span_test.go:757: sha256_16 = ""`. Meldung und Ursache
  wie in `ADR-0087` §Fitness Function behauptet.
- Die in der ADR benannte Lücke (kein Sensor gegen einen Ebenen-Schalter) steht offen und benannt — keine
  Zusage über den Sensor hinaus.

## Geltende Fassung — widerspruchsfrei

- `LH-FA-14` §Redaktion: „Ableitung (Pfad, Länge, Fingerabdruck)", Bestand ausdrücklich nicht geschützt —
  deckt Grund 2 der ADR.
- `SPEC-018` (`bytes`, `sha256_16` aus dem Dateisystem) und `SPEC-029` (Schreib-Werkzeuge: `path` + `bytes` +
  `sha256_16`) ohne Ebenen-Vorbehalt; Code: `emit.go` Z. 138 `classFileWrite` setzt ihn unbedingt,
  `grep -c 'Ebene' internal/span/emit.go` → 0; emittierte Feldliste `fieldlist.go` Z. 94 führt `sha256_16`.
- Nach der Ablösung sagen Rang 1, Rang 2, Entscheidung und Träger dasselbe. Lebende Artefakte außerhalb der
  ADRs mit „ohne Inhalts-Hash" für die Erfassung: keine (`git grep -i 'Inhalts-Hash'` außer `docs/reviews`,
  `done/`, Baseline — Treffer nur Gate-Nachweis und der Slice-Plan selbst, der den Ist-Stand vor (a) zitiert).

## Plan vs. Stand

- Slice-Commits `80b6154a … 924484e3` berühren nur ADR-0087, ADR-Index, den Slice-Plan, den Review-Report und
  die Roadmap. §3 „unverändert" für `lastenheft.md`, `emit.go`, `fieldlist.go`, `done/` gehalten.
- Roadmap-Änderung in `80b6154a` (Ruhe-Marker → „In Arbeit") weicht vom §3-Eintrag „unverändert" ab; sie ist
  der Marker-Wechsel, den Modul 6 §Offene Wellen beim Anspruch verlangt, keine Inhalts-Änderung — INFO.

## Offene Punkte für den Planner

- Keine Befunde zu Bedeutung, Verhalten oder Zusage. Closure kann DoD (1)–(3) abhaken; §7 nennt für DoD (2)
  den Wert 0 → 1.
