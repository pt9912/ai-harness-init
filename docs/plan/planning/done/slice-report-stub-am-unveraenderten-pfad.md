# Slice slice-report-stub-am-unveraenderten-pfad: Der Review-Report-Stub am unveränderten Pfad (Implementation [`ADR-0061`](../../adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md))

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle ([`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst):
der Baseline-Test ist das *Mehr* — eine beobachtbare Closure-Bedingung, die
mehr beobachtet als die DoD dieses Slice; es gibt keine, der Closure-Trigger
unten wäre die Abschrift der eigenen DoD). Wellenlose Arbeit erscheint nicht in
der Roadmap (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle
braucht).

**Bezug:**
[`ADR-0061`](../../adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md)
(`Accepted` — die bindende Fassung: Stub am unveränderten Pfad — Festlegung 1,
repo-eigene Vorlage — Festlegung 2, Fähigkeit als Erweiterung — Festlegung 3,
drei Gegenformen benannt, nicht geschlossen — Festlegung 4),
[`MR-072`](../../../../harness/conventions.md#mr-072) (die Adaptions-Form, die
den Report-Anteil der `[haenger]`-Sperre auffängt),
[`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) (der
Träger; Abnahme-Kriterium 1 verliert für Report-*Ziele* seinen Gegenstand und
bleibt für Slice-/Welle-Ziele unverändert),
[`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md)
(Festlegung 4 hält `[haenger]` als Sperre des ersten Archiv-Moves; diese
Implementation löst seinen Report-Anteil),
[`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md)
(dessen Festlegung 4 führt die drei Gegenformen schon für Slice-Stubs — hier
in derselben Grenze übernommen),
[`MR-041`](../../../../harness/conventions.md#mr-041--die-referenz-statt-kopie-setzung-für-ausfüll-templates-steht-jetzt-in-der-adoptierten-baseline)
(bindet **vendored** Vorlagen; die Stub-Vorlage dieser Klasse ist deshalb
bewusst repo-eigen — [`ADR-0061`](../../adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md) Festlegung 2),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(kein Sensor hält den Status eines Artefakts gegen die Form seiner Adressen —
die drei Gegenformen bleiben benannt),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(je Zahl am Kommando).

**Berührte Spec-Stellen:** `—` — die Entscheidung schärft keinen
Spec-Stratum ([`ADR-0061`](../../adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md)
*„Prozess-ADR ohne Spec-Stratum"*). Der Verweis zeigt **aufwärts**: Die Spec
nennt diesen Slice nie.

**Verantwortlich:** pt9912

**Autor:** pt9912 (Rolle Planner, Architektur-Skizze zum Accept von
[`ADR-0061`](../../adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md),
`8f901668`). **Datum:** 2026-11-27.

---

## 1. Ziel und Abgrenzung

**Ziel:** die Implementations-Seite von
[`ADR-0061`](../../adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md)
Festlegungen 1–3 — ein Review-Report bekommt beim Archivieren einen gekürzten
Stub an **seinem unveränderten Pfad** `docs/reviews/<datei>.md`, statt
ersatzlos entfernt zu werden. Anlass ist der Altbestand-`archive-welle`-Befund
des Architektur-Zugs zum Accept: die `[haenger]`-Vorschau zählt **107**
Fundstellen (`archive-welle --vorschau altbestand`, Architektur-Bericht
2026-11-27), deren Report-Anteil je [`ADR-0061`](../../adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md)-Klasse
entfällt — Report→Report **43** · Evidence **42** · `Accepted`-ADR **11** ·
Closure-Notizen/Carveouts **6** · `open/` **5** (je `grep`-Messung beim
Implementer-Zug gegen den Bestand wiederholen, [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)-Form).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- *(Benannt, nicht geschlossen — Festlegung 4.)* Die drei Gegenformen an
  Report-Stubs — ein Zustandssatz neben der Adresse (*„der Report ist
  40 Zeilen lang"*), ein Operand in einem Mess-Kommando, ein künftiger
  Abschnitts-Anker auf einen gekürzten Stub — bekommen keinen Sensor und kein
  `ignore-refs`-Paar; ein Ventil wäre eine Senkung nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5 mit eigener ADR
  ([`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md)
  Aufnahme-Grenze), und dieser Slice ist sie nicht.
- *(Kein Nachzug.)* Keine der bestehenden Report-Verweise wird umgeschrieben —
  der Kern des Preises der Alternative b) ([`ADR-0061`](../../adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md)
  *„Was diese Entscheidung nicht tut"*): der Stub tritt an dieselbe Adresse,
  jeder bestehende Link löst unverändert auf.
- *(Es wäre ein anderer Vorgang.)* Die Slice-/Welle-Stub-Mechanik selbst und
  die Archivierung des Altbestands als ausführender Lauf bleiben unangetastet;
  dieser Slice legt nur die Fähigkeit und ihre Form.

## 2. Definition of Done

- [x] **Liefer-Punkt 1:** die **repo-eigene Stub-Vorlage** unter
      `docs/plan/planning/` (Name beim Implementer, Platzhalter
      `archive-stub-report.template.md` <!-- d-check:ignore (Platzhalter: entsteht im Implementer-Zug, MR-071-Form) -->)
      als Nachbar der vendored Vorlage
      [`.harness/baseline/v7.0.0/templates/docs/plan/planning/archive-stub-slice.template.md`](../../../../.harness/baseline/v7.0.0/templates/docs/plan/planning/archive-stub-slice.template.md)
      — dieselbe Grundform (Überschrift, Archiv-Zeiger, Zustand), auf einen
      Review-Report angewandt; der Träger `archive-welle` liest sie selbst
      ([`MR-041`](../../../../harness/conventions.md#mr-041--die-referenz-statt-kopie-setzung-für-ausfüll-templates-steht-jetzt-in-der-adoptierten-baseline)-Grenze
      je [`ADR-0061`](../../adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md)
      Festlegung 2).
- [x] **Liefer-Punkt 2:** [`internal/archive/anwenden.go`](../../../../internal/archive/anwenden.go)
      schreibt statt `g.Rm(b.Reviews)` je Review einen Stub an
      unveränderter Adresse `docs/reviews/<datei>.md` und staged ihn; das
      Archiv-Zip nimmt den vollen Report-Inhalt wie bisher auf
      ([`ADR-0061`](../../adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md)
      Festlegung 3). Wächter je Fitness-Tafel der ADR: der Go-Test in
      `internal/archive` hält Stub am ursprünglichen Pfad samt Archiv-Zeiger
      und Zustand, die `[haenger]`-Vorschau führt nach der Umsetzung keine
      Report-Ziele mehr (`make test`), ein bestehender Verweis auf einen
      archivierten Report löst weiterhin auf (`make docs-check-host`).
- [x] **Liefer-Punkt 3:** die `[haenger]`-Vorschau-Messung je
      [`ADR-0061`](../../adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md)-Klasse
      — die fünf Report-Klassen des 107er-Befunds entfallen; die übrige Luft
      (Slice-/Welle-Ziele) bleibt je Quelle benannt und wird nicht still
      eingesammelt. Abnahme-Kriterium 1 von
      [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md)
      verliert für Report-*Ziele* seinen Gegenstand und bleibt für
      Slice-/Welle-Ziele unverändert stehen.

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; Gate-Läufe und die Closure-Pflichten
zählen nicht mit.

- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben —
      `evidence/`-Datei ergänzen, wo eine Beobachtung anfiel; keine
      Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7
      notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind hier geprüft
      — Repo ohne Wellen-Betrieb, nach dem `git mv`.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/plan/planning/archive-stub-report.template.md` <!-- d-check:ignore (Platzhalter: entsteht im Implementer-Zug, MR-071-Form) --> (Name beim Implementer) | neu | die repo-eine Report-Stub-Form (LP 1) — Referenz statt Kopie über die Vorlagen-Verdratung des Trägers |
| [`internal/archive/anwenden.go`](../../../../internal/archive/anwenden.go) | update | statt `g.Rm(b.Reviews)` die Stub-Emission je Review an unveränderter Adresse, staged; Zip-Logik unverändert voll (LP 2) |
| `internal/archive/` (Tests), `cmd/ai-harness-init/` (Tests) | update | Wächter je Fitness-Tafel: Stub bleibt am Pfad, Archiv-Zeiger und Zustand im Stub, Vorschau ohne Report-Ziele (LP 2) |
| [`Makefile`](../../../../Makefile) (`archive-welle`-Rezept) | — | keine Änderung: der Träger liest die Report-Vorlage selbst über `internal/archive` (`stub.go`), das Rezept führt sie nicht — die Plan-Zeile „liest die neue Vorlage" ist gegen den Ist-Zustand berichtigt ([`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 1: die Logik liegt in `internal/archive`) |
| `internal/emit/templates.go` | update | der Bootstrap trägt die Report-Vorlage in das Ziel-Repo (`docs/plan/planning/archive-stub-report.template.md`, skip-if-present) — ohne ihn bricht `archive-welle` im gebootstrappten Ziel fail-closed an der fehlenden Vorlage; byte-gleich zur repo-eigenen Vorlage, Kopplung in `test/archiv-stub-vorlagen.bats` (LP 2, Träger-Form) |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | update | die E2E-Stufe der Archivierung folgt der Fähigkeit: der Report-Verweis ist kein `[haenger]`-Auslöser mehr, der Report bleibt als Stub; das Ziel-Repo startet mit der emittierten Vorlage (LP 2/LP 3) |
| [`harness/sensors/archive-welle.md`](../../../../harness/sensors/archive-welle.md), [`cmd/ai-harness-init/main.go`](../../../../cmd/ai-harness-init/main.go) | update | der öffentliche Vertrag des Unterkommandos nennt den Report-Stub statt der Löschung (DoD „Doku-Update") |

## 4. Trigger

**Start** (`next` → `in-progress`): [`ADR-0061`](../../adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md)
ist `Accepted` (beobachtbar an der Status-Zeile der ADR-Datei; Accept
2026-11-27) und [`MR-072`](../../../../harness/conventions.md#mr-072) trägt
die Adaptions-Form. Ein weiterer Architektur-Zug braucht es davor nicht — die
Fassung trägt die ADR selbst (Festlegungen 1–4).

**Rückführungen — vorab benennen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): gerät der Nachzug
  der bestehenden Report-Verweise, ein `ignore-refs`-Paar oder der
  Altbestand-Lauf in den Umfang — alle drei sind in §1 ausdrücklich
  ausgeschlossen.
- `in-progress` → `open` (blockiert — Carveout?): das Archiv-Zip trägt die
  volle Report-Größe nicht mehr, oder der Träger liest die Vorlage an einer
  zweiten Stelle neben `internal/archive/` — dann ist die Erweiterungs-Form
  (Festlegung 3) verletzt und die Frage geht an den Architect.

## 5. Closure-Trigger

DoD (§2) vollständig, und die Fitness-Tafel von
[`ADR-0061`](../../adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md)
ist in der d-check-Fassung gezeigt: ein archivierter Review hinterlässt seinen
Stub am ursprünglichen Pfad, die `[haenger]`-Vorschau zählt keine
Report-Ziele mehr, und der Rest-Restante der 107 Fundstellen je Quelle
benannt. Zusätzlich: Closure-Notiz mit Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

- **Die drei Gegenformen an Report-Stubs** (Zustandssatz neben der Adresse,
  Operand in einem Mess-Kommando, künftiger Abschnitts-Anker auf einen
  gekürzten Stub) bleiben von keinem Sensor getragen — dieselbe Grenze, die
  [`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md)
  Festlegung 4 für Slice-Stubs benennt und
  [`ADR-0061`](../../adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md)
  Festlegung 4 übernimmt; der Anker-Fall ist heute leer (Messung 4 der ADR). —
  **Ausgang:** weiter offen · benannt, nicht geschlossen (Festlegung 4); wird
  der Anker-Fall real, greift Re-Evaluierungs-Trigger 1 der ADR.
- **Der Stub verkleinert den Report-Bestand nicht an seiner Stelle** — die
  Verschlankung wirkt im Archiv-Zip; `docs/reviews/` behält so viele Dateien,
  wie es je hatte (Kontext der ADR). — **Ausgang:** entfallen mit Grund —
  die ADR nimmt den Preis in den Konsequenzen bewusst.
- **Archiv-Zip wächst durch den vollen Report-Inhalt** (der Stub ersetzt den
  Inhalt nur im Arbeitsbaum, nicht im Zip). — **Ausgang:** eingetreten —
  die Größe im Zip ist die gesetzte Form (Festlegung 3: das Zip trägt den
  vollen Report-Inhalt, die Probe vergleicht byte-gleich); kein Carveout und
  kein Folge-Slice, der Preis steht so in den Konsequenzen der
  [`ADR-0061`](../../adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md).

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln. Ging
der Gegenstand an einen anderen Slice oder entfiel er, trägt diese Sektion die
Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko aus §6 seinen
Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

- **Was hat funktioniert:** die drei Liefer-Punkte gegen
  [`ADR-0061`](../../adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md)
  Festlegungen 1–3 — die repo-eigene Report-Stub-Vorlage
  (`docs/plan/planning/archive-stub-report.template.md`) liest der Träger
  `archive-welle` selbst, `schreibeReportStubs` schreibt je Review den Stub
  an unveränderter Adresse `docs/reviews/<datei>.md` und das Zip trägt den
  vollen Report-Inhalt, und die `[haenger]`-Vorschau zählt keine
  Report-Ziele mehr (am realen Bestand gemessen,
  `archive-welle --vorschau altbestand`, Review-Zug 2026-11-28:
  `Sperren: keine — der schreibende Lauf liefe.`). Der Review-Verweis aus
  Rang 1 überlebt den Lauf am Stub (`test/mutations/251`). Review
  ([`../../../reviews/2026-11-28-slice-report-stub-am-unveraenderten-pfad.md`](../../../reviews/2026-11-28-slice-report-stub-am-unveraenderten-pfad.md))
  ohne HIGH — 2 MEDIUM / 2 LOW / 1 INFO, alle behoben (`3ee2ebcb`,
  `b2088a1e`, `9b565038`); Verifikation bestätigt LP1–LP3 und die
  Pauschal-Punkte; `make gates` grün je Endlauf (Stempel
  `gates-passed.head`), die Gates zu dieser Closure fährt der
  koordinierende Kontext.

- **Was ging anders als geplant:** die FormOK-Verdrahtung am Report-Zweig
  trug bei der Übergabe keinen bindenden Fall — der im Kommentar genannte
  Fall (243, `TestAnwendenBrichtBeiVerletzterStubFormAb`) setzt die
  Slice-Vorlage an, der Lauf bricht vor dem Report-Zweig ab, und die
  Bruchprobe (nur die Report-FormOK-Zeile unwirksam gesetzt) blieb grün
  (Review F-2). Behoben in `b2088a1e`: eigener Fall am Report-Zweig
  (`TestAnwendenBrichtBeiVerletzterReportStubFormAb`, Mutations-Anlage 819).
  Weiter ging die Plan-§3-Tabelle: sie wurde im Implementation-Commit
  (`c701d1bf`) gegen den Ist berichtigt (keine Makefile-Zeile mehr, je
  [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md)
  Festlegung 1; Träger-/E2E-/Doku-Zeilen ergänzt) — transparent je Review
  I-1, hier von der Rolle Planner gegen den Plan gelesen.

- **Steering-Loop-Eintrag:** die wiederkehrende Finding-Klasse aus dem
  Review (F-2 — ihre Quelle ist die verkörperte Zeile *„Mehrteilige
  Regel-Zusage im Kommentar ohne Mutations-Deckung je Teil"*)
  trägt einen Beleg in den bestehenden Eintrag
  [`BEO-ALL/zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel`](../observations/BEO-ALL/zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel/state.md)
  — zitiert, nicht neu benannt. Der Eintrag führt Schwelle und Ausgang
  schon: Folge-Slice
  [`../open/slice-der-mutations-treiber-sieht-bindung-und-abdeckung.md`](../open/slice-der-mutations-treiber-sieht-bindung-und-abdeckung.md),
  darum in dieser Closure gezählt und **nicht verkörpert** — es entsteht
  keine Regel an einem Zielort, kein `liegt in`-Feld. F-1 ist eine Instanz
  der in `AGENTS.md` §3.5 benannten Grenze des Ausnahme-Grund-Wächters
  (sie prüft die Nennung, nicht ob sie stimmt) und trägt keinen zweiten
  Namen; F-3/F-4 sind Einzelkorrekturen am Ist (`9b565038`), I-1 eine
  Rollen-Notiz ohne Klasse.

- **Beobachtungs-Register
  ([`../observations/`](../observations/)):** zwei Belege an bestehenden
  Einträgen ergänzt —
  [`BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/state.md):
  keine Treffer der Klasse (der Lauf schreibt keine Adresse um — je Review,
  Abschnitt *Kein Nachzug, kein Ventil*), gekoppelt das **weiter
  offen**-Risiko aus §6: die drei Gegenformen an Report-Stubs bleiben je
  [`ADR-0061`](../../adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md)
  Festlegung 4 benannt, nicht geschlossen — die Grenze der Verkörperung
  trägt der Eintrag selbst; und der F-2-Beleg in dem oben zitierten
  Eintrag. Die Stand-Zeilen der zwei Einträge tragen ihre Ausgänge
  (*verkörpert* / *geplant*) und bleiben unverändert.

- **Folge-Slices:** keiner neu — der Ausgang der gezählten Klasse bleibt
  der bestehende Slice
  [`../open/slice-der-mutations-treiber-sieht-bindung-und-abdeckung.md`](../open/slice-der-mutations-treiber-sieht-bindung-und-abdeckung.md).

- **Risiken aus §6:** (1) die drei Gegenformen — **weiter offen**, an den
  Register-Eintrag oben gekoppelt; wird der Anker-Fall real, greift
  Re-Evaluierungs-Trigger 1 der ADR. (2) der Verkleinerungsort —
  **entfallen** mit Grund: die ADR nimmt den Preis in den Konsequenzen
  bewusst. (3) die Zip-Größe — **eingetreten**: sie ist die gesetzte Form
  (Festlegung 3 — voller Report-Inhalt im Zip, Probe byte-gleich); kein
  Carveout und kein Folge-Slice, der Preis steht so in den Konsequenzen
  der ADR.

- **Drei Paarungen** — geprüft nach dem `git mv`, Pfade vom Ruheort
  (`done/`) gelesen: **Anker** — in dieser Closure ist keine Regel mit
  `liegt in`-Feld entstanden (gezählt, nicht verkörpert, siehe
  Steering-Loop-Eintrag oben); es gibt keinen Anker-Gegenstand.
  **Folge-Slice** — keiner neu; der zitierte
  [`../open/slice-der-mutations-treiber-sieht-bindung-und-abdeckung.md`](../open/slice-der-mutations-treiber-sieht-bindung-und-abdeckung.md)
  liegt in `open/` und trägt den Ausgang der gezählten Klasse.
  **Register** — beide Belege lösen vom Ruheort einstufig auf
  ([`../observations/BEO-ALL/zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel/evidence/slice-report-stub-am-unveraenderten-pfad.md`](../observations/BEO-ALL/zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel/evidence/slice-report-stub-am-unveraenderten-pfad.md)
  und
  [`../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/evidence/slice-report-stub-am-unveraenderten-pfad.md`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/evidence/slice-report-stub-am-unveraenderten-pfad.md)),
  die Stand-Zeilen der zwei Einträge tragen ihre Ausgänge (*verkörpert* /
  *geplant*) und bleiben unverändert — keine zweiten Namen, nichts still
  eingeschrieben.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die zwei vorgelagerten
Schritte (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die vier Pflichtkriterien (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan — sie hängen weder am Modus noch am Slice-Typ. Bedingt
ist allein der Modus-Begründungsblock am Ende; deshalb nennt der Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo,
Kürzel `ALL`, Modus-Deklaration
[`harness/conventions.md`](../../../../harness/conventions.md) §Modus-Deklaration
pro Sub-Area) — die Schwelle ≥ 2 von 3 Achsen ist erfüllt (Strukturregeln über
den Adaptions-Block, Phase-Reife Phase 5 — `archive-welle` ist Träger des
Archiv-Laufs); `harness/tools/` (`TOOLS`) als zweite berührte Sub-Area über
die Träger-Verdrahtung.

**Vorgelagert — offene Beobachtungen sichten:** Register gemergt gelesen
(`docs/plan/planning/observations/BEO-ALL/`). Der Eintrag
[`BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/state.md)
ist die Herkunft dieses Slices (13 Belege zum Zeitpunkt der ADR-Planung,
[ADR-0042](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) §Kontext)
— **verkörpert** ([`ADR-0061`](../../adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md)
Festlegung 3 nimmt den Report-Anteil); dieser Slice arbeitet an der
verkörperten Form, bei Closure `evidence/slice-report-stub-am-unveraenderten-pfad.md`
ergänzen. Keine Treffer unter der Schwelle in den berührten Sub-Areas.

**Modus:** alle berührten Sub-Areas GF — der Modus-Begründungsblock entfällt.
