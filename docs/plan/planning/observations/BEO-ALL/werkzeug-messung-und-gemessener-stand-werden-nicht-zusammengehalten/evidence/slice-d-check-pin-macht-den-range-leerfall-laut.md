**Vorgang:** slice-d-check-pin-macht-den-range-leerfall-laut

**Fund:** Die Tabellenzeile *flacher Klon* in `harness/sensors/history-range-guard.md` und [`MR-079`](../../../../../../../harness/conventions.md#mr-079) nennen ein am Pin `v0.81.0` gemessenes Verhalten — `vcs` bricht im flachen Klon auch über nicht leerer Range ab (Tiefe 2, `HEAD~1..HEAD`: `v0.81.0` Exit 2, `v0.79.0` Exit 0) —, und keine Stufe fährt es; ein späterer Pin-Sprung hält die Aussage nicht gegen den gefahrenen Stand (Review F-4).
