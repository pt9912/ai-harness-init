# ADR-0104: Die Fall-Beleg-Zeile der Festlegung 4 von ADR-0103 — der erste bats-Fall ist der rot färbende, nicht der zweite

**Status:** Accepted

**Datum:** 2026-11-26

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(der Beleg nennt den Fall, der wirklich rot wird, nicht seinen Nachbarn),
[ADR-0103](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
(die ADR, deren Festlegung 4 hier in ihrer Beleg-Zeile korrigiert wird),
[`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
(der Fall 791 als Mutations-Anlage mit Anker gegen den Quell-Bestand)

**Supersedes:** [ADR-0103](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
begrenzt auf Festlegung 4 (die Fall-Beleg-Zeile der Fitness-Tabelle): die rote
Fall-Nennung war die falsche der zwei bats-Fälle — der erste Fall des
[`test/working-tree-hash-abnahme.bats`-Wächters](../../../test/working-tree-hash-abnahme.bats)
(„ein Pfad unter .harness/stamp/mutate bewegt den Hash nicht“) ist der rot färbende,
der fail-closed-Fall bleibt grün. Der Rest der ADR-0103 — Festlegungen 1–3, der
Titel und der Re-Evaluierungs-Trigger — bleibt unverändert regierend.

**Schärft:** — Prozess-ADR ohne Spec-Stratum. Die Mutations-Records liegen außerhalb
jeder Spec-Stelle; geändert wird nur die Beleg-Zeile einer Fitness-Tabelle.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR).

---

## Kontext

Die Fall-Beleg-Zeile der ADR-0103-Festlegung 4 nannte den fail-closed-Fall als den
rot färbenden. Die Gegenprobe widerlegt die Nennung:

```sh
make mutate MUTATE_CASES=791-working-tree-stamp-ausnahme-ohne-zaehne.sh
# -> test/working-tree-hash-abnahme.bats faerbt den ERSTEN Fall
#    („ein Pfad unter .harness/stamp/mutate bewegt den Hash nicht“) rot;
#    der fail-closed-Fall bleibt gruen: die Mutation wirkt im Stamp-Inneren,
#    der fail-closed-Zweig bleibt als Code unberuehrt.
```

## Entscheidung

Die Festlegung 4 der ADR-0103 trägt ab diesem ADR die Fassung:

| Tooling | Regel | Make-Target |
|---|---|---|
| `test/mutations/791-working-tree-stamp-ausnahme-ohne-zaehne.sh` | Nimmt der Ausnahme-Prefix seine Zahn-Funktion, färbt der erste bats-Fall („ein Pfad unter .harness/stamp/mutate bewegt den Hash nicht“) über dem realen Skript rot | `make mutate` |

## Grenze (was dieser ADR nicht trägt)

Der Titel der ADR-0103 bleibt im Accepted-Stand und sagt die Ausnahme als
Kurzfassung („nimmt `.harness/stamp/**` aus“): die präzise Form — Liste plus
fail-closed-Rest — tragen Festlegung 2 der ADR-0103 und die Form-Zeile in
[`harness/sensors/mutate.md`](../../../harness/sensors/mutate.md) §CI-Branch. Kein
Sensor hält eine Titel-Kurzfassung gegen die Listen-Form; die Lücke ist benannt,
nicht geschlossen.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — die Zeile in-place in ADR-0103 korrigieren | eine Kennung weniger | überschreibt den Kern einer Accepted-ADR ([`AGENTS.md`](../../../AGENTS.md) §3.4) — dieselbe Grenze, über die der Supersedes-Weg gerade heilt; ein in-place-Zug über der ADR färbt `make adr-immutable` rot, der hier geheilt wird |
| B — die Korrektur nur in den lebenden Dateien lassen, die ADR-Zeile unverändert | kein zweites ADR | die ADR-Zeile ist die Herkunfts-Adresse des Belegs: die eingefrorene Fassung bliebe die falsche Nennung, und jeder Lauf, der ADR-0103-Festlegung 4 zitiert, liest sie |
| **C — dieser ADR mit begrenztem `supersedes` (gewählt)** | der eingefrorene Beleg nennt den richtigen Fall; der Rest der ADR-0103 bleibt unverändert regierend | zwei Kennungen für eine Zeile der ADR-0103 — die Index-Zelle und die Geschichte-Zeile halten die Kette auflösbar |

## Konsequenzen

- Positiv: der eingefrorene Beleg nennt den Fall, den der Mutations-Lauf wirklich
  färbt; die Korrektur liegt in einer neuen Kennung ([`AGENTS.md`](../../../AGENTS.md) §3.4).
- Negativ: die Titel-Kurzfassung der ADR-0103 trägt die Listen- und Rest-Form nicht
  (oben Grenze).
- Folgepflicht: die Index-Zelle der ADR-0103 nennt die teilweise Ablösung, die
  Geschichte-Zeile der ADR-0103 hält sie in deren Fortschreibungs-Tab.

## Re-Evaluierungs-Trigger

Permanent in der Form „gilt unbefristet“ — bis die Fall-Beleg-Zeile erneut
korrekturbedürftig wird; der Weg ist derselbe: Folge-ADR mit `supersedes` und
begrenztem Umfang, der die betroffene Festlegung nennt.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-11-26 | Accepted; supersedes [ADR-0103](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md) begrenzt auf Festlegung 4 — die Fall-Beleg-Zeile trägt die erste-bats-Fall-Fassung | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) · Review [`2026-11-26-adr0103-stamp-relocation.md`](../../reviews/2026-11-26-adr0103-stamp-relocation.md) F-1 |
