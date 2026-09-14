**Vorgang:** 2026-09-14-welle-13-trigger-audit

**Fund:** Der Trigger-Audit der Welle fand eine zweite `Proposed`-Entscheidung in derselben Lage —
und eine schärfere: [`ADR-0035`](../../../../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
trägt **keinen** Acceptance-Trigger:

```sh
grep -c '^## Der Acceptance-Trigger' docs/plan/adr/0035-*.md    # 0
```

**Kein Erwartungswert.** Damit ist die Lage der
[`ADR-0036`](../../../../../../../docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md)-Zeile
vergleichbar, ihr Gegenmittel fehlt aber: dort steht der Acceptance-Trigger **in** der Datei.

**Und einen Träger-Slice hatte sie zum Zeitpunkt des Audits nicht** — er ist erst durch die
Closure entstanden und darum hier als Zustand zitiert, nicht als Kommando-Ausgabe
([`MR-058`](../../../../../../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)
Setzung 2: eine Messung, die ihr eigener Vorgang bewegt, wird nach dem Vorgang genommen). Der
Closure-Lauf der Welle hat den Ausgang als
[`slice-ausnahmeliste-bekommt-ihre-berechtigungs-pruefung`](../../../../open/slice-ausnahmeliste-bekommt-ihre-berechtigungs-pruefung.md)
geschnitten und die zugehörige Register-Zeile
[`ausnahmeliste-nur-auf-form-geprueft`](../../ausnahmeliste-nur-auf-form-geprueft/observation.md)
von `offen` auf `geplant` gezogen.
