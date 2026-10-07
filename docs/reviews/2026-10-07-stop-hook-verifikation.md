# Verifikation: slice-stop-hook-bindet-an-den-commit

**Rolle:** Verifier (Modul 11) · **Datum:** 2026-10-07 · **Gegenstand:** Implementer `09ac442b` +
`807071ba`, Architect `8e80f1c6` (MR-085), gegen Slice-Plan §2/§3,
[ADR-0083](../plan/adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)
(Festlegungen 1–7, §Fitness Function) und den Review `2026-10-07-stop-hook-review`.
Stichproben statt Vollnachlauf, wo der Review gefahren hat (Mutationsfälle 545–550: dort `6 ok`).

## Verdikte je Liefer-DoD-Punkt

- **1 — Hook und Stempel: bedingt.** Verhalten bestätigt (unten); bedingt allein am Werkzeug:
  DoD und Plan §3 nennen bats, geliefert ist `internal/emit/stophook_test.go` (Review LOW-1, Urteil
  zur Gleichwertigkeit dort: trägt; Übergabe an den Planner fehlt weiter). Den Rot-Beleg für die
  **Dogfood**-Fassung, den kein Mutationsfall trägt (Review INFO-1), trage ich nach (unten).
- **2 — Ziel: bestätigt.** `make full-smoke` → `EXIT 0`; im Log die drei Entscheidungen des echten
  Hooks im Klon des Ziels: `selbstpruefung: STOP FREI — …`, `STOP STRENG — …` (Umgebung **und**
  Datei), `STOP BLOCK — im Default haelt der Stop-Hook einen Commit ohne Nachweis auf.`
  Die Ziel-Deklaration (`selbstpruefung.sh`, `e2e_abdeckung`) nennt die Stop-Hook-Messung; die
  Dogfood-Stufe 29 bleibt bei „prueft seine eigene Durchsetzungsschicht" — umfassend, nicht zu breit.
- **3 — Texte: bestätigt.** `CLAUDE.md`, beide `implement-slice.md`, `plan-welle.md`,
  `close-welle.md` nennen Commit-Bindung, Schalter (Datei + `=1`) und Grenze; nach `807071ba` ist die
  Freigabe ohne Commit an den Stempel gebunden, wie Hook Z. 72–75.
- **Doku-Update (MR-085 + Kopf-Marken MR-002/003): bestätigt**, mit einem Befund zur Grenze (F-1).

## Dogfood-Hook selbst gefahren

`git clone` des Repos in den Scratchpad, Hook mit Eingabe per stdin, `STOP_GATE_STRENG` entfernt;
`record-gates.sh` direkt:

| Lage | Ausgabe | Exit |
|---|---|---|
| frischer Klon, kein Nachweis, sauber | `approve` | 0 |
| Stempel = HEAD, ungedeckte Datei (Turn-Ende ohne Commit) | `approve` | 0 |
| dito, `STOP_GATE_STRENG=true` | `approve` | 0 |
| dito, `STOP_GATE_STRENG=1` | `block` | 0 |
| dito, Datei `.harness/stop-gate-streng` | `block` | 0 |
| `{"stop_hook_active": true}` | `approve` | 0 |
| Commit der ungedeckten Datei ohne Gate-Lauf | `block` | 0 |
| Commit, dessen Inhalt der letzte Lauf deckt | `approve` | 0 |
| Stempel gelöscht, ungedeckte Datei | `block` | 0 |
| Stempel unlesbar (Verzeichnis) | `cat: … Ist ein Verzeichnis` | 2 |
| Nebenzweig-Commit ungedeckt / danach `reset --soft` auf den Stempel | `block` / `approve` | 0 / 0 |
| `git checkout --orphan` in Repo mit Commits | — | 2 |

Alles wie ADR-0083 Festlegungen 1, 4–6 und MR-085 Adaption (1)–(5).

## Rot-Beleg nachgetragen (Dogfood-Fassung)

Klon im Scratchpad, Mutation von Fall 545 auf `.claude/hooks/stop-require-gates.sh` statt auf die
Ziel-Fassung, `make test-go` → Exit 2, genau ein Fehlfall:
`--- FAIL: TestStopHook_CommitBindung/dogfood/neuer_HEAD_ohne_gruenen_Lauf_blockiert` —
`stophook_test.go:164: Hook: erwartet Exit 0 mit "decision": "block", bekommen Exit 0: …` (approve).
Der Dogfood-Zweig des Tests bindet damit den SHA-Vergleich der Dogfood-Fassung; ein dauerhafter
Mutationsfall dafür fehlt weiter (INFO-1 bleibt).

## Plan-vs-Code

- Plan → Code: alle Zeilen §3 geliefert; `test/*.bats` als Go-Test (LOW-1).
- Code → Plan: ungeplant, aber gedeckt — Mutationsfall 550 (full-smoke) über die fünf hinaus; neu
  erzeugte `docs/user/e2e-abdeckung.md` (DoD 2). Kein Norm-Artefakt im Implementer-Commit.
- `.harness/stop-gate-streng` ist weder hier (`git check-ignore -v` → rc 1) noch im Ziel ignoriert
  (`templates/enforce/gitignore` führt nur `state/`); kein Go-Code des Werkzeugs nennt die Datei.

## Findings

### F-1 (LOW) — „`git switch --orphan` endet mit Exit 2" gilt für die Hook-Logik, nicht für den Lauf

- `quelle`: MR-085 §Grenze; ADR-0083 Festlegung 4 (immutabel)
- `befund`: `git switch --orphan` (git 2.43.0) leert den Arbeitsbaum, auch `.claude/hooks/`. Die
  Verdrahtung `bash "$CLAUDE_PROJECT_DIR"/.claude/hooks/stop-require-gates.sh` findet den Hook dann
  nicht (`Datei oder Verzeichnis nicht gefunden`, Exit 127) — nach der Hooks-Referenz kein
  blockierender Code, also Freigabe. Von außen gestartet endet derselbe Hook dort mit 2;
  `git checkout --orphan` (Baum bleibt) ebenso 2. Die Zusage „die strenge Seite" trägt also nur, wo
  der Hook im Baum liegt.
- `adressat`: Architect (Grenz-Zeile MR-085 einschränken); Exit 127 gegen Claude Code ist im Repo
  ungemessen wie Plan-Risiko 1.

## Offene Punkte für den Planner

- LOW-1 (bats → Go) als Plan-Abweichung entscheiden; INFO-1 (kein Dogfood-Mutationsfall) einordnen.
- Risiko 1 (Exit-2-Semantik): Beleg in der vendored Referenz (Review INFO-2), kein Lauf; F-1 berührt es.
- Risiko 2 (Übergang ohne Stempel): Verhalten bestätigt (Zeile „Stempel gelöscht"), Texte nennen es.

## Gates

`make gates` einmal nach dem Commit dieses Berichts (Ergebnis in der Übergabe).
