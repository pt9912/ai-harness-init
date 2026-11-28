# Slice slice-emittierte-traeger-dateien-tragen-keine-werkzeug-kennung: Die emittierten Träger-Dateien tragen keine Kennung, die im Ziel nicht auflöst

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt; er wechselt nur durch `git mv`.

**Welle:** ohne Welle — keine Closure-Bedingung, die mehr beobachtet als die DoD ([`MR-037`](../../../../harness/conventions.md#mr-037)).

**Ebene: emittiert, nicht Dogfood.** Gegenstand sind `traeger-fetch.sh` und `traeger.mk` unter `internal/emit/templates/enforce/`.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`MR-057`](../../../../harness/conventions.md#mr-057), [`MR-059`](../../../../harness/conventions.md#mr-059) (Setzung 4).
Eigenschaft: Architect-Bericht `2026-10-06-architect-emittierte-kennungen.md` (Verdikt 1).

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-06.

---

## 1. Ziel und Abgrenzung

**Ziel:** Ein emittierter Kommentar oder Meldungstext der Träger-Familie trägt keine Kennung (`ADR-NNNN`, `LH-XX-NN`, `MR-NNN` mit Ziffern), die im Ziel nicht
auflöst; die Zusage steht in Worten, die Meldung nennt den Satz, nach dem der Anwender handelt.

**Lage, nachgemessen:**

```sh
git grep -nE '\b(ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3})\b' -- internal/emit/templates/enforce/traeger-fetch.sh internal/emit/templates/enforce/traeger.mk
git grep -cE '\b(ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3})\b' -- 'internal/emit/templates' ':!*_test.go'
```

- `traeger-fetch.sh`: 19 Zeilen — 13 Kommentare, 6 Meldungen (Zeilen 43, 59, 67, 96, 101, 130); `traeger.mk`: 7 Zeilen, alle Kommentare. Zusammen 26 von 49
  Zeilen in 10 Dateien (Gesamtmessung des Architect-Berichts, am Bestand nachgemessen und gleich: 46 in `templates/`, 3 in `emit.go`).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Rest (8 Dateien, 23 Zeilen) und der Wächter-Test:** Folge-Slice `slice-emittierte-dateien-tragen-keine-nicht-aufloesende-kennung`; er nimmt
  die Sendung an (sein Gegenstand ist genau dieser Rest samt Wächter). Hier fehlt der Wächter bewusst: er startet dort grün, nachdem dieser Slice
  geschlossen ist.
- **Kennungen, die das Ziel selbst führt** (Platzhalter-Form `ADR-NNNN`, vom Lauf emittierte Register): bleiben zulässig; sie lösen im Ziel auf.
- **Prosa-Verweise ohne Ziffernform** (`Modul 13`, `slice-…`): Urteil, kein Sensor; nicht Gegenstand dieser Fundmenge.
- **Dogfood-Skripte und Quell-Kommentare des Werkzeugs:** ein anderer Vorgang (Dogfood-Ebene, [`MR-059`](../../../../harness/conventions.md#mr-059) Setzung 1).

## 2. Definition of Done

- [ ] **(1) Die 20 Kommentar-Zeilen der Träger-Familie tragen keine Kennung.** Die Zusage steht in Worten; die Herkunft hält Release und git des Werkzeugs.
      *Bricht, wenn:* das erste Kommando aus §1 einen Treffer in den zwei Dateien nennt (vorher 26, nachher 0).
- [ ] **(2) Die 6 Meldungen von `traeger-fetch.sh` nennen Wortlaut statt Kennung.** Tests, die eine Meldung zitieren
      (`grep -rn 'traeger-fetch:' internal test`), ziehen mit; jede Meldung behält den Satz, nach dem gehandelt wird. *Bricht, wenn:* ein bestehender Meldungs-Test
      rot wird, weil ein Fall-Wortlaut mit der Kennung geändert wurde, ohne dass der Test die Aussage statt der Kennung hält. **Benannte Lücke:** bis der Folge-Slice
      seinen Wächter liefert, hält allein das Kommando aus §1 diese Eigenschaft; ob der Ersatz-Wortlaut die Zusage trägt, ist Urteil des Reviews.

Standard (zählen nicht): `make gates` grün · Review-Report (kein Self-Review) · Closure-Notiz mit Lerneintrag · Register fortgeschrieben · Risiko-Ausgänge · drei Paarungen.

## 3. Plan (vor Code)

| Datei | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/enforce/traeger-fetch.sh` | update | DoD (1), (2): 13 Kommentare, 6 Meldungen |
| `internal/emit/templates/enforce/traeger.mk` | update | DoD (1): 7 Kommentare |
| Tests mit zitierten Meldungen | update | DoD (2) |

Eine Schicht: Emissions-Vorlagen.

## 4. Trigger

**Start** (`next` → `in-progress`): erfüllt — Eigenschaft und Übergabe stehen im Architect-Bericht `2026-10-06-architect-emittierte-kennungen.md`.

**Rückführungen:**

- `in-progress` → `next`: ein Meldungs-Test lässt sich nur mit Fall-Umbau halten — dann Meldungen und Kommentare trennen.
- `in-progress` → `open`: der Architect ändert die Eigenschaft.

## 5. Closure-Trigger

`make gates` grün; das Kommando aus §1 nennt in den zwei Dateien 0 Treffer, nachdem es vorher 26 nannte. Dazu ein Lerneintrag in einer der drei Formen.

## 6. Risiken und offene Punkte

- Eine Meldung verliert mit der Kennung die einzige Fundstelle für den Anwender. — **Ausgang:** eingetreten: `slice-emittierte-dateien-tragen-nur-im-ziel-aufloesende-kennungen` (übernommen).
- Der Folge-Slice wird nicht gearbeitet; die Eigenschaft bleibt dann ohne Wächter. — **Ausgang:** eingetreten: `slice-emittierte-dateien-tragen-nur-im-ziel-aufloesende-kennungen` (übernommen).

## 7. Closure-Notiz

Geschrieben vom Planner (Gruppierungs-Durchgang, Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur Schritt 3). **Rolle:** Planner · **Datum:** 2026-10-07

- **Gegenstand:** übernommen von `slice-emittierte-dateien-tragen-nur-im-ziel-aufloesende-kennungen`.
- **Was hat funktioniert:** — (keine Arbeit; die Liefer-Punkte bleiben leer).
- **Was ging anders als geplant:** Der Schnitt in Träger-Familie und Rest teilte eine Fundmenge
  unter einem Kommando und erzwang eine Reihenfolge; der Nehmer trägt beides in einem Slice.
- **Steering-Loop-Eintrag:** keiner.
- **Beobachtungs-Register (`../observations/`):** keine Beobachtung angefallen.
- **Folge-Slices:** keiner.
- **Risiken aus §6:** jede Zeile trägt den Ausgang *eingetreten* mit der Kennung des Nehmers.
- **Kennung löst auf:** `ls docs/plan/planning/*/slice-emittierte-dateien-tragen-nur-im-ziel-aufloesende-kennungen.md` nennt genau eine Datei (`open/`).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo, `ALL`): Emissions-Vorlagen; Inklusionskriterium erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen; Treffer: `BEO-ALL/abgeschaffte-kennung-in-unveraenderlichem-artefakt` (verwandt, eingefrorene
Artefakte — nicht berührt) und `BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus`. Zähler-Stand je Eintrag: `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`.

### Sub-Area: `*` (gesamtes Repo)

- **Modus:** GF
- **Konventionen-Dichte:** hoch — [`MR-059`](../../../../harness/conventions.md#mr-059) Setzung 4; Baseline-Regel zum Kommentar steht in [`AGENTS.md`](../../../../AGENTS.md) §3.7.
- **Phase-Reife:** Phase 5.
- **Evidenz-/Diskrepanz-Risiko:** niedrig; Fundmenge gemessen (§1).
- **Reconciliation-Aufwand:** keiner.
