# Verifikation: slice-emittierte-zusage-nennt-was-der-lauf-im-ziel-misst

Rolle: Verifier · Bezug: LH-FA-12, LH-FA-13, LH-FA-15, LH-FA-16, LH-FA-17 · AGENTS.md §3.6
Gegenstand: 3e2d25f5, 8fbd8ea4, 42feef25 (Implementer), c6badd9b (Architect); Stand HEAD. Quellen: Plan, beide Review-Berichte, Diff, Lastenheft.

## Verdikte je DoD-Punkt

**DoD 1 — Kurzbeschreibungen Stufe 3/6, Sicht neu erzeugt: bestätigt.**
- Diff `full-smoke.sh`: beide `e2e_abdeckung`-Aufrufe nennen FA-13/15/16/17-Teilmessung und das Nicht-Gemessene (`tool_response.agentType`, Lesevorschrift).
- `make e2e-abdeckung` → Exit 0, `git status --short` leer (dieselbe Datei). `grep -c 'nur teilweise gemessen' docs/user/e2e-abdeckung.md` → 2.
- `make test-bats BATS_TARGET=test/e2e-abdeckung.bats` → Exit 0, 17 Fälle ok.
- Rot-Beleg: Teilabdeckungs-Text in Scratchpad-Kopie von `full-smoke.sh` gestrichen (8 Diff-Zeilen), Erzeuger im Sandkasten wie der Fall `halter` → `cmp` gegen die committete Datei Exit 1, der Fall wäre rot (Ursache: Abweichung Deklaration/Datei). Fall selbst nicht auf der Kopie gefahren, Aufrufform nachgebaut.
- Grenze (deckt Review F2): wird der Text gestrichen **und** neu erzeugt, bleibt der Fall grün; „Teilabdeckung entfernt → Fall rot" gilt nur ohne Neuerzeugung. Der Inhalt gegen den Stufenkörper wird von keinem Sensor gehalten, nur vom Review gelesen.

**Zählprüfung `rolle_im_ziel` (Teil von DoD 1 / Commit 8fbd8ea4): bestätigt.**
- Isoliert (Scratchpad, Funktion extrahiert, nachgebautes Git-Ziel, realer Träger aus `make host-bin`, Wrapper aus `internal/emit/templates/enforce/span-emit.sh`): 6 Typen → Exit 0, „8 Payloads"; `architect.md` gelöscht → Exit 1, Meldung „LH-FA-15: das Ziel emittiert 5 Rollen-Typ-Dateien, die Quelle fuehrt 6".
- Hinweis: Das Ziel braucht ein Git-Repo, sonst bleibt der Span leer (Nachbau-Eigenschaft, kein Befund).
- Grenze: Stufe nicht im Docker-E2E (`make full-smoke`) gefahren; die Messung deckt nur die Funktion. Gezählt wird die Anzahl, nicht die Namensmenge (Review F4; Namen fängt `rollen_typen_im_ziel`).

**DoD 2 — Regel als Architect-Artefakt in eigenem Commit: bestätigt (mit Vorbehalt).**
- `git show c6badd9b`: AGENTS.md §3.6 trägt Falsch/Richtig-Paar, „Ein Wächter existiert nicht", Anker `· seit slice-emittierte-zusage-nennt-was-der-lauf-im-ziel-misst`; Rolle in der Message. Stand HEAD geprüft, uncommittete AGENTS.md-Änderung ignoriert.
- Vorbehalt: Der Commit berührt zusätzlich `state.md` der Beobachtung (Review F1, §3.8/§3.10-Frage) — offen für Architect/Planner. Der Satz „Den Wortlaut hält allein der Fall … byte-gleich" ist enger zu lesen (Review F2).

**DoD 3 — `make gates`, Review, Closure, Register: bedingt.**
- `make gates` → Exit 0 (ohne Pipe, Datei-Umleitung; Arbeitsbaum sauber).
- Review liegt vor. Closure-Notiz §7, Risiko-Ausgänge, Paarungen stehen noch leer — Planner-Arbeit nach dieser Verifikation.
- Register: `state.md` der Beobachtung `emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` steht auf „verkörpert in AGENTS.md §3.6 (seit slice-…)". Fortschreibung gehört dem Planner (§3.10).

## Weitere Sensoren
- `make doc-trace` → Exit 0, „21 Anforderung(en), 0 Waise(n)"; `make doc-complete` → Exit 0, dieselbe Zeile. LH-FA-13/15/16/17 zeigen „E2E ok" — die Matrix unterscheidet Teil- von Vollmessung nicht (Werkzeug-Aussage, laut Plan außerhalb).

## Findings
- Keine neuen. Review F1 (state.md im Architect-Commit) und F2 (Reichweite des Falls) bestätigt, nicht entschieden.
- Offen, Plan-vs-Code: Stufen 2 und 5 deklarieren FA-13 ohne Teilabdeckungs-Text (Review F3, laut §1 ausgeschlossen) — als eigener Beleg im Register zu führen.
- Negativbefunde: Plan-vs-Code der Kurzbeschreibungen gegen LH-FA-15-Kriterium „Rolle besetzt" stimmt; Gebautes ohne Plan nicht gefunden (Zählprüfung ist in Commit 8fbd8ea4 benannt, vom Plan nicht gefordert, aber durch DoD 1 getragen).
