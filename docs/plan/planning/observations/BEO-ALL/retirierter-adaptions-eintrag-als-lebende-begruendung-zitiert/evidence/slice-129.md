**Vorgang:** slice-129
**Fund:** Zwei Fundstellen, ein Vorgang. Die tragende Begründung der Filter-Entscheidung in
`harness/README.md` stützte den Ausschluss der Welle-Ebene auf
[`MR-016`](../../../../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) — die
Zwei-Datei-Form der Welle-Closure stand dort nie, und der ablösende
[`MR-037`](../../../../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
trägt sie ebenfalls nicht:

```sh
grep -ciE 'zwei[- ]datei|ergebnisnotiz|welle-plan.*zeiger' harness/conventions/MR-037-*.md   # 0
```

Das einzige lebende Artefakt, das die Form behauptete, war jener Absatz selbst. Dieselbe tote
Adresse stand **viermal** im Slice-Plan (Kopf `Bezug:`, §3, §4, §8), dort am 2026-08-28 korrekt
niedergeschrieben und am 2026-08-31 durch die Auflösung des Eintrags überholt — sie wäre mit dem
`git mv` nach `done/` eingefroren worden. Beide Stellen zeigen jetzt auf die Quelle, die die Form
wirklich vorschreibt: `modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 3, Baseline `v6.5.0`.
