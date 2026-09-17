# Slice slice-stilllegungs-form-hat-einen-waechter: Ein stillgelegter Slice ohne Zeile `Gegenstand:` färbt `make docs-check` rot

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Nach dem Test aus Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit
eine Welle braucht beobachtet keine Closure-Bedingung mehr als diese DoD.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) (die Kanten `open → done` und
`next → done` kommen mit `v6.9.0`),
[`MR-001`](../../../../harness/conventions.md#mr-001) (eine Gate-Schärfung läuft über den
Steering-Loop), [`MR-054`](../../../../harness/conventions.md#mr-054) (was ins emittierte Gate
geht).

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-17.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Trägt ein Slice in `done/` in seiner DoD offene Task-Items, verlangt `make docs-check` in
§7 die Zeile `Gegenstand:`. Fehlt sie, meldet das Gate den Grund-Code
`section-open-tasks-marker-missing`. Dafür aktiviert der Slice im Dogfood das Modul `structure` mit
der Bedingung `open-tasks-require-marker`. Ob die Bedingung auch ins emittierte Gate geht,
entscheidet er nach den drei Kriterien aus [`MR-054`](../../../../harness/conventions.md#mr-054).

**Herkunft:**
- Die Ziel-Fassung nennt den Teil urteilsfrei: *„dass die `Gegenstand:`-Zeile eine Kennung oder
  einen Grund trägt"* (`v6.9.0` · `modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein
  anderer übernimmt).
- Am `v0.74.1` (Messstand; den gepinnten Stand führt `d-check.mk`, und die Umsetzung misst an ihm neu) meldet kein aktives Modul einen stillgelegten Slice ohne diese Zeile
  ([`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) §Grenze).
- d-check `v0.76.0` bringt die Bedingung (`CHANGELOG.md`, `[0.76.0]`); den Pin hebt
  `slice-d-check-pin-bringt-die-stilllegungs-bedingung`.

**Der Bestand ist kein leerer Prüfbereich.** Offene Task-Items tragen
`grep -l '^- \[ \]' docs/plan/planning/done/*.md | wc -l` → 30 von
`ls docs/plan/planning/done/*.md | wc -l` → 202 flachen Dateien in `done/`. Keine der zwei Zahlen ist
ein Erwartungswert. Ein Gate über den ganzen Bestand wäre ab dem ersten Lauf rot. Den Prüfbereich
und seine Grenze deklariert darum DoD 1.

**Warum vor der Gruppierung.** Die Gruppierung der Go-Slices legt mehrere Slices über die
Stilllegungs-Kanten nach `done/`. Mit diesem Slice meldet das Gate eine vergessene
`Gegenstand:`-Zeile, statt dass allein der Lauf sie beurteilt
([`.claude/commands/plan-welle.md`](../../../../.claude/commands/plan-welle.md) §Einen Slice
stilllegen, Prüfung 3).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Pin-Sprünge.** *Zwei andere Slices übernehmen sie:*
  `slice-d-check-pin-bringt-die-stilllegungs-bedingung` und danach der Patch-Sprung
  `slice-d-check-pin-zieht-den-vcs-patch-nach`. Dieser Slice startet nach beiden (§4).
- **Die offenen Task-Items im Bestand werden nicht umgeschrieben.** *Bestand bleibt bewusst
  stehen:* Die Dateien in `done/` sind Zeitdokumente. Der Prüfbereich aus DoD 1 grenzt sie aus.
- **Kein Sensor für den Risiko-Ausgang.** *Ein anderer Slice übernimmt ihn:*
  `slice-risiko-ausgang-hat-einen-sensor`.
- **Ob die Kennung in `Gegenstand:` auflöst, bleibt Urteil.** *Anderer Vorgang:* Die Bedingung
  prüft, dass die Marke da ist, nicht, worauf sie zeigt.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Suchreihenfolge: Was übernimmt ein **Folge-Slice** (mit
Kennung — und die Kennung muss den Punkt auch annehmen)? Was bleibt als
**Bestand** bewusst stehen (mit Begründung)? Was wäre ein **anderer Vorgang**?
Welche **Schicht** rührt der Slice nicht an?

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

Drei Liefer-Punkte, jeder mit dem Kommando, das ihn rot färbt
([`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [x] **1 — `.d-check.yml` aktiviert `structure` mit `open-tasks-require-marker` für die
      Slice-Pläne in `done/`, mit deklariertem Prüfbereich.**
      - Die Marke wird im Abschnitt §7 gesucht (`open-tasks-require-marker-section`). Das Muster
        ist gegen die Überschriften im Bestand gemessen.
      - `make docs-check` meldet über dem Bestand keinen Befund.
      - Der Prüfbereich und seine Grenze stehen mit Kommando in
        [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md).
      - **Beleg:** Verifikation §1 und §2.1: `structure` steht in `modules:`, die Regel zählt §2 und sucht die Marke in §7, und `make docs-check` meldet über dem Bestand keinen Befund. Die Ausnahmeliste ist genau die Menge der Pläne mit offenen Items und ohne Marke, und die zwei Überschriften-Muster treffen jeden heutigen Plan in `done/`, `open/`, `next/` und `in-progress/`. Review Runde 1 hat die Zahlen-Kommandos der Sensor-Datei nachgefahren.
- [x] **2 — Die Bedingung ist rot gesehen, die Meldung ist gelesen.**
      - In einer Kopie außerhalb des Repos färbt ein stillgelegter Slice ohne `Gegenstand:`
        `make docs-check` mit `section-open-tasks-marker-missing`.
      - Derselbe Slice mit der Zeile bleibt ohne Befund.
      - Die Kommandos stehen im Umsetzungs-Commit. `make mutate` kennt für `make docs-check` keine
        Fehlschlag-Form; das steht als Grenze in der Sensor-Datei.
      - **Beleg:** Verifikation §2.2: Lage V1 meldet `section-open-tasks-marker-missing` auf der §2-Überschrift der Sonde, V2 bleibt mit der Zeile ohne Befund, V9 ist die Gegenprobe ohne Aktivierung. Die Meldung ist gelesen und passt zum Treffer. Die Kommandos stehen in `8366b374`; die Grenze `make mutate` steht in der Sensor-Datei, die Zahl im selben Satz ist in `4a583474` berichtigt (Verifikation V-2).
- [x] **3 — Die Entscheidung für das emittierte Gate steht mit Beleg.**
      - Die drei Kriterien aus [`MR-054`](../../../../harness/conventions.md#mr-054) sind je mit
        Messung beantwortet: Erprobung, grüner Start, rotes Gegenbeispiel.
      - Geht die Bedingung ins Ziel, zieht die Vorlage nach, und
        [`make full-smoke`](../../../../harness/sensors/full-smoke.md) bleibt grün.
      - Geht sie nicht ins Ziel, steht der Grund in der Sensor-Datei.
      - **Beleg:** Verifikation §2.3, an einem frisch emittierten Ziel: Kriterium 1 erfüllt, Kriterium 2 nicht (Lage E1, `section-missing`), Kriterium 3 nicht (kein Zahn in `harness/tools/full-smoke.sh`, gewertet nach [`MR-055`](../../../../harness/conventions.md#mr-055) Setzung 3). Die Entscheidung *nicht ins Ziel* steht mit Grund in der Sensor-Datei, und `internal/` ist in der Kette unverändert.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) nennt die Bedingung, ihren Prüfbereich und das Gegenbeispiel (DoD 1, DoD 2).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`.d-check.yml`](../../../../.d-check.yml) | update | `structure` mit der Bedingung (DoD 1) |
| [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) | update | Prüfbereich, Grenze, Gegenbeispiel (DoD 1, DoD 2) |
| emittierte Doc-Gate-Vorlage unter `internal/emit/` | update, falls die Bedingung ins Ziel geht | [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (DoD 3) |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): `slice-d-check-pin-bringt-die-stilllegungs-bedingung` liegt in
`done/`, ebenso `slice-d-check-pin-zieht-den-vcs-patch-nach`, und das WIP-Limit ist frei.
**Die Gruppierung der Go-Slices startet erst nach diesem
Slice.**

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Ein grüner Start braucht mehr als eine
  Auswahl des Prüfbereichs, etwa eine Änderung an Plänen in `done/`.
- `in-progress` → `open` (blockiert — Carveout?): Die Bedingung kann die Marke nicht in §7 suchen,
  weil sich die Überschriften des Bestands durch kein Muster fassen lassen. Die Anforderung geht dann
  an das d-check-Repo.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. `make docs-check` ist über dem Bestand grün, mit aktivierter Bedingung.
2. Das Gegenbeispiel aus DoD 2 ist rot gesehen, und `make gates` ist grün.

Dazu kommt ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

1. **Der Prüfbereich schließt zu viel aus**, etwa alle Dateien vor einem Stichtag, und damit auch
   künftige Stilllegungen. *Absehbar:* entfallen, wenn das Gegenbeispiel aus DoD 2 im Prüfbereich
   liegt. — **Ausgang:** **entfallen.** Die Einträge unter `exempt-paths` sind Dateinamen ohne Glob-Zeichen, und keiner trägt den Namen eines Plans aus `open/`, `next/` oder `in-progress/` (in der Closure nachgemessen, `comm -12` gegen die drei Verzeichnisse → leer). Das Gegenbeispiel liegt im Prüfbereich (Verifikation V1), ebenso ein nummerierter Slice aus `open/` unter eigenem Namen (V10). Nicht gedeckt ist ein Plan außerhalb der flachen Ablage (V12); das ist die benannte Grenze *der Glob ist flach* und keine Stilllegung.
2. **Die Bedingung zählt Task-Items in anderen Abschnitten als §2.** *Absehbar:* entfallen, wenn
   `section-pattern` auf §2 beschränkt ist und das Gegenbeispiel es zeigt. — **Ausgang:** **entfallen.** `section-pattern` ist `'^## 2\. Definition of Done$'` (`grep -n 'section-pattern' .d-check.yml`). Ein regulärer Slice mit je einem offenen Item in §1, §6, §7 und §8 bleibt ohne Befund, ein eingerücktes offenes Item in §2 meldet (Verifikation V7, V8i).

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10). Eingang ist
der Stand `c8d94fb8` mit den Review-Reports der Runden 1 bis 4, dem Architect-Verdikt zu F-1 und dem
Verifikations-Report, alle vom 2026-09-17. Maßstab sind Baseline-Regelwerk `v6.9.0` ·
`modul-05-planning-harness.md` §Closure- und Lerneintrag-Regeln und `modul-06-roadmap.md` §Das
Beobachtungs-Register.

- **Was hat funktioniert:**
  - Die Verifikation hat jede Lage selbst gefahren, in Kopien außerhalb des Repos, und ihre Tabelle
    deckt beide Richtungen: Der stillgelegte Slice ohne Zeile färbt rot, der gelieferte mit allen
    Häkchen bleibt still, und ohne `structure` in `modules:` bleibt auch das Gegenbeispiel still
    (Lagen V1, V6, V9).
  - Die Ausnahmeliste ist extensional und genau die Differenz: die Pläne mit offenen Items und ohne
    Marke (Verifikation §2.1). Ein nummerierter Slice aus `open/` fällt unter eigenem Namen in den
    Prüfbereich (V10).
  - Der Konflikt um F-1 lief über den Konflikt-Pfad (`v6.9.0` · `modul-08-agentenrollen.md`
    §Konflikt-Pfad als Rollen-Sequenz). Der Reviewer meldete HIGH, der Architect entschied mit dem
    Satz aus `modul-05`, der die Paarungen zu den Pflichten zählt, die *„wie bei jeder Closure"*
    abgehakt werden. Das Finding wurde mit Quelle erledigt, nicht herabgestuft.
  - DoD 3 hat die Entscheidung *nicht ins Ziel* an einem frisch emittierten Ziel gemessen
    (Verifikation §2.3).
- **Was ging anders als geplant:**
  - **§3 nannte zwei Dateien und bedingt die Vorlage; geändert wurden mehr** (Verifikation V-5):
    `d-check.mk`, `harness/sensors/doc-structure.md`, `harness/sensors/doc-tracked.md`,
    `harness/README.md`, `.github/workflows/ci.yml`, `harness/sensors/history-range-guard.md` und
    der Kommentar von `test/mutations/309-drittes-c-ziel-ohne-marke.sh`. Keine davon verlässt die
    Abgrenzung in §1 (Verifikation §3). Sie halten lebende Aussagen über die aktive Modul-Menge und
    die Marken-Menge wahr, die die Aktivierung sonst falsch gemacht hätte. §3 hat diese
    Nachzugs-Klasse nicht vorhergesehen und bleibt, wie er ist: der Plan vor dem Code.
  - **Die Aktivierung machte auch Planner-Artefakte falsch.** Ihr Nachzug steht in `689f3a09`
    (Übergaben unten).
  - **Mehrere Review-Runden, ein Architect-Verdikt und eine Verifikation statt einer Runde.** Runde 1
    fand F-1 (HIGH) und F-2 (MEDIUM), ab Runde 2 blockierte kein Befund. Der Architect zog
    [`AGENTS.md`](../../../../AGENTS.md) §3.8 und §3.10 in eigenen Commits nach (`510b7ac7`,
    `c4701568`, `35897912`).
  - **Runde 5 des Implementers (`c8d94fb8`) hat keine eigene Review-Runde.** Sie setzt R4-1 in zwei
    Sensor-Dateien um. Runde 4 hatte Push und Closure freigegeben und R4-1 nicht blockierend genannt.
- **Entscheidungen zu den Übergaben:**
  - **Risiken aus §6:** beide *entfallen*, in der Closure nachgeprüft (§6).
  - **V-5:** vermerkt, oben.
  - **R2-2, zwei Pläne in `next/`:** beide nachgezogen, keiner stillgelegt (`689f3a09`).
    - `slice-114-jede-aussage-hat-einen-abschnitt` nennt `structure` aktiv mit einer Regel über den
      Slice-Plänen in `done/`. Das Kommando, das `0` zusagte, ist ersetzt.
    - `slice-218-harness-einstieg-behaelt-seine-index-form` behält seinen Kern, die Zellen-Grenze im
      Einstieg, und davon ist nichts geliefert. Die Wegfall-Hälfte aus `modul-05` §Ein Slice, dessen
      Gegenstand ein anderer übernimmt, trifft darum nicht. Entfallen ist sein DoD-Punkt 3, den
      dieser Slice geliefert hat; Block und Aktivierung setzt der Plan jetzt voraus.
  - **Veraltete Modul-Aufzählungen in Planner-Artefakten:** alle nachgezogen (`689f3a09`). Die
    Roadmap-Zeile *Doku- und Sensor-Wartung*, `slice-139-lastenheft-deckt-die-emit-disposition`,
    `slice-121-commit-message-nennt-was-es-gibt` und `slice-072-adr-verweist-nicht-auf-lifecycle`
    nennen das Kommando statt einer Liste. Der Welle-Plan `welle-11-traeger-aussage` trägt die
    Ziel-Messung neu gefahren.
  - **[`MR-011`](../../../../harness/conventions.md#mr-011),
    [`MR-012`](../../../../harness/conventions.md#mr-012) und
    [`MR-025`](../../../../harness/conventions.md#mr-025):** Die Adresse ist das Register,
    [`praesens-aussage-in-einzufrierendem-artefakt-ohne-form`](../observations/BEO-ALL/praesens-aussage-in-einzufrierendem-artefakt-ohne-form/observation.md)
    (Beleg unten). Ob die drei Stellen eine Kopf-Marke mit Folge-Eintrag bekommen, entscheidet der
    Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8); diese Zeile ist das Übergabe-Artefakt.
    - `slice-werkzeug-aussage-traegt-quelle-stand-und-messstelle` nimmt die Sendung nicht an. Sein
      §1 schließt den Bestand und die Umschrift von Adaptions-Einträgen aus, und die drei Stellen
      sprechen über die eigene Gate-Konfiguration, nicht über das Verhalten des Werkzeugs.
    - [`MR-011`](../../../../harness/conventions.md#mr-011) und [`MR-012`](../../../../harness/conventions.md#mr-012) nennen die emittierte Startkonfiguration `modules: [links, anchors]`,
      die Vorlage führt mehr (`grep -m1 '^modules:' internal/emit/templates/d-check.yml`); das war
      schon vor diesem Slice so. [`MR-025`](../../../../harness/conventions.md#mr-025) nennt `structure` *nicht aktiviert*; das hat dieser Slice
      überholt.
  - **`.claude/commands/close-welle.md`:** ergänzt (`b77ae1bd`). Das abgehakte Paarungen-Kästchen
    weist die Prüfung im Repo mit Wellen der Welle-Closure zu. Ein Anweisungssatz, der sie nicht
    nennt, lässt diese Zusage ohne Träger in dem Lauf, der sie einlösen soll. Der Schritt steht, wo
    `v6.9.0` · `modul-06-roadmap.md` §Wellen-Closure-Prozedur ihn führt und die emittierte Fassung
    ihn trägt. Der Anweisungssatz gehört dem Planner
    ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)).
  - **R2-1:** vermerkt. Die Message von `61a6fe61` ordnet Treffer ihres eigenen ersten Kommandos
    keiner Gruppe zu. Sie ist gepusht und bleibt; die Fundliste hält der Report der Runde 2, die
    Klasse ist unten gezählt.
  - **Offene Grenzen:**
    - **V9** (`structure` allein aus `modules:` genommen, der Block bleibt: still): Folge-Slice
      `slice-218-harness-einstieg-behaelt-seine-index-form` in `next/`. Sein DoD-Punkt 2 hält die
      Modul-Aktivierung hermetisch und nennt diesen Fall jetzt ausdrücklich (`689f3a09`). Bis dahin
      trägt [`AGENTS.md`](../../../../AGENTS.md) §3.5 die Senkung als Feedforward.
    - **F-9 und V-4** (ein toter Eintrag in `exempt-paths` bleibt still): Register,
      [`ausnahmeliste-nur-auf-form-geprueft`](../observations/BEO-ALL/ausnahmeliste-nur-auf-form-geprueft/observation.md)
      (Beleg unten). Dessen geplanter Slice entscheidet, was eine Ausnahmeliste über Existenz und
      Form hinaus schuldet; hier fehlt schon die Existenz-Prüfung, und ob er diese untere Hälfte
      mitnimmt, sichtet seine Planung. Eintreten kann der Fall mit der ersten Archivierung; der
      Lauf, der sie plant, misst die Liste vorher ([`AGENTS.md`](../../../../AGENTS.md) §3.11).
    - **V3** (die Platzhalter-Zeile der Vorlage zählt als Marke): Register,
      [`gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang`](../observations/BEO-ALL/gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang/observation.md),
      zusammen mit F-7 (Beleg unten). Die Grenze steht in der Sensor-Datei und im Kommentar der
      Regel.
- **Steering-Loop-Eintrag:** **Neuer Sensor.** `make docs-check` hält mit dem Modul `structure` und
  der Bedingung `open-tasks-require-marker` die Stilllegungs-Form: Ein Slice-Plan in `done/` mit
  offenem DoD-Punkt färbt `section-open-tasks-marker-missing`, außer §7 trägt die Zeile
  `Gegenstand:`. Prüfbereich, Ausnahmeliste und Grenzen stehen in
  [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) §Modul `structure`.
  - Ohne Anker-Feld: Der Sensor setzt eine Regel des adoptierten Stands `v6.9.0` um, keine, die die
    3×-Schwelle erreicht hat.
  - Der nächste Lauf, der einen Slice stilllegt, bekommt eine vergessene Zeile vom Gate gemeldet;
    die Gruppierung der Go-Slices hat damit ihre Vorbedingung aus §1.
- **Beobachtungs-Register (`../observations/`):**
  - Der Beleg heißt in jedem Fall `evidence/slice-stilllegungs-form-hat-einen-waechter.md`.
  - Den Zähler liefert `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, die
    Zahl der Belege aus diesem Vorgang
    `ls docs/plan/planning/observations/BEO-ALL/*/evidence/slice-stilllegungs-form-hat-einen-waechter.md | wc -l`
    (→ 10). Keine der Zahlen ist ein Erwartungswert.
  - Kein neuer Eintrag: Für jede gezählte Klasse passt ein vorhandener.

  | Eintrag | Quelle | Zähler | Stand |
  |---|---|---|---|
  | [`korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge`](../observations/BEO-ALL/korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge/observation.md) | Review F-2 und F-8; Runde 2, R2-1 und R2-2; Runde 3, R3-2 | 9 | geplant |
  | [`ausnahmeliste-nur-auf-form-geprueft`](../observations/BEO-ALL/ausnahmeliste-nur-auf-form-geprueft/observation.md) | Review F-9; Runde 2, R2-5; Verifikation V-4 | 4 | geplant |
  | [`stellen-messung-als-eigenschaft-ausgegeben`](../observations/BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben/observation.md) | Review F-10; Runde 3, R3-1; Runde 4, R4-1 und R4-2 | 5 | geplant |
  | [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md) | Review F-3 und F-4; Verifikation V-5 | 27 | geplant |
  | [`kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle`](../observations/BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle/observation.md) | Review F-6 | 14 | verkörpert |
  | [`gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang`](../observations/BEO-ALL/gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang/observation.md) | Review F-7; Verifikation, Lage V3 | 2 | offen |
  | [`werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten`](../observations/BEO-ALL/werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten/observation.md) | Runde 2, R2-3 | 4 | geplant |
  | [`mess-rezept-setzt-unbenannte-host-konfiguration-voraus`](../observations/BEO-ALL/mess-rezept-setzt-unbenannte-host-konfiguration-voraus/observation.md) | Runde 2, R2-4 | 2 | offen |
  | [`zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`](../observations/BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht/observation.md) | Verifikation V-2 | 16 | verkörpert |
  | [`praesens-aussage-in-einzufrierendem-artefakt-ohne-form`](../observations/BEO-ALL/praesens-aussage-in-einzufrierendem-artefakt-ohne-form/observation.md) | Implementer Runde 2 und Architect-Sichtung, drei Adaptions-Einträge | 5 | geplant |

  **Lese-Schritt.** Kein Eintrag erreicht mit diesem Slice zum ersten Mal 3×. Die zwei, die offen
  bleiben, stehen darunter; die übrigen standen schon darüber und behalten ihren Ausgang. Repo-weit
  trägt kein Eintrag mit mindestens drei Belegen den Stand `offen` (in der Closure gemessen: je
  Verzeichnis die Zahl der Belege gegen die erste Zeile der `state.md`).

  - **Zwei Ausgänge decken diesen Fall nur zum Teil, und das ist das Urteil der Closure:**
    - `zusage-neben-geaenderter-ableitung-bleibt-stehen` ist mit `slice-153` geplant, und dessen
      `state.md` sagt selbst, dass er nur die Anker-Unterklasse trägt. F-3, F-4 und V-5 liegen in
      den Unterklassen, deren Ausgang dort *Regel ohne Sensor* heißt.
    - `ausnahmeliste-nur-auf-form-geprueft`: siehe *Offene Grenzen* oben.

  **Nicht getragen, mit Urteil:**

  - **F-1** (*Gate entscheidet eine Auslegung, die keine Quelle getroffen hat*): Das
    Architect-Verdikt hat die Prämisse widerlegt, die Quelle steht in `modul-05`. Auch
    `aktivierung-entscheidet-die-als-offen-uebergebene-frage` passt nicht: Keine Frage war als
    offen übergeben.
  - **F-5** (*Kriterium ohne Urteil neben seiner Messung*): ein Fund, behoben in `61a6fe61`; die
    Wertung setzt [`MR-055`](../../../../harness/conventions.md#mr-055) Setzung 3 bereits.
  - **V-1 und V-3:** behoben bzw. fail-closed und nicht schärfer als die Vorlage. Der Report nennt
    keine Klasse, und kein Eintrag passt.
  - `vollstaendigkeits-zusage-misst-falsche-ebene` (Runde 3 nennt ihn nahe): Seine Ebene ist Datei
    gegen Hunk. R3-1 betrifft die Breite eines Suchmusters und steht unter
    `stellen-messung-als-eigenschaft-ausgegeben`.
  - `extensionale-zahl-unterschreitet-die-eigene-fundmenge` (Runde 2 nennt ihn nahe): Der Eintrag
    setzt eine Zahl neben ihrer Aufzählung voraus. R2-1 trägt keine Zahl, sondern eine Fundliste,
    die ihr Kommando nicht abarbeitet, und steht unter
    `korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge`.
  - `naechste-rolle-uebernimmt-vor-dem-schluss-der-vorigen-runde`: Runde 5 hat keinen Review, aber
    Runde 4 hat die Closure freigegeben, bevor diese Closure begann.
  - `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`: Den Ruhe-Marker setzt die Closure in
    einem eigenen Commit nach dem Move.
  - `bedingung-ohne-traeger-im-lauf-den-sie-bindet` und
    `werkzeug-luecke-im-nachbar-repo-ohne-adresse` (§8): kein neues Auftreten. Der erste bekommt für
    die Stilllegungs-Form einen Träger im Gate; sein Stand bleibt *offen*, weil der Eintrag die
    Klasse beschreibt und nicht diesen Fall.
- **Trigger-Audit** (bei der Slice-Closure):
  - **Carveout:** `CO-001` steht auf *Auflösung fällig*, seine Adresse ist
    `slice-113-co-001-ist-faellig` in `open/`. `CO-002` steht auf *permanent*. Dieser Slice berührt
    keine ihrer Bedingungen.
  - **Bootstrap-aware Gate:** keines (`grep -rn -i 'bootstrap-aware' Makefile *.mk` → kein Treffer).
    Die Ausnahmeliste der neuen Regel ist keine Reifestufe: Sie nimmt den Bestand aus, und jeder
    weitere Eintrag ist nach dem Kommentar der Regel eine Senkung.
  - **ADR:** [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md): Keiner der vier
    Trigger ist eingetreten. Der Slice setzt eine Regel des adoptierten Stands um; er springt nicht,
    bewegt den Zielstand nicht, und kein Schritt folgt allein einem Prozedur-Text.
  - **Adaptions-Einträge:**
    - [`MR-054`](../../../../harness/conventions.md#mr-054), permanent: in DoD 3 angewandt,
      Entscheidung *nicht ins Ziel*. Die zwei Teil-Trigger (emittierte Prosa, `ids`-Muster) berührt
      der Slice nicht.
    - [`MR-061`](../../../../harness/conventions.md#mr-061), permanent (*bei jedem
      d-check-Release*): **ausgelöst**, nicht durch diesen Slice, sondern durch die Releases
      `v0.76.2` und `v0.76.3` (`git -C <Klon des Werkzeugs> tag -l 'v0.76*'`). Getragen wird er vom
      neuen Pin-Slice.
    - [`MR-064`](../../../../harness/conventions.md#mr-064) und
      [`MR-065`](../../../../harness/conventions.md#mr-065), permanent: Ihr Neu-Prüf-Fall *d-check
      liest Packs unter fremdem Präfix* ist mit `v0.76.2` laut CHANGELOG des Werkzeugs eingetreten.
      Getragen vom selben Pin-Slice.
    - [`MR-062`](../../../../harness/conventions.md#mr-062): nicht eingetreten. Die Menge seines
      Geltungsbereichs ist nicht leer, sie besteht aus `doc-tracked`
      (`test/doc-block-marke-wiring.bats`, Fall 2, in `make gates`), und `--print-mk` erzeugt keinen
      Hinweis (Verifikation §2.4).
- **Folge-Slices:**
  - `slice-d-check-pin-liest-fremde-packs-und-loest-jede-range` (neu, in `open/`): Pin `v0.76.1` →
    `v0.76.3`, aus dem Trigger-Audit.
  - `slice-218-harness-einstieg-behaelt-seine-index-form` (vorhanden, in `next/`): V9.
  - Kein weiterer: F-9, V-4, V3 und die drei Adaptions-Stellen gehen ins Register.
- **Risiken aus §6:** Beide haben genau einen Ausgang, *entfallen*.
- **Archiv:** keines. Dieses Repo archiviert bei einer Slice-Closure nicht.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan — sie hängen weder am Modus noch am Slice-Typ. Bedingt
ist allein der Modus-Begründungsblock am Ende; deshalb nennt der Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `.d-check.yml`, `internal/emit/`
und `harness/sensors/`; alle liegen in `*`. `harness/tools/` (`TOOLS`) und `.codex/` (`CODEX`) sind
nicht berührt.

**Vorgelagert — offene Beobachtungen sichten:** Alle Einträge führen die Sub-Area `*`; gesichtet
ist nach Gegenstand. Den Zähler liefert
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, den Stand die erste Zeile
der `state.md`; keine der Zahlen ist ein Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| [`werkzeug-luecke-im-nachbar-repo-ohne-adresse`](../observations/BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse/observation.md) | 2 | offen | die Lücke der Stilllegungs-Form hat mit `v0.76.0` eine Antwort im Werkzeug |
| [`bedingung-ohne-traeger-im-lauf-den-sie-bindet`](../observations/BEO-ALL/bedingung-ohne-traeger-im-lauf-den-sie-bindet/observation.md) | 1 | offen | die Prüfungen je Stilllegung bekommen einen Träger im Gate |
| [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md) | 16 | geplant | DoD 2: das Gegenbeispiel zeigt, dass der Sensor die Form sieht |

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
