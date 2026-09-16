**Vorgang:** slice-commit-traeger-wird-skip-if-present
**Fund:** Vier neue oder geänderte Begründungen des Vorgangs standen im Irrealis über einen **nicht
gefahrenen** Lauf — *„Ein Lauf, der ihn konvergent schriebe, koennte am Pfad nicht erkennen, wessen
Datei dort liegt"* (`commitMsgHookFile`), *„ein stiller Default waere genau die Setzung, die niemand
ausgesprochen hat"* (`writeEnforceFile`), *„Ein stilles Uebergehen waere die zweite Haelfte desselben
Fehlers"* (`writeSkipIfPresentTold`), *„ein Test, der die Klassen je Pfad selbst auflistet, haette
eine zweite Fassung daneben"* (`PathClass`). Beschrieben war damit nicht die Stelle, sondern die
**verworfene Alternative** — die §3.7-Form, die `make gates` nicht fängt und die der Review als
eigene Klasse gefunden hat.

```sh
git show 65b78423^:internal/emit/commitmsg.go | grep -n 'konvergent schriebe'          # :54
git show 65b78423^:internal/emit/enforce.go   | grep -n 'stiller Default waere'       # :439
git show 65b78423^:internal/emit/enforce.go   | grep -n 'stilles Uebergehen waere'    # :453
git show 65b78423^:internal/emit/enforce.go   | grep -n 'selbst auflistet, haette'    # :249
```

Nachgezogen in `65b78423`: alle vier stehen im Indikativ über den Zustand
([`AGENTS.md`](../../../../../../../AGENTS.md) §3.7). Die Abwägung, die sie wiederholten, steht in
[`ADR-0054`](../../../../../../../docs/plan/adr/0054-emittierter-commit-traeger-skip-if-present.md)
§Verglichene Alternativen und ist an drei der vier Stellen ohnehin zitiert.
