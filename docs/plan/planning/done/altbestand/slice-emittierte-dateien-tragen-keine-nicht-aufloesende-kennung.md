# Slice slice-emittierte-dateien-tragen-keine-nicht-aufloesende-kennung: Der Rest der emittierten Dateien trägt keine nicht auflösende Kennung, und ein Wächter hält die Menge

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt; er wechselt nur durch `git mv`.

**Welle:** ohne Welle — keine Closure-Bedingung, die mehr beobachtet als die DoD ([`MR-037`](../../../../harness/conventions.md#mr-037)).

**Ebene: emittiert, nicht Dogfood.** Gegenstand sind die emittierten Vorlagen außerhalb der Träger-Familie und ein Go-Test in `internal/emit/`.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`MR-057`](../../../../harness/conventions.md#mr-057), [`MR-059`](../../../../harness/conventions.md#mr-059) (Setzung 4 und die Fundmenge).
Eigenschaft: Architect-Bericht `2026-10-06-architect-emittierte-kennungen.md` (Verdikt 1 und 3).

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-06.

---

## 1. Ziel und Abgrenzung

**Ziel:** Die übrigen emittierten Dateien tragen keine Kennung, die im Ziel nicht auflöst, und ein Go-Test in `internal/emit/` hält die Eigenschaft über alle
Lauf-Varianten mit namentlicher Fundmenge (Datei → Kennungs-Menge), Gleichheit in beide Richtungen ([`MR-059`](../../../../harness/conventions.md#mr-059)).

**Lage, nachgemessen** (Kommando wie in `slice-emittierte-traeger-dateien-tragen-keine-werkzeug-kennung`, über `internal/emit/templates` und die Go-Strings in `internal/emit/*.go`):

- 23 Zeilen in 8 Dateien: `hooks-install.mk` 4, `selbstpruefung.sh` 5, `span-emit.sh` 4, `selbstpruefung.mk` 3, `emit.go` (Doc-Gate-Fragment) 3,
  `baseline-verify.sh` 2, `e2e-abdeckung.mk` 1, `d-check.yml` 1.
- Davon 17 Kommentare, 4 Meldungen (`hooks-install.mk:48`, `selbstpruefung.sh:203`, `emit.go:106`, `emit.go:114`) und **2 funktionale Nutzlast**: der Default-Commit-Text
  [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) in `selbstpruefung.sh:87` und `selbstpruefung.mk:39` muss ein Kennungs-Muster des Ziels treffen. Sie bleiben als namentliche Ausnahme.

**Entscheidung zur Lage des Wächters:** der Test gehört in **diesen** Slice, den zweiten der beiden Rest-Schnitte: er startet grün, ohne Ausnahmeliste für
die Träger-Familie. Der Gegenentwurf (Wächter zuerst mit 49-Zeilen-Ausnahmeliste, die der zweite Slice leert) braucht zwei Listen-Pflegen und lässt eine Fundmenge
im Test stehen, die ausdrücklich noch falsch ist. Den Preis trägt die Reihenfolge: dieser Slice startet erst, wenn der Träger-Slice in `done/` liegt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Träger-Familie (`traeger-fetch.sh`, `traeger.mk`, 26 Zeilen):** `slice-emittierte-traeger-dateien-tragen-keine-werkzeug-kennung` trägt sie; er schließt vor dem Start dieses
  Slice (Start-Trigger §4), sonst ist die Fundmenge des Wächters falsch.
- **Zweige, die der Test nicht fährt** (nicht gesetzte Flag-Kombinationen): benannte Lücke, kein Sensor.
- **Prosa-Verweise ohne Ziffernform** und die Frage, ob der Ersatz-Wortlaut die Zusage trägt: Urteil, kein Sensor.
- **Kennungen des Ziels selbst** (Platzhalter-Form, emittierte Register): zulässig; der Wächter sucht die Ziffernform mit `\b`-Bindung.

## 2. Definition of Done

- [ ] **(1) Die 17 Kommentare und 4 Meldungen des Rests tragen Wortlaut statt Kennung;** Tests, die eine dieser Meldungen zitieren, ziehen mit. Die zwei Nutzlast-Zeilen bleiben.
      *Bricht, wenn:* der Wächter aus Punkt 2 eine Kennung außerhalb der Ausnahmeliste findet.
- [ ] **(2) Ein Go-Test in `internal/emit/` emittiert jede Lauf-Variante (Sprache, `--arch`, mit/ohne Erfassung) in ein Temp-Verzeichnis,** durchläuft jede Datei und vergleicht die
      Fundmenge (`\b(ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3})\b`) mit der namentlichen Liste *Datei → Kennungs-Menge* auf **Gleichheit in beide Richtungen**: heute die zwei Nutzlast-Zeilen
      (`selbstpruefung.sh`, `selbstpruefung.mk`: [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)). Der Test läuft über die **reale** Emission, nicht über eine nachgebaute Eingabe. **Rot gesehen, beide Richtungen:** eine erfundene ADR-Kennung der Ziffernform in eine
      Vorlage geschrieben → rot mit Dateiname; eine Ausnahme aus der Liste gestrichen → rot. Ein Fall in `test/mutations/` führt die erste Mutation (`sed`-Anker gegen den Quell-Bestand gemessen,
      [`MR-071`](../../../../harness/conventions.md#mr-071)). *Bricht, wenn:* eine Kennung in irgendeiner emittierten Datei der gefahrenen Varianten steht, oder eine Ausnahme ohne Fund in der Liste bleibt.

Standard (zählen nicht): `make gates` grün · `make mutate` für den neuen Fall ohne Befund · Review-Report (kein Self-Review) · Closure-Notiz mit Lerneintrag · Register fortgeschrieben · Risiko-Ausgänge · drei Paarungen.

## 3. Plan (vor Code)

| Datei | Änderungs-Art | Begründung |
|---|---|---|
| `hooks-install.mk`, `selbstpruefung.sh`, `selbstpruefung.mk`, `span-emit.sh`, `baseline-verify.sh`, `e2e-abdeckung.mk`, `d-check.yml` (alle unter `internal/emit/templates/`) | update | DoD (1) |
| `internal/emit/emit.go` | update | DoD (1): Doc-Gate-Fragment, Kommentar und zwei Meldungen |
| `internal/emit/` (neue Test-Datei), `test/mutations/` | neu | DoD (2) |

Zwei Schichten: Emissions-Vorlagen und Go-Test.

## 4. Trigger

**Start** (`next` → `in-progress`): `slice-emittierte-traeger-dateien-tragen-keine-werkzeug-kennung` liegt in `done/` (beobachtbar: `ls docs/plan/planning/done/slice-emittierte-traeger-dateien-tragen-keine-werkzeug-kennung.md`).

**Rückführungen:**

- `in-progress` → `next`: die Nachmessung findet Kennungen in Lauf-Varianten, die die Fundmenge nicht benennt — Wächter und Text trennen.
- `in-progress` → `open`: der Träger-Slice wird zurückgeführt.

## 5. Closure-Trigger

`make gates` grün; der Wächter ist in beiden Richtungen rot gesehen, `make mutate` für den Fall ohne Befund. Dazu ein Lerneintrag in einer der drei Formen.

## 6. Risiken und offene Punkte

- Eine Lauf-Variante emittiert eine Datei, die der Test nicht fährt. — **Ausgang:** eingetreten: `slice-emittierte-dateien-tragen-nur-im-ziel-aufloesende-kennungen` (übernommen).
- Der Ersatz-Wortlaut trägt die Zusage nicht. — **Ausgang:** eingetreten: `slice-emittierte-dateien-tragen-nur-im-ziel-aufloesende-kennungen` (übernommen).

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo, `ALL`): Emissions-Vorlagen und Go-Test; Inklusionskriterium erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen; Treffer: `BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`,
`BEO-ALL/erkennende-regel-ueber-text-waechst-ueber-ihren-schnitt`. Zähler-Stand je Eintrag: `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`.

### Sub-Area: `*` (gesamtes Repo)

- **Modus:** GF
- **Konventionen-Dichte:** hoch — [`MR-059`](../../../../harness/conventions.md#mr-059); [`AGENTS.md`](../../../../AGENTS.md) §3.6/§3.7.
- **Phase-Reife:** Phase 5.
- **Evidenz-/Diskrepanz-Risiko:** niedrig; Fundmenge gemessen (§1).
- **Reconciliation-Aufwand:** keiner.
