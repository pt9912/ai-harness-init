# Verifikation: slice-aktivierung-reist-nicht-mit-dem-klon — Stufe „Aktivierung im Klon"

- **Rolle:** Verifier (Modul 11), frischer Kontext — Bericht an den Planner
- **Gegenstand:** Commit `0cf73557` (Arbeit), HEAD `4986c611` (+ Review-Report, sonst gleich:
  `git diff 0cf73557 HEAD --stat` → 1 Datei, der Review-Report)
- **Plan:** slice-aktivierung-reist-nicht-mit-dem-klon (in `in-progress/`), Welle
  welle-adopter-weg-im-ziel
- **Bezug:** [`LH-FA-06`](../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), `AGENTS.md` §3.6
- **Datum:** 2026-10-08
- **Stichprobe:** der Review hat Stufe und Fall vollständig gelesen und (b)–(d) per Sonde
  gebrochen; hier nachgefahren sind nur der gelistete Zahn, der E2E auf HEAD und die
  Abdeckungs-Sicht, der Rest ist Lektüre von Plan und Diff.

## Verdikte je DoD-Punkt

- **(1) Stufe im unaktivierten Klon — bestätigt.** `harness/tools/full-smoke.sh`
  `aktivierung_im_klon`: Vorbedingungen aus git/Dateisystem gelesen (Ziel `core.hooksPath` =
  `.githooks`, Klon leer, Träger `-f` und `-x`), (a) Commit ohne Kennung Exit 0 und `git log -1`
  trägt die Message, (b)–(d) je rc ≠ 0 **und** `git config --get core.hooksPath` leer **und** eine
  Zeile `^hooks-install: ` nennt den Pfad; (d) zusätzlich ohne `.githooks/commit-msg`. Beleg: CI
  `ci` Run `37751930957` auf `4986c611`, Job `full-smoke` success; sein Log trägt
  `full-smoke: Aktivierung im Klon (golang): im unaktivierten Klon geht ein Commit OHNE Kennung durch und entsteht; make hooks-install endet ohne Traeger-Datei, ueber einem Verzeichnis an ihrer Stelle und mit HOOKS_DIR auf ein leeres Verzeichnis mit Exit != 0, nennt den jeweiligen Pfad und laesst core.hooksPath ungesetzt.`
  (`gh run view --job 113227536617 --log | grep 'Aktivierung im Klon'`).
- **(2) Deklaration — bestätigt.** `e2e_abdeckung "LH-FA-06 LH-QA-01" …` direkt unter der
  `echo`-Zeile (`full-smoke.sh:4540-4542`); `make e2e-abdeckung` →
  `e2e-abdeckung: unverändert — docs/user/e2e-abdeckung.md (33 Stufen, 33 Deklarationen).`,
  `git status --porcelain` leer; Zeile *Stufe 31*, Ort `full-smoke.sh:4542`. Kurzbeschreibung nennt
  nur Gemessenes und die Grenze (Klon-Reise = Vorbedingung, Dogfood, Ausführrecht) — gegen den
  Körper gelesen, trifft zu (Risiko 4).
- **(3) Gelisteter Zahn, Rot gesehen — bestätigt (Rot-Beleg nachgefahren).**
  `make mutate MUTATE_CASES=588-aktivierung-ohne-traeger-pruefung` → EXIT 0,
  `mutate: ok 588-aktivierung-ohne-traeger-pruefung -> aber keine Zeile des Ziels nennt .githooks/commit-msg rot`,
  `1 ok, 0 Befund(e)`, 144.86 s. Die `# expect`-Zeile ist die Meldung aus Fall (b), deren Satz die
  behauptete Ursache trägt (*„der Abbruch kommt nicht aus der Traeger-Pruefung"*); der `sed`-Anker
  trifft genau die `test -f`-Zeile des Fragments (`internal/emit/templates/enforce/hooks-install.mk`).
- **`make gates` grün — bestätigt.** CI-Job `gates` success auf `4986c611`; lokal einmal nach
  diesem Bericht gefahren (Commit dieses Berichts).
- **`make full-smoke` Exit 0, Stufe im Output — bestätigt** (s. (1)). Der CI-Lauf auf `0cf73557`
  (`37751633854`) ist `cancelled` (vom Push des Review-Commits abgelöst), nicht rot.
- **Review, kein Self-Review — bestätigt:** `docs/reviews/2026-10-08-aktivierung-im-klon-review.md`,
  0/0/0/1.
- **Doku-Update entfällt — bestätigt:** Diff berührt `harness/sensors/full-smoke.md` und
  `harness/README.md` nicht; beide führen keine Stufen-Liste.
- **Closure-Notiz, Register, Risiko-Ausgänge, Paarungen — offen,** Planner-Arbeit (§3.10); §6/§7
  tragen noch Platzhalter.

## Plan-vs-Code

- **Plan → Code:** alle drei Zeilen der Tabelle §3 umgesetzt (Stufe hinter
  `kennungs_traeger_im_ziel`, Deklaration, Fall 588); `$tmpklon`-Kommentar mitgezogen; Aufrufe in
  der `if out=…; then rc=0; else rc=$?; fi`-Form; Fehler-Zeilen einzeilig. Kein Eingriff in
  `internal/emit/**` (Diff: drei Dateien).
- **Code → Plan:** nichts Ungeplantes. Die übrigen Zeilen von `docs/user/e2e-abdeckung.md` ändern
  nur ihre Zeilennummer (erzeugt).
- **Schluss-Zeile »reist mit dem Klon, seine Aktivierung nicht«:** die Hälfte *Aktivierung nicht*
  hat jetzt ihren Lauf (a); *reist mit* trägt weiter die Selbstprüfungs-Stufe.

## Offene Punkte für den Planner

- **INFO-1 des Reviews bleibt bestehen:** (c) und (d) haben Zähne in der Stufe, aber keinen
  gelisteten Mutations-Fall; DoD (3) verlangt nur (b). Ausgang für die Closure: Register
  `zusage-nennt-zwei-kanten-der-sensor-deckt-eine` oder bewusst stehen lassen.
- **Risiko 3 (Zahn nur nächtlich):** der Rot-Beleg dieses Laufs ist bis zum Nacht-Job der einzige
  — als Ausgang verwendbar.

## Negativbefunde

- Vorbedingungen: lesen den Zustand, statt ihn herzustellen; brechen mit Exit 1 ab — ohne Befund.
- Lesart der Konfiguration: aus git, nicht aus der Meldung — ohne Befund.
- Zusage-Breite: die Stufe behauptet nichts über das Dogfood-Rezept und das Ausführrecht — ohne Befund.
