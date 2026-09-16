**Vorgang:** slice-commit-traeger-wird-skip-if-present
**Fund:** Der Satz *„Diese Entscheidung steht auf `Proposed`"* steht in
[`ADR-0055`](../../../../../../../docs/plan/adr/0055-abgeschaffte-kennung-verlaesst-die-fitness-function-als-teil-abloesung.md)
auf Zeile **302**, während dieselbe Datei seit dem 2026-09-16 `Accepted` trägt — und die Entscheidung
konnte ihn **nicht** ziehen: sie sagt in §Konsequenzen selbst, daß sie keine Form für Präsens-Aussagen
in einfrierenden Artefakten ist. Der Accept-Übergang durfte ihn nicht berichtigen
([`AGENTS.md`](../../../../../../../AGENTS.md) §3.4).

```sh
grep -n 'steht auf `Proposed`' docs/plan/adr/0055-*.md      # :302 — der Satz, im Accepted-Stand
grep -n '^\*\*Status:\*\*' docs/plan/adr/0055-*.md          # :3   — Accepted
```

**Der Fall ist die Form, nicht der Einzelfall:** der Satz steht in **14** `Accepted`-ADRs dieses
Repos, weil er zur Sektion *Der Acceptance-Trigger* gehört, die mit dem Accept einfriert —

```sh
for f in docs/plan/adr/0*.md; do grep -q '^\*\*Status:\*\* Accepted' "$f" || continue; \
  n=$(grep -c 'steht auf `Proposed`' "$f"); [ "$n" -gt 0 ] && echo "$f"; done | wc -l   # 14
```

— und keine Quelle sagt, in welcher Zeitform er nach dem Umschlag stehen soll. Die zwei vorigen
Fälle derselben Klasse waren Sätze, die eine Quelle hätte ziehen können (slice-145 an
[`ADR-0028`](../../../../../../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md),
slice-offene-wellen-liste-hat-einen-waechter an
[`ADR-0046`](../../../../../../../docs/plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md));
hier setzt die einfrierende Entscheidung die Form für solche Zeilen ausdrücklich **nicht** — der
Gegenstand ist damit reif für einen eigenen Träger.
