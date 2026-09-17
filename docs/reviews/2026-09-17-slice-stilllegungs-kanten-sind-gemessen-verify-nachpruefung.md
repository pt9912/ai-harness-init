# Nachprüfung der Verifikation `slice-stilllegungs-kanten-sind-gemessen`: DoD erfüllt, bereit für Closure

**Rolle:** Verifier · **Datum:** 2026-09-17 · **Geprüfter Stand:** `42f3a6d1` · **Gegenstand:** die
Nacharbeit zu den Punkten 1 bis 4 der Liste „Vor der Closure fehlt" aus dem Verifikations-Bericht
`docs/reviews/2026-09-17-slice-stilllegungs-kanten-sind-gemessen-verify.md` (Commit `25d143ab`).
Punkt 5 ist die Closure selbst und nicht Gegenstand. Geprüft sind drei Commits:

| Commit | Rolle | Datei(en) |
|---|---|---|
| `a1ae2e74` | Planner | Folge-Slice `slice-risiko-ausgang-hat-einen-sensor` in `open/` |
| `dd330ee9` | Planner | `.claude/commands/plan-welle.md` §Einen Slice stilllegen; Trägerzeile in `slice-mv-kanten-nach-done-sind-bewacht` §1 |
| `42f3a6d1` | Implementer | [`harness/sensors/docs-check.md`](../../harness/sensors/docs-check.md) |

Die neue Lage ist nicht nachgemessen. Gelesen sind die Angabe und das Kommando; sie decken sich mit
den Lagen R1 und R2 aus §2 des Verifikations-Berichts.

## Status je Punkt

| # | Punkt | Status | Beleg |
|---|---|---|---|
| 1 | Adresse für die Lücke „kein aktives Modul prüft den Risiko-Ausgang" | **erledigt** | `slice-risiko-ausgang-hat-einen-sensor` liegt in `open/`. Das Ziel nimmt die Lücke an: *„Er meldet jeden Slice in `done/`, der in §6 ein Risiko ohne Ausgang trägt oder einen Ausgang außerhalb der geschlossenen Menge … Das gilt für jede Closure, nicht nur für eine Stilllegung."* Keiner der fünf Ausschlüsse in §1 nimmt das zurück. Die Stilllegungs-Form geht mit Begründung an die d-check-Anforderung. |
| 2 | Lage „ein Risiko ohne Ausgang" samt Einordnung in `docs-check.md` | **erledigt** | Die Tabelle trägt die Zeile *„ein Risiko aus §6 ohne Ausgang → keine"*. Dazu kommen die Beschreibung der Lage und das Kommando `make -C <kopie> docs-check`. Die Lage ohne Risiko-Zeile steht als Satz daneben. Die Folgerung „Die Form der Stilllegung liest kein aktives Modul" ist damit für alle drei Elemente der Form durch die Tabelle gedeckt. Die Lücke ist eingeordnet („betrifft jede Closure"), ihre Adresse ist Punkt 1. Die Sensor-Datei behauptet keinen Wächter. |
| 3 | N-1: Träger für die Bedingung im Gruppierungs-Lauf | **erledigt** | `plan-welle.md` §Einen Slice stilllegen nennt die drei Prüfungen je Wechsel: Exit-Code 0, reiner Rename per `git show --numstat --format= -M`, `make docs-check` ohne Befund. Er sagt, welcher Commit der Move-Commit ist, und hält die Serie bei der ersten roten Prüfung an. `slice-mv-kanten-nach-done-sind-bewacht` §1 zeigt auf diesen Träger. |
| 4 | F-6: die Wahl „Urteil" als Setzung ausweisen | **erledigt** | `plan-welle.md` nennt die Prüfung *„ein Urteil dieses Laufs, kein Sensor"*, als *„Setzung des Planners vom 2026-09-17"*, mit zwei Bedingungen für eine neue Entscheidung. `docs-check.md` zeigt auf diese Stelle. |

## Hinweise, die die Closure nicht blockieren

- **Die Reihenfolge aus N-1 hat keinen eigenen Träger.** N-1 nannte neben den drei Prüfungen, dass
  `slice-mv-zieht-praefixlose-geschwister-verweise-nach` vor der Gruppierung schließt.
  `plan-welle.md` nennt das nicht. Ein früherer Start fällt trotzdem laut auf: Prüfung 3 meldet die
  präfixlosen Verweise als `target-missing`, und die Serie hält an. Offen bleibt damit nur, dass
  die Serie anhalten kann, nicht dass etwas still durchgeht.
- **Der Träger bindet nur einen Lauf, der `plan-welle.md` liest.** Ob der Gruppierungs-Lauf diesen
  Anweisungssatz lädt, entscheidet der Planner beim Start der Gruppierung.
- **Wem die Setzung aus Punkt 4 gehört, ist eine bekannte offene Frage.** Die Wahl hat kein
  Original in den kanonischen Quellen; die Baseline lässt *Urteil oder eigener Sensor* offen.
  Genau diesen Teil nimmt
  [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 2 aus
  und weist ihn keiner Rolle zu. Der Planner-Commit verneint zudem eine Baseline-Abweichung, aber
  nur in der Commit-Message, nicht in der Datei. Eine Entscheidung darüber ist Sache des
  Architect. Die DoD berührt das nicht: Liefer-Punkt 3 verlangt, dass die Grenze in der
  Sensor-Datei steht, und das tut sie.

## Verdikt

**DoD erfüllt, bereit für Closure.** Die Liefer-Punkte 1 bis 3 sind erfüllt. `make gates` war schon
im Verifikations-Bericht grün; für diesen Stand steht das Ergebnis in der Commit-Message dieser
Nachprüfung. Für die Closure bleibt Punkt 5 aus dem Verifikations-Bericht: §7, Risiko-Ausgänge,
Register und DoD-Häkchen. Das ist Sache des Planners.
