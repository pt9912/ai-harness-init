# Slice slice-emittierte-gate-vorlage-traegt-targets-und-reviews: Die emittierte Doc-Gate-Vorlage nennt die zwei Module, die sie heute verschweigt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case.

**Welle:** `welle-emittiertes-doc-gate`.

**Ebene: emittiert, nicht Dogfood.** Gegenstand ist ausschließlich die Doc-Gate-Startkonfiguration,
die das Werkzeug in ein **frisches Zielrepo** schreibt. Die
[`.d-check.yml`](../../../../.d-check.yml) dieses Repos bleibt unberührt (§1) — die zwei Ebenen
tragen verschiedene Verträge und verschiedene Gründe.

**Bezug:**
[`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) (die
emittierte Doc-Gate-Baseline ist der Liefergegenstand),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (nichts
wird aktiviert, dessen Prüfbereich im Ziel leer wäre — dieser Slice aktiviert **gar nichts**),
[`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
(die drei Kriterien für eine **Aktivierung** und, in Setzung 3, die Form des begründeten
Kommentar-Blocks für ein Modul, das **nicht entschieden** ist),
[`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
(die Default-Regel für emittierte Prüfbereiche),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben ihrem Kommando).

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle; Gegenstand ist eine emittierte
Konfigurations-Vorlage).

**Verantwortlich:** — (bis zur Priorisierung).

**Autor:** Planner. **Datum:** 2026-09-13.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Die emittierte Doc-Gate-Vorlage
[`internal/emit/templates/d-check.yml`](../../../../internal/emit/templates/d-check.yml) nennt die
Module `targets` und `reviews` als **begründete, inaktive Kommentar-Blöcke** mit je eigenem
Trigger — in genau der Form, die
[`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
Setzung 3 für `codepaths` und `planning` bereits führt. Ein Adopter erfährt damit, **dass** es die
zwei gibt und **wie** man sie einschaltet, statt sie gar nicht zu sehen.

### Die Lücke ist gemessen, nicht vermutet

```sh
B=.harness/baseline/v6.7.2/templates/.d-check.yml
E=internal/emit/templates/d-check.yml
grep -cE '^# (targets|reviews):' "$B"   # 2 — die Ziel-Form fuehrt beide als Kommentar-Block
grep -cE '^# (targets|reviews):' "$E"   # 0 — die emittierte Vorlage fuehrt keinen
grep -cin 'reviews' "$E"                # 0 — das Wort kommt in ihr nicht vor
```

**Keine Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — alle drei wandern mit dem Stand. Gemessen am adoptierten Stand `v6.7.2`, weil
[`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
zu einer Baseline-Aussage den Tag verlangt, gegen den sie gemessen ist.

**Dieser Slice nimmt eine namentlich adressierte Sendung an.**
[slice-224](../done/slice-224-delta-nachweis-und-planungs-nachzug.md) §9 führt die Zeile zu
`lab/templates/.d-check.yml` mit dem Ziel `slice-225`; dessen §1 schloss die emittierte Vorlage
aus und nannte vier Adressen, von denen keine sie annahm. Die Closure von `slice-225` hat den Fall
als Risiko-Ausgang *eingetreten → Folge-Slice mit Kennung* aufgelöst, und **dieser Slice ist die
Kennung.** Sein Gegenstand ist genau der Teil jener Zeile, der die emittierte Ebene betrifft; der
Dogfood-Teil derselben Zeile — ob **dieses** Repo `reviews` einschaltet — bleibt draußen (unten).

### Was der Block je Modul tragen muss

| Modul | Lage heute | was der Kommentar-Block sagen muss |
|---|---|---|
| `targets` | im Dogfood **aktiv**, im Ziel ebenfalls **aktiv** (§3, Ist-Stand) | nichts — ein Kommentar-Block hat keinen Gegenstand |
| `reviews` | weder im Dogfood aktiv noch emittiert | dass `done-dir` der Aktivierungs-Schalter ist und ohne ihn keine Datei geöffnet wird |

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Keine Aktivierung — weder `targets` noch `reviews` kommt in die emittierte `modules:`-Liste.**
  Eine Aktivierung verlangt nach
  [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  Setzung 1 alle drei Kriterien — Erprobung im Dogfood, grün über dem frisch emittierten Bestand,
  rotes Gegenbeispiel im Ziel —, und `reviews` scheitert schon am ersten. Dieser Slice liefert die
  **Dokumentation** eines nicht entschiedenen Moduls, was jener Eintrag ausdrücklich von der
  Ablehnung unterscheidet. *Es wäre ein anderer Vorgang.*
- **Keine Änderung an der [`.d-check.yml`](../../../../.d-check.yml) dieses Repos.** Ob der Dogfood
  `reviews` einschaltet, ist eine Gate-Aktivierung mit eigener Erprobung und eigenem rotem
  Gegenbeispiel und liegt bei
  [slice-213](../open/slice-213-review-report-laeuft-in-der-tabellen-form.md), der zuvor die **Form** der
  Reports herstellt, auf die das Modul bindet. *Folge-Slice übernimmt es* — und `slice-213` nimmt
  diese Hälfte an, weil sein §1 die Dogfood-`.d-check.yml` als Gegenstand nennt.
- **Keine Entscheidung über `codepaths` und `planning`.** Für beide führt
  [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  Setzung 3 bereits einen begründeten Kommentar-Block mit eigenem Trigger, und ihre Auflösung liegt
  bei [slice-210](../next/slice-210-planning-modul-im-emittierten-doc-gate.md) und
  [slice-211](../next/slice-211-codepaths-im-emittierten-doc-gate.md). *Folge-Slice übernimmt es* — beide
  nehmen die Sendung an, weil ihr §1 je genau ein Modul nennt.
- **Kein neuer Adaptions-Eintrag.** Der Block, dessen Form dieser Slice anwendet, steht bereits als
  [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  Setzung 3; eine Anwendung ist keine neue Abweichung
  ([`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)). Stellt sich im Lauf
  heraus, dass der Eintrag **erweitert** gehört — zwei Positionen mehr in Setzung 3 —, ist das ein
  Übergabe-Artefakt an den Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8) und kein Posten
  dieses Diffs. *Es wäre ein anderer Vorgang.*
- **Kein bereits gebootstrapptes Zielrepo.** `.d-check.yml` ist *skip-if-present*
  ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md)), und
  [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  Setzung 5 benennt die Folge: Wer schon gebootstrappt hat, bekommt nichts davon. Ein
  Migrationspfad ist nicht Gegenstand dieses Slice. *Bestand bleibt bewusst stehen.*

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

Zwei slice-eigene Punkte.

- [x] **1 — Der `reviews`-Block steht, inaktiv und begründet; `targets` ist schon aktiv.**
      `grep -cE '^# (targets|reviews):' internal/emit/templates/d-check.yml` liefert **1**
      (`reviews`); `targets` steht vor wie nach dem Diff in `modules:`
      (`git show d4850268^:internal/emit/templates/d-check.yml | grep '^modules:'`), ein
      Kommentar-Block hat dort keinen Gegenstand. Die `modules:`-Zeile ist **unverändert**, und der
      `reviews`-Block trägt seine **eigene** `# Trigger:`-Zeile in der Form aus
      [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
      Setzung 3, als dritte ausbleibende Position getragen von
      [`MR-086`](../../../../harness/conventions.md#mr-086--das-modul-reviews-bleibt-als-dritte-position-aus-dem-emittierten-doc-gate).
- [x] **2 — Ein frisch gebootstrapptes Ziel bleibt grün, und das ist gemessen statt behauptet.**
      [`make full-smoke`](../../../../harness/sensors/full-smoke.md) läuft durch: Das tmp-Ziel
      bekommt die Vorlage, sein `make gates` ist out-of-the-box grün. **Rot gesehen**
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6), getrennt nach Lage: ein **halb** entkommentierter
      Block (`reviews:` und `done-dir` ohne `#`) bricht `make docs-check` im Ziel mit einem
      Konfig-Fehler; ein **vollständig** entkommentierter bleibt dort grün und fällt am Unit-Wächter
      `TestDCheckConfig_ReviewsBleibtKommentarBlock` über der eingebetteten Vorlage, gebunden durch
      Mutations-Fall `568`.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: [`docs/user/benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md)
      sagt, was ein frisches Ziel an Doc-Gate-Konfiguration bekommt — ein öffentlicher Vertrag
      gegenüber dem Adopter, falls die dortige Beschreibung die Modul-Lage aufzählt.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht (`ls docs/plan/planning/reconciliation.md`).
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo fährt Wellen (`ls docs/plan/planning/welle-*.md`), sie werden deshalb von der nächsten Welle-Closure geprüft, auch für diesen Slice ohne Wellen-Zugehörigkeit; nach dem Move gefahren, §7.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`internal/emit/templates/d-check.yml`](../../../../internal/emit/templates/d-check.yml) | update | die zwei Kommentar-Blöcke samt Trigger; `modules:` bleibt, wie es ist |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | update | das rote Gegenbeispiel aus DoD-Punkt 2, falls der Voll-E2E es tragen soll statt eines Einmal-Laufs |
| [`docs/user/benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md) | update | nur falls die dortige Beschreibung die Modul-Lage des Ziels aufzählt — sonst entfällt die Zeile |
| [`internal/emit/emit_test.go`](../../../../internal/emit/emit_test.go) | update | Wächter: `reviews` bleibt Kommentar-Block mit Trigger-Zeile — ein unkommentierter Block lässt `docs-check` im Ziel grün und fällt dort nicht auf |
| [`test/mutations/568-emittierter-reviews-block-unkommentiert.sh`](../../../../test/mutations/568-emittierter-reviews-block-unkommentiert.sh) | neu | Mutations-Fall zum Wächter |

**Ist-Stand vor dem Diff, gegen diesen Plan gemessen:** `targets` ist in der emittierten Vorlage
bereits **aktiv** (`sed -n 's/^modules: \[\(.*\)\]$/\1/p' internal/emit/templates/d-check.yml`
nennt es, ein `targets:`-Block steht unkommentiert). Für `targets` entfällt der Kommentar-Block;
der Diff trägt allein `reviews`.

**Was hier bewusst fehlt:** eine Zeile für [`.d-check.yml`](../../../../.d-check.yml) und für
[`harness/conventions/`](../../../../harness/conventions/). Beide sind in §1 mit Adresse
ausgeschlossen.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): `slice-225` liegt in `done/` — ablesbar an
`ls docs/plan/planning/done/slice-225-*.md` auf dem Hauptzweig. Beobachtbar ohne Rückfrage, und
**kein Ergebnis dieses Slice**: Der Nachweis, aus dem die Sendung stammt, steht in keiner DoD-Zeile
von §2.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Wenn der `targets`-Block im Ziel nicht
  ohne eine Aussage über die dortige `Makefile`-Lage zu formulieren ist — dann wird `targets` ein
  eigener Slice und dieser behält `reviews`. Konkrete Schwelle: Der Block braucht eine
  `makefiles:`-Zeile, deren Wert von etwas abhängt, das der Bootstrap nicht kennt.
- `in-progress` → `open` (blockiert — Carveout?): Wenn
  [`make full-smoke`](../../../../harness/sensors/full-smoke.md) aus einem Grund rot wird, der
  außerhalb dieses Slice liegt. Dann geht die **Messung** zurück an den Auftraggeber; ein
  auskommentierter Block, der ein Gate beruhigt, statt die Ursache zu nennen, ist kein Ausweg.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: (1) `grep -cE '^# (targets|reviews):' internal/emit/templates/d-check.yml`
liefert **2**, `make gates` und `make full-smoke` sind grün. (2) Der Review-Report zu diesem Slice
liegt unter `docs/reviews/` und trägt keinen blockierenden Befund. Dazu der Lerneintrag in §7 und
für jedes Risiko aus §6 ein Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Ein Kommentar-Block ist eine Zusage ohne Wächter.** Nichts prüft, ob der beschriebene
  Aktivierungs-Weg im Ziel wirklich funktioniert; das täte erst die Aktivierung selbst, und die ist
  ausgeschlossen. Register-Stand der Klasse `zusage-nennt-sensor-der-form-nicht-sieht`: **14×**
  (`ls docs/plan/planning/observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/evidence/*.md | wc -l`).
  — **Ausgang:** weiter offen — die **Form** hält `TestDCheckConfig_ReviewsBleibtKommentarBlock`
  mit Fall `568`; die **Werkzeug-Aussagen** im Kommentar (Phrase, fail-closed) hält kein Sensor
  gegen einen künftigen d-check-Pin, Beleg in
  [`BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`](../observations/BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand/state.md).
- **Der Block beschreibt einen Stand des gepinnten Werkzeugs, in den niemand geschaut hat.** Was
  `targets` und `reviews` im gepinnten d-check verlangen, ist gegen seinen Stand zu lesen und nicht
  aus der Baseline-Vorlage abzuschreiben. Register-Stand der Klasse
  `aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`: **2×**
  (`ls docs/plan/planning/observations/BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand/evidence/*.md | wc -l`).
  — **Ausgang:** eingetreten — die Umschrift „unabhaengiger Review" erkennt der Pin v0.84.0 nicht
  (Review L-1), behoben in `1d2442f7`; Reviewer und Verifier lasen den Stand am Pin (Sonden C–H der
  [Verifikation](../../../reviews/2026-10-08-emittierte-gate-vorlage-verifikation.md)); Beleg im
  selben Register-Eintrag.
- **`make full-smoke` ist teuer und läuft nicht in `make gates`.** DoD-Punkt 2 hängt an einem
  Sensor, den kein Pro-Push-Auslöser fährt; er ist ausdrücklich zu fahren, nicht vorauszusetzen.
  — **Ausgang:** entfallen — der Verifier fuhr ihn ausdrücklich, `EXIT 0`.
- **Die Sendung könnte breiter sein als die zwei Module.** `slice-224` §9 nennt die Zeile als
  *„Doku-Kommentare zu den Modulen `targets` … und `reviews`"*; findet der Lauf in der
  Baseline-Vorlage weitere Kommentar-Positionen ohne Gegenstück, wächst der Umfang über diesen
  Plan hinaus. Register-Stand der Klasse `slice-plan-umfang-waechst-ueber-umsetzung-hinaus`: **3×**
  (`ls docs/plan/planning/observations/BEO-ALL/slice-plan-umfang-waechst-ueber-umsetzung-hinaus/evidence/*.md | wc -l`).
  — **Ausgang:** entfallen — der Diff trägt allein `reviews` (§3, Ist-Stand); die dritte
  ausbleibende Position ging als Übergabe an den Architect
  ([`MR-086`](../../../../harness/conventions.md#mr-086--das-modul-reviews-bleibt-als-dritte-position-aus-dem-emittierten-doc-gate)),
  nicht in den Diff.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10).
**Rolle:** Planner · **Datum:** 2026-10-08

- **Was hat funktioniert:** `make full-smoke` `EXIT 0`, im Ziel `0 Befund(e)`; Sonden C–H am Pin
  v0.84.0 bestätigen die Phrasen-Zusage in allen drei Teilen
  ([Verifikation](../../../reviews/2026-10-08-emittierte-gate-vorlage-verifikation.md)). Review
  0 HIGH · 1 MEDIUM · 2 LOW ([Review](../../../reviews/2026-10-08-emittierte-gate-vorlage-review.md)):
  M-1 getragen durch das [Architect-Verdikt](../../../reviews/2026-10-08-emittierte-gate-vorlage-architect-verdikt.md)
  und [`MR-086`](../../../../harness/conventions.md#mr-086--das-modul-reviews-bleibt-als-dritte-position-aus-dem-emittierten-doc-gate),
  L-1/L-2 behoben in `1d2442f7`.
- **Was ging anders als geplant — Abnahme bei der Closure geändert:** DoD 1 verlangte zwei
  Kommentar-Blöcke; `targets` war im Ziel schon aktiv, gemessen ist **1**. DoD 2 sagte ein Rot für
  jeden Block ohne führende `#` zu; am Pin bricht nur der halb entkommentierte, der vollständig
  entkommentierte bleibt grün und fällt am Unit-Wächter mit Fall `568`. Beide Punkte sind auf das
  Gemessene umformuliert, nicht still abgehakt; §1-Tabelle und §4-Rückführung (`targets`) haben
  damit keinen Gegenstand mehr.
- **Steering-Loop-Eintrag:** benannte Sensor-Lücke — kein Sensor hält die Werkzeug-Aussagen eines
  emittierten Kommentar-Blocks gegen einen künftigen d-check-Pin; gezählt in
  `BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand` (Stand *geplant*,
  `slice-werkzeug-aussage-traegt-quelle-stand-und-messstelle`), nicht verkörpert, kein Zielort-Feld.
- **Beobachtungs-Register (`../observations/`):** je ein Beleg in
  [`BEO-ALL/abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt`](../observations/BEO-ALL/abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt/observation.md),
  [`BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/observation.md)
  und
  [`BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`](../observations/BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand/observation.md);
  Stände unverändert.
- **Folge-Slices:** keine. Die Anforderung an d-check, die Review-Zeile der Slice-Vorlage zu
  erkennen, liegt beim Auftraggeber (fremdes Repo).
- **Trigger-Audit:** Carveouts: keiner berührt. Bootstrap-aware Gates: keines. ADR/MR:
  [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  Setzung 3 durch [`MR-086`](../../../../harness/conventions.md#mr-086--das-modul-reviews-bleibt-als-dritte-position-aus-dem-emittierten-doc-gate) erweitert, kein weiterer Trigger eingetreten. Hard Rules: keine.
- **Risiken aus §6:** Jede Zeile in §6 trägt ihren Ausgang.
- **Paarungen geprüft am 2026-10-08** (nach dem Move): (a) *Anker*: §7 trägt kein Zielort-Feld,
  nichts zu prüfen. (b) *Folge-Slice*: keiner genannt; der zitierte
  `slice-werkzeug-aussage-traegt-quelle-stand-und-messstelle` steht in `open/`. (c) *Register*: die
  drei genannten Pfade existieren, `evidence/` trägt 9, 7 und 5 Dateien. Zweite Hälfte über das ganze
  Register: 3 Verzeichnisse ohne Beleg, namentlich `BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`,
  `BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab`,
  `BEO-ALL/planungs-bestand-waechst-schneller-als-er-abgebaut-wird`; nicht als getragen behauptet
  ([`ADR-0069`](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
  Festlegung 2). Zusätzlich geprüft von der Closure von
  `welle-emittiertes-doc-gate`.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area: `*` (gesamtes Repo,
Kürzel `ALL`), deklariert in [`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area. Die Schwelle ≥ 2 von 3 Achsen ist erfüllt: eigene Regeln
([`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel),
[`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)),
eigener Prüfbereich ([`make full-smoke`](../../../../harness/sensors/full-smoke.md) über einem tmp-Ziel)
und eigene Fehlermodi (ein Ziel, das am ersten Tag rot startet). **`TOOLS` ist geprüft und nicht
berührt:** Keine Aussage über `harness/tools/` ändert sich; dass der Voll-E2E-Smoke dort liegt, ist
Pfad-Berührung und nicht hinreichend. **`CODEX` ebenso wenig.**

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist am gemergten Stand durchgegangen
— **100** Verzeichnisse (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, **kein
Erwartungswert**); alle führen dieselbe Sub-Area `*`, die Sichtung ist damit vollständig. **Fünf
Treffer** berühren diesen Slice:

| Beobachtung (`BEO-ALL/<slug>`) | Zähler | Stand |
|---|---|---|
| `zusage-nennt-sensor-der-form-nicht-sieht` | 14× | geplant |
| `uebergabe-an-andere-rolle-ohne-traeger-artefakt` | 4× | offen |
| `emittierte-vorlagen-klassifikation-ohne-traeger` | 3× | geplant |
| `slice-plan-umfang-waechst-ueber-umsetzung-hinaus` | 3× | offen |
| `aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand` | 2× | offen |

```sh
for s in zusage-nennt-sensor-der-form-nicht-sieht uebergabe-an-andere-rolle-ohne-traeger-artefakt \
         emittierte-vorlagen-klassifikation-ohne-traeger slice-plan-umfang-waechst-ueber-umsetzung-hinaus \
         aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand; do
  printf '%s %s\n' "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)" "$s"
done
```

**Vier stehen über der Schwelle**, alle **vor** diesem Slice und nicht durch ihn; der Lese-Schritt,
der ihnen einen Ausgang zuweist, gehört der Welle-Closure und nicht dieser Planung. Zwei treffen
den Schnitt unmittelbar: `uebergabe-an-andere-rolle-ohne-traeger-artefakt` ist die Klasse, deren
vierter Beleg die Sendung ohne Empfänger war, die dieser Slice annimmt; und
`emittierte-vorlagen-klassifikation-ohne-traeger` nennt als verbleibende Lücke die fehlende Deckung
zwischen emittiertem Text und emittiertem Bestand — genau die Achse, auf der ein
Kommentar-Block ohne Wächter liegt (§6).

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas sind Greenfield; der Block trägt
eine Sub-Area.

### Sub-Area: `*` (gesamtes Repo, Kürzel `ALL`)

- **Modus:** GF
- **Konventionen-Dichte:** hoch — die Modul-Zusammensetzung der emittierten Startkonfiguration ist
  in [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  vollständig geregelt (fünf Setzungen, davon Setzung 3 die Form dieses Slice), die Default-Regel
  für emittierte Prüfbereiche in
  [`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed),
  und die Bootstrap-Idempotenz in
  [`ADR-0007`](../../adr/0007-bootstrap-phasen.md).
- **Phase-Reife:** Phase 4 für die emittierte Gate-Konfiguration — die Vorlage ist über
  [`make full-smoke`](../../../../harness/sensors/full-smoke.md) am frischen Ziel gemessen und
  trägt bereits einen Herkunfts-Kommentar gegen die Baseline-Vorlage
  (`sed -n '20,39p' internal/emit/templates/d-check.yml`). Was fehlt, ist eine Deckung des
  **Kommentar**-Bestands: Kein Sensor hält ihn gegen die Ziel-Form.
- **Evidenz-/Diskrepanz-Risiko:** mittel — die tragende Diskrepanz ist **Ziel-Form gegen emittierte
  Fassung**: Die Baseline-Vorlage führt zwei Kommentar-Blöcke, die emittierte keinen, und gemerkt
  hat das ein Delta-Durchgang, kein Wächter. `emittierte-vorlagen-klassifikation-ohne-traeger` (3×)
  ist genau diese Klasse, und sie steht auf `geplant` mit
  [slice-211](../next/slice-211-codepaths-im-emittierten-doc-gate.md) als benanntem Träger für ihre
  `codepaths`-Hälfte.
- **Reconciliation-Aufwand:** keiner — GF, kein Inventur-Fund im Sinne des
  Reconciliation-Registers (die Datei existiert in diesem Repo nicht; das DoD-Item entfällt).
  Graduation entfällt (n/a bei GF). Der Trigger, der die Achse auf Phase 5 höbe, wäre ein Sensor,
  der die emittierte Vorlage gegen die Ziel-Form hält; er existiert nicht.
