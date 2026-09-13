# Slice slice-225: Der Gate-Index steht einmal, die Norm-Ebene zieht nach, und was der neue Stand auflöst, verlässt den Adaptions-Block

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — aus demselben Grund und mit derselben Prüfung wie
[slice-223](../done/slice-223-baum-tausch-v672-pins-ziehen.md) und
[slice-224](../done/slice-224-delta-nachweis-und-planungs-nachzug.md). Nach
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
**kein neuer `MR`-Eintrag, der eine Abweichung bucht** — ein solcher Eintrag setzt eine *gewollte*
Abweichung voraus ([`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)), und
die gibt es nicht. **Ein Eintrag, den die Ziel-Fassung selbst verlangt, ist davon nicht
betroffen** — §1 trennt die zwei Gegenstände. Die Gegenrichtung bleibt Liefer-Punkt 3. **Färbt ein Posten beim Übernehmen ein Gate rot, ist das
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
  [slice-224](../done/slice-224-delta-nachweis-und-planungs-nachzug.md) führt den Nachweis über
  alle 42 Posten und die Planungs-Ebene; dieser Slice vollzieht die Teilmenge, die dort benannt
  ist. *Folge-Slice übernimmt es* — und slice-224 nimmt die Sendung an, weil sein Liefer-Punkt 3
  genau diese Zuweisung verlangt.
- **Kein neuer `MR`-Eintrag, der eine Abweichung bucht.** Die Vorgabe des Auftraggebers schließt
  gewollte Abweichungen aus (Kopf), und ein Abweichungs-Eintrag ohne Abweichung wäre Buchführung
  über nichts ([`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)). *Bestand
  bleibt bewusst stehen* — die 52 aktiven Einträge werden um keinen solchen vermehrt.

  **Ein Deklarations-Eintrag ist ein anderer Gegenstand und fällt nicht unter diesen Ausschluss.**
  Der Adaptions-Block trägt neben den Abweichungen die Setzungen, die die Baseline dem Repo
  ausdrücklich zuweist; `grundlagen-source-precedence.md` §Vergabe verlangt seit der regierenden
  Fassung genau eine davon — *„Welche Form gilt, deklariert das Repo — in
  `harness/conventions.md`"* —, nachdem derselbe Abschnitt den Satz gestrichen hat, der bis
  `v6.0.0` dichte Nummern für Ein-Schreiber-Repos lizenzierte
  (`grep -c 'dichte Nummern' .harness/baseline/v6.7.2/regelwerk/grundlagen-source-precedence.md`
  → **0**, kein Erwartungswert). Die Kennungs-Form ist damit deklarationspflichtig statt
  voreingestellt, und die geltende Deklaration steht heute im **permanenten**
  [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (`ID-Schema: … slice-NNN`),
  an dem nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 und
  [`MR-032`](../../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  inhaltlich nichts geändert wird. Die Form ist deshalb vorgezeichnet und nicht zu erfinden: **ein
  neuer Eintrag trägt die Setzung, der bestehende bekommt eine Kopf-Marke auf ihn.** Der Inhalt der
  Setzung ist die Entscheidung des Auftraggebers, die
  [slice-224](../done/slice-224-delta-nachweis-und-planungs-nachzug.md) §9 in der Zeile zu
  `lab/regelwerk/grundlagen-source-precedence.md` festhält — Namen für neue Welle- und
  Slice-Kennungen, **kein Nachrüsten des Bestands**; bestehende `slice-<NNN>`/`welle-<NN>` behalten
  ihre Nummer. **Die Cutoff-Setzung beginnt mit diesem Eintrag:** Kennungen, die vor ihm vergeben
  werden, folgen der heute deklarierten Form, und daraus entsteht kein Nachrüstungs-Auftrag. Dieser
  Punkt schließt den Eintrag nicht aus, er ordnet ihn ein; geliefert wird er über Liefer-Punkt 2,
  der jede Zeile des Nachweises mit Ziel `slice-225` bindet.
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

- [x] **1 — Der Gate-Index steht einmal, und die Messung liegt daneben.**
      `targets.authority` in [`.d-check.yml`](../../../../.d-check.yml) nennt
      `harness/README.md`, die Gate-Tabelle in [`AGENTS.md`](../../../../AGENTS.md) §4 ist durch
      Regel und Zeiger ersetzt, und ``grep -cE '^\| `make ' AGENTS.md`` liefert **0**. `make gates`
      ist grün — insbesondere meldet das `targets`-Modul weder `gate-undocumented` noch
      `gate-phantom`. Die Senkungs-Frage ist **beantwortet, nicht erwogen**: Die Mengen-Differenz
      aus §1 ist im Lauf neu gefahren, ihr Ergebnis steht in der Closure-Notiz, und ist sie
      **nicht** leer, ist das der Befund und geht als Meldung an den Auftraggeber (Kopf) — nicht
      in einen Eintrag.

      **Ausgang bei Closure:** erfüllt, und die Senkungs-Frage ist **anders** beantwortet worden,
      als der Punkt sie stellte. Die drei Messungen sind am Abschluss neu gefahren:

      ```sh
      grep -n 'authority:' .d-check.yml                 # authority: harness/README.md
      grep -cE '^\| `make ' AGENTS.md                   # 0 — keine Gate-Tabelle mehr in AGENTS.md
      comm -23 <(git show 99bfd1c5^:AGENTS.md | grep -oE '^\| `make [a-z0-9-]+`' | sed 's/^| `make //;s/`$//' | sort -u) \
               <(grep -oE '`make [a-z0-9-]+`' harness/README.md | sed 's/`make //;s/`$//' | sort -u) | wc -l   # 0
      ```

      Die Mengen-Differenz ist leer. Eine
      Senkung gibt es trotzdem — in der Richtung, die diese Messung nicht erfasst; sie ist über
      [`ADR-0045`](../../adr/0045-authority-wechsel-senkt-eine-richtung.md) (`Accepted`) gebucht
      und über den §Sensors-Scope von `authority_table_targets()` kompensiert. Das ist der Weg aus
      [`AGENTS.md`](../../../../AGENTS.md) §3.5 und schärfer als die Meldung, die der Plan-Kopf als
      Alternative vorsah.
- [x] **2 — Die Norm-Ebene trägt die übrigen Posten, die
      [slice-224](../done/slice-224-delta-nachweis-und-planungs-nachzug.md) §9 ihr zuweist.**
      Der Umfang steht dort, nicht hier — dieser Punkt ist erfüllt, wenn **jede** Zeile des
      Nachweises mit Ziel `slice-225` einen Beleg im Diff hat. Nach heutigem Stand fallen darunter
      mindestens: der Rollenwechsel-Satz zu Schritt 8 in [`AGENTS.md`](../../../../AGENTS.md) §6
      und in [`harness/README.md`](../../../../harness/README.md) §Minimal agent workflow, die
      Zeile auf `.harness/skills/reviewer.md` in §Guides, und die Kennungs-Notation an den **2**
      Stellen in [`AGENTS.md`](../../../../AGENTS.md) (`git grep -cE 'slice-<NNN>|welle-<NN>' -- AGENTS.md`).
      **Und die Deklaration der Kennungs-Form**, die §1 als eigenen Gegenstand einordnet: ein neuer
      Eintrag unter [`harness/conventions/`](../../../../harness/conventions/) trägt die
      Cutoff-Setzung, [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)
      bekommt eine Kopf-Marke auf ihn, und die Index-Zeile in
      [`harness/conventions.md`](../../../../harness/conventions.md) reist mit. Ohne sie bleibt die
      Zeile des Nachweises zu `lab/regelwerk/grundlagen-source-precedence.md` ohne Beleg im Diff,
      und dieser Punkt ist nicht erfüllt.
      **Die Liste in diesem Plan ist nicht die Grenze** — die Grenze ist §9 von slice-224; steht
      dort ein Posten, den dieser Plan nicht kennt, gehört er trotzdem hierher, und wächst die
      Menge über *einen* Review-Sitzung hinaus, greift die Rückführung in §4.

      **Ausgang bei Closure:** erfüllt, und **zwei** der sieben Zeilen bekommen ihn hier statt im
      Diff. Die Zeilen sind ausgezählt, nicht geschätzt:

      ```sh
      awk -F'|' '{n=NF; gsub(/^[ \t]+|[ \t]+$/,"",$n); if ($n=="slice-225") print NR}' \
        docs/plan/planning/done/slice-224-delta-nachweis-und-planungs-nachzug.md   # 7 Zeilen
      ```

      Fünf sind im Diff belegt (`grundlagen-harness-dateien.md`, `grundlagen-source-precedence.md`,
      `AGENTS.template.md`, `lab/templates/harness/README.template.md`, `lab/templates/harness/conventions.template.md`). Die
      zwei übrigen:

      - `lab/regelwerk/modul-13-quality-gates.md` — **erfüllt, Beleg hier nachgetragen.** Der
        Posten trägt drei Teile, und alle drei stehen:

        ```sh
        grep -c 'targets' <(grep '^modules:' .d-check.yml)                  # 1  Deklarations-Sensor aktiv
        grep -cE '^\|.*\| *kein Gate' harness/README.md                     # 17 Zeilen mit der Markierung
        ls harness/sensors/*.md | wc -l                                     # 15 Sensor-Dateien
        grep -lE '^#+ .*Grenze' harness/sensors/*.md | wc -l                # 15 davon mit Grenzen-Abschnitt
        ```

        **Keine Erwartungswerte.** Teil 1 ist der `authority`-Wechsel dieses Slice; Teil 2 und 3
        standen vorher schon (`git show 99bfd1c5^:harness/README.md | grep -cE '^\|.*\| *kein Gate'`
        → 17). Der Posten verlangt keine Arbeit, die nicht getan ist — er verlangte den Beleg, und
        der fehlte.
      - `lab/templates/.d-check.yml` — **eingetreten → Folge-Slice mit Kennung**
        [slice-emittierte-gate-vorlage-traegt-targets-und-reviews](../open/slice-emittierte-gate-vorlage-traegt-targets-und-reviews.md).
        Die Zeile hat zwei Hälften: die emittierte Vorlage (von §1 dieses Plans ausgeschlossen) und
        die Aktivierungsfrage des Moduls `reviews` in der `.d-check.yml` dieses Repos (bei
        [slice-213](../open/slice-213-review-report-laeuft-in-der-tabellen-form.md)). Für die erste
        nahm keine der vier in §1 genannten Adressen die Sendung an; der neue Slice nennt sie in
        seinem §1 als Gegenstand. Keine Ablehnung — die Lücke ist gemessen
        (`grep -cE '^# (targets|reviews):' .harness/baseline/v6.7.2/templates/.d-check.yml` → 2
        gegen `internal/emit/templates/d-check.yml` → 0).
- [x] **3 — Was der Stand `v6.7.2` auflöst, hat den Adaptions-Block verlassen.** Jeder aktive
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

      **Ausgang bei Closure: keiner feuert, und die Kandidatenzahl ist am Abschluss genommen** —
      **24 von 55**, nicht die 21 des Plans. Der Slice erzeugt mit [`MR-057`](../../../../harness/conventions.md#mr-057) und [`MR-058`](../../../../harness/conventions.md#mr-058) zwei
      seiner eigenen Kandidaten und bewegt damit seine Bezugsmenge; genau dafür verlangt
      [`MR-058`](../../../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)
      Setzung 2 die Messung **nach** dem Vorgang:

      ```sh
      ls harness/conventions/MR-*.md | wc -l              # 55 aktive Eintraege
      for f in harness/conventions/MR-*.md; do
        awk '/^- \*\*Auflösungs-Trigger:\*\*/{p=1} p{print} p&&/^- \*\*(Datum|Wirksamkeits-Anlass|Geltungsbereich|Ersetzt)/&&!/Auflösungs/{exit}' "$f" \
          | grep -qiE 'baseline|regelwerk|kurs-|upstream|adoptiert|Ziel-Fassung' && basename "$f"
      done | wc -l                                        # 24 Kandidaten
      git diff --name-status 99bfd1c5^..HEAD -- harness/conventions/ | grep -c '^R'   # 0 Umzuege nach done/
      ```

      **Keine Erwartungswerte.** Unabhängig nachgeprüft sind **11** der 24 — 2 Grenzfälle im
      Review, 9 in der benannten Stichprobe des Verifiers; für die übrigen 13 trägt die Messung des
      umsetzenden Laufs. Eine Vollständigkeitsaussage einer prüfenden Rolle über alle 24 steht
      damit **nicht** da, und das gehört benannt statt vorausgesetzt.
- [x] `make gates` grün — EXIT 0 über `05672bfc` laut Auftrag, nicht in diesem Lauf gemessen; nach
      den Closure-Commits fährt ihn der Orchestrator erneut.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8). **Drei Reports, zwei
      Rollen, kein Self-Review:** Runde 1 (blockierend), die Verifikation, und Runde 2 derselben
      Reviewer-Rolle — *nicht mehr blockierend*.
- [x] Doku-Update: [`harness/README.md`](../../../../harness/README.md) §Sensors ist die alleinige
      Gate-Index-Autorität, [`AGENTS.md`](../../../../AGENTS.md) §4 trägt Regel und Zeiger dorthin
      — ein öffentlicher Vertrag im Sinne des Minimal Agent Workflow, und beide Dateien sind
      Gegenstand von Liefer-Punkt 1 und 2.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht (`ls docs/plan/planning/reconciliation.md`).
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo fährt Wellen (`ls docs/plan/planning/welle-*.md`), sie werden deshalb von der nächsten Welle-Closure geprüft, auch für diesen Slice ohne Wellen-Zugehörigkeit.

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
[slice-224](../done/slice-224-delta-nachweis-und-planungs-nachzug.md) liegt in `done/` — ablesbar
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
  — **Ausgang: entfallen.** Kein Gate ist rot geworden, und zwischen Planung und Lauf kam kein
  Rezept hinzu: Die Mengen-Differenz ist am Abschluss neu gefahren und leer (DoD-Punkt 1). Das
  Risiko in der Form, in der es hier steht, kann nicht mehr eintreten — der Wechsel ist vollzogen.
  **Was stattdessen eintrat, gehört in dieselbe Zeile, weil es sonst als „nichts passiert" gelesen
  wird:** Eine Senkung gibt es, und sie war für beide hier genannten Wächter unsichtbar — für das
  rote Gate wie für die Mengen-Differenz. Gefunden hat sie der Review mit einer Sonde, entschieden
  ist sie in [`ADR-0045`](../../adr/0045-authority-wechsel-senkt-eine-richtung.md). Die **Klasse**
  dahinter ist gebucht: `BEO-ALL/senkungs-pruefung-misst-die-menge-statt-des-gate-verhaltens`.
- **Die Ausnahmeliste wird nach dem Wechsel nur auf Form geprüft.** 17 der 37 `exempt-targets`
  stehen künftig als Zeile im Index und brauchen die Ausnahme nicht mehr; sie stehen zu lassen ist
  still grün und macht die Liste zu einer, die nichts mehr sagt. Register-Stand der Klasse
  `ausnahmeliste-nur-auf-form-geprueft`: **2×**
  (`ls docs/plan/planning/observations/BEO-ALL/ausnahmeliste-nur-auf-form-geprueft/evidence/*.md | wc -l`).
  — **Ausgang: weiter offen → Beobachtungs-Register.** Es ist eingetreten und in **einer**
  Richtung kompensiert: 17 der 37 Einträge stehen seit dem Wechsel als Zeile im Index **und** in
  der Ausnahmeliste, und ein bats-Wächter hält seitdem, dass kein Eintrag zugleich eine
  Sensors-Tabellenzeile ist ([`ADR-0045`](../../adr/0045-authority-wechsel-senkt-eine-richtung.md)
  Festlegung 2). Was der Wächter **nicht** prüft, ist die inhaltliche Berechtigung eines Eintrags —
  genau die Klasse. Sie wandert darum an den Zähler statt in einen zweiten Mechanismus:
  `BEO-ALL/ausnahmeliste-nur-auf-form-geprueft`, mit diesem Beleg bei **3×**.
- **Der `git mv` eines Adaptions-Eintrags macht eine bewachte Adresse falsch.** Wandert ein
  Eintrag nach `conventions/done/`, ändern sich seine eigenen relativen Pfade **und** jede Adresse,
  die auf ihn zeigt; die Anker-Mitnahme in der Index-Tabelle ist der Grund, warum die Kennungs-Links
  nicht brechen, aber `../`-Tiefen im Rumpf brechen sehr wohl. Register-Stand der Klasse
  `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`: **13×**
  (`ls docs/plan/planning/observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/evidence/*.md | wc -l`)
  — mit Abstand der größte Zähler des Registers. — **Ausgang: entfallen.** Kein Eintrag ist
  gefeuert, also hat kein `git mv` in
  [`harness/conventions/`](../../../../harness/conventions/) stattgefunden
  (`git diff --name-status 99bfd1c5^..HEAD -- harness/conventions/ | grep -c '^R'` → **0**); die
  Bedingung des Risikos ist nicht eingetreten und kann es in diesem Slice nicht mehr. **Der
  Registereintrag bleibt davon unberührt und hat trotzdem einen Beleg aus diesem Vorgang** — aus
  einer anderen Fundstelle: Der Closure-Move von `slice-224` hatte eine Stand-Zelle in
  [`harness/conventions.md`](../../../../harness/conventions.md) §Baseline falsch stehen lassen
  (Review MEDIUM-3). Zwei verschiedene Aussagen, und beide sind wahr.
- **Der zweite mögliche Rot-Fall liegt bei einem Modul, das dieser Slice nicht aktiviert.** Eine
  Aktivierung von `reviews` über `done/`-Slices mit Review-DoD-Zeile ohne Report unter
  `docs/reviews/` wäre rot; §1 schließt sie mit Adresse aus, und sie ist hier als **benannte
  Möglichkeit** notiert, damit der Lauf sie nicht als Versäumnis liest. — **Ausgang: entfallen.**
  Das Modul ist nicht aktiviert; die `modules:`-Liste der
  [`.d-check.yml`](../../../../.d-check.yml) führt es weder vor noch nach diesem Slice
  (`grep '^modules:' .d-check.yml`), und der Diff berührt die Zeile nicht. Ohne Aktivierung gibt es
  den Rot-Fall nicht.
- **Der Umfang von Liefer-Punkt 2 steht in einem anderen Plan.** Er ist damit erst bei Start des
  Slice bekannt; die Rückführung in §4 ist die vorab benannte Antwort, und Register-Stand der
  Klasse `slice-plan-umfang-waechst-ueber-umsetzung-hinaus`: **2×**
  (`ls docs/plan/planning/observations/BEO-ALL/slice-plan-umfang-waechst-ueber-umsetzung-hinaus/evidence/*.md | wc -l`).
  — **Ausgang: eingetreten → Folge-Slice mit Kennung**
  [slice-emittierte-gate-vorlage-traegt-targets-und-reviews](../open/slice-emittierte-gate-vorlage-traegt-targets-und-reviews.md).
  Zwei der sieben Zeilen standen bei der Verifikation ohne Beleg da (DoD-Punkt 2), und eine davon
  hatte **keinen** Empfänger: §9 adressierte sie an diesen Slice, dessen §1 sie ausschloss und vier
  Adressen nannte, von denen keine sie annahm. Die Rückführung aus §4 war **nicht** der richtige
  Zug — der Umfang wuchs nicht über eine Review-Sitzung hinaus, er hatte eine Lücke. Nicht der
  Zuschnitt war falsch, sondern die Annahmebereitschaft einer Adresse; gebucht als
  `BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt`.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

**Rolle:** Planner · **Datum:** 2026-09-13.

- **Was hat funktioniert:** Die **Sonde statt der Zahl**. Der Gate-Index-Wechsel ist der einzige
  Posten dieses Slice, dessen Wirkung keine Textmessung zeigt, und er ist der einzige, bei dem eine
  prüfende Rolle den konstruierten Zustand über **beiden** Ständen gefahren hat — Nicht-Gate-Rezept
  mit bloßer Werkzeuge-Zeile, über dem alten Baum zurückgewiesen, über dem neuen durchgelassen. Das
  hat aus einer Formulierungsfrage eine Entscheidung gemacht
  ([`ADR-0045`](../../adr/0045-authority-wechsel-senkt-eine-richtung.md)) und eine Kompensation,
  die man rot sehen kann. Getragen hat ebenso der **Rollen-Wechsel vor dem Norm-Text**
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8): Die drei Architect-Commits berühren ausschließlich
  Architect-Artefakte, und dass der Implementer-Lauf [`MR-057`](../../../../harness/conventions.md#mr-057) nicht selbst schrieb, ist der Grund,
  warum die Zahl darin überhaupt einer zweiten Rolle auffiel. Und die **vorab benannten Risiken**
  in §6 haben getragen: Von fünf sind vier in einer Form entschieden worden, die der Plan
  beschrieben hatte.
- **Was ging anders als geplant:** Vier Dinge.
  1. **Der Plan hielt die Senkungs-Frage für beantwortet, und sie war es nicht.** §1 setzt die
     leere Mengen-Differenz als Beleg *„kein §3.5-Fall, sondern der Steering-Loop-Weg
     Gate-Anheben"*; die Messung ist richtig und spricht über Namenslisten, die Folgerung über
     Annahme-Verhalten. Zwei Läufe haben sie nacheinander nachgefahren, weil sie reproduzierbar und
     grün war. Das ist der Lerneintrag unten.
  2. **Die Kandidatenzahl des Retirements hatte drei Werte, und alle drei waren richtig.** 21 im
     Plan, 23 im Review, 24 beim Verifier — der Slice erzeugt mit [`MR-057`](../../../../harness/conventions.md#mr-057)/[`MR-058`](../../../../harness/conventions.md#mr-058) zwei seiner
     eigenen Kandidaten. Der Widerspruch war keiner, sondern eine Messung, die ihr eigener Vorgang
     bewegt; die Form dafür steht seitdem als
     [`MR-058`](../../../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)
     Setzung 2 da, und die Zahl in DoD-Punkt 3 ist danach genommen.
  3. **Der Plan-Kopf sah für einen gemessenen Gate-Befund nur einen Weg vor** — *„eine Meldung an
     den Auftraggeber, nicht in einen Eintrag und nicht in eine Ausnahme"*. Gegangen wurde der
     zweite, den [`AGENTS.md`](../../../../AGENTS.md) §3.5 kennt: eine ADR. Das ist keine Abweichung
     vom Plan, sondern die schärfere seiner zwei zulässigen Antworten — der Befund ist gebucht
     **und** kompensiert statt nur gemeldet.
  4. **Eine Nachweis-Zeile hatte zwei Absender-Aussagen und keinen Empfänger.** `slice-224` §9
     schickte `lab/templates/.d-check.yml` hierher, §1 dieses Plans schloss die emittierte Ebene
     aus und nannte vier Adressen, von denen keine sie annahm. Aufgefallen ist das der Verifikation,
     nicht dem Schnitt; die Adresse steht jetzt.
- **Steering-Loop-Eintrag — geschärfte Regel, gezählt und nicht verkörpert:** *Die Frage „ist das
  eine Senkung?" ist eine Frage über **Verhalten**, nicht über **Mengen**. Eine Differenz über den
  Inhalts-Listen zweier Konfigurations-Stände — welche Namen vorher und nachher dokumentiert sind —
  kann leer sein, während das Gate einen Zustand durchlässt, den es vorher zurückwies. Wer sie
  beantworten will, baut die **Sonde**: derselbe konstruierte Zustand über beiden Ständen, einmal
  rot und einmal grün gesehen. Eine zweite Mengen-Messung liefert denselben leeren Rest.* Auslöser:
  `BEO-ALL/senkungs-pruefung-misst-die-menge-statt-des-gate-verhaltens` (neu, 1×). **Die Teil-Zeile
  `— liegt in …` entfällt**, weil mit diesem Slice keine Regel dieser Klasse verkörpert wurde: Der
  Eintrag steht bei 1×, und den Ausgang weist der Lese-Schritt der nächsten Welle-Closure zu. Was
  entschieden ist, ist der **Einzelfall** — und das trägt bereits eine ID
  ([`ADR-0045`](../../adr/0045-authority-wechsel-senkt-eine-richtung.md)), braucht also nach
  Baseline-Regelwerk `grundlagen-traceability.md` §Herkunfts-Anker keinen zweiten.
- **Beobachtungs-Register (`../observations/`):** **Sechs** Belege geschrieben, **ein** Verzeichnis
  neu angelegt (`senkungs-pruefung-misst-die-menge-statt-des-gate-verhaltens`); der Zähler folgt den
  Dateien und wird nirgends gesetzt (keine Erwartungswerte):

  ```sh
  for s in senkungs-pruefung-misst-die-menge-statt-des-gate-verhaltens \
           mess-zusage-trifft-das-eigene-zitat \
           uebergabe-an-andere-rolle-ohne-traeger-artefakt \
           ausnahmeliste-nur-auf-form-geprueft \
           lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch \
           verweis-nachzug-ersetzt-eine-historisch-richtige-adresse; do
    printf '%s %s\n' "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)" "$s"
  done   # 1 · 4 · 4 · 3 · 14 · 3
  ```

  **Eine neue Klasse, und die Prüfung davor ist protokolliert:** Fünf vorhandene Einträge sind als
  Kandidat gelesen und keiner deckt den Fall.
  `vollstaendigkeits-zusage-misst-falsche-ebene` trifft die **Granularität** derselben Messung
  (Datei statt Hunk) — hier ist die Granularität richtig und der **Gegenstand** falsch;
  `byte-gleichheit-als-aussage-ueber-die-regel-gelesen` setzt eine Messung voraus, die etwas
  **übersieht** — diese übersieht nichts und beantwortet vollständig eine andere Frage;
  `zusage-nennt-sensor-der-form-nicht-sieht` bindet Skript- und Funktionsköpfe, nicht eine
  Plan-Begründung; `zusicherung-ueber-der-leeren-menge-wahr` setzt eine Negation über einer
  weggefallenen Menge voraus — die Menge hier ist da und wird richtig gezählt;
  `zusammenfassung-staerker-als-ihre-quelle` setzt eine Quelle voraus, die weniger sagt — hier sagt
  die Quelle genau so viel, nur über etwas anderes. Eine Klasse in einen unpassenden Namen zu
  drücken teilt sie still.
  **Kein Eintrag hat in dieser Closure einen Ausgang bekommen:** Vier der sechs stehen über der
  Schwelle, und der Lese-Schritt gehört in einem Repo mit Wellen-Betrieb der Welle-Closure
  (`ls docs/plan/planning/welle-*.md` → drei offene Wellen).
- **Folge-Slices:**
  [slice-werkzeug-erkennt-die-benannte-kennung](../open/slice-werkzeug-erkennt-die-benannte-kennung.md)
  (Verweis-Nachzug und Archiv-Stub erkennen eine benannte Slice-Kennung) und
  [slice-emittierte-gate-vorlage-traegt-targets-und-reviews](../open/slice-emittierte-gate-vorlage-traegt-targets-und-reviews.md)
  (Die emittierte Doc-Gate-Vorlage nennt die zwei Module, die sie heute verschweigt) — beide Dateien
  in `open/`, beide neu geschnitten. **Es sind die ersten zwei Kennungen dieses Repos ohne Nummer**
  ([`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
  Setzung 1 bindet ab `3c2b4d82`; `slice-226`/`slice-227` fielen einen Tag davor und behalten ihre
  Nummer nach Setzung 2). Der erste nimmt damit die Sendung an, die seine eigene Kennung fällig
  gemacht hat.
- **Risiken aus §6:** fünf, jedes mit genau einem Ausgang — dreimal *entfallen* mit Begründung
  (kein rotes Gate aus einem neuen Rezept · kein `git mv` in `harness/conventions/`, weil kein
  Trigger feuerte · das Modul `reviews` ist nicht aktiviert), einmal *weiter offen →
  Beobachtungs-Register* (`ausnahmeliste-nur-auf-form-geprueft`, **3×**), einmal *eingetreten →
  Folge-Slice mit Kennung* (`slice-emittierte-gate-vorlage-traegt-targets-und-reviews`).
- **Vor dem `git mv` gemessen** ([`AGENTS.md`](../../../../AGENTS.md) §3.11, und
  [`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 5 verlangt,
  dass der bewegende Lauf nennt, was er anfasst):

  Der Stand vor dem Move steht als Commit-Operand in beiden Kommandos, nicht als Pfad-Literal:
  Über dem Arbeitsbaum liefern sie nach dem Move nichts mehr — die Adressen sind nachgezogen —,
  und eine Zahl, die ihr eigener Vorgang bewegt, wird nach ihm genommen oder an einem festen
  Stand ([`MR-058`](../../../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)
  Setzung 2). Reproduzierbar auf jedem Checkout:

  ```sh
  M=380820b5   # der Closure-Commit, letzter Stand vor dem git mv
  git grep -cE 'in-progress/slice-225-gate-index-steht-einmal\.md' $M -- 'docs/plan/adr/*.md'
  # keine Zeile, Exit 1 — keine ADR nennt die Datei als Pfad

  git grep -cE 'in-progress/slice-225-gate-index-steht-einmal\.md' $M -- \
    'docs/plan/planning/done/*.md' 'docs/reviews/*.md' 'docs/plan/carveouts/done/*.md' \
    'docs/plan/planning/observations/**/evidence/*.md' | wc -l                        # 9 Dateien
  # dieselbe Zeile, statt `wc -l`:  | awk -F: '{s+=$NF} END{print s}'                 # 23 Fundstellen
  ```

  **Keine `Accepted`-ADR** nennt diese Datei als Pfad — der Move ist nicht gesperrt. Angefasst
  werden **9** eingefrorene Dateien mit **23** Fundstellen in den vier Bäumen, die
  [`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 1 bindet;
  dort ist der Nachzug beschlossen, weil er die Adresse ersetzt und die Aussage stehen lässt. **Eine
  Fundstelle ist die Ausnahme davon** und bleibt nach Festlegung 4 unrepariert:
  `observations/BEO-ALL/mess-zusage-trifft-das-eigene-zitat/evidence/slice-224.md` zitiert eine
  `git grep -c`-Ausgabe unter einem Pathspec, der `done/` ausnimmt — nach der Ersetzung behauptet
  sie einen Treffer, den dasselbe Kommando nie liefert. Gebucht als
  `BEO-ALL/verweis-nachzug-ersetzt-eine-historisch-richtige-adresse` (**3×**).
- **Drei Paarungen:** Repo **mit** Wellen-Betrieb — geprüft von der nächsten Welle-Closure, auch
  für diesen Slice ohne Wellen-Zugehörigkeit. Die **Anker**-Paarung hat hier kein Objekt: Der
  Steering-Loop-Eintrag oben trägt kein Feld `liegt in`, ist also gezählt und nicht verkörpert. Die
  **Folge-Slice**- und die **Register**-Paarung haben je zwei bzw. sechs Objekte, und alle liegen
  vor — die zwei genannten Slices sind Dateien im Planning-Lifecycle, jede genannte Beobachtung ist
  ein Verzeichnis mit nicht leerem `evidence/`.

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
