# ADR-0082: Die Ziel-Fassung regiert den Sprung `v6.16.0` → `v6.17.0` — Welle 160 schaltet im emittierten Doku-Gate die Disjunktheit ein, das Dogfood hat für sie kein Objekt

**Status:** Proposed

**Datum:** 2026-10-07

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0078](0078-ziel-fassung-regiert-den-sprung-v6160.md) (der vorige Sprung; Form und Prozedur
werden hier gelesen, nicht abgeschrieben),
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md),
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md),
[ADR-0060](0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md) (Sprung auf a-check `v0.20.0`),
[`MR-054`](../../../harness/conventions.md#mr-054),
[`MR-063`](../../../harness/conventions.md#mr-063),
[`MR-080`](../../../harness/conventions.md#mr-080),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: Sie wählt die normative Quelle eines Vorgangs und
schneidet seine Folge-Arbeit.

**Kopplung:** wie [ADR-0078](0078-ziel-fassung-regiert-den-sprung-v6160.md) §Kopplung — §Baseline
von [`harness/conventions.md`](../../../harness/conventions.md) bekommt Zielstand-Buchung und
Zeiger mit dem Vollzug, [`harness/migration.md`](../../../harness/migration.md) §1 die Sprung-Zeile;
der ADR-Index die Zeile dieser Datei mit diesem Commit.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR).

---

## Kontext

Der Auftraggeber hat den Sprung `v6.16.0` → `v6.17.0` beauftragt. `K` ist der lokale Kurs-Klon;
Zahlen aus einem Tag-Vergleich sind fest.

```sh
git -C "$K" log --oneline v6.16.0..v6.17.0
# -> de590bd … Welle 160 - Disjunktheit des Gate-Index wird ein Gate
#    c99354a chore(d-check): Pin v0.82.0 -> v0.83.0 - beide Fragmente regeneriert
#    4e71d48 docs(roadmap): Meilenstein v6.16.0 mit Beleg eintragen
git -C "$K" diff --stat v6.16.0 v6.17.0 -- lab/regelwerk lab/templates | tail -1
# -> 4 files changed, 11 insertions(+), 6 deletions(-)
```

Die vier Dateien: `README.md` (Stand-Zeile), `grundlagen-harness-dateien.md` und
`modul-13-quality-gates.md` (je ein Absatz), `templates/.d-check.yml` (Kommentar plus
`authority-disjoint: true`, `d-check >= v0.83.0`). **`modul-02-harness-bootstrap.md` ist
unverändert** — die Prozedur des Durchgangs ist byte-gleich zu der, die
[ADR-0078](0078-ziel-fassung-regiert-den-sprung-v6160.md) Festlegung 1 wählte.

**Der Inhalt der Welle 160:** die Vereinigung der Gate-Index-Teile sieht ein doppelt geführtes
Target nicht; *„Wer [die Disjunktheits-Prüfung] hat, schaltet sie zusammen mit der Vereinigung
ein; bleibt sie aus, steht die Regel nur im Briefing."* Die Prüfung liefert d-check `v0.83.0`
(`/Development/d-check/CHANGELOG.md` §0.83.0): `targets.authority-disjoint: true` → Befund
`gate-declared-twice`, ohne Schalter byte-identische Ausgabe; eine Doppelung **innerhalb** einer
Datei ist kein Fall.

**Was das in diesem Repo trifft:**

```sh
grep -n 'authority' .d-check.yml | grep -v '^[0-9]*:#'
# -> 188:  authority: harness/README.md
grep -n 'authority' internal/emit/templates/d-check.yml
# -> 157:  authority: [harness/README.md, harness/mk/ai-harness-init.md]
```

Das Dogfood führt **einen** Teil, das emittierte Ziel **zwei**. Der Emitter schreibt den
Werkzeug-Teil heute schon disjunkt gegen `harness/README.md`
(`internal/emit/werkzeugindex.go`, Kommentar an `WerkzeugIndex`), und seine Grenz-Zeile im
emittierten Teil nennt den Pin `v0.82.0` als Grund, warum niemand die Disjunktheit prüft.

**Zwei Schreib-Klassen im Ziel:** die `.d-check.yml` schreibt der Lauf skip-if-present
(`internal/emit/emit.go`, `DocGate`), `d-check.mk` und den Werkzeug-Teil
harness/mk/ai-harness-init.md bei jedem Lauf kanonisch neu. Ein **bestehendes** Ziel bekommt mit
dem nächsten Lauf also Pin und Grenz-Zeile, aber nicht den Schalter.

**a-check liegt außerhalb des Deltas:**
`git -C "$K" grep -c 'a-check:v' v6.17.0 -- Makefile lab/` → kein Treffer; der Kurs pinnt kein
a-check.

## Entscheidung

### Festlegung 1 — Ziel-Fassung `v6.17.0`, Übernahme vollständig

Es regiert `v6.17.0`, `modul-02-harness-bootstrap.md` §Freshness-Audit der vendored Baseline
(Schritt 2), mit derselben Begründung wie
[ADR-0078](0078-ziel-fassung-regiert-den-sprung-v6160.md) Festlegung 1 (Prozedur unverändert,
Tag-Klammer [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Keine neue
Abweichung. Der Durchgang liest die drei geänderten Regelwerk- und Vorlagen-Dateien mit Inhalt als
Volltext; **Kandidaten** sind die aktiven Einträge, die einen der zwei geänderten Abschnitte oder
die geänderte Vorlage nennen:

```sh
grep -ln 'hard-rule-doku-disziplin\|harnessreadmemd-als-einstiegspunkt\|templates/\.d-check\.yml' harness/conventions/*.md
# -> MR-001, MR-009, MR-010, MR-011, MR-014, MR-024, MR-054, MR-065, MR-080
```

[`MR-001`](../../../harness/conventions.md#mr-001),
[`MR-009`](../../../harness/conventions.md#mr-009),
[`MR-010`](../../../harness/conventions.md#mr-010),
[`MR-011`](../../../harness/conventions.md#mr-011),
[`MR-014`](../../../harness/conventions.md#mr-014),
[`MR-024`](../../../harness/conventions.md#mr-024),
[`MR-054`](../../../harness/conventions.md#mr-054),
[`MR-065`](../../../harness/conventions.md#mr-065),
[`MR-080`](../../../harness/conventions.md#mr-080); das Urteil je Eintrag fällt im Durchgang.

### Festlegung 2 — Welle 160 im emittierten Ziel: Schalter an, mit dem Pin

Das emittierte Doku-Gate bekommt `targets.authority-disjoint: true`, **im selben Vorgang wie der
emittierte Default-Pin d-check `v0.83.0`** — vorher kennt das Werkzeug den Schlüssel nicht. Der
Schalter ist eine Verschärfung eines aktiven Moduls, kein neues Modul; die drei Kriterien von
[`MR-054`](../../../harness/conventions.md#mr-054) gelten trotzdem, weil das Ziel ihn ab dem
ersten Lauf fährt: **Erprobung** (Lauf im gebootstrappten Ziel), **grüner Start** (der Emitter
schreibt disjunkt, der Lauf belegt es) und **rotes Gegenbeispiel** (§Fitness Function).

**Die Grenz-Zeile im Werkzeug-Teil folgt der `.d-check.yml`, die im Ziel liegt** — nicht der, die
der Lauf emittieren würde. `WerkzeugIndex` liest die Ziel-`.d-check.yml` nach `DocGate`, also auch
die eben frisch geschriebene: Trägt sie eine nicht auskommentierte Zeile
`authority-disjoint: true`, nennt die Zeile den Sensor und seine Grenze (er sieht eine Doppelung
erst, wenn das Repo sie angelegt hat); fehlt sie, sagt die Zeile, dass eine Doppelung still bleibt,
und nennt den Schlüssel, der sie einschaltet. So hält der Werkzeug-Teil in beiden Ziel-Klassen
die Wahrheit am Ort ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)),
und die skip-if-present-Zusage an die `.d-check.yml` bleibt unberührt. **Grenze:** erkannt wird
die Zeile textuell, nicht über das YAML-Schema; ein Schalter an anderer Stelle der Datei gilt als
gesetzt. Akzeptiertes Negativ — der Lauf schreibt die Datei selbst in genau dieser Form, und ein
Adopter, der sie umbaut, liest die Zeile, die ihn betrifft.

### Festlegung 3 — Welle 160 im Dogfood: kein Schalter, akzeptiertes Negativ

Das Dogfood führt eine Autoritäts-Datei; eine Doppelung innerhalb einer Datei ist für d-check kein
Fall. Der Schalter hätte kein Objekt und behauptete ein Gate über einer leeren Menge
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Er bleibt
aus, **ohne** Adaptions-Eintrag: die Welle verlangt den Schalter *zusammen mit der Vereinigung*,
und die gibt es hier nicht. Wird ein zweiter Teil eingeführt, gilt der Re-Evaluierungs-Trigger.

### Festlegung 4 — d-check-Pin `v0.83.0` im Dogfood und als emittierter Default, mit Eintrag

Der Pin springt an beiden Stellen im Sprung-Vorgang. Wie jeder d-check-Pin im Bestand bekommt er
einen Adaptions-Eintrag nach dem Muster von [`MR-080`](../../../harness/conventions.md#mr-080) —
Digest, Strenge-Bilanz mit
Gegenmessung nach [`MR-063`](../../../harness/conventions.md#mr-063). **Der Architect schreibt ihn
mit dem Vollzug, nicht jetzt:** sein Inhalt sind Messungen am neuen Digest, die erst der
Sprung-Vorgang erhebt; ein vorgezogener Eintrag trüge Platzhalter. Eigener Commit, nur
Architect-Artefakte ([`AGENTS.md`](../../../AGENTS.md) §3.8).

### Festlegung 5 — der a-check-Pin `v0.20.0` → `v0.22.0` ist nicht Teil dieses Sprungs

Der Kurs pinnt kein a-check; der Sprung trägt nur, was das Delta bringt. Der Pin ist rein
emittiert (das Dogfood fährt kein a-check, `harness/README.md` §Safety and scope boundaries), und
für a-check-Pins gibt es **keinen** Adaptions-Eintrag im Bestand — der Sprung auf `v0.20.0` lief
über [ADR-0060](0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md) und einen Slice. Das
bleibt so: ein **eigener Slice** mit Bezug
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), kein MR, keine ADR. Die
emittierte `.a-check.yml` nutzt `shapes` nicht (`grep -rn 'shapes' internal/emit/` → kein
Treffer); beide Releases ändern nur `shapes`-Verhalten, der Slice belegt das am grünen
`full-smoke` samt dem verbotenen Import.

### Folge-Arbeit und Schnitt

| Vorgang | Inhalt | Träger |
|---|---|---|
| Sprung-Slice | Vendoring `v6.17.0` + Baseline-Pins + emittierter Mess-Tag; d-check-Pin `v0.83.0` (Dogfood, emittierter Default); Schalter und zustandsabhängige Grenz-Zeile im Ziel (Festlegung 2) samt rotem Gegenbeispiel für beide Ziel-Klassen — drei Liefer-Punkte | Planner schneidet, Implementer |
| `MR`-Eintrag d-check `v0.83.0` | Festlegung 4 | Architect, mit dem Vollzug |
| Buchung §Baseline, `migration.md` §1, Freshness-Review | Festlegung 1 | Architect, mit dem Vollzug |
| a-check-Pin `v0.22.0` | Festlegung 5 | eigener Slice, unabhängig |
| Release `v0.4.0` | nach Closure des Sprung-Slice | Release-Schnitt |

**Release-Bedingung:** Pin und Schalter reisen im selben Release. Mit einem Sprung-Slice gilt das
von selbst; schneidet der Planner Festlegung 2 ab, darf zwischen den zwei Vorgängen kein Tag
liegen (dieselbe Form wie [ADR-0078](0078-ziel-fassung-regiert-den-sprung-v6160.md)
Festlegung 5). Der a-check-Slice ist keine Bedingung für `v0.4.0`.

### Acceptance-Trigger

`Accepted` auf Weisung des Auftraggebers nach einer Reviewer-Konsistenzrunde in frischem Kontext
gegen [ADR-0078](0078-ziel-fassung-regiert-den-sprung-v6160.md),
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) und
[`MR-054`](../../../harness/conventions.md#mr-054) ohne blockierenden Befund.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts entscheiden | kein Aufwand | [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 verlangt die Begründung; das Ziel stünde nach dem Vendoring unter einer Vorlage, die den Schalter verlangt, und führte ihn nicht |
| B — Sprung ohne Schalter, Welle 160 als eigener späterer Vorgang | kleinerer Sprung | die Vorlage sagt nach dem Vendoring *„bleibt sie aus, steht die Regel nur im Briefing"* — ein Intervall, das ein Release erreichen könnte; der Schalter ist eine Zeile plus ein Gegenbeispiel |
| C — Schalter auch im Dogfood | eine Konfiguration für beide Ebenen | kein Objekt bei einer Autoritäts-Datei; behauptet ein Gate über einer leeren Menge |
| D — a-check-Pin in den Sprung | ein Vorgang für alle Pins | nicht im Delta; vier Liefer-Punkte sprengen die Größenregel (`modul-05-planning-harness.md` §Ziel-Form: Slice) |
| F — bestehendes Ziel nur per stdout-Meldung über den fehlenden Schalter informieren | kein Lesen der Ziel-Konfiguration im Werkzeug-Teil | die Meldung vergeht mit dem Lauf, die Grenz-Zeile im Werkzeug-Teil behauptete weiter eine Prüfung, die nicht läuft |
| G — Konsequenz auf frisch gebootstrappte Ziele einschränken, Klasse nur benennen | kein Code | die Grenz-Zeile bliebe im bestehenden Ziel falsch; Benennen in der ADR erreicht den Adopter nicht |
| **E — gewählt: Ziel-Fassung, Schalter emittiert mit dem Pin, Grenz-Zeile nach der liegenden `.d-check.yml`, Dogfood ohne, d-check-`MR` mit dem Vollzug, a-check eigener Slice** | Delta und Wirkung in einem Vorgang; kein Intervall im Ziel; der Werkzeug-Teil sagt in jeder Ziel-Klasse, was läuft; jede Folge-Arbeit hat einen Träger | der Sprung-Slice trägt Code (Emitter, Grenz-Zeile, `full-smoke`), nicht nur Doku |

## Konsequenzen

- **Positiv:** Das emittierte Ziel prüft die Zusage *„kein Target in zwei Teilen"*, statt sie nur
  zu nennen; die Grenz-Zeile im Werkzeug-Teil verliert ihren Pin-Grund und sagt in jedem Ziel, ob
  die Prüfung dort läuft.
- **Negativ:** Ein ab `v0.4.0` **frisch gebootstrapptes** Ziel, das eine eigene
  `harness/README.md`-Zeile für ein Werkzeug-Target anlegt, wird rot, wo es bisher still blieb —
  gewollt, aber eine sichtbare Verhaltensänderung für Adopter; sie gehört in die Release-Notiz.
  Ein **bestehendes** Ziel behält seine `.d-check.yml` und bleibt still, bis der Adopter den
  Schalter setzt; die Grenz-Zeile seines Werkzeug-Teils sagt ihm das, die Release-Notiz ebenso.
- **Negativ / [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6):**
  im Dogfood hält kein Sensor die Disjunktheit — sie hat dort kein Objekt (Festlegung 3).
- **Folgepflicht:** siehe §Folge-Arbeit und Schnitt.
- **Darüber hinaus ändert diese ADR keine Datei außer sich selbst und dem ADR-Index.**

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| d-check `targets` mit `authority-disjoint: true`, im gebootstrappten Ziel | eine Tabellenzeile für ein Target aus harness/mk/ai-harness-init.md im Ziel, zusätzlich in `harness/README.md` §Sensors eingefügt, färbt das Doku-Gate des Ziels rot mit `gate-declared-twice`; der unveränderte Bootstrap bleibt grün | `make full-smoke` (Stufe `targets_im_ziel`, im Sprung-Slice erweitert) |
| Grenz-Zeile gegen die liegende `.d-check.yml`, im Ziel mit vorab gelegter `.d-check.yml` ohne Schalter | der Lauf lässt die Datei unverändert, der Werkzeug-Teil nennt die Disjunktheit **nicht** geprüft, und dieselbe Doppelzeile lässt das Doku-Gate grün (gemessene Grenze); rotes Gegenbeispiel: schreibt der Emitter die Zeile unabhängig vom Ziel-Stand („geprüft"), fällt die Stufe | `make full-smoke` (neue Stufe im Sprung-Slice, mit Fall in `test/mutations/`) |

**Lücke:** ob der Durchgang der gewählten Fassung folgte, und die Release-Bedingung — wie
[ADR-0078](0078-ziel-fassung-regiert-den-sprung-v6160.md) §Fitness Function; Träger ist der
Release-Schnitt, der diese Entscheidung liest.

## Re-Evaluierungs-Trigger

- **Der nächste Sprung steht an**, oder der Zielstand bewegt sich vor dem Vollzug
  (`make baseline-freshness` meldet einen neueren Tag).
- **Das Dogfood führt einen zweiten `authority`-Teil:** Festlegung 3 verliert ihren Grund; der
  Schalter gehört dann auch hierher.
- **Der grüne Start im Ziel scheitert** (der Emitter schreibt doch eine Doppelung): Festlegung 2
  geht nicht ohne Emitter-Korrektur in den Sprung; der Schnitt ist neu zu führen.
- **Die `.d-check.yml` des Ziels wird konvergent oder gemischt geschrieben:** die
  zustandsabhängige Grenz-Zeile aus Festlegung 2 verliert ihren Grund.
- **Der Kurs pinnt a-check:** Festlegung 5 verliert ihren Grund.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-10-07 | Proposed | — |
