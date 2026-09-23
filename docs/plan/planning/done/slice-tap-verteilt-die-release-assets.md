# Slice slice-tap-verteilt-die-release-assets: Das Tap verteilt die Release-Assets

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-v021-faehigkeit](welle-v021-faehigkeit.md) — Mitglied laut
deren §4 (Slices in dieser Welle); die Welle bündelt die Belegbasis-Kette und trägt
über diese DoD hinaus den repo-weiten `make full-smoke`-Beleg als Closure-Bedingung.

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

**Verantwortlich:** Implementer (pt9912)

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

- [x] **Liefer-Punkt 1 — der Workflow-Upload-Schritt lädt die Formel je
      Release:** der Release-Workflow lädt die Formel als weiteres Asset im
      selben Vorgang wie die sechs Plattform-Assets und die `SHA256SUMS`
      (dieselbe Kopplung wie
      [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
      Festlegung 1); fehlt die Formel im Release, bricht der Tap-Abzug laut
      ab (Analog zur gemessenen SUMS-Form: HTTP 404). Rote Gegenprobe: fehlt
      die Formel, färbt der Abzug rot — gemessen am Abzug gegen ein Release
      ohne Formel-Asset (Konstruktion: das Formel-Asset entsteht erst mit
      diesem Slice).
- [x] **Liefer-Punkt 2 — der Formel-Nachzug je Release und der Handbuch-Weg
      3:** die Formel-Quelle steht formularseitig (Skeleton-Template), der
      Nachzug fährt je Release, und der Handbuch-Weg 3 nennt das Tap als
      dritten Verteil-Weg (Adresse: Zeile 73). Rote Gegenprobe: nennt der
      Weg ein Release ohne Formel-Asset, färbt `make docs-check` rot — jede
      genannte Adresse löst.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen
      Brownfield-Bootstrap und führt die Register-Datei nicht.
- [x] Beobachtungs-Register (`../observations/`) fortgeschritten — oder
      „keine Beobachtung angefallen" in §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang; die drei Paarungen sind
      getragen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.github/workflows/release.yml` | update | der Upload-Schritt lädt die Formel je Release (dieselbe Kopplung wie `SHA256SUMS`) |
| Formel-Quelle (Skeleton-Template, formularseitig) | neu | die Formel-Quelle reist formularseitig; der Nachzug fährt je Release |
| `docs/user/benutzerhandbuch.md` | update | der Handbuch-Weg 3 (Adresse: Zeile 73) |

## 4. Trigger

**Start** (`next` → `in-progress`): nach dem Handbuch-Nachzug
([`slice-benutzerhandbuch-nachzug-traegt-fuenf-posten`](../done/slice-benutzerhandbuch-nachzug-traegt-fuenf-posten.md) —
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
  Slice blockiert auf die Voraussetzung. **Ausgang: entfallen** — die
  Scoping-Entscheidung (Tap-Repo = Auftraggeber-Verantwortung) stand bereits
  vor Slice-Start fest (Setzung vom 2026-09-20, siehe Kopf); das physische
  Repo bleibt bewusst außerhalb dieses Slice (§1-Ausschluss) und wird vom
  Handbuch selbst als ausstehend benannt (`benutzerhandbuch.md`, Weg C, Zeile
  ~153). Der Slice trägt nur die Verdrahtung zu ihm (Upload-Schritt,
  Formel-Nachzug) und hat diesen Teil geliefert; das Risiko, das den
  physischen Repo-Aufbau betraf, wird durch die Setzung selbst gegenstandslos
  — es ist keine Aussage darüber, dass das Repo existiert.
- **Der Handbuch-Weg hängt am Nachzug** — läuft der Handbuch-Nachzug zuerst,
  trägt der Weg 3 eine Adresse, die erst mit diesem Slice wahr wird.
  **Ausgang: entfallen** — `slice-benutzerhandbuch-nachzug-traegt-fuenf-posten`
  liegt in `done/` und lief laut §4-Trigger bereits vor diesem Slice; die
  Reihenfolge-Voraussetzung war beim Slice-Start bereits erfüllt.

## 7. Closure-Notiz

- **Was hat funktioniert:** Die Asset-Kopplung nach dem Muster von
  [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
  (Formel reist als weiteres Release-Asset im selben
  Upload-Schritt wie die sechs Plattform-Assets und `SHA256SUMS`) ließ sich
  ohne neue Mechanik übernehmen; die rote Gegenprobe für Liefer-Punkt 2
  (falscher Pfad im Handbuch → `docs-check` rot) wurde real gezogen und
  zurückgesetzt. Review lief ohne HIGH-Finding, Negativbefunde decken
  Umfangs-Treue, Sequenzierung, Platzhalter-Vollständigkeit und die
  §1-Abgrenzung.
- **Was ging anders als geplant:** Der Fail-Closed-Guard im neuen
  Workflow-Schritt (Abbruch vor dem Formel-Schreiben, wenn ein
  Plattform-Digest in `SHA256SUMS` fehlt) trug im ersten Durchgang keinen
  für **ihn** dokumentierten Rot-Beleg — die im DoD genannten roten
  Gegenproben (HTTP-404 gegen `v0.2.1`, `docs-check`-Pfadfehler) prüfen
  andere Fehlerbilder (Review-Finding F-1, MEDIUM). Der Nachzug
  (`1f156fed`) hat den Guard-Rot-Beleg nachgetragen und mit einem
  `test/release-matrix.bats`-Fall dauerhaft gesichert.
- **Steering-Loop-Eintrag:** Fail-Closed-Logik, die inline in einem
  Workflow-Schritt (`run:`-Block) entsteht, bekommt ihren Rot-Beleg leicht
  vergessen, weil die DoD-Gegenproben für den *Liefer-Punkt* geschrieben
  werden, nicht für jede einzelne Zusage, die der Schritt nebenbei trägt
  (AGENTS.md §3.6). Gelernte Lektion für künftige Workflow-Slices: eine
  Fail-Closed-Prüfung gehört von Anfang an in ein eigenes, testbares Skript
  statt inline in den Workflow-Schritt — dann zieht ein Bats-Fall den
  Rot-Beleg mit, statt ihn im Review nachzutragen. Diese Lektion steht hier
  als Erwähnung; ein Registereintrag entsteht nicht — die Beobachtungen
  wurden gegen `docs/plan/planning/observations/BEO-ALL/` geprüft (Muster
  „inline Workflow-Logik ohne Rot-Beleg"), kein bestehender Eintrag deckt
  genau dieses Muster, und es ist bislang ein Einzelfall (dieser Slice).
  Tritt dasselbe Muster in einem weiteren Slice auf, ist es beim zweiten
  Auftreten als neue Beobachtung anzulegen.
- **Beobachtungs-Register (`../observations/`):** keine neue Beobachtung
  angelegt (siehe Steering-Loop-Eintrag oben) — Sichtung am 2026-09-20 (§8)
  hatte bereits keine Treffer für die Tap-Verteil-Klasse; die einzige neue
  Erkenntnis (F-1-Muster) bleibt unter der Schwelle einer Registeranlage.
- **Folge-Slices:** keine.
- **Risiken aus §6:** beide *entfallen* (siehe §6 oben, mit Begründung).
- **Drei Paarungen:** (a) Anker-Paarung — kein Eintrag mit `liegt in
  <Zielort>` in diesem §7, daher kein Gegenstand der Paarung. (b)
  Folge-Slice-Paarung — kein Folge-Slice genannt, daher kein Gegenstand der
  Paarung. (c) Register-Paarung — kein neuer Registerverweis in diesem §7,
  daher kein Gegenstand der Paarung.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `*` (gesamtes Repo) — der
Release-Workflow und die Nutzer-Doku — und `.github/` (der Workflow-Schritt).
Schwelle ≥ 2 von 3 erfüllt. `*` steht in der Modus-Deklaration als Greenfield.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen am
2026-09-20 (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` →
**151**). Treffer: keine für die Tap-Verteil-Klasse — notiert.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF; kein BF/Hybrid-Block.