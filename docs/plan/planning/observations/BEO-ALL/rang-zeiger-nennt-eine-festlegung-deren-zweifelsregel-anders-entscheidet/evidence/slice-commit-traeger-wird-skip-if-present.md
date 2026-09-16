**Vorgang:** slice-commit-traeger-wird-skip-if-present
**Fund:** Der Abbruch bei einem Eintrag ohne Idempotenz-Klasse begründet sich mit einem Rang-Zeiger,
der in eine andere Richtung entscheidet als die Meldung. Sie sagt *„ein Pfad ohne Klasse faellt aus,
statt konvergent zu gelten ([`ADR-0007`](../../../../../../../docs/plan/adr/0007-bootstrap-phasen.md)
Festlegung 3)"*, während jene Festlegung für den unentschiedenen Fall `skip-if-present` als
*„der sichere Default"* nennt:

```sh
grep -n 'keine Idempotenz-Klasse' internal/emit/enforce.go    # :447 — die Meldung, die den Zeiger trägt
grep -n 'der sichere Default' docs/plan/adr/0007-bootstrap-phasen.md   # :89 — die zitierte Zweifelsregel
```

Die Annahme, daß ein klassenloser Eintrag ein Programmierfehler und keine unentschiedene Klasse ist,
ist an keiner Stelle ausgesprochen; das Verhalten ist damit strenger als die zitierte Regel, statt
ihre Anwendung zu sein. Die Stelle liegt in **Produkt-Code** (`internal/emit/enforce.go`), die
zitierte Festlegung in einer `Accepted`-ADR — die Auflösung ist eine Entscheidung über die zitierte
Stelle und damit Architect-Arbeit.
