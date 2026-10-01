# Verifikation slice-e2e-belegt-die-rolle-der-erfassung-im-ziel (2026-10-01)

Rolle: Verifier. Bezug: LH-FA-15, LH-FA-12. Commits: 25d12f62, 811888ea, b591bf8d.

## Verdikte je DoD-Punkt
1. **Funktion `rolle_im_ziel`: bestätigt.** Aus `traeger_im_ziel` gerufen (`full-smoke.sh:1409`, Funktion beider Bootstrap-Varianten, da `traeger_im_ziel` für beide läuft). Isoliert (Scratchpad-Kopie, Ziel nachgebaut aus `internal/emit/templates/agents/*.md` + `enforce/span-emit.sh`, realer Träger aus `make host-bin`): `Rolle im Ziel (tst): 8 Payloads ... (LH-FA-15)`, Exit 0 (6 Rollen-Typen + `general-purpose` + `kein-rollen-typ`). FEHLER-Zweige nennen `LH-FA-15` und die Span-Zeile.
2. **Deklaration + doc-trace: bestätigt.** Stufe 3 und 6 nennen LH-FA-15 (`e2e-abdeckung.md` Z. 22, 25). `make e2e-abdeckung` → `git status --short` leer (committet = Ausgang). `make test` Exit 0 (bats 153/154 abdeckung ok). `make doc-trace`: `LH-FA-15 | ... | E2E | ok`, `21 Anforderung(en), 0 Waise(n)`; `make doc-complete` Exit 0.
3. **Rot-Beleg: bestätigt, beide Seiten von mir selbst gefahren.**
   (a) `RoleFromAgentType`: `return role` → `return ""`, `make host-bin`, Funktion neu: `FEHLER — tst: LH-FA-15: bei agent_type=architect erwartet die Span-Zeile des abgelegten Traegers "agent_role":"architect" (leer = unbekannt, nie rollenlos) — Zeile: [{... "agent_type":"architect","agent_role":"" ...}]`, Exit 1. Quelle per `git checkout` zurück, Träger neu gebaut → wieder grün.
   (b) Erwartung umgekehrt (fremder Typ erwartet besetzt): `FEHLER — tst: LH-FA-15: bei agent_type=kein-rollen-typ erwartet ... "agent_role":"kein-rollen-typ" ...`, Exit 1. (Die Wortlaute des Implementers (a)/(b) lagen mir nicht vor; diese Meldungen sind meine eigenen.)
4. **`make gates`: bestätigt.** Exit 0; Arbeitsbaum danach sauber.

## Bedeutung (Prüfung 4)
- Kriterium „Rolle besetzt": je emittierter Typ `agent_role` == Name — gemessen. „Leer heißt unbekannt": `general-purpose` und fremder Typ → `"agent_role":""` bei anwesendem Feld — gemessen (Feld-Anwesenheit via `grep` auf `"agent_role":""`). Typ-Namen kommen aus den emittierten Dateien, keine Fixture-Liste.
- Nicht gemessen, im Plan §1 ausgeschlossen: Rolle aus `tool_response.agentType`, „nie als general-purpose im Span" für Subagenten, Lesevorschrift, `agent_type` im Haupt-Kontext.

## Findings
- **F1 (mittel, Zusage, Deklaration): bedingt.** Die Kurzbeschreibungen der Stufen 3 („Das gates des Ziels laeuft vollstaendig …") und 6 sind unverändert; Plan §6 Risiko 2 sagt „die Kurzbeschreibung sagt es" (nur *Rolle besetzt* + *abgeleitet, erster Teil*) — das ist nicht umgesetzt. Folge: die Matrix (`doc-trace`: LH-FA-15 = „E2E ok") und die Abdeckungs-Sicht lesen sich als Deckung der ganzen Anforderung; drei Kriterienteile (siehe oben) hat kein E2E. Das Risiko-Ausgang „entfallen" trägt damit nicht. Abhilfe: Kurzbeschreibungen/Funktionskommentar benennen die Teilabdeckung, oder Ausgang als „weiter offen" ins Register. Planner entscheidet (Abnahme-Kriterium, nicht vom Implementer zu ändern).

## Grenzen
- Wrapper und Ziel nachgebaut, nur Träger real; Stufe selbst nicht im Docker-E2E (`make full-smoke`) gefahren.
- Synthetischer Payload belegt nur die Ableitung im Emitter, nicht dass Claude Code `agent_type` so setzt (Register `BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`, 3. Beleg bei Closure → Folge-Slice).

## Negativbefunde
- Plan-vs-Code: kein Gebautes ohne Plan; Produkt-Code `internal/span` nach Rücknahme unverändert. Typ-Namen nicht verdrahtet. Rücknahme-Baum sauber.
