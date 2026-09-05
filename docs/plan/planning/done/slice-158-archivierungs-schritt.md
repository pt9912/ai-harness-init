# Slice slice-158: Der Archivierungs-Schritt der Wellen-Closure — Entscheidung und Sechs-Schritte-Form

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-14](welle-14-re-baseline.md).

**Bezug:** [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)
(die emittierten Anweisungssätze nennen die Schritt-Zahl),
[`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (wer die
Command-Artefakte schreiben darf).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Ob und ab wann Modul 6 Schritt 4 — *Zeitdokumente der Welle archivieren* — in diesem Repo läuft,
ist entschieden und belegt; und wo heute *fünf* Closure-Schritte stehen, stehen sechs.**

Die neue Fassung schiebt der Wellen-Closure einen Schritt ein: Slice-Dateien, Welle-Plan und
Review-Reports wandern nach `done/<welle-id>/archiv.zip`, an ihrer Stelle bleiben gekürzte Stubs
(zwei neue Vorlagen), die Ergebnisnotiz bleibt vollständig und flach. Gemessen ist der Bruch, den
das erzeugt: die Anweisungssätze dieses Repos und die emittierten führten beide *„fünf Schritte"*
(`git grep -c 'fünf' 470b5d3 -- .claude/commands/close-welle.md internal/emit/templates/commands/close-welle.md`
→ je **4**; Tree-Operand nach
[`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
Ausgang 2, keine Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Der Altbestand ist nicht Gegenstand** — [welle-14](welle-14-re-baseline.md) §6 schließt ihn
aus, und die Ziel-Fassung stellt ihn selbst frei.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **Die Entscheidung steht mit Beleg:** ab welcher Welle Schritt 4 hier läuft — oder dass er
      als benannte Abweichung nicht läuft (`MR-<NNN>`). Dazu die Vorbedingung, die die Quelle
      selbst nennt: der **Geltungsbereich der vorhandenen Sensoren** ist gegen `done/*.md` geprüft,
      damit kein Sensor über den Stubs grün bleibt, ohne noch etwas zu prüfen.
- [x] **Sechs statt fünf:** die Closure-Schritt-Zahl und der Archivierungs-Schritt stehen in den
      Anweisungssätzen — Dogfood **und** emittierte Ebene. Wer sie schreiben darf, ist
      [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md); ist sie bei
      Beginn noch `Proposed`, ist das der Blocker aus §4 und keine stille Ausnahme.
- [x] **Die zwei Stub-Vorlagen sind erreichbar** — `archiv-stub-slice` und `archiv-stub-welle`
      sind wiederkehrende Artefakte und entstehen per `cp` aus dem vendored Baum
      ([`MR-041`](../../../../harness/conventions.md#mr-041--die-referenz-statt-kopie-setzung-für-ausfüll-templates-steht-jetzt-in-der-adoptierten-baseline));
      dass das gilt, ist belegt, nicht angenommen.
- [x] `make gates` grün.
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations.md`) fortgeschrieben — neue `BEO-<NNN>` oder Zähler +1 mit Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`.claude/commands/close-welle.md`](../../../../.claude/commands/close-welle.md) | update | führt heute fünf Schritte |
| `internal/emit/templates/commands/close-welle.md` | update | dieselbe Aussage auf der emittierten Ebene |
| `harness/conventions.md` | update | falls die Antwort ein `MR-<NNN>` ist — Architect, eigener Commit |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`) — **zwei Bedingungen, beide vor dem Beginn prüfbar:**

1. [slice-156](../done/slice-156-baum-tauschen-pins-ziehen.md) liegt in `done/` — die Quelle, gegen
   die die Form gemessen wird, ist die adoptierte.
2. **Eine Vorbedingung außerhalb dieses Slice, kein Liefer-Punkt:**
   [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) trägt
   `**Status:** Accepted`
   (`grep -c '^\*\*Status:\*\* Accepted' docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md`
   → **1**). Träger ist
   [slice-145](../done/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md). Vorher steht
   nicht fest, wer die zwei Anweisungssätze schreiben darf, die DoD 2 anfasst — und ein Lauf, der
   sie ohne diese Antwort ändert, ist genau der Vorgang, den `BEO-007` zählt.
   Der Slice liegt darum in `open/`, nicht in `next/`; dieselbe Platzierung aus demselben Grund
   trägt [slice-153](../open/slice-153-wellen-commands-nennen-die-roadmap-abschnitte.md).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn der Sensor-Geltungsbereich mehr
  als eine Nachziehung verlangt — dann trägt die Sensor-Hälfte ein eigener Slice.
- `in-progress` → `open` (blockiert — Carveout?): wenn der Reviewer-Durchgang aus
  [slice-145](../done/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md)
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) nicht annimmt und
  das Eigentum an den Command-Artefakten offen bleibt (`BEO-007`).

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; kein Anweisungssatz nennt mehr eine Schritt-Zahl, die die adoptierte Fassung
nicht führt; Closure-Notiz mit Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Ein Sensor auf `done/*.md` bleibt über den Stubs grün, ohne noch etwas zu prüfen** — die
  Quelle nennt diese Vorbedingung selbst; ungeprüft ist sie ein stilles Grün. — **Ausgang:**
  **entfallen** — kein Sensor dieses Repos verliert eine Ebene tiefer seine Zähne, gemessen mit der
  Sonde in §7: `.d-check.yml` scannt ab `.` ohne Ausnahme für `done/**`, und die einzige
  glob-tragende Klasse (`matrix.classes.slice`) greift über `**` auch zwei Ebenen tief. Was der
  Geltungsbereich **zusätzlich** einschließt — die ID-Link-Pflicht im Stub — steht als Kopplung in
  Schritt 4 des Anweisungssatzes.
- **Der Slice hängt an einer `Proposed`-ADR** — wer die Command-Artefakte schreiben darf, ist
  `BEO-007` im Register, und die Zeile schließt erst, wenn alle drei
  Hälften eine angenommene Quelle haben. — **Ausgang:** **entfallen** für diesen Slice:
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) trägt
  `**Status:** Accepted`
  (`grep -c '^\*\*Status:\*\* Accepted' docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md`
  → **1**), und der Träger [slice-145](../done/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md)
  liegt in `done/`. Die Registerzeile bleibt davon unberührt — ihre zwei anderen Hälften stehen
  weiter offen.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

**Rolle:** Planner. **Datum:** 2026-09-03.

**Die Entscheidung: Schritt 4 läuft in diesem Repo, und seine Start-Bedingung ist beobachtbar —
[slice-170](../done/slice-170-archivierungs-werkzeug.md) (Archivierungs-Werkzeug) liegt in `done/`.**
Sie steht dort, wo sie gelesen wird: in Schritt 4 der zwei Anweisungssätze. Keine benannte
Abweichung, also kein `MR-<NNN>`: Die Bedingung kommt aus der Quelle selbst — *„Ob das Archiv
vollständig ist, bezeugt nur der Archivierungs-Commit — deshalb gehört die Operation in ein Werkzeug
und nicht in Handarbeit"* (`v5.18.0`, `modul-06-roadmap.md`, §Wellen-Closure-Prozedur, Schritt 4) —,
und der Handlauf wäre die Abweichung, nicht ihr Aufschub. Für
[welle-14](welle-14-re-baseline.md) ist die Bedingung offen; ihre Closure verbucht **das** als
Feststellung, statt den Schritt still auszulassen. Der Altbestand bleibt frei (jene §6, und die
Quelle stellt ihn selbst frei). **Die Gegen-Lesart ist benannt:** Wer den Aufschub als Abweichung
liest, braucht dafür einen Eintrag im Konventionsspeicher — und der gehört dem Architect
([`AGENTS.md`](../../../../AGENTS.md) §3.8), nicht diesem Lauf.

**Beleg 1 — Sensor-Geltungsbereich, mit rot gesehener Sonde.** Zwei Sonden-Dateien in `done/` (flach
als Kontrolle, verschachtelt unter `done/welle-99-sonde/`) und je ein Link darauf aus
`spec/architecture.md`: `make docs-check` meldet **beide** als `matrix-forbidden`
(`d-check: 568 Datei(en) geprüft, 2 Befund(e)`, Exit 1) — die Klasse `slice` der
[`.d-check.yml`](../../../../.d-check.yml) greift über `**` also auch zwei Ebenen tief, und die
Kontrolle belegt, dass die Regel überhaupt feuert. Sonde danach entfernt. Dazu ohne Sonde:
`scan.roots` ist `["."]` und `scan.ignore` nimmt `done/**` nicht aus; kein bats-Fall und kein
`make`-Ziel keilt auf `docs/plan/planning/done/`
(`grep -rln 'planning/done' test/ harness/tools/ Makefile` trifft `slice-mv.sh`, `slice-mv.bats`,
`full-smoke-ausgang.bats` und drei Mutations-Fälle — je als Lifecycle-Logik oder Fixture-Text, nicht
als Prüfbereich); `comment-claims` führt vier Pfad-Muster ohne Markdown. **Was der Bereich dagegen
einschließt:** `ids.exempt-paths` nennt nur `CHANGELOG.md` und `docs/reviews/**` — die Link-Pflicht
gilt im Stub, dessen Feld `Hervorgegangen:` Kennungen trägt. Diese Kopplung steht jetzt in Schritt 4.

**Beleg 2 — die zwei Stub-Vorlagen sind erreichbar.** Sie liegen im vendored Baum und damit unter
`make baseline-verify`
(`grep -c 'archiv-stub' .harness/baseline/v5.18.0/SHA256SUMS` → **2**), und der Emitter führt beide
als **wiederkehrend** (`grep -c 'archiv-stub' internal/emit/templates.go` → **1**, die `case`-Zeile
in `isRecurring`; Verdikt und Wächter: [slice-164](../done/slice-164-emitter-klassifiziert-die-zwei-neuen-vorlagen.md)).
Wiederkehrend heißt: nicht emittiert, je Instanz per `cp` aus dem vendored Baum
([`MR-041`](../../../../harness/conventions.md#mr-041--die-referenz-statt-kopie-setzung-für-ausfüll-templates-steht-jetzt-in-der-adoptierten-baseline)) —
der Workflow erreicht sie, weil Schritt 4 jetzt beide `cp`-Quellen mit vollem Pfad nennt. Keine
Erwartungswerte ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

- **Was hat funktioniert:** Die Sonde hat die Frage entschieden, die ein `grep` nicht entscheidet —
  ob ein `**` zwei Ebenen trägt, sagt das Werkzeug und nicht die Konfigurationszeile. Die Kontrolle
  daneben trennt *die Regel greift nicht* von *die Regel gibt es nicht*.
- **Was ging anders als geplant:** Die Frage aus §1 hatte zwei Antworten im Angebot — *ab Welle X*
  oder *benannte Abweichung* —, und beide passten nicht: Die Quelle bindet die Ausführung an ein
  Werkzeug, das dieses Repo nicht hat. Die Antwort ist darum eine dritte Form, die der Harness
  ohnehin führt: eine beobachtbare Start-Bedingung mit geschnittenem Träger.
- **Steering-Loop-Eintrag:** Regel geschärft: Eine übernommene Baseline-Pflicht, die ihre Ausführung
  an ein Werkzeug bindet, bekommt eine **beobachtbare Start-Bedingung plus Folge-Slice** — nicht
  Handarbeit und nicht Schweigen; ist die Bedingung bei einer Closure nicht eingetreten, ist *das*
  die Feststellung in der Results-Notiz. Steht in Schritt 4 beider Anweisungssätze.
- **Beobachtungs-Register (`../observations.md`):** `BEO-009` auf 8× erhöht, Beleg slice-158
  ergänzt — der Baum-Tausch bewegte die Ableitung (die Quelle führt sechs Schritte), die Zusage
  *„fünf Schritte"* stand daneben unverändert weiter, und kein Gate sieht sie.
- **Folge-Slices:** [slice-170](../done/slice-170-archivierungs-werkzeug.md) (Das
  Archivierungs-Werkzeug der Wellen-Closure) — ist eine Datei in `open/`, ohne Wellen-Zugehörigkeit
  und darum kein Mitglied von [welle-14](welle-14-re-baseline.md).
- **Risiken aus §6:** zwei, je genau ein Ausgang, beide **entfallen** — mit Begründung in §6 selbst.
- **Drei Paarungen:** nicht hier fällig. Dieser Slice ist Mitglied von
  [welle-14](welle-14-re-baseline.md) §4; Anker, Folge-Slice und Register prüft deren Closure.
  Was sie von hier erbt: **ein** Steering-Loop-Eintrag ohne `liegt in` (gezählt, nicht verkörpert),
  **null** *weiter offen*-Ausgänge, **einen** neuen Folge-Slice, **keine** neue `BEO-<NNN>`
  (ein Zähler +1 auf `BEO-009`).

**Sensor-Belege dieses Laufs.** `make gates` Exit **0** (`baseline-verify: v5.18.0 OK — 53 Dateien`,
`d-check: 567 Datei(en) geprüft, 0 Befund(e)`, `comment-claims: 47 Datei(en) geprueft, 0 Befund(e)`,
`1..206` in der bats-Stufe, **0** `not ok`). Der Sonden-Lauf davor ist der einzige rote dieses
Slice und war es mit Absicht: `2 Befund(e)` über **beide** Sonden. Alle Zahlen wandern mit dem Baum
und sind keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

## 8. Sub-Area-Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Umfang.** Der **Modus-Begründungsblock** unten ist Pflicht, sobald
mindestens eine berührte Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei
reinem GF genügt der Hinweis *"alle berührten Sub-Areas GF"*; bei reinem
Refactor ohne neue Sub-Area-Berührung entfällt er ganz. Die beiden
*Vorgelagert*-Blöcke entfallen nie.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — der Planning-Lifecycle
und die Command-Artefakte liegen in keiner engeren Sub-Area der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area).

**Vorgelagert — offene Beobachtungen sichten:** `BEO-007` (Command-Eigentum) steht als Risiko in
§6; `BEO-009` (ein Fix ändert die Ableitung und lässt die Zusage stehen) trifft die
Schritt-Zahl-Aussage und ist der Grund für DoD 2. Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.
