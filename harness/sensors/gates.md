# make gates — Fast-Pfad je-Check-Satz (Tier 2)

## Vertrag

`make gates` ist der Einsprung der vollen Gates: sein Rezept startet den
Wrapper [`harness/tools/gates-fast.sh`](../../harness/tools/gates-fast.sh)
([ADR-0108](../../docs/plan/adr/0108-stempel-synthese-je-check-pruefgegenstand.md), nach der
Fastpfad-Form [ADR-0099](../../docs/plan/adr/0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md)).
Die SKIP-Bedingung ist der **je-Check-Satz**: sie deckt nur, wenn für jeden Kanten-Check
der Satzerzeuger-Menge (`gates-keys.sh liste`; der Satzerzeuger ist die EINE Definition
je Menge, [`ADR-0108`](../../docs/plan/adr/0108-stempel-synthese-je-check-pruefgegenstand.md) Festlegung 1) der Stempel
`.harness/state/gates-passed-<check>.key` vorhanden, formal (64 Hex) und gleich dem
Tafel-Wert (`gates-keys.sh key <check>`) ist. Bei Teildrift fährt der Lauf **genau** die
gedrifteten Checks und stempelt nur deren Keys; der Stempel-Aufruf folgt dem make-Lauf,
endet dieser rot, entsteht kein neuer Stempel, und der stehende Wert entwertet nicht —
die Leser sehen die Drift ([`ADR-0108`](../../docs/plan/adr/0108-stempel-synthese-je-check-pruefgegenstand.md) Festlegung 3). Jeder Zweifel — fehlender, leerer,
unlesbarer oder fremd geformter Key, Satzerzeuger-Fehler — fährt fail-closed den vollen
Lauf über `make record-gates`, dasselbe Rezept mit derselben Kante
(`record-gates: environment-check baseline-verify … span-check`; die Kante trägt seit
slice-environment-check-fuehrt-die-gates den Umgebungs-Check als ersten Eintrag).

Die je-Check-Keys beurteilt nur der Fast-Pfad; die zwei Gesamt-Dateien
(`.harness/state/gates-passed.diffsha`, `.harness/state/gates-passed.head`) entstehen
weiterhin allein im Rezept `record-gates` ([`ADR-0108`](../../docs/plan/adr/0108-stempel-synthese-je-check-pruefgegenstand.md) Festlegung 2) und werden vom
Stop-Hook an seiner HEAD-Kante und seiner je-Check-Deckung beurteilt ([`ADR-0108`](../../docs/plan/adr/0108-stempel-synthese-je-check-pruefgegenstand.md)
Festlegung 5) — `head_wert` führt im Fast-Pfad nicht mehr.

## Der benannte Rest

Der SKIP urteilt über baum-abgeleitete Schlüssel, und sein Rest liegt
außerhalb jedes baum-abgeleiteten Schlüssels: **der lokale Docker-Cache-Zustand
und die Host-Werkzeuge (bash, tar, git, docker)**
([ADR-0108](../../docs/plan/adr/0108-stempel-synthese-je-check-pruefgegenstand.md)
Festlegung 4, je Tier-1;
[ADR-0099](../../docs/plan/adr/0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md)
Festlegung 2, Wortlaut-Präzedenz
[ADR-0035](../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
Festlegung 4). Jeder SKIP- und Teildrift-Meldung nennt ihn; `GATES_FORCE=1` erzwingt den
vollen Lauf, jeder andere Wert und das Fehlen sagen nichts (Festlegung 3).

## Der transportierte Konsum (CI)

Die je-Check-Keys sind committet und reisen mit dem Klon
([ADR-0111](../../docs/plan/adr/0111-ci-stempel-eingecheckt-committed-je-check-keys.md)
Festlegung 1; die committete Klasse liegt ebenso außerhalb des Baum-Hash als
deklarierte Hash-Ausnahme in `working-tree-hash.sh`). Der push-`main`-Job der
CI konsultiert den transportierten Satz über **unverändertes** `make gates` —
der Fast-Pfad entscheidet am frischen Klon am selben Satzerzeuger, kein
zweiter Maßstab (Festlegung 2). `pull_request` und jeder Nicht-main-Push fahren
`GATES_FORCE=1` voll: die Skip-Konsultation ist an den main-Push-Schutz
gebunden, der PR läuft die Prüfung seines eigenen Baums (Festlegung 2). Auf CI
schreibt der Lauf bei Teildrift keinen Stempel zurück — der Read-only-Kontext
der CI bleibt, der Rück-Stempel ist Host-Pflicht des Implementer-Zugs
(Festlegung 3/5). Die zwei Gesamt-Dateien reisen nicht
(Festlegung 3, host-Klasse über
[ADR-0083](../../docs/plan/adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)).

## Wächter

- [`test/gates-fastpfad.bats`](../../test/gates-fastpfad.bats) — die Klassifikation über
  dem je-Check-Bericht (gedeckter Satz → SKIP, Teildrift → genau die gedrifteten Checks,
  fehlender/unformaler Key oder Satzerzeuger-Fehler → voller Lauf, fail-closed),
  FORCE-Beleg (hermetisch über `--entscheide`), Verdrahtung (voller Lauf oder
  Teildrift-Lauf, Keys nur über den Satzerzeuger, keine der zwei Gesamt-Dateien, Bericht
  aus Stempeln und Satzerzeuger) und die zwei `head_wert`-Fassungen gleich
- [`test/gate-nachweis-kante.bats`](../../test/gate-nachweis-kante.bats) — Kante
  an `record-gates` byte-gleich, `gates` ohne `make`-Prerequisites, Rezept startet
  nur den Wrapper
- [`test/ci-stempel-committed.bats`](../../test/ci-stempel-committed.bats) — die
  committete Klasse: `git check-ignore` je Klasse (Key-Klasse und E2E-Stempel
  transportiert, Gesamt-Dateien und die übrigen state-Ablagen lokal,
  [ADR-0111](../../docs/plan/adr/0111-ci-stempel-eingecheckt-committed-je-check-keys.md)
  Festlegung 1/3/4) und die Verdrahtung der Workflows (push-`main` unforced,
  `pull_request` erzwungen voll); die Gitignore-Umstellung selbst rotiert keinen
  Baum-Hash, das hält
  [`test/working-tree-hash-abnahme.bats`](../../test/working-tree-hash-abnahme.bats)
  an den deklarierten Hash-Ausnahmen

## Grenze

Der SKIP urteilt nie über das hinaus, was er sicher lesen kann; was er nicht
deckt, ist der benannte Rest und die Re-Evaluierungs-Trigger der ADR (bei jedem
künftigen Check im Kanten-Satz neu zu zeigen), nicht ein weiterer Sensor. Auf
CI kommt der Rest der Runner- und Netz-Fassung hinzu: die konsultierten Keys
conservieren das Verdikt eines Host-Laufs; die Verdrahtung der Workflows belegt
der reale CI-Lauf selbst, nicht der Wächter
([`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Form:
die CI ist dort das Netz).

## Grenze

Der SKIP urteilt nie über das hinaus, was er sicher lesen kann; was er nicht
deckt, ist der benannte Rest und die Re-Evaluierungs-Trigger der ADR (bei jedem
künftigen Check im Kanten-Satz neu zu zeigen), nicht ein weiterer Sensor.
