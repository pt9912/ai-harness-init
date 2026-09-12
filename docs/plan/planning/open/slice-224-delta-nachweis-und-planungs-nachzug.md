# Slice slice-224: Der Delta-Nachweis gegen `v6.0.0` steht, und die lebenden Planungs-Artefakte tragen die neue Ziel-Form

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — aus demselben Grund und mit derselben Prüfung wie
[slice-223](../next/slice-223-baum-tausch-v672-pins-ziehen.md): Es gibt keine Closure-Bedingung,
die mehr beobachtet als die DoD dieses Slice, und
[`ADR-0044`](../../adr/0044-ziel-fassung-regiert-den-sprung-v672.md) §Konsequenzen ordnet für den
Vollzug **Slices** an, kein Bündel. Nach
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
steht wellenlose Arbeit nicht in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: Dogfood, nicht emittiert.** Gegenstand sind der Nachweis selbst und die lebenden
Planungs-Artefakte **dieses** Repos. Die emittierte Ebene bleibt draußen und hat einen benannten
Ausgang (§1).

**Vorgabe des Auftraggebers, empfangen am 2026-09-12 — sie setzt die Beweislast dieses
Durchgangs:** *auf das neueste Regelwerk umstellen*, und auf die Frage, wer über Abweichungen
entscheidet: *„Nein, der Architekt wird das nicht entscheiden — wir geben es vor."* **Übernehmen
ist damit die Vorgabe, nicht die Voreinstellung.** Für diesen Durchgang folgt zweierlei, und beides
ist Randbedingung, keine Setzung dieses Plans:

1. Je Delta-Posten gibt es faktisch **zwei** Antworten — *übernommen* oder *schon erfüllt*. Die
   dritte (*abweichend*) ist durch die Vorgabe ausgeschlossen.
2. **Aus diesem Durchgang entsteht kein neuer `MR`-Eintrag.** Ein Eintrag bucht eine *gewollte*
   Abweichung ([`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)), und die
   gibt es nicht. Die Gegenrichtung gilt unverändert: ein **bestehender** Eintrag, dessen
   Auflösungs-Trigger der neue Stand feuert, wandert nach `harness/conventions/done/`
   ([`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf),
   [`MR-038`](../../../../harness/conventions.md#mr-038--ein-retirierender-eintrag-nennt-den-baseline-stand-der-seinen-trigger-feuerte))
   — das liegt bei [slice-225](../open/slice-225-gate-index-steht-einmal.md), weil der
   Adaptions-Block Architect-Eigentum ist.

**Färbt ein Posten beim Übernehmen ein Gate rot, ist das eine Messung und geht als Meldung zurück
an den Auftraggeber** — nicht in einen `MR`-Eintrag und nicht in eine stille Ausnahme. Wo dieser
Plan so einen Fall für möglich hält, steht er in §6.

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Delta-Messung läuft
gegen zwei Tags eines gepinnten Repos, nicht gegen `main`),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein
Gate liest, nach welcher Fassung ein Durchgang lief oder ab welchem Stand er misst — dieser Slice
behauptet dafür keine Deckung),
[`ADR-0044`](../../adr/0044-ziel-fassung-regiert-den-sprung-v672.md) (Festlegung 1: die
**regierende Fassung** dieses Sprungs ist `v6.7.2`; §Konsequenzen ordnet diesen Slice an),
[`ADR-0043`](../../adr/0043-ziel-fassung-regiert-den-sprung-v671.md) (Festlegung 2, **nicht**
abgelöst: die **Delta-Basis** ist der letzte Stand, für den §Baseline einen Slice mit
Delta-Nachweis ausweist — heute `v6.0.0`),
[`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) (Festlegung 4 — die Deutung
der Ausgänge je Eintrag),
[`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (ein
Rollen-Anweisungssatz gehört der Rolle, die ihn ausführt — deshalb steht
`.claude/commands/implement-slice.md` in §1 als Übergabe und nicht in §2),
[`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
und [`MR-041`](../../../../harness/conventions.md#mr-041--die-referenz-statt-kopie-setzung-für-ausfüll-templates-steht-jetzt-in-der-adoptierten-baseline)
(Ausfüll-Vorlagen werden **referenziert, nicht kopiert** — der tragende Grund, warum ein
Vorlagen-Delta mit dem Baum ankommt und dieser Slice nur den **Bestand** nachzieht),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben ihrem Kommando),
[`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(jede Aussage über die Baseline nennt ihren Mess-Tag).

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle; Gegenstand sind ein Nachweis
und Planungs-Artefakte).

**Verantwortlich:** — (bis zur Priorisierung).

**Autor:** Planner. **Datum:** 2026-09-12.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Jeder Posten des Deltas `v6.0.0..v6.7.2` trägt eine der zwei Antworten — *übernommen*
oder *schon erfüllt* — mit Beleg, und die lebenden Planungs-Artefakte dieses Repos tragen die
Ziel-Formen, die dieses Delta bewegt hat.

### Die Delta-Basis ist gelesen, nicht gewählt

`v6.0.0` ist der letzte Stand, für den §Baseline von
[`harness/conventions.md`](../../../../harness/conventions.md) einen Slice mit Delta-Nachweis
ausweist (`slice-176`); der `v6.5.0`-Nachweis steht dort als *steht aus*. Damit schließt dieser
Durchgang **zwei** Sprünge ein, und seine Kennung ist der Wert **beider** offenen
Nachweis-Felder der Buchung — so ordnet es
[`ADR-0044`](../../adr/0044-ziel-fassung-regiert-den-sprung-v672.md) §Konsequenzen an, und die
Leseregel selbst steht in
[`ADR-0043`](../../adr/0043-ziel-fassung-regiert-den-sprung-v671.md) Festlegung 2, die **nicht**
abgelöst ist.

**Gemessen wird am lokalen Kurs-Klon**, weil beide Seiten des Deltas als Tag nur dort vorliegen;
der Pathspec ist der der Quelle im Klon, nicht der des vendored Baums hier. Die Zahlen wandern mit
dem Klon-Stand und sind **keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2):

```sh
cd /Development/KI/ai-harness-course
git diff --shortstat v6.0.0..v6.7.2 -- lab/regelwerk/ lab/templates/   # 42 Dateien, +907/−404
git diff --shortstat v6.0.0..v6.5.0 -- lab/regelwerk/ lab/templates/   # 32 Dateien, +624/−153
git diff --shortstat v6.5.0..v6.7.2 -- lab/regelwerk/ lab/templates/   # 33 Dateien, +295/−263
git log  --oneline  v6.0.0..v6.7.2  -- lab/regelwerk/ lab/templates/   # 11 Commits, Kurs-Wellen 118–134
```

Die 42 Posten sind **nicht** 32 + 33: **23** Dateien ändern sich in **beiden** Hälften.

```sh
cd /Development/KI/ai-harness-course
comm -12 <(git diff --name-only v6.0.0..v6.5.0 -- lab/regelwerk/ lab/templates/ | sort) \
         <(git diff --name-only v6.5.0..v6.7.2 -- lab/regelwerk/ lab/templates/ | sort) | wc -l   # 23
```

Genau deshalb ist dieser Durchgang **einer** und nicht zwei nach Delta-Bereich geteilte: Zwei Läufe
schrieben 23-mal dieselbe Zieldatei, der zweite müsste die Entscheidungen des ersten wieder
aufmachen, und beide führen ihr Urteil gegen dieselbe regierende Fassung `v6.7.2` — die Teilung
brächte den Streit, den
[`ADR-0043`](../../adr/0043-ziel-fassung-regiert-den-sprung-v671.md) §Verglichene Alternativen unter
Option E verwirft.

### Was ein Vorlagen-Delta hier kostet, und was nicht

Dieses Repo **referenziert** die Ausfüll-Vorlagen, es kopiert sie nicht
([`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert),
[`MR-041`](../../../../harness/conventions.md#mr-041--die-referenz-statt-kopie-setzung-für-ausfüll-templates-steht-jetzt-in-der-adoptierten-baseline)).
Eine geänderte Vorlage ist damit **mit dem Baum-Tausch schon adoptiert** und gilt für jedes
Artefakt, das ab dann daraus entsteht. Zu tun bleibt der **Bestand**: lebende Artefakte, die eine
alte Ziel-Form verkörpern und fortgeschrieben werden. Der Nachweis muss das je Posten
unterscheiden — eine Vorlage, deren Bestand leer ist, ist *schon erfüllt* durch den Tausch, nicht
durch Arbeit.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Posten, der in `AGENTS.md`, `harness/README.md`, [`.d-check.yml`](../../../../.d-check.yml)
  oder [`harness/conventions/`](../../../../harness/conventions/) landet.**
  [slice-225](../open/slice-225-gate-index-steht-einmal.md) übernimmt sie; dieser Slice **benennt**
  sie im Nachweis und vollzieht sie nicht. Der Grund ist der Beleg: Jene Posten schließt ein
  Gate-Lauf, diese ein Form-Vergleich gegen den vendored Baum — wer beides in einen Slice legt,
  lässt ein grünes `make gates` als Deckung für eine Hälfte lesen, die es nie berührt hat
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine
  Ebene tiefer). *Folge-Slice übernimmt es*, und slice-225 nimmt die Sendung an: sein §1 nennt
  genau diesen Gegenstand.
- **Kein neuer `MR`-Eintrag.** Die Vorgabe des Auftraggebers schließt gewollte Abweichungen aus
  (Kopf); ein Eintrag ohne Abweichung wäre Buchführung über nichts. Und der Adaptions-Block ist
  Architect-Eigentum ([`AGENTS.md`](../../../../AGENTS.md) §3.8) — *es wäre ein anderer Vorgang
  einer anderen Rolle*.
- **Keine Form-Änderung an `docs/reviews/review-report.template.md`-Bestand und keine
  `structure`-Regel dafür.** [slice-213](../open/slice-213-review-report-laeuft-in-der-tabellen-form.md)
  (Findings- und Negativbefund-Tabelle plus Gate) und
  [slice-214](../open/slice-214-zellengrenze-wird-gemessen-statt-gesetzt.md) (der gemessene
  Grenzwert) liegen dafür geschnitten in `open/`. Was slice-213 §1 ausdrücklich **an die Adoption
  der Vorlage abgibt** — die Kennungs-Notation im Kopf und in der Zitier-Form —, nimmt dieser
  Slice an; die Sendung geht also in beide Richtungen und in keiner doppelt. *Folge-Slice
  übernimmt es.*
- **Nichts auf der emittierten Ebene** (`internal/emit/templates/`). Sie hat einen eigenen
  Prüfbereich und einen eigenen Beleg — `make full-smoke`, nicht `make gates` — und ihre
  Zusammensetzung entscheiden
  [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  und [`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed);
  [slice-210](../open/slice-210-planning-modul-im-emittierten-doc-gate.md),
  [slice-211](../open/slice-211-codepaths-im-emittierten-doc-gate.md) und
  [slice-212](../open/slice-212-modul-aktivierung-hat-keinen-adaptions-eintrag.md) liegen dafür in
  `open/`. **Gemessen, nicht vermutet:** `internal/emit/templates/commands/` trägt 6 der 25
  lebenden Vorkommen der alten Kennungs-Notation
  (`git grep -cE 'slice-<NNN>|welle-<NN>' -- internal/emit/templates`) — sie bleiben hier liegen.
  *Schicht-Abgrenzung.*
- **Kein Schreibzugriff auf `.claude/commands/implement-slice.md` und
  `.harness/skills/reviewer.md`.** Beide sind Rollen-Anweisungssätze und gehören der Rolle, die sie
  **ausführt** ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md));
  dieser Slice plant ihre Änderung und übergibt sie, er schreibt sie nicht. *Es wäre ein anderer
  Vorgang einer anderen Rolle.*

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

Drei slice-eigene Punkte. Gezählt ist nur, was mit dem Umfang wächst.

- [ ] **1 — Der Delta-Nachweis liegt vor und ist vollständig.** Alle **42** Posten des Deltas
      `v6.0.0..v6.7.2` (Pathspec `lab/regelwerk/ lab/templates/`, Kommando in §1) tragen je eine
      der zwei Antworten — *übernommen* oder *schon erfüllt* — mit Beleg. **Vollständig heißt: die
      Zahl der beurteilten Posten ist die Zahl, die `git diff --name-only` ausgibt**, gemessen im
      Lauf und nicht aus diesem Plan übernommen; ein Posten ohne Antwort ist der Befund, nicht eine
      Auslassung. Der Nachweis nennt den **Mess-Tag beider Seiten**
      ([`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist))
      und je Posten den Ort, an dem er landet — in diesem Slice, in
      [slice-225](../open/slice-225-gate-index-steht-einmal.md), oder in einem der in §1
      ausgeschlossenen Bereiche mit dessen Kennung. Er ist der Wert **beider** offenen
      Nachweis-Felder der §Baseline-Buchung (`v6.5.0` und `v6.7.2`).
- [ ] **2 — Die lebenden Planungs-Artefakte tragen die neue Ziel-Form.** Prüfbereich ist der
      Bestand, den dieser Slice besitzt: [`docs/plan/planning/README.md`](../README.md),
      [`docs/plan/planning/observations/README.md`](../observations/README.md),
      [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md), die flachen
      Welle-Dateien unter `docs/plan/planning/` und die Planner-Anweisungssätze
      [`.claude/commands/plan-welle.md`](../../../../.claude/commands/plan-welle.md) und
      [`.claude/commands/close-welle.md`](../../../../.claude/commands/close-welle.md).
      Der Nachzug der Kennungs-Notation (`slice-<NNN>` → `slice-<Kennung>`,
      `· seit welle-<NN>` → `· seit welle-<Kennung>`) ist in diesem Bereich vollständig; nach dem
      Lauf liefert

      ```sh
      git grep -nE 'slice-<NNN>|welle-<NN>' -- docs/plan/planning .claude/commands \
        ':!docs/plan/planning/done'
      ```

      nur noch Treffer in `implement-slice.md`, das §1 an die Implementer-Rolle übergibt.
- [ ] **3 — Jede Sendung an eine andere Rolle liegt als Übergabe-Artefakt vor.** Für jeden Posten,
      den §1 ausschließt, nennt der Nachweis den Empfänger und das, was er bekommt: die
      Norm-/Gate-Posten an [slice-225](../open/slice-225-gate-index-steht-einmal.md), die
      Anweisungssätze `implement-slice.md` und `.harness/skills/reviewer.md` an Implementer bzw.
      Reviewer ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)),
      die emittierte Ebene an
      [slice-210](../open/slice-210-planning-modul-im-emittierten-doc-gate.md)/
      [slice-211](../open/slice-211-codepaths-im-emittierten-doc-gate.md)/
      [slice-212](../open/slice-212-modul-aktivierung-hat-keinen-adaptions-eintrag.md). **Ein
      Rollenwechsel ohne Artefakt ist keiner** (`v6.5.0` · `regelwerk/modul-08-agentenrollen.md`
      §Die neun Übergaben und ihre Artefakte); eine Sendung ohne Empfänger ist der Befund.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: kein öffentlicher Vertrag berührt — die Buchung der Nachweis-Kennung in
      §Baseline von [`harness/conventions.md`](../../../../harness/conventions.md) ist
      Architect-Arbeit und liegt als Übergabe-Artefakt aus Liefer-Punkt 3 vor.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht (`ls docs/plan/planning/reconciliation.md`).
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo fährt Wellen (`ls docs/plan/planning/welle-*.md`), sie werden deshalb von der nächsten Welle-Closure geprüft, auch für diesen Slice ohne Wellen-Zugehörigkeit.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| §9 dieses Plans (Delta-Nachweis, 42 Posten) | neu | der Nachweis selbst; Präzedenz der Form: [slice-176](../done/slice-176-inventur-vor-dem-schnitt-v600.md) §9 |
| [`docs/plan/planning/observations/README.md`](../observations/README.md) | update | trägt 2 Vorkommen der alten Kennungs-Notation; derivativ zur Register-Ziel-Form |
| [`docs/plan/planning/README.md`](../README.md) | update | Lifecycle-Beschreibung gegen `planning/README.template.md` (2/2) halten |
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | update | `roadmap.template.md` bewegt 5/5 Zeilen |
| flache `welle-*.md` unter `docs/plan/planning/` | update | `welle.template.md` (5/5); `welle-13` trägt 2 Vorkommen der alten Notation |
| [`.claude/commands/plan-welle.md`](../../../../.claude/commands/plan-welle.md), [`.claude/commands/close-welle.md`](../../../../.claude/commands/close-welle.md) | update | Planner-Anweisungssätze; `close-welle.md` trägt 1 Vorkommen |
| Übergabe-Artefakte an slice-225, Implementer, Reviewer, emittierte Ebene | neu | Liefer-Punkt 3 |

**Was hier bewusst fehlt:** eine Zeile für `.harness/baseline/**`. Der Baum wird von
[slice-223](../next/slice-223-baum-tausch-v672-pins-ziehen.md) getauscht und ist hier
**Mess-Grundlage**, nicht Gegenstand.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`):
[slice-223](../next/slice-223-baum-tausch-v672-pins-ziehen.md) liegt in `done/` — ablesbar an
`ls docs/plan/planning/done/slice-223-*.md` auf dem Hauptzweig. Beobachtbar ohne Rückfrage, und
**kein Ergebnis dieses Slice**: Baum und Pins stehen in keiner DoD-Zeile von §2. Der Trigger ist
inhaltlich nötig, nicht nur sequenziell — die regierende Fassung `v6.7.2` muss im Baum liegen,
damit der Nachweis netzlos gegen sie misst.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Der Nachweis weist der **Planungs-Ebene**
  mehr als die zwei Liefer-Punkte 2 und 3 zu — konkret, wenn ein Posten dort eine Ziel-Form
  bewegt, die einen eigenen Sensor oder eine eigene Entscheidung braucht (etwa die
  Archiv-Stub-Form, `archiv-stub-slice.template.md` +9/−1 und `archiv-stub-welle.template.md`
  +8/−0). Dann behält dieser Slice den Nachweis und der Vollzug wird ein eigener.
- `in-progress` → `open` (blockiert — Carveout?): Ein Posten lässt sich weder als *übernommen*
  noch als *schon erfüllt* beantworten, weil seine Übernahme eine Entscheidung verlangt, die die
  Vorgabe des Auftraggebers nicht deckt — etwa wenn Übernehmen ein Gate rot färbt und die rote
  Stelle außerhalb dieses Slice liegt. Dann geht die **Messung** zurück an den Auftraggeber
  (Kopf), und der Slice wartet auf die Antwort.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: (1) Die Zahl der in §9 beurteilten Posten ist die Zahl, die
`git diff --name-only v6.0.0..v6.7.2 -- lab/regelwerk/ lab/templates/` im Lauf ausgibt, und
`make gates` ist grün. (2) Der Review-Report zu diesem Slice liegt unter `docs/reviews/` und trägt
keinen blockierenden Befund. Dazu der Lerneintrag in §7 und für jedes Risiko aus §6 ein Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Nachweis wächst über den Slice hinaus.** 42 Posten je mit Beleg ist ein Dokument, das in
  *einer* Review-Sitzung geprüft werden muss; Register-Stand der Klasse
  `slice-plan-umfang-waechst-ueber-umsetzung-hinaus`: **2×**
  (`ls docs/plan/planning/observations/BEO-ALL/slice-plan-umfang-waechst-ueber-umsetzung-hinaus/evidence/*.md | wc -l`).
  Die Rückführung `in-progress → next` in §4 ist die vorab benannte Antwort. — **Ausgang:** offen
  bis zur Closure.
- **Ein Posten färbt beim Übernehmen ein Gate rot.** Zwei Stellen halte ich dafür für möglich, und
  beide liegen in [slice-225](../open/slice-225-gate-index-steht-einmal.md), nicht hier: der
  `authority`-Wechsel des `targets`-Moduls und eine Aktivierung des `reviews`-Moduls über
  `done/`-Slices, die eine Review-DoD-Zeile tragen, aber keinen Report unter `docs/reviews/`. Wird
  ein solcher Fall **hier** sichtbar, geht er als Messung an den Auftraggeber (Kopf) und nicht in
  einen Eintrag. — **Ausgang:** offen bis zur Closure.
- **„Byte-gleich" wird als Antwort auf die Regel-Frage gelesen.** Ein Posten, dessen Datei sich
  nicht geändert hat, ist damit noch nicht *schon erfüllt*: Die Frage ist, ob **unser Bestand** die
  Regel trägt, nicht, ob die Vorlage sich bewegt hat. Register-Stand der Klasse
  `byte-gleichheit-als-aussage-ueber-die-regel-gelesen`: **2×**
  (`ls docs/plan/planning/observations/BEO-ALL/byte-gleichheit-als-aussage-ueber-die-regel-gelesen/evidence/*.md | wc -l`);
  [`ADR-0044`](../../adr/0044-ziel-fassung-regiert-den-sprung-v672.md) führt dieselbe Entkräftung
  als eigenen Punkt. — **Ausgang:** offen bis zur Closure.
- **Ein offener Plan in `open/`/`next/` verpflichtet nach dem Sprung anders, und dieser Slice
  sieht ihn nicht.** Der Nachweis prüft das Delta gegen den Bestand, nicht gegen die **Pläne**;
  `open/` und `next/` führen zusammen **70** Slice-Pläne
  (`ls docs/plan/planning/open docs/plan/planning/next | grep -c '^slice-'`, kein
  Erwartungswert). Register-Stand der
  Klasse `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`: **3×** — die Schwelle ist
  erreicht, und der Lese-Schritt gehört in die Closure. — **Ausgang:** offen bis zur Closure.
- **Der Zuschnitt zwischen diesem Slice und slice-225 ist eine Vorab-Zuordnung.** Er ist nach dem
  **Beleg** geschnitten (Form-Vergleich gegen Gate-Lauf), und der Nachweis kann ergeben, dass ein
  Posten auf der falschen Seite liegt. Register-Stand der Klasse
  `uebergabe-an-andere-rolle-ohne-traeger-artefakt`: **2×**
  (`ls docs/plan/planning/observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/evidence/*.md | wc -l`)
  — deshalb verlangt Liefer-Punkt 3 je Sendung ein benanntes Artefakt. — **Ausgang:** offen bis zur
  Closure.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<…>`. Auslöser: `<BEO-ALL/<slug>>`.
  *(Wurde mit diesem Slice nichts verkörpert, entfällt die Teil-Zeile `— liegt in …` ersatzlos.)*
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <slice-225 (Der Gate-Index steht einmal) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <Repo **mit** Wellen-Betrieb — geprüft von der nächsten Welle-Closure, auch
  für diesen Slice ohne Wellen-Zugehörigkeit>

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
§Modus-Deklaration pro Sub-Area. Die Schwelle ≥ 2 von 3 Achsen ist erfüllt: eigener
Konventions-Bestand (der Adaptions-Block als Abweichungs-Register), eigener Prüfbereich
(`make docs-check` über den Planungs-Baum) und eigene Fehlermodi (Ziel-Form driftet gegen
Bestand). **`TOOLS` ist nicht berührt** — kein Posten des Deltas bewegt eine Aussage über
`harness/tools/`; **`CODEX` ebenso wenig** — der SessionStart-Injektor liest den Index des Baums,
und dessen Pfad bewegt [slice-223](../next/slice-223-baum-tausch-v672-pins-ziehen.md), nicht dieser
Slice. Pfad-Berührung allein genügt nicht.

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist am gemergten Stand durchgegangen
— **98** Verzeichnisse (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, **kein
Erwartungswert**); alle führen dieselbe Sub-Area `*`, die Sichtung ist damit vollständig. **Sechs
Treffer** berühren diesen Slice:

| Beobachtung (`BEO-ALL/<slug>`) | Zähler | Stand |
|---|---|---|
| `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht` | 3× | offen |
| `re-baseline-ohne-inventur-slice` | 2× | offen |
| `byte-gleichheit-als-aussage-ueber-die-regel-gelesen` | 2× | offen |
| `slice-plan-umfang-waechst-ueber-umsetzung-hinaus` | 2× | offen |
| `uebergabe-an-andere-rolle-ohne-traeger-artefakt` | 2× | offen |
| `baseline-aussage-ohne-mess-tag` | 2× | offen |

```sh
for s in folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht re-baseline-ohne-inventur-slice \
         byte-gleichheit-als-aussage-ueber-die-regel-gelesen \
         slice-plan-umfang-waechst-ueber-umsetzung-hinaus \
         uebergabe-an-andere-rolle-ohne-traeger-artefakt baseline-aussage-ohne-mess-tag; do
  printf '%s %s\n' "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)" "$s"
done
```

**`re-baseline-ohne-inventur-slice` ist der Eintrag, den dieser Slice beantwortet**, nicht der, den
er auslöst: Er sagt, dass die Form-Pflichten einer neuen Fassung einzeln als Nachzügler
zurückkommen, wenn kein Inventur-Slice vorangeht — dieser Slice **ist** der Inventur-Slice, und
sein Liefer-Punkt 1 ist genau die gebündelte Antwort. **`folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`
steht bei 3×**, also über der Schwelle, und zwar **vor** diesem Slice; der Lese-Schritt, der ihm
seinen Ausgang zuweist, gehört in die Closure und nicht in diese Planung.

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas sind Greenfield; der Block trägt
eine Sub-Area.

### Sub-Area: `*` (gesamtes Repo, Kürzel `ALL`)

- **Modus:** GF
- **Konventionen-Dichte:** hoch, und sie ist der Gegenstand: 52 aktive Einträge unter
  [`harness/conventions/`](../../../../harness/conventions/) plus 4 aufgelöste
  (`ls harness/conventions/MR-*.md | wc -l`, `ls harness/conventions/done/MR-*.md | wc -l` —
  keine Erwartungswerte). Der Durchgang misst gegen genau diesen Bestand; die Vorgabe des
  Auftraggebers (Kopf) sagt, dass er dabei nicht wächst.
- **Phase-Reife:** Phase 4 für die Planungs-Artefakte (Ziel-Formen stehen, Vorlagen werden
  referenziert statt kopiert, ein Teil ist gate-geprüft über das `planning`-Modul), Phase 2 für den
  Nachweis selbst — er hat eine erprobte Form (zwei Präzedenzfälle) und **keinen** Sensor.
- **Evidenz-/Diskrepanz-Risiko:** hoch, und es ist die tragende Größe dieses Slice. Die Diskrepanz
  läuft zwischen **Ziel-Form** und **Bestand**, und drei der sechs Treffer oben sagen, wie sie
  fehlgeht: als Überdehnung (`slice-plan-umfang-waechst-ueber-umsetzung-hinaus` 2×), als
  Fehlschluss aus Byte-Gleichheit (`byte-gleichheit-als-aussage-ueber-die-regel-gelesen` 2×) und
  als Sendung ohne Empfänger (`uebergabe-an-andere-rolle-ohne-traeger-artefakt` 2×). Die zwei
  vorangegangenen Durchgänge (`slice-155`, `slice-176`) sind die Erfahrungsbasis; der hiesige ist
  mit 42 Posten der größte von dreien.
- **Reconciliation-Aufwand:** keiner — GF, kein Inventur-Fund im Sinne des
  Reconciliation-Registers (die Datei existiert in diesem Repo nicht; das DoD-Item entfällt).
  Graduation entfällt (n/a bei GF). Der Trigger, der die Nachweis-Achse über Phase 2 hebt, ist ein
  Sensor, der Zielstand-Buchung und Nachweis-Kennung zusammenhält — er existiert nicht, und
  [`ADR-0044`](../../adr/0044-ziel-fassung-regiert-den-sprung-v672.md) §Konsequenzen benennt genau
  diese Lücke.

## 9. Delta-Nachweis `v6.0.0..v6.7.2`

Diese Sektion ist der Liefer-Gegenstand aus §2 Punkt 1 und wird **im Lauf** gefüllt, nicht in
dieser Planung. Die Form ist die von
[slice-176](../done/slice-176-inventur-vor-dem-schnitt-v600.md) §9 und
[slice-155](../done/slice-155-inventur-vor-dem-schnitt.md) §9: je Zeile ein Posten, je Posten eine
der zwei Antworten mit Beleg und dem Ort, an dem er landet. Die Zahl der Zeilen ist die Zahl, die
`git diff --name-only v6.0.0..v6.7.2 -- lab/regelwerk/ lab/templates/` im Lauf ausgibt.

| Posten (Datei im Kurs-Klon) | Kurs-Welle | Antwort | Beleg | landet in |
|---|---|---|---|---|
| <…> | <…> | übernommen \| schon erfüllt | <…> | slice-224 \| slice-225 \| <Kennung des in §1 ausgeschlossenen Bereichs> |
