# Slice slice-benutzerhandbuch-nachzug-traegt-fuenf-posten: Der Handbuch-Nachzug trägt die fünf Posten

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-v021-faehigkeit](../welle-v021-faehigkeit.md) — Mitglied laut
deren §4 (Slices in dieser Welle); die Welle bündelt die Belegbasis-Kette und trägt
über diese DoD hinaus den repo-weiten `make full-smoke`-Beleg als Closure-Bedingung.

**Bezug:**
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)
(der Init-Aufruf trägt die Zielordner-Form), [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)
(die Software-Stand-Zusage am Download-Weg),
[`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
(der Ziel-Fetch, den der Klon-Abschnitt misst),
[Verifikations-Report](../../../../docs/reviews/2026-09-19-slice-adapter-und-ports-ordner-folgen-ihren-rollen-namen-verifikation.md)
V-2 (die `:298`-Ports-Form als Nachzug-Posten);
Setzung des Auftraggebers vom 2026-09-20: der pausierte Nachzug trägt die
fünf Posten in einem Vorgang.

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-09-20.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten.

**Ziel:** Der pausierte Handbuch-Nachzug läuft — fünf Posten, je eine Adresse
im [`benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md):

1. **Software-Stand:** der Download-Weg trägt die aktuelle Fassung (`v0.2.1`
   plus die seit Juli gewachsenen Fähigkeiten) — Adresse: §„Das Werkzeug
   bereitstellen" (Zeile 73).
2. **Die vier Operationen:** `archive-welle`, `span-report`, `span-clean`,
   `traeger-fetch` — Adresse: ein Betriebs-Abschnitt unter §„Aufgaben" (er
   trägt sie heute nicht).
3. **Der Klon-Abschnitt:** „Sie haben ein aufgesetztes Repo geklont — was
   fehlt, was funktioniert, wie der Träger zurückkommt" — Adresse: §„Das
   aufgesetzte Repository prüfen" (Zeile 302).
4. **Die Zielordner-Form:** der Init-Aufruf trägt die Ziel-Form
   (`ai-harness-init --lang go --name "X" <zielordner>`) — Adresse: die
   Aufruf-Formen unter §„Aufgaben" (Zeile 209/221).
5. **Die Ports-Form:** Zeile 298 weist den Adopter auf „unter `ports`" nach —
   die emittierte Config führt `ports_inbound`/`ports_outbound` mit je
   `direction:`; die Adresse trägt die neue Gliederung. Das Handbuch bleibt
   bis zum Implementer-Zug unangetastet.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Release-Text** — **anderer Vorgang:** die Release-Notes sind
  veröffentlicht und liegen außerhalb des Repos.
- **Kein Tap-Weg** — **anderer Vorgang:**
  `slice-tap-verteilt-die-release-assets` trägt den dritten Download-Weg und
  läuft nach diesem Slice.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß.

- [ ] **Liefer-Punkt 1 — die drei Stand-Posten:** Software-Stand (Adresse
      Zeile 73), Klon-Abschnitt (Zeile 302) und die Ports-Form (Zeile 298)
      tragen die aktuelle Lage; jede Adresse existiert und löst. Rote
      Gegenprobe: verweist das Handbuch auf eine Sektion, die es nicht
      trägt, färbt `make docs-check` (Modul `links`) rot.
- [ ] **Liefer-Punkt 2 — die Operations- und Aufruf-Posten:** der
      Betriebs-Abschnitt trägt die vier Operationen (Adresse: neuer Abschnitt
      unter §„Aufgaben"), und die Aufruf-Formen tragen die Ziel-Form
      (Zeilen 209/221). Rote Gegenprobe: nennt der Abschnitt eine Operation
      ohne Träger, färbt `make docs-check` rot — jede genannte Adresse löst.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen
      Brownfield-Bootstrap und führt die Register-Datei nicht.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschritten — oder
      „keine Beobachtung angefallen" in §7.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang; die drei Paarungen sind
      getragen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/user/benutzerhandbuch.md` | update | die fünf Posten an ihren Adressen (Zeilen 73, 302, 298, 209/221, neuer Betriebs-Abschnitt) |

## 4. Trigger

**Start** (`next` → `in-progress`): Implementer übernimmt, WIP-Limit frei.

**Rückführungen:** zu groß → `next`, wenn ein Posten eine eigene
Mechanik-Änderung braucht; blockiert → `open`, falls eine Adresse wegfällt.

## 5. Closure-Trigger

DoD belegt und `make docs-check` grün über dem nachgezogenen Handbuch.

## 6. Risiken und offene Punkte

- **Die Adressen wandern mit dem Handbuch** — die Zeilen-Adressen tragen den
  Stand; eine Verschiebung verliert die Adresse. Ausgang: weiter offen →
  die Sichtung liest die Posten bei der nächsten Closure.

## 7. Closure-Notiz

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <…>
- **Drei Paarungen:** <…>

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — die
Nutzer-Doku. Schwelle ≥ 2 von 3 erfüllt. `*` steht in der Modus-Deklaration
als Greenfield.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen am
2026-09-20 (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` →
**151**). Treffer: keine für die Handbuch-Nachzug-Klasse — notiert.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF; kein BF/Hybrid-Block.