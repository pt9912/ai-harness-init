# Review-Report: slice-reviewer-skills-im-ziel-skip-if-present — 2026-10-07

**Rolle:** Reviewer (Modul 10), frischer Kontext. **Gegenstand:** Commits `d66451f5`, `361455f8`,
`e8126fd0` (Implementer) gegen den Slice-Plan `slice-reviewer-skills-im-ziel-skip-if-present`,
[ADR-0084](../plan/adr/0084-reviewer-skills-im-ziel-skip-if-present.md),
[ADR-0054](../plan/adr/0054-emittierter-commit-traeger-skip-if-present.md) (Meldungsform),
[ADR-0007](../plan/adr/0007-bootstrap-phasen.md) (Teil abgelöst),
[ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md),
[`AGENTS.md`](../../AGENTS.md) §3.6/§3.7.

## Findings

### M-1 — Die emittierte Baum-Aussage zählt die gemeldeten Pfade falsch

- `kategorie`: MEDIUM
- `quelle`: ADR-0084 Festlegung 3; [`AGENTS.md`](../../AGENTS.md) §3.6 (emittierte Zusage)
- `pfad`: `internal/emit/baumaussage.go:302-307`
- `befund`: Der neu geschriebene Satz sagt *„Drei solche Pfade nennt der Lauf"* und *„Für jeden
  anderen schweigt er"*. Der Lauf nennt aber zusätzlich die drei skip-if-present-`.gitattributes`
  (`internal/emit/zeilenenden.go:28-30`, Klasse `SkipIfPresent` mit `meldung`, über
  `writeEnforceFile(…, notice)` in `internal/emit/enforce.go:332` → `writeSkipIfPresentTold`), und
  das bei **jedem** Re-Lauf; das Benutzerhandbuch sagt es richtig (§Klassen, Satz *„Bei
  `.githooks/commit-msg` und den drei `.gitattributes` nennt der Lauf zusätzlich …"*).
  Failure-Szenario: ein Adopter liest im Ziel „drei Pfade, sonst Stille", bekommt beim Re-Lauf
  sechs Zeilen bzw. drei Meldungen zu Pfaden, die die Aussage als stumm deklariert. Die Zahl ist neu
  in diesem Diff (der Plan verlangte nur, die zwei Skills aufzunehmen und den Einzahl-Satz zu
  streichen); `TestBaumAussage_NenntDieGemeldetenPfade` prüft nur die Anwesenheit der drei
  Pfade, nicht die Vollständigkeit der Menge, und wird darum unter dieser Lücke nicht rot.
- `verifizierbar`: ja — Re-Lauf über einem gebootstrappten Ziel, Ausgabe gegen den Absatz.
- `klasse`: emittierte Zusage reicht weiter als im Ziel geschieht

### M-2 — Fitness-Zeile 2 der ADR und ihr Ist-Träger fallen auseinander; der Träger der Abweichung ist nur der Plan

- `kategorie`: MEDIUM
- `quelle`: ADR-0084 §Fitness Function Zeile 2 und §Konsequenzen (Folgepflicht „Selbstprüfung")
- `pfad`: `harness/tools/full-smoke.sh:4074-4139`; ADR-0084 §Fitness Function
- `befund`: Die drei Ziel-Fälle laufen in `make full-smoke`, nicht in `make selbstpruefung`. Die
  Begründung trägt: das Skript fährt keinen Bootstrap
  (`grep -n 'ai-harness-init' internal/emit/templates/enforce/selbstpruefung.sh` → nur der
  Kopfkommentar), ein Re-Lauf ist dort nicht herstellbar; die Messung selbst ist nicht schwächer
  (echter Binär-Aufruf, drei Fälle, Vorlagen-Pfad im Ziel existiert). Aber die ADR ist ab
  `Accepted` immutabel und nennt weiter `make selbstpruefung` als Make-Target der Regel; die
  Abweichung steht allein im Slice-Plan §1, einem Zeitdokument, das nach der Closure archiviert
  wird. Failure-Szenario: ein späterer Leser (Retirement-Check, Verifier einer Folge-ADR) sucht die
  Fitness Function dort, wo die ADR sie nennt, findet sie nicht und hält die Regel für unbewacht —
  oder ein Adopter erwartet, dass die Selbstprüfung seines Ziels die Klasse hält. Ob das
  Werkzeug-Wechsel einer Fitness-Zeile eine Folge-ADR/Index-Notiz braucht oder ob der Plan
  genügt, ist eine Architect-Frage; Übergabe über den Planner an den Architect.
- `verifizierbar`: nein (Zuständigkeitsfrage, kein Gate)
- `klasse`: Fitness-Träger einer Accepted-ADR wechselt ohne ADR-seitigen Zeiger

### I-1 — Zwischen-Commits nicht grün

- `kategorie`: INFO
- `quelle`: Maintainability
- `pfad`: `d66451f5`, `361455f8`
- `befund`: `d66451f5` ist laut Auftrag nicht grün (`make lint`, unparam), die Message von
  `361455f8` beschreibt einen Stand, den `e8126fd0` ablöst. Folgenlos, solange die drei gemeinsam
  gepusht werden (CI prüft die Spitze); ein Einzel-Push von `d66451f5` machte den roten Stand
  zum geprüften.
- `verifizierbar`: ja
- `klasse`: roter Zwischen-Commit im Push

## Negativbefunde

- **(a) `skillWriter`/`skillMeldung`:** byte-gleich → keine Meldung, abweichend → Meldung mit
  Pfad, `skip-if-present` und Vorlage, fehlend → Anlage ohne Meldung — im Go-Test und in der
  full-smoke-Stufe je gefahren. Meldungsform wörtlich die von `writeSkipIfPresentTold`
  (ADR-0054). Vorlagen-Pfad: `".harness/baseline/"+tag+"/templates"` aus demselben `tag`, mit
  dem `templatesDir` die Quelle öffnet — also der Tag des Ziels; full-smoke prüft die Existenz
  der gemeldeten Datei im Ziel. Fehlerpfade: Verzeichnis statt Datei oder unlesbare Datei →
  `skillMeldung` bricht mit `pruefen: …` ab; der konvergente Vorgänger brach an denselben Lagen
  in `writeFileMode` ab — kein neues Verhalten. Die Skill-Vorlagen tragen keinen
  `<Projektname>` (`grep -c 'Projektname' .harness/baseline/v6.17.0/templates/.harness/skills/*.md`
  → 0 / 0), ein Namenswechsel zwischen Läufen löst also keine Meldung aus (Rückführung §4 nicht
  eingetreten).
- **(b) Signatur:** einziger Produkt-Aufrufer `emitAll` (`grep -rn 'emit.Templates(' --include=*.go . | grep -v _test`)
  übergibt `notice` = `stderr` (`cmd/ai-harness-init/main.go:548`), dieselbe Senke wie der
  Commit-Träger; kein `io.Discard` im Produktpfad dieses Diffs (die zwei Bestands-Stellen in
  `commands.go`/`agents.go` liegen außerhalb). Risiko §6 nicht eingetreten.
- **(c) Texte:** `spec/architecture.md` §5 und `ARC-006` (§1, §2) sowie Benutzerhandbuch im
  Ist-Zustand; Befund nur M-1 an der Baum-Aussage.
- **(d) Mutation/Gegenprobe:** `make mutate MUTATE_CASES='53-skills-konvergent 300-observations-readme-clobbert'`
  → `2 ok, 0 Befund(e)`, EXIT 0 (Fall 300: sein `sed`-Anker `write := writeSkipIfPresent`
  trifft die neue Quelle). Gegenprobe Fall 53: Mutation angewandt **und** `t.Skip` allein in
  `TestTemplates_SkillsSkipIfPresent` → `make test-go` EXIT 0, alle Pakete `ok` — der benannte
  Test bindet allein; danach `git checkout --` beider Dateien. Die full-smoke-Stufe misst, was ihre
  Deklaration sagt (Fall „unverändert" liest die Ausgabe des vorherigen Re-Laufs über einem Ziel,
  in dem die Skills schon lagen, und ist durch die Meldung zum Commit-Träger nicht leer);
  `make e2e-abdeckung` → EXIT 0, `git status` leer: `docs/user/e2e-abdeckung.md` byte-gleich.
  `make full-smoke` nicht selbst gefahren.
- **(e) Abweichung:** Begründung trägt, Ort siehe M-2.
- **ADR-0007:** byte-gleich (`git diff 9ffb9986..e8126fd0 -- docs/plan/adr` leer). **ADR-0028:**
  Dogfood-Skill `.harness/skills/reviewer.md` unberührt.
- **§3.7:** neue Kommentare in `templates.go`, `main.go`, Tests und `full-smoke.sh` beschreiben
  die Stelle, ohne Chronik.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 0 |
| INFO | 1 |

Wiederkehrende Klasse: *emittierte Zusage reicht weiter als im Ziel geschieht* (M-1).

## Verdikt

Kein HIGH. M-1 vor Closure an den Implementer; M-2 als Übergabe an den Planner zur Frage an den
Architect.
