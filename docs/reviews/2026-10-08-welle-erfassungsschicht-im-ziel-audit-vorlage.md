# Welle-Closure welle-erfassungsschicht-im-ziel — Audit-Vorlage und Steering-Loop-Übergabe (Schritte 2, 3a, 3b)

- **Rolle:** Planner · **an:** Architect (Abschnitte A, B) · **Bezug:**
  [`LH-FA-13`](../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans), Baseline-Regelwerk
  `modul-06-roadmap.md` §Wellen-Closure-Prozedur und `modul-08-agentenrollen.md` §Rollen-Sequenz für
  eine Welle (`v6.17.0`)
- **Gemessen auf:** `bb0aa718`; Fenster = seit der letzten Welle-Closure `3779eb4a`
  (Self-Close `welle-adopter-weg-im-ziel`), 60 Commits (`git log --oneline 3779eb4a..HEAD | wc -l`)
- **Schritt 1:** erledigt — Verifier-Beleg `2026-10-08-welle-erfassungsschicht-im-ziel-trigger.md`.
- **Die Closure hält hier an.** Schritte 3c, 4, 5, 6 laufen nach dem Verdikt zu A und B.

## Schritt 2 — vom Planner erledigt

- **Carveouts:** `CO-001` *Auflösung fällig*, Folge-Slice `slice-113` (in `open/`); `CO-002`
  permanent — beide unverändert seit dem letzten Audit; keine weiteren (`ls docs/plan/carveouts/`).
- **Bootstrap-aware Gates:** keines (`grep -n 'bootstrap-aware' Makefile *.mk` → leer).

## A — Trigger-Audit, ADR- und Hard-Rule-Zweig (Architect)

Ereignisse im Fenster (`git diff --name-status 3779eb4a HEAD -- docs/plan/adr harness/conventions
AGENTS.md Makefile d-check.mk internal/emit/emit.go .d-check.yml spec/`):

| Ereignis im Fenster | Frage |
|---|---|
| [ADR-0087](../plan/adr/0087-fingerabdruck-gilt-auch-fuer-das-emittierte.md) `Accepted`, *Supersedes (Teil)* [ADR-0011](../plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 2 | löst die Teil-Ablösung einen Re-Evaluierungs-Trigger von ADR-0011 aus, oder ist sie mit der Annahme erledigt? |
| [ADR-0088](../plan/adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) neu, `Proposed` | kein Trigger dieser Welle — nur genannt, weil im Fenster |
| `spec/spezifikation.md` geändert (Fassung 5, `SPEC-087`/`SPEC-096`/`SPEC-098`); `spec/lastenheft.md`, `AGENTS.md`, `MR`-Einträge, Pins unverändert | — vermutlich kein weiterer Trigger gefeuert |

**Hard Rules:** einziger Auflösungs-Trigger in `AGENTS.md` lautet *permanent*
(`grep -n 'Auflösungs-Trigger' AGENTS.md`); Architect bestätigt.

## B — Lese-Schritt 3a und Verkörperungs-Frage 3b (Architect)

`make register-ausgang` → `235 Eintraege, 66 ueber der Schwelle, 0 Befund(e)`. Im Fenster angelegte
Belege (`git diff --name-status --diff-filter=A 3779eb4a HEAD -- docs/plan/planning/observations`):
acht, verteilt auf sechs Einträge; keiner überschreitet damit **erstmals** 3× ohne Ausgang.

**3b — Wiederauftreten nach Verkörperung bzw. bei geplantem Ausgang** (verlangt je Zeile: *Prosa
trägt — Sensor X* · *kein Sensor möglich, weil …* · *Zielort ist bereits ein Sensor* · *geplanter
Träger fängt es*):

| Eintrag | Belege | Stand | neuer Beleg im Fenster |
|---|---|---|---|
| `span-feld-bedeutung-wechselt-ohne-fassungs-angabe` | 4 | **geplant auf `slice-span-traegt-die-fassung-seiner-erfassungsregel` — der Slice liegt in `done/`** | derselbe Slice |
| `neuer-waechter-ohne-mutations-fall` | 19 | geplant `slice-119` (in `open/`) | `slice-107-inhalts-hash-traegt-eine-entscheidung`, `slice-agent-role-traegt-nicht-bekannt` |
| `zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel` | 7 | geplant `slice-069` (in `open/`) | `slice-span-traegt-die-fassung-seiner-erfassungsregel`, `slice-emittierte-feldliste-traegt-verfuegbarkeit-und-aufbewahrung` |
| `zusage-neben-geaenderter-ableitung-bleibt-stehen` | 36 | geplant `slice-153` (in `open/`) | `slice-agent-role-traegt-nicht-bekannt` |
| `geplanter-slice-wird-nie-gearbeitet` | 5 | verkörpert (`.claude/commands/plan-welle.md` §Slices bereitstellen) | `slice-205-der-strom-traegt-die-zug-grenze` |
| `feldnotiz-traeger-und-spec-koennen-in-der-kernaussage-abweichen-ohne-sensor` | 2 | offen, unter der Schwelle | `slice-emittierte-feldliste-traegt-verfuegbarkeit-und-aufbewahrung` |

**(a) `span-feld-bedeutung-wechselt-ohne-fassungs-angabe` braucht einen neuen Ausgang.** Der geplante
Träger ist geliefert: jede Zeile trägt `rule_version` (`SPEC-096`, `CurrentRuleVersion = 5`), Fall 593
hält die Konstante, `TestCurrentRuleVersionIsTheLastSpecFassung` hält sie gegen die reale Spezifikation.
`geplant` auf eine geschlossene Kennung ist keine Adresse mehr. Verlangt: *verkörpert* mit Zielort, der
`seit slice-span-traegt-die-fassung-seiner-erfassungsregel` trägt (die §7 des Slice führt kein
`liegt in`-Feld, der Anker fehlt also noch) — oder ein anderer Ausgang aus der geschlossenen Menge. Die
unbewachte Hälfte (ein Bedeutungswechsel wird nicht als solcher erkannt) benennt `SPEC-094` selbst.

**(b) `zusicherung-ueber-der-leeren-menge-wahr` — ehrlich neu gezählt.** Stand *verkörpert*
(`.harness/skills/reviewer.md`, MEDIUM-Zeile, `seit slice-mutate-fall-filter-und-die-belegform-vereinigung`),
3 Belege, `state.md` nennt als Eskalation eine Falsch/Richtig-Zeile in `AGENTS.md` §3.6. Gelesen über
die vier Welle-Slices (Review-, Verifikations-Reports, §6/§7, Commit-Messages im Fenster):

- **Kein Artefakt hält ein Auftreten der Klasse** (Negation über einer selbst besorgten Menge, die
  leer werden kann). `grep -n -i 'leer\|vakui\|eskal'` über `2026-10-08-agent-role-*.md` und §6/§7 von
  `slice-agent-role-traegt-nicht-bekannt` trifft nur die Lesart *`[]` heißt keiner* — geprüft, ohne
  Befund. Ein bewusster Nicht-Beleg steht in keinem Artefakt; stammt er aus dem Lauf-Kontext der
  Closure, ist die Quelle vom Auftraggeber oder Koordinator zu nennen.
- **Nächster Kandidat:** `2026-10-08-span-fassung-review.md` F-2 — `fassungsZeile` schreibt bei leerem
  Bestand ohne Guard eine leere Zeile, kein Test bindet es. Das ist ein ungebundener Zweig für leere
  Eingabe, keine Zusicherung, die über leerer Menge grün wird; gezählt wurde er unter
  `zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel`. Dieselbe Review nennt
  `TestCurrentRuleVersionIsTheLastSpecFassung` *„bricht bei leerer Treffermenge ab"* — der Ausweg der
  Klasse, angewandt.
- **Planner-Lesart:** kein neuer Beleg. Verlangt vom Architect: die Lesart bestätigen oder, falls ein
  Auftreten belegt wird, den vierten Beleg samt Vorgang benennen — dann greift nach
  `modul-06-roadmap.md` Schritt 3 die Pflicht *Sensor benennen oder begründen, warum keiner möglich ist*
  (Prosa ausgeschöpft); die Eskalationsfolge ist dabei kein Kriterium für die Zählung.

## Paarungen der Welle-Slices (Planner, vorab)

(a) keine §7 der vier Slices trägt `liegt in` als Feld (die Treffer sind Prosa der Paarungs-Zeilen).
(b) jeder in §6/§7 genannte Slice existiert im Lifecycle (`slice-098` in `done/`, `slice-119` in
`open/`, die Welle-Slices in `done/`). (c) erste Hälfte grün — die sechs zitierten Einträge existieren
mit 2–36 Belegen; zweite Hälfte: 2 Verzeichnisse ohne Beleg,
`cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`,
`einstiegs-datei-weicht-von-der-pflichtgliederung-ab` — nicht als getragen behauptet.

**Kopf-Feld von `slice-205`:** trägt weiter `**Welle:** welle-erfassungsschicht-im-ziel`, obwohl er §4
verlassen hat (Gegenstand *entfallen*). Der Planner berichtigt das Feld in Schritt 3c in einem eigenen
Commit (Modul 5, Bedingung 3); kein Verdikt nötig.

## C — Backlog-Lese-Schritt (Vorschläge, Entscheidung beim Auftraggeber)

`open/` 59, `next/` 7 (`ls … | wc -l`); im Fenster kein Slice neu angelegt. Die Welle berührt:

| Slice | Vorschlag | Grund |
|---|---|---|
| `slice-feldabdeckung-existenz-sensor` | bestätigt | Out-of-Scope dieser Welle; der Feldlisten-Text wächst, ein Wortlaut-Sensor fehlt weiter |
| `slice-119-zusage-ohne-fall-wird-sichtbar` | bestätigt, Priorität hoch | trägt `neuer-waechter-ohne-mutations-fall` (19 Belege, +2 im Fenster) |
| `slice-069-zahn-bindet-zusicherung` | bestätigt | trägt `zusage-im-doc-kommentar-ohne-zahn-…` (+2 im Fenster) |
| `slice-153-wellen-commands-nennen-die-roadmap-abschnitte` | prüfen | trägt `zusage-neben-geaenderter-ableitung-bleibt-stehen` (36 Belege); der Titel deckt nur drei Stellen — Gruppierungs-Kandidat mit dem Sensor der Klasse |
| `slice-113-co-001-ist-faellig` | bestätigt | `CO-001` steht auf *Auflösung fällig* |

Nichts stillgelegt, nichts abgelehnt.

## D — Archivierung, Schritt 4

`.harness/state/bin/ai-harness-init archive-welle --vorschau welle-erfassungsschicht-im-ziel` → rc 3
(125 s): `[ergebnisnotiz]` und `[kein-plan]` lösen Schritt 3c und 5; **`[untergrenze]`** (198
wellenlose Slices flach in `done/`, kein `done/*/archiv.zip`) und **`[haenger]`** (ADR-0016 → zwei
Review-Reports von `slice-050`) bleiben. Wie bei den zwei Vorgänger-Wellen (Auftraggeber-Freigabe vom
2026-10-08) schließt die Welle ohne Schritt 4, als Feststellung in der Ergebnisnotiz; kein Verdikt nötig.
