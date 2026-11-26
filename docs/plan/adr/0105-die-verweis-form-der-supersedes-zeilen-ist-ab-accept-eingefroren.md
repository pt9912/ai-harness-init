# ADR-0105: Die Verweis-Form der Supersedes-Zeilen in einer Accepted-ADR — Revert auf den Accept-Stand, die Färbung darüber trägt eine benannte matrix-Ausnahme

**Status:** Accepted

**Datum:** 2026-11-26

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(der Wächter-Nachweis nennt Range und Befund-Zeile, nicht ein Urteil darüber),
[ADR-0103](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
(die ADR, deren vier ADR-0102-Verweis-Zeilen hier zurückgenommen werden),
[ADR-0104](0104-die-fall-beleg-zeile-der-festlegung-4-von-adr-0103-der-erste-bats-fall-ist-rot.md)
(das Heilmuster, zweite Anwendung),
[ADR-0101](0101-die-baseline-verweis-form-in-adrs.md)
(die erste Anwendung desselben Musters an der Verweis-Form-Klasse)

**Supersedes:** [ADR-0103](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
begrenzt auf die Verweis-Form der vier Zeilen, die ADR-0102 nennen (**Supersedes:**-Kopf,
**Bezug:**-Liste, Kontext-Einstieg, Festlegung 1) und der Prosa-Zeile `docs/reviews/mutate/`:
sie tragen ab diesem ADR die Form ihres Accept-Stands `075b84a4` (Markdown-Link,
Backtick-Prosa); der in-place Nachzug `c030e4c8` (Marker-Form je c7-Form) ist aus dem
Accepted-Kern zurückgenommen. Der übrige Kern — die Festlegungen 1–3 und Festlegung 4 in
der Fassung von [ADR-0104](0104-die-fall-beleg-zeile-der-festlegung-4-von-adr-0103-der-erste-bats-fall-ist-rot.md) —
bleibt unverändert regierend.

**Schärft:** — Prozess-ADR ohne Spec-Stratum. Geändert wird nur die Verweis-Form von
Kern-Zeilen einer `Accepted`-ADR und die Ausnahme, die ihre Färbung trägt; die
Mutations-Records und die Hash-Ausnahme liegen außerhalb jeder Spec-Stelle.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR).

---

## Kontext

[`make adr-immutable`](../../../harness/sensors/adr-immutable.md)
über der Range `075b84a4..HEAD` färbte 1 Befund:

```sh
make adr-immutable RANGE=075b84a4..HEAD
# docs/plan/adr/0103-…:3  core-drift-vcs  Core einer immutablen Datei hat sich
#   über die Commit-Range geändert
```

Die Änderung war der Commit `c030e4c8` (Supersedes-Lineage der ADR-0102-Verweise auf
Marker-Form, je c7-Form): vier Verweis-Zeilen und eine Backtick-Prosa-Zeile im Kern der
seit `075b84a4` `Accepted`-ADR-0103 — eine Kern-Änderung nach
[`AGENTS.md`](../../../AGENTS.md) §3.4.

Die Marker-Form ist daneben nicht frei erfunden: sie ist die **Entstehungs-Form** der
Zeilen-Klasse ([`ADR-0003`](0003-go-native-binaries.md),
[`ADR-0005`](0005-ziel-repo-distribution.md),
[ADR-0101](0101-die-baseline-verweis-form-in-adrs.md) tragen sie am eigenen Kern) und die
Link-Form färbt das `matrix`-Modul, weil die Ziel-ADR seit `075b84a4` inaktiv ist
(„Superseded by"):

```sh
make docs-check   # ADR-0103 im Accept-Verweis-Form (Link-Form)
# docs/plan/adr/0103-…:9|18|38|73   0102-…-datei.md  matrix-inactive  Referenz auf
#   inaktives Dokument (Status: Superseded by [ADR-0103](…))        (4 Fundstellen)
```

Beide Sensoren an derselben Zeilen-Klasse: der Nachzug heilt das `matrix`-Rot und färbt
den `adr-immutable`-Wächter; der Revert kehrt das um. Eine Form, die **beide** grün hält,
gibt es nicht — die Wahl fällt auf den Zustand, der die Hard Rule trägt, und die eine
Färbung trägt eine deklarierte Ausnahme. **Sonden-Messung zum Instrument:** das
`ignore-refs`-Paar (die Form von
[ADR-0079](0079-tote-adresse-in-den-vendored-baum-aus-zwei-accepted-adrs.md)) schaltet
die vier `matrix-inactive`-Befunde **nicht** stumm — `ignore-refs` ist geteilt zwischen
links, anchors und codepaths ([`.d-check.yml`](../../../.d-check.yml) Kopf des Blocks);
die Status-Achse von `matrix` honoriert es nicht, gemessen am `make docs-check`-Lauf
2026-11-26 (4 Befunde blieben stehen). Ihr Instrument ist
`matrix.exempt-paths` — derselbe Mechanismus, der den [ADR-Index](../../plan/adr/README.md)
nimmt, der superseded ADRs als seine Aufgabe nennt.

## Entscheidung

Drei Festlegungen:

1. **Revert auf den Accept-Stand.** Die vier Zeilen und die Prosa-Zeile tragen die Form
   von `075b84a4` (Markdown-Link, Backtick); der Nachzug ist eine Kern-Änderung und ist
   nicht im Bestand — der Weg ist der von
   [ADR-0101](0101-die-baseline-verweis-form-in-adrs.md) (Entstehungsstand) und
   [ADR-0104](0104-die-fall-beleg-zeile-der-festlegung-4-von-adr-0103-der-erste-bats-fall-ist-rot.md)
   (Accept-Stand, Festlegung 4), dritte Anwendung.
2. **Die Marker-Form ist eine Entstehungs-Form.** Die
   `<!-- d-check:ignore (Supersedes-Lineage …) -->`-Marker der Präzedenzen tragen Zeilen,
   die mit ihrem ADR entstanden; die Marker der Präzedenz-Kerne bleiben unberührt
   (kein Nachrüsten, [`AGENTS.md`](../../../AGENTS.md) §3.4). Ein Nachzug der Marker-Form
   über einem Accept — wie `c030e4c8` ihn fuhr — ist keine Form-Reparatur, sondern
   derselbe Weg wie hier: Revert und Folge-ADR.
3. **Die Färbung über der Link-Form trägt eine benannte `matrix`-Ausnahme.** Die
   Quelldatei `docs/plan/adr/0103-…` kommt als viertes Element in
   `matrix.exempt-paths` der [`.d-check.yml`](../../../.d-check.yml) — mit dem Grund an
   der Stelle: Die Quelldatei ist eingefroren, der Status-Befund ist in ihr nicht
   behebbar, die Ziel-ADR rotiert mit keinem Bump (repo-intern), und der Gegenstand ist
   genau diese eine Datei — die Restbreite ist strukturell null (eine eingefrorene Datei
   bekommt keinen zweiten Stand). Es ist eine Senkung nach
   [`AGENTS.md`](../../../AGENTS.md) §3.5: der vier Elemente davor entnimmt die
   Ausnahme keine Klasse — dieses Element nimmt eine (`adr`) heraus.

## Grenze (was dieser ADR nicht trägt)

Die drei Präzedenz-ADRs behalten ihre Marker-Zeilen in der Entstehungs-Form; die
Marker-Form bleibt die Form für **neue** ADR-Zeilen über einem Supersedes-Übergang. Der
Bestand trägt damit beide Formen dokumentiert: Marker-Form (Entstehungskontext) und,
hinter der Ausnahme, Link-Form (eingefrorene Adresse) — der Index liest beide gleich.
Ein Lauf über der Range `17deb083..HEAD` färbt ADR-0103 weiter (1 Befund): die
Range-Basis liegt chronologisch nach `c030e4c8` und trägt dessen Marker-Form selbst —
beide Anker schließen sich aus, der Accept-Anker ist der tragende
([`AGENTS.md`](../../../AGENTS.md) §3.4); das ist die Geschichte der Range, kein
Zustand des Bestands.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — die Marker-Form im Bestand stehen lassen | `docs-check` grün ohne Ausnahme-Eintrag | bestätigt einen Kern-Nachzug nach `Accepted` — der `adr-immutable`-Wächter am Accept-Anker bliebe dauerhaft rot; dasselbe Verfahren, das [ADR-0104](0104-die-fall-beleg-zeile-der-festlegung-4-von-adr-0103-der-erste-bats-fall-ist-rot.md) Alternative A verwirft, in Gegenrichtung |
| B — Link-Form + `ignore-refs`-Paar | das etablierte Instrument der eingefrorenen Adressen | **gemessen untauglich**: die Status-Achse von `matrix` honoriert `ignore-refs` nicht, 4 Befunde blieben stehen (oben Kontext, Sonden-Messung); ein Paar, das nichts trägt, wäre eine Deklaration ohne Wirkung ([`AGENTS.md`](../../../AGENTS.md) §3.6) |
| **C — Revert + `matrix`-Ausnahme + dieser ADR (gewählt)** | der Kern trägt den Accept-Stand; beide Sensoren grün; die Ausnahme nennt ihren ganzen Gegenstand (eine Datei) | ein dauerhaftes Ausnahme-Element über einem eingefrorenen Ziel — derselbe Preis, den der [ADR-Index](../../plan/adr/README.md) und die drei Pfad-Muster davor für dieselbe Klasse zahlen |

## Konsequenzen

- Positiv: `make adr-immutable RANGE=075b84a4..HEAD` schweigt; `make docs-check` meldet
  an der ADR-0103 keinen Status-Befund.
- Negativ: das vierte `exempt-paths`-Element steht dauerhaft — sein Gegenstand wird nie
  mehr bewegt (eingefrorene Quelle, inaktives Ziel); sein Entfall-Trigger ist Re-Eval. 1.
- Folgepflicht: die Index-Zelle der ADR-0103 nennt die zweite Teil-Ablösung, die
  Geschichte-Zeile der ADR-0103 hält sie in deren Fortschreibungs-Tab.

## Re-Evaluierungs-Trigger

Permanent in der Form „gilt unbefristet" — bis eine dieser Bedingungen eintritt:

1. **d-check kennt die Klasse selbst** — ein Modul nimmt Referenzen aus eingefrorenen
   Artefakten auf inaktive Ziele selbst aus der Status-Prüfung; das Element entfällt,
   Folge-ADR mit `supersedes`.
2. **Die Status-Form der Ziel-ADR ändert sich** — `docs/plan/adr/0102-…` ist nach
   [`AGENTS.md`](../../../AGENTS.md) §3.4 eingefroren; träte sie doch in Bewegung,
   gilt der Weg der Ausnahme-Auflösung wie bei ADR-0027.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-11-26 | Accepted; supersedes [ADR-0103](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md) begrenzt auf die Verweis-Form der vier ADR-0102-Zeilen und der Prosa-Zeile — der Nachzug `c030e4c8` ist auf den Accept-Stand `075b84a4` zurück, die Färbung darüber trägt die vierte `matrix`-Ausnahme | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
