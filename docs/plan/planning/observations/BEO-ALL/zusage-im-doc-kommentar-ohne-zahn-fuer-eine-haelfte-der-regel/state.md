**Stand:** offen

Schwelle erreicht, Ausgang steht aus
(`ls docs/plan/planning/observations/BEO-ALL/zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel/evidence/*.md | wc -l`
→ 3, gelesen 2026-09-27, keine Erwartung): der dritte Vorgang ist `slice-204-das-programm-feld-nennt-das-programm` (die Tab-Wortgrenze
und die Fortsetzungs-Bedingung von `splitWords`, das Programm-Feld auf `;` in `segmentArgc`: Kommentar und `SPEC-031` sagen jede Grenze
zu, die Fälle banden je eine Hälfte). Der Ausgang ist Sache des Architect; `offen` ist bis dahin vorübergehend und kein Ausgang.
Die zweite Instanz ist die Abschnitts-Erkennung des Kopplungs-Tests `test/codepaths-reviews-ausnahme.bats`: Start-Grenze
und Block-Ende sind je durch einen Mutations-Fall gebunden (`474`, `475`), der Kommentar-Filter steht ohne
Fall und ist im Kommentar als solcher genannt. In der ersten Instanz sind die
Zeilengrenze und die Verzeichnisgrenze je durch einen Go-Test und einen Mutations-Fall gebunden; die
Maskierung des Namens in der Link-Regel trägt keinen Zahn und ist nicht behoben. Ein Wächter für die
Klasse besteht nicht: `make mutate` meldet nur den **gelisteten** Fall, der seine Zähne verliert, und
`make comment-claims` prüft, ob ein genannter Sensor existiert, nicht, ob er jede Hälfte der Zusage
trifft. Träger ist der Review, der jede Grenze im Kommentar gegen einen Fall liest — und der Lauf, der
den Kommentar schreibt, nach [`AGENTS.md`](../../../../../../AGENTS.md) §3.6.
