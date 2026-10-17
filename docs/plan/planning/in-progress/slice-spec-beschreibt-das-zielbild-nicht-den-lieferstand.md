# Slice slice-spec-beschreibt-das-zielbild-nicht-den-lieferstand: Lastenheft und Architektur-Sicht sagen, was gilt, nicht wann geliefert wird

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Es gibt keine Closure-Bedingung, die über die DoD dieses Slice hinausgeht
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) (Befund
Z. 122), [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) (Z. 172),
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (Z. 39),
[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (Grenz-Notiz, umformuliert nach Entscheidung 2026-10-17),
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
Setzung 2 (eigener Commit, vor dem Start),
[`MR-042`](../../../../harness/conventions.md#mr-042--der-anlass-einer-lastenheft-änderung-steht-nicht-in-der-historie-sondern-in-der-closure-notiz)
(Anlass in der Closure-Notiz),
[`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)
(Technik-Stratum; die Spezifikation führt keinen Befund der Klasse A).

**Berührte Spec-Stellen:** `spec/lastenheft.md` §1 ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)-Beschreibung), §3 ([`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4),
[`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)), §5 Globale Out-of-Scope-Punkte und — nach Entscheidung des Auftraggebers —
[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) · `spec/architecture.md` Kopf (Hard-Rule-Zeile) und §5 (Zeile zur a-check-Emission).
`spec/spezifikation.md` bleibt unberührt (Messung in §3 dieses Plans).

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-10-17.

---

## 1. Ziel und Abgrenzung

**Ziel:** Die drei Spec-Dateien beschreiben das **Zielbild** im Indikativ — was gilt, nicht wann etwas
geliefert wird oder wurde; die eindeutigen Zeit-/Liefer-Sätze außerhalb der Historien sind
bedeutungstreu umformuliert, und eine Messung zeigt, dass dort nur benannte, begründete Treffer
stehen bleiben. Auftrag des Auftraggebers vom 2026-10-17. Das Baseline-Regelwerk sagt dazu in
`modul-03-spec.md` allein für die Architektur-Sicht: *„Sprach- und meilensteinfrei — **darf** Pfade zu
**Code-Modulen** referenzieren (`src/service/`), aber **keine** Wellen, Slices, Commit-Hashes oder
Closure-Daten."* Für Lastenheft und Spezifikation führt der Text keine Aussage über Zeit- oder
Liefer-Sätze (Messung: `grep -niE 'Zielbild|Lieferstand|meilensteinfrei' .harness/baseline/v6.18.1/regelwerk/modul-03-spec.md`
liefert nur diese Zeile); der Slice stützt sich auf den Auftrag, nicht auf eine Regelwerk-Zeile.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Sprach-Liste `go`, `python`, `kotlin`, `java`, `csharp`, `cpp` (Z. 121) bleibt Zielbild.** Dass
  `python`, `java` und `csharp` kein Profil in `internal/gen/` tragen
  (`grep -n 'func profiles' -A 6 internal/gen/gen.go` nennt `go`, `cpp`, `kotlin`), ist ein Lieferstand und
  gehört in die Rückverfolgbarkeit (`make doc-trace`, `trace:` in [`.d-check.yml`](../../../../.d-check.yml)),
  nicht in den Vertrag — anderer Vorgang. Ein Eintrag dazu besteht nicht: weder
  [slice-192](../open/slice-192-rtm-sieht-alle-anforderungen.md) noch ein Verzeichnis unter
  `docs/plan/planning/observations/BEO-ALL/` nennt die Sprachen (`grep -rliE 'python|csharp' docs/plan/planning/observations/BEO-ALL/*/observation.md`
  → keine Datei).
- **Kein Sensor für Zeit-/Liefer-Sätze in Specs.** Ein Wortlisten-Sensor wäre baubar, trifft aber
  `Folgenummer` und `folgen` im Sinn von *entsprechen* und braucht eine Ausnahmeliste; das ist ein anderer
  Vorgang mit eigenem Schnitt. Empfehlung: Register-Eintrag bei der Closure (§7), ein Folge-Slice erst
  mit Auslöser nach `.claude/commands/plan-welle.md`.
- **Keine Entscheidung, welche Rolle `spec/architecture.md` und `spec/spezifikation.md` schreibt.**
  Die Frage ist offen und liegt bei [slice-151](../next/slice-151-spec-straten-haben-eine-schreibende-rolle.md);
  ein Spec-Nachzug lief bisher als Implementer-Commit im Slice. Dieser Slice übergibt die Frage und
  beantwortet sie nicht. Das Lastenheft ist davon nicht berührt: seine Änderungen tragen den eigenen
  Commit nach [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 2.
- **Keine Hard Rule.** Ob „Specs beschreiben das Zielbild" in `AGENTS.md` §3 gehört, schreibt der
  Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8); die Closure übergibt die Frage.
- **Die Historien bleiben unberührt** (`spec/lastenheft.md` §7, `spec/spezifikation.md` §8): ein Protokoll
  darf Zeit nennen und wird nicht rückwirkend geändert.
- **Der Rest der Datei bleibt, wie er ist.** Eine Umformulierung ändert keine Anforderung, keinen
  Akzeptanzkriterien-Anker und keine Überschrift; kein Anker-Nachzug.

## 2. Definition of Done

Liefer-Punkte (drei):

- [x] **(1) Umformulierung:** Jeder Befund der Klasse A und B (`LH` Z. 39) in §3 steht in `spec/lastenheft.md` und
      `spec/architecture.md` im Indikativ des Zielbilds; jeder Befund der Klasse C ist umformuliert (Entscheidung
      des Auftraggebers 2026-10-17). Der `LH`-Teil liegt im Commit `b7999710` (Lastenheft 0.27.0) und `d4e63263` (0.27.1), der
      `AR`-Teil (Kopf, §5, Z. 170) ist Arbeit des Implementers in diesem Slice.
- [x] **(2) CR-Eintrag:** `spec/lastenheft.md` trägt Version 0.27.1 und Historie-Zeilen 0.27.0 und 0.27.1 nach [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler): Verweis
      `Nutzer-Entscheidung 2026-10-17`, der Anlass steht nicht in der Zeile
      ([`MR-042`](../../../../harness/conventions.md#mr-042--der-anlass-einer-lastenheft-änderung-steht-nicht-in-der-historie-sondern-in-der-closure-notiz)),
      Stufe nach dem Präzedenz-Fall 0.15.0: Minor, weil ein normativer Abschnitt seine Aussage-Form ändert.
      Geliefert in den Commits `b7999710` (0.27.0) und `d4e63263` (0.27.1, Patch: zwei nachgezogene Stellen, Z. 100 und Z. 146); der Implementer prüft ihn, er schreibt ihn nicht neu.
- [x] **(3) Messbeleg mit Rot:** Die drei Messkommandos aus §3 zeigen nach der Änderung nur die in §3 als
      stehengelassen benannten Zeilen; ein einmal eingefügter Satz *„… folgt …"* im Rumpf lässt das
      Kommando um 1 steigen (Gegenprobe im Arbeitsbaum, danach zurückgenommen, nicht committet).

Pflichten, die mit dem Umfang nicht wachsen:

- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `spec/lastenheft.md` (Rumpf, Version, §7-Zeile) | update | Liefer-Punkte (1) und (2); eigener Commit nur dieser Datei, **vor** dem Start ([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 2) |
| `spec/lastenheft.md` Z. 100 ([`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), Architektur-Achse) | update | „das heutige Verhalten" → „das Verhalten ohne `--arch`"; Zeitbezug, vom Muster P1 nicht erfasst (`heutige`); Commit `d4e63263` |
| `spec/lastenheft.md` Z. 146 ([`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren), CLAUDE.md-Vorlage) | update | Klammersatz zur Herkunft der Vorlage entfällt: im vendored Baum liegt keine (`find .harness/baseline/v6.18.1/templates -iname '*claude*'` → leer), Z. 145 sagt „autort, nicht tool-generiert"; Commit `d4e63263` |
| `spec/architecture.md` (Kopf, §5) | update | Liefer-Punkt (1); Marker `**Letzte Änderung:**` mitziehen; die Architektur-Sicht führt keine Historie |
| `docs/plan/planning/done/slice-053-cpp-hexslice-renderer.md` | unberührt | zitiert den alten Wortlaut von Z. 641; ein Zeitdokument bleibt, wie es ist |

**Messkommandos** (Stand der Planung 2026-10-17, **keine Erwartungswerte** —
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) —
sie wandern mit dem Text; tragend ist, dass jede Zeile des Treffers in der Tabelle darunter steht).
Muster P1 = `folgt|folgen|künftig|später|noch nicht|geplant|vorerst|zunächst|bislang|derzeit|heute|aktuell|erst mit|nicht zugesagt|real ab v|noch kein|bisher|vorläufig|spätere`;
Muster P2 = `v[0-9]+\.[0-9]+|frühere`. Die Historien enden den Messbereich (`sed` bis zur Überschrift):

```sh
sed -n '1,/^## 7\. Historie/p' spec/lastenheft.md    | grep -cE 'folgt|folgen|künftig|später|noch nicht|geplant|vorerst|zunächst|bislang|derzeit|heute|aktuell|erst mit|nicht zugesagt|real ab v|noch kein|bisher|vorläufig|spätere'   # 9
sed -n '1,/^## 7\. Historie/p' spec/lastenheft.md    | grep -cE 'v[0-9]+\.[0-9]+|frühere'   # 3
sed -n '1,/^## 8\. Historie/p' spec/spezifikation.md | grep -cE 'folgt|folgen|künftig|später|noch nicht|geplant|vorerst|zunächst|bislang|derzeit|heute|aktuell|erst mit|nicht zugesagt|real ab v|noch kein|bisher|vorläufig|spätere'   # 3
sed -n '1,/^## 8\. Historie/p' spec/spezifikation.md | grep -cE 'v[0-9]+\.[0-9]+|frühere'   # 0
grep -cE 'folgt|folgen|künftig|später|noch nicht|geplant|vorerst|zunächst|bislang|derzeit|heute|aktuell|erst mit|nicht zugesagt|real ab v|noch kein|bisher|vorläufig|spätere' spec/architecture.md                                      # 5
grep -cE 'v[0-9]+\.[0-9]+|frühere' spec/architecture.md                                      # 1
```


**Befund-Einordnung** — Zeilennummern am Stand der Planung; die Zeile wird beim Lauf über ihren Wortlaut
gefunden, nicht über die Nummer:

| Klasse | Stelle | Befund | Vorschlag |
|---|---|---|---|
| A | `LH` Z. 122 | „`cpp` … **folgt**" — Zeitaussage über den Lieferstand, zudem überholt (`cpp` ist ein Profil) | Indikativ: `cpp` trägt C++/CMake mit cmake/ctest/clang-tidy; der Generator ist sprach-agnostisch |
| A | `LH` Z. 641 (§5) | „Weitere Sprachen **folgen** … je einen Renderer" | Indikativ: eine weitere Sprache ist ein weiterer Renderer, der Generator bleibt sprach-agnostisch |
| A | `LH` Z. 172 ([`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)) | „**Vorbedingung erfüllt** … (v0.15.0 …); die Umsetzung stützt sich auf diesen Beleg" — Zustand und Versionsbezug im Rumpf | Voraussetzung nennen: a-check ist wie d-check ein gepinntes Image mit `--print-mk`; ohne Versionsbezug und ohne Beleg-Satz |
| A | `LH` Z. 212 ([`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)) | „nicht **mehr** Vorbedingung (die **frühere** Picker-Setzung entfällt)" — beschreibt abwesenden Text | „Eine Kurs-Upstream-Ergänzung ist keine Vorbedingung." |
| A | `AR` Z. 6 | „Die zeitliche Schicht lebt in docs/plan/planning/ *(folgt)*" — die Schicht besteht | `*(folgt)*` entfällt |
| A | `AR` Z. 186 | „`--print-mk`, **real ab v0.15.0**" | Voraussetzung ohne Versionsbezug, wie `LH` Z. 172 |
| B | `LH` Z. 39 ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)) | „Das Sprachskelett **folgt** als separater, wiederholbarer Schritt" — Reihenfolge im Ablauf, aber als Lieferung lesbar | umgesetzt (F3, 2026-10-17): „ist ein eigener, wiederholbarer Schritt, der nach der Entscheidung … läuft" — gleiche Bedeutung ohne Mehrdeutigkeit |
| B | `LH` Z. 648 (Glossar) | „bleibt co-located für **spätere** Instanzen" — *spätere* meint spätere Verwendungen im Zielrepo | stehen lassen: Ablauf, kein Lieferzeitpunkt |
| B | `SP` Z. 93 | „jedes andere Feld einer **künftigen** Payload wird nicht still mitgeschrieben" — Regel über fremde Payloads | stehen lassen: Geschlossenheits-Regel, kein Lieferstand |
| C | `LH` Z. 80 | Hinweis „Titel historisch … siehe Historie (§7, v0.7.0)" | umformuliert (Entscheidung F2, 2026-10-17) |
| C | [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix), Z. 612/616/625 | „erst mit Plattform-Runnern", „läuft **heute** schlicht nicht", „**offen und nicht zugesagt**" — Aussage über den Lieferstand der CI in einer Grenz-Notiz einer Messmethode | umformuliert (Entscheidung F2, 2026-10-17), Richtung: Indikativ der Grenze („belegt ist linux/amd64; ein Voll-Smoke auf linux/arm64 braucht arm64-fähige Gate-Images"), ohne die Messmethode zu ändern |
| C | `LH` Z. 146 | „seine Vorlage ist eine **offene** Ergänzung" | umformuliert (Entscheidung F2, 2026-10-17) |
| C | `AR` Z. 170 | „ein Entry-Point wie **heute**" | umformuliert (Entscheidung F2, 2026-10-17) |
| C | `LH` Z. 118 und 620 | „gemessen 2026-07-27", „gemessen 2026-07-26" — datierte Messung | stehen lassen: ein Messbeleg nennt sein Datum |
| harmlos | `LH` Z. 355, 607 | „nicht zugesagt" als Zusage-Grenze | stehen lassen |
| harmlos | `SP` Z. 150, 199 | „kein Programm folgt" (Syntax), `Folgenummer` in der Test-Bindung | stehen lassen |
| harmlos | `AR` Z. 201, 228 | „folgen" im Sinn von *entsprechen* | stehen lassen |
| harmlos | `Use-Case-Slices` in `LH` Z. 127 und `AR` Z. 170 | „Slice" als Architekturbegriff, kein Terminbezug | stehen lassen |

Reihenfolge der Commits: (a) Lastenheft allein (Auftraggeber-Anweisung, wie die Commits der Versionen 0.25.0
bis 0.26.0), vor `open → next` und `next → in-progress`; (b) `spec/architecture.md` im Slice; (c) Closure
in frischem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 4. Trigger

**Start** (`next` → `in-progress`): erfüllt am 2026-10-17 — der Auftraggeber hat priorisiert (der Auftrag
selbst) und F1 bis F3 beantwortet (§6); der Lastenheft-Commit (a) `b7999710` liegt im Hauptzweig; das
WIP-Limit ist frei (`in-progress/` trug keinen Slice).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): die Entscheidung zu F2 zieht mehr als die
  genannten Stellen nach sich, etwa eine Änderung einer Messmethode oder eines Akzeptanzkriteriums.
- `in-progress` → `open` (blockiert — Carveout?): F1 bleibt unbeantwortet, und `spec/architecture.md`
  darf ohne benannte schreibende Rolle nicht im Slice-Commit mitgenommen werden.

## 5. Closure-Trigger

DoD (1) bis (3) und `make gates` grün; die Closure-Notiz benennt den Lerneintrag in einer der drei Formen
(geschärfte Regel · neuer Sensor · benannte Spec-Lücke). Vorschlag zur Form: **benannte Spec-Lücke** —
„Specs beschreiben das Zielbild" steht in keiner Quelle über der Architektur-Sicht; ob eine Hard Rule
daraus wird, entscheidet der Architect.

## 6. Risiken und offene Punkte

- Eine Umformulierung ändert die Bedeutung einer Anforderung (Z. 39, QA-04) — **Ausgang:** entfallen: die
  Bedeutungstreue-Prüfung der Verifikation fand keinen Befund, keine Zusage entfällt (§7, Vorher/Nachher).
- Die Reihenfolge nach [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 2 kippt: Der Lastenheft-Commit liegt erst nach dem Start —
  **Ausgang:** entfallen: der Lastenheft-Commit 0.27.0 lag vor dem Move nach `in-progress/`; der Commit 0.27.1 kam
  danach, als Patch zu zwei Folgestellen aus dem Review, mit eigenem Commit nur dieser Datei.
- Der Messbereich (Wortliste P1/P2) ist enger als der Gegenstand: andere Formulierungen von Zeit-/Liefer-Aussagen
  (*sobald*, *ab Version*, *wird eingeführt*) schlagen nicht an — **Ausgang:** weiter offen →
  `BEO-ALL/spec-nennt-den-lieferstand-statt-des-zielbilds` (Messgrenze benannt).
- Die Spezifikation führt heute keinen Befund der Klasse A; ein Treffer, den die Messung am Tag des Starts
  zusätzlich zeigt, ist eine Änderung an Rang 2 — **Ausgang:** eingetreten: die erweiterte Suche der Verifikation
  fand zwei Zeitbezüge (`SPEC-039`, `SPEC-093`); sie blieben unberührt, Folge-Slice
  `slice-spezifikation-nennt-zeitbezuege-als-zielbild`; Rollenfrage bei
  [slice-151](../next/slice-151-spec-straten-haben-eine-schreibende-rolle.md).

**Entschieden vom Auftraggeber am 2026-10-17:**

- **F1 — Rolle:** Der Implementer schreibt den Nachzug in `spec/architecture.md` im Slice (wie bisher bei
  Spec-Nachzügen); die Closure übergibt die Rollenfrage
  ([slice-151](../next/slice-151-spec-straten-haben-eine-schreibende-rolle.md)) an den Architect.
- **F2 — Klasse C: umformulieren.** [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)-Grenze (Z. 612/616/625),
  Z. 80, Z. 146 und `AR` Z. 170 als Zielbild im Indikativ ohne Zeit- und Versionsbezug, bedeutungstreu (was
  gilt, nicht wann). Bleiben: die datierten Messungen (`LH` Z. 118/620 — ein Messbeleg nennt sein Datum) und
  „nicht zugesagt" als Zusage-Grenze (Z. 355, 607, 625).
- **F3 — Klasse B:** Z. 39 umformuliert („ist ein eigener, wiederholbarer Schritt, der nach dem Init läuft").
- **Stufe:** Minor (0.27.0), wie 0.15.0; der Auftraggeber hat nicht widersprochen. Die zwei Folgestellen (Review LOW-1/LOW-2) tragen Patch 0.27.1, wie 0.25.1.

**Größe:** bleibt bei drei Liefer-Punkten; die Entscheidungen erweitern Punkt (1) um Stellen derselben Art
(Umformulierung eines Satzes), nicht um einen neuen Gegenstand. Schichten: nur Spec-Text.

## 7. Closure-Notiz

Geschrieben im Planner-Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10), getrennt von der Arbeit.

- **Anlass der Lastenheft-Änderung** (nach [`MR-042`](../../../../harness/conventions.md#mr-042--der-anlass-einer-lastenheft-änderung-steht-nicht-in-der-historie-sondern-in-der-closure-notiz)
  hier und nicht in der Historie): Auftraggeber-Hinweis vom 2026-10-17, sinngemäß: *in den Specs, auch im Lastenheft,
  wird das Zielbild definiert; Sätze wie „folgt auf" haben dort nichts verloren.* Ausgelöst durch die Frage, welche
  Zielsprachen noch nicht unterstützt werden, und den Satz „`cpp` … folgt" in `LH-FA-04`, obwohl `cpp` ein Profil ist.
- **Was hat funktioniert:** Lastenheft 0.27.0 und 0.27.1, `spec/architecture.md` (Marker 2026-10-17). Review:
  0 HIGH/0 MEDIUM/2 LOW/4 INFO; die zwei LOW (Z. 146 eine erfundene Herkunftsbehauptung zur CLAUDE.md-Vorlage, Z. 100
  *„das heutige Verhalten"*) behob 0.27.1. Verifikation: alle DoD-Punkte erfüllt; Messung Lastenheft 4 Treffer,
  Spezifikation 3, Architektur 2, jeder benannt und begründet; Rot-Gegenprobe je Datei (ein eingefügter Satz hebt die Zählung um 1:
  4→5, 3→4, 2→3); `heutige` steht nur noch als Protokoll-Zitat in der Historie-Zeile 0.27.1; Bedeutungstreue ohne Befund;
  `make gates` grün, Stempel gleich HEAD (`docs/reviews/2026-10-17-slice-spec-beschreibt-das-zielbild-nicht-den-lieferstand.md`, `…-verify.md`).
- **Vorher/Nachher je Satz** (Anker über den Wortlaut, nicht über Zeilen): `LH-FA-04` *„`cpp` … folgt; der Generator bleibt"* →
  *„`cpp` trägt C++/CMake …; der Generator ist"* · §5 *„Weitere Sprachen folgen … je einen Renderer"* → *„Jede weitere Sprache
  ist ein eigener Renderer des sprach-agnostischen Generators"* · `LH-FA-07` *„Vorbedingung erfüllt … (v0.15.0 …); die Umsetzung stützt
  sich auf diesen Beleg"* → *„Voraussetzung: a-check ist — wie d-check — ein Digest-gepinntes Image mit `--print-mk`"* ·
  `LH-FA-08` *„nicht mehr Vorbedingung (die frühere Picker-Setzung entfällt)"* → *„nicht Vorbedingung"* · `LH-FA-01` *„folgt als
  separater, wiederholbarer Schritt"* → *„ist ein eigener, wiederholbarer Schritt, der nach dem Init läuft"* (F3) · Klasse C (F2):
  Titel-Hinweis in `LH-FA-04`, Default `flat` ohne Zeitbezug, Klammer der CLAUDE.md-Vorlage in `LH-FA-06` entfällt,
  `LH-QA-04`-Grenze im Indikativ ohne *erst/heute/offen und*, Messmethode unverändert · Architektur: *„*(folgt)*"* entfällt,
  *„real ab v0.15.0"* entfällt, *„byte-identisch zum heutigen"* → *„zur Ausgabe ohne `--arch`"*, *„Entry-Point wie heute"* →
  *„Entry-Point"*. Antworten: **F1** der Implementer schreibt den Nachzug in `spec/architecture.md`; **F2** Klasse C umformuliert, datierte
  Messungen und *„nicht zugesagt"* als Zusage-Grenze bleiben; **F3** Klasse B (`LH-FA-01`) umformuliert.
- **Was ging anders als geplant:** zwei Folgestellen (Review LOW-1/LOW-2) führten zu 0.27.1 als Patch. **Abweichung zwischen
  Auftrag und Lieferung, benannt:** der Auftraggeber setzte das Prinzip für *die Specs, auch das Lastenheft*; der Plan führte die
  Spezifikation als unberührt, weil seine Muster dort keinen Befund der Klasse A fanden. Die erweiterte Suche der Verifikation fand
  zwei Zeitbezüge, `SPEC-039` (*„die Aussage entfällt, sobald …"*) und `SPEC-093` (*„seit dem Feld `rule_version` …"*); sie blieben
  unangetastet. **Entscheidung: Folge-Slice statt Register allein** — ein Register-Beleg zählt Wiederkehr und trägt keine
  Arbeit; die zwei Stellen sind ein benannter, endlicher Gegenstand mit eigener Prüf-Frage (Zielbild oder Grenze?), und der
  Auftrag ist ohne sie nicht erfüllt. Adresse: `slice-spezifikation-nennt-zeitbezuege-als-zielbild` in `open/`, nicht priorisiert.
  Messgrenzen der Verifikation: die Muster P1/P2 erfassen keine Formulierung ohne Signalwort, keine implizite Lieferaussage und
  nicht die Wahrheit der Aussage; der erste Rot-Versuch mit BSD-`sed` scheiterte an der Syntax, gültig ist der `awk`-Lauf.
- **Steering-Loop-Eintrag:** **benannte Spec-Lücke, kein neuer Sensor und keine Regel:** „Specs beschreiben das Zielbild" steht in
  keiner Quelle über der Architektur-Sicht (`modul-03-spec.md` sagt es allein für sie, meilensteinfrei); der Auftraggeber-Hinweis
  ist die einzige Quelle, ein Wächter besteht nicht. Träger ist der Lauf, der die Spec schreibt, und der Verifier mit erweiterter
  Suche. Ob daraus eine Hard Rule wird, entscheidet der Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8).
- **Übergaben an den Architect (nicht hier entschieden):** (a) die Rollenfrage für `spec/architecture.md` und
  `spec/spezifikation.md` liegt bei [slice-151](../next/slice-151-spec-straten-haben-eine-schreibende-rolle.md); dieser Slice lief
  unter F1 des Auftraggebers und zählt als **kein** Beleg für `BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`,
  weil die Frage entschieden wurde statt faktisch beantwortet; ob F1 in dessen Residuum zählt, prüft der Architect am Trigger 2 von
  [`ADR-0062`](../../../../docs/plan/adr/0062-eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-nicht-beantwortet.md). (b) Ob
  „Specs beschreiben das Zielbild" eine Hard Rule wird.
- **Lieferstand der Sprachen (Abgrenzung §1):** dass `python`, `java` und `csharp` kein Profil in `internal/gen/` tragen, bleibt
  Rückverfolgbarkeit. [slice-192](../open/slice-192-rtm-sieht-alle-anforderungen.md) trägt den Gegenstand nicht (Matrix über Anforderungen, nicht über
  Teilabdeckung einer Anforderung); der Hinweis steht als *benannt, nicht gezählt* im Register-Eintrag, ein eigener Slice entsteht nicht.
- **Beobachtungs-Register (`../observations/`):** neu angelegt
  [`BEO-ALL/spec-nennt-den-lieferstand-statt-des-zielbilds`](../observations/BEO-ALL/spec-nennt-den-lieferstand-statt-des-zielbilds/observation.md)
  mit Beleg `evidence/slice-spec-beschreibt-das-zielbild-nicht-den-lieferstand.md` — Zähler 1, Stand `offen`; Messgrenze in `state.md`.
  Geprüft, ohne Beleg: [`BEO-ALL/spec-zeile-enger-als-der-code-den-sie-beschreibt`](../observations/BEO-ALL/spec-zeile-enger-als-der-code-den-sie-beschreibt/observation.md)
  (andere Fehlerrichtung: dort beschreibt die Spec den Code zu eng), [`BEO-ALL/spec-aenderung-ohne-historie-zeile`](../observations/BEO-ALL/spec-aenderung-ohne-historie-zeile/observation.md)
  (Lastenheft trägt die Zeilen 0.27.0/0.27.1, die Architektur-Sicht keine Historie), [`BEO-ALL/werkzeug-zelle-traegt-einen-ist-stand-der-vom-ausgelieferten-abweicht`](../observations/BEO-ALL/werkzeug-zelle-traegt-einen-ist-stand-der-vom-ausgelieferten-abweicht/observation.md)
  (anderer Gegenstand). Kein 3×-Übertritt durch diesen Slice (Lese-Schritt: keine Beobachtung dieser Closure erreicht 3×).
- **Trigger-Audit:** keine ADR und kein Eintrag verlangt eine Änderung; `LH-FA-04` Z. 80 nannte *„Picker"* als historisch, die Anker
  bleiben stabil.
- **Folge-Slices:** `slice-spezifikation-nennt-zeitbezuege-als-zielbild` — ist eine Datei in `open/`.
- **Risiken aus §6:** 1 entfallen · 2 entfallen · 3 weiter offen → Register · 4 eingetreten → Folge-Slice (Begründung je Punkt in §6).
- **Drei Paarungen:** nach dem Move geprüft (Anker: kein `liegt in`-Feld, nichts zu paaren; Folge-Slice: liegt im Planning-Lifecycle; Register: die zitierten Pfade existieren).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist allein `ALL` (gesamtes Repo, `spec/**`); die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md) führt `*` als einzige Sub-Area der Beobachtungen
und kennt keine feinere für `spec/`. Keine zu grobe Wahl: der Slice schneidet nach Sätzen, nicht nach Bereichen.

**Vorgelagert — offene Beobachtungen sichten:** `docs/plan/planning/observations/` durchgegangen
(Stand des gemergten Hauptzweigs 2026-10-17). Drei Verzeichnisse berühren den Gegenstand, keines erreicht mit
diesem Slice 3×:
`BEO-ALL/spec-zeile-enger-als-der-code-den-sie-beschreibt` (2 Belege),
`BEO-ALL/werkzeug-zelle-traegt-einen-ist-stand-der-vom-ausgelieferten-abweicht` (1 Beleg) und
`BEO-ALL/spec-aenderung-ohne-historie-zeile` (1 Beleg; gilt für den Lastenheft-Commit). Für die Rollenfrage
zählt `BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext` (10 Belege) und
`BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet` (13 Belege): beide sind über der
Schwelle und gehören zu slice-151, nicht hierher. Zähler am 2026-10-17 gemessen
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`), keine Erwartungswerte.

**Stand nach der Closure:** `BEO-ALL/spec-nennt-den-lieferstand-statt-des-zielbilds` — Zähler 1, `offen`;
`spec-zeile-enger-als-der-code-den-sie-beschreibt` (2), `spec-aenderung-ohne-historie-zeile` unverändert.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF — Doc führt, Code folgt nicht; der Slice ändert allein Text
der Specs.
