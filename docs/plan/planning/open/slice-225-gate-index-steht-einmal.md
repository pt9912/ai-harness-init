# Slice slice-225: Der Gate-Index steht einmal, die Norm-Ebene zieht nach, und was der neue Stand auflöst, verlässt den Adaptions-Block

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — aus demselben Grund und mit derselben Prüfung wie
[slice-223](../done/slice-223-baum-tausch-v672-pins-ziehen.md) und
[slice-224](../next/slice-224-delta-nachweis-und-planungs-nachzug.md). Nach
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
steht wellenlose Arbeit nicht in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: Dogfood, nicht emittiert.** Gegenstand sind die Norm-Artefakte und die
Gate-Konfiguration **dieses** Repos. Was ein emittiertes Repo an Modul-Zusammensetzung und
Vorlagen bekommt, entscheiden
[`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
und [`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed),
nicht diese Datei.

**Rollen-Zuschnitt: dieser Slice läuft im Architect-Kontext.** Alle vier berührten Artefakte —
[`AGENTS.md`](../../../../AGENTS.md), [`harness/conventions.md`](../../../../harness/conventions.md),
[`harness/conventions/`](../../../../harness/conventions/) und der ADR-Index — gehören nach
[`AGENTS.md`](../../../../AGENTS.md) §3.8 und
[`ADR-0024`](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) dem
**Architect**; [`harness/README.md`](../../../../harness/README.md) und
[`.d-check.yml`](../../../../.d-check.yml) reisen mit, weil die Gate-Index-Entscheidung sie in
einem Zug bewegt. Der Commit-Zuschnitt aus §3.8 gilt: Architect-Artefakte in einem Commit, der die
Rolle in seiner Message nennt.

**Vorgabe des Auftraggebers, empfangen am 2026-09-12:** *auf das neueste Regelwerk umstellen*, und
zur Entscheidungsfrage: *„Nein, der Architekt wird das nicht entscheiden — wir geben es vor."*
**Der Architect schreibt den Norm-Text; er wägt nicht mehr ab.** Für diesen Slice folgt daraus:
**kein neuer `MR`-Eintrag** — ein Eintrag bucht eine *gewollte* Abweichung
([`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)), und die gibt es nicht.
Die Gegenrichtung bleibt Liefer-Punkt 3. **Färbt ein Posten beim Übernehmen ein Gate rot, ist das
eine Messung und geht als Meldung zurück an den Auftraggeber**, nicht in einen Eintrag und nicht in
eine Ausnahme; §6 nennt, wo dieser Plan so einen Fall für möglich hält.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (der
Gate-Index ist die Deklarations-Seite dieser Anforderung; `gate-phantom` und `gate-undocumented`
sind ihre zwei maschinellen Richtungen),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (jede Messung unten läuft
gegen den in [`d-check.mk`](../../../../d-check.mk) gepinnten Digest, netzlos),
[`ADR-0044`](../../adr/0044-ziel-fassung-regiert-den-sprung-v672.md) (die regierende Fassung des
Sprungs; ihre Folgepflicht *„Architect, fällig im Durchgang, nicht hier"* benennt genau die
`targets.authority`-Frage),
[`ADR-0024`](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) (der
ADR-Index gehört der Rolle, die seine Originale schreibt),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(*„Gate-Anheben → Steering-Loop"* — der Weg, den eine Verschärfung nimmt;
[`AGENTS.md`](../../../../AGENTS.md) §3.5 bindet Senkungen, und §2 misst, welche von beidem hier
vorliegt),
[`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf),
[`MR-032`](../../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger),
[`MR-038`](../../../../harness/conventions.md#mr-038--ein-retirierender-eintrag-nennt-den-baseline-stand-der-seinen-trigger-feuerte),
[`MR-039`](../../../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines),
[`MR-046`](../../../../harness/conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht)
(die Form der Retirement-Runde in Liefer-Punkt 3),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben ihrem Kommando),
[`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(jede Aussage über die Baseline nennt ihren Mess-Tag).

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle; Gegenstand sind Norm-Artefakte
und eine Gate-Konfiguration).

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

**Ziel:** Der Gate-Index dieses Repos steht an **einer** Stelle —
[`harness/README.md`](../../../../harness/README.md) §Sensors —, die Norm-Artefakte
[`AGENTS.md`](../../../../AGENTS.md) und [`harness/README.md`](../../../../harness/README.md)
tragen die übrigen Norm-Posten des Deltas, und jeder Adaptions-Eintrag, dessen Auflösungs-Trigger
der Stand `v6.7.2` feuert, liegt in [`harness/conventions/done/`](../../../../harness/conventions/done/).

### Die Gate-Index-Frage ist eine Messung, keine Abwägung

Die Ziel-Fassung streicht die Gate-Tabelle in `AGENTS.md` §4 ersatzlos und setzt an ihre Stelle
Regel und Zeiger; der Index steht dann nur noch in `harness/README.md` §Sensors. Unsere
[`.d-check.yml`](../../../../.d-check.yml) setzt heute `authority: AGENTS.md`, und das Modul nimmt
**genau eine** Datei. Zieht man die Tabelle, ohne `authority` mitzuziehen, fällt jedes nicht
ausgenommene Rezept als `gate-undocumented`.

Die vier Zahlen, die den Vollzug tragen, sind über dem Arbeitsbaum gefahren, der diesen Plan
enthält — **keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2):

```sh
grep -cE '^\| `make ' AGENTS.md                                            # 11  Gate-Zeilen heute in der authority-Datei
grep -cE '^\| \[?`make ' harness/README.md                                 # 28  Gate-/Werkzeug-Zeilen im Einstiegspunkt
sed -n '/^targets:/,/^ignore-refs:/p' .d-check.yml | grep -c '^    - '     # 37  exempt-targets
grep -hoE '^[a-zA-Z0-9_.-]+:.*##' Makefile d-check.mk | cut -d: -f1 | sort -u | wc -l   # 48 Rezepte mit Hilfetext
```

**11 + 37 = 48** — dieselbe Zahl, die die vierte Zeile liefert. Jedes Rezept ist heute entweder
Index-Zeile in der `authority`-Datei oder Ausnahme; das ist die Deckung, die `make gates` grün
hält, und sie ist die Ausgangslage, gegen die der Wechsel zu messen ist. **Die Gleichheit ist
gemessen, nicht hergeleitet:** die vierte Zeile zählt `##`-Hilfetexte, das Modul zählt Regeln mit
Rezept — beide Mengen fallen heute zusammen, und ob sie es im Lauf noch tun, sagt der Lauf.

**Ob der Wechsel eine Senkung nach [`AGENTS.md`](../../../../AGENTS.md) §3.5 ist, entscheidet die
Mengen-Differenz, nicht die Zeilenzahl** — und sie ist gemessen:

```sh
comm -23 <(grep -oE '^\| `make [a-z0-9-]+`'   AGENTS.md        | sed 's/^| `make //;s/`$//' | sort -u) \
         <(grep -oE '^\| \[?`make [a-z0-9-]+`' harness/README.md | sed 's/^| \[\?`make //;s/`$//' | sort -u)
# leer — kein Target steht in AGENTS.md, das harness/README.md nicht führt
```

Der Index in `harness/README.md` ist ein **echtes Obermenge** der elf: Nichts, was heute
dokumentiert ist, wird durch den Wechsel undokumentiert, und die neue Autorität trägt 17 Zeilen
mehr, die in beide Richtungen zu belegen sind (`gate-phantom` prüft jede behauptete Zeile gegen ein
reales Rezept). **Die Prüfung wird damit strenger, nicht schwächer** — kein §3.5-Fall, sondern der
Steering-Loop-Weg *„Gate-Anheben"* aus
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids).
Die Messung ist im Lauf zu wiederholen und gehört als Beleg in die Closure-Notiz; dieser Plan
nimmt sie als **Ausgangslage**, nicht als Ergebnis.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Delta-Posten, der außerhalb von [`AGENTS.md`](../../../../AGENTS.md),
  [`harness/README.md`](../../../../harness/README.md), [`.d-check.yml`](../../../../.d-check.yml)
  und [`harness/conventions/`](../../../../harness/conventions/) landet.**
  [slice-224](../next/slice-224-delta-nachweis-und-planungs-nachzug.md) führt den Nachweis über
  alle 42 Posten und die Planungs-Ebene; dieser Slice vollzieht die Teilmenge, die dort benannt
  ist. *Folge-Slice übernimmt es* — und slice-224 nimmt die Sendung an, weil sein Liefer-Punkt 3
  genau diese Zuweisung verlangt.
- **Kein neuer `MR`-Eintrag.** Die Vorgabe des Auftraggebers schließt gewollte Abweichungen aus
  (Kopf), und ein Eintrag ohne Abweichung wäre Buchführung über nichts
  ([`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)). *Bestand bleibt
  bewusst stehen* — die 52 aktiven Einträge werden geprüft, nicht vermehrt.
- **Keine inhaltliche Änderung an einem angenommenen `MR`-Eintrag und an keiner
  `Accepted`-ADR.** [`AGENTS.md`](../../../../AGENTS.md) §3.4,
  [`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
  und [`MR-032`](../../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  sperren sie. Gemessen trifft das die alte Kennungs-Notation an **9** Stellen — **5** in
  angenommenen Einträgen
  ([`MR-028`](../../../../harness/conventions.md#mr-028--der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt),
  [`MR-031`](../../../../harness/conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline))
  und **4** in ADRs
  ([`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md),
  [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md),
  [`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md)):

  ```sh
  git grep -cE 'slice-<NNN>|welle-<NN>' -- harness/conventions docs/plan/adr
  ```

  Der alte Wortlaut bleibt dort stehen; **das ist Historie, keine Abweichung, und es entsteht
  dafür kein Eintrag.** Eine Einschränkung, die der Plan benennt statt sie zu verschweigen:
  [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) steht auf
  `Proposed`, nicht auf `Accepted` — §3.4 friert sie also noch nicht; sie bleibt trotzdem draußen,
  weil eine ADR-Änderung ein eigener Architect-Vorgang mit eigenem Anlass ist und kein Nachzug.
  *Bestand bleibt bewusst stehen.*
- **Keine Aktivierung eines Doc-Gate-Moduls über die `targets`-Achse hinaus.** Das Delta bringt
  einen `reviews:`-Block in die `.d-check.yml`-**Vorlage** mit; ob dieses Repo das Modul
  einschaltet, ist eine Gate-Aktivierung mit eigener Erprobung und eigenem rotem Gegenbeispiel und
  liegt bei [slice-213](../open/slice-213-review-report-laeuft-in-der-tabellen-form.md) (Form und
  `structure`) sowie bei den Modul-Slices
  [slice-210](../open/slice-210-planning-modul-im-emittierten-doc-gate.md),
  [slice-211](../open/slice-211-codepaths-im-emittierten-doc-gate.md) und
  [slice-212](../open/slice-212-modul-aktivierung-hat-keinen-adaptions-eintrag.md). *Es wäre ein
  anderer Vorgang.*
- **Kein Produkt-Code und keine emittierte Vorlage.** Dieser Slice ändert Norm-Text und eine
  Gate-Konfiguration; alles unter `internal/` und `cmd/` bleibt unberührt. *Schicht-Abgrenzung* —
  beim Review sofort prüfbar.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

Drei slice-eigene Punkte. Gezählt ist nur, was mit dem Umfang wächst.

- [ ] **1 — Der Gate-Index steht einmal, und die Messung liegt daneben.**
      `targets.authority` in [`.d-check.yml`](../../../../.d-check.yml) nennt
      `harness/README.md`, die Gate-Tabelle in [`AGENTS.md`](../../../../AGENTS.md) §4 ist durch
      Regel und Zeiger ersetzt, und `grep -cE '^\| `make ' AGENTS.md` liefert **0**. `make gates`
      ist grün — insbesondere meldet das `targets`-Modul weder `gate-undocumented` noch
      `gate-phantom`. Die Senkungs-Frage ist **beantwortet, nicht erwogen**: Die Mengen-Differenz
      aus §1 ist im Lauf neu gefahren, ihr Ergebnis steht in der Closure-Notiz, und ist sie
      **nicht** leer, ist das der Befund und geht als Meldung an den Auftraggeber (Kopf) — nicht
      in einen Eintrag.
- [ ] **2 — Die Norm-Ebene trägt die übrigen Posten, die
      [slice-224](../next/slice-224-delta-nachweis-und-planungs-nachzug.md) §9 ihr zuweist.**
      Der Umfang steht dort, nicht hier — dieser Punkt ist erfüllt, wenn **jede** Zeile des
      Nachweises mit Ziel `slice-225` einen Beleg im Diff hat. Nach heutigem Stand fallen darunter
      mindestens: der Rollenwechsel-Satz zu Schritt 8 in [`AGENTS.md`](../../../../AGENTS.md) §6
      und in [`harness/README.md`](../../../../harness/README.md) §Minimal agent workflow, die
      Zeile auf `.harness/skills/reviewer.md` in §Guides, und die Kennungs-Notation an den **2**
      Stellen in [`AGENTS.md`](../../../../AGENTS.md) (`git grep -cE 'slice-<NNN>|welle-<NN>' -- AGENTS.md`).
      **Die Liste in diesem Plan ist nicht die Grenze** — die Grenze ist §9 von slice-224; steht
      dort ein Posten, den dieser Plan nicht kennt, gehört er trotzdem hierher, und wächst die
      Menge über *einen* Review-Sitzung hinaus, greift die Rückführung in §4.
- [ ] **3 — Was der Stand `v6.7.2` auflöst, hat den Adaptions-Block verlassen.** Jeder aktive
      Eintrag, dessen Auflösungs-Trigger einen Baseline-/Regelwerks-Stand nennt, ist gegen
      `v6.7.2` geprüft; die **Kandidatenmenge ist 21 von 52** — gemessen, nicht geschätzt:

      ```sh
      ls harness/conventions/MR-*.md | wc -l              # 52 aktive Eintraege
      for f in harness/conventions/MR-*.md; do
        awk '/^- \*\*Auflösungs-Trigger:\*\*/{p=1} p{print} p&&/^- \*\*(Datum|Wirksamkeits-Anlass|Geltungsbereich|Ersetzt)/&&!/Auflösungs/{exit}' "$f" \
          | grep -qiE 'baseline|regelwerk|kurs-|upstream|adoptiert|Ziel-Fassung' && basename "$f"
      done | wc -l                                        # 21 Kandidaten
      ```

      **21 ist die Menge, die zu lesen ist, nicht die Menge, die feuert** — welcher Trigger
      wirklich eingetreten ist, ist ein Urteil je Eintrag. Jeder feuernde Eintrag liegt per
      `git mv` in [`harness/conventions/done/`](../../../../harness/conventions/done/), behält
      Kopf und Zeiger statt Rumpf
      ([`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)),
      nennt den Baseline-Stand, der seinen Trigger feuerte
      ([`MR-038`](../../../../harness/conventions.md#mr-038--ein-retirierender-eintrag-nennt-den-baseline-stand-der-seinen-trigger-feuerte)),
      und seine Zeile wandert samt beider Anker in die Tabelle *Aufgelöste Adaptionen*. **Feuert
      keiner, ist das ebenfalls ein Ergebnis** und wird mit der geprüften Kandidatenzahl notiert.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: [`harness/README.md`](../../../../harness/README.md) §Sensors ist die alleinige
      Gate-Index-Autorität, [`AGENTS.md`](../../../../AGENTS.md) §4 trägt Regel und Zeiger dorthin
      — ein öffentlicher Vertrag im Sinne des Minimal Agent Workflow, und beide Dateien sind
      Gegenstand von Liefer-Punkt 1 und 2.
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
| [`.d-check.yml`](../../../../.d-check.yml) (`targets.authority`, `targets.doc-tables`) | update | der Index steht einmal; `authority` nimmt genau eine Datei |
| [`AGENTS.md`](../../../../AGENTS.md) §4 | update | die Gate-Tabelle weicht Regel und Zeiger auf `harness/README.md` §Sensors |
| [`AGENTS.md`](../../../../AGENTS.md) §6, §3.7 | update | Rollenwechsel-Satz zu Schritt 8; Kennungs-Notation an 2 Stellen |
| [`harness/README.md`](../../../../harness/README.md) §Guides, §Sensors, §Minimal agent workflow | update | Zeile auf `.harness/skills/reviewer.md`; alleinige Index-Autorität; Rollenwechsel-Satz |
| [`harness/conventions/`](../../../../harness/conventions/) → `done/` | `git mv` | Retirement-Runde über 21 Kandidaten (§2 Punkt 3) |
| [`harness/conventions.md`](../../../../harness/conventions.md) Index-Tabellen | update | derivativ: jede gewanderte Zeile verlässt *Aktive* und erscheint in *Aufgelöste Adaptionen*, beide Anker ziehen mit |

**Was hier bewusst fehlt:** eine Zeile für `internal/` und für die `.d-check.yml`-**Vorlage**.
Beide liegen auf der emittierten Ebene und sind in §1 mit Adresse ausgeschlossen.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`):
[slice-224](../next/slice-224-delta-nachweis-und-planungs-nachzug.md) liegt in `done/` — ablesbar
an `ls docs/plan/planning/done/slice-224-*.md` auf dem Hauptzweig. Beobachtbar ohne Rückfrage, und
**kein Ergebnis dieses Slice**: Der Nachweis steht in keiner DoD-Zeile von §2. Der Trigger ist
inhaltlich nötig, nicht nur sequenziell — Liefer-Punkt 2 nimmt seinen Umfang aus §9 jenes Slice.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): §9 von slice-224 weist der Norm-Ebene
  mehr zu, als in *einer* Review-Sitzung prüfbar ist — die konkrete Schwelle: wenn der
  Gate-Index-Vollzug (Liefer-Punkt 1) und die Retirement-Runde (Liefer-Punkt 3) nicht mehr in
  denselben Diff passen, weil mehr als eine Handvoll Einträge feuert. Dann wird die
  Retirement-Runde ein eigener Slice, und dieser behält Index und Norm-Text.
- `in-progress` → `open` (blockiert — Carveout?): Der `authority`-Wechsel färbt `make gates` rot,
  und die rote Stelle liegt außerhalb dieses Slice — etwa ein Rezept, das weder im neuen Index
  noch in `exempt-targets` steht und dessen Einordnung eine eigene Entscheidung braucht. Dann geht
  die **Messung** zurück an den Auftraggeber (Kopf); ein Referenz-Ventil oder eine erweiterte
  Ausnahmeliste ist kein Ausweg, sondern eine Senkung nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5 mit eigener ADR.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: (1) `grep -cE '^\| `make ' AGENTS.md` liefert **0**, `make gates` ist
grün, und die Mengen-Differenz aus §1 ist im Lauf neu gefahren und leer. (2) Der Review-Report zu
diesem Slice liegt unter `docs/reviews/` und trägt keinen blockierenden Befund. Dazu der
Lerneintrag in §7 und für jedes Risiko aus §6 ein Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der `authority`-Wechsel färbt `make gates` rot.** Die Mengen-Differenz aus §1 ist heute leer;
  sie ist am **heutigen** Bestand gemessen, und zwischen dieser Planung und dem Lauf können
  Rezepte hinzukommen. Das ist der erste der zwei Orte, an denen dieser Plan ein rotes Gate für
  möglich hält — **die Antwort ist eine Meldung an den Auftraggeber, keine Ausnahme** (Kopf, §4).
  — **Ausgang:** offen bis zur Closure.
- **Die Ausnahmeliste wird nach dem Wechsel nur auf Form geprüft.** 17 der 37 `exempt-targets`
  stehen künftig als Zeile im Index und brauchen die Ausnahme nicht mehr; sie stehen zu lassen ist
  still grün und macht die Liste zu einer, die nichts mehr sagt. Register-Stand der Klasse
  `ausnahmeliste-nur-auf-form-geprueft`: **2×**
  (`ls docs/plan/planning/observations/BEO-ALL/ausnahmeliste-nur-auf-form-geprueft/evidence/*.md | wc -l`).
  — **Ausgang:** offen bis zur Closure.
- **Der `git mv` eines Adaptions-Eintrags macht eine bewachte Adresse falsch.** Wandert ein
  Eintrag nach `conventions/done/`, ändern sich seine eigenen relativen Pfade **und** jede Adresse,
  die auf ihn zeigt; die Anker-Mitnahme in der Index-Tabelle ist der Grund, warum die Kennungs-Links
  nicht brechen, aber `../`-Tiefen im Rumpf brechen sehr wohl. Register-Stand der Klasse
  `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`: **13×**
  (`ls docs/plan/planning/observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/evidence/*.md | wc -l`)
  — mit Abstand der größte Zähler des Registers. — **Ausgang:** offen bis zur Closure.
- **Der zweite mögliche Rot-Fall liegt bei einem Modul, das dieser Slice nicht aktiviert.** Eine
  Aktivierung von `reviews` über `done/`-Slices mit Review-DoD-Zeile ohne Report unter
  `docs/reviews/` wäre rot; §1 schließt sie mit Adresse aus, und sie ist hier als **benannte
  Möglichkeit** notiert, damit der Lauf sie nicht als Versäumnis liest. — **Ausgang:** offen bis
  zur Closure.
- **Der Umfang von Liefer-Punkt 2 steht in einem anderen Plan.** Er ist damit erst bei Start des
  Slice bekannt; die Rückführung in §4 ist die vorab benannte Antwort, und Register-Stand der
  Klasse `slice-plan-umfang-waechst-ueber-umsetzung-hinaus`: **2×**
  (`ls docs/plan/planning/observations/BEO-ALL/slice-plan-umfang-waechst-ueber-umsetzung-hinaus/evidence/*.md | wc -l`).
  — **Ausgang:** offen bis zur Closure.

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
- **Folge-Slices:** <…>
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
§Modus-Deklaration pro Sub-Area. Die Schwelle ≥ 2 von 3 Achsen ist erfüllt: eigene Regeln (Hard
Rules und Adaptions-Block), eigener Prüfbereich (`targets`-Modul des Doku-Gates über `Makefile`,
`d-check.mk`, `AGENTS.md`, `harness/README.md`) und eigene Fehlermodi (`gate-phantom`,
`gate-undocumented`). **`TOOLS` ist geprüft und nicht berührt:** Der Index nennt Targets, deren
Rezepte auf `harness/tools/*.sh` zeigen, aber keine Aussage **über** `harness/tools/` ändert sich
— Pfad-Berührung ist nicht hinreichend. **`CODEX` ebenso wenig.**

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist am gemergten Stand durchgegangen
— **98** Verzeichnisse (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, **kein
Erwartungswert**); alle führen dieselbe Sub-Area `*`, die Sichtung ist damit vollständig. **Fünf
Treffer** berühren diesen Slice:

| Beobachtung (`BEO-ALL/<slug>`) | Zähler | Stand |
|---|---|---|
| `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch` | 13× | offen |
| `gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse` | 3× | offen |
| `ausnahmeliste-nur-auf-form-geprueft` | 2× | offen |
| `slice-plan-umfang-waechst-ueber-umsetzung-hinaus` | 2× | offen |
| `schwellen-uebertritt-ohne-zustaendige-rolle` | 2× | offen |

```sh
for s in lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch \
         gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse \
         ausnahmeliste-nur-auf-form-geprueft slice-plan-umfang-waechst-ueber-umsetzung-hinaus \
         schwellen-uebertritt-ohne-zustaendige-rolle; do
  printf '%s %s\n' "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)" "$s"
done
```

**Zwei stehen über der Schwelle** — `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch` (13×)
und `gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse` (3×), beide **vor** diesem Slice und
nicht durch ihn. Der Lese-Schritt, der ihnen ihren Ausgang zuweist, gehört in eine Closure und
nicht in diese Planung; hier zählen sie als Evidenz-Risiko (unten) und als Risiko (§6). Der
zweite trifft die Rückführung in §4 unmittelbar: Ein Referenz-Ventil, das ein rotes Gate
beruhigt, statt die Adresse nachzuziehen, ist genau diese Klasse — deshalb steht er dort als
ausdrücklich **kein** Ausweg.

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas sind Greenfield; der Block trägt
eine Sub-Area.

### Sub-Area: `*` (gesamtes Repo, Kürzel `ALL`)

- **Modus:** GF
- **Konventionen-Dichte:** sehr hoch — der Gegenstand **ist** der Konventionsspeicher: 52 aktive
  Einträge (`ls harness/conventions/MR-*.md | wc -l`) plus 4 aufgelöste
  (`ls harness/conventions/done/MR-*.md | wc -l`), dazu die Hard Rules in
  [`AGENTS.md`](../../../../AGENTS.md) §3 und die Gate-Konfiguration selbst. Die Form der
  Retirement-Runde ist in vier Einträgen geregelt
  ([`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf),
  [`MR-032`](../../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger),
  [`MR-038`](../../../../harness/conventions.md#mr-038--ein-retirierender-eintrag-nennt-den-baseline-stand-der-seinen-trigger-feuerte),
  [`MR-046`](../../../../harness/conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht)).
- **Phase-Reife:** Phase 5 für die Index-Achse — das `targets`-Modul läuft in `make gates`, prüft
  beide Richtungen und hat einen dokumentierten Vertrag in
  [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md). Phase 3 für die
  Adaptions-Achse: Die Form steht vollständig, der Trigger-Eintritt ist ein Urteil und hat keinen
  Sensor.
- **Evidenz-/Diskrepanz-Risiko:** hoch, und die Belegquelle ist das Register oben. Die tragende
  Diskrepanz ist **Deklaration gegen Bestand**: Der Index behauptet 28 Zeilen, die
  Ausnahmeliste 37, das Makefile 48 Rezepte — nach dem Wechsel muss diese Rechnung neu aufgehen,
  und `ausnahmeliste-nur-auf-form-geprueft` (2×) sagt, wie sie still falsch bleibt.
  `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch` (13×) trifft Liefer-Punkt 3 direkt:
  Jeder `git mv` eines Eintrags bewegt Adressen, die anderswo bewacht sind.
- **Reconciliation-Aufwand:** keiner — GF, kein Inventur-Fund im Sinne des
  Reconciliation-Registers (die Datei existiert in diesem Repo nicht; das DoD-Item entfällt).
  Graduation entfällt (n/a bei GF). Der Trigger, der die Adaptions-Achse auf Phase 5 höbe, wäre ein
  Sensor, der einen Auflösungs-Trigger gegen den adoptierten Stand hält; er existiert nicht, und
  [`MR-038`](../../../../harness/conventions.md#mr-038--ein-retirierender-eintrag-nennt-den-baseline-stand-der-seinen-trigger-feuerte)
  ist die Deklarations-Hälfte davon.
