**Stand:** offen

Kein Modul aus `modules:` der [`.d-check.yml`](../../../../../../.d-check.yml) liest einen
Rollen-Anweisungssatz auf eine Konvention, und `make mutate` kennt dafür keine Fehlschlag-Form.
Die naheliegende Behebung — die Konvention in die betroffenen Anweisungssätze schreiben — ist
rollen-gebunden: [`.harness/skills/reviewer.md`](../../../../../../.harness/skills/reviewer.md)
gehört nach [`ADR-0028`](../../../../../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
der ausführenden Rolle, und für `.claude/agents/*.md` ist das Eigentum selbst noch offen
([`ADR-0029`](../../../../../../docs/plan/adr/0029-agenten-typkarten-derivativ-gemischte-originale.md),
`slice-152`). Die konventions-unabhängige Behebung — ein Träger, der die auslösende Form nicht mehr
braucht — trägt `slice-215`.
