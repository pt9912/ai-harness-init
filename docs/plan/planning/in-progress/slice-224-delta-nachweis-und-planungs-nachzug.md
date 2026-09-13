# Slice slice-224: Der Delta-Nachweis gegen `v6.0.0` steht, und die lebenden Planungs-Artefakte tragen die neue Ziel-Form

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — aus demselben Grund und mit derselben Prüfung wie
[slice-223](../done/slice-223-baum-tausch-v672-pins-ziehen.md): Es gibt keine Closure-Bedingung,
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

**Verantwortlich:** Implementer-Rolleninhaber dieses Laufs.

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
  und [`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  — eine eigene Gate-Aktivierung mit eigener Erprobung und eigenem rotem Gegenbeispiel, kein Nachzug
  dieses Slice. **Korrigiert (Review slice-224 MEDIUM-4):** keiner der drei zuvor hier genannten
  Slices trägt diesen Gegenstand — [slice-210](../open/slice-210-planning-modul-im-emittierten-doc-gate.md)
  und [slice-211](../open/slice-211-codepaths-im-emittierten-doc-gate.md) entscheiden über die
  Modul-Zusammensetzung des emittierten Doc-Gates, [slice-212](../open/slice-212-modul-aktivierung-hat-keinen-adaptions-eintrag.md)
  schließt die Kennungs-Notation wörtlich aus; die Ausschluss-Klasse *Schicht-Abgrenzung* trägt hier
  ohne Adresse. **Gemessen, nicht vermutet:** `internal/emit/templates/commands/` trägt 6 der 25
  lebenden Vorkommen der alten Kennungs-Notation
  (`git grep -cE 'slice-<NNN>|welle-<NN>' -- internal/emit/templates`) — sie bleiben hier liegen,
  ohne benannten Folge-Träger. *Schicht-Abgrenzung.*
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

- [x] **1 — Der Delta-Nachweis liegt vor und ist vollständig.** Alle **42** Posten des Deltas
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
- [x] **2 — Die lebenden Planungs-Artefakte tragen die neue Ziel-Form.** Prüfbereich ist der
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
- [x] **3 — Jede Sendung an eine andere Rolle liegt als Übergabe-Artefakt vor.** Für jeden Posten,
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
- [x] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: kein öffentlicher Vertrag berührt — die Buchung der Nachweis-Kennung in
      §Baseline von [`harness/conventions.md`](../../../../harness/conventions.md) ist
      Architect-Arbeit und liegt als Übergabe-Artefakt aus Liefer-Punkt 3 vor.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht (`ls docs/plan/planning/reconciliation.md`).
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
[slice-223](../done/slice-223-baum-tausch-v672-pins-ziehen.md) getauscht und ist hier
**Mess-Grundlage**, nicht Gegenstand.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`):
[slice-223](../done/slice-223-baum-tausch-v672-pins-ziehen.md) liegt in `done/` — ablesbar an
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
- **Zwei Sendungen aus Liefer-Punkt 3 haben keinen terminierten Träger** (Review slice-224
  MEDIUM-5, dieselbe Register-Klasse `uebergabe-an-andere-rolle-ohne-traeger-artefakt` wie oben, ein
  dritter, hier neu beobachteter Fall). Für `implement-slice.md` (Zeile zu `modul-09-implementierung.md`)
  endet die Sendung mit der Closure dieses Plans, ohne dass ein künftiger Implementer-Lauf sie
  aufnimmt — nach `grundlagen-traceability.md` §Der Fluss kommt der Volltext eines geschlossenen
  Slice in keinem lesenden Knoten mehr vor. Für `.harness/skills/reviewer.md` erzeugt §9 gar keine
  Zeile — keiner der 42 Posten ist diese Datei —, während Liefer-Punkt 3 die Sendung dennoch nennt;
  ihr Kopf trägt weiter `Baseline: … v6.0.0`, während `.harness/baseline/` nur `v6.7.2` führt. Für
  den Architect wurde mit demselben Sprung ein Träger geschnitten ([slice-225](../open/slice-225-gate-index-steht-einmal.md));
  für Implementer und Reviewer nicht. Einen neuen Slice dafür zu schneiden ist Planner-Arbeit
  ([`AGENTS.md`](../../../../AGENTS.md) §3.10) und liegt außerhalb dieses Laufs. — **Ausgang:** offen
  bis zur Closure.

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
und dessen Pfad bewegt [slice-223](../done/slice-223-baum-tausch-v672-pins-ziehen.md), nicht dieser
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

Gemessen im Lauf: `cd /Development/KI/ai-harness-course && git diff --name-only v6.0.0..v6.7.2 -- lab/regelwerk/ lab/templates/ | wc -l` → **42**. Die Tabelle hat **42** Zeilen, eine je Datei, in derselben Reihenfolge.

Zwei Antworten, gelesen gegen unseren Bestand: **schon erfüllt** heißt, unser Bestand erfüllt die Regel bereits (kein Handlungsbedarf, an niemanden). **übernommen** heißt, eine Adoptions-Handlung ist nötig — `landet in` sagt, wer sie trägt: `slice-224` (hier vollzogen), `slice-225`/`Implementer` (Übergabe, hier nur benannt) oder eine der in §1 ausgeschlossenen Kennungen (slice-210/211/212/213/214, emittierte Ebene). **Korrigiert (Review slice-224 MEDIUM-5):** `Reviewer` steht hier nicht mehr als Ziel — keine Zeile der Tabelle trägt diesen Wert, obwohl §1/§3 die Sendung an `.harness/skills/reviewer.md` benennen; der fehlende Träger für diese Sendung und für `Implementer` ist als offenes Risiko in §6 geführt. Die Klammerzusätze `(teilweise)` und `(Übergabe)` verfeinern **übernommen**, sie eröffnen keine dritte oder vierte Antwort — die Menge bleibt zwei (Review slice-224 LOW-1).

**Das erste Beleg-Kommando dieser Tabelle war blind für zwei Änderungsarten** (Review slice-224
MEDIUM-1): `grep -E '^[+-][^+-]'` trifft keine Markdown-Listenzeile (ihr zweites Zeichen ist wieder
`-`), und der nachgeschaltete `grep -vE '^[+-]\|'` filtert jede Tabellenzeile weg, auch neue. Jede
Zeile, die sich unten auf „ausschließlich Tabellen-Reformatierung"/„keine Inhaltsänderung" stützt,
ist mit dem robusteren Vergleich neu gefahren:

```sh
cd /Development/KI/ai-harness-course
diff <(git show v6.0.0:<datei> | sed 's/[[:space:]]\+/ /g; s/ *| */|/g') \
     <(git show v6.7.2:<datei> | sed 's/[[:space:]]\+/ /g; s/ *| */|/g')
```

Whitespace- und Spaltenbreiten-neutral, ohne die zwei Blindstellen des ersten Kommandos: Es filtert
keine Zeilenklasse heraus, sondern zeigt jede tatsächlich geänderte Zeile. Ergebnis über die
betroffenen Posten: `grundlagen-begriffe.md` **3** Zeilen (nicht 0 — die Zelle unten ist korrigiert),
`grundlagen-bootstrap.md`/`grundlagen-klassifikation.md`/`modul-04-adrs.md`/
`modul-11-verification.md`/`modul-12-replay-evaluierung.md`/`modul-14-docker-harness.md` je **0**
(die Behauptung „ausschließlich Tabellen-Reformatierung" hält), `modul-08-agentenrollen.md` **4**
und `modul-16-produktiver-betrieb.md` **2** (beide nicht 0 — die Zellen unten sind korrigiert).

**Verteilung, gemessen über die fertige Tabelle** (Review slice-224 LOW-1; die dem Reviewer
zuvor genannte Verteilung *32 × schon erfüllt / 10 × übernommen, sechs Übergaben* traf nicht zu):

```sh
F=docs/plan/planning/in-progress/slice-224-delta-nachweis-und-planungs-nachzug.md
sed -n '/^| Posten (Datei im Kurs-Klon)/,$p' "$F" | grep -E '^\| `lab/' \
  | awk -F'|' '{print $4}' | sed 's/^ *//;s/ *$//' | sort | uniq -c
#  29 schon erfüllt · 11 übernommen · 1 übernommen (teilweise) · 1 übernommen (Übergabe)  →  29/13, Summe 42
sed -n '/^| Posten (Datei im Kurs-Klon)/,$p' "$F" | grep -E '^\| `lab/' \
  | grep -ocE '\| (slice-225|slice-213/slice-214|Implementer \(Übergabe\)) \|$'
#  9 — Zeilen, deren `landet in` eine andere Rolle/einen anderen Slice nennt (Übergaben), nicht 6
```

Keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — beide Zahlen gelten für den Stand dieser Tabelle nach den Review-Korrekturen und
wandern mit jeder weiteren Änderung an ihr.

| Posten (Datei im Kurs-Klon) | Kurs-Welle | Antwort | Beleg | landet in |
|---|---|---|---|---|
| `lab/regelwerk/README.md` | 134 | schon erfüllt | reine `Stand:`-Zeilen-Aktualisierung (Kurs-Welle 116→134); vendored bereits über den Baum-Tausch ([slice-223](../done/slice-223-baum-tausch-v672-pins-ziehen.md)), und `harness/conventions.md` §Baseline nennt bereits „Kurs-Welle 134 · 2026-09-12" (`grep -n 'Kurs-Welle' harness/conventions.md`) | slice-224 |
| `lab/regelwerk/grundlagen-begriffe.md` | 132 | schon erfüllt | **korrigiert (Review slice-224 MEDIUM-1):** das ursprüngliche Beleg-Kommando filtert Tabellenzeilen heraus und sieht sie nicht; der robustere Vergleich (§9-Intro) zeigt **3** neue Glossar-Einträge: `Plan (vor Code)`, `RTM`, `harness/sensors/<target>.md`. Keiner begründet eine eigene Pflicht neben dem, was andere Zeilen dieser Tabelle schon tragen: `Plan (vor Code)` beschreibt §3 dieses Plans (Datei-Tabelle vor Code, hier bereits geführt); `RTM` beschreibt die neue Sektion in `grundlagen-traceability.md` (Zeile unten, eigener Beleg); `harness/sensors/<target>.md` beschreibt das Muster, das `gate.template.md` (Zeile unten, 15 Dateien) schon vollständig trägt. **schon erfüllt** bleibt richtig, aus dem richtigen Grund | slice-224 |
| `lab/regelwerk/grundlagen-bootstrap.md` | 125-128 | schon erfüllt | ausschließlich Tabellen-Reformatierung, keine Inhaltsänderung (dieselbe Prüfung wie oben, gegen diese Datei → leer) | slice-224 |
| `lab/regelwerk/grundlagen-durchsetzungsschicht.md` | 125-128 | schon erfüllt | 1 Zeile Formatierung, keine Inhaltsänderung | slice-224 |
| `lab/regelwerk/grundlagen-harness-dateien.md` | 134 | übernommen (teilweise) | Muster `harness/sensors/<target>.md` bereits im Bestand (`ls harness/sensors/*.md \| wc -l` → **15**); `AGENTS.md` §3.11 trägt bereits „Kennung statt Adresse" für einfrierende Artefakte. Offen: die „Gate-Index steht einmal"-Konsequenz (`AGENTS.md` trägt Regel+Zeiger, nicht die Liste — `AGENTS.md` §4 führt die Liste heute noch selbst) | slice-225 |
| `lab/regelwerk/grundlagen-klassifikation.md` | 125-128 | schon erfüllt | ausschließlich Tabellen-Reformatierung | slice-224 |
| `lab/regelwerk/grundlagen-referenz-richtung.md` | 130-131 | schon erfüllt | Tabellen-Reformatierung + ein Beispiel-Platzhalter (`slice-NNN` → `slice-tie-break-determinismus`), keine neue Pflicht | slice-224 |
| `lab/regelwerk/grundlagen-source-precedence.md` | 130-131 | übernommen | **korrigiert (Review slice-224 HIGH-1):** §Vergabe sagt seit diesem Stand ausdrücklich „**Welle- und Slice-Kennungen sind Namen, nicht Nummern — unabhängig von der Schreiberzahl**" (`.harness/baseline/v6.7.2/regelwerk/grundlagen-source-precedence.md:360`) und hat den Absatz gestrichen, der in `v6.0.0` dichte Nummern für Ein-Schreiber-Repos ausdrücklich lizenzierte. Das trägt unser [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (`slice-NNN`/`welle-NN`) nicht mehr — das war die Antwort *schon erfüllt* zu Unrecht. **Entscheidung des Auftraggebers, empfangen am 2026-09-12:** ab jetzt Namen für neue Welle-/Slice-Kennungen, kein Nachrüsten des Bestands — bestehende `slice-<NNN>`/`welle-<NN>` behalten ihre Nummer. Das ist der Ausgang **übernommen** im Sinne des Plan-Kopfs, keine Feststellung: [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) bleibt nach [`MR-032`](../../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger) inhaltlich unverändert und bekommt eine Kopf-Marke auf einen neuen Eintrag, der diese Cutoff-Setzung trägt — Architect-Arbeit am Adaptions-Block ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Nicht behauptet: dass dieser Slice oder sein Nachfolger den Bestand umbenennt | slice-225 |
| `lab/regelwerk/grundlagen-traceability.md` | 130-131 | übernommen | Herkunfts-Anker-Notation `seit welle-<Kennung>`/`seit slice-<Kennung>` trug in [`observations/README.md`](../observations/README.md) und [`.claude/commands/close-welle.md`](../../../../.claude/commands/close-welle.md) noch die alte Form — in diesem Lauf behoben (`git grep -nE 'slice-<NNN>\|welle-<NN>' -- docs/plan/planning .claude/commands ':!docs/plan/planning/done'` zeigt beide Dateien danach nicht mehr). **Ergänzt (Review slice-224 MEDIUM-2):** der Posten trägt daneben **62** Plus-Zeilen (`git diff v6.0.0..v6.7.2 -- lab/regelwerk/grundlagen-traceability.md \| grep -cE '^\+'`), mehrheitlich die neue Sektion §Die zweite Richtung: Anforderung → Beleg (RTM — derselbe Gegenstand wie der Glossar-Eintrag `RTM` in `grundlagen-begriffe.md`, Zeile oben). Ihre Setzungspflicht bindet nur ein Repo, das von der **Default-Antwort** — der Slice entlastet eine Anforderung — abweicht, etwa mit einer kuratierten Nachweis-Datei; dieses Repo tut das nicht: Anforderungen schließen über Slice-DoDs, eine zweite RTM-Ablage existiert nicht (`ls docs/plan/planning/reconciliation.md` als Vergleichsfall: Datei fehlt, kein Analogon vorhanden). Keine Deklaration nötig, kein eigener `MR`-Eintrag | slice-224 |
| `lab/regelwerk/modul-02-harness-bootstrap.md` | 130-131 | schon erfüllt | reine Anker-Umbenennung eines Querverweises, keine Inhaltsänderung | slice-224 |
| `lab/regelwerk/modul-04-adrs.md` | 125-128 | schon erfüllt | ausschließlich Tabellen-Reformatierung | slice-224 |
| `lab/regelwerk/modul-05-planning-harness.md` | 130-131 | schon erfüllt | §1 „Ziel und Abgrenzung" (vier Ausschluss-Klassen) und §8 „Sub-Area-Prüfungen und Modus-Begründung" sind in **diesem eigenen Slice-Plan** bereits verkörpert (§1/§8 dieser Datei); die Archiv-Notation `slice-<Kennung>-archiv.zip` trifft auf keinen Bestand (kein archivierter Slice, `ls docs/plan/planning/done/*/archiv.zip 2>/dev/null \| wc -l` → **0**) | slice-224 |
| `lab/regelwerk/modul-06-roadmap.md` | 133 | übernommen | dieselbe Herkunfts-Anker-Notation wie `grundlagen-traceability.md`; mit derselben Behebung gedeckt (`observations/README.md`, `close-welle.md`) | slice-224 |
| `lab/regelwerk/modul-07-carveouts.md` | 130-131 | schon erfüllt | neue Regel „Auflösung setzt die Bindung-Spalte in `harness/README.md` §Sensors zurück" betrifft aktuell keinen Carveout — kein `CO-<NNN>` in der Sensors-Tabelle (`grep -n 'CO-[0-9]' harness/README.md` → leer) | slice-224 |
| `lab/regelwerk/modul-08-agentenrollen.md` | 130-131 | schon erfüllt | **korrigiert (Review slice-224 MEDIUM-1):** keine Tabellen-Reformatierung — zwei Tabellenzellen tragen die Kennungs-Notation (`welle-<NN>-results.md`→`welle-<Kennung>-results.md`, `seit slice-<NNN>`/`seit welle-<NN>`→`seit slice-<Kennung>`/`seit welle-<Kennung>`) als Beispieltext über den wellenlosen Betrieb. Kein eigener Bestand trägt diese Beispielform separat: Dieselbe Notations-Regel ist über die Zeilen zu `grundlagen-traceability.md`/`modul-06-roadmap.md` oben bereits repo-weit behoben — `git grep -nE 'slice-<NNN>\|welle-<NN>' -- docs/plan/planning .claude/commands ':!docs/plan/planning/done'` zeigt außer `implement-slice.md` nichts mehr. **schon erfüllt** bleibt richtig, weil dieselbe Regel schon an anderer Stelle vollzogen ist — nicht, weil sich nichts geändert hätte | slice-224 |
| `lab/regelwerk/modul-09-implementierung.md` | 132 | übernommen (Übergabe) | Plan-vor-Code-Disziplin (Tests-Zeile bindet an Akzeptanzkriterien-ID, Out-of-Scope-Nennung in Schritt 4, Zeiger auf den Gate-Index statt Listen-Wiederholung) betrifft ausschließlich `.claude/commands/implement-slice.md` — Rollen-Anweisungssatz der Implementer-Rolle ([ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)), von diesem Slice laut §1 nicht beschreibbar | Implementer (Übergabe) |
| `lab/regelwerk/modul-10-review-harness.md` | 130-131 | schon erfüllt | Notation + eine Klarstellung zur Deckungs-Prüfung des d-check-Moduls `reviews`; das Modul selbst ist Gegenstand der `.d-check.yml`-Zeile unten, keine zusätzliche Pflicht hier | slice-224 |
| `lab/regelwerk/modul-11-verification.md` | 125-128 | schon erfüllt | ausschließlich Tabellen-Reformatierung | slice-224 |
| `lab/regelwerk/modul-12-replay-evaluierung.md` | 125-128 | schon erfüllt | ausschließlich Tabellen-Reformatierung | slice-224 |
| `lab/regelwerk/modul-13-quality-gates.md` | 130-131 | übernommen | „Gate-Index steht einmal"-Konzept (Deklarations-Sensor, `kein Gate`-Markierung in der Zeile selbst, Grenzen-Pflicht je Gate) — deckungsgleich mit dem Titel von [slice-225](../open/slice-225-gate-index-steht-einmal.md) | slice-225 |
| `lab/regelwerk/modul-14-docker-harness.md` | 125-128 | schon erfüllt | ausschließlich Tabellen-Reformatierung | slice-224 |
| `lab/regelwerk/modul-15-observability.md` | 129 | schon erfüllt | Wortlaut-Präzisierung eines illustrativen „Doku-Konsistenz-Agent"-Konzepts, keine neue Pflicht | slice-224 |
| `lab/regelwerk/modul-16-produktiver-betrieb.md` | 130-131 | schon erfüllt | **korrigiert (Review slice-224 MEDIUM-1):** keine Tabellen-Reformatierung — eine **Listenzeile** trägt die Kennungs-Notation (`done/welle-NN-closure.md`→`done/welle-<Kennung>-closure.md`). Das Pfadmuster `…-closure.md` hat in unserem Bestand kein Gegenstück: Wir führen `welle-<id>-results.md`, keine `-closure.md`-Datei (`grep -rn 'welle-.*-closure' --include='*.md' docs/plan/planning` → leer). **schon erfüllt** bleibt richtig, aus dem richtigen Grund: kein Bestand, den die Notation träfe | slice-224 |
| `lab/templates/.d-check.yml` | 129 | übernommen | Doku-Kommentare zu den Modulen `targets` (bei uns bereits aktiv, `grep -n '^modules:' .d-check.yml`) und `reviews` (bei uns noch **nicht** aktiviert); Aktivierungsentscheidung liegt in `.d-check.yml`, Architect-Eigentum | slice-225 |
| `lab/templates/AGENTS.template.md` | 130-131 | übernommen | dieselbe „Gate-Index steht einmal"-Konsequenz für `AGENTS.md` §4 (Liste → Zeiger auf `harness/README.md` §Sensors) | slice-225 |
| `lab/templates/Makefile` | 129 | schon erfüllt | Kommentar-Vorlage für ein bootstrap-Repo; unser Root-`Makefile` ist keine Kopie dieser Vorlage (`grep -n 'Targets in AGENTS.md' Makefile` → leer) — kein eigener Bestand betroffen | slice-224 |
| `lab/templates/README.md` | 124 | schon erfüllt | Index-Zeile für `.harness/baseline/v6.7.2/templates/harness/sensors/gate.template.md` plus zwei Hinweiszeilen zu §1/§8 des Slice-Plans — Kurs-Dokumentation für Adopter, kein eigenes Artefakt dieses Repos | slice-224 |
| `lab/templates/docs/plan/carveouts/README.template.md` | 130-131 | schon erfüllt | Notation; unser [`docs/plan/carveouts/README.md`](../../carveouts/README.md) trägt keine Platzhalter-Form (`grep -n 'slice-<' docs/plan/carveouts/README.md` → leer) | slice-224 |
| `lab/templates/docs/plan/carveouts/carveout.template.md` | 130-131 | schon erfüllt | Notation; unsere zwei aktiven Carveouts tragen bereits konkrete Slice-Namen statt Platzhalter (`grep -n 'Folge-Slice' docs/plan/carveouts/CO-*.md`) | slice-224 |
| `lab/templates/docs/plan/planning/README.template.md` | 130-131 | schon erfüllt | zwei Stellen `welle-<NN>-results.md` → `welle-<Kennung>-results.md`; unser [`docs/plan/planning/README.md`](../README.md) nutzt an beiden Stellen bereits das generische `<welle-id>-results.md` (kein Platzhalter mit `NN`) | slice-224 |
| `lab/templates/docs/plan/planning/archiv-stub-slice.template.md` | 130-131 | schon erfüllt | Notation + neuer „Zitier-Form"-Normblock; kein archivierter Slice-Stub im Bestand (`ls docs/plan/planning/done/*/ 2>/dev/null` → keiner) | slice-224 |
| `lab/templates/docs/plan/planning/archiv-stub-welle.template.md` | 130-131 | schon erfüllt | dieselbe Begründung wie beim Slice-Stub-Template | slice-224 |
| `lab/templates/docs/plan/planning/observation.template.md` | 130-131 | übernommen | zwei Stellen der Notation trugen in [`observations/README.md`](../observations/README.md) noch die alte Form (`slice-<NNN>.md`, `seit welle-<NN>`/`seit slice-<NNN>`) — in diesem Lauf behoben | slice-224 |
| `lab/templates/docs/plan/planning/reconciliation.template.md` | 130-131 | schon erfüllt | Greenfield-Repo, Datei existiert nicht (`ls docs/plan/planning/reconciliation.md` → Fehler); kein Bestand betroffen | slice-224 |
| `lab/templates/docs/plan/planning/roadmap.template.md` | 130-131 | schon erfüllt | Platzhalter `welle-N+1`/`welle-NN` → konkrete Namen; unsere [`in-progress/roadmap.md`](../in-progress/roadmap.md) führt durchweg konkrete Welle-/Slice-Namen, keine Platzhalter-Reste (`git grep -nE 'slice-<NNN>\|welle-<NN>' -- docs/plan/planning/in-progress/roadmap.md` → leer) | slice-224 |
| `lab/templates/docs/plan/planning/slice.template.md` | 132 | schon erfüllt | §1 „Ziel und Abgrenzung" / §8 „Sub-Area-Prüfungen und Modus-Begründung" bereits in diesem eigenen Slice-Plan verkörpert (referenziert, nicht kopiert — [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)) | slice-224 |
| `lab/templates/docs/plan/planning/welle-results.template.md` | 130-131 | schon erfüllt | „Zitier-Form"-Normblock + Notation; kein offenes `welle-*-results.md` im Bestand (alle drei offenen Wellen — `welle-09`, `welle-11`, `welle-13` — sind ungeschlossen, `ls docs/plan/planning/welle-*.md`) | slice-224 |
| `lab/templates/docs/plan/planning/welle.template.md` | 130-131 | übernommen | `welle-<NN>-results.md` trug in [`welle-13-regeln-bekommen-ihren-sensor.md`](../welle-13-regeln-bekommen-ihren-sensor.md) noch die alte Form — in diesem Lauf behoben | slice-224 |
| `lab/templates/docs/reviews/review-report.template.md` | 130-131 | übernommen | Zitier-Form-Norm + Notation der Kopfzeile; Formänderung des Review-Report-Bestands ist ausdrücklich Gegenstand von [slice-213](../open/slice-213-review-report-laeuft-in-der-tabellen-form.md)/[slice-214](../open/slice-214-zellengrenze-wird-gemessen-statt-gesetzt.md) | slice-213/slice-214 |
| `lab/templates/harness/README.template.md` | 134 | übernommen | „Gate-Index steht einmal"-Konsequenz; unser `harness/README.md` trägt bereits den Abschnitt „Werkzeuge (kein Gate)" und `harness/sensors/<target>.md`-Links, aber `AGENTS.md` §4 dupliziert die Gate-Liste noch statt nur auf `harness/README.md` §Sensors zu zeigen | slice-225 |
| `lab/templates/harness/conventions.template.md` | 130-131 | übernommen | Notation in der ID-Schema-Zeile der Adaptions-Vorlage (`slice-<NNN>` → `slice-<Kennung>`); `harness/conventions.md` ist Architect-Eigentum | slice-225 |
| `lab/templates/harness/sensors/gate.template.md` | 120 | schon erfüllt | Muster bereits vollständig im Bestand umgesetzt (`ls harness/sensors/*.md \| wc -l` → **15** Dateien, je mit Index-Zeile in `harness/README.md`) | slice-224 |
