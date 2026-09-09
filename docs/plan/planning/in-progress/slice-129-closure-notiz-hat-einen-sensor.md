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
[slice-073](../next/slice-073-emittierte-doc-gate-module.md) — dort ist die Frage gestellt, und sie ist
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
`modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 3, Baseline `v6.5.0`
(die Welle-Ebene: *„Und die Welle-Plan-Datei wandert per `git mv` von flach nach `done/`"* — neben
ihre Ergebnisnotiz; **diese** Zwei-Datei-Form ist der Gegenstand von DoD (2)),
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
[`.d-check.yml`](../../../../.d-check.yml) führt sieben Module
(`grep -m1 '^modules:' .d-check.yml`), von denen keines eine Paket-Datei auf ihren Abschluss hin
öffnet — `planning` ebenfalls nicht, solange der `closure.dir`-Block fehlt, den dieser Slice
setzt. Wer eine Notiz vergisst, erfährt es von einer schreibenden Rolle oder gar nicht.

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

- [x] **(1) Die Closure-Fähigkeit ist verdrahtet und färbt rot.** Der Lauf hat einen benannten Ort,
      und die Meldung nennt Datei, Zeile und Grund-Code.
      **Rot:** in einer Wegwerf-Kopie das §7 einer `done/`-Datei auf einen Satz kürzen → der Lauf
      fällt mit `closure-note-thin`. Derselbe Lauf über den unveränderten Baum bleibt grün. Beide
      gehören in den Umsetzungs-Commit. **Der Arbeitsbaum wird für das Rot nicht angefasst** —
      [`done/`](../done) ist Zeitdokument-Bestand
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      §Geltungsbereich).
      **Erfüllt:** `.d-check.yml` setzt `planning.closure.dir: docs/plan/planning/done` (der Lauf
      ist `docs-check` in `make gates`, kein zusätzlicher Ort). **Rot gesehen** gegen eine Kopie
      außerhalb des Repos, netzlos, mit dem in [`d-check.mk`](../../../../d-check.mk) gepinnten
      Digest: Basis-Lauf über dem unveränderten Baum → `0 Befund(e)`; Abschnitt 7 von
      `docs/plan/planning/done/slice-001a-cli-skeleton.md` in derselben Kopie auf einen Satz
      gekürzt → `closure-note-thin`, Datei `docs/plan/planning/done/slice-001a-cli-skeleton.md`,
      Zeile `79`. Beide Kommandos und Ausgaben stehen in
      [`harness/README.md`](../../../../harness/README.md). Der Arbeitsbaum selbst
      ([`done/`](../done)) bleibt unverändert.
- [x] **(2) Der Kandidaten-Filter ist entschieden, und die Welle-Ebene ist benannt statt
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
      **Erfüllt:** `slice-glob` bleibt der Modul-Default (`.d-check.yml` setzt kein eigenes
      `glob:`) — [`harness/README.md`](../../../../harness/README.md) nennt, dass die Welle-Dateien
      (`ls docs/plan/planning/done/welle-*.md | wc -l` → **24** zum Zeitpunkt der Umsetzung, kein
      Erwartungswert) außerhalb bleiben und warum: die Welle-Closure ist auf zwei Dateien verteilt
      (Welle-Plan trägt nur einen Zeiger, Ergebnisnotiz führt ihre Aussage bei **8** der **12**
      Welle-Ergebnisnotizen als H1 statt der erwarteten H2/H3 — die übrigen vier weichen zusätzlich
      von der vendored Ziel-Form ab, benannt statt gezählt in
      [`harness/README.md`](../../../../harness/README.md)). Probeweise mit `glob: '*.md'`
      geweitet (Kopie außerhalb des Repos): **20**
      Befunde — **12** `closure-note-missing` (jede `welle-NN-results.md`), **8**
      `closure-note-thin` (acht der zwölf Welle-Pläne) — überwiegend dieselbe Zwei-Datei-Form,
      keine grundsätzlich fehlende Substanz. Die im Plan genannten Zahlen (18/16, gemessen mit
      `v0.65.0` gegen den damaligen Bestand) sind mit dem Bestand gewachsen; die Zusammensetzung
      (missing = Ergebnisnotizen,
      thin = Plan-Zeiger) ist unverändert. Der mechanische Falsifikator (ein neues Paket ohne Notiz
      wandert unbemerkt nach `done/`) ist mit dieser Entscheidung nicht aufgehoben — er bleibt der
      Rot-Weg für jeden Folge-Lauf, unabhängig davon, ob `slice-glob` oder ein geweiteter `glob`
      gilt.
- [x] **(3) Der Ort des Laufs ist entschieden, und die Entscheidung steht gegen die
      Werkzeug-Empfehlung.** Das Benutzerhandbuch des Werkzeugs legt für diese Fähigkeit ein
      **eigenes Prüf-Profil** nahe (`--config`), damit nicht jeder gewöhnliche Lauf die
      Closure-Notizen mitprüft. Dieses Repo hat **einen** Durchsetzungspunkt: `make gates`. Welcher
      der beiden gilt, ist aufzuschreiben — mit dem, was die gewählte Form **nicht** leistet.
      **Rot:** ein eigenes Profil ohne Aufrufer. Es liefe nie, und die Regel bliebe im
      Feedforward-Quadranten, aus dem dieser Slice sie holen soll — dieselbe Klasse wie die
      `doc-*`-Ziele, die heute ohne Trigger im [`d-check.mk`](../../../../d-check.mk) stehen
      (`grep -c '^doc-' d-check.mk` → **11**, davon von einem Aufrufer genannt:
      `grep -c 'doc-' Makefile` → **0**).
      **Erfüllt:** **kein** eigenes `--config`-Profil. `closure` läuft im selben `planning`-Block
      wie die Marker-Hälfte, am geteilten Durchsetzungspunkt `docs-check` in `make gates` — ein
      zweites Profil wäre ein zweiter Ort, an dem dieselbe Modul-Config driften kann. Was das
      **nicht** leistet, steht in [`harness/README.md`](../../../../harness/README.md): jeder
      `docs-check`-Lauf öffnet jetzt auch jede `slice-*.md`, die **flach** unter `done/` liegt, und
      prüft ihre §7-Struktur, auch wenn die auslösende Änderung mit `done/` nichts zu tun hat; ein
      dediziertes Advisory-Target ohne die übrigen sechs aktiven Module gibt es nicht.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Doku-Update, falls ein öffentlicher Vertrag berührt ist · Closure-Notiz mit
Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| Prüf-Profil für die Closure-Fähigkeit | update | entschieden gegen ein eigenes Profil (DoD (3)): der `closure`-Block landet im bestehenden `planning:`-Block in [`.d-check.yml`](../../../../.d-check.yml), am geteilten Durchsetzungspunkt |
| [`Makefile`](../../../../Makefile) | **unverändert** | die Entscheidung aus DoD (3) braucht keinen neuen Aufrufer — `docs-check`/`make gates` binden den erweiterten `planning:`-Block bereits über das bestehende `.d-check.yml`; ein eigenes Profil hätte hier ein neues Ziel gebraucht |
| [`harness/README.md`](../../../../harness/README.md) | update | was der Lauf prüft und was **nicht** — insbesondere die Filter-Entscheidung aus DoD (2) und die Grenze *Struktur, nicht Bedeutung* |
| `test/` | neu | der Fall, der die Zusage aus DoD (1) rot färbt, plus sein `test/mutations/`-Zahn |
| [`done/`](../done) | **unverändert** | Zeitdokument-Bestand ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) §Geltungsbereich). Das Rot entsteht in einer Wegwerf-Kopie; wird eine `done/`-Datei geändert, um den Gate grün zu bekommen, ist das ein Befund und keine Umsetzung |
| [`internal/emit/`](../../../../internal/emit) | **unverändert** | Ebene Dogfood (Kopfzeile); die emittierte Modul-Liste entscheidet [slice-073](../next/slice-073-emittierte-doc-gate-module.md) |
| [`harness/conventions.md`](../../../../harness/conventions.md) | **nicht durch diesen Slice** | fällt DoD (2) für die Welle-Ebene aus, wäre eine Abweichung von der Baseline-Form (`modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 3) zu erklären — ein neuer Adaptions-Eintrag, und damit **Übergabe** an den Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8) |

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md)
ist gestartet und das WIP-Limit ist frei.** Hermetisch, hängt an keinem anderen Slice der Welle —
insbesondere **nicht** an [slice-123](../done/slice-123-ci-sieht-die-historie.md): die Fähigkeit liest
keinen git-Stand.

**Eine Reihenfolge-Notiz, die kein Trigger ist:** dieser Slice und
[slice-125](../done/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md) konfigurieren **dasselbe** Modul
in **einem** Schlüsselbaum. Laufen sie nacheinander, erbt der zweite den Block des ersten; laufen
sie parallel, kollidieren sie in einer Datei. Die Reihenfolge ist frei, die Gleichzeitigkeit nicht.

**Rückführungen, vorab benannt:**

- `in-progress` → `next`: DoD (2) und DoD (3) erweisen sich als zwei Schnitte — die Filter-Frage
  (welche Pakete) und die Orts-Frage (welcher Lauf) haben verschiedene Gegenstände. Dann trägt
  dieser Slice die Slice-Ebene, und die Welle-Ebene wird ein eigener.
- `in-progress` → `open`: die Welle-Ebene lässt sich ohne einen neuen Adaptions-Eintrag gegen die
  Baseline-Form (`modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 3)
  nicht auflösen. Dann blockiert der Slice an einer Architect-Entscheidung und wartet auf sie,
  statt die Norm im Implementations-Kontext mitzunehmen.

## 5. Closure-Trigger

DoD (1) bis (3) erfüllt mit gefahrenen Kommandos, `make gates` grün, `make mutate` ohne Befund,
Review nach Modul 10 und Verifikation nach Modul 11 ohne blockierenden Befund, Closure-Notiz in §7
mit Steering-Loop-Eintrag — die dann von dem Sensor gelesen wird, den dieser Slice einführt.

## 6. Risiken und offene Punkte

Vier Risiken, vier Ausgänge — jeder genau einer aus der geschlossenen Menge *eingetreten ·
entfallen · weiter offen* (Baseline-Regelwerk `modul-05-planning-harness.md` §Offene Risiken werden
bei Closure aufgelöst).

- **Der Sensor sitzt am Ausgang, nicht davor.** Er urteilt über Dateien in [`done/`](../done); eine
  fehlende Notiz wird also erst sichtbar, wenn das Paket dort liegt. In diesem Repo ist das kein
  Defekt, sondern der richtige Moment: der Übergang ist ein reiner `git mv`
  ([`AGENTS.md`](../../../../AGENTS.md) §3.3), und der `make gates`-Lauf **nach** dem Move ist der
  erste, der die Datei am neuen Ort sieht. Wer eine engere Kante will — Notiz **vor** dem Move —,
  braucht einen anderen Gegenstand als diese Fähigkeit; das gehört aufgeschrieben, sonst liest die
  nächste Runde *„Closure-Notizen sind bewacht"* und meint beide Kanten.
  — **Ausgang: weiter offen**, wandert ins Beobachtungs-Register. Die Bedingung des Risikos war
  *aufgeschrieben*, und sie ist nicht erfüllt: [`harness/README.md`](../../../../harness/README.md)
  führt den Prüf**bereich** und seine Nicht-Rekursion, aber an keiner Stelle den **Zeitpunkt**
  (`awk 'NR>=82 && NR<=170' harness/README.md | grep -ciE 'nach dem move|vor dem move|erst wenn'`
  → 0). Der Satz hier zu wiederholen wäre kein Träger — diese Datei friert mit dem `git mv` ein und
  wird nicht wieder gelesen. Kennung:
  [`BEO-ALL/zusage-nennt-zwei-kanten-der-sensor-deckt-eine`](../observations/BEO-ALL/zusage-nennt-zwei-kanten-der-sensor-deckt-eine/observation.md),
  Zähler **1×** — unter der Schwelle, also ohne Ausgang.
- **Die Platzhalter-Bedingung kostet genau einen Befund, und er ist keiner.** Mit
  `placeholder: true` meldet der Basis-Lauf **1** × `closure-note-placeholder`
  (`docs/plan/planning/done/slice-087-emittierte-doku-tische-init-invariant.md:353`). Die Zeile
  zeigt eine Vorlagen-Syntax in **escapten** Backticks; die ungerade Backtick-Zahl verschiebt die
  Inline-Code-Paarung, und das Werkzeug führt genau diese Vorverarbeitungs-Grenze selbst als
  bekannt. Ein echter unausgefüllter Rumpf ist es nicht. Die Bedingung anzuschalten hieße
  entweder, ein Zeitdokument zu ändern, oder eine Ausnahme für eine Datei zu setzen, die nichts
  falsch macht — beides schlechter als sie auszulassen und den Grund hinzuschreiben.
  — **Ausgang: entfallen.** Die Bedingung ist nicht gesetzt (`.d-check.yml` führt unter
  `planning.closure` allein `dir:`), und der Grund steht im lebenden Artefakt statt hier:
  [`harness/README.md`](../../../../harness/README.md) nennt den einen Befund samt Datei und Zeile
  und die Vorverarbeitungs-Grenze, die ihn erzeugt. Die Verifikation hat den Wert unabhängig
  reproduziert. Das Risiko war *die Bedingung wird unbedacht angeschaltet*; sie ist bedacht
  ausgelassen.
- **Die Floskel-Liste ist die Stelle, an der dieser Slice sich selbst rot färben kann.** Sie
  entscheidet über rot und grün und wirkt rückwirkend auf **alle** Kandidaten. Eine Phrase gehört
  nur hinein, wenn sie im Bestand **null** Treffer hat — sonst färbt sie Notizen rot, die tragen,
  und die einzige Reparatur wäre eine Änderung an [`done/`](../done).
  — **Ausgang: entfallen.** `boilerplate:` ist nicht gesetzt, keine Phrase ist deklariert, und der
  Bestand unter [`done/`](../done) ist unverändert (`git diff --name-only` über den Slice-Umfang
  enthält keinen `done/`-Pfad). Was eine Aktivierung kostete, ist **gemessen statt vermutet** und
  in [`harness/README.md`](../../../../harness/README.md) benannt — die Verifikation hat den Wert
  mit `boilerplate: ["Platzhalter"]` unabhängig nachgestellt. Die Fehlform, vor der das Risiko
  warnt, kann aus diesem Slice nicht mehr eintreten.
- **Ein zweites Profil ist ein zweiter Ort, an dem eine Modul-Liste driften kann.** Fällt DoD (3)
  auf eine eigene Profil-Datei, gibt es danach zwei Konfigurationen für dasselbe Modul. Was in
  welcher steht und warum, gehört in
  [`harness/README.md`](../../../../harness/README.md) — die Klasse, die
  [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) für
  das Gate-Fragment schon einmal ausbuchstabiert hat.
  — **Ausgang: entfallen.** Die Bedingung ist nicht eingetreten: DoD (3) hat gegen ein eigenes
  `--config`-Profil entschieden, `closure` läuft im bestehenden `planning:`-Block am geteilten
  Durchsetzungspunkt, und der [`Makefile`](../../../../Makefile) bekam kein neues Ziel
  (`git diff` über den Slice-Umfang ist dort leer, unabhängig nachgeprüft). Es gibt keine zweite
  Konfiguration, die driften könnte.

## 7. Closure-Notiz (nach `done/`)

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register
(vorhandene Kennungen **zitieren** statt neu formulieren) · `grundlagen-traceability.md`
§Herkunfts-Anker (das Feld `liegt in` steht **nur**, wenn wirklich etwas verkörpert wurde).

- **Was hat funktioniert:** Die **Kontroll-Zeile neben der Null**. Der Basis-Lauf meldete
  `0 Befund(e)`, und genau dieser Wert ist die Form, vor der
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) warnt:
  ein grüner Gate über leerem Prüfbereich sieht identisch aus. Erst der zweite Lauf über derselben
  Kopie — §7 **einer** `done/`-Datei auf einen Satz gekürzt — trennte *„der Bestand hält die
  Schwelle"* von *„das Modul erreicht den Bestand nicht"*. Beide Läufe stehen mit Datei, Zeile und
  Grund-Code in [`harness/README.md`](../../../../harness/README.md), und beide sind in der
  Verifikation unabhängig reproduziert worden. Das Gegenstück dazu ist der billigste Befund der
  ganzen Welle: Die Adoptions-Schuld der Basis-Form war **null** — die Notizen dieses Repos hielten
  die Struktur-Schwelle bereits, bevor jemand sie prüfte.
- **Was ging anders als geplant:** Der Slice sollte einen Sensor verdrahten und tat das im ersten
  Anlauf; **alle** blockierenden Befunde lagen **neben** der Fähigkeit — in ihrer Begründung. Drei
  Review-Runden fanden vier HIGH/MEDIUM, von denen kein einziger die Konfiguration betraf: ein
  totes [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)-Zitat als tragende Begründung, ein nicht-rekursiver Prüfbereich unter einer
  Zusage, die *„jede"* sagte, eine Zuschreibung von zwölf Befunden zu einer Ursache, die acht
  trägt, und eine Baseline-Berufung ohne Mess-Tag. **Die Lehre ist die Asymmetrie:** Eine
  Config-Zeile ist in einer Stunde gemessen, ihre Begründung braucht drei Runden — und die
  Begründung ist das, was der nächste Lauf liest. Dazu ein Rollen-Fehler in derselben Richtung: Der
  ausführende Lauf setzte die eigenen DoD-Häkchen und strich dabei zwei Falsifikatoren, so dass die
  Verifikation beinahe gegen ein Kriterium geprüft hätte, das der geprüfte Lauf selbst geschrieben
  hat.
- **Steering-Loop-Eintrag — zwei, in zwei verschiedenen Formen.**
  **(a) Neuer Sensor:** Die Closure-Notiz-Pflicht verlässt den Feedforward-Quadranten.
  [`.d-check.yml`](../../../../.d-check.yml) setzt `planning.closure.dir: docs/plan/planning/done`;
  der Lauf ist `docs-check` in `make gates`, kein zweiter Ort. Der Eintrag trägt **kein** Feld
  `liegt in <Zielort>`: Ein Herkunfts-Anker `seit welle-13` wird gesetzt, wenn diese Welle schließt,
  nicht von einem ihrer Slices — die Anker-Paarung hat hier also keinen Gegenstand.
  **(b) Benannte Spec-Lücke:** *Ein Slice-Plan altert im Lifecycle gegen den Adaptions-Block, und
  kein Wächter sieht es.* Dieser Plan zitierte [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) viermal, am 2026-08-28 korrekt; am
  2026-08-31 löste [`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst) den Eintrag auf, und der Plan lag zu diesem Zeitpunkt im Lifecycle. Die
  Zitate wären mit dem `git mv` nach [`done/`](../done) eingefroren worden. **Kein Gate kann das
  finden:** Der Anker eines aufgelösten Eintrags bleibt nach
  [`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
  mit Absicht in der Index-Tabelle stehen, damit Verweise gerade **nicht** brechen — `links` und
  `anchors` sind über einem toten Zitat dauerhaft grün. Der Bestand ist gemessen, **kein
  Erwartungswert**:

  ```sh
  git grep -ln 'MR-016' -- '*.md' ':!.harness/baseline' ':!docs/plan/planning/done' \
    ':!docs/reviews' ':!harness/conventions' | wc -l
  ```

  Auslöser:
  [`BEO-ALL/retirierter-adaptions-eintrag-als-lebende-begruendung-zitiert`](../observations/BEO-ALL/retirierter-adaptions-eintrag-als-lebende-begruendung-zitiert/observation.md)
  — Zähler **1×**, also **unter** der Schwelle. Der Eintrag ist damit *gezählt, nicht verkörpert*;
  ob der Bestand nachgezogen wird und wie, ist eine Norm-Frage für den **Architect**
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8), nicht für diese Closure. **Was diese Closure getan
  hat, ist eng:** die vier Zitate **in dieser Datei**, weil sie einfriert und der Ersatz messbar ist
  — die Zwei-Datei-Form der Welle-Closure schreibt `modul-06-roadmap.md`
  §Wellen-Closure-Prozedur Schritt 3 der Baseline `v6.5.0` selbst vor, und kein Adaptions-Eintrag
  hat sie je getragen:

  ```sh
  tr '\n' ' ' < .harness/baseline/v6.5.0/regelwerk/modul-06-roadmap.md | tr -s ' ' \
    | grep -c 'Welle-Plan-Datei wandert per `git mv` von flach nach `done/`\*\* — neben ihre Ergebnis-Notiz'
  ```

- **Beobachtungs-Register (`../observations/`):** **vierzehn** Belege, davon **neun** in bestehende
  Verzeichnisse ergänzt und **fünf** Verzeichnisse neu angelegt. Alle vierzehn tragen denselben
  Vorgangs-Namen `slice-129` — drei Review-Runden und eine Verifikation über *einem* Slice sind
  **eine** Gelegenheit, kein vierfaches Auftreten. Zähler als Dateizahl abgelesen
  (`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, **keine
  Erwartungswerte**):
  [`fremdes-rollen-artefakt-im-implementations-kontext`](../observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/observation.md)
  **8×** ·
  [`lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
  **7×** ·
  [`verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md)
  **6×** ·
  [`zusammenfassung-staerker-als-ihre-quelle`](../observations/BEO-ALL/zusammenfassung-staerker-als-ihre-quelle/observation.md)
  **4×** ·
  [`kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle`](../observations/BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle/observation.md)
  **4×** ·
  [`zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`](../observations/BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht/observation.md)
  **4×** ·
  [`mutations-fall-deckt-den-lauten-statt-den-stillen-pfad`](../observations/BEO-ALL/mutations-fall-deckt-den-lauten-statt-den-stillen-pfad/observation.md)
  **2×** ·
  [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  **2×** ·
  [`gruen-aussage-ohne-herkunft`](../observations/BEO-ALL/gruen-aussage-ohne-herkunft/observation.md)
  **2×** · neu, je **1×**:
  [`retirierter-adaptions-eintrag-als-lebende-begruendung-zitiert`](../observations/BEO-ALL/retirierter-adaptions-eintrag-als-lebende-begruendung-zitiert/observation.md) ·
  [`sensor-pruefbereich-deckt-den-bewegten-ort-nicht`](../observations/BEO-ALL/sensor-pruefbereich-deckt-den-bewegten-ort-nicht/observation.md) ·
  [`baseline-aussage-ohne-mess-tag`](../observations/BEO-ALL/baseline-aussage-ohne-mess-tag/observation.md) ·
  [`commit-message-ohne-traceability-kennung`](../observations/BEO-ALL/commit-message-ohne-traceability-kennung/observation.md) ·
  [`zusage-nennt-zwei-kanten-der-sensor-deckt-eine`](../observations/BEO-ALL/zusage-nennt-zwei-kanten-der-sensor-deckt-eine/observation.md).

  **Der Beleg zählt das Auftreten, nicht den Rest im Baum.** Die Mehrzahl dieser Klassen ist
  innerhalb dieses Vorgangs behoben worden — **wie viele, steht hier nicht:** ob eine Behebung
  trägt, ist ein Urteil und kein Muster, und eine Zahl daneben gäbe ein Urteil als Messung aus.
  Sie trotzdem zu zählen ist die Regel und keine Strenge:
  Der Zähler misst Wiederholung über Vorgänge hinweg, und eine Klasse, die nur zählt, wenn sie
  ungefixt liegen bleibt, misst die Gründlichkeit des Reviews statt der Häufigkeit des Musters.
  Damit weicht diese Closure in **einem** Punkt von der Vorarbeit ab, die der Verifikations-Report
  §6 anbot (*„kein neuer Registerzähler-Zuwachs, da nichts unwidersprochen im Baum blieb"*) — die
  Vorlage dafür ist der Beleg `slice-201` desselben Eintrags, der ausdrücklich *„die Reichweite der
  Verkörperung"* misst.

  **Was diese Closure ausdrücklich *nicht* tut: den Lese-Schritt.** Dieses Repo führt
  Wellen-Betrieb, `welle-13` steht offen und dieser Slice gehört zu ihr — damit liegt der
  Lese-Schritt bei der **Welle-Closure**, nicht hier (Baseline-Regelwerk
  `modul-05-planning-harness.md` §Lifecycle als State Machine: *„vom Lese-Schritt (Welle-Closure;
  in einem Repo ohne Wellen-Betrieb löst ihn die Slice-Closure selbst aus)"*). Diese Closure
  **zählt**, sie **entscheidet nicht** — auch dort nicht, wo eine Klasse mit diesem Slice weit über
  der Schwelle steht. Als Übergabe an `welle-13` steht der Rückstand hier gemessen:

  ```sh
  for d in docs/plan/planning/observations/BEO-ALL/*/; do
    n=$(ls "$d"evidence/*.md 2>/dev/null | wc -l)
    s=$(grep -m1 '^\*\*Stand:\*\*' "$d"state.md | sed 's/\*\*Stand:\*\* //')
    [ "$n" -ge 3 ] && [ "$s" = "offen" ] && printf '%3s  %s\n' "$n" "$(basename "$d")"
  done | sort -rn
  ```
- **Folge-Slices: keiner.** Das ist eine Entscheidung und kein Versehen. Drei Befunde, die in
  diesem Repo je einen neuen Slice ausgelöst hätten, sind statt dessen in das Register gegangen —
  der Zeitpunkt des Sensors, die wandernde Zahl in `test/mutations/288`, die fehlende
  Traceability-Kennung. Alle drei stehen bei **1×**, also unter der Schwelle; für einen Slice-Schnitt
  wäre erst der Lese-Schritt der Welle zuständig. Die zwei Fragen, die einen Träger brauchen, haben
  ihn bereits: `slice-126` trägt den Commit-Sensor, und der Prüfbereich unter `done/<welle-id>/`
  hängt an dem Lauf, der [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md)
  produktiv nimmt — in [`harness/README.md`](../../../../harness/README.md) als Grenze benannt.
- **Risiken aus §6:** vier Risiken, vier Ausgänge — **drei *entfallen* mit Begründung, eines
  *weiter offen*** ins Register; siehe §6. Dass drei entfallen, liegt an derselben Bewegung wie bei
  der Vorgänger-Closure: Der Review hat die Fragen, die der Plan als offen führte, einzeln messen
  lassen, und die Antworten stehen seitdem als **entschiedene Grenzen** in
  [`harness/README.md`](../../../../harness/README.md) statt als Risiko in dieser Datei. Das vierte
  ist genau das Gegenstück — seine Bedingung war *aufgeschrieben*, und die Messung sagt, dass es
  nicht aufgeschrieben ist.
- **Vor dem `git mv` gemessen ([`AGENTS.md`](../../../../AGENTS.md) §3.11):** **acht** eingefrorene
  Artefakte nennen diese Datei als Pfad — drei unter `done/`, fünf Rollen-Reports —, außerhalb von
  Markdown **null**. `make slice-mv` nimmt keinen der beiden Bäume aus und schreibt sie im
  Nachzugs-Commit. Der Move ist trotzdem gefahren: Die Auflösung dieser Lage ist dem **Architect**
  zugewiesen, und bis dahin ist der bewegende Lauf der Träger — er hat hier gemessen und
  entschieden, statt es zu übersehen. Gezählt als sechster Beleg der Klasse.
- **Drei Paarungen:** **nicht dieser Closure geschuldet** — im Repo **mit** Wellen-Betrieb trägt
  sie die nächste Welle-Closure. Als Übergabe dennoch gefahren, mit Ergebnis: **(a) Anker** — der
  Steering-Loop-Eintrag trägt kein Feld `liegt in`, die Paarung hat keinen Gegenstand.
  **(b) Folge-Slice** — keiner genannt, kein Gegenstand. **(c) Register** — jede hier zitierte
  Kennung löst als Verzeichnis auf; die zweite Hälfte *„jede Registerzeile trägt mindestens einen
  Beleg"* meldet unverändert **einen** Eintrag ohne `evidence/`,
  `einstiegs-datei-weicht-von-der-pflichtgliederung-ab`. Das ist **kein** Rückstand und derselbe
  Fall, den die zwei vorigen Closures benannt haben: Der Eintrag führt sein einziges Vorkommen unter
  *Benannt, nicht gezählt*, und ein Vorkommen ohne abgeschlossenen Vorgang bekommt nach
  Baseline-Regelwerk `modul-06-roadmap.md` ausdrücklich keinen Beleg.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example). Ein Begründungsblock
entfällt: der Slice legt keine neue Sub-Area an und berührt keine in BF oder Hybrid. Die
Planungs-Ablage ist die dichteste Sub-Area des Repos — Modul 5 setzt den Lifecycle, Modul 6 die
Closure-Notiz als Wellen-Pflichtteil und mit ihr die Zwei-Datei-Form (Welle-Plan neben
Ergebnisnotiz, §Wellen-Closure-Prozedur Schritt 3). Einen Adaptions-Eintrag **dazwischen** führt
der Block nicht: `grep -rliE 'zwei[- ]datei|ergebnisnotiz|welle-plan' harness/conventions/` nennt
allein [`MR-035`](../../../../harness/conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl), und dort steht *„zwei Dateien"* über die Claude-Modul-Auswahl, nicht über die
Welle-Closure.
