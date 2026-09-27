# Review-Report: slice-109-feldliste-jede-aussage-hat-ihre-quelle — 2026-09-27

**Review-Art:** Code — geprüft gegen Plan + Konventionen (Modul 10 §Drei Review-Arten).

**Gegenstand:** Commits `6b83fce9`, `db4575f0`, `0f961841`, `e39940cb`
(Diff-Range `f2d6e466~1..e39940cb`). Die Commits `d0c905e4`/`4130fc42` danach gehören zu
einem anderen Vorgang (Kopplungsform Feldnotiz/Spec) und wurden **nicht** geprüft.

**Skill:** `.harness/skills/reviewer.md` @ 2.2.0 · **Modell:** claude-sonnet-5 · **Datum:** 2026-09-27

**Eingangs-Kontext:**

- `slice-109-feldliste-jede-aussage-hat-ihre-quelle` (Plan, §1 A/B, §2 DoD, §3 Plan, §6 Risiken)
- `LH-FA-10` (§Redaktion, dritter Grenz-Satz)
- `ADR-0022` (Accepted — Festlegung 6 Stück 3, Festlegung 7)
- `spec/spezifikation.md` SPEC-021
- `AGENTS.md` §3 (§3.4, §3.6, §3.7, §3.9, §3.10)

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | LOW | Die neue `program`-Notiz sagt zwei Grenzen in einem Satz zu ("das erste Wort des ausgeführten Segments" und "nie das der ganzen Kommandozeile"); Mutations-Fall 488 bindet nur die exakte Rückkehr zum alten Volltext (Test sucht die Teilzeichenkette "das erste Token der Kommandozeile"), nicht jede Teil-Grenze einzeln — eine Änderung, die nur eine der beiden Hälften bricht (z. B. "nie das der ganzen Kommandozeile" entfernt), bleibt ungebunden. | `AGENTS.md` §3.6 (Reviewer-Skill v2.2.0, Zeile "Mehrteilige Regel-Zusage im Kommentar ohne Mutations-Deckung je Teil") | `internal/span/fieldlist.go:94`, `test/mutations/488-feldliste-program-notiz-widerlegt.sh` | ja — ein gezielter Mutations-Fall, der nur eine Hälfte bricht, würde grün bleiben | Mehrteilige Regel-Zusage ohne Mutations-Deckung je Teil |
| F-2 | INFO | Der neue Test-Kommentar zu `TestFeldliste_ProgramNotizWidersprichtSpecNichtMehr` erzählt, was die **frühere** Notiz behauptete ("die program-Notiz behauptete …"), bevor er den heutigen Wächter-Zustand nennt — nahe an der in `AGENTS.md` §3.7 genannten Falsch-Form "beschreibt abwesenden Text", hier aber funktional nötig, weil der Wächter genau diesen abgelösten Wortlaut als Rückfall-Muster sucht. Kein Blocker, zur Beobachtung. | `AGENTS.md` §3.7 | `internal/span/fieldlist_test.go:149-163` | nein — Stilfrage, kein Gate prüft Kommentar-Klassen | Zustandsform vs. Chronik-Ton in einem notwendig rückfall-benennenden Wächter-Kommentar |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| DoD (1) — `limitStore`-Zutat entfernt, gegen LH-FA-10 §Redaktion und den emittierten Träger geprüft | geprüft, ohne Befund — `make host-bin` in Scratch-Kopie gebaut, `harness/erfassung-feldliste.md` real emittiert: `grep -c 'Arbeitsverzeichnis lesen kann'` → **0**, `grep -c 'nicht zugriffsbeschränkt'` → **1** (Nicht-Zusage bleibt wörtlich stehen) |
| DoD (1) — Entscheidungs-Dokumentation ("Schweigen ist nicht zulässig") | geprüft, ohne Befund — Commit `db4575f0` benennt Grund und Gegenprobe (0600-Modus, `Chmod` in `emit.go`, kein LH-FA-10-Wortlaut trägt die Zutat); keine stille Streichung |
| DoD (2) — neuer Notiztext gegen SPEC-021 und `commandProgram()` | geprüft, ohne Befund über das hinausgehend, was F-1 nennt — "das erste Wort des ausgeführten Segments, nie das der ganzen Kommandozeile" deckt sich mit SPEC-021 und mit `cd /x && make gates` → `program="make"`; die von slice-204 benannten Randfälle V-2/V-3 (Länge, Anführungszeichen-Rand) widersprechen der Notiz nicht — sie betreffen die Grenzen des "ausgeführten Segments", nicht die Kommandozeile als Ganzes |
| Mutations-Fall 488 — Anker gegen Quell-Bestand (MR-071), Kopf-/Anker-Form gegen Nachbarn 476-488, Datei-Modus | geprüft, ohne Befund — `sed`-Anker enthält den heutigen Quelltext genau einmal, Kopf-Form (`# files:`/`# expect:`/Blockkommentar) deckungsgleich mit 476/486/487; `git ls-files -s` zeigt `100644` für 488 **und** für 476/486/487 — kein Modus-Unterschied |
| Mutations-Fall 488 — Teillauf real gefahren | geprüft, ohne Befund — `make mutate MUTATE_JOBS=1 MUTATE_CASES='488-feldliste-program-notiz-widerlegt'` in isolierter Scratch-Kopie: `1 ok, 0 Befund(e)`, `488-feldliste-program-notiz-widerlegt -> TestFeldliste_ProgramNotizWidersprichtSpecNichtMehr rot`; `.harness/state/mutate-passed.key` vorher und nachher nicht vorhanden (Teillauf-Beleg-Slot unberührt) |
| "Grenzen-Aufzählung ohne Formen-Probe" (Skill-Zeile) | nicht anwendbar — der Diff legt keine neue nummerierte/aufgezählte Grenzen-Liste an oder ändert eine (die vierteilige Aufzählung in `TestFeldliste_GrenzeUeberDenBestand`s Docstring ist unverändert im Diff und damit Bestand, nicht Gegenstand dieser Regel) |
| §3.7/§3.6 an neuen Kommentaren/Test-Namen (außer F-2) | geprüft, ohne Befund — Testname `TestFeldliste_ProgramNotizWidersprichtSpecNichtMehr` ist Zustandsform (Präsens), die Mutations-Datei-Kopfzeilen tragen Zusage- und Kopplungs-Klasse (Wächter + Rot-Fall), kein Kommentar bricht mitten im Satz ab, kein Herkunfts-Feld über die zulässige `seit slice-<Kennung>`-Form hinaus |
| §3.8/§3.10 — Diff berührt keine Norm-Artefakte, keinen Slice-Inhalt/DoD-Haken, kein Register, keine ADR | geprüft, ohne Befund — `git diff --stat f2d6e466~1..e39940cb` zeigt außer den fünf slice-mv-Referenz-Nachzügen (b1d46c20, außerhalb des geprüften Implementer-Diffs) nur `fieldlist.go`, `fieldlist_test.go`, den neuen Mutations-Fall und die Roadmap-Ruhe-Marker-Entfernung; `spec/spezifikation.md`, `spec/lastenheft.md`, `harness/tools/full-smoke.sh`, `docs/plan/adr/`, `docs/plan/planning/observations/` unverändert; die Slice-Datei selbst hat 0 Insertionen/Deletionen (reiner `git mv`) |
| Claim/Ruhe-Marker (`6b83fce9`) gegen Vorgänger-Form | geprüft, ohne Befund — Commit-Message- und Diff-Form (Ruhe-Marker-Entfernung in `roadmap.md`) deckungsgleich mit den Vorgänger-Claims `9ab93032` (slice-204) und `e2d433e7` (slice-form-regel…); der erste Move (`f2d6e466`) ist reiner `git mv` (0 Insertionen/Deletionen), `b1d46c20` zieht 5 eingehende Referenzen nach |
| Kommandozeilen-Werkzeuge/Host | geprüft, ohne Befund — kein `go`/`python3` auf dem Host verwendet; Go-Build/-Test ausschließlich über `make host-bin`/`make gates` (Docker) |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** Mehrteilige Regel-Zusage ohne Mutations-Deckung je Teil ·
Zustandsform vs. Chronik-Ton in einem notwendig rückfall-benennenden Wächter-Kommentar

## Verdikt

**Merge-blockierend:** nein — F-1 ist LOW (die ungebundene Hälfte ist praktisch erreichbar,
aber kein Gate-/Sicherheitspfad betroffen; kein Stilles-Grün in einem Gate selbst), F-2 ist
INFO. Beide DoD-Punkte sind gegen Plan, LH-FA-10 und SPEC-021 selbst nachgemessen (Negativbefunde
oben) und stützen die Implementer-Angaben; keine der geprüften Behauptungen war unrichtig.

**Übergabe:** Findings gehen an den Implementer; die Finding-Klassen gehen in die Slice-Closure
§7 und von dort in den Steering-Loop-Zähler. Dieser Report ist ein Lauf-Beleg und ersetzt keine
Verifikation — DoD-/Spec-Konformität (inkl. `make gates`/`make mutate` vollständig, Closure-Notiz,
Risiko-Ausgänge, Register- und Folge-Slice-Paarungen) prüft der Verifier separat (Modul 11).

---

## Selbst gefahrene Prüfungen (Belege)

- `make host-bin` in einer isolierten Scratch-Kopie von `e39940cb` (eigener `git init`, ein
  Snapshot-Commit) gebaut; Träger real ausgeführt (`ai-harness-init --name probe .` gegen ein
  frisches Git-Repo) und `harness/erfassung-feldliste.md` gelesen: `grep -c 'Arbeitsverzeichnis
  lesen kann'` → 0, `grep -c 'nicht zugriffsbeschränkt'` → 1.
- `internal/span/span.go` (`commandProgram()`) gelesen: die Funktion liefert das erste Wort des
  **ausgeführten Segments** nach übersprungenen Zuweisungs-/Navigations-Segmenten — deckt sich
  mit SPEC-021 und mit der neuen Notiz.
- `docs/plan/planning/done/slice-204-das-programm-feld-nennt-das-programm.md` gelesen (V-2, V-3,
  V-4) — keiner der dort benannten Ränder widerspricht der neuen Notiz; beide betreffen die
  Grenzen des Segments, nicht die Kommandozeile als Ganzes.
- `make mutate MUTATE_JOBS=1 MUTATE_CASES='488-feldliste-program-notiz-widerlegt'` in derselben
  Scratch-Kopie gefahren: `1 ok, 0 Befund(e)`, Fall färbt `TestFeldliste_ProgramNotizWidersprichtSpecNichtMehr`
  rot; Beleg-Slot `.harness/state/mutate-passed.key` vorher und nachher nicht vorhanden.
- `git ls-files -s` für `test/mutations/488-*.sh` und die Nachbarn 476/486/487 verglichen:
  alle vier `100644` — kein Modus-Unterschied.
- `make docs-check` im Arbeitsbaum (Stand `4130fc42`, inkl. der zwei fremden Architect-Commits):
  Exit 0, `d-check: 2035 Datei(en) geprüft, 0 Befund(e)`.
- `make gates` im Arbeitsbaum: Exit 0 (alle Teil-Gates grün, u. a.
  `baseline-verify: v6.9.0 OK — 54 Dateien`, `comment-claims: 77 Datei(en) geprueft, 0 Befund(e)`,
  `span-check: Traeger vorhanden, span-emit hat einen Span geschrieben`).
- Stempel vor eigenem Commit geprüft: `.harness/state/gates-passed.diffsha` ==
  `bash harness/tools/working-tree-hash.sh` (beide `5315510841e1bfb523c1fd49f1b8276685770664e4b48698ec569fb328c9d23e`).

**Nur gelesen, nicht ausgeführt:** `spec/spezifikation.md`, `spec/lastenheft.md`,
`harness/tools/full-smoke.sh`, `docs/plan/adr/0022-…`, die Closure-Notiz von slice-204,
die Vorgänger-Claim-Commits `9ab93032`/`e2d433e7` (nur `git show`, keine Ausführung).
