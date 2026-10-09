# Review-Report: slice-mutate-laeuft-ueber-einen-ci-branch — 2026-10-09

**Review-Art:** Code — gegen Plan und Konventionen
**Gegenstand:** `853db12e`, `b7de7a9a`, `fa950d7a` (Implementer, wellenlos)
**Skill:** `.harness/skills/reviewer.md` @ 2.3.0 · **Modell:** claude-opus-5-5 · **Datum:** 2026-10-09

**Eingangs-Kontext:** Slice-Plan `slice-mutate-laeuft-ueber-einen-ci-branch` §1 · `MR-014`, `MR-071`,
`MR-090` · `LH-QA-01`, `LH-QA-03` · `AGENTS.md` §3 · Vorgaben des Auftraggebers (kein `gh`, Start per
Branch-Push, 10 Shards, Ergebnis im Branch, ≤ 8 lokal) und des Orchestrators (kein Force-Push, Branch
`mutate/<kennung>-<sha8>` je Lauf).

**Summary:** 0 HIGH · 3 MEDIUM · 3 LOW · 2 INFO — Klassen: *Make-Variable ungequotet in Shell-Rezept
(Ref-Injection)* · *Konstante doppelt, eine Richtung still* · *Plan nicht nachgezogen nach
Orchestrator-Entscheidung*.

---

## Findings

### MEDIUM-1 — Ref-Name bricht aus dem Rezept-Quoting aus; die Schreibschritt-Zusage hält nur fürs Skript

- **quelle:** `MR-014`, `AGENTS.md` §3.6 · **klasse:** Make-Variable ungequotet in Shell-Rezept (Ref-Injection)
- **pfad:** `Makefile:275-280` (Rezept `mutate-branch`, `'$(REF)'`), `.github/workflows/mutate-branch.yml:63`
  (`SLICE='${{ needs.plan.outputs.kennung }}'`), Kopf `mutate-branch.yml:12-16`, `harness/sensors/mutate.md` §CI-Branch
- **befund:** Ein gültiger Branch-Name mit `'` setzt Make den Wert wörtlich in `'…'` ein, der Shell-Teil
  dahinter läuft im Job `plan` und im Job `ergebnis` (`contents: write`, Checkout-Token persistiert),
  **bevor** `kennung_aus_ref` prüft. Belegt:
  `git check-ref-format "refs/heads/mutate/x';echo\$\${IFS}INJIZIERT-AUS-DEM-REF;'-12345678"` → gültig;
  `make mutate-branch SCHRITT=lauf REF="<derselbe Name>"` → `ABBRUCH — Ref 'mutate/x' …`, danach
  `INJIZIERT-AUS-DEM-REF`. Dieselbe Klasse trägt `SLICE='${{ … }}'` im Shard-Job (Kennung = `.+` aus dem Ref).
  Keine Rechte-Ausweitung über das Push-Recht hinaus — der Workflow läuft ohnehin in der Fassung des
  gepushten Branch, wer ihn pusht, bestimmt auch die YAML. Die Zusage „bricht ab, wenn der Ref nicht die
  Form … hat, pusht auf genau `refs/heads/<ref>`" hält aber nur für das Skript, nicht für den Weg dorthin,
  und §CI-Branch §Grenze nennt nicht, dass der Branch-Inhalt den Workflow definiert.
- **verifizierbar:** ja (Sonde oben, kein Gate)

### MEDIUM-2 — Shard-Zahl doppelt; wächst die Matrix, fallen Shards still aus dem Urteil

- **quelle:** `AGENTS.md` §3.6 (Stilles-Grün, latent) · **klasse:** Konstante doppelt, eine Richtung still
- **pfad:** `.github/workflows/mutate-branch.yml:58` (Matrix 0–9) gegen `:84` (`SHARDS=10`);
  `harness/tools/mutate-auswahl.sh:249-275`
- **befund:** `ergebnis_schreiben` liest nur `shard-0 … shard-<SHARDS-1>` und zählt die Fallmenge aus
  diesen Belegen; es gleicht sie nicht gegen `faelle_fuer` ab. Wird die Matrix vergrößert, ohne `SHARDS=10`
  nachzuziehen, fehlen die Fälle der zusätzlichen Shards in der Datei und das Urteil bleibt `gruen`.
  Die Gegenrichtung (Matrix kleiner) ist laut (`KEIN BELEG`). Kein Test hält die beiden Werte zusammen.
- **verifizierbar:** nein

### MEDIUM-3 — Plan §1 beschreibt eine Branch-Form, die der Code nicht mehr hat

- **quelle:** `AGENTS.md` §3.10 (Abnahme-Änderung ist Übergabe-Artefakt) · **klasse:** Plan nicht nachgezogen nach Orchestrator-Entscheidung
- **pfad:** Plan §1 *Festlegungen des Schnitts* (Punkte **Branch**, **Ergebnis**, **Lesen und Wegräumen**)
- **befund:** Der Plan nennt `mutate/<slice-kennung>`, `git push -f`, „ein erneuter Push ersetzt den Lauf"
  und das Löschen von `mutate/<slice-kennung>`; der Code führt `mutate/<kennung>-<sha8>`, keinen Force-Push,
  eine `concurrency`-Gruppe je Commit und das Löschen über ein `ls-remote`-Muster. Die Abweichung ist
  vom Orchestrator gesetzt, aber der Prüfmaßstab des Verifiers ist der Plan; ohne Plan-Korrektur durch den
  Planner prüft er gegen eine überholte Festlegung.
- **verifizierbar:** ja (Lesevergleich)

### LOW-1 — Das Urteil der Ergebnisdatei ignoriert den Exit eines Shards

- **quelle:** Maintainability · **klasse:** Beleg-Urteil ohne Lauf-Exit
- **pfad:** `harness/tools/mutate-auswahl.sh:256-275`
- **befund:** `befund` setzt sich nur aus fehlendem `rc` und den Fall-Zeilen; ein Shard mit `Exit ≠ 0`,
  dessen Fälle alle eine `ok`-Zeile tragen, ergibt `Urteil: gruen`. Der Exit steht sichtbar in der
  Shard-Zeile der Datei.
- **verifizierbar:** nein

### LOW-2 — Test-Name sagt dem ganzen Werkzeug zu, was er nur am Urteil misst

- **quelle:** `AGENTS.md` §3.6 · **klasse:** Test-Name behauptet mehr als gemessen
- **pfad:** `test/mutate-auswahl.bats:138` („grenze: das Werkzeug gibt nie einen Force-Push aus"),
  `test/mutations/659-mutate-auswahl-force-push.sh`
- **befund:** Der Test prüft die Ausgabe von `urteil`; der Push in `ergebnis_schreiben` (`:282`) liegt
  außerhalb, und das `sed`-Muster von 659 (`git push origin HEAD:refs`) trifft ihn wegen des `"` nicht.
  §CI-Branch nennt den Refspec des Ergebnis-Jobs korrekt als unbewacht; der Test-Name nicht.
- **verifizierbar:** ja

### LOW-3 — „Fallmenge eines Slice" enthält fremde Commits zwischen Claim und HEAD

- **quelle:** `AGENTS.md` §3.6 (Grenze unvollständig) · **klasse:** Grenze der Auswahl unbenannt
- **pfad:** `harness/tools/mutate-auswahl.sh:93-97`, `harness/sensors/mutate.md` §CI-Branch §Grenze
- **befund:** `git diff <claim> HEAD` umfasst jeden Commit auf `main` nach dem Claim, auch die anderer
  Rollen und Slices — hier `d3d29d5d` und `6e7bccd0` (`git log --oneline 5c54dc7a^..HEAD`). Die Menge
  kann dadurch nur wachsen und die Schwelle überschreiten; §Grenze nennt das nicht.
- **verifizierbar:** ja

### INFO-1 — Keine Station wartet auf das Ergebnis

- **pfad:** `.claude/agents/implementer.md`, `.claude/agents/verifier.md`
- **befund:** Implementer wartet nicht, Verifier liest „einmal, zu Beginn" und meldet eine fehlende Datei
  als Befund. Ob die Datei da ist, hängt an der Dauer des Reviews gegenüber dem CI-Lauf; der Fehler ist laut.

### INFO-2 — `lauf_pruefen` (Überspringen) und `ergebnis_schreiben` haben keinen Test

- **pfad:** `test/mutate-auswahl.bats` (Test-`git` ist ein Stub ohne `diff HEAD^`-Pfad, kein Fall für `ergebnis`)
- **befund:** Die Schleifen-Sperre trägt zusätzlich GitHub selbst (ein `GITHUB_TOKEN`-Push löst keinen
  Workflow aus); die Auswertung der Log-Zeilen ist ungetestet, bricht aber laut (`kein Ergebnis im Log`).

---

## Geprüft, ohne Befund

- **`ci.yml`:** `branches-ignore: ['mutate/**']` plus `tags: ['**']` lässt Branch-Pushes außer `mutate/**`
  und alle Tag-Pushes wie zuvor laufen; `pull_request` trägt keinen Filter und ist unverändert.
- **Push-Ziel und Rechte (ohne Ref-Injection):** `kennung_aus_ref` ist verankert (`^mutate/…-[0-9a-f]{8}$`),
  der Push geht auf `HEAD:refs/heads/$ref` mit dem vollen, geprüften Ref, ohne `--force`; `contents: write`
  steht allein im Job `ergebnis`; `concurrency` je Ref; `lauf` prüft `<sha8>` gegen den Tip.
- **Auswahl:** fehlender Claim → Exit 2; „nicht Vorfahr" kann nicht eintreten, weil `git log` nur die
  Historie von HEAD läuft. Real gefahren: `bash harness/tools/mutate-auswahl.sh urteil slice-mutate-laeuft-ueber-einen-ci-branch`
  → Basis `5c54dc7a` (der `slice-mv`-Commit), 60 Fälle, Exit 10, Branch `…-fa950d7a`.
- **Gewichte:** im Skriptkopf und in §Grenze als Annahme deklariert, Messung genannt — kein Befund.
- **Mutationsfälle 652–659:** treffen das Skript, das Makefile-Rezept und beide Workflows aufrufen.
  `make mutate MUTATE_CASES='655-… 656-… 658-…'` → alle drei `ok`, je mit dem genannten Test rot.
  Nicht gedeckt ist das Rezept selbst (s. MEDIUM-1). 652, 653, 654, 657, 659 gelesen, nicht gefahren.
- **`mutate.yml`:** dieselbe Zuteilung über `--alle`; der entfernte Leer-Shard-Abbruch ist durch den
  Abbruch von `make mutate` ohne `MUTATE_CASES` getragen (`harness/README.md` §Werkzeuge, gelesen, nicht gefahren).
- **Anweisungssätze** (`implement-slice.md`, `agents/implementer.md`, `agents/verifier.md`): nennen Exit 10,
  Branch-Form und Lesebefehl wie das Werkzeug; das Lösch-Muster des Verifiers schließt Kennungen mit
  gleichem Präfix aus; keine Schwellen-Zahl im Anweisungssatz.
- **Hard Rules:** kein Move mit Inhaltsänderung (§3.3), kein Norm-Artefakt nach §3.8 berührt
  (`git show --stat`), keine Inline-Suppression (§3.2), Kommentare beschreiben den Ist-Zustand (§3.7).
