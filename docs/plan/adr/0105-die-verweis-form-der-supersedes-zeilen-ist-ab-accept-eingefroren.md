# ADR-0105: Die Verweis-Form der Supersedes-Zeilen in einer Accepted-ADR — eingefroren ab Accept, Revert statt Form-Nachzug

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
(die erste Anwendung desselben Musters an der Verweis-Form-Klasse),
[ADR-0079](0079-tote-adresse-in-den-vendored-baum-aus-zwei-accepted-adrs.md)
(die Paar-Form der Senkung über eingefrorenen Quellen)

**Supersedes:** [ADR-0103](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
begrenzt auf die Verweis-Form der vier Zeilen, die ADR-0102 nennen (**Supersedes:**-Kopf,
**Bezug:**-Liste, Kontext-Einstieg, Festlegung 1) und der Prosa-Zeile `docs/reviews/mutate/`:
sie tragen ab diesem ADR die Form ihres Accept-Stands `075b84a4` (Markdown-Link,
Backtick-Prosa); der in-place Nachzug `c030e4c8` (Marker-Form je c7-Form) ist aus dem
Accepted-Kern zurückgenommen. Der übrige Kern — die Festlegungen 1–3 und Festlegung 4 in
der Fassung von [ADR-0104](0104-die-fall-beleg-zeile-der-festlegung-4-von-adr-0103-der-erste-bats-fall-ist-rot.md) —
bleibt unverändert regierend.

**Schärft:** — Prozess-ADR ohne Spec-Stratum. Geändert wird nur die Verweis-Form von
Kern-Zeilen einer `Accepted`-ADR und die Senkung, die ihre Färbung trägt; die
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
# docs/plan/adr/0103-…:9   …  0102-…-datei.md  matrix-inactive  Referenz auf inaktives
# docs/plan/adr/0103-…:18  …  Dokument (Status: Superseded by [ADR-0103](…))       (4 Fundstellen)
```

Beide Sensoren an derselben Zeilen-Klasse: der Nachzug heilt das `matrix`-Rot und färbt
den `adr-immutable`-Wächter; der Revert kehrt das um. Eine Form, die **beide** grün hält,
gibt es nicht — die Wahl fällt darum auf den Zustand, der die Hard Rule trägt, und die
eine Färbung trägt eine deklarierte Senkung.

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
   (kein Nachrüsten, [`AGENTS.md`](../../../AGENTS.md) §3.4). Ein Nachzug der Marker- auf
   die Link-Form — wie `c030e4c8` ihn fuhr — ist keine Form-Reparatur, sondern derselbe
   Weg wie hier: Revert und Folge-ADR.
3. **Die Färbung über der Link-Form trägt ein benanntes Paar.** Das **elfte**
   `ignore-refs`-Paar der [`.d-check.yml`](../../../.d-check.yml)
   (`in: docs/plan/adr/0103-…`, `refs: docs/plan/adr/0102-…`, **Deckung: 5** — 4
   Inline-Links im Kern, 1 Geschichte-Zeile, Markdown-Achse am
   `test/ignore-refs-restbreite.bats`-Wächter) nimmt die vier
   `matrix-inactive`-Befunde aus; es ist eine Senkung nach
   [`AGENTS.md`](../../../AGENTS.md) §3.5 mit dem Grund an der Stelle: Die Quelldatei
   ist eingefroren, der Befund ist in ihr nicht behebbar, und die Ziel-ADR rotiert mit
   keinem Bump (repo-intern; die Pfad-Klasse von
   [ADR-0101](0101-die-baseline-verweis-form-in-adrs.md) trifft hier kein Ziel). Die
   Restbreite ist strukturell null: eine eingefrorene Datei bekommt keine zweite
   Referenz.

## Grenze (was dieser ADR nicht trägt)

Die drei Präzedenz-ADRs behalten ihre Marker-Zeilen in der Entstehungs-Form; die
Marker-Form bleibt die Form für **neue** ADR-Zeilen über einem Supersedes-Übergang. Der
Bestand trägt damit beide Formen dokumentiert: Marker-Form (Entstehungskontext) und,
hinter dem Paar, Link-Form (eingefrorene Adresse) — der Index liest beide gleich. Ein
Lauf über der Range `17deb083..HEAD` färbt ADR-0103 weiter (1 Befund): die Range-Basis
liegt chronologisch nach `c030e4c8` und trägt dessen Marker-Form selbst — beide Anker
schließen sich aus, der Accept-Anker ist der tragende ([`AGENTS.md`](../../../AGENTS.md)
§3.4); das ist die Geschichte der Range, kein Zustand des Bestands.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — die Marker-Form im Bestand stehen lassen | `docs-check` grün; ein `docs-check:ignore`-Marker weniger im Config-Block | bestätigt einen Kern-Nachzug nach `Accepted` — der `adr-immutable`-Wächter am Accept-Anker bliebe dauerhaft rot; dasselbe Verfahren, das [ADR-0104](0104-die-fall-beleg-zeile-der-festlegung-4-von-adr-0103-der-erste-bats-fall-ist-rot.md) Alternative A verwirft, in Gegenrichtung |
| B — die Link-Form ohne Paar (nur Revert) | kein Config-Eintrag | die vier `matrix-inactive`-Befunde stehen dauerhaft in `make gates` — ein stehend rotes Gate statt einer Senkung ([`AGENTS.md`](../../../AGENTS.md) §3.5) |
| **C — Revert + Paar + dieser ADR (gewählt)** | der Kern trägt den Accept-Stand; beide Sensoren grün; die Senkung ist benannt, gezählt und bewacht | ein Config-Eintrag über einem eingefrorenen Ziel — derselbe Preis, den [ADR-0079](0079-tote-adresse-in-den-vendored-baum-aus-zwei-accepted-adrs.md) und [ADR-0101](0101-die-baseline-verweis-form-in-adrs.md) für dieselbe Klasse zahlt |

## Konsequenzen

- Positiv: `make adr-immutable RANGE=075b84a4..HEAD` schweigt; `make docs-check` meldet
  an der ADR-0103 keinen Verweis-Befund; die Deckung `Deckung: 5` ist in beiden
  Richtungen bewacht.
- Negativ: das elfte Paar steht dauerhaft im Config-Block — sein Gegenstand wird nie
  mehr bewegt (eingefrorene Quelle, inaktives Ziel), es ist nicht auflösbar; sein
  Entfall-Trigger ist der unter Re-Evaluierungs-Trigger 1.
- Folgepflicht: die Index-Zelle der ADR-0103 nennt die zweite Teil-Ablösung, die
  Geschichte-Zeile der ADR-0103 hält sie in deren Fortschreibungs-Tab.

## Re-Evaluierungs-Trigger

Permanent in der Form „gilt unbefristet" — bis eine dieser Bedingungen eintritt:

1. **d-check kennt die Klasse selbst** — ein Modul nimmt Referenzen aus eingefrorenen
   Artefakten auf inaktive Ziele selbst aus der Ziel-Prüfung; das Paar entfällt, das
   Wächter-Zahl-Buch führt es still zu 0, Folge-ADR mit `supersedes`.
2. **Die Status-Form der Ziel-ADR ändert sich** — `docs/plan/adr/0102-…` ist nach
   [`AGENTS.md`](../../../AGENTS.md) §3.4 eingefroren; träte sie doch in Bewegung, gilt
   der Weg der Paar-Auflösung wie bei ADR-0027.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-11-26 | Accepted; supersedes [ADR-0103](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md) begrenzt auf die Verweis-Form der vier ADR-0102-Zeilen und der Prosa-Zeile — der Nachzug `c030e4c8` ist auf den Accept-Stand `075b84a4` zurück, die Färbung darüber trägt das elfte `ignore-refs`-Paar | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
