# Slice slice-der-ci-lauf-ist-abrufbar: Der CI-Lauf zu einem Commit ist vom Baum aus abrufbar

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case.

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Eine Welle liegt vor, wenn es eine beobachtbare
Closure-Bedingung gibt, die **mehr** beobachtet, als die DoDs ihrer Slices schon
belegen (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle
braucht). Dieses *Mehr* fehlt hier: Der Beleg dieses Slice ist sein eigener
Abruf-Lauf, und `make gates` steht in seiner eigenen DoD — ein Welle-Trigger
schriebe sie ab. Wellenlose Arbeit erscheint nicht in der Roadmap; ihr Zustand
ist die Verzeichnis-Position.

**Bezug:** [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
(die Laufzeit-Untergrenze *git + docker*, an der die Werkzeug-Wahl hängt),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(ein Netz-Ziel ist kein Gate), [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)
(die CI auf frischem Klon ist die Quelle der Jobs).

**Berührte Spec-Stellen:** [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
· [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) —
beide aus `lastenheft.md` §4. Der Verweis zeigt **aufwärts**: Die Spec nennt
diesen Slice nie (Baseline-Regelwerk `grundlagen-referenz-richtung.md`
§Referenz-Richtung (SDP), `grundlagen-source-precedence.md` §ID-Schema als Klammer).

**Verantwortlich:** `—` bis zur Priorisierung.

**Autor:** Planner. **Datum:** 2026-09-14.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Der Lauf zu einem Commit ist vom Baum aus mit **einem** `make`-Ziel
abrufbar — welche der CI-Jobs liefen, mit welchem Ausgang, und die
Log-Abschnitte —, ohne Weboberfläche und ohne `gh`.

### Der Anlass ist am Baum gemessen

Modul 13 §Hard Rule (Doku-Disziplin) weist die Lauf-Wahrheit ausdrücklich nach
CI: *„die Sensors-Tabelle trägt keinen Lauf-Status; Lauf-Wahrheit pro Commit
liegt in CI"*. Dort liegt sie auch — und kein Ziel dieses Baums holt sie:

```sh
sed -n '/^jobs:/,$p' .github/workflows/ci.yml | grep -cE '^  [a-z][a-z0-9-]*:$'   # 5 Jobs
grep -c 'make ci-run' harness/README.md                                          # 0
grep -rn 'curl -fsSL' harness/tools/*.sh                                         # 3 Abrufe, alle in *-freshness.sh
```

Die fünf Jobs sind `gates`, `smoke`, `full-smoke`, `mutate` und `adr-immutable`.
**Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die erste Zahl wandert mit dem Workflow, die zweite mit dem Eintrag,
den dieser Slice setzt, die dritte mit den Netz-Tools. Tragend ist die zweite:
Solange sie null ist, gibt es den Abruf nicht.

### Der Weg ist `curl` gegen die GitHub-API, nicht `gh`

Keine Stilfrage. [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
setzt die Laufzeit-Untergrenze auf **git + docker**; die wörtliche Grenze
überschreitet schon der bestehende Freshness-Abruf — `curl` ist die etablierte,
längst bezahlte Ausnahme. Ein zweites Werkzeug (`gh`) wäre eine **zweite neue**
Host-Abhängigkeit samt Token-Haushalt, für dieselbe Antwort. Dass `gh` auf dem
Entwickler-Rechner bereitliegt, verschiebt die Untergrenze nicht: Sie gilt für
den frischen Klon, nicht für diesen Host.

### Die zwei Grenzen stehen hier, nicht in einer Fußnote

- **`cancel-in-progress: true`** (`.github/workflows/ci.yml`): Ein neuer Push
  bricht den Vorgänger ab. Ein abgebrochener Lauf ist **kein** Grün, und ein
  Commit, der nie Push-Spitze war, hat **gar keinen** Lauf. Beides wird mit
  eigener Meldung und Exit ≠ 0 **gesagt** — nicht als leeres Ergebnis
  ausgegeben.
- **Das Log altert** (GitHubs Aufbewahrung): Das Ziel ist ein Fenster auf den
  Lauf, keine Ablage. Was nicht zitiert ist, ist nach der Frist weg.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Gate.** Ein Gate läuft auf frischem Checkout ohne Netz
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)),
  und ein Upstream-Ausfall darf keinen Push blockieren — dieselbe Trennung, die
  `make regelwerk-check` und `make baseline-freshness` tragen. Ein Eintrag in
  `gates` wäre ein behauptetes Gate ohne die Deckung, die es behauptet.
  *Schicht-Abgrenzung.*
- **Kein `gh`.** Eine zweite neue Host-Abhängigkeit samt Token-Haushalt gegen
  die Untergrenze aus
  [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) —
  und `curl` trägt denselben Abruf, weil dieser Baum ihn schon führt.
- **Kein eigener Speicher.** Weder ein Lauf-Status-Feld noch ein Log-Archiv im
  Repo: Der Zustand liegt bei GitHub, eine Kopie daneben wäre eine zweite
  Quelle, die driftet — und die Sensors-Tabelle trägt ausdrücklich keinen
  Lauf-Status (Modul 13 §Hard Rule). Ein Log-Archiv wäre ein **anderer
  Vorgang** (Ablage und Aufbewahrung), nicht dieser.
- **Keine Emission ins Ziel-Repo.** Was ein Ziele-Repo an Werkzeugen bekommt,
  entscheidet der Slice, der die Tool-Ebene entscheidet: Der Slug und die CI
  des Ziels sind nicht die dieses Repos, und eine Emission trüge eine Zusage,
  die kein Ziel prüft. *Schicht-Abgrenzung: kein Produkt-Code unter
  `internal/`.*

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Was hier steht, ist die Grenze, an der ein wachsender Slice sich
messen lässt: Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den
Plan **geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [ ] **Liefer-Punkt 1 — das Ziel heißt `ci-run`.** `make ci-run` holt zu einer
      Commit-SHA (Vorgabe `HEAD`) den Lauf, dessen Jobs mit Status und Ausgang
      und das Log je Job, per `curl` gegen die GitHub-API; der
      `## `-Hilfetext nennt **„NICHT in gates"**. Fetch und Auswertung sind
      getrennte, einzeln aufrufbare Pfade — die Auswertung ist damit **netzlos**
      prüfbar, das Muster der bestehenden Netz-Tools
      ([`harness/tools/go-freshness.sh`](../../../../harness/tools/go-freshness.sh)
      `--normalize`/`--compare`, geprüft in
      [`test/go-freshness.bats`](../../../../test/go-freshness.bats)). Keine
      neue Host-Abhängigkeit über `git`, `docker` und das bestehende `curl`
      hinaus ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- [ ] **Liefer-Punkt 2 — die Lagen werden gesagt, nicht leer ausgegeben.** Drei
      Fälle tragen je eine eigene Meldung und einen eigenen Exit: **läuft noch**
      (Status genannt; die API liefert dann kein Log — *„logs will be available
      when it is complete"* ist die Lage, nicht ein leeres Ergebnis) · **kein
      Lauf zur SHA** (nie Push-Spitze oder vom Nachfolger abgebrochen,
      `cancel-in-progress: true`) · **Log nicht mehr da oder leer**
      (Aufbewahrung). Der benannte Fehl-Fall ist **einmal rot gesehen**: ein
      Abruf mit nicht auflösendem Repo-Slug oder unbekannter SHA endet Exit ≠ 0,
      und die **Ausgabe** ist gelesen, nicht nur der Exit-Code. Und der
      hermetische Wächter hat **Zähne**: ein Fall in `test/mutations/` verstellt
      die Auswertung so, dass `test-bats` rot fällt — nach
      [`AGENTS.md`](../../../../AGENTS.md) §3.6 ist ein neuer Wächter ohne
      gelisteten Fall **unbewacht**.
- [ ] **Liefer-Punkt 3 — Verdrahtung, beide Hälften.** Eine Zeile in
      [`harness/README.md`](../../../../harness/README.md) §Werkzeuge mit
      **„kein Gate"** in der Zeile selbst und einem Halbsatz, was das Werkzeug
      stattdessen tut — **und** ein Eintrag `ci-run` in
      `targets.exempt-targets` der [`.d-check.yml`](../../../../.d-check.yml).
      Nicht wahlweise: `test/targets-modul-wiring.bats` bindet die disjunkte
      Menge *§Sensors-Tabellenzeile XOR `exempt-targets`* und liest allein den
      §Sensors-Abschnitt der Autoritäts-Datei — eine §Werkzeuge-Zeile **ohne**
      `exempt-targets`-Eintrag färbt ihn rot. Der Name tritt zugleich in die
      Aufzählung der Gruppe (a) des `targets`-Kommentars derselben Datei ein,
      und dessen zwei Zählwerte wandern mit (sie stehen heute ohne Kommando
      da: `grep -n 'von 17' .d-check.yml` — wer sie bewegt, führt es nach
      [MR-025](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2 mit).
- [ ] Die drei Lagen aus Liefer-Punkt 2 sind **hermetisch** als Test geführt
      (`test/`), ohne je das Netz zu treffen — `test-bats` läuft mit
      `--network none` und färbt sonst in `make gates` rot.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `Makefile` | update | `.PHONY` + das Rezept `ci-run` mit seinem `## `-Hilfetext („NICHT in gates" in der Zeile, wie bei `smoke`/`full-smoke`/`baseline-freshness`); der Rumpf delegiert an das Skript, damit `shell-lint` ihn deckt |
| ein Skript `ci-run.sh` unter `harness/tools/` | neu | Fetch und Auswertung getrennt: `curl` gegen die GitHub-API (Lauf → Job-IDs → Log), daneben die reine Auswertung als eigener, netzlos aufrufbarer Pfad; die drei Lagen aus §2 als eigene Meldung und Exit |
| ein Sensor-Dokument `ci-run.md` unter `harness/sensors/` | neu | der Vertrag jenseits einer Tabellenzeile — die drei Lagen, die zwei Grenzen aus §1, der Rot-Fall, „kein Gate"; die Form, in der die übrigen Werkzeuge mit mehr als einem Satz Vertrag dokumentiert sind |
| `harness/README.md` | update | die §Werkzeuge-Zeile mit „kein Gate" in der Zeile und dem Halbsatz, was das Werkzeug stattdessen tut |
| `.d-check.yml` | update | `targets.exempt-targets`-Eintrag `ci-run` (Pflicht, s. §2 Liefer-Punkt 3) + Nachzug der Gruppe-(a)-Aufzählung im `targets`-Kommentar |
| eine Testdatei `ci-run-auswertung.bats` unter `test/` | neu | hermetisch über Fixture-JSON (Happy/Boundary/Negative: Lauf gefunden / läuft noch / kein Lauf / Log leer), `--network none` — nach [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| ein Fall `ci-run-…` unter `test/mutations/` | neu | der Zahn des neuen Wächters: verstellt `ci-run.sh` so, dass die bats-Datei aus der Zeile darüber rot fällt (`# files:` / `# expect:`-Kopf wie die bestehenden Fälle — `ls test/mutations/ \| wc -l` → **314**, kein Erwartungswert und wandert mit dem Satz) |

**Ansatz, der sich nicht auf eine Zeile herunterbrechen lässt:**

- **Der Repo-Slug wird abgeleitet, nicht gesetzt.** Er kommt aus der
  `origin`-Remote desselben Baums; eine zweite Konstante daneben wäre eine
  zweite Quelle für dieselbe Adresse.
- **Gesucht wird über `head_sha`, nicht über die Listenposition.** Der Lauf zu
  einer SHA ist die Anfrage; „der oberste Lauf" zeigte bei einem Zwischen-Push
  auf den falschen.
- **Ein Token ist optional, nicht Voraussetzung.** Ein `GITHUB_TOKEN` aus der
  Umgebung hebt nur das Rate-Limit (ein Header); ohne ihn bleibt der Abruf
  bedienbar. Das ist die Grenze, die §6 als Risiko führt.
- **Die SHA ist Parameter mit Vorgabe `HEAD`** — derselbe Baum soll den Lauf
  der Spitze ohne Argument zeigen.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Der Slice ist priorisiert
(`Verantwortlich:` gesetzt) und das WIP-Limit frei. Keine Vorbedingung aus einer
anderen Welle: Der Netzzugang, den das Werkzeug braucht, ist am Entwickler-Host
und im CI-Runner vorhanden und wird nicht beschafft.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Ausgabe über
  die drei Lagen hinaus eine vierte Achse bekommt (etwa eine Auswertung über
  mehrere Läufe oder ein Diff zweier Läufe) — dann ist der Schnitt ein anderer,
  nicht die DoD länger.
- `in-progress` → `open` (blockiert — Carveout?): wenn sich zeigt, dass die
  Job- und Log-Achse ohne authentifizierten Abruf nicht erreichbar ist — dann
  hängt der Slice an einer Token-Beschaffung, die kein Werkzeug dieses Repos
  leisten kann.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

`make gates` grün (darin `docs-check` und die neue hermetische bats-Datei über
`test-bats`); der Abruf einmal **real** gefahren und sein Ergebnis gelesen — die
drei Lagen und der Rot-Fall aus §2 Liefer-Punkt 2; Closure-Notiz mit
Steering-Loop-Lerneintrag.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der anonyme Abruf stößt an das Rate-Limit der GitHub-API.** Die Zahl der
  Anfragen je Stunde ist ohne Token klein, und ein Werkzeug, das im Alltag rot
  aus fremdem Grund steht, erzieht zum Überlesen.
  — **Ausgang:** <eingetreten: CO-NNN / slice-<Kennung> | entfallen: Grund |
  weiter offen: → BEO im Register>
- **Der hermetische Test misst die Fixture, nicht die API.** Die Auswertung ist
  über nachgebautem JSON bewiesen und über der echten Antwort nur behauptet;
  ändert GitHub die Feldnamen, bleibt der Test grün.
  — **Ausgang:** <eingetreten: CO-NNN / slice-<Kennung> | entfallen: Grund |
  weiter offen: → BEO im Register>
- **Der Lauf, den dieser Slice als Beleg zitiert, altert.** Das Log unterliegt
  GitHubs Aufbewahrung; ein in die Closure-Notiz zitierter Auszug ist nach der
  Frist nicht mehr nachlesbar, und der Beleg verliert seinen Gegenstand.
  — **Ausgang:** <eingetreten: CO-NNN / slice-<Kennung> | entfallen: Grund |
  weiter offen: → BEO im Register>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<NNN>` (<slice-kennung-a>, <slice-kennung-b>, <slice-kennung-c> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-<Kennung>.md` | `evidence/slice-<Kennung>.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-<Kennung> (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Zwei berührte Sub-Areas, beide in der
Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
geführt:

- `*` (gesamtes Repo, `ALL`) — `Makefile`, `harness/README.md`, `.d-check.yml`
  und `test/` liegen in keiner engeren Sub-Area der Deklaration.
- `harness/tools/` (`TOOLS`) — die neue Skriptdatei. Die drei Inklusions-Achsen
  (Baseline-Regelwerk `grundlagen-bootstrap.md` §Was ist eine Sub-Area?):
  **Achse 3** erfüllt (eigenes Verzeichnis), **Achse 1** erfüllt (dieses
  Verzeichnis trägt eigene Strukturregeln als
  [`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)
  und
  [`MR-047`](../../../../harness/conventions.md#mr-047--der-ort-der-ausführbaren-harness-tools-ist-keine-abweichung-mehr)) —
  Schwelle ≥ 2 von 3 damit erreicht; Achse 2 wird hier nicht beansprucht.

**Vorgelagert — offene Beobachtungen sichten:** Das Register zum
**gemergten** Stand durchgegangen; die Sub-Area jedes Eintrags ist `*`, die
Auswahl darum thematisch. Zähler-Stand = Zahl der Dateien unter dem `evidence/`
des Eintrags, abgelesen mit
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l` (kein
gespeicherter Wert —
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1). **Vier berührt:**

- [`BEO-ALL/roter-nicht-gate-sensor-ohne-instrument`](../observations/BEO-ALL/roter-nicht-gate-sensor-ohne-instrument/observation.md)
  — **1×, offen.** Ein Sensor, der kein Gate ist, kann rot aus einem fremden
  Grund stehen, und die Closure hat dafür keine Form. Konsequenz hier: Dieser
  Slice hängt seine DoD **nicht** an einen grünen Netz-Lauf. Der Beleg ist die
  hermetische Auswertung plus ein **absichtlich** herbeigeführter Rot-Fall —
  ein Vorbefund, den niemand herbeigeführt hat, kommt nicht vor.
- [`BEO-ALL/gruen-aussage-ohne-herkunft`](../observations/BEO-ALL/gruen-aussage-ohne-herkunft/observation.md)
  — **2×, offen.** Eine Aussage über einen Lauf trägt denselben Wortlaut für
  gemessen und für zitiert. Konsequenz hier: Die Ausgabe des Werkzeugs nennt
  ihre Herkunft — SHA, Run-ID, Job-Name, Status — statt „grün" zu behaupten.
  Erreicht der Eintrag mit diesem Slice einen dritten Beleg, ist er keine Notiz
  mehr, sondern eine Lücke mit eigener Adresse; dieser Slice verlängert ihn
  nicht, er vermeidet den Fall.
- [`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  — **6×, verkörpert** in [`AGENTS.md`](../../../../AGENTS.md) §3.6. Der neue
  hermetische Wächter ist genau der Fall der Klasse. Konsequenz hier: Er bekommt
  einen gelisteten Mutations-Fall (§2 Liefer-Punkt 2, §3) — kein neuer Wächter
  ohne Zahn.
- [`BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md)
  — **1×, offen.** Die Regel ist über der Fixture bewiesen und über der echten
  API nur behauptet. Konsequenz hier: Die Grenze steht in §1 (das Werkzeug sagt,
  was es zeigt und was es nicht weiß) und als Risiko in §6 — und sie deckt nur
  die **Auswertungs**-Hälfte: Für den Fetch gibt es keinen hermetischen Beleg,
  und dieser Slice behauptet keinen.

**Geprüft und nicht berührt** — die zwei Kandidaten dieser Fläche mit ihrem
Zähler-Stand, damit die Sichtung sichtbar ist und nicht bloß behauptet:

- [`BEO-ALL/rotierender-pruef-gegenstand-ohne-ort`](../observations/BEO-ALL/rotierender-pruef-gegenstand-ohne-ort/observation.md)
  — **1×, offen.** Gegenstand dort ist ein Baseline-Abgleich, dem ein stehender
  Ort fehlt; dieser Slice führt keinen solchen Abgleich.
- [`BEO-ALL/beleg-nach-dem-ausgang-findet-keinen-leser`](../observations/BEO-ALL/beleg-nach-dem-ausgang-findet-keinen-leser/observation.md)
  — **2×, offen.** Gegenstand dort ist der Zähler eines Register-Eintrags nach
  seinem Ausgang; hier altert ein **Log-Aufbewahrungsfenster**. Dieselbe Sorge
  eine Ebene daneben, aber ein anderer Träger — darum nicht als Treffer gezählt.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit
(beide Sub-Areas der Deklaration führen `Greenfield`).
