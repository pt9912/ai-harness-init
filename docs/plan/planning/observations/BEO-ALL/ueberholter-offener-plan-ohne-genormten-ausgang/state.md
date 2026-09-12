**Stand:** offen

Der heute verfügbare Behelf ist ein Zeiger in der überholten Plandatei auf den Plan, der an ihre
Stelle tritt; er hält die Adresse gültig und sagt über den Zustand der Datei nichts. Ein Wächter
besteht nicht: kein Modul aus `modules:` der [`.d-check.yml`](../../../../../../.d-check.yml)
liest den Lifecycle, und `make mutate` kennt dafür keine Fehlschlag-Form.

**Der Preis des fehlenden Ausgangs ist beziffert, und er ist kein Formfehler.** Ein Plan in
`open/` wird von den Zeitdokumenten zitiert, die ihn hervorgebracht haben — `done/` und
`docs/reviews/` —, und die sind nach [`AGENTS.md`](../../../../../../AGENTS.md) §3.7 Chronik von
Beruf und werden nicht nachgezogen. Wer die Datei entfernt, bricht genau diese Adressen, und
[`.d-check.yml`](../../../../../../.d-check.yml) §`ignore-refs` erklärt jedes weitere Ventil-Paar
zur Senkung nach [`AGENTS.md`](../../../../../../AGENTS.md) §3.5 mit eigener ADR. Gemessen über
einen Bestand von 24 Plänen, netzlos, an einer Kopie außerhalb des Repos, über dem in
[`d-check.mk`](../../../../../../d-check.mk) gepinnten Digest:

```sh
git archive HEAD | tar -x -C <kopie>
rm -f <kopie>/docs/plan/planning/open/slice-{072,074,075,078,101,102,103,108,109,110,112,115}-*.md
rm -f <kopie>/docs/plan/planning/open/slice-{119,121,134,142,143,171,189,198,199,208,212,215}-*.md
DIGEST=$(grep -oE 'DCHECK_DIGEST \?= sha256:[0-9a-f]+' d-check.mk | cut -d' ' -f3)
docker run --rm --network none -v <kopie>:/repo:ro "ghcr.io/pt9912/d-check@$DIGEST" | tail -1
#   d-check: … 232 Befund(e)
```

Von diesen Befunden entspringen **211** einem eingefrorenen Artefakt und **21** einem lebenden —
die Aufteilung entscheidet, ob ein Nachzug überhaupt möglich ist:

```sh
grep -E 'target-missing|codepath-missing' <lauf> | cut -d: -f1 \
  | awk '{ if ($0 ~ /^docs\/plan\/planning\/done\/|^docs\/reviews\/|^docs\/plan\/adr\//) f++; else e++ }
         END{ print "frozen="f" editierbar="e }'
```

**Keine Erwartungswerte** ([`MR-025`](../../../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — beide Zahlen wandern mit dem Bestand. Tragend ist ihr Verhältnis: Der Ausgang scheitert
nicht am Urteil über den Plan, sondern daran, dass sein **Pfad** zitiert ist. Ein Plan ohne
eingefrorenen Zitierer geht heute sauber; vier sind auf diesem Weg ausgeschieden
(`git log --diff-filter=D --name-only -- docs/plan/planning/open/`).

**Offene Übergabe an den Architect.** Entschieden ist die Form nicht, und dieser Eintrag entscheidet
sie nicht: Ob ein ausscheidender Plan einen Stub an seinem Pfad behält (die Form, die
`modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 4 für die Archivierung vorschreibt — sie
„lässt eingehende Verweise gültig"), ob die Kennungs-Form aus
[`AGENTS.md`](../../../../../../AGENTS.md) §3.11 auch für `open/` gilt, oder ob ein fünfter
Lifecycle-Zustand nötig ist, ist eine Norm-Frage mit eigenem `MR`-Bedarf. Bis dahin bleibt jeder
Plan mit eingefrorenem Zitierer liegen, gleich wie sein Verdikt lautet.
