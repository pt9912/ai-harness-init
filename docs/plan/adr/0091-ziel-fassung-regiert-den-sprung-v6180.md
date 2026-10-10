# ADR-0091: Die Ziel-Fassung regiert den Sprung `v6.17.0` → `v6.18.0` — Welle 161 zieht im emittierten Doku-Gate nur den Kommentar-Block nach, `reviews` bleibt auf beiden Ebenen aus

**Status:** Accepted

**Datum:** 2026-10-10

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0082](0082-ziel-fassung-regiert-den-sprung-v6170.md) (der vorige Sprung; Form und Prozedur
werden hier gelesen, nicht abgeschrieben),
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md),
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md),
[`MR-054`](../../../harness/conventions.md#mr-054),
[`MR-086`](../../../harness/conventions.md#mr-086),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: Sie wählt die normative Quelle eines Vorgangs und
fällt das Delta-Urteil zu einem Modul des Doku-Gates auf beiden Ebenen.

**Kopplung:** wie [ADR-0082](0082-ziel-fassung-regiert-den-sprung-v6170.md) §Kopplung; der
ADR-Index die Zeile dieser Datei mit diesem Commit.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR).

---

## Kontext

Der Auftraggeber hat am 2026-10-10 den Sprung auf `v6.18.0` freigegeben, *„und auch für unser
emit"*. `K` ist der lokale Kurs-Klon; Zahlen aus einem Tag-Vergleich sind fest.

```sh
git -C "$K" diff --stat v6.17.0 v6.18.0 -- lab/regelwerk lab/templates | tail -1
# -> 5 files changed, 44 insertions(+), 9 deletions(-)
```

Gezählt ist der vendored Baum ([`MR-007`](../../../harness/conventions.md#mr-007)). Geändert:
`regelwerk/modul-10-review-harness.md` (Absatz in §Harness-Einordnung (Modul 10), Ablage-Satz),
`regelwerk/README.md` (Stand-Zeile), die Vorlagen `.d-check.yml`, `README.template.md` (unter
`harness/`), `review-report.template.md` (unter `docs/reviews/`). Die Kurs-Fassung des Moduls unter
`kurs/de` ist nicht vendored und darum nicht mitgezählt; der übrige Tag-Diff liegt ebenfalls
außerhalb des vendored Baums. **`modul-02-harness-bootstrap.md` ist unverändert** —
die Prozedur des Durchgangs ist dieselbe wie in
[ADR-0082](0082-ziel-fassung-regiert-den-sprung-v6170.md) Festlegung 1.

**Der Inhalt der Welle 161:** ein Deckungs-Sensor meldet den Leerlauf (keine erkannte Zusage unter
vorhandenen Slices), ordnet Reports über die volle Slice-Kennung zu und führt archivierte Slices
nicht mehr; ein Report trägt die volle Kennung im Dateinamen. Die Vorlage `.d-check.yml` lässt
`reviews` **auskommentiert** und ergänzt `match: name`, `require-promises`, `recursive`,
`skip-pattern`, `skip-allows-empty` (d-check `>= v0.86.0`; gepinnt ist `v0.86.1`).

## Entscheidung

### Festlegung 1 — Ziel-Fassung `v6.18.0`, Übernahme vollständig

Es regiert `v6.18.0`, mit derselben Begründung wie
[ADR-0082](0082-ziel-fassung-regiert-den-sprung-v6170.md) Festlegung 1. Keine neue Abweichung.
**Kandidaten** des Durchgangs sind die aktiven Einträge, die Modul 10, eine geänderte Vorlage, das
Modul `reviews` oder die Report-Ablage nennen:

```sh
grep -lE 'modul-10-review-harness|review-report\.template|templates/\.d-check\.yml|README\.template\.md|`reviews`|Modul reviews|docs/reviews/<' harness/conventions/*.md
# -> MR-001, MR-008, MR-009, MR-011, MR-052, MR-054, MR-072, MR-080, MR-086, MR-087, MR-092
```

Das Urteil je Eintrag fällt im Durchgang, vor dem Entfernen von `v6.17.0/`.

### Festlegung 2 — Emission: `reviews` bleibt Kommentar-Block, mit den neuen Schlüsseln

`internal/emit/templates/d-check.yml` behält `reviews` auskommentiert; der Block übernimmt
`require-promises: true`, `recursive: true`, `skip-pattern` und `skip-allows-empty: true` der
Vorlage neben dem vorhandenen `match: name`. Grund: Am Pin `v0.86.1` startet ein frisch
gebootstrapptes Ziel mit **keiner** Schlüssel-Kombination grün — Kriterium 2 von
[`MR-054`](../../../harness/conventions.md#mr-054) scheitert weiter. Gemessen über einem Ziel aus
`make host-bin` + `ai-harness-init <ziel>` (`done/` trägt nur `.gitkeep`), je Variante eine
Konfiguration mit `modules: [reviews]`, `done-dir`, `reviews-dir`, `match: name` und:

```sh
docker run --rm --network none -v "$PWD:/repo:ro" ghcr.io/pt9912/d-check@sha256:3e0b9779… --config vN.yml
# v1 alle vier neuen Schlüssel · v2 ohne require-promises · v3 keiner · v4 require-promises: false
# v5 nur require-promises — jede: exit=1,
# review-missing  leere Pruefmenge: 0 Kandidat(en), 0 Review-Zusage(n), reviews-dir lesbar: true — fail-closed
```

`skip-allows-empty` greift laut `--manual reviews` nur für eine Menge, aus der `skip-pattern`
mindestens eine Datei genommen hat; `require-promises` betrifft den Leerlauf unter vorhandenen
Slices, nicht die leere Menge. [`MR-086`](../../../harness/conventions.md#mr-086) bleibt damit in
Kraft, ohne Folge-Eintrag: sein Auflösungs-Trigger ist nicht eingetreten, und sein Grund trägt am
neuen Pin. **Akzeptiertes Negativ:** das Feld Adaption von [`MR-086`](../../../harness/conventions.md#mr-086) nennt die Messung am Pin
`v0.84.0`; die Messung am `v0.86.1` steht hier, der Eintrag wird nicht angefasst.

### Festlegung 3 — Dogfood: `reviews` im Sprung nicht aktiv, aktiviert in einem eigenen Slice

Über dem Bestand meldet die Konfiguration der neuen Vorlage **70** Befunde. Gemessen an HEAD
`5faf3823`, `S` ein Scratch-Verzeichnis, `v1.yml` wie oben:

```sh
git archive HEAD docs/plan/planning/done docs/reviews | tar -x -C "$S"
cd "$S" && docker run --rm --network none -v "$PWD:/repo:ro" ghcr.io/pt9912/d-check@sha256:3e0b9779… --config v1.yml | tail -1
# -> d-check: 1167 Datei(en) geprüft, 70 Befund(e)      (alle review-missing, exit=1)
```

Die Befunde sind überwiegend Benennung, nicht fehlende Reviews: Reports tragen eine gekürzte
Kennung (`2026-10-08-emittierte-gate-vorlage-review.md` zu
`slice-emittierte-gate-vorlage-traegt-targets-und-reviews`). Umbenennen scheidet aus —
`docs/reviews/**` sind Zeitdokumente ([`AGENTS.md`](../../../AGENTS.md) §3.7). Das Präfix-Risiko
von `match: name` trifft den Bestand nicht: kein Basisname unter `done/` ist Präfix eines anderen
(`… | awk '…index(a[j],a[i]"-")==1…'` → `Praefix-Paare=0`). Grün würde der Dogfood nur mit einer
geschlossenen `exempt-paths`-Liste über die 70 Pläne — einer Bestands-Ausnahme, die nach
[`AGENTS.md`](../../../AGENTS.md) §3.5 ihren ganzen Gegenstand nennt; das wächst mit dem Bestand,
nicht mit dem Delta, und gehört nicht in den Sprung.

[`MR-054`](../../../harness/conventions.md#mr-054) Kriterium 1 bleibt im Sprung damit unerfüllt; für die Emission folgt daraus nichts Neues, weil
Kriterium 2 sie schon allein ausschließt (Festlegung 2).

**Gewählt vom Auftraggeber am 2026-10-10 (*„ok so"*): Aktivierung in einem eigenen Slice,
`slice-review-deckung-laeuft-im-dogfood`.** Er setzt die Schlüssel der Vorlage, `exempt-paths` mit
den 70 gemessenen Plänen als Cutoff und einen Rot-Beleg mit einem Plan ohne Report. Danach hält ein
Sensor die volle Kennung im Dateinamen, und [`MR-054`](../../../harness/conventions.md#mr-054)
Kriterium 1 ist erfüllt, sobald ein Pin den leeren Start grün macht. Verworfen ist das Ausbleiben im
Dogfood, bei dem allein der Reviewer-Skill die Ablage-Regel neuer Reports trüge. **Grenze:**
`match: name` hält einen Dateinamen, nicht dass er ein Review ist; ein `…-architect-verdikt.md` mit
voller Kennung deckt den Slice ebenso. **Darum steht das Verdikt dieses Durchgangs in dieser ADR und
nicht unter `docs/reviews/`:** dort deckte es unter `match: name` den Sprung-Slice, als wäre er
reviewt.

### Festlegung 4 — Folge für `emittierter-stand-laeuft-dem-dogfood-voraus`

Kein drittes Auftreten: das Ziel aktiviert `reviews` nicht (Festlegung 2). Mit der Aktivierung im
Dogfood (Festlegung 3) läuft der Dogfood dem Ziel voraus — die Gegenrichtung, nicht diese Klasse.
Der Eintrag bleibt bei 2, offen.

### Folge-Arbeit und Schnitt

| Vorgang | Inhalt | Träger |
|---|---|---|
| Sprung-Slice | Vendoring `v6.18.0`, Pins, Mess-Tag, Adressen; Ablage-Form neuer Reports; Kommentar-Block nach Festlegung 2 samt Wächter (§Fitness Function, je neuem Schlüssel einmal rot gesehen); `harness/README.md` nennt `reviews` als nicht aktiv mit Grund aus Festlegung 3 | `slice-sprung-auf-v6180-wird-vollzogen` |
| Buchung §Baseline, `migration.md` §1, Freshness-Verdikt über Festlegung 1 | wie ADR-0082 | Architect, mit dem Vollzug |
| Dogfood-Aktivierung | nach Festlegung 3 | `slice-review-deckung-laeuft-im-dogfood` |

Kein d-check-Pin-Eintrag: der Pin `v0.86.1` liegt schon.

### Acceptance-Trigger

`Accepted` auf Weisung des Auftraggebers nach einer Reviewer-Konsistenzrunde in frischem Kontext
gegen [ADR-0082](0082-ziel-fassung-regiert-den-sprung-v6170.md),
[`MR-054`](../../../harness/conventions.md#mr-054) und
[`MR-086`](../../../harness/conventions.md#mr-086) ohne blockierenden Befund.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — `reviews` im Ziel aktiv | Ziel folgt der Welle wörtlich | frisches Ziel startet rot (Festlegung 2); bricht [`MR-054`](../../../harness/conventions.md#mr-054) Kriterium 2 und [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| B — aktiv im Ziel mit einem gesäten Plan in `done/` | grüner Start | ein erfundener Vorgang im Ziel; eine Deckung über einem Beispiel ist keine |
| C — Kommentar-Block unverändert lassen | kein Code | das Ziel liest eine Vorlage `v6.18.0`, deren Schlüssel sein Block nicht nennt; ein Adopter, der aktiviert, läuft nach dem Archivieren rot |
| D — Dogfood im Sprung aktivieren | eine Vorlage für beide Ebenen | 70 Befunde; eine Bestands-Ausnahme dieser Größe sprengt den Sprung-Slice |
| F — Dogfood dauerhaft aus | kein Slice | die Ablage-Regel neuer Reports hält kein Sensor; vom Auftraggeber verworfen (Festlegung 3) |
| **E — gewählt: Ziel Kommentar-Block mit neuen Schlüsseln, Dogfood im Sprung aus, Aktivierung in einem eigenen Slice** | Delta im Ziel nachgezogen ohne rotes Ziel; die Bestandsfrage hat einen Träger | bis zu dessen Closure fährt der Dogfood die Review-Deckung nicht |

## Konsequenzen

- **Positiv:** Ein Adopter, der `reviews` einschaltet, bekommt die Schlüssel, ohne die das Modul
  nach dem Archivieren rot wird oder leer läuft.
- **Negativ / [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6):**
  das Ziel fährt die Review-Deckung nicht; im Dogfood hält die Ablage-Regel neuer Reports kein
  Sensor, bis `slice-review-deckung-laeuft-im-dogfood` geschlossen ist.
- **Darüber hinaus ändert diese ADR keine Datei außer sich selbst und dem ADR-Index.**

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| Go-Test `TestDCheckConfig_ReviewsBleibtKommentarBlock`, im Sprung-Slice erweitert | die emittierte `.d-check.yml` führt kein aktives `reviews:` (Fall `568` in `test/mutations/` färbt rot) und im Kommentar-Block `match: name` (Fall `667`); der Test verlangt daneben jeden der vier neuen Schlüssel einzeln, und der Sprung-Slice sieht ihn je Schlüssel durch Streichen einmal rot | `make test`; `make mutate` (kein Gate) |

**Lücke:** für die vier neuen Schlüssel führt `test/mutations/` keinen Fall; ob der Test sie nach
dem Sprung-Slice weiter einzeln verlangt, hält `make mutate` nicht. Und dass ein frisches Ziel mit
aktivem Block rot startet, hält kein Sensor — gemessen ist es mit dem Kommando in Festlegung 2;
Träger ist der d-check-Pin-Sprung (Re-Evaluierungs-Trigger).

## Re-Evaluierungs-Trigger

- **Der nächste Sprung steht an**, oder `make baseline-freshness` meldet vor dem Vollzug einen
  neueren Tag.
- **Ein d-check-Pin startet ein Ziel mit leerem `done/` und aktivem Block grün:** Festlegung 2 und
  der Auflösungs-Trigger von [`MR-086`](../../../harness/conventions.md#mr-086) sind neu zu messen.
- **Der Dogfood fährt `reviews`** (`slice-review-deckung-laeuft-im-dogfood` geschlossen,
  `grep '^modules:' .d-check.yml` nennt `reviews`): [`MR-054`](../../../harness/conventions.md#mr-054) Kriterium 1 ist erfüllt.
- **Die Kurs-Vorlage aktiviert `reviews`:** Festlegung 2 verliert ihre Deckung durch die Vorlage.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-10-10 | Proposed | — |
| 2026-10-10 | Proposed, nachgebessert | Wahl (ii) des Auftraggebers in Festlegung 3, Fitness-Zusage eingeschränkt — Commit `1522c29c` |
| 2026-10-10 | **Accepted** | Review `2026-10-10-adr-0091-review` (Commit `5ee4251c`, annahmereif, 0 HIGH), Nachbesserung `1522c29c` (MEDIUM-1, LOW-1, INFO-1, INFO-2 eingearbeitet); keine Nachprüfung, weil [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 sie nur nach einem blockierenden Befund verlangt; Annahme durch den Auftraggeber am 2026-10-10 ([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1) |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0091` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
