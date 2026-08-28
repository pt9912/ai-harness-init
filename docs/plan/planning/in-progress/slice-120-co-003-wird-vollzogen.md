# Slice slice-120: Der Vollzug für `CO-003` — der Trigger ist entschieden, die Datei liegt noch am alten Ort

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Carveout-Auflösung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, hier beantwortet: **(1) Bündel?** Nein — der Gegenstand ist **ein** Carveout, dessen
Sache bereits gebaut ist; der Slice ist einzeln lieferbar und wartet auf keinen zweiten.
**(2) Gemeinsames Closure-Kriterium?** Nein. Der einzige Kandidat wäre *„kein aktiver Carveout
trägt einen eingetretenen Trigger"* — das ist die **Konjunktion** zweier unabhängiger DoDs und
keine Bedingung, die erst aus dem Zusammenwirken entsteht. **(3) Auslöser reaktiv oder gewollt?**
Reaktiv: der Auflösungs-Trigger von
[`CO-003`](../../carveouts/CO-003-mutate-ohne-zeitschranke.md) ist eingetreten, vom Architect am
2026-08-28 als eingetreten entschieden, und offen ist allein der **Vollzug**. Kein
Fähigkeits-Sprung — es entsteht kein Sensor, keine Gate-Ausnahme fällt, die emittierte Ebene
bleibt unberührt. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Warum das nicht derselbe Slice ist wie [slice-113](../open/slice-113-co-001-ist-faellig.md).** Beide
vollziehen eine fällige Carveout-Auflösung, beide bewegen eine Datei nach `done/` und gleichen
Links ab — die Frage ist gestellt und wird hier beantwortet, nicht vorausgesetzt. Drei gemessene
Unterschiede tragen die Trennung:

1. **Der Gegenstand ist ein anderer.** [slice-113](../open/slice-113-co-001-ist-faellig.md) **baut**: er
   öffnet einen Gate-Prüfbereich, wählt zwischen zwei Techniken, fährt einen Trockenlauf über
   `git ls-files 'test/*.bats' | wc -l` → **16** Dateien und braucht dafür einen eigenen
   `test/mutations/`-Fall. Dieser Slice baut nichts: die Sache ist mit
   [slice-117](../done/slice-117-lauf-ohne-ende-faerbt-rot.md) gebaut, es fehlt die
   Verzeichnis-Position.
2. **Der Ausgang ist ein anderer.** [slice-113](../open/slice-113-co-001-ist-faellig.md) §2 DoD (3) lässt
   **zwei** Ausgänge zu — Auflösung **oder** Neufassung mit einem Trigger, der noch nicht
   eingetreten ist —, weil die Technik-Wahl vor dem Trockenlauf offen ist. Hier ist der Trigger
   entschieden; es gibt einen Ausgang.
3. **Die Fläche ist eine andere.** Eingehende Links auf den jeweiligen Carveout:
   `grep -rho '](\([^)]*\)CO-001-bats-shell-lint\.md)' --include='*.md' docs/ | wc -l` → **32**
   über **17** Dateien (`grep -rlo …` derselben Form), gegen **20** über **6** für
   [`CO-003`](../../carveouts/CO-003-mutate-ohne-zeitschranke.md) (§1). Alle vier Zahlen wandern
   mit ihrem Bestand und sind **kein** Erwartungswert
   ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
   Setzung 2).

**Was aus 1–3 folgt, ist eine Schranke, keine Vorliebe.** Zusammengelegt träfen zwei Sätze zu je
drei slice-eigenen DoD-Punkten aufeinander, und Modul 5 §Ziel-Form sagt zu dieser Lage nicht *„die
DoD wird länger"*, sondern *„der Schnitt ist falsch"* (≤ 3). Der Preis stünde daneben: ein
`git mv`, für den nichts mehr offen ist, hinge am Ausgang eines Trockenlaufs, dessen Befund-Zahl
niemand kennt — [slice-113](../open/slice-113-co-001-ist-faellig.md) §4 benennt dafür ausdrücklich zwei
Rückführungen. Ein fälliger Carveout, der auf eine offene Technik-Wahl wartet, ist genau die
De-facto-Permanenz, gegen die Modul 7 den Carveout-Audit stellt.

**Ebene: Dogfood, nicht emittiert.** Gegenstand sind das Carveout-Register **dieses** Repos und
die Planungs-Artefakte unter `docs/plan/`. Was ein emittiertes Repo an Carveout-Register bekommt,
entscheidet der Slice, der die Tool-Ebene entscheidet — nicht dieser.

**Bezug:**
[`CO-003`](../../carveouts/CO-003-mutate-ohne-zeitschranke.md) (der Carveout selbst; sein
§Übergabe-Block verteilt den Vollzug auf Planner und Implementer),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(Verortung),
[`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)
(die `codepaths`-Ausnahme für `docs/reviews/**` — sie entscheidet, welche Zeitdokumente beim
Link-Abgleich unangetastet bleiben),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben ihrem Kommando),
[`AGENTS.md`](../../../../AGENTS.md) §3.3 (`git mv` und Inhaltsänderung sind zwei Commits — hier
tragend, weil der Move die Datei eine Ebene tiefer legt),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (jede Zusage braucht ihr rot gesehenes Gegenbeispiel —
DoD (2) macht daraus einen Schritt in der Reihenfolge).

**Autor:** Planner. **Datum:** 2026-08-28.

---

## 1. Ziel

**[`CO-003`](../../carveouts/CO-003-mutate-ohne-zeitschranke.md) liegt in
`docs/plan/carveouts/done/`, sein Kopf und der Carveout-Index sagen dasselbe wie sein Ort, und <!-- d-check:ignore (done/ entsteht erst bei erster Carveout-Auflösung) -->
kein Verweis zeigt ins Leere — in beide Richtungen.**

### Die Ausgangslage: entschieden ist der Trigger, offen ist der Vollzug

[`CO-003`](../../carveouts/CO-003-mutate-ohne-zeitschranke.md) steht auf *Aktiv — Auflösung
fällig* (`grep -c '^\*\*Status:\*\* Aktiv' docs/plan/carveouts/CO-003-mutate-ohne-zeitschranke.md`
→ **1**). Der Architect hat am 2026-08-28 entschieden: die Wort-Bedingung gestrichen, die
verbleibenden zwei Bedingungen eingetreten, der zweite Ausgang (Überführung in eine ADR) verneint;
Modul-7-Übergang *aufgelöst*. Was fehlt, ist die Handlung, die Modul 7 §Carveout-Audit-Slice dem
Implementer zuweist — *„Implementer führt `git mv` und Config-Updates aus"*. Solange sie
aussteht, sagt die Verzeichnis-Position das Gegenteil der Entscheidung, und ein Carveout, dessen
Ort seiner Aussage widerspricht, ist genau die Doku-Drift, gegen die der Mechanismus steht.

**Eine Gate-Ausnahme ist nicht auszubauen, und das ist gemessen, nicht angenommen.**
[`CO-003`](../../carveouts/CO-003-mutate-ohne-zeitschranke.md) §Geltungs-Konfiguration sagt es
selbst — *„Keine Gate-Konfiguration trägt eine Ausnahme für diesen Carveout"* —, und der Kopf
nennt als betroffenes Gate **keines**: `make mutate` ist Nicht-Gate-Verify. Der Slice fasst
darum weder [`Makefile`](../../../../Makefile) noch [`.d-check.yml`](../../../../.d-check.yml) an.

### Der Move geht eine Ebene tiefer — daran unterscheidet er sich vom Move eines Slice

Ein Slice wandert `in-progress/` → `done/`: **gleich tief**, seine eigenen `../`-Links tragen
unverändert, nur die eingehenden Verweise brechen. Der letzte solche Zug ist gemessen und
committet (`ba5c07f`, *„32 Verweise ueber 6 Dateien, zwei Formen"*). Dieser Move geht
`docs/plan/carveouts/` → `docs/plan/carveouts/done/` — **eine Ebene tiefer**, und damit brechen <!-- d-check:ignore (done/ entsteht erst bei erster Carveout-Auflösung) -->
**beide** Richtungen:

| Richtung | Fläche | Kommando |
|---|---|---|
| **ausgehend** (die Links der Datei selbst) | **40** Ziele, alle relativ | `grep -o '](\([^)]*\))' docs/plan/carveouts/CO-003-mutate-ohne-zeitschranke.md \| grep -vc '](http'` |
| **eingehend**, Form *Markdown-Link* | **20** Vorkommen über **6** Dateien | `grep -rho '](\([^)]*\)CO-003-mutate-ohne-zeitschranke\.md)' --include='*.md' docs/ \| wc -l`; die Datei-Zahl über `grep -rlo …` derselben Form |
| **eingehend**, alle Nennungen | **8** Dateien | `grep -rln 'CO-003' --include='*.md' . \| grep -v '^./.harness' \| grep -v 'CO-003-mutate' \| wc -l` |

Die ausgehende Hälfte zerfällt in zwei Klassen, die verschieden zu ziehen sind: **zehn**
eindeutige `../`-Ziele (`grep -o '](\.\./[^)#]*' … | sed 's/^](//' | sort -u | wc -l`) bekommen
je ein `../` mehr, und **fünf** Geschwister-Links (`CO-001-bats-shell-lint.md` viermal,
`README.md` einmal) sind nach dem Move keine Geschwister mehr. Alle Zahlen wandern mit ihrem
Bestand und sind **kein** Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Die Lücke zwischen 8 und 6 ist keine Nachlässigkeit, sondern eine gemessene Ausnahme.** Die zwei
Verifikations-Berichte unter `docs/reviews/` nennen `CO-003` in **keiner** Link-Form
(`grep -c '](\([^)]*\)CO-003-mutate-ohne-zeitschranke\.md)' docs/reviews/2026-08-27-slice-117-verify.md docs/reviews/2026-08-27-slice-117-verify-runde2.md`
→ **0** und **0**); die eine Pfad-Nennung als Inline-Code deckt `codepaths.exempt-paths:
["docs/reviews/**"]` in [`.d-check.yml`](../../../../.d-check.yml) — die Ausnahme, die genau für
alternde Lifecycle-Pfade in Zeitdokumenten da ist
([`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)).
**Was sie nicht deckt, ist die Link-Form:** `docs/reviews/**` ist für `ids` und `codepaths`
ausgenommen, für `links` **nicht**. Die zwei Review-Berichte derselben Runde tragen deshalb je
einen Link und werden gezogen, die zwei Verifikations-Berichte bleiben unangetastet. Dieselbe
Trennung hat `ba5c07f` gemessen und mit einer Gegenprobe belegt.

### Was dieser Slice nicht entscheidet

- **Den Haken an [slice-105](../done/slice-105-mutate-messen-dann-teilen.md) §2 DoD (3).** Er ist
  **gesetzt** — Planner-Entscheidung vom 2026-08-28, mit *wodurch* und *wann* an Ort und Stelle
  statt in einer zweiten Fassung. Der Vollzug hakt in der Verifikations-Checkliste des Carveouts
  nur nach; er entscheidet nicht neu und schreibt
  [slice-105](../done/slice-105-mutate-messen-dann-teilen.md) nicht um.
- **Den Trigger.** Er ist entschieden; die Begründung steht in der Geschichte-Zeile des Carveouts
  zum 2026-08-28.
- **Den Hänger im Vorwärmlauf vor dem Fork.** Er liegt seit derselben Prüfung außerhalb des
  Geltungsbereichs und hat mit
  [slice-118](../open/slice-118-vorwaermlauf-endet-von-selbst.md) einen eigenen Träger; er blockiert die
  Auflösung nicht.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **(1) Die Datei liegt am neuen Ort, und beide Register sagen es.** Verzeichnis-Position und
      Carveout-Index stimmen überein; der Move ist ein **eigener** Commit ohne Inhaltsänderung
      ([`AGENTS.md`](../../../../AGENTS.md) §3.3).
      **Rot:** `ls docs/plan/carveouts/CO-003-*.md` → heute **ein** Treffer, danach Exit 1;
      `sed -n '/^## Aktiv/,/^## Permanent/p' docs/plan/carveouts/README.md | grep -c 'CO-003'` →
      heute **1**, danach **0**;
      `sed -n '/^## Aufgelöst/,$p' docs/plan/carveouts/README.md | grep -c 'CO-003'` → heute
      **0**, danach **1**. Bewegt sich nur eine der drei Antworten, widersprechen sich Ort und
      Index.
- [ ] **(2) Kein Verweis zeigt ins Leere, und der Beleg dafür ist ein rot gesehener Lauf.** Die
      Reihenfolge ist Teil der Zusage: **nach** dem `git mv` und **vor** dem Nachziehen läuft
      `make docs-check` **einmal** und meldet die gebrochenen Ziele mit Datei und Zeile — beide
      Richtungen, gegen die Fläche aus §1 gehalten. Erst danach werden sie gezogen, in einem
      zweiten Commit.
      **Rot:** genau dieser Zwischenlauf. Über dem unbewegten Baum ist `make docs-check` grün
      (2026-08-28: `d-check: 422 Datei(en) geprüft, 0 Befund(e)`; die Dateizahl wandert mit dem
      Markdown-Bestand) und taugt deshalb als Beleg **nicht** — was heute grün ist, sagt nichts
      über einen Zug, der noch nicht getan ist.
      **Unangetastet bleiben** die zwei Verifikations-Berichte unter `docs/reviews/`; der Grund
      ist gemessen und steht in §1, nicht in der Kulanz.
- [ ] **(3) Der Kopf des Carveouts und seine Verifikations-Checkliste sagen dasselbe wie sein
      Ort.** Modul 7 §Carveout-Audit-Slice gibt dem Implementer *„`git mv` und Config-Updates"*;
      die Checkliste des Carveouts ist eines davon. Was der Kopf statt *Aktiv* sagt, ist der
      Modul-7-Übergang *aufgelöst*.
      **Rot:** über der bewegten Datei `grep -c '^\*\*Status:\*\* Aktiv'` → heute **1**, danach
      **0**; `grep -c '^- \[ \] '` → heute **4**, danach **0** — oder jeder verbleibende Punkt
      trägt an seiner Zeile den Grund seiner Auslassung. Die vier sind nicht frei wählbar: einer
      von ihnen verlangt `make gates` grün **und** `make mutate` ohne Befund über dem Baum, der
      den Move trägt.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Doku-Update, falls ein öffentlicher Vertrag berührt ist · Closure-Notiz mit
Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`docs/plan/carveouts/CO-003-mutate-ohne-zeitschranke.md`](../../carveouts/CO-003-mutate-ohne-zeitschranke.md) | `git mv` **und** update, in **zwei** Commits | der Move nach `done/`; danach Kopf, Verifikations-Checkliste und die 40 ausgehenden Ziele. Getrennt, sonst fällt die Rename-Detection unter die Similarity-Schwelle ([`AGENTS.md`](../../../../AGENTS.md) §3.3) |
| [`docs/plan/carveouts/README.md`](../../carveouts/README.md) | update | der Index: die Zeile wandert von *Aktiv* nach *Aufgelöst*. Der Abschnitt trägt heute `_(noch keine)_` |
| die **6** Dateien mit eingehendem Link (§1) | update | **20** Vorkommen; darunter zwei Review-Berichte unter `docs/reviews/`, für die die `links`-Prüfung **nicht** ausgenommen ist |
| `docs/reviews/2026-08-27-slice-117-verify.md` und `docs/reviews/2026-08-27-slice-117-verify-runde2.md` | **unverändert** | keine Link-Form, gemessen; die Inline-Code-Nennung deckt `codepaths.exempt-paths` ([`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)) |
| [`docs/plan/planning/done/slice-105-mutate-messen-dann-teilen.md`](../done/slice-105-mutate-messen-dann-teilen.md) | **bereits gezogen** | der Haken an §2 DoD (3) samt *wodurch* und *wann*; Planner-Zug vom 2026-08-28, nicht Teil dieses Slice |
| [`Makefile`](../../../../Makefile), [`.d-check.yml`](../../../../.d-check.yml) | **unverändert** | es gibt keine Gate-Ausnahme auszubauen (§1, gemessen) |
| [`.harness/baseline`](../../../../.harness/baseline) | **unverändert** | byte-verifiziert |
| `internal/emit/` | **unverändert** | Ebene Dogfood (Kopfzeile) |

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): eine Bedingung, und sie ist ohne Rückfrage
entscheidbar.** Das Pflicht-Feld `Folge-Slice` in
[`CO-003`](../../carveouts/CO-003-mutate-ohne-zeitschranke.md) nennt heute keine ID —
`grep -c 'slice-120' docs/plan/carveouts/CO-003-mutate-ohne-zeitschranke.md` → **0**; der Carveout
erklärt dieses Feld selbst zu *„der offenen Stelle dieses Carveouts"*. Es zu füllen ist
Architect-Arbeit, weil der Carveout Architect-Eigentum ist. **Der Slice beginnt, wenn dasselbe
Kommando ≥ 1 liefert.** Der Grund ist nicht Formalismus: Modul 7 schreibt *„jeder temporäre
Carveout [braucht] einen Folge-Slice mit ID, der das Auflösen plant. Slice schlägt Memo."* Ein
Carveout, der mit leerem Pflicht-Feld nach `done/` wandert, verliert genau die Spur, für die das
Feld existiert — und niemand liest ihn danach je wieder.

**Rückführungen, vorab benannt:**

- `in-progress` → `next`: der Zwischenlauf aus DoD (2) meldet Ziele **außerhalb** der in §1
  gemessenen Fläche. Dann ist zuerst zu klären, warum die Messung zu klein war; Messung und
  Vollzug sind dann zwei Landungen, kein vierter DoD-Punkt.
- `in-progress` → `open`: `make mutate` über dem Baum, der den Move trägt, meldet einen Befund.
  Dann ist die Verifikations-Checkliste des Carveouts nicht erfüllbar, und der Befund gehört
  **vor** den Move — eine Auflösung, die über einem roten Sensor vollzogen wird, sagt etwas
  anderes, als sie belegt.

## 5. Closure-Trigger

DoD (1) bis (3) erfüllt mit gefahrenen Kommandos, `make gates` grün, `make mutate` ohne Befund
über dem Baum, der den Move trägt, Review nach Modul 10 und Verifikation nach Modul 11 ohne
blockierenden Befund, Closure-Notiz in §7 mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Wer den Move wie den eines Slice behandelt, zieht nur die eingehende Hälfte.** Das ist der
  wahrscheinlichste Fehler dieses Zugs, weil der letzte Move im Repo (`ba5c07f`) genau so
  aussah und dort richtig war. DoD (2) fängt ihn nicht durch Aufmerksamkeit, sondern durch die
  Reihenfolge: der Zwischenlauf steht **vor** dem Nachziehen und nennt beide Richtungen.
- **`docs/plan/carveouts/done/` entsteht mit dem ersten der beiden fälligen Carveouts.** Wer <!-- d-check:ignore (done/ entsteht erst bei erster Carveout-Auflösung) -->
  zweiter landet, findet das Verzeichnis vor; der Index-Abschnitt *Aufgelöst* bekommt von jedem
  eine Zeile. Kein Konflikt — aber auch keine Reihenfolge-Annahme in eine der beiden Richtungen.
- **Der Slice liefert keinen Code und damit keinen neuen `test/mutations/`-Fall.** Das ist keine
  Ausnahme von [`AGENTS.md`](../../../../AGENTS.md) §3.6, sondern seine Anwendung: die Zusagen
  dieses Slice sind Verzeichnis-Positionen und Link-Ziele, ihr Sensor ist `make docs-check`, und
  der existiert und läuft in `make gates`. Was fehlte, wäre ein Sensor für die Aussage *„kein
  aktiver Carveout trägt einen eingetretenen Trigger"* — und der existiert nicht, gemessen:
  `git grep -c 'CO-00' -- Makefile .d-check.yml d-check.mk .github/` findet in **keiner**
  Gate-Konfiguration eine Carveout-Kennung (Exit 1), `.d-check.yml` führt sechs Module
  (`links, anchors, ids, matrix, codepaths, spans`) und keines liest `docs/plan/carveouts/`, und
  die drei Treffer aus `git grep -lni 'carveout' -- harness/tools/ test/` betreffen sämtlich den
  **emittierten** Index, nicht unser Register. Getragen wird die Aussage heute vom
  Welle-Closure-Audit, also von einer Rolle. Dieser Slice schneidet den Sensor **nicht** mit; er
  ist größer als er, und [slice-113](../open/slice-113-co-001-ist-faellig.md) §6 hat dieselbe Frage aus
  der Audit-Richtung offen.
- **Der Carveout ist Architect-Eigentum, und der Implementer fasst ihn trotzdem an.** Die
  Zuweisung kommt aus Modul 7 §Carveout-Audit-Slice, nicht aus der Bequemlichkeit des Zugs — sie
  deckt `git mv` und Config-Updates, nicht die Trigger- oder Geltungsbereichs-Frage. Wer das
  anders liest, hält vor dem Move und fragt, statt es nebenbei zu entscheiden.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example). Ein Begründungsblock
entfällt: der Slice berührt keine Sub-Area in BF oder Hybrid, öffnet keinen Gate-Prüfbereich und
legt keine neue Sub-Area an. Was er bewegt, sind Verzeichnis-Positionen und Link-Ziele unter
`docs/plan/` — ein Bereich, den `make docs-check` in jedem `make gates`-Lauf vollständig prüft.
