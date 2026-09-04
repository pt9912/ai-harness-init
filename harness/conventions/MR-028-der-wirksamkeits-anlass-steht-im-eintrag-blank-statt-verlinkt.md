# MR-028 — Der Wirksamkeits-Anlass steht im Eintrag, blank statt verlinkt

> **ÜBERHOLT: die Einordnung „Zusatz zur Vorlagen-Form, keine Abweichung von einer Baseline-Regel" → [`MR-043`](../conventions.md#mr-043--ein-nachgetragenes-pflichtfeld-schlägt-die-einordnung-im-rumpf).** Das Feld `Wirksamkeits-Anlass` und seine Blank-Form binden unverändert fort.

- **Datum:** 2026-08-28
- **Geltungsbereich:** die **Form** eines Eintrags dieses Blocks. **Nicht** `docs/plan/adr/`,
  **nicht** `docs/plan/planning/**` — dort entscheidet, wer sie führt.
- **Ersetzt-Baseline-Regel:**
  [`grundlagen-traceability.md`](../../.harness/baseline/v6.0.0/regelwerk/grundlagen-traceability.md#herkunfts-anker)
  §Herkunfts-Anker — der Satz, der die Herkunft in diesem Block verortet: *„Der Adaptions-Block
  trägt das Muster bereits über sein Feld Begründung."* An seine Stelle tritt das eigene Feld
  `Wirksamkeits-Anlass`, und dazu die Form: derselbe Abschnitt schreibt *„ein Feld, kein Konstrukt"*
  mit auflösenden Ankern (`seit welle-<NN>`, `seit slice-<NNN>`, die über
  `done/slice-<NNN>-*.md` §7 auflösen), hier steht die Slice-Nummer **blank**. Der Adaptions-Absatz
  unten begründet den Zusatz gegen die Pflichtfeld-Liste der Vorlage von `v3.5.2` und liest ihn
  darum als *„keine Abweichung von einer Baseline-Regel"*; gegen den adoptierten Stand `v5.12.0`
  gemessen ist er eine, und zwar an dieser einen Stelle. Die **Begründung** der Blank-Form —
  Adressen verfallen, und die Link-Pflicht bestrafte genau die Aussage, deren Nicht-Auflösen ein
  Beleg ist — bleibt davon unberührt.
- **Adaption — Zusatz zur Vorlagen-Form, keine Abweichung von einer Baseline-Regel.** Die
  vendored Vorlage (`.harness/baseline/v3.5.2/templates/harness/conventions.template.md`,
  Kommentar über dem Adaptions-Block) nennt sechs Pflichtfelder — ID · Datum · Geltungsbereich ·
  Adaption · Begründung · Auflösungs-Trigger — und verbietet daneben nichts. Ein Eintrag nennt
  zusätzlich seinen **Wirksamkeits-Anlass**: die Arbeitseinheit, durch die die Abweichung in Kraft
  trat. `Datum` beantwortet *wann*, der Anlass *wodurch* — ein Register, das seine Abweichungen
  ohne ihn führt, behauptet sie. Denselben Rang haben zwei verwandte Nennungen: der
  **Beleg-Anlass** (unter welchem Lauf eine hier stehende Messung entstand) und die **Umdeutung
  einer Adresse in einem immutablen Artefakt**, für die es keinen zweiten Ort gibt
  ([`AGENTS.md`](../../AGENTS.md) §3.4; §Modus-Deklaration trägt den Fall).
- **Form: blank, nicht als Link — Setzung, nicht Lücke.** `ids.patterns` in `.d-check.yml` führt
  drei Muster (`grep -c 'regex:' .d-check.yml` → **3**), und keines trifft eine Slice-Nummer
  (`grep -A1 'regex:' .d-check.yml | grep -c 'slice'` → **0**). Eine Slice-Nummer ist eine
  **Adresse**, und Adressen verfallen: dieselbe Grenze ziehen
  [`ADR-0014`](../../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) und
  [`ADR-0016`](../../docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md) als *Eigenschaft statt
  Adresse*. Unter Link-Pflicht ginge
  [`MR-016`](../conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) rot, dessen Satz
  über das Nachschneiden zwei Nummern nennt, deren **Nicht**-Auflösen sein Beleg ist — die
  Link-Pflicht bestrafte dort genau die Aussage. Eine Nummer aus einem fremden Projekt trägt
  dessen Namen als Präfix: blanke Nummern haben keinen Namensraum, und dieser Block nennt eine
  fremde Nummer, die auch als eigene existiert.
- **Grenze: Anlass ist Herkunft, nicht Prozess-Zustand.** Eine Nennung, die auf **ungeschnittene**
  Arbeit zeigt, nennt keinen Anlass, sondern eine Erwartung; ihr Ort ist der Plan, der sie führt.
  Gemessen:
  `grep -oE 'slice-[0-9]{2,}(/[0-9]{2,})*' harness/conventions.md | tr '/' '\n' | sed 's/^\([0-9]\)/slice-\1/' | sort -u | while read n; do ls docs/plan/planning/*/$n-*.md >/dev/null 2>&1 || echo "$n"; done`
  → **vier** Ausgaben, davon **eine** eine ungeschnittene Einheit. Die drei übrigen sind keine
  Verweise: zwei sind der Beleg aus
  [`MR-016`](../conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird), einer ein Glob in
  einem Kommando. Welche der vier was ist, trennt das Kommando nicht — das ist ein **Urteil, kein
  Muster** ([`AGENTS.md`](../../AGENTS.md) §3.6), und die Nummer steht deshalb hier nicht noch einmal.
  Der eine Fall liegt in
  [`MR-005`](../conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption) und wird dort **nicht
  angefasst**: der Eintrag ist akzeptiert, und die Nennung heilt oder verfällt mit der
  Entscheidung über den Schnitt.
- **Was hier nicht entschieden wird.** Die Punkte 5 und 6 der Liste *„Was ersatzlos entfällt"* in
  [`MR-021`](../conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  binden nach dessen Pflichtfeld `Geltungsbereich`
  [`MR-018`](../conventions.md#mr-018--span-schema-der-telemetrie-erfassung) und zwei Abschnitte des
  Technik-Stratums. Sie sind das Streich-Protokoll **eines** Rumpfs — die vier Posten davor nennen
  einzelne Sätze jenes Eintrags —, kein blockweites Verbot; blockweit lesbar sind allein ihre
  allgemein formulierten Begründungen. Dieser Eintrag nimmt jenen deshalb nicht zurück und
  bessert ihn nicht nach: die append-only-Disziplin der Vorlage steht, und
  [`MR-020`](../conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) hebt sie nur für den
  Rumpf eines **vollständig aufgehobenen** Eintrags auf. Er stellt die Form daneben, gegen die zu
  lesen ist.
- **Kein Wächter, und die Lücke ist die Regel selbst.** Kein Modul aus `modules:` der
  `.d-check.yml` sieht eine blanke Slice-Nummer — `links` prüft Links, `ids` die drei Muster oben.
  Ein Wächter wäre nur um den Preis der Link-Pflicht zu haben, und die ist oben verworfen. Träger
  ist der Rollen-Wechsel vor der Änderung.
- **Auflösungs-Trigger:** permanent für die Form. Die Grenze fällt neu an, sobald `ids.patterns`
  ein Slice-Muster führt — dann ist zuerst zu entscheiden, was mit den Nummern geschieht, deren
  Nicht-Auflösen heute ein Beleg ist.
