# Slice slice-084: Stichprobe gegen den Bestand, nicht gegen das Delta

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-10](../welle-10-re-baseline.md).

**Bezug:** [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) — die Aussage
*„keine inhaltlichen Adaptionen ggü. Baseline-Default"* ist genau die, über die diese Stichprobe
etwas herausfindet.

**Autor:** Planner. **Datum:** 2026-08-09.

---

## 1. Ziel

Ein Abschnitt der Baseline, der **kein Delta** hatte, ist gegen die ausgefüllten Artefakte
geprüft. Sein Gegenstand ist der **Bestand**, nicht die Änderung — deshalb läuft er unabhängig
vom Ergebnis der Tag-Frage und hätte auch bei aktuellem Pin zu laufen.

**Warum das eine eigene Eigenschaft der Prozedur ist:** Eine Baseline-Regel, die **nie** ins
ausgefüllte Artefakt übernommen wurde und sich seither **nie** geändert hat, erzeugt keinen
Template-Diff und hat keinen Eintrag, den der Adaptions-Durchgang abschreiten könnte. Sie ist
unsichtbar, *weil* sie alt und stabil ist.

**Der Präzedenzfall ist dieses Repo.** Modul 15 lag seit `554cade` (2026-07-17) vendored im Baum,
taucht in vier Commits auf — allesamt Re-Vendor — und war nie inhaltlich behandelt; das wurde der
Trigger von [welle-09](../welle-09-modul-15-konformitaet.md). Die Ursache ist mechanisch: die
Adoptions-Prüfung sieht bei jeder Re-Baseline nur das Delta, nie den Bestand.

## 2. Definition of Done

- [ ] Ein Abschnitt **ohne Delta** ist gewählt und die Wahl belegt — die Komplementärmenge zu
      `git diff <alt> <neu> -- .harness/baseline/`. Umfang: **genau ein** Abschnitt, keine
      Vollinventur.
- [ ] Je Regel dieses Abschnitts ist beantwortet: *Steht sie im ausgefüllten Artefakt — oder als
      deklarierte Abweichung?* Zweimal nein heißt: nie übernommen.
- [ ] Der Ausgang ist verbucht: **ein** Fund geht den Weg jeder Diskrepanz (Übernahme im nächsten
      Slice oder Carveout mit Auflösungs-Trigger); **mehrere** Funde treffen nicht die einzelne
      Regel, sondern die
      [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)-Aussage — sie ist
      dann falsch und wird korrigiert.
- [ ] `make gates` grün.
- [ ] Doku-Update: nur bei Fund — Übernahme im ausgefüllten Artefakt oder deklarierte Abweichung.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| dieser Slice, §7 | update | der geprüfte Abschnitt und sein Ergebnis — die Rotation braucht ein Gedächtnis |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update, **nur bei Fund** | Übernahme oder deklarierte Abweichung |
| `docs/plan/carveouts/` bzw. `docs/plan/planning/open/` | neu, **nur bei Fund** | Carveout mit Auflösungs-Trigger oder Folge-Slice |

## 4. Trigger

[slice-081](slice-081-baum-tauschen-pin-ziehen.md) liegt in `done/`. **Nicht** abhängig vom
Adaptions-Durchgang: sein Gegenstand ist die Änderung, dieser hier prüft den Bestand.

Rückführungen: `in-progress` → `next`, wenn der gewählte Abschnitt mehrere Artefakte gleichzeitig
trifft und die Prüfung zur Inventur wird. `in-progress` → `open`, wenn ein Fund eine Entscheidung
verlangt, die über diesen Slice hinausreicht.

## 5. Closure-Trigger

DoD vollständig, Closure-Notiz geschrieben — inklusive der Angabe, **welcher** Abschnitt geprüft
wurde.

## 6. Risiken und offene Punkte

- **Die Versuchung ist die Vollinventur.** Ein Abschnitt pro Audit, rotierend; die Prozedur nennt
  den Grund selbst — sonst verliert die Welle ihr Closure-Kriterium.
- **Die Rotation hat kein Gedächtnis außer der Closure-Notiz.** Welcher Abschnitt zuletzt geprüft
  wurde, steht danach in §7 dieses Slice und in `welle-10-results.md`; ein Sensor, der die Rotation
  führt, existiert nicht. Das ist eine benannte Lücke, keine Zusage.
- **Eine BF-Markierung ist hier nicht die Antwort.** Sie regelt Doc ↔ Code und trifft die Achse
  nicht, um die es geht (Baseline ↔ ausgefülltes Artefakt).
- **Mehrere Funde sind der interessante Fall.** Dann ist nicht eine Regel offen, sondern eine
  Aussage über das ganze Repo falsch — und die Korrektur ist größer als dieser Slice. Sie wird
  benannt und geschnitten, nicht hier erledigt.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `harness/` und
`docs/plan/` gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
