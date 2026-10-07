# MR-085 — Das Handoff-Gate bindet an einen neuen HEAD, nicht an jedes Turn-Ende

- **Datum:** 2026-10-07
- **Wirksamkeits-Anlass:** slice-stop-hook-bindet-an-den-commit;
  [`ADR-0083`](../../docs/plan/adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)
  Festlegung 7.
- **Geltungsbereich:** der Handoff-Gate in beiden Fassungen —
  [`.claude/hooks/stop-require-gates.sh`](../../.claude/hooks/stop-require-gates.sh) und
  [`harness/tools/record-gates.sh`](../../harness/tools/record-gates.sh) (Dogfood),
  [`internal/emit/templates/enforce/stop-require-gates.sh`](../../internal/emit/templates/enforce/stop-require-gates.sh) und
  [`internal/emit/templates/enforce/record-gates.sh`](../../internal/emit/templates/enforce/record-gates.sh) (emittiert).
  Schärft bzw. lockert den Wächter aus
  [`MR-002`](../conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) und
  [`MR-003`](../conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
  nach `modul-13-quality-gates.md` §Guard-Härtung; beide bleiben aktiv
  ([`MR-046`](../conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht)).
  **Nicht** der PreToolUse-Guard, **nicht** die Hash-Funktion und **nicht** das Format von
  `gates-passed.diffsha`.
- **Ersetzt-Baseline-Regel:**
  [`grundlagen-durchsetzungsschicht.md`](../../.harness/baseline/v6.17.0/regelwerk/grundlagen-durchsetzungsschicht.md#drei-bindepunkte)
  §Drei Bindepunkte, Zeile *Handoff-Gate* — Bindepunkt *„bevor der Agent ‚fertig' meldet"*. Im
  Default bindet er an den Commit; die strenge Lesart bleibt als Schalter.
- **Adaption.** Den Inhalt trägt [`ADR-0083`](../../docs/plan/adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md) Festlegungen 1–6; hier steht die Abweichung, nicht ihr
  Text. (1) **Default:** der Hook blockiert nur, wenn HEAD ≠ gestempelter HEAD **und**
  Inhalts-Hash ≠ Nachweis. (2) **HEAD-Stempel:** `record-gates.sh` schreibt nach dem Hash die
  aufgelöste SHA nach `gates-passed.head` im ignorierten State-Verzeichnis; ein roter Lauf schreibt
  keinen. (3) **Repo ohne Commit:** der Wert `kein-commit`, eng erkannt (ungeborener Zweig **und**
  kein einziger Commit). (4) **Fail-closed:** jeder unerwartete Fehler endet mit Exit 2; fehlt der
  Stempel, gilt der strenge Zweig. (5) **Schalter:** streng, wenn die versionierte Datei
  `.harness/stop-gate-streng` existiert oder `STOP_GATE_STRENG` genau `1` ist; das Werkzeug
  schreibt die Datei nie.
- **Grenze.** Eine „fertig"-Meldung ohne neuen HEAD geht ohne Gate-Lauf durch — das Netz dort ist
  CI auf dem Push. Ohne Stempel (erster Turn nach dem Update) gilt der strenge Zweig, bis der erste
  grüne `make gates` ihn schreibt. Die Rückkehr per `git switch -` oder `git reset --soft` auf den
  gestempelten HEAD gibt frei: zugesagt ist „HEAD gleich geblieben", nicht „kein Commit". Ein
  ungeborener HEAD in einem Repo mit Commits — `git checkout --orphan` mit erhaltenem Baum, oder
  der Hook von außen gegen einen solchen Klon gestartet — endet mit Exit 2, der strengen Seite.
  `git switch --orphan` leert dagegen den Arbeitsbaum samt `.claude/hooks/`; der verdrahtete
  Aufruf findet den Hook nicht und endet mit Exit 127, den Claude Code als nicht blockierenden
  Fehler liest ([`claude-hooks-referenz.md`](../../docs/user/claude-hooks-referenz.md)
  §Exit-Code-Ausgabe) — dort gibt der Stop **frei**. Die
  Restlücke aus `MR-003` (frischer Klon ohne State mit cleanem Tree wird freigegeben) bleibt
  unverändert. Fitness Function, Gegenbeispiele und Mutationsfälle: [`ADR-0083`](../../docs/plan/adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md) §Fitness Function.
- **Begründung.** Die Bindung an jedes Turn-Ende blockiert Rückfrage und Zwischenstand und ist
  strenger als die Baseline-Absicht; der Commit ist der Punkt, an dem Arbeit das Repo verlässt.
  Die Abwägung trägt [`ADR-0083`](../../docs/plan/adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md) §Verglichene Alternativen.
- **Auflösungs-Trigger:** permanent, wie `MR-002`.
