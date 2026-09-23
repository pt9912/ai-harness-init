# Slice slice-benutzerhandbuch-nachzug-traegt-fuenf-posten: Der Handbuch-Nachzug trägt die fünf Posten

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-v021-faehigkeit](welle-v021-faehigkeit.md) — Mitglied laut
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

- [x] **Liefer-Punkt 1 — die drei Stand-Posten:** Software-Stand (Adresse
      Zeile 4/75), Klon-Abschnitt (Adresse ~Zeile 315-321) und die Ports-Form
      (Adresse Zeile 298) tragen die aktuelle Lage; jede Adresse existiert und
      löst. Rote Gegenprobe: verweist das Handbuch auf eine Sektion, die es
      nicht trägt, färbt `make docs-check` (Modul `links`) rot.
      **Belegt:** Initial in `be39594a`. Review-Runde-1-HIGH F-1 (Software-Stand-
      und Ports-Form-Zeile banden die neue Rollen-Namensform fälschlich an das
      veröffentlichte `v0.2.1`, obwohl [ADR-0060](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)
      §Konsequenzen das Gegenteil festhält) behoben in `26bdaa15` und in
      Review-Runde 2 unabhängig mit `git merge-base --is-ancestor 366c8837
      v0.2.1` (Exit 1) verifiziert — siehe
      [Runde-1-Report](../../../reviews/2026-09-20-slice-benutzerhandbuch-nachzug-traegt-fuenf-posten.md)
      F-1 und
      [Runde-2-Report](../../../reviews/2026-09-20-slice-benutzerhandbuch-nachzug-traegt-fuenf-posten-runde-2.md)
      §F-1-Prüfung („Urteil F-1: geschlossen").
- [x] **Liefer-Punkt 2 — die Operations- und Aufruf-Posten:** der
      Betriebs-Abschnitt trägt die vier Operationen (Adresse: §„Betriebs-
      Operationen", Zeile ~362), und die Aufruf-Formen tragen die Ziel-Form
      (Zeilen 209/221 — Runde-1-Negativbefund: unverändert bereits aktuell,
      siehe unten). Rote Gegenprobe: nennt der Abschnitt eine Operation ohne
      Träger oder mit falscher Docker-/Träger-Zuordnung, färbt kein
      `make docs-check`-Modul (reine Tatsachenbehauptung, kein Link), sondern
      nur ein Review, das den vollständigen Bereich gegen die
      `.mk`-Referenz prüft.
      **Belegt:** Initial in `be39594a`. Zielordner-Form (Zeilen 209/221)
      Runde-1-Negativbefund „geprüft, ohne Befund" (bereits aktuell durch
      `slice-zielordner-richtet-das-werkzeug-auf-ein-ziel-repo`). Drei
      Fehlklassifikationen der Vier-Kommandos-Gruppe (Docker-Bedarf/Träger-
      Vorbedingung/Träger-Unabhängigkeit über `traeger-fetch`/`archive-welle`/
      `span-report`/`span-clean`) über zwei Runden gefunden und behoben:
      F-2/F-3 (Runde 1, `26bdaa15`), F-5/F-6 (Runde 2, `02670bed`); Runde 3
      (angehängt an den Runde-2-Report) fährt einen vollständigen
      Satz-für-Satz-Durchgang über den gesamten betroffenen Bereich (16
      Einzelaussagen, nicht nur die benannten Sätze) und findet **keine**
      vierte Fehlstelle — siehe
      [Runde-2/3-Report](../../../reviews/2026-09-20-slice-benutzerhandbuch-nachzug-traegt-fuenf-posten-runde-2.md)
      §Runde 3 §Satz-für-Satz-Durchgang.
- [x] `make gates` grün. Verifiziert vom Verifier inhaltsbasiert auf dem
      Stand nach `02670bed` (Arbeitsbaum-Hash in
      `.harness/state/gates-passed.diffsha` stimmt exakt, inklusive der
      beiden — zum Zeitpunkt der Verifikation bereits vorliegenden, jetzt
      erst committeten — Review-Report-Dateien unter `docs/reviews/`).
      Vom Planner bei dieser Closure erneut selbst gefahren (2026-09-20) auf
      demselben Commit plus den beiden Review-Report-Dateien und den beiden
      neuen Register-Einträgen aus §7: Hash `30cd07ef3a4f9d7e…` in
      `.harness/state/gates-passed.diffsha`, alle Recipes bis `span-check`
      durchlaufen (`record-gates` bricht bei jedem roten Prerequisite vor
      dem Hash-Schreiben ab, Mechanik: `Makefile:record-gates`).
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8). Drei
      Runden:
      [Runde 1](../../../reviews/2026-09-20-slice-benutzerhandbuch-nachzug-traegt-fuenf-posten.md)
      (1 HIGH, 2 MEDIUM, 1 INFO),
      [Runde 2 + Runde 3](../../../reviews/2026-09-20-slice-benutzerhandbuch-nachzug-traegt-fuenf-posten-runde-2.md)
      (Runde 2: 0 HIGH, 2 MEDIUM neu; Runde 3: 0 Findings nach vollständigem
      Durchgang, merge-blockierend: nein).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag — siehe §7.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen
      Brownfield-Bootstrap und führt die Register-Datei nicht.
- [x] Beobachtungs-Register (`../observations/`) fortgeschritten — siehe §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang; die drei Paarungen sind
      getragen — siehe §6/§7.

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
  Stand; eine Verschiebung verliert die Adresse. **Ausgang: weiter offen.**
  Eingetreten während dieses Slice selbst: die drei Implementierungs-Commits
  haben Zeilen verschoben (der Klon-Absatz wanderte von der im Plan
  zitierten Zeile 302 auf ~315-321, der Betriebs-Operationen-Vorspann auf
  ~362-367), ohne dass ein Sensor das anzeigt — kein Fix in diesem Slice: die
  Zeilen-Adresse bleibt die einzige Adressform für Prosa-Zitate in
  Slice-Plänen. In
  [`../observations/BEO-ALL/zeilen-adressen-im-handbuch-wandern-mit-umstrukturierung/`](../observations/BEO-ALL/zeilen-adressen-im-handbuch-wandern-mit-umstrukturierung/observation.md)
  eingetragen (1×, `offen`).

## 7. Closure-Notiz

- **Was hat funktioniert:** Die Rollen-Trennung Implementer/Reviewer über
  drei Runden hat den eigentlichen Fehler gefangen — nicht die erste Runde
  allein. Runde 1 fand die Kern-Tatsachenverletzung (F-1 HIGH, Rollen-
  Namensform fälschlich an `v0.2.1` gebunden) und zwei Pauschal-Aussagen
  (F-2/F-3). Runde 2 verifizierte den F-1-Fix unabhängig
  (`git merge-base --is-ancestor 366c8837 v0.2.1` → Exit 1) und fand, dass
  der F-2/F-3-Fix an denselben Stellen zwei neue Fehlklassifikationen
  derselben Art einführte (F-5/F-6) — ein Fund, den ein Self-Review mit
  hoher Wahrscheinlichkeit übersehen hätte, weil derselbe Kontext, der den
  Fix schrieb, seine eigene Korrektur naheliegend für vollständig hält.
  Runde 3 ging über die explizit benannten Sätze hinaus und fuhr einen
  vollständigen Satz-für-Satz-Durchgang über den ganzen betroffenen Bereich
  (16 Einzelaussagen) — das fing die Möglichkeit einer vierten,
  unbenannten Fehlstelle, die ein enger, nur auf F-5/F-6 skopierter
  Nachzugs-Review nicht geprüft hätte. Verifikation (DoD/Spec, Gate-Hash)
  lief mit wieder anderem Eingabe-Kontext und fand keine DoD-Verletzung —
  drei unterschiedliche Blickwinkel, keine Redundanz (Modul 8).
- **Was ging anders als geplant:** Der Slice-Plan sah keine Mehrfach-Runden
  vor; §5 nennt einen einzigen Closure-Trigger. Tatsächlich brauchte es drei
  Review-Durchgänge, weil derselbe Implementer-Kontext, der einen Fund in
  einer Vier-Kommandos-×-Drei-Eigenschaften-Klassifikation korrigierte,
  zweimal hintereinander an einer *anderen* Zelle derselben Klassifikation
  denselben Fehlertyp neu einführte, statt beim Korrigieren den ganzen
  Bereich gegen die Referenz (`erfassung.mk`/`archivierung.mk`/`traeger.mk`/
  `traeger-fetch.sh`) neu durchzugehen. Das ist die Fehlerklasse, die unten
  als Steering-Loop-Kandidat geprüft wird.
- **Steering-Loop-Eintrag:** Da dieser Slice zur Welle
  `welle-v021-faehigkeit` gehört (§Kopf `Welle:`), aber die Welle selbst
  noch offen ist (nicht alle sieben Mitglieds-Slices in `done/`), laufen
  Lese-Schritt und Trigger-Audit dennoch **hier**, weil das Beobachtungs-
  Register bei **jeder** Slice-Closure fortgeschrieben wird
  (Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register,
  „Wer schreibt, wer liest"). Lese-Schritt: keine Registerzeile erreicht mit
  diesem Slice 3× — beide unten neu angelegten Beobachtungen stehen bei 1×,
  `offen`, kein Zielort verkörpert. Geprüft und **kein passender Treffer
  gefunden**: Stichwortsuche im Bestand
  (`grep -rliE 'kreuzprodukt|klassifikation|fehlklassifikation|zuordnungsfehler'
  docs/plan/planning/observations/*/*/observation.md`) traf nur
  `BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger` — eine andere
  Klasse (fehlender Träger einer Vorlagen-Klassifikation, nicht ein Fix, der
  einen Fall korrigiert und einen anderen neu einführt). Neue Beobachtung
  angelegt (siehe unten) statt Folge-Slice: Bei 1× ist ein eigener Slice
  verfrüht — der Kandidat ist real und benennbar, aber eine einzelne
  Instanz (auch wenn sie sich innerhalb dieses einen Vorgangs zweimal
  wiederholte, zählt sie nach Registerregel als *ein* Vorgang).
  Trigger-Audit: kein Carveout, kein bootstrap-aware Gate und keine ADR mit
  fälligem Re-Evaluierungs-Trigger sind an diesem Slice beteiligt — nichts
  fällig.
- **Beobachtungs-Register (`../observations/`):** zwei neue Verzeichnisse
  angelegt, Sub-Area `ALL`:
  [`klassifikations-fix-verschiebt-den-fehler-statt-ihn-zu-loesen`](../observations/BEO-ALL/klassifikations-fix-verschiebt-den-fehler-statt-ihn-zu-loesen/observation.md)
  (der Steering-Loop-Kandidat aus F-2/F-3 → F-5/F-6: ein Fix an einer
  N-über-M-Klassifikation korrigiert einen Fall und führt einen anderen neu
  ein, solange nur die explizit genannten Sätze statt des ganzen Bereichs
  neu geprüft werden) und
  [`zeilen-adressen-im-handbuch-wandern-mit-umstrukturierung`](../observations/BEO-ALL/zeilen-adressen-im-handbuch-wandern-mit-umstrukturierung/observation.md)
  (der §6-Risiko-Ausgang — Zeilen-Adressen in Slice-Plänen sind kein
  stabiler Anker über eine Handbuch-Umstrukturierung hinweg). Beide bei 1×,
  `offen`.
- **Folge-Slices:** keine. Beide Register-Einträge stehen bei 1× und werden
  erst ab 3× zu einem verkörperten Steering-Loop-Eintrag oder einem eigenen
  Folge-Slice.
- **Risiken aus §6:** ein Risiko, **Ausgang: weiter offen** — im Register
  eingetragen (siehe oben), Details und Beleg direkt bei §6.
- **Drei Paarungen:**
  (a) Anker-Paarung — kein Eintrag dieser Closure trägt `liegt in
  <Zielort>` (keine Registerzeile hat 3× erreicht), daher nichts zu prüfen.
  (b) Folge-Slice-Paarung — keine Folge-Slices genannt, daher nichts zu
  prüfen.
  (c) Register-Paarung — beide neu angelegten Verzeichnisse existieren
  unter `docs/plan/planning/observations/BEO-ALL/` mit je einer
  nicht-leeren `evidence/`-Datei
  (`slice-benutzerhandbuch-nachzug-traegt-fuenf-posten.md`).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — die
Nutzer-Doku. Schwelle ≥ 2 von 3 erfüllt. `*` steht in der Modus-Deklaration
als Greenfield.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen am
2026-09-20 (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` →
**151**). Treffer: keine für die Handbuch-Nachzug-Klasse — notiert.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF; kein BF/Hybrid-Block.