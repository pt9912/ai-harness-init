# Slice slice-129: Die Closure-Notiz-Pflicht bekommt ihren Sensor — und er ist geliefert, nicht gebaut

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) — Achse (6) des Roadmap-Kandidaten
*Regeln ohne Feedback-Quadrant schließen*. Hermetisch, hängt an keinem anderen Slice der Welle.

**Ebene: Dogfood, nicht emittiert.** Gegenstand ist der Ruheort **dieses** Repos
([`done/`](../done)). Die emittierte Starter-Config bleibt `modules: [links, anchors]`
([`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed));
ob ein Ziel-Repo diese Fähigkeit bekommt, entscheidet
[slice-073](slice-073-emittierte-doc-gate-module.md) — dort ist die Frage gestellt, und sie ist
dort eine andere, weil ein frisch gebootstrapptes Ziel **keine** abgeschlossenen Pakete hat und die
Fähigkeit über null Kandidaten fail-closed abbricht.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die
Regel, die hier einen Sensor bekommt — die Closure-Notiz ist eine Zusage jedes Slice, und über sie
urteilt heute kein Gate),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(Gate-*Anheben* → Steering-Loop, kein ADR — die Auflage, unter der dieser Slice steht),
[`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)
(*„Kein Rückfall auf stilles Grün: jede Ventil-Zeile nennt, was sie ausnimmt und warum"* — der
Maßstab für den Kandidaten-Filter in DoD (2)),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(die Welle-Ebene, deren Closure-Notiz dieses Repo auf **zwei** Dateien verteilt — der Gegenstand
von DoD (2)),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(§Geltungsbereich nimmt [`done/`](../done) als Zeitdokument-Bestand ausdrücklich aus — ein Gate
über genau diesem Bestand muss wissen, dass es dort nichts nachziehen darf),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel).

**Autor:** Planner. **Datum:** 2026-08-28.

---

## 1. Ziel

**Ein abgeschlossenes Paket ohne Closure-Notiz — oder mit einer, die aus einer Zeile besteht —
färbt rot, und zwar an dem Lauf, der es nach [`done/`](../done) bewegt.**

### Der Anlass: die dichteste Zusage dieses Repos hat keinen Träger

Die Standard-DoD jedes Slice endet mit *„Closure-Notiz mit Steering-Loop-Lerneintrag"* —
`grep -l 'Closure-Notiz mit Steering-Loop' docs/plan/planning/open/*.md | wc -l` → **32** von
**42** offenen Plänen (`ls docs/plan/planning/open/*.md | wc -l`; die übrigen tragen dieselbe
Zusage in einer Wortvariante). **Beide Zahlen sind keine Erwartungswerte** — sie wandern mit dem
Bestand, diese Datei eingerechnet
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Gelesen wird eine solche Notiz von nichts: `grep -c '^verify' Makefile` → **0**, und
[`.d-check.yml`](../../../../.d-check.yml) führt sechs Module
(`grep -m1 '^modules:' .d-check.yml`), von denen keines eine Paket-Datei auf ihren Abschluss hin
öffnet. Wer eine Notiz vergisst, erfährt es von einer schreibenden Rolle oder gar nicht.

### Der Sensor ist geliefert, nicht zu bauen

Das gepinnte Image trägt die Prüfung im Modul `planning` als **zweite** Fähigkeit (opt-in über
`closure.dir`), mit fünf eigenen Grund-Codes — `closure-note-missing`, `-thin`, `-boilerplate`,
`-placeholder`, `-ambiguous`. Achse (6) ist damit dieselbe Klasse wie die vier anderen
Wellen-Mitglieder: Trockenlauf, Config-Block, Verdrahtung — und nicht die Eigenbau-Klasse, unter
der die Roadmap sie bis zum Schnitt dieser Welle geführt hat.

**Was von Achse (6) draußen bleibt, ist nicht dasselbe:** die Roadmap-Zeile nennt daneben die
Dogfood-Lücke `.harness/skills/closure-note-reviewer.md` — `ls .harness/skills/ | wc -l` → **1**
(`reviewer.md`), während `grep -c 'closure-note-reviewer' internal/emit/templates.go` → **1** die
Datei in **jedes** Ziel-Repo emittiert. Das ist eine Skill-Datei, kein Gate; sie bleibt beim
Kandidaten.

### Was die Fähigkeit über diesem Repo tut — gemessen, nicht geschätzt

Gegen eine Kopie außerhalb des Repos, netzlos, Mount `:ro`, Image `v0.65.0` per Digest, Stand
`fccc627`: `git archive HEAD | tar -x -C <kopie>`, dann je Lauf
`docker run --rm --network none -v <kopie>:/repo:ro ghcr.io/pt9912/d-check@<digest> --config <profil> --enable planning`.
Der Kandidaten-Bestand ist `ls docs/plan/planning/done/ | wc -l` → **104** Dateien, davon
`ls docs/plan/planning/done/slice-*.md | wc -l` → **86** Slices.

| Lauf | Profil | Ergebnis |
|---|---|---|
| `closure.dir: docs/plan/planning/done`, Kandidaten-Filter aus `slice-glob` (die 86) | Basis | `417 Datei(en) geprüft, 0 Befund(e)`, **Exit 0** |
| **Kontrolle** zum selben Profil: §7 **einer** `done/`-Datei auf einen Satz gekürzt | Basis | **1** `closure-note-thin` mit Datei und Zeile, Exit 1 |
| dasselbe Profil **plus** `placeholder: true` | Basis + Platzhalter | **1** `closure-note-placeholder` |
| dasselbe Profil **plus** `glob: '*.md'` (alle 104) | Basis + Welle-Ebene | **16** Befunde, Exit 1 |

**Die Null der ersten Zeile ist eine gemessene Null und kein leerer Prüfbereich** — das sagt die
Kontroll-Zeile, die denselben Baum mit **einer** gekürzten Notiz rot färbt. Die 86 Slice-Notizen
dieses Repos halten die Struktur-Schwelle also heute schon; die Adoptions-Schuld der Basis-Form ist
**null**, und das ist die billigste Adoption der ganzen Welle.

**Die 16 der letzten Zeile sind eine echte Struktur-Aussage, kein Rückstand.** Sie verteilen sich
auf **8** × `closure-note-missing` (jede `welle-NN-results.md`: sie **ist** die Notiz und führt sie
als **H1**, während das Muster `heading-pattern` H2/H3 erwartet) und **8** × `closure-note-thin`
(jeder Welle-Plan: sein §7 ist ein **Zeiger** auf die Ergebnisnotiz und trägt zwei Sätze). Unsere
Welle-Closure liegt auf **zwei** Dateien, das Modell des Moduls kennt **eine**. Das ist die
Entscheidung dieses Slice und keine Konfiguration.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3).

- [ ] **(1) Die Closure-Fähigkeit ist verdrahtet und färbt rot.** Der Lauf hat einen benannten Ort,
      und die Meldung nennt Datei, Zeile und Grund-Code.
      **Rot:** in einer Wegwerf-Kopie das §7 einer `done/`-Datei auf einen Satz kürzen → der Lauf
      fällt mit `closure-note-thin`. Derselbe Lauf über den unveränderten Baum bleibt grün. Beide
      gehören in den Umsetzungs-Commit. **Der Arbeitsbaum wird für das Rot nicht angefasst** —
      [`done/`](../done) ist Zeitdokument-Bestand
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      §Geltungsbereich).
- [ ] **(2) Der Kandidaten-Filter ist entschieden, und die Welle-Ebene ist benannt statt
      weggefiltert.** Entweder gilt weiter `slice-glob` — dann steht in
      [`harness/README.md`](../../../../harness/README.md), dass die **18** Welle-Dateien
      (`ls docs/plan/planning/done/welle-*.md | wc -l`) außerhalb liegen und warum —, oder `glob`
      wird geweitet und die **16** Befunde sind aufgelöst, indem die Konvention nachzieht (die
      Ergebnisnotiz trägt eine passende Überschrift, der Plan-§7 trägt Substanz).
      **Rot:** der Filter wird so gesetzt, dass er die Menge leert oder auf eine Klasse zeigt, in
      der die Bedingung trivial gilt — dann meldet der Gate grün über nichts, und das ist der
      Verstoß, gegen den er antritt
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
      Mechanisch rot wird der Punkt, wenn nach der Entscheidung ein **neues** Paket ohne Notiz nach
      [`done/`](../done) wandert und der Lauf es **nicht** meldet.
- [ ] **(3) Der Ort des Laufs ist entschieden, und die Entscheidung steht gegen die
      Werkzeug-Empfehlung.** Das Benutzerhandbuch des Werkzeugs legt für diese Fähigkeit ein
      **eigenes Prüf-Profil** nahe (`--config`), damit nicht jeder gewöhnliche Lauf die
      Closure-Notizen mitprüft. Dieses Repo hat **einen** Durchsetzungspunkt: `make gates`. Welcher
      der beiden gilt, ist aufzuschreiben — mit dem, was die gewählte Form **nicht** leistet.
      **Rot:** ein eigenes Profil ohne Aufrufer. Es liefe nie, und die Regel bliebe im
      Feedforward-Quadranten, aus dem dieser Slice sie holen soll — dieselbe Klasse wie die
      `doc-*`-Ziele, die heute ohne Trigger im [`d-check.mk`](../../../../d-check.mk) stehen
      (`grep -c '^doc-' d-check.mk` → **11**, davon von einem Aufrufer genannt:
      `grep -c 'doc-' Makefile` → **0**).

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Doku-Update, falls ein öffentlicher Vertrag berührt ist · Closure-Notiz mit
Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| Prüf-Profil für die Closure-Fähigkeit | neu **oder** update | entweder eine eigene Profil-Datei nach der Empfehlung des Werkzeugs oder der `closure`-Block in [`.d-check.yml`](../../../../.d-check.yml) — die Entscheidung **ist** DoD (3) und wird nicht vorweggenommen |
| [`Makefile`](../../../../Makefile) | update | der Aufrufer des gewählten Laufs; ohne ihn ist die Fähigkeit ein Ziel ohne Trigger |
| [`harness/README.md`](../../../../harness/README.md) | update | was der Lauf prüft und was **nicht** — insbesondere die Filter-Entscheidung aus DoD (2) und die Grenze *Struktur, nicht Bedeutung* |
| `test/` | neu | der Fall, der die Zusage aus DoD (1) rot färbt, plus sein `test/mutations/`-Zahn |
| [`done/`](../done) | **unverändert** | Zeitdokument-Bestand ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) §Geltungsbereich). Das Rot entsteht in einer Wegwerf-Kopie; wird eine `done/`-Datei geändert, um den Gate grün zu bekommen, ist das ein Befund und keine Umsetzung |
| [`internal/emit/`](../../../../internal/emit) | **unverändert** | Ebene Dogfood (Kopfzeile); die emittierte Modul-Liste entscheidet [slice-073](slice-073-emittierte-doc-gate-module.md) |
| [`harness/conventions.md`](../../../../harness/conventions.md) | **nicht durch diesen Slice** | fällt DoD (2) für die Welle-Ebene aus, ist [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) betroffen — **Übergabe** an den Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8) |

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md)
ist gestartet und das WIP-Limit ist frei.** Hermetisch, hängt an keinem anderen Slice der Welle —
insbesondere **nicht** an [slice-123](slice-123-ci-sieht-die-historie.md): die Fähigkeit liest
keinen git-Stand.

**Eine Reihenfolge-Notiz, die kein Trigger ist:** dieser Slice und
[slice-125](slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md) konfigurieren **dasselbe** Modul
in **einem** Schlüsselbaum. Laufen sie nacheinander, erbt der zweite den Block des ersten; laufen
sie parallel, kollidieren sie in einer Datei. Die Reihenfolge ist frei, die Gleichzeitigkeit nicht.

**Rückführungen, vorab benannt:**

- `in-progress` → `next`: DoD (2) und DoD (3) erweisen sich als zwei Schnitte — die Filter-Frage
  (welche Pakete) und die Orts-Frage (welcher Lauf) haben verschiedene Gegenstände. Dann trägt
  dieser Slice die Slice-Ebene, und die Welle-Ebene wird ein eigener.
- `in-progress` → `open`: die Welle-Ebene lässt sich ohne eine Änderung an
  [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
  nicht auflösen. Dann blockiert der Slice an einer Architect-Entscheidung und wartet auf sie,
  statt die Norm im Implementations-Kontext mitzunehmen.

## 5. Closure-Trigger

DoD (1) bis (3) erfüllt mit gefahrenen Kommandos, `make gates` grün, `make mutate` ohne Befund,
Review nach Modul 10 und Verifikation nach Modul 11 ohne blockierenden Befund, Closure-Notiz in §7
mit Steering-Loop-Eintrag — die dann von dem Sensor gelesen wird, den dieser Slice einführt.

## 6. Risiken und offene Punkte

- **Der Sensor sitzt am Ausgang, nicht davor.** Er urteilt über Dateien in [`done/`](../done); eine
  fehlende Notiz wird also erst sichtbar, wenn das Paket dort liegt. In diesem Repo ist das kein
  Defekt, sondern der richtige Moment: der Übergang ist ein reiner `git mv`
  ([`AGENTS.md`](../../../../AGENTS.md) §3.3), und der `make gates`-Lauf **nach** dem Move ist der
  erste, der die Datei am neuen Ort sieht. Wer eine engere Kante will — Notiz **vor** dem Move —,
  braucht einen anderen Gegenstand als diese Fähigkeit; das gehört aufgeschrieben, sonst liest die
  nächste Runde *„Closure-Notizen sind bewacht"* und meint beide Kanten.
- **Die Platzhalter-Bedingung kostet genau einen Befund, und er ist keiner.** Mit
  `placeholder: true` meldet der Basis-Lauf **1** × `closure-note-placeholder`
  (`docs/plan/planning/done/slice-087-emittierte-doku-tische-init-invariant.md:353`). Die Zeile
  zeigt eine Vorlagen-Syntax in **escapten** Backticks; die ungerade Backtick-Zahl verschiebt die
  Inline-Code-Paarung, und das Werkzeug führt genau diese Vorverarbeitungs-Grenze selbst als
  bekannt. Ein echter unausgefüllter Rumpf ist es nicht. Die Bedingung anzuschalten hieße
  entweder, ein Zeitdokument zu ändern, oder eine Ausnahme für eine Datei zu setzen, die nichts
  falsch macht — beides schlechter als sie auszulassen und den Grund hinzuschreiben.
- **Die Floskel-Liste ist die Stelle, an der dieser Slice sich selbst rot färben kann.** Sie
  entscheidet über rot und grün und wirkt rückwirkend auf **alle** Kandidaten. Eine Phrase gehört
  nur hinein, wenn sie im Bestand **null** Treffer hat — sonst färbt sie Notizen rot, die tragen,
  und die einzige Reparatur wäre eine Änderung an [`done/`](../done).
- **Ein zweites Profil ist ein zweiter Ort, an dem eine Modul-Liste driften kann.** Fällt DoD (3)
  auf eine eigene Profil-Datei, gibt es danach zwei Konfigurationen für dasselbe Modul. Was in
  welcher steht und warum, gehört in
  [`harness/README.md`](../../../../harness/README.md) — die Klasse, die
  [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) für
  das Gate-Fragment schon einmal ausbuchstabiert hat.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example). Ein Begründungsblock
entfällt: der Slice legt keine neue Sub-Area an und berührt keine in BF oder Hybrid. Die
Planungs-Ablage ist die dichteste Sub-Area des Repos — Modul 5 setzt den Lifecycle, Modul 6 die
Closure-Notiz als Wellen-Pflichtteil, und
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
die Abweichung dazwischen.
