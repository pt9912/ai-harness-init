**Vorgang:** slice-174-archivierung-emittieren
**Fund:** Zwei Zusagen standen neben einer Ableitung, die die Umsetzung dieses Vorgangs seither
bewegt hatte, und keine Runde zog sie nach. (a) Der Anlass-Block des Plans (DoD-Punkt 1) führte
zwei Prosa-Zahlen mit ihren Kommandos; die Kommandos standen daneben, ausgeführt wurden sie nach
den späteren Commits nicht mehr:

```sh
grep -l 'archive' test/mutations/*.sh | wc -l        # Block sagte 33 — der Stand gibt 34
grep -c 'archive' harness/tools/full-smoke.sh        # Block sagte 21 — der Stand gibt 23
```

(b) Dieselbe Richtung an einem zweiten Artefakt: `harness/sensors/archive-welle.md` §Grenze zählte
„**Zwei** Aufrufer liegen im Prüfbereich", während derselbe Vorgang dem Sensor eine dritte Quelle
des Namens gab — das emittierte Archivierungs-Fragment:

```sh
grep -n 'Aufrufer' harness/sensors/archive-welle.md       # :49 — "Zwei Aufrufer …"
grep -c '^@test' test/unterkommando-kopplung.bats         # 3 — je eine Quelle
```

Beide sind **Prosa-Zahlen** — genau die Unterklasse, die die `state.md` dieses Eintrags als noch
offen führt. Gezogen hat sie der Planner bei der Closure; ein Gate liest keine von beiden.
