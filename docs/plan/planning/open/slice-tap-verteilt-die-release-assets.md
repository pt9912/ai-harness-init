# Slice slice-tap-verteilt-die-release-assets: Das Tap verteilt die Release-Assets

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Nach dem Test aus Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht beobachtet keine Closure-Bedingung mehr als
diese DoD — der Upload-Schritt, der Formel-Nachzug und der Handbuch-Weg sind
Belege der Liefer-Punkte selbst.

**Bezug:**
[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)
(die Plattform-Matrix — das Tap verteilt dieselben Assets),
[`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
(die `SHA256SUMS` reisen als Asset — die Formel-Nachzug-Form folgt derselben
Kopplung),
[Verifikations-Report](../../../../docs/reviews/2026-09-19-slice-adapter-und-ports-ordner-folgen-ihren-rollen-namen-verifikation.md)
V-2 (die Nachzug-Adressen, die dieser Slice nicht trägt — der Handbuch-Nachzug
läuft zuerst);
Setzung des Auftraggebers vom 2026-09-20: das Tap-Repo ist Auftraggeber-Commit,
die Verteilung läuft formularseitig.

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-20.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten.

**Ziel:** Das Paket-Tap verteilt die Release-Assets in dritter Verteilung —
neben dem GitHub-Release. **Prio hinter dem Handbuch-Nachzug** — drei
Abhängigkeiten: das **Tap-Repo** (formularseitig — das Repo selbst ist
Auftraggeber-Commit, Voraussetzung, nicht Lieferung), der **Workflow-Upload-
Schritt** (der Release-Lauf lädt die Formel je Release hoch — dieselbe
Asset-Kopplung wie `SHA256SUMS` nach
[`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)), und der **Handbuch-Weg 3** (Adresse: §„Das
Werkzeug bereitstellen", Zeile 73 — der dritte Verteil-Weg neben Download und
Quellcode-Bau). Die Formel selbst kommt formularseitig aus dem Skeleton-
Template und folgt dem Formel-Nachzug je Release.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Das Tap-Repo selbst** — **anderer Vorgang:** der Auftraggeber-Commit
  legt es an; der Slice trägt nur die Verdrahtung zu ihm (Upload-Schritt,
  Formel-Nachzug).
- **Kein zweiter Fetch-Weg** — **Bestand bleibt bewusst stehen:** der Fetch
  ([`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  Festlegung 1) bleibt der Träger-Weg; das Tap verteilt Assets, es ersetzt
  keinen Fetch.
- **Kein Re-Publish von `v0.2.1`** — **anderer Vorgang:** der Formel-Nachzug
  gilt für den nächsten Release-Schnitt; das published Release bleibt.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß.

- [ ] **Liefer-Punkt 1 — der Workflow-Upload-Schritt lädt die Formel je
      Release:** der Release-Workflow lädt die Formel als weiteres Asset im
      selben Vorgang wie die sechs Plattform-Assets und die `SHA256SUMS`
      (dieselbe Kopplung wie
      [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
      Festlegung 1); fehlt die Formel im Release, bricht der Tap-Abzug laut
      ab (Analog zur gemessenen SUMS-Form: HTTP 404). Rote Gegenprobe: fehlt
      die Formel, färbt der Abzug rot — gemessen am Abzug gegen ein Release
      ohne Formel-Asset (Konstruktion: das Formel-Asset entsteht erst mit
      diesem Slice).
- [ ] **Liefer-Punkt 2 — der Formel-Nachzug je Release und der Handbuch-Weg
      3:** die Formel-Quelle steht formularseitig (Skeleton-Template), der
      Nachzug fährt je Release, und der Handbuch-Weg 3 nennt das Tap als
      dritten Verteil-Weg (Adresse: Zeile 73). Rote Gegenprobe: nennt der
      Weg ein Release ohne Formel-Asset, färbt `make docs-check` rot — jede
      genannte Adresse löst.
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
| `.github/workflows/release.yml` | update | der Upload-Schritt lädt die Formel je Release (dieselbe Kopplung wie `SHA256SUMS`) |
| Formel-Quelle (Skeleton-Template, formularseitig) | neu | die Formel-Quelle reist formularseitig; der Nachzug fährt je Release |
| `docs/user/benutzerhandbuch.md` | update | der Handbuch-Weg 3 (Adresse: Zeile 73) |

## 4. Trigger

**Start** (`next` → `in-progress`): nach dem Handbuch-Nachzug
([`slice-benutzerhandbuch-nachzug-traegt-fuenf-posten`](../in-progress/slice-benutzerhandbuch-nachzug-traegt-fuenf-posten.md) —
drei Abhängigkeiten: das Tap-Repo (Auftraggeber-Commit) steht, der
Workflow-Schritt und der Handbuch-Weg sind frei), Implementer übernimmt,
WIP-Limit frei.

**Rückführungen:** zu groß → `next`, wenn der Abzug über die Formel hinaus
wächst; blockiert → `open`, falls das Tap-Repo oder die Formel-Quelle
fehlen.

## 5. Closure-Trigger

DoD mit den roten Gegenproben belegt und der Abzug aus dem Tap greift (die
Formel liegt im Release, der Handbuch-Weg nennt sie).

## 6. Risiken und offene Punkte

- **Das Tap-Repo ist Auftraggeber-Commit** — ohne es bricht der Abzug; der
  Slice blockiert auf die Voraussetzung. Ausgang: weiter offen → die
  Sichtung liest die Abhängigkeit bei der nächsten Closure.
- **Der Handbuch-Weg hängt am Nachzug** — läuft der Handbuch-Nachzug zuerst,
  trägt der Weg 3 eine Adresse, die erst mit diesem Slice wahr wird. Ausgang:
  weiter offen → Sichtung.

## 7. Closure-Notiz

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <…>
- **Drei Paarungen:** <…>

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `*` (gesamtes Repo) — der
Release-Workflow und die Nutzer-Doku — und `.github/` (der Workflow-Schritt).
Schwelle ≥ 2 von 3 erfüllt. `*` steht in der Modus-Deklaration als Greenfield.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen am
2026-09-20 (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` →
**151**). Treffer: keine für die Tap-Verteil-Klasse — notiert.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF; kein BF/Hybrid-Block.