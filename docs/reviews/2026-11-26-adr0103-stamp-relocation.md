# Review-Report: adr0103-stamp-relocation — 2026-11-26

**Review-Art:** Code — *wogegen* geprüft wird: Code + Konfiguration gegen
`ADR-0103` (als Plan-Ersatz — dieser Zug trägt keinen Slice-Plan), die aktiven
berührten ADRs (`ADR-0035`, `ADR-0083`, `ADR-0102` als Supersedes-Gegenstand)
und `AGENTS.md` §3 (Hard Rules), namentlich §3.3 (Move/Inhalt getrennt),
§3.4 (Supersedes statt Überschreiben), §3.6 (rot gesehen), §3.7 (Kommentar),
§3.5 je [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
und [`MR-029`](../../harness/conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage).

**Gegenstand:** Range `f4a94a75..5de9ee9f`, ADR-0103-Teilzug —
`075b84a4` (ADR-0103, supersedes ADR-0102) · `45d91550` (`mutate.md` §CI-Branch) ·
`57ddbfc0` (`.d-check.yml` scan.ignore + Tombstones) · `c030e4c8`
(Supersedes-Lineage) · `09756281` (Hash-Ausnahme + Wächter + Fälle 791/792) ·
`ef54b273` (Records-`git mv`) · `83d58d29` (Kopf-Züge) · `5de9ee9f`
(Fall-792-Anker-Form). Der übrige Teil der Range (Wellen c5–c7,
`slice-mutations-beleg-eingecheckt`) trägt eigene Reports und wurde hier nur als
Umgebung gelesen.

**Skill:** `.harness/skills/reviewer.md` @ 2.3.0 ·
**Modell:** glm-5.3-flash (Z.ai) über das Claude Agent SDK · **Datum:** 2026-11-26

> **Zitier-Form:** Kennung, nicht Adresse — `ADR-0103`, `make mutate-greift`
> statt eines Links auf den Sensor; Baseline-Stellen als Tag + Pfad in
> Inline-Code (`v7.0.0` · `regelwerk/modul-10-review-harness.md` §Ziel-Form:
> Reviewer-Skill).

**Eingangs-Kontext:**

- `ADR-0103` — `docs/plan/adr/0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md` (Festlegungen 1–4)
- `ADR-0102` (superseded, gelesen für Übergangs-Form und Kopf-Formen der Records)
- `ADR-0035` Festlegung 3 (Form der deklarierten Ausnahme) · `ADR-0083` (Handoff-Gate)
- [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Beleg-Kommandos)
- `AGENTS.md` §3; [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed),
  [`MR-029`](../../harness/conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage),
  [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung),
  [`MR-071`](../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand),
  [`MR-072`](../../harness/conventions.md#mr-072--ein-review-report-bekommt-beim-archivieren-einen-stub-entgegen-dem-wortlaut-der-ziel-form),
  [`MR-090`](../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | LOW | Die Festlegung-4-Zeile zu Fall 791 behauptet, er färbe „der zweite bats-Fall" rot; der Fall-Kopf von 791 und die Bruchprobe färben den **ersten** bats-Fall („ein Pfad unter .harness/stamp/mutate bewegt den Hash nicht"), der zweite (fail-closed) bleibt grün — der Verweis im eingefrorenen ADR-Körper zielt auf den Nachbarn. | ADR-0103 Festlegung 4 (`AGENTS.md` §3.6) | `docs/plan/adr/0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md` Festlegung-4-Tabelle, Zeile zu Fall 791 | ja — `make mutate MUTATE_CASES=791-working-tree-stamp-ausnahme-ohne-zaehne.sh` färbt den ersten, nicht den zweiten Fall | „Mutations-Beleg-Zeile nennt den Nachbarn des roten Falls" |
| F-2 | LOW | Der bats-Kopf sagt, Fall 3 (enge) und Fall 4 (Determinismus) hätten „der Fall 791 selbst" als rot färbendes Gegenbeispiel; Fall 3 bleibt unter 791 grün (791 entleert die Ausnahme im Stamp-Inneren, der enge Fall misst außerhalb von `.harness/stamp/`, wo die Mutation nichts ändert) — nur für Fall 4 trägt die Nennung. | `AGENTS.md` §3.6 | `test/working-tree-hash-abnahme.bats` Kopf, Zeilen 27–30 | ja — `make mutate MUTATE_CASES=791-…` lässt Fall 3 grün | „Wächter-Kopf behauptet eine Färbungs-Paarung, die die Gegenprobe widerlegt" |
| F-3 | LOW | Der Fall-791-Kopf behauptet Exklusivität („Faerbt genau den Fall … rot"); Fall 4 (Determinismus) färbt ebenso rot — sein Setup enthält Stamp-Inhalt, der unter der entleerten Liste die beiden Hash-Aufrufe über den fail-closed-Zweig bricht. | `AGENTS.md` §3.6 | `test/mutations/791-working-tree-stamp-ausnahme-ohne-zaehne.sh` Kopf | ja — dieselbe Mutation lädt Fall 4 mit | „Fall-Kopf-Zusicherung im Kommentar" |
| F-4 | INFO | Die Kurzfassung „nimmt `.harness/stamp/**` aus" (ADR-Titel; entsprechend `mutate.md` §CI-Branch) liest sich als stilles Ausnehmen des ganzen Baums; der Code nimmt nur `.harness/stamp/mutate` aus und beendet undeckten Inhalt unter `.harness/stamp/` rot (Exit 2) — die Mechanik trägt Festlegung 2, die Kurzfassung übernimmt die Listen-Form nicht. | ADR-0103 Festlegung 2 (Grenze) | Titel von `ADR-0103`; `harness/sensors/mutate.md` §CI-Branch | nein — Text-Urteil; der fail-closed-Lauf selbst macht die Differenz laut, ein Text-Gate existiert nicht | „Kurzfassung einer Ausnahme trägt die Listen- und Rest-Form nicht" |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Hash-Ausnahme-Mechanik (`harness/tools/working-tree-hash.sh` Zeilen 14–56, Bruchproben in Kopien unter `/tmp/rev-adr0103/`) | geprüft, ohne Befund — die Ausnahme deckt genau `.harness/stamp/mutate` (nicht den ganzen Baum), und Inhalt unter `.harness/stamp/` außerhalb der Liste endet mit Meldung und Exit 2; kein stiller Pfad. |
| Stop-Hook-Kette (`.claude/hooks/stop-require-gates.sh` Zeile 84; `harness/tools/record-gates.sh` Zeile 60; `harness/tools/gates-fast.sh` Zeile 99) | geprüft, ohne Befund — alle drei Anrufer rufen dasselbe `working-tree-hash.sh`; keine zweite, ausnahmefreie Hash-Berechnung, die vom Gates-Stempel divergiert. |
| Records-Form (vier `.harness/stamp/mutate/*.txt`) | geprüft, ohne Befund — der Kopf nennt den neuen Ablageort je ADR-0103 Festlegung 1, die `MR-051`-Zahl/Kommando-Belege im Kopf sind unberührt, keine verbliebenen `d-check:ignore`-Marker; Move (`ef54b273`, 0 inseriert/0 gelöscht mit `-M`) und Kopf-Zug (`83d58d29`, 2 Zeilen je Datei) getrennt je `AGENTS.md` §3.3. |
| Scan-Messung (`.d-check.yml` `scan.ignore` + zwei `codepaths.ignore-refs`-Tombstones) | geprüft, ohne Befund — die Begründung nennt den getroffenen Baum in seiner Gesamtheit, beide Tombstones tragen eigene Gruppen und nennen die Tiefe-4-Bäume ihrer Treffer; `internal/ausnahmegrund` liest die reale `.d-check.yml` und misst dort, wo Markdown-Treffer liegen — für die neue `scan.ignore`-Zeile ist die Treffer-Menge heute leer (nur `.txt` darunter; die Grenze „nur Markdown" steht am Paketkopf), die Begründung nennt den Baum trotzdem. |
| Supersedes-Form (`ADR-0102` über der Range) | geprüft, ohne Befund — Status-Zeile und Geschichte-Zeile sind die einzigen Züge nach Accepted, der Kern ist unverändert; `ADR-0103` trägt Supersedes mit Umfangs-Aussage. |
| `mutate-greift`-Anlagen ([`MR-071`](../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)-Form der neuen Fälle) | geprüft, ohne Befund — `make mutate-greift` → `mutate-greift: 778 Fall/Faelle, 778 greifen, 0 Befund(e)`; beide Anker transformieren den Quell-Bestand je genau einmal. |

Beleg-Kommandos und -Ausgaben (Kurzfassung):

```text
sed-Fall 791 auf Kopie   -> genau ein Zug (grep -c 'nicht-gedeckt-vorhanden': 1)
sed-Fall 792 auf Kopie   -> genau ein Zug (grep -c 'if false && ! ausnahme': 1)
make mutate-greift       -> mutate-greift: 778 Fall/Faelle, 778 greifen, 0 Befund(e)
ls test/mutations/*.sh | wc -l ; ls test/mutations | grep -c '79[12]'
                         -> 778 ; 2  (die neuen Fälle sind unter den 778)
Verhaltensprobe 792 (Stub-git-Werkstatt, Kopie mit .harness/stamp/fremd/):
  transformiertes Skript -> exit 0, still  (der Defekt, den bats-Fall 2 bindet)
```

Anmerkung zur Probe: Die In-place-Ausführung von Fall 791 im Baum (versehentlich,
Bruchprobe) hat die Skript-Zeile mutiert; unmittelbar darauf über
`git checkout -- harness/tools/working-tree-hash.sh` rückgesetzt — `git status`
ist clean, keine Reste. Die Kopien liegen unter `/tmp/rev-adr0103/` außerhalb
des Baums.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 3 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** „Mutations-Beleg-Zeile nennt den Nachbarn des roten Falls" · „Wächter-Kopf behauptet eine Färbungs-Paarung, die die Gegenprobe widerlegt" · „Fall-Kopf-Zusicherung im Kommentar" · „Kurzfassung einer Ausnahme trägt die Listen- und Rest-Form nicht"

## Kern-Verdikt je Prüffeld (Auftrag)

1. **Hash-Ausnahme-Klasse** — ja, deckt genau den deklarierten Gegenstand: Das
   Skript nimmt **nur** `.harness/stamp/mutate` aus (`HASH_AUSNAHMEN`-Liste,
   `case`-Grenze `"$e" | "$e"/*`) und beendet Inhalt unter `.harness/stamp/`
   außerhalb der Liste mit Meldung und Exit 2 (fail-closed je `MR-017`-Form) —
   nicht zu weit (`.harness/stamp/fremd/*` bricht), nicht zu eng (alle vier
   Records und künftige deckt der Unterbaum). Die ADR-Kurzfassung
   `.harness/stamp/**` im Titel ist die F-4-Lücke; die Mechanik selbst stimmt
   mit Festlegung 2.
2. **Stop-Hook-Halsband (Kern)** — die Kette stimmt: Der Stop-Hook ruft
   `bash harness/tools/working-tree-hash.sh` (Zeile 84) — **denselben**
   Skript-Lauf, der die Ausnahme trägt; kein separater Kalkulations-Zweig, keine
   Divergenz zwischen Hook-Stempel und Gates-Stempel. `record-gates.sh` (Zeile 60)
   und `gates-fast.sh` (Zeile 99) rufen dasselbe Skript. Die Wirkung „ein
   Record-Commit allein unter der Ablage hält den Nachweis gültig, auch bei neuem
   HEAD" ist in `ADR-0103` Festlegung 2 als Wirkung deklariert — kein stiller Pfad.
3. **Records-Form** — Kopf-Form je `ADR-0102` (Festlegungen 2–4 in Kraft) mit dem
   neuen Ort, `MR-051`-Belege unberührt, Move und Kopf-Zug getrennt
   (`AGENTS.md` §3.3); die Records tragen keine verbliebenen Ignore-Marker und
   liegen unter `scan.ignore`.
4. **Scan-Messung** — `MR-029`-Form erfüllt: Der Grund nennt den Baum in seiner
   Gesamtheit; die Tombstones nennen ihre Treffer-Bäume; der
   `internal/ausnahmegrund`-Lauf über der realen `.d-check.yml` misst die
   Tombstones an ihren Markdown-Treffern und hat über der neuen
   `scan.ignore`-Zeile heute keine Treffer-Menge (oben benannt — keine
   Befund-Lücke, die Grenze steht am Paketkopf).
5. **Supersedes-Form (`AGENTS.md` §3.4)** — `ADR-0102` trägt `Status:` Superseded
   mit Zeiger und eine Geschichte-Zeile; der Kern ist über der Range
   unverändert; `ADR-0103` trägt Supersedes in vollem Umfang mit
   Umfangs-Aussage — „nur der Ort wechselt" ist am Form-Set nachgezeichnet.
6. **`mutate-greift`** — `778 Fall/Faelle, 778 greifen, 0 Befund(e)`; beide neuen
   Fälle (776 + 2) greifen am Bestand, die Anker transformieren den Quell-Bestand
   je genau einmal ([`MR-071`](../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)-Form;
   `5de9ee9f` zog die SC2016-freie Doppelquote an den Quell-Bestand — beide
   sed-Formen treffen die reale Zeile nachgezeichnet).

## Verdikt

**Merge-blockierend:** nein — nur LOW und INFO; die drei LOW-Findings sind
Beleg-Text-Zusagen über Färbungs-Paarungen am Kopf von Fall und Wächter, sie
ändern kein Verhalten von Skript, Wächter oder Hook. Das Kern-Verdikt je
Prüffeld 1 und 2 ist ungeteilt grün.

**Übergabe:** Findings an den Implementer; die Finding-Klassen in die
Slice-Closure §7 (die Klasse „Fall-Kopf-Zusicherung im Kommentar" ist gelebt —
Abgleich im Register dort). Dieser Report ist ein Lauf-Beleg (Audit: Range
`f4a94a75..5de9ee9f`, Skill 2.3.0, Modell glm-5.3-flash, Verdikt nicht
blockierend); Verifikation gegen DoD/Spez bleibt der Verifier (Modul 11).
