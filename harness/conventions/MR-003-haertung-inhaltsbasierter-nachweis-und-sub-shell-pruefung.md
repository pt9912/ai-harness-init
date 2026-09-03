# MR-003 — Härtung: inhaltsbasierter Nachweis und Sub-Shell-Prüfung

- **Datum:** 2026-06-13
- **Geltungsbereich:** [`harness/tools/working-tree-hash.sh`](../../harness/tools/working-tree-hash.sh), [`.claude/hooks/`](../../.claude/hooks/)
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  und er setzt keine Abweichung: beide Härtungen sind die Baseline-Regel selbst. Der
  inhaltsbasierte Nachweis ist Design-Eigenschaft 2 aus
  [`grundlagen-durchsetzungsschicht.md`](../../.harness/baseline/v5.18.0/regelwerk/grundlagen-durchsetzungsschicht.md#vier-design-eigenschaften)
  — *„Nachweis über Inhalt, nicht Diff. Ein Content-Hash des Arbeitsbaums belegt ‚die Gates liefen
  auf genau diesem Stand'"* —, die rekursive Sub-Shell-Prüfung ist
  [`modul-13-quality-gates.md`](../../.harness/baseline/v5.18.0/regelwerk/modul-13-quality-gates.md#guard-haertung)
  §Guard-Härtung: *„wird der Payload **rekursiv** derselben Prüfung unterworfen — mit Tiefenlimit,
  darüber fail-closed blockiert"*. Auch die stehengelassene Restlücke ist keine Abweichung, sondern
  die dort benannte Grenze (*„frischem Klon bzw. gelöschtem State mit cleanem Tree … dort ist CI
  das Netz"*). Gemessen am adoptierten Stand `v5.12.0`.
- **Adaption:** (a) Der Working-Tree-Hash ist **inhaltsbasiert** (sha256
  über getrackte + untracked Dateien) statt diff-basiert — der Gate-Nachweis
  gilt über Commits hinweg; ein Commit *ohne* Gate-Lauf macht den Stop-Hook
  nicht grün. Restlücke: frischer Klon bzw. gelöschter `.harness`-State mit
  cleanem Tree wird freigegeben (CI ist dort das Netz). (b) Der
  PreToolUse-Guard prüft Sub-Shell-Strings (`bash -c "…"`) rekursiv
  (Tiefe ≤ 3, darüber fail-closed).
- **Begründung:** schließt Commit-Bypass des Stop-Hooks und Guard-Umgehung
  via `bash -c`.
- **Auflösungs-Trigger:** permanent.
