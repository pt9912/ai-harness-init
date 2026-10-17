# Slice slice-spezifikation-nennt-zeitbezuege-als-zielbild: Zwei Zeitbezüge der Spezifikation als Zielbild prüfen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Es gibt keine Closure-Bedingung, die über die DoD dieses Slice hinausgeht
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:** [`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans) (beide Stellen tragen
diese Anforderung in der Spalte *Präzisiert*),
[`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)
(Technik-Stratum).

**Berührte Spec-Stellen:** `SPEC-039` (Satz *„die Aussage entfällt, sobald …"*) · `SPEC-093` (Halbsatz
*„seit dem Feld `rule_version` …"*) in `spec/spezifikation.md` §5.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-17.

---

## 1. Ziel und Abgrenzung

**Ziel:** Jede der zwei Stellen ist entweder bedeutungstreu als Zielbild im Indikativ gefasst (was gilt, nicht
seit wann oder bis wann) oder als stehenbleibend begründet; eine Messung mit erweiterten Mustern zeigt über der
Spezifikation (ohne Historie §8) nur benannte Treffer.

**Herkunft:** Der Auftraggeber hat am 2026-10-17 das Prinzip für „die Specs, auch das Lastenheft" gesetzt; der
Vorgänger `slice-spec-beschreibt-das-zielbild-nicht-den-lieferstand` hat die Spezifikation als unberührt geführt,
weil seine Muster dort keinen Befund der Klasse A fanden. Die zwei Stellen fielen erst in der erweiterten Suche
seiner Verifikation auf.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Sensor für Zeit-/Liefer-Aussagen.** *Anderer Vorgang:* die Messgrenze steht im Register
  (`BEO-ALL/spec-nennt-den-lieferstand-statt-des-zielbilds`); ein Folge-Slice dafür braucht einen Auslöser.
- **Lastenheft und Architektur-Sicht bleiben.** *Bestand bleibt bewusst stehen:* beide hat der Vorgänger gefasst.
- **Keine Entscheidung zur schreibenden Rolle für `spec/spezifikation.md`.** *Anderer Vorgang:* sie liegt bei
  [slice-151](../next/slice-151-spec-straten-haben-eine-schreibende-rolle.md).
- **Die Historie (§8) bleibt.** *Bestand:* ein Protokoll nennt Zeit.

## 2. Definition of Done

- [ ] **(1) Zwei Stellen entschieden:** `SPEC-039` und `SPEC-093` sind je bedeutungstreu als Zielbild gefasst oder
      mit Grund stehengelassen (eine Auflösungs-Bedingung einer Abweichung kann eine Grenze sein, kein Zeitbezug).
- [ ] **(2) Messung mit Rot:** Muster *sobald · seit · entfällt · vorher · früher · nicht mehr · bis* über der
      Spezifikation bis vor §8 zeigt nur benannte Treffer; ein eingefügter Satz *„… sobald …"* lässt die Zählung steigen.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register fortgeschrieben (`BEO-ALL/spec-nennt-den-lieferstand-statt-des-zielbilds`, Beleg).
- [ ] Jedes Risiko aus §6 trägt einen Ausgang.
- [ ] Die drei Paarungen sind getragen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `spec/spezifikation.md` §5, Zeilen `SPEC-039`, `SPEC-093` | update, falls bedeutungstreu fassbar | Liefer-Punkt (1); Historie-Zeile nach §8 der Spezifikation, Marker mitziehen |

Die Zeile wird über ihren Wortlaut gefunden, nicht über die Nummer. Bedeutungstreue prüft der Vorher/Nachher-Vergleich
je Satz in der Closure-Notiz.

## 4. Trigger

**Start** (`next` → `in-progress`): die schreibende Rolle für `spec/spezifikation.md` ist durch slice-151 entschieden
oder der Auftraggeber benennt sie für diesen Slice; WIP-Limit frei.

**Rückführungen:**

- `in-progress` → `next`: die Fassung verändert eine Zusage und verlangt eine Entscheidung zu [`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans).
- `in-progress` → `open`: die schreibende Rolle bleibt offen.

## 5. Closure-Trigger

DoD (1) und (2), `make gates` grün; Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Die Fassung als Zielbild ändert die Bedeutung von `SPEC-039` (Abweichung 5, Auflösungs-Bedingung) — **Ausgang:**
  offen bis Closure; Gegenprobe ist der Vorher/Nachher-Vergleich.
- Die erweiterten Muster erfassen Formulierungen ohne Signalwort nicht — **Ausgang:** weiter offen →
  `BEO-ALL/spec-nennt-den-lieferstand-statt-des-zielbilds` im Register.

## 7. Closure-Notiz

Wird bei der Closure im Planner-Kontext geschrieben ([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist allein `ALL` (`spec/spezifikation.md`).

**Vorgelagert — offene Beobachtungen sichten:** Treffer
[`BEO-ALL/spec-nennt-den-lieferstand-statt-des-zielbilds`](../observations/BEO-ALL/spec-nennt-den-lieferstand-statt-des-zielbilds/observation.md)
(Zähler 1 am 2026-10-17, `offen`); dieser Slice ist ein zweiter Vorgang der Klasse, ein Beleg ist zu erwarten.

Alle berührten Sub-Areas GF.
