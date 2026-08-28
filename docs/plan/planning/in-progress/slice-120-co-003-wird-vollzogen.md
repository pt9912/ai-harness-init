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
[`CO-003`](../../carveouts/done/CO-003-mutate-ohne-zeitschranke.md) ist eingetreten, vom Architect am
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
3. **Die Fläche ist eine andere.** Eingehende Links auf den jeweiligen Carveout, beide über dem
   Stand des Schnitts erhoben:
   `git grep -ho '](\([^)]*\)CO-001-bats-shell-lint\.md)' 32f12dd -- 'docs/*.md' | wc -l` → **32**
   über **17** Dateien (`git grep -lo …` derselben Form), gegen **29** über **7** für
   [`CO-003`](../../carveouts/done/CO-003-mutate-ohne-zeitschranke.md) (§1). Alle vier Zahlen wandern
   mit ihrem Bestand und sind **kein** Erwartungswert
   ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
   Setzung 2); der Rev-Pin hält fest, über welchem Baum sie gelten
   ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
   Setzung 1).

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
[`CO-003`](../../carveouts/done/CO-003-mutate-ohne-zeitschranke.md) (der Carveout selbst; sein
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

**[`CO-003`](../../carveouts/done/CO-003-mutate-ohne-zeitschranke.md) liegt in
`docs/plan/carveouts/done/`, sein Kopf und der Carveout-Index sagen dasselbe wie sein Ort, und
kein Verweis zeigt ins Leere — in beide Richtungen.**

### Die Ausgangslage: entschieden ist der Trigger, offen ist der Vollzug

[`CO-003`](../../carveouts/done/CO-003-mutate-ohne-zeitschranke.md) stand beim Schnitt auf *Aktiv —
Auflösung fällig*
(`git show 32f12dd:docs/plan/carveouts/CO-003-mutate-ohne-zeitschranke.md | grep -c '^\*\*Status:\*\* Aktiv'`
→ **1**; dasselbe `grep` über der bewegten Datei an HEAD → **0**, Exit 1). Der Architect hat am
2026-08-28 entschieden: die Wort-Bedingung gestrichen, die
verbleibenden zwei Bedingungen eingetreten, der zweite Ausgang (Überführung in eine ADR) verneint;
Modul-7-Übergang *aufgelöst*. Was fehlt, ist die Handlung, die Modul 7 §Carveout-Audit-Slice dem
Implementer zuweist — *„Implementer führt `git mv` und Config-Updates aus"*. Solange sie
aussteht, sagt die Verzeichnis-Position das Gegenteil der Entscheidung, und ein Carveout, dessen
Ort seiner Aussage widerspricht, ist genau die Doku-Drift, gegen die der Mechanismus steht.

**Eine Gate-Ausnahme ist nicht auszubauen, und das ist gemessen, nicht angenommen.**
[`CO-003`](../../carveouts/done/CO-003-mutate-ohne-zeitschranke.md) §Geltungs-Konfiguration sagt es
selbst — *„Keine Gate-Konfiguration trägt eine Ausnahme für diesen Carveout"* —, und der Kopf
nennt als betroffenes Gate **keines**: `make mutate` ist Nicht-Gate-Verify. Der Slice fasst
darum weder [`Makefile`](../../../../Makefile) noch [`.d-check.yml`](../../../../.d-check.yml) an.

### Der Move geht eine Ebene tiefer — daran unterscheidet er sich vom Move eines Slice

Ein Slice wandert `in-progress/` → `done/`: **gleich tief**, seine eigenen `../`-Links tragen
unverändert, nur die eingehenden Verweise brechen. Der letzte solche Zug ist gemessen und
committet (`ba5c07f`, *„32 Verweise ueber 6 Dateien, zwei Formen"*). Dieser Move geht
`docs/plan/carveouts/` → `docs/plan/carveouts/done/` — **eine Ebene tiefer**, und damit brechen
**beide** Richtungen:

| Richtung | Fläche | Kommando |
|---|---|---|
| **ausgehend** (die Links der Datei selbst) | **40** Ziele, alle relativ — Stand des Schnitts; beim Move waren es **45**, an HEAD **47** | `git show 32f12dd:docs/plan/carveouts/CO-003-mutate-ohne-zeitschranke.md \| grep -o '](\([^)]*\))' \| grep -vc '](http'`; für die zwei anderen Stände `dbe5e50:…/done/…` bzw. der Pfad ohne `git show` |
| **eingehend**, Form *Markdown-Link* | **29** Vorkommen über **7** Dateien — Stand des Schnitts | `git grep -ho '](\([^)]*\)CO-003-mutate-ohne-zeitschranke\.md)' 32f12dd -- 'docs/*.md' \| wc -l`; die Datei-Zahl über `git grep -lo …` derselben Form |
| **eingehend**, alle Nennungen | **9** Dateien — Stand des Schnitts | `git grep -ln 'CO-003' 32f12dd -- '*.md' ':!.harness' \| grep -v 'CO-003-mutate' \| wc -l` |

**Die eingehende Fläche zählt diesen Plan mit, und der Rev-Pin ist dafür da.** **8** der **29**
Vorkommen stehen in dieser Datei selbst
(`git grep -co '](\([^)]*\)CO-003-mutate-ohne-zeitschranke\.md)' 32f12dd -- 'docs/*.md'`, Zeile
`…/slice-120-co-003-wird-vollzogen.md:8`) — wer die Fläche misst, **bevor** er den Plan schreibt,
misst eine Menge, der er gleich beitritt. `32f12dd` ist der Commit, der den Plan schreibt; über ihm
gelten die drei Zahlen oben.

Die ausgehende Hälfte zerfällt in zwei Klassen, die verschieden zu ziehen sind: **zehn**
eindeutige `../`-Ziele (`grep -o '](\.\./[^)#]*' … | sed 's/^](//' | sort -u | wc -l`) bekommen
je ein `../` mehr, und **fünf** Geschwister-Links (`CO-001-bats-shell-lint.md` viermal,
`README.md` einmal) sind nach dem Move keine Geschwister mehr. Alle Zahlen wandern mit ihrem
Bestand und sind **kein** Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Die Lücke zwischen 9 und 7 ist keine Nachlässigkeit, sondern eine gemessene Ausnahme.** Die zwei
Verifikations-Berichte unter `docs/reviews/` nennen `CO-003` in **keiner** Link-Form
(`git grep -ho '](\([^)]*\)CO-003-mutate-ohne-zeitschranke\.md)' 32f12dd -- docs/reviews/2026-08-27-slice-117-verify.md docs/reviews/2026-08-27-slice-117-verify-runde2.md | wc -l`
→ **0**); die eine Pfad-Nennung als Inline-Code deckt `codepaths.exempt-paths:
["docs/reviews/**"]` in [`.d-check.yml`](../../../../.d-check.yml) — die Ausnahme, die genau für
alternde Lifecycle-Pfade in Zeitdokumenten da ist
([`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)).
**Was sie nicht deckt, ist die Link-Form:** `docs/reviews/**` ist für `ids` und `codepaths`
ausgenommen, für `links` **nicht**. Die zwei Review-Berichte derselben Runde tragen deshalb **3**
bzw. **2** Links (dasselbe Kommando je Datei über `32f12dd`) und werden gezogen, die zwei
Verifikations-Berichte bleiben unangetastet. Dieselbe Trennung hat `ba5c07f` gemessen und mit
einer Gegenprobe belegt.

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

- [x] **(1) Die Datei liegt am neuen Ort, und beide Register sagen es.** Verzeichnis-Position und
      Carveout-Index stimmen überein; der Move ist ein **eigener** Commit ohne Inhaltsänderung
      ([`AGENTS.md`](../../../../AGENTS.md) §3.3).
      **Rot:** `ls docs/plan/carveouts/CO-003-*.md` → heute **ein** Treffer, danach Exit 1;
      `sed -n '/^## Aktiv/,/^## Permanent/p' docs/plan/carveouts/README.md | grep -c 'CO-003'` →
      heute **1**, danach **0**;
      `sed -n '/^## Aufgelöst/,$p' docs/plan/carveouts/README.md | grep -c 'CO-003'` → heute
      **0**, danach **1**. Bewegt sich nur eine der drei Antworten, widersprechen sich Ort und
      Index.
- [x] **(2) Kein Verweis zeigt ins Leere, und der Beleg dafür ist ein rot gesehener Lauf.** Die
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
- [x] **(3) Der Kopf des Carveouts und seine Verifikations-Checkliste sagen dasselbe wie sein
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
| [`docs/plan/carveouts/done/CO-003-mutate-ohne-zeitschranke.md`](../../carveouts/done/CO-003-mutate-ohne-zeitschranke.md) | `git mv` **und** update, in **zwei** Commits | der Move nach `done/`; danach Kopf, Verifikations-Checkliste und die 40 ausgehenden Ziele. Getrennt, sonst fällt die Rename-Detection unter die Similarity-Schwelle ([`AGENTS.md`](../../../../AGENTS.md) §3.3) |
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
[`CO-003`](../../carveouts/done/CO-003-mutate-ohne-zeitschranke.md) nennt heute keine ID —
`git show 32f12dd:docs/plan/carveouts/CO-003-mutate-ohne-zeitschranke.md | grep -c 'slice-120'` → **0**; der Carveout
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
- **`docs/plan/carveouts/done/` entsteht mit dem ersten der beiden fälligen Carveouts, und das ist
  dieser.** [slice-113](../open/slice-113-co-001-ist-faellig.md) findet das Verzeichnis vor; der
  Index-Abschnitt *Aufgelöst* bekommt von jedem eine Zeile. Kein Konflikt — aber auch keine
  Reihenfolge-Annahme in eine der beiden Richtungen: welche Spalten der Abschnitt führt, entscheidet
  nicht der zweite Vollzug, sondern die Rolle, der das Register gehört (§7).
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

**Was gilt.** [`CO-003`](../../carveouts/done/CO-003-mutate-ohne-zeitschranke.md) liegt in
`docs/plan/carveouts/done/`, der Index führt die Zeile unter *Aufgelöst*, der Kopf sagt
*Aufgelöst*, die Verifikations-Checkliste ist vollständig gehakt
(`grep -c '^- \[x\] '` über der bewegten Datei → **7**, `grep -c '^- \[ \] '` → **0**, Exit 1), und
kein Verweis zeigt ins Leere (`make docs-check` → `424 Datei(en) geprüft, 0 Befund(e)`, Exit 0;
die Dateizahl wandert mit dem Markdown-Bestand und ist **kein** Erwartungswert). Was der Slice zu
tun hatte, ist getan.

**Was ihn teuer gemacht hat, war nichts davon.** Der Reviewer schreibt es in einem Satz, und die
Verifikation misst dasselbe unabhängig: *„die handwerklich schwierigen Teile des Slice sind
fehlerfrei … Was bricht, sind ausnahmslos Behauptungen **über** die Arbeit, nicht die Arbeit."*
Die Ebenen-Transformation über 44 Ziele, der rot gesehene Zwischenlauf und die Aufteilung 44/28
haben zwei unabhängigen Nachmessungen standgehalten. Gebrochen sind fünf Tatsachenbehauptungen in
zwei Commit-Messages.

### DoD-Verdikt, Punkt für Punkt

**(1) ERFÜLLT.** Alle drei Rot-Kommandos selbst gefahren, alle drei Antworten haben sich bewegt:
`ls docs/plan/carveouts/CO-003-*.md` → kein Treffer; der *Aktiv*-Abschnitt des Index nennt `CO-003`
**0**-mal, der *Aufgelöst*-Abschnitt **1**-mal (die zwei `sed -n … | grep -c 'CO-003'` aus §2). Der
Move ist ein eigener Commit ohne Inhaltsänderung: `dbe5e50` ist `R100`, und der Blob ist beidseits
identisch (`git rev-parse dbe5e50^:…` und `git rev-parse dbe5e50:done/…` →
`d280f3961fb75754c2884798b56343d4ee9cf814`). **Eine Ziffer im Plan trifft nicht:** `ls` liefert für
den fehlenden Pfad Exit **2**, nicht die vorhergesagte **1** — dieselbe Aussage („kein Treffer"),
anderer Code. Sie bleibt stehen, und der Grund steht unten bei den offenen Posten.

**(2) ERFÜLLT — in fünf von sechs Teilen zur rechten Zeit, im sechsten nachgeholt.** Der Punkt ist
zusammengesetzt, und jede Hälfte hat ihren eigenen Beleg:

| Teilzusage | Stand | Beleg |
|---|---|---|
| kein Verweis zeigt ins Leere | **erfüllt** | eigener Lauf, `424/0`, Exit 0 |
| ein rot gesehener Lauf **nach** dem `git mv` | **erfüllt** | `dbe5e50` extrahiert und nachgefahren: `422 Datei(en), 72 Befund(e)`, Exit 2 — von Review **und** Verifikation unabhängig auf die Ziffer reproduziert |
| beide Richtungen gemeldet | **erfüllt** | 44 ausgehend, 28 eingehend über 8 Dateien, alle `target-missing` |
| erst danach gezogen, in einem zweiten Commit | **erfüllt** | `dbe5e50` → `48c2063` |
| die zwei Verifikations-Berichte unangetastet | **erfüllt am Ergebnis, verletzt im Verlauf** | `48c2063` änderte `…-verify.md:618`; `75ba487` hat es zurückgedreht. Die Datei ist über `32f12dd`, `dbe5e50` und HEAD **derselbe Blob** (`e05a42f37e11f7b0faf85d3593560c8cab388c7a`, `git rev-parse <rev>:<datei>` bzw. `git hash-object <datei>`) |
| **gegen die Fläche aus §1 gehalten** | **nicht zu seiner Zeit** | der Abgleich hat im Slice nicht stattgefunden; sein Ergebnis steht seit dieser Closure in §1 |

Die **zeitliche** Hälfte der zweiten Zeile ist gestützt und nicht bewiesen, und das bleibt so: dass
der Lauf **in jenem Moment** und **vor** dem Nachziehen fiel, trägt ein Drei-Minuten-Fenster
(`dbe5e50` 05:30:45, `48c2063` 05:33:46) und die Übereinstimmung von vier Zahlen, die niemand rät —
kein Protokoll mit Zeitstempel. Wer sie beweisen will, braucht eines; für diesen Lauf gibt es
keines.

**(3) ERFÜLLT.** Über der bewegten Datei: `grep -c '^\*\*Status:\*\* Aktiv'` → **0** (Exit 1),
`grep -c '^- \[ \] '` → **0** (Exit 1), auch mit beliebiger Einrückung
(`grep -cE '^[[:space:]]*- \[ \] '` → **0**). Es gibt also keinen ausgelassenen Punkt, der einen
Grund an seiner Zeile tragen müsste. **Die „heute 4" des Rot-Kommandos war richtig, als sie
geschrieben wurde** — `git show 32f12dd:docs/plan/carveouts/CO-003-…md | grep -c '^- \[ \] '` →
**4**; dieselbe Zeile über `6bbea9f` und `dbe5e50` → **3**, weil der Architect einen Haken früher
gesetzt hat. Die Zahl ist zwischen Schnitt und Vollzug gealtert, nicht falsch gemessen worden.

### Der Closure-Trigger aus §5, Zeile für Zeile

| Bedingung | Stand | Beleg |
|---|---|---|
| DoD (1)–(3) mit gefahrenen Kommandos | **erfüllt** | oben, alle selbst gefahren |
| `make gates` grün | **erfüllt** | eigener Lauf, unten |
| `make mutate` ohne Befund über dem Baum, der den Move trägt | **erfüllt laut Protokoll** — **198 ok, 0 Befund(e)**, 788,76 s über `48c2063` | nicht selbst gefahren (Auflage). Die Zuordnung zum Baum ruht auf zwei übereinstimmenden Uhren, nicht auf einem Feld im Protokoll — die Verifikation nennt das *Indizienlage* und hat recht |
| Review (Modul 10) und Verifikation (Modul 11) ohne blockierenden Befund | **erfüllt für alles, was herstellbar war** | von fünf blockierenden Positionen sind **drei** behoben (F-2, F-3, F-4), **eine** am Ergebnis geheilt (F-1/V-1), **eine** unbehebbar (F-0/V-4, gepushte Message). Die unbehebbare steht unten |
| Closure-Notiz in §7 mit Steering-Loop-Eintrag | **dieser Zug** | — |

**Die vierte Zeile verdient ihren eigenen Satz.** Ein blockierender Befund blockiert, bis er
behoben ist — oder bis seine Behebung unmöglich ist und **das** aufgeschrieben steht. Eine gepushte
Commit-Message ist kein Gegenstand, den ein Slice noch ändert; was hier bleibt, ist die Wahl
zwischen *aufschreiben* und *vergessen*. Sie steht unten, mit Fundort und Kommando.

### Was anders lief als geplant

**Fünf Tatsachenbehauptungen in zwei Commit-Messages hielten ihrem eigenen Kommando nicht stand,
drei davon in einer einzigen Message.** Der Reviewer stellt die Klasse so: *„eine trivial
überprüfbare Tatsachenbehauptung, die niemand vor dem Commit gegen ihr eigenes Kommando gehalten
hat."* Keine von ihnen betrifft den Baum; jede betrifft die Auskunft **über** den Baum, und genau
die liest der nächste Lauf, statt sie nachzumessen.

**Der Plan hat eine Fläche gemessen, der er gleich beitrat.** Die §1-Zahlen `20/6/8` galten über
`60b438b`, zwei Commits vor `32f12dd` — und `32f12dd` ist der Commit, der den Plan **schreibt**.
Der Plan legte **8** eigene Links auf `CO-003` an
(`git grep -co '](\([^)]*\)CO-003-mutate-ohne-zeitschranke\.md)' 32f12dd -- 'docs/*.md'`, Zeile
`…/slice-120-co-003-wird-vollzogen.md:8`), womit die Fläche auf **29** über **7** wuchs, bevor
irgendjemand sie las. Das ist keine Schlamperei an der Ziffer, sondern eine **Rückkopplung, die die
Messung nicht kannte** — dieselbe Klasse wie
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1, nur schwerer zu sehen: das Kommando war richtig, der Baum war richtig, und trotzdem galt
das Ergebnis nicht mehr, als es gebraucht wurde. §1 trägt die drei Zahlen jetzt an `32f12dd`
gepinnt, mit `git grep <rev>` statt `grep -r` — ein Kommando, das seinen Baum benennt, kann nicht
still den falschen messen.

**Ein `d-check:ignore`-Marker war nicht wirkungslos, sondern aktiv — das ist gemessen, nicht
geschätzt.** Der Review führt vier Marker mit dem Grund *„done/ entsteht erst bei erster
Carveout-Auflösung"* und schätzt sie als *„heute wirkungslos"* ein. Die Gegenprobe zeigt das
Gegenteil: hängt man an die zwei zuvor unterdrückten Zeilen je einen Inline-Code-Pfad auf ein
Unterverzeichnis unter `docs/plan/carveouts/`, das es nicht gibt, meldet `make docs-check`
**2 Befunde** (`codepath-missing`, beide Zeilen); wird **ein** Marker wieder gesetzt, meldet
derselbe Lauf **1** — die unterdrückte Zeile verschwindet lautlos.
Eine Suppression, deren Grund veraltet ist, deckt also ab sofort jede künftige Falschschreibung
derselben Zeile. Herkunft: die Zeile stammt aus der **vendored Vorlage**
(`.harness/baseline/v3.5.2/templates/docs/plan/carveouts/carveout.template.md:67`), wo ihr Grund
weiter gilt — in einem frischen Repo gibt es `done/` wirklich nicht. Hier gilt er seit `dbe5e50`
nicht mehr.

**Die Sonde selbst hätte kein Gate gefangen.** Für die Gegenprobe oben standen zwei tote Pfade
mitten in laufenden Sätzen dieses Plans; entfernt wurden sie durch Rückspielen einer Kopie und ein
ausdrückliches `grep`, nicht durch `make docs-check`. Der Grund steht in der Verifikation §3.2:
`codepaths` prüft **keine Globs** — ein `test/mutations-GIBTESNICHT/*.sh` blieb dort grün. Wer eine
Sonde setzt, braucht seinen eigenen Rückweg; das Gate ist keiner.

### Die offenen Posten und ihr Ausgang

Vier Ausgänge sind zulässig — *diagnostiziert* · *als Eigenschaft ausgewiesen* · *abgelehnt mit
Grund* · *aufgeschoben mit beobachtbarem Trigger*. **„Genannt" ist keiner.** Jede Zeile trägt ihren
Stand mit dem Kommando, das ihn liefert.

| Posten | Stand (Kommando) | Ausgang |
|---|---|---|
| **§1 maß die eingehende Fläche über einem Baum, den der Plan-Commit noch änderte** (V-2) | die drei Zahlen an `32f12dd` nachgemessen: **29** / **7** / **9** (die Kommandos stehen in §1, jetzt mit Rev-Pin) | **diagnostiziert und behoben.** Ursache ist die Rückkopplung oben, nicht die Ziffer |
| **Die §4-Rückführung `in-progress` → `next` ist eingetreten und wurde nicht vollzogen** | der Zwischenlauf meldete auf jeder Achse mehr als §1 (44>40, 28>20, 7>6, 9>8) | **diagnostiziert.** Ihr ausdrücklicher Zweck — *„zuerst zu klären, warum die Messung zu klein war"* — ist mit der Fünf-Stände-Messung der Verifikation und der Selbstbezugs-Messung oben eingelöst. Ein Rücksprung jetzt öffnete einen grünen Slice, um eine Klärung zu wiederholen, die vorliegt; §4 sieht dafür selbst *„zwei Landungen"* vor, und das ist die zweite |
| **`48c2063` nennt den Move-Commit `0f8d1a1`, den es nicht gibt** (F-0/V-4) | `git rev-parse -q --verify 0f8d1a1^{commit}` → Exit **1**; der Move ist `dbe5e50` | **als Eigenschaft der Historie ausgewiesen.** Gepusht und nicht änderbar. Über alle sechs Messages und neun Dateien geprüft: genau **ein** nicht auflösbarer Commit-Verweis. Der Sensor dafür ist der Steering-Loop-Eintrag unten |
| **`48c2063` sagt zu, zwei Dateien nicht anzufassen, und fasst eine davon im selben Commit an** (F-1) | `git show --stat 48c2063 \| grep -c 'slice-117-verify\.md'` → **1** | **als Eigenschaft der Historie ausgewiesen** — die Message bleibt falsch über ihren eigenen Diff. **Das Ergebnis ist geheilt:** die Datei ist über `32f12dd`, `dbe5e50` und HEAD derselbe Blob (oben) |
| **`48c2063` rechnet 4 − 2 = 1** (F-7) | Ist-Stand am Eltern-Commit war **3** (`git show dbe5e50:… \| grep -c '^- \[ \] '`); mit 3 stimmt die Rechnung | **als Eigenschaft der Historie ausgewiesen.** Dieselbe Message, dieselbe Klasse |
| **`1f0a4a0` beruft sich auf [`AGENTS.md`](../../../../AGENTS.md) §3.8 für *„der Carveout ist Architect-Artefakt"* und beziffert die Präzedenz falsch** (F-8) | §3.8 Absatz 2 sagt ausdrücklich, dass er über andere Norm-Artefakte **nichts** sagt; die tragende Quelle ist Modul 7 §Carveout-Audit-Slice. Von 56 Link-Abgleich-Commits fassen **8** (bzw. **5** mit dem Wort in der Betreffzeile) Carveouts an, nicht **2** | **als Eigenschaft der Historie ausgewiesen.** Die *Zuordnung* trägt — Modul 7 weist zu, und der Review bestätigt sie als Negativbefund; falsch ist allein die genannte Quelle und die Zahl daneben |
| **Der Index verlor beim Verschieben die Spalte *Betroffenes Gate*** (F-10) | die drei Abschnitte führen drei Spaltensätze (`sed -n '14,16p;26,28p;32,34p' docs/plan/carveouts/README.md`); die Angabe *„keines (`make mutate` ist Nicht-Gate-Verify)"* steht in **keiner** Zeile mehr, obwohl der Kopf des Carveouts sie *„die erste Aussage dieses Carveouts"* nennt | **Übergabe an den Architect** (unten). Kein Template-Verstoß — die Vorlage gibt für *Aufgelöst* keine Form vor, und wer die erste Auflösung schreibt, legt sie für jede weitere fest |
| **Index-Titel in Vergangenheit, H1 der Quelle in Gegenwart** (F-5) | `head -1 docs/plan/carveouts/done/CO-003-*.md` gegen `sed -n '34p' docs/plan/carveouts/README.md`; bei `CO-001` und `CO-002` stimmen beide zeichengleich überein | **Übergabe an den Architect**, dieselbe wie F-10 — es ist dieselbe Frage („was sagt der *Aufgelöst*-Abschnitt") in der Titel-Achse |
| **Der Index-Kopf sagt weiter voraus, was dieser Slice getan hat** (F-6) | `sed -n '6,7p' docs/plan/carveouts/README.md` gegen `test -d docs/plan/carveouts/done`; **daneben** eine zweite Stelle, die kein Befund nennt: `sed -n '9,10p' …` (*„Dieses Verzeichnis kehrt mit dem ersten realen Carveout zurück"* — es sind drei da) | **Übergabe an den Architect**, dieselbe wie F-10. Der zweite Fundort steht dabei, weil ein Befund einen Fundort nennt und keine Fundmenge |
| **Vier `d-check:ignore`-Marker führen einen Grund, den dieser Slice aufgehoben hat** (F-9) | die drei in diesem Plan und der eine in [slice-113](../open/slice-113-co-001-ist-faellig.md) sind entfernt: `grep -rn 'd-check:ignore (done/' --include='*.md' docs/plan/ \| grep -v 'slice-120-co-003' \| wc -l` → **3**, nämlich `carveouts/CO-001-…:86`, `carveouts/done/CO-003-…:205` und `planning/done/welle-12-results.md:312` (der Ausschluss gilt dieser Datei, die den Marker-Text zitiert und sich sonst selbst zählte); die Wirksamkeit ist rot gesehen (oben) | **teils behoben, teils Übergabe.** Behoben, wo der Marker in einem Planner-Artefakt steht; **Übergabe an den Architect** für die zwei im Carveout-Register. `welle-12-results.md` bleibt: Zeitdokument, wird per Definition nicht nachgezogen |
| **Zuständigkeit für Link- und Kommando-Pflege in fremden Rollen-Verzeichnissen** (F-11) | die Übergabe-Tabelle des Carveouts sagt *„Schnitte und `docs/plan/planning/**` gehören dem Planner"*, und der Implementer hat dort in `48c2063` **vier** Dateien angefasst, davon zwei Mess-Kommandos; [`AGENTS.md`](../../../../AGENTS.md) §3.8 Absatz 2 lässt die Frage ausdrücklich offen | **Übergabe an den Architect** (unten). Der Reviewer hat dafür bewusst keine Regel erfunden, und diese Notiz erfindet auch keine |
| **Der Reviewer fuhr für eine Pfad-Normalisierung `python3` auf dem Host** | offengelegt im Kopf seines Berichts; kein Check, kein Build, kein Gate, und kein `make`-Ziel deckt den Schritt | **abgelehnt mit Grund** — kein §3.9-Verstoß: die Aufzählung der Regel nennt Paketmanager und Host-Toolchains, der PreToolUse-Guard nimmt andere Interpreter ausdrücklich aus, und die Sätze der Regel binden *Checks, Builds und Gates*. **Mit einer benannten Grenze:** das Ergebnis stützt genau einen **Negativbefund** (die Pfad-Erhaltung über 44 Ziele) und keinen Befund und kein Verdikt; auf einem Host mit nur `git`, `docker` und `make` ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)) ist es nicht wiederholbar. Wiederholt sich der Fall, ist die Antwort ein `make`-Ziel, keine breitere Lesart von §3.9 |
| **`ls` liefert Exit 2, das Rot-Kommando in §2 DoD (1) sagt Exit 1** | selbst gefahren: `ls docs/plan/carveouts/CO-003-*.md; echo $?` → **2** | **diagnostiziert, nicht nachgezogen.** §2 ist der **Vertrag** dieses Slice; ihn nach dem Urteil nachzuschärfen wäre zirkulär, auch bei einer Ziffer. §1 dagegen ist Messung und fällt unter [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) — daher der Unterschied in der Behandlung |
| **Kein Sensor für *„kein aktiver Carveout trägt einen eingetretenen Trigger"*** | `git grep -c 'CO-00' -- Makefile .d-check.yml d-check.mk .github/` → Exit 1; [`.d-check.yml`](../../../../.d-check.yml) führt sechs Module, keines liest `docs/plan/carveouts/` | **aufgeschoben mit Trigger.** Der Träger ist [slice-113](../open/slice-113-co-001-ist-faellig.md) §6, wo dieselbe Frage aus der Audit-Richtung offen steht; der Auflösungs-Trigger ist dessen Schnitt-Entscheidung. Getragen wird die Aussage heute vom Welle-Closure-Audit, also von einer Rolle |

### Steering-Loop-Eintrag — neuer Sensor

**Eine Commit-Message ist der einzige Zusage-Träger aus [`AGENTS.md`](../../../../AGENTS.md) §3.6,
den nach dem Push kein Lauf mehr korrigieren kann — und der einzige, den kein Sensor liest.**

**Der gemessene Anlass.** Fünf Behauptungen in zwei Messages, drei davon in einer. Jede wäre von
einem Kommando widerlegt worden, das der schreibende Lauf zur Hand hatte: `git rev-parse`,
`git show --stat`, `grep -c`. Gefunden hat sie eine zweite Rolle — dieselbe Diagnose, die
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
§Begründung für sich selbst stellt, und die Runde-2-Review zu
[slice-117](../done/slice-117-lauf-ohne-ende-faerbt-rot.md) hat die Klasse **am selben Gegenstand**
schon einmal gemeldet.

**Warum ein Sensor und keine geschärfte Regel.** Die Regel gibt es:
[`AGENTS.md`](../../../../AGENTS.md) §3.6 nennt die Commit-Message beim Namen. Was fehlt, ist die
Stelle, an der ihre Verletzung sichtbar wird, ohne dass eine zweite Rolle sie sucht. Und die
Regel-Hälfte, die noch fehlt, gehört ohnehin nicht hierher, sondern in eine Übergabe (unten) —
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
bindet **lebende Markdown-Artefakte**, und eine Commit-Message ist keines, obwohl seine eigene
Begründung eine als Fundort führt.

**Kein Sensor dieses Repos liest eine Commit-Message, und das ist gemessen:**
`git grep -lnE 'git (log|show|cat-file).*(%B|--format=.%s)|commit-msg|COMMIT_EDITMSG' -- Makefile d-check.mk .d-check.yml harness/tools/ .claude/hooks/ .codex/ .github/ test/`
→ **kein Treffer** (Exit 1).

**Die Fläche, mit ihrer Eigenschaft vor der Zahl, und der Cutoff gehört in den Schnitt.** Die
Eigenschaft: *ein Token in einer Message, das wie ein Kurz-Hash aussieht und keinen Commit
bezeichnet*. Über die ganze Historie: **1060** Commits (`git rev-list --count HEAD`), **217** mit
einem Hex-Token in der Message, **55** nicht auflösbare Token über **46** Commits, ohne reine
Dezimalzahlen **46** über **39**. **Die Längen-Verteilung entscheidet den Schnitt:** **37** der 46
sind achtstellig und damit **Digest-Fragmente** aus Pin-Commits, keine Commit-Verweise. In der
siebenstelligen Achse — der Kurzform, die dieses Repo schreibt — sind es **6** Vorkommen über **5**
Commits, davon **3** ursprüngliche Fehler und **2** Läufe, die einen davon als Befund **zitieren**.
Ein Maßstab über der ganzen Historie wäre also an fünf Commits dauerhaft rot, zwei davon zu
Unrecht; welche Achse und welcher Cutoff, ist deshalb **DoD-Punkt des Slice und nicht seine
Voraussetzung** — dieselbe Begründung, mit der
[`AGENTS.md`](../../../../AGENTS.md) §3.7 seinen Cutoff trägt.

**Träger:
[slice-121](../open/slice-121-commit-message-nennt-was-es-gibt.md)**, neu in `open/`, mit den
Zahlen oben als Ausgangslage, dem Cutoff als eigenem DoD-Punkt und der Ortsfrage — ein Sensor für
eine Message muss **vor** dem Commit greifen, sonst meldet er rot an einem Gegenstand, den niemand
mehr grün machen kann. Der Slice deckt **eine** der fünf gemessenen Instanzen; das steht in seinem
§1 und gehört in seine Meldung. Ein Lerneintrag, der nur hier stünde, würde nie wieder gelesen —
der Träger ist der Grund, aus dem dieser Eintrag ein Eintrag ist und keine Beobachtung.

### Übergaben an den Architect — drei

Keine davon ist hier geschrieben. Was übergeben wird, ist jeweils die **Entscheidung**, mit der
Messung daneben, damit sie ohne neue Erhebung fallen kann.

**1 — Bindet [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
eine Commit-Message?** Sein §Geltungsbereich nennt *„die **lebenden**, repo-eigenen
Markdown-Artefakte"*; eine Commit-Message ist keines. Seine eigene §Begründung führt dagegen als
einen von drei Fundorten der Klasse ausdrücklich *„eine Commit-Message"*. Regel und Begründung
sagen an dieser Stelle Verschiedenes, und dieser Slice liefert fünf weitere Instanzen genau dort.
Die zweite Hälfte derselben Frage: [`AGENTS.md`](../../../../AGENTS.md) §3.6 führt vier
Zusage-Träger, und drei von ihnen haben einen Sensor (`make comment-claims` für den Doc-Kommentar,
`make mutate` für den Test-Namen, Modul 11 für den DoD-Punkt — eine Rolle, kein Gate); der vierte
hat keinen. Ob das als **benannte Lücke** in die Regel gehört, wie §3.7 und §3.8 ihre Lücken
benennen, ist dieselbe Entscheidung. **Berührt:** [`AGENTS.md`](../../../../AGENTS.md) §3 und
[`harness/conventions.md`](../../../../harness/conventions.md) — beides Architect-Artefakte
([`AGENTS.md`](../../../../AGENTS.md) §3.8).

**2 — Welche Form hat der *Aufgelöst*-Abschnitt des Carveout-Index, und was gehört ins Register?**
Vier Posten, alle in `docs/plan/carveouts/`: die fehlende Spalte *Betroffenes Gate* (F-10), der
Titel in Vergangenheit gegen die H1 in Gegenwart (F-5), der Kopf, der die Entstehung von `done/`
weiter voraussagt (F-6, mit einer zweiten Stelle daneben), und die zwei `d-check:ignore`-Marker mit
totem Grund in `CO-001:86` und `CO-003:205` — deren Wirksamkeit oben rot gesehen ist und deren
Herkunft die vendored Vorlage ist. **Warum nicht der Planner:** Modul 7 gibt dem Implementer
*„`git mv` und Config-Updates"* und dem Planner die Identifikation der fälligen Carveouts; die
**Form eines Register-Abschnitts** ist keines von beidem, und wer sie bei der ersten Auflösung
setzt, setzt sie für jede weitere. **Der natürliche Termin** ist vor
[slice-113](../open/slice-113-co-001-ist-faellig.md) — er vollzieht die zweite Auflösung und würde
die Form sonst als Implementer nebenbei entscheiden, also genau in der Lage aus Übergabe 3.

**3 — Wem gehört die Link- und Kommando-Pflege in einem fremden Rollen-Verzeichnis?** Der
Link-Abgleich nach einem Move fasst notwendig Dateien anderer Rollen an; die Übergabe-Tabelle von
[`CO-003`](../../carveouts/done/CO-003-mutate-ohne-zeitschranke.md) sagt *„Schnitte und
`docs/plan/planning/**` gehören dem Planner"* und im selben Absatz, dass der Abgleich *„Dateien
anfasst, die anderen Rollen gehören"*. [`AGENTS.md`](../../../../AGENTS.md) §3.8 Absatz 2 lässt die
Frage ausdrücklich offen. In diesem Slice hat sie sich bewegt: aus dem reinen Pfad-Zug wurde in
`48c2063` ein Zug **innerhalb von Mess-Kommandos** in Planner-Dateien — und dort war er falsch, weil
die Zahl daneben nicht mitgezogen wurde (F-3). Die Grenze zwischen *Pfad nachziehen* und *Messung
ändern* ist der Gegenstand, nicht die Rolle als solche. Ein Sensor existiert nicht: kein Modul von
[`.d-check.yml`](../../../../.d-check.yml) liest Commits.

### Folge-Slices und Register

**Ein neuer `open/`-Eintrag**, ohne Welle
([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 — sein Zustand ist das Verzeichnis, nicht die Roadmap):
[slice-121](../open/slice-121-commit-message-nennt-was-es-gibt.md), der Steering-Loop-Eintrag oben.

**Ein Register-Eintrag ist abgeschlossen.**
[`CO-003`](../../carveouts/done/CO-003-mutate-ohne-zeitschranke.md) ist **aufgelöst** und liegt in
`done/`; die Geschichte-Tabelle trägt den Vollzug, der Index führt die Zeile unter *Aufgelöst*.
**[`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) bleibt fällig** und ist nicht Gegenstand
dieses Zugs; sein Vollzug ist [slice-113](../open/slice-113-co-001-ist-faellig.md), der das
Verzeichnis jetzt vorfindet.

**Ein Zug an einem fremden Plan, und er ist klein.** In
[slice-113](../open/slice-113-co-001-ist-faellig.md) ist der `d-check:ignore`-Marker mit dem
aufgehobenen Grund entfernt — ein Planner-Artefakt, dessen Suppression nach der Gegenprobe oben
aktiv ist und dessen Gegenstand genau die nächste Auflösung ist. `make docs-check` bleibt danach
grün (`424/0`).

### Gates

Eigener Lauf über dem Baum, den diese Closure hinterlässt: `make gates` **EXIT=0**. `make mutate`
ist **nicht** gefahren (Auflage); der frische Lauf über `48c2063` meldet **198 ok, 0 Befund(e)** bei
788,76 s, und dieser Zug bewegt nur Markdown — von **45** eindeutigen `# files:`-Zielen in
`test/mutations/` liegt **0** unter `docs/`
(`sed -n 's/^# files: //p' test/mutations/*.sh | tr ' ' '\n' | sort -u | grep -c '^docs/'`, Exit 1).
Alle Zahlen sind Messungen, keine Schwellen
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example). Ein Begründungsblock
entfällt: der Slice berührt keine Sub-Area in BF oder Hybrid, öffnet keinen Gate-Prüfbereich und
legt keine neue Sub-Area an. Was er bewegt, sind Verzeichnis-Positionen und Link-Ziele unter
`docs/plan/` — ein Bereich, den `make docs-check` in jedem `make gates`-Lauf vollständig prüft.
