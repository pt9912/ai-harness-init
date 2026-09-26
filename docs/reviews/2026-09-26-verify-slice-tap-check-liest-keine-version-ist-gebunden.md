# Verifikationsbericht: slice-tap-check-liest-keine-version-ist-gebunden — 2026-09-26

**Rolle:** Verifier (Modul 8/11) — Frage: *Bauen wir es richtig?* gegen Plan, DoD und normative Quellen. Nicht die
Frage des Reviewers (Diff gegen Plan, ADR, Hard Rules) und nicht die des Validators.

**Gegenstand:** der Slice `slice-tap-check-liest-keine-version-ist-gebunden` (Kennung, nicht Pfad — der Plan wandert mit dem
Lifecycle, `AGENTS.md` §3.11) am Stand `main` = `e873b633`, Baum sauber, Stempel gedeckt. Implementer-Commits `cf186c0c`
(bats-Fall, Mutations-Fall), `026c1aff` (`docs/user/releasing.md` Schritt 7), `7551a7c4` (Ruhe-Marker, Beanspruchung); Review-Report
`5b3b0d95` (0 HIGH · 1 MEDIUM · 1 LOW · 3 INFO); Findings-Nachzug `e873b633` (`docs/user/releasing.md` Schritt 7, Absatz *Grenze*) —
**von keinem Reviewer gelesen**, hier selbst gegen Läufe gemessen. Nichts gepusht. Der Slice ist **nicht** geschlossen; dieser Bericht
setzt kein DoD-Häkchen und ändert weder Slice noch Code, Test, Doku noch ADR (`AGENTS.md` §3.10).

**Bezug:** `LH-QA-02` · `ADR-0064` (Festlegung 2, §Fitness Function) · `ADR-0066` (Festlegung 2) · `MR-071` · `AGENTS.md` §3.6, §3.7,
§3.10, §3.11.

**Methode:** Alle Läufe in Scratchpad-Kopien von `git archive HEAD` (kein `.git`), bats im gepinnten Bild des Makefiles
(`docker run --rm --network none -v <Kopie>:/code:ro … test/tap-nachzug.bats`, Rezept von `make test-bats`); nie im Repo-Baum mutiert
(`git status` blieb leer). Kein Host-Toolchain, kein `make mutate`, kein Tap-Zugriff. Der bekannte Kopie-Artefakt-Fall
`driver: die Kopie traegt den Sensor-Bedarf inklusive .git` ist in Läufen über ganz `test/` das einzige `not ok` und kein Befund.

---

## Gesamturteil

**Alle drei Liefer-Punkte sind bestätigt; kein Befund oberhalb INFO.** Der Zahn trägt: Fall und Mutations-Fall färben aus dem
behaupteten Grund rot, der Fall ist die einzige Deckung der Stelle (Gegenprobe grün ohne ihn), die Familie der 27 `tap-check`-Fälle ist
unbeschädigt. Der von keinem Reviewer gelesene Findings-Nachzug `e873b633` hält: jede Aussage in *Grenze* ist an einem eigenen Lauf
gemessen, auch die Aussage *„nicht gebunden"* samt einer Fixture, unter der die überlebende Mutation feuert (in der Implementer-Arbeit
nur das Überleben, nicht das Feuern gezeigt). Vorbehalte: die Bindung von `releasing.md` an die Fälle trägt weiter kein Gate (Register-Klasse,
Träger Review/Verifikation); die Assertions von Fall 13 hinter dem Exit-Vergleich sind nicht einzeln mutationsgebunden (INFO).

---

## Gelaufene Sensoren (Kommando und Ausgang)

| # | Lauf (Kopie von `HEAD`) | Ergebnis |
|---|---|---|
| A | `test/tap-nachzug.bats` unverändert | `1..38`, kein `not ok` |
| B | Mutation 452 (`bash test/mutations/452-…sh` in der Kopie) | `diff` gegen den Quell-Bestand: genau **eine** Zeile geändert (`grep -c '^>'` → 1), `sh -n` ok; `1..38`, **genau ein** `not ok 13 check liest keine Version: ungleiche Bytes mit groesserer Tap-Version …`, gelesene Meldung: ``[ "$status" -eq 1 ]' failed`` mit `Exit 0, stdout: tap-check: gleich — Tag v0.2.3, Tap-Kopf …` — die Mutation endet mit *gleich* statt Formel-Unterschied: die behauptete Ursache |
| C | 452 + Fall 13 aus der Kopie entfernt (Gegenprobe 1) | `1..37`, **grün**; über ganz `test/` (`1..388`) einziges `not ok`: das Kopie-Artefakt — **kein anderer Fall** deckt die Stelle |
| D | 452 + Fall 13 auf kleinere Version geschwächt (`0.2.2` statt `0.2.4`, Assertions angepasst; Gegenprobe 2) | `1..38`, **grün** — grün heißt bindet: der Fall bindet die Größer-Richtung |
| E1 | Ersatz-Mutation „kleinere Tap-Version gilt als gleich" (`awk`-Stringvergleich, ohne Kopie des Anlage-Musters) | `not ok 3 vorfall nachgestellt`, `not ok 30 exit-zeile`, `not ok 35 unterschied` |
| E2 | Ersatz-Mutation „gleiche `version`-Zeile bei ungleichen Bytes gilt als gleich" | `not ok 2 vergleich verschieden`, `4 vergleich byte-genau`, `8 cache-fenster: erst alt`, `9 cache-fenster: beide Male alt`, `11 cache-fenster: die Wartezeit` |
| E3 | Ersatz-Mutation „Tap-Version größer **und** mehr als eine Zeile weicht ab gilt als gleich" (differierende Zeilen per `awk` gezählt) | `1..38`, **kein** `not ok` — überlebt |
| F | E3 + zusätzlicher Fall (Tap `0.2.4` mit zweiter abweichender Zeile `MIT`→`BSD`, erwartet Exit 1): unmutiert / unter E3 / unter 452 | unmutiert `1..39` grün; unter E3 `not ok 39`, Meldung `Exit 0, stdout: tap-check: gleich …` — **die überlebende Mutation feuert unter einer passenden Fixture**; unter 452 zusätzlich `not ok 13` und `not ok 39` |
| G | alle 27 Fälle der Familie (`409`–`434`, `452`), je Fall in frischer Kopie angewandt, `test/tap-nachzug.bats` gefahren | jeder Anker wirkt (Änderung in `harness/tools/`), jeder Fall färbt **einen Fall mit seinem `# expect:`-Text** rot; `452`: rot=1. Meine erste Auswertung verwarf vier Fälle (410, 411, 413, 434) wegen eines Kürzungs-Fehlers im Skript (`cut -c1-90` schnitt lange Namen ab); die Wiederholung mit voller Namenslänge trifft bei allen vieren. `411` färbt zusätzlich Fall 13 (dessen Zählung `tap_lesungen` = 2) |
| H | `git ls-files -s test/mutations/452-…sh`; Familie | `100755`, wie alle 27 der Familie (`git ls-files 'test/mutations/*tap-check*' \| wc -l` → 27) |
| I | Anker (MR-071): `grep -cP '^\t1\) return 1 ;;$' harness/tools/tap-nachzug-nutzlast.sh`; das `sed`-Muster des Falls als `p`-Adresse | je **1** Treffer, im Zweig *cmp meldet Unterschied* von `gleich()` |
| J | `grep -c '^@test' test/tap-nachzug.bats` | `38` |

Die Ersatz-Mutationen E1–E3 sind nach der Beschreibung im Review nachgebaut, mit eigener Implementierung (Stringvergleich
per `awk` statt `sort`); das Verdikt stimmt mit dem des Reviews überein.

---

## DoD, Punkt für Punkt

### Liefer-Punkt 1 — der bats-Fall: **bestätigt**

Fall `check liest keine Version: …` (Zeilen 262–275 von `test/tap-nachzug.bats`): Asset `0.2.3`, Tap `0.2.4` mit **ungleichen Bytes**
(die Vorbedingung `digest(asset) != digest(tap024)` schützt vor dem Leerlauf), Assertions: Exit 1 · `Formel-Unterschied` ·
`Tap [  version "0.2.4"]` · letzte stderr-Zeile `tap-check: Exit 1` (gelesen aus `stderr_lines[-1]`, nicht der Prozess-Exit, `ADR-0066`
Festlegung 2) · zwei Tap-Lesungen. Auf unverändertem Code grün (A). Rot unter der Mutation der Kurzrunde (B), Meldung gelesen.
Die Zusage ist auf das Gebundene eingeschränkt (Fallkommentar; D belegt: kleinere Version bindet er nicht, E1/E2: die anderen Formen
binden andere Fälle). **Vorbehalt (INFO V-2):** unter der Mutation bricht die erste Assertion ab; die Assertions auf Meldung, Tap-Version
und Exit-Zeile werden dort nicht erreicht und sind von mir nicht einzeln geschwächt. Die Zählung der Lesungen hat einen eigenen Zahn
(Mutation 411 färbt Fall 13, G). Die DoD verlangt die Mutation aus Liefer-Punkt 1, nicht je Assertion einen Zahn.

### Liefer-Punkt 2 — der Mutations-Fall samt Gegenprobe: **bestätigt**

Kopf: `# files:` die Nutzlast, `# expect: check liest keine Version: ungleiche Bytes` (Präfix des Fall-Namens), `# verify: test-bats`;
Modus `100755` im Index (H); Nummer 452 frei (höchste Nummer im Verzeichnis nach `ls test/mutations | sort -n | tail -1`). Anker nach
`MR-071` gegen den heutigen Bestand: eine Zeile (I), `diff` der Mutation: eine Zeile (B). Rot mit dem Namen aus `# expect:` und der
behaupteten Ursache (B); Gegenprobe 1 grün = kein anderer Fall deckt die Stelle, auch nicht in der ganzen Suite (C); Gegenprobe 2 grün =
der Fall bindet die Größer-Richtung (D). **Weg des Einzelfalls:** Kopie, Anker von Hand angewandt (`bash test/mutations/452-…sh`), bats
über das `make test-bats`-Bild; ein Einzelfall-Lauf über `make mutate` ist mir untersagt und nicht gefahren. Die Kopf-Angabe `# files:`
löst der Treiber auf; diese Auflösung habe ich weder gelesen noch über den Treiber gefahren.

### Liefer-Punkt 3 — der Text trägt nur, was gebunden ist: **bestätigt**

`grep -n 'der Zahn fehlt' docs/user/releasing.md` trifft nicht mehr (0). Die Aussagen des Absatzes *Grenze* in Schritt 7 einzeln:

| Aussage im Text | Beleg |
|---|---|
| *gebunden:* gleiche Bytes → Exit 0, auch mit `version`-Zeile außerhalb der Feldform und ohne jede `version`-Zeile | Fall `version-zeile: in check …` (251–260): beide Hälften stehen im Fall (Kommando `grep -n 'version-zeile: in check'` → ein Treffer) |
| *gebunden:* ungleiche Bytes, **größere** Tap-Version, nur die `version`-Zeile weicht ab → Exit 1, Formel-Unterschied, `tap-check: Exit 1` | Fall 13, B/D |
| Mutations-Fall `test/mutations/452-…` färbt „einen Vergleich, der bei ungleichen Bytes die `version`-Zeilen liest und bei größerer Tap-Version, **deren Zeile allein abweicht**, mit Exit 0 endet" | B; die Einschränkung *allein abweicht* stimmt mit F überein (452 färbt zusätzlich die Probe, der Text ist damit enger als gebunden, nicht weiter) |
| kleinere Tap-Version als gleich → färbt `vorfall nachgestellt`, `exit-zeile`, `unterschied` | E1: exakt diese drei (3, 30, 35) |
| gleiche `version`-Zeile bei ungleichen Bytes als gleich → färbt `vergleich verschieden`, `vergleich byte-genau`, `cache-fenster: erst alt`, `cache-fenster: beide Male alt`, `cache-fenster: die Wartezeit` | E2: exakt diese fünf (2, 4, 8, 9, 11) |
| *nicht gebunden:* größere Tap-Version als gleich, sobald außer der `version`-Zeile weitere Zeilen abweichen; „keiner der `38` Fälle wird von ihm rot" | E3 überlebt `1..38`; F zeigt: unter passender Fixture feuert sie. Die Aussage ist für jede Variante dieser Beschreibung tragfähig: E3 feuert auf **jeder** Eingabe „größer und weitere Zeile weicht ab"; eine strengere Bedingung feuert auf einer Teilmenge und überlebt damit erst recht — solange sie sonst nichts ändert |
| Fall-Namen (acht) je einzeln mit `grep -n` auf den Namen in `test/tap-nachzug.bats` | alle zehn genannten Namen (die acht der Aufzählung, dazu `version-zeile: in check`, `check liest keine Version`) treffen je genau einen `@test`; `vorfall nachgestellt` trifft zusätzlich eine Kommentarzeile des neuen Falls (INFO V-1) |
| `38` neben `grep -c '^@test' test/tap-nachzug.bats` | J: `38`; die Zahl hängt an der Aussage *„keiner der 38 Fälle"* (R1-3 des Reviews erledigt) |
| Rest des Absatzes (`grep -ci version …`, *„Bytes, keine Versionen"*, *„Vorwärts-Schutz allein bei der Vorbedingung"*) unverändert | `git diff 3be0f3c4..HEAD -- docs/user/releasing.md` berührt nur den Satzblock zwischen *„Exit 0, weil die Bytes gleich sind"* und dem `grep -ci`-Kommando (§1 des Plans: Rest bleibt) |
| Schritt-Nummerierung | unverändert (`Schritt 7` in Schritt 8 und in Zeile 202 zeigt auf `tap-check`), `grep -rnE 'Schritt(e)? [0-9]' docs/user harness README.md` |
| Zustandsform (`AGENTS.md` §3.7, Setzung *Ist-Zustand*) | Indikativ, keine Chronik, kein Konjunktiv über die verworfene Alternative, keine Rolle, kein Slice-Name; der Slice steht nirgends in `releasing.md` |

**Doku-Update-Punkt (DoD):** `harness/README.md` (Zeile `make tap-check`) und der Makefile-Kommentar des Ziels berühren die Eigenschaft *„check
liest keine Version"* nicht; `git diff 3be0f3c4..HEAD --name-only` berührt beide nicht. Der DoD-Satz *„entfällt"* trägt.

### Gates, Review, Pro-Slice-konstant

- `make gates` grün: Belege des Implementers und des Reviews; von mir am Stand dieses Berichts nach dem Commit gefahren (in der Übergabe genannt,
  nicht in diesem Text — er wäre selbst Teil des Stempel-Hashs).
- Review: Report liegt vor (`docs/reviews/2026-09-26-slice-tap-check-liest-keine-version-ist-gebunden.md`); R1-1 (MEDIUM), R1-2 (LOW), R1-3
  (INFO) durch `e873b633` gezogen — von mir gemessen (Tabelle oben), nicht durch einen zweiten Review-Durchlauf. R1-4, R1-5: INFO,
  bestätigt.
- Closure-Notiz, Lerneintrag, DoD-Häkchen, Register-Fortschreibung, Risiko-Ausgänge, Paarungen: **nicht gesetzt** (Planner, `AGENTS.md` §3.10);
  die Slice-Datei trägt keine Häkchen und §7 ist leer.

---

## Plan-vs-Code-Diff

`git diff 3be0f3c4..HEAD --stat` (Basis: Stand vor dem Slice):

| Datei | Plan | Ist |
|---|---|---|
| `test/tap-nachzug.bats` | update, ein Fall | +15 Zeilen, ein Fall (262–275) — geplant |
| `test/mutations/452-tap-check-liest-versionen-bei-ungleichen-bytes.sh` | neu, Nummer/Name/Modus gemessen | +14 Zeilen, `100755` — geplant |
| `docs/user/releasing.md` | update, Satz über den Zahn | +29/−12 im Absatz *Grenze* von Schritt 7 — geplant; der Umfang (zwei weitere Formen, die die Suite über andere Fälle bindet) geht über *„ersetzt den Satz"* hinaus, folgt aber aus Review R1-1 und dem Plan-Satz *„nur, was gebunden ist"* |
| Slice-Datei (`open/` → `next/` → `in-progress/`) | Lifecycle | zwei reine `make slice-mv`-Moves plus Verweis-Nachzug (§3.3); ein Zeilenwechsel in §4 (die Mess-Kommando-Pfadangabe zieht mit dem Ort) |
| Roadmap (Ruhe-Marker) | nicht im §3 des Plans | −3 Zeilen: der Marker *„Nichts in Arbeit"* entfällt, solange `in-progress/` beansprucht ist |
| Review-Report | DoD | `docs/reviews/2026-09-26-slice-tap-check-liest-keine-version-ist-gebunden.md` |

**Gebaut, nicht geplant:** (1) der Ruhe-Marker-Eingriff in der Roadmap — Träger ist die Regel des Kurses (Marker steht genau dann, wenn
`in-progress/` leer ist, `modul-06-roadmap.md`), im §3 des Plans nicht als Berührung genannt; er ist eine Folge des Anspruchs, keine
Zusatzarbeit, und ihn wiederherzustellen ist ein Schritt der Closure (Planner). (2) Zwei Zusatz-Assertions im Fall (Tap-Version in der Meldung,
zwei Lesungen) über das hinaus, was DoD Punkt 1 nennt — enger als eine Erweiterung der Zusage, sie erhöhen die Bindung des Falls.
**Geplant, nicht gebaut:** nichts. Die Abgrenzung §1 hält: kein Produkt-Code (`git diff 3be0f3c4..HEAD --stat -- harness .claude Makefile internal`
ist leer), kein Eingriff in `sync` und in dessen Slice-Datei (`git diff --name-status 3be0f3c4..HEAD -- docs/plan/planning/open` nennt allein
den Move des eigenen Slice), ADRs unberührt (`git diff … -- docs/plan/adr` leer), Bestand `done/` und die Beobachtungs-Verzeichnisse nicht
angefasst.

**Größe:** drei Liefer-Punkte (Fall · Mutations-Fall · Text); Schichten: Test und Nutzer-Doku (zwei) — innerhalb der Grenzen aus
`modul-05-planning-harness.md` §Ziel-Form: Slice.

---

## Findings

Kein HIGH, kein MEDIUM. Klasse der DoD-Verletzung (Verifier-only): **keine**.

**V-1 (INFO)** — `pfad`: `docs/user/releasing.md`, Absatz *Grenze* · `befund`: die acht Fall-Namen sind je einzeln auffindbar, aber als kurze Wörter
(`unterschied`, `exit-zeile`); sie tragen heute genau einen Treffer je Wort, jeder weitere Fall mit einem der Wörter im Namen würde die
Auffindbarkeit verwässern. `grep -n 'vorfall nachgestellt'` trifft bereits zwei Zeilen (Fall und Kommentar des neuen Falls). Zusage an
die Fall-Namen, kein Gate hält sie. · `klasse`: Zeiger auf Namens-Präfix ohne Wächter.

**V-2 (INFO)** — `pfad`: `test/tap-nachzug.bats:262-275` · `befund`: unter Mutation 452 bricht die erste Assertion den Fall ab; Meldung, Tap-Version
und `tap-check: Exit 1` in Fall 13 hat kein eigener Zahn in diesem Slice (die Klassen bindet Fall 2/3/30, Review R1-5 nennt dasselbe). Eine
Zusage darüber steht in DoD und Text nicht. · `klasse`: Assertion unter der gewählten Mutation nicht erreicht.

**V-3 (INFO, Nachprüfungs-Fehler, korrigiert)** — mein erster Familien-Lauf meldete für vier Fälle `expect-Treffer=0`; Ursache war eine
Kürzung meiner Auswertung auf 90 Zeichen. Wiederholt ohne Kürzung: alle vier färben ihren Fall. Kein Befund am Slice; genannt, weil die
Instrument-Regel (Nachprüfung erbt den Defekt) den Lauf ohne Nennung unglaubwürdig machte.

---

## Nur gelesen, nicht gemessen

- `make gates` und `make mutate`: nicht als Einzelbeleg gefahren (`make mutate` ist mir untersagt); die Familie ist stattdessen einzeln
  in Kopien emuliert (Tabelle G) — das ist **nicht** der Treiber-Lauf: `# verify: test-bats` fährt der Treiber über `test/`, ich
  über `test/tap-nachzug.bats`; die Ganz-Suite-Gegenprobe (C) ist für Fall 452 gefahren, für die 26 Altfälle nicht.
- Die Kopf-Angabe `# files:` und ihre Auflösung durch den Treiber: weder gelesen noch gefahren; geprüft ist allein, dass die genannte Datei existiert und der Anker sie trifft.
- Dass kein Gate `releasing.md` gegen die Fälle hält, ist die benannte Deckungslücke des Plans; Träger ist Review und diese Verifikation, kein
  Sensor. Die Aussagen in *Grenze* gelten für den Stand `e873b633`; ein neuer Fall in `test/tap-nachzug.bats` verschiebt die Zahl `38`
  und kann die Namensauffindbarkeit (V-1) ändern.
- Die Instrument-Frage der Emulation: E1–E3 setzen die Mutations-Bedingung selbst (`awk`); dass der Stub-`curl` und die Formel-Fixture
  `formel` dieselben Bytes wie ein reales Tap tragen, ist nicht Gegenstand (hermetische Suite).

---

## Übergaben an den Planner (Fakten, Urteil beim Planner)

1. **§6-Risiko 1 (Anker nach dem `sync`-Slice verschoben):** heute trifft der Anker genau eine Zeile (I). Der `sync`-Slice liegt weiter in `open/`,
   die Nutzlast ist seit Slice-Beginn (`git diff 3be0f3c4..HEAD -- harness`) unverändert. Nicht eingetreten. Kandidat laut Plan: *weiter offen* →
   `BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet` (dort 5 Belege-Dateien, verkörpert als `MR-071`).
2. **§6-Risiko 2 (Fall bindet nur eine Form):** die Einschränkung steht in Fallkommentar, Fall-Name und Text. Der Review nennt in R1-1 die Form
   *größere Tap-Version bei weiteren abweichenden Zeilen* als von der Suite ungefärbt; ich habe sie gemessen (E3) und ihr Feuern gezeigt (F). Ob sie
   *zusagenswert* ist (Plan-Kriterium für *weiter offen*), habe ich nicht beurteilt; ein Fall mit meiner Fixture wäre lieferbar (F lief in einer Kopie, nichts
   im Repo).
3. **§6-Risiko 3 (Mutation färbt mehrere Fälle):** `452` färbt genau einen Fall (B, G: rot=1); eingetreten nicht. Kandidat laut Plan: *entfallen*
   (Gegenprobe C trennt den Fall von den anderen); ein Beleg im Register (`mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere`, 1 Evidence-Datei) entsteht nur
   bei Eintritt.
4. **Register-Klasse `doku-zusage-nennt-den-test-dessen-fall-nur-einen-ausschnitt-misst`** (1 Evidence-Datei: die Kurzrunde vom 2026-09-25, `state.md`
   `offen`, Träger *Review des Textes*): der Slice hat die Instanz M-1 geheilt und am Ausgangstext `026c1aff` eine **zweite Instanz** erzeugt, die der Review
   fand (R1-1: *„nicht gebunden"* über Formen, die die Suite über andere Fälle bindet; R1-2: Allsatz *„ein Vergleich, der …"*) und `e873b633`
   behoben hat. Ein zweiter Beleg-Kandidat mit Vorgangs-Kennung wäre der Slice selbst (Zählregel: ein Vorgang zählt einmal; der Slice ist noch
   nicht abgeschlossen). Der Ausgang der Klasse ist mit diesem Slice **nicht** geliefert: kein Wächter hält `releasing.md` gegen die Fälle (Deckungslücke im Plan
   benannt, in diesem Lauf bestätigt); *verkörpert* oder *geplant* hätten eine Regel/einen Slice zur Voraussetzung, den dieser Slice nicht schreibt. Mein Lauf
   hat keine dritte Instanz gefunden (V-1 ist Zeiger ohne Wächter, eine andere Klasse).
5. **Berührungspunkt `slice-tap-nachzug-sync-schreibt-die-formel-ins-tap`:** dessen Datei (`open/`) ist unberührt. Sie nennt in der Abgrenzung den Satz
   *„der Zahn fehlt"* in Schritt 7 als Gegenstand dieses Slice; der Satz steht nach `026c1aff` nicht mehr da (`grep -n 'der Zahn fehlt' docs/user/releasing.md` → 0). Sie
   sagt selbst, sie nehme den Absatz *„an ihrem Start in dem Stand, in dem er liegt"*. Der Absatz *Grenze* trägt jetzt zwei Formen von Aussagen über Versions-Lektüre; die vier
   alternden Aussagen (*Handgriff*, *einziges Tap-Ziel*, *ein Nachzug von Hand …*, `grep -ci version` samt *„Bytes, keine Versionen"*) sind unverändert und liegen
   bei jenem Slice.
6. **Ruhe-Marker der Roadmap:** entfernt (`7551a7c4`), solange `in-progress/` den Slice trägt; Wiederherstellung beim Abschluss ist ein Schritt der Closure. Stand jetzt:
   `ls docs/plan/planning/in-progress/` nennt `roadmap.md` und die Slice-Datei.
7. **Prozedur-Wiedergabe-Klasse** (`BEO-ALL/prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle`, 2 Evidence-Dateien): der Plan (§8) rechnete mit einem
   dritten Beleg, wenn der Review den neuen Satz als weiter reichend als seine Quelle liest. Der Review hat R1-1/R1-2 der **Zahn-Klasse** zugeordnet, nicht dieser;
   mein Lauf findet in *Grenze* keine Aussage, die weiter reicht als der Sensor, der sie deckt.
8. **Finding-Klassen des Reviews** (in Closure §7 und Zähler): Doku-Zusage nennt als ungebunden, was die Suite über einen anderen Fall bindet · Zusage über *„ein Vergleich, der …"*
   bindet die eine Mutations-Form · Zahl neben Kommando ohne die Aussage, die sie stützt · zwei offene Slices berühren denselben Absatz · Assertion unter der Mutation nicht
   erreicht. Aus meinem Lauf kommt keine neue Klasse hinzu (V-3 ist ein eigener Instrument-Fehler).
9. **§3.10:** die Slice-Datei trägt keine Häkchen, §7 ist leer, in den Commits des Slice steht kein Closure-Artefakt; der Abschluss (Notiz, Häkchen, Register, `git mv` nach
   `done/`) liegt beim Planner.
