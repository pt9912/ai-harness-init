# Slice slice-baseline-delta-lesung-v7-0-0: Baseline-Sprung auf v7.0.0 — Delta-Lesung mit Schätzung

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [`welle-baseline-sprung-v7-0-0`](../welle-baseline-sprung-v7-0-0.md) —
deren Closure-Trigger trägt das Mehr über die DoD dieses Slice: die Gesamt-Gates
am neuen Stand, der Replay `make full-smoke` und der Bestands-Lese-Schritt.

**Bezug:** [`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(jede Aussage über die neue Baseline trägt den Tag), [`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
(das Mehr-Wahlkriterium der Welle), [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
(die Cluster-Slice-Kennungen tragen die Namens-Form).

**Berührte Spec-Stellen:** `—` — die Lesung schreibt keine Festlegung; Befunde,
die an das Technik-Stratum rühren, stehen als Befundzeile mit ihrem Spec-Bezug
in der Delta-Tafel.

**Verantwortlich:** `—` bis zur Priorisierung (Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine).

**Autor:** Planner (ai-harness-init-Team, pt9912). **Datum:** 2026-11-25.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Ziel:** Das neue Regelwerk unter `.harness/baseline/<tag>/` vollständig gegen
den Bestand lesen; je berührtem MR ([`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)–[`MR-093`](../../../../harness/conventions.md#mr-093--a-check-pin-v0232-go-sicherheitsfix-prüfverhalten-unverändert))
und je neuem/entfallenem Baseline-Stück eine Befundzeile mit Schätzung (S/M/L)
in der **Delta-Tafel** ([`welle-baseline-sprung-v7-0-0`](../welle-baseline-sprung-v7-0-0.md) §4) schreiben.
Aus der Tafel werden die **Cluster-Slices** geschnitten — Modul 5: Plan und
Implementation alternieren; die Welle schneidet nicht vorab.

**Der Konsument der Tafel steht in ihren Zeilen:** je Befundzeile trägt eine
**Cluster-Slice-Kennung** (Slice-Datei in `open/`, [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)-Form —
das `Übernimmt:`-Feld des Slice nimmt den Befund an), eine ausdrückliche
**Ablehnung mit Grund** oder die **Deckung durch Bestand mit Zeiger**. Keine
Zeile nur mit Schätzung — das wäre eine Adresse, die niemand trägt.

**Ausdrücklich NICHT in diesem Slice:**

- **Jede Implementation** (Code, Doku-Texte, verkörperte Regeln) — ein anderer
  Vorgang (Klasse 3): die Befundzeile trägt Schätzung und Ausgangs-Adresse, die
  Umsetzung trägt der geschnittene Cluster-Slice.
- **Anpassung des Bestands an den neuen Baum** — genau das wird hier nur
  gelesen und geschätzt; sie übernimmt die Cluster-Slices (Klasse 1, oben).
- **Der d-check-Pin-Sprung (v0.93.0)** — wellenloser nebellaufender Slice
  (Klasse 3, wie im Vendorier-Slice).

## 2. Definition of Done

- [ ] **(1) Die Delta-Tafel in der Welle-Datei (§4) steht:** je Befund eine
      Zeile mit Schätzung S/M/L **und** einem der drei Ausgänge —
      Cluster-Slice-Kennung (Slice-Datei in `open/`), ausdrückliche Ablehnung
      mit Grund, Bestand mit Zeiger. Keine Zeile nur mit Schätzung; jede
      Kennung löst (`ls docs/plan/planning/open/` nennt sie).
- [ ] **(2) Die Cluster-Slice-Pläne tragen die Sichtung:** Sub-Area-Wahl und
      Beobachtungs-Sichtung (§8) je geschnittenem Slice nachgetragen, mit dem
      Zähler-Stand des Registers.
- [ ] `make docs-check` grün über die geänderten Plan-Artefakte — der
      Voll-Gate-Lauf bleibt an der Welle-Closure (der Zwischen-Rot-Zustand der
      Welle §1 ist hierin keine Ausnahme, sondern der geplante Stand).
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor —
      kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — weitere
      Datei in `evidence/` je getroffenem Eintrag; kein Zähler wird gesetzt.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) prüft die nächste
      Welle-Closure — hier die [`welle-baseline-sprung-v7-0-0`](../welle-baseline-sprung-v7-0-0.md)-Closure.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`welle-baseline-sprung-v7-0-0.md`](../welle-baseline-sprung-v7-0-0.md) | update | §4: Delta-Tafel angelegt und gefüllt (Les-Stand) |
| `docs/plan/planning/open/slice-<cluster>-<titel>.md` | neu | je Cluster-Slice aus der Tafel — Kennung nach [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) |

**Ansatz:** Die Lesung läuft über den Befund-Katalog des Upstreams (diff-Katalog
der Regelwerk-Bäume) und endet in der Tafel; die Cluster-Slices werden so
geschnitten, dass jede Befundzeile einen Ausgang trägt — die Schätzung S/M/L
steht an der Zeile, nicht als Prosa daneben.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [`slice-baseline-vendorung-v7-0-0`](slice-baseline-vendorung-v7-0-0.md)
liegt in `done/` — die Befunde lesen sich erst am neuen Baum.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): die Lesung kippt in
  Umsetzung — ein Befund drängt, im selben Slice repariert zu werden statt
  Schätzung + Adresse zu tragen.
- `in-progress` → `open` (blockiert — Carveout?): der neue Baum ist unlesbar
  oder die Befundlage nicht reproduzierbar.

## 5. Closure-Trigger

**Erstens:** die Delta-Tafel ist komplett — keine Befundzeile mit leerem
Schätzung- oder Ausgangs-Feld, jede genannte Kennung liegt als Slice-Datei in
`open/` oder trägt Ablehnung/Bestand. **Zweitens:** `make docs-check` grün über
die geänderten Plan-Artefakte. Dazu die Closure-Notiz mit Lerneintrag und je
Risiko aus §6 genau ein Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Lesung übersteigt einen Slice** (Befundmenge L, die Tafel wird zur
  Unform). — **Ausgang:** <eingetreten: Rückführung nach §4 — Cluster vor der
  Tafel | entfallen: die Tafel trägt>
- **[`BEO-ALL/re-baseline-ohne-inventur-slice`](../observations/BEO-ALL/re-baseline-ohne-inventur-slice/observation.md)
  erreicht mit dieser Lesung den dritten Beleg** (Zähler 2×, offen — für den
  Sprung v5.12.0→v5.18.0 trug der Diff-Katalog von slice-155 §9 die Klasse).
  — **Ausgang:** <weiter offen: der Lese-Schritt weist den Ausgang bei der
  Closure zu — die Lesung ist genau die Inventur-Form, die die Beobachtung
  fordert; Anker `seit slice-baseline-delta-lesung-v7-0-0`>
- **Befunde kollidieren mit Hard Rules ([`AGENTS.md`](../../../../AGENTS.md) §3)** —
  der übernommene Regelwerk-Satz gegen die eigene Zeile. — **Ausgang:**
  <weiter offen: → [`BEO-ALL/uebernommener-regelwerk-satz-kollidiert-mit-eigener-hard-rule`](../observations/BEO-ALL/uebernommener-regelwerk-satz-kollidiert-mit-eigener-hard-rule/observation.md);
  die Tafel nennt jede Kollision, der Träger bleibt das Trigger-Audit>

## 7. Closure-Notiz

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist der vendored Regelwerk-Baum
unter `.harness/baseline/<tag>/` und die Berührungs-Form desselben (Adaptions-
Block, `AGENTS.md` Hard Rules); alles fällt unter den Eintrag `*` (gesamtes
Repo) der Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area).

**Vorgelagert — offene Beobachtungen sichten:** Register `BEO-ALL`
durchgegangen. Treffer: [`BEO-ALL/re-baseline-ohne-inventur-slice`](../observations/BEO-ALL/re-baseline-ohne-inventur-slice/observation.md)
(2×, offen — erreicht mit diesem Slice den dritten Beleg, Ausgang in §6/§7),
[`BEO-ALL/stand-feld-ausserhalb-des-konventionsspeichers-bleibt-beim-sprung-stehen`](../observations/BEO-ALL/stand-feld-ausserhalb-des-konventionsspeichers-bleibt-beim-sprung-stehen/observation.md)
(1×, offen — die Lesung zählt die betroffenen `Stand:`-Zellen zum Befund),
[`BEO-ALL/retirierter-adaptions-eintrag-als-lebende-begruendung-zitiert`](../observations/BEO-ALL/retirierter-adaptions-eintrag-als-lebende-begruendung-zitiert/observation.md)
(1×, offen — die aufgelösten Einträge des Blocks gehen in die Lesung ein),
[`BEO-ALL/adaptions-eintrag-nennt-einen-konfigurationswert-den-ein-slice-fortschreibt`](../observations/BEO-ALL/adaptions-eintrag-nennt-einen-konfigurationswert-den-ein-slice-fortschreibt/observation.md)
(1×, offen — Werte, die Cluster-Slices fortschreiben, nennt die Tafel je Zeile),
[`BEO-ALL/tag-tragende-adresse-ueberlebt-den-baseline-tausch-nicht`](../observations/BEO-ALL/tag-tragende-adresse-ueberlebt-den-baseline-tausch-nicht/observation.md)
(3× — Bestandsdeckung: der Ausgang steht, [`slice-162-versions-sensor-baseline-pins`](slice-162-versions-sensor-baseline-pins.md)
ist die Adresse in `open/`). Keine weitere Berührung erreicht hier die
Schwelle.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF — entfällt nach dem
Umfang-Absatz der Vorlage.
