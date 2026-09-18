# Slice slice-das-ziel-prueft-seine-durchsetzung-selbst: Das gebootstrappte Ziel bekommt die Selbstprüfung seiner Durchsetzungsschicht — und fährt sie einmal real

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case.

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Begründung in §1 *Warum wellenlos* — geprüft gegen
Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht (Modul 6).

**Bezug:** [`LH-FA-11`](../../../../spec/lastenheft.md#lh-fa-11--selbstprüfung-der-durchsetzungsschicht-emittieren)
(tragend — die Anforderung, die dieser Slice liefert),
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
(die emittierte Fassung reist mit adaptierbaren Markern),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(kein Artefakt aus dem Nichts — die emittierte Fassung wird im Emitter-Lauf real gefahren),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
(das Ziel bekommt keine neue Abhängigkeit),
[`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md)
(Klasse des Trägers — die Selbstprüfung liest sie, sie ändert sie nicht),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl dieses Plans steht neben ihrem Kommando).

**Berührte Spec-Stellen:** [`LH-FA-11`](../../../../spec/lastenheft.md#lh-fa-11--selbstprüfung-der-durchsetzungsschicht-emittieren)
— das Zielelement trägt eine Kennung, deshalb steht sie statt eines `§`-Ankers. Der Verweis
zeigt **aufwärts**: die Spec nennt diesen Slice nie. Geändert wird die Spec **nicht** — sie ist
mit dem CR 0.20.0 geschrieben, dieser Slice löst sie ein.

**Verantwortlich:** Implementer (pt9912) — gesetzt mit der Priorisierung (Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine: der Übergang `open→next` setzt sie).

**Autor:** Planner. **Datum:** 2026-09-18.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Ein gebootstrapptes Zielrepo bekommt eine **ziel-eigene** Selbstprüfung seiner
emittierten Durchsetzungsschicht und kann sie über sein eigenes `make` fahren: Sie klont das
Repo des Ziels lokal, stellt fest, dass `core.hooksPath` im frischen Klon **leer** ist,
aktiviert dort den Träger der Commit-Kennung, lässt einen Commit **ohne** Kennung scheitern,
einen **mit** Kennung durchgehen und fährt `make gates` im Klon grün — **beide Ausgänge in
einem Lauf**. Sie reist als Vorlage mit **adaptierbaren Markern** (Träger-Pfad ·
Aktivierungsschritt · Gate-Kommando), und der Emitter fährt sie in seinem eigenen
`make full-smoke` **einmal real** am gebootstrappten Ziel durch.

### Warum ein eigener Slice und nicht der vorhandene

[slice-aktivierung-reist-nicht-mit-dem-klon](../open/slice-aktivierung-reist-nicht-mit-dem-klon.md)
ist der nächstliegende Plan und nimmt diesen Gegenstand **nicht** an — aus drei Gründen, jeder
an seinem Text nachlesbar:

1. **Er schließt die Schicht aus, in der dieser Slice liefert.** Sein §1 führt
   *„Ein Eingriff in die emittierte Ebene (Fragment, Prüfung, `internal/emit/**`) —
   Schicht-Abgrenzung: kein Produkt-Code"*. Dieser Slice **ist** ein Eingriff in
   `internal/emit/**`: er legt eine neue emittierte Vorlage an. Ein Folge-Slice, der den
   verwiesenen Punkt selbst ausschließt, ist keine Adresse (Baseline-Regelwerk
   `modul-05-planning-harness.md` §Ziel-Form: Slice, Klasse 1).
2. **Er misst von außen, die Anforderung grenzt sich davon ab.** Sein Gegenstand ist der
   E2E **des Emitters**: `make full-smoke` legt einen Klon des Ziels an und liest ihn.
   [`LH-FA-11`](../../../../spec/lastenheft.md#lh-fa-11--selbstprüfung-der-durchsetzungsschicht-emittieren)
   trennt genau hier: *„[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
   prüft dasselbe Ziel **von außen** … hier fährt das Ziel **sich selbst**"*. Der Träger der
   Zusage ist also ein Artefakt **im Ziel**, das der Adopter nach dem Bootstrap ohne den
   Emitter fahren kann.
3. **Die Größenregel.** Jener Plan trägt bereits drei Liefer-Punkte; ein vierter machte ihn
   zu groß (≤ 3, dieselbe Sektion des Regelwerks). Die Übernahme änderte seinen Plan, statt
   ihn zu ergänzen.

Die zwei Slices berühren dieselbe Mechanik aus zwei Richtungen und bleiben getrennt: dort die
Messung des Aktivierungs-Rezepts **durch den Emitter**, hier die **Emission** einer Prüfung,
die das Ziel selbst besitzt. Ihre Serialisierung steht in §4.

### Warum wellenlos

Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht: Eine Welle liegt vor,
wenn ein Closure-Trigger **mehr** beobachtet, als die DoDs ihrer Slices ohnehin belegen. Hier ist
es ein Slice; sein Closure-Trigger schriebe seine eigene DoD ab — der dort benannte Regelfall für
wellenlose Arbeit. Die repo-weiten Belege (`make gates` im eigenen Baum, Replay) trägt dieser
Schnitt nicht.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Emitter-seitige Messung des Aktivierungs-Rezepts** — die drei negativen Fälle (Träger
  fehlt · Träger ist ein Verzeichnis · `HOOKS_DIR` wirkt) und der Nachweis, dass der Träger mit
  dem Klon reist und seine Aktivierung nicht. **Folge-Slice mit Adresse:**
  [slice-aktivierung-reist-nicht-mit-dem-klon](../open/slice-aktivierung-reist-nicht-mit-dem-klon.md),
  dessen §2 (1) und (2) genau diese Punkte führen — die Adresse nimmt sie an, weil sie sein
  eigener Gegenstand sind.
- **Der bestehende Abschnitt `COMMIT-KENNUNG IM ZIEL` in `harness/tools/full-smoke.sh`** —
  **Bestand bleibt bewusst stehen.** Er misst das Ziel **von außen** und ist damit die
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Hälfte,
  von der sich diese Anforderung abgrenzt. Ihn umzubauen nähme die eine Messung weg, die dort
  heute trägt, und verwischte die Trennung, die der CR gezogen hat.
- **Ein Vergleichs-Sensor zwischen der Dogfood-Fassung des Aktivierungs-Rezepts und der
  emittierten** — **anderer Vorgang.** Der Gegenstand ist im Register benannt
  ([`zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`](../observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/observation.md)
  · [`emittierter-stand-laeuft-dem-dogfood-voraus`](../observations/BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus/observation.md));
  ein Sensor über zwei Fassungen ist kein emittiertes Artefakt und hätte je Fassung einen
  eigenen Bau.
- **Jede Änderung an der Durchsetzungsschicht selbst** — `commit-msg-hook.sh`,
  `commit-msg-traceability.sh`, `hooks-install.mk` — **Schicht-Abgrenzung.** Das ist
  [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren);
  dieser Slice **fährt** sie und ändert sie nicht. Fällt die Selbstprüfung an einer dieser
  Dateien, ist das ein Befund an ihnen, kein Nachzug hier (§4, Rückführung).
- **Ein neues `make`-Ziel dieses Repos und die Prosa darüber** — `harness/README.md` §Sensors
  und §Werkzeuge, `harness/sensors/**` — **Schicht-Abgrenzung: keine Harness-Selbstbeschreibung.**
  Dieser Slice legt hier kein Target an; die neue Stufe lebt **in** `make full-smoke`, das dort
  bereits als `kein Gate` geführt ist. Die Prosa der emittierten Vorlage steht in ihrem eigenen
  Kopf, im Ziel.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Suchreihenfolge: Was übernimmt ein **Folge-Slice** (mit
Kennung — und die Kennung muss den Punkt auch annehmen)? Was bleibt als
**Bestand** bewusst stehen (mit Begründung)? Was wäre ein **anderer Vorgang**?
Welche **Schicht** rührt der Slice nicht an?

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

Die Akzeptanzkriterien aus
[`LH-FA-11`](../../../../spec/lastenheft.md#lh-fa-11--selbstprüfung-der-durchsetzungsschicht-emittieren)
gehen in diesen drei Punkten **auf**; keines steht daneben. Die Zuordnung: *Happy Path* und
*Minimal* → (1) · *Zähne — beide Ausgänge in einem Lauf*, *Adaptierbar* und *Benannte Grenze*
→ (2) · *Kein aus dem Nichts* und *Messung im Emitter-Lauf* → (3).

- [x] **(1) Die Selbstprüfung liegt im Ziel, ist über dessen `make` fahrbar und ist kein Gate.**
  Der Bootstrap legt beides ab: die Vorlage unter `tools/harness/` **ausführbar** (git
  transportiert nur das Ausführungs-Bit, und ein verlorenes Bit wäre eine Prüfung, die nur so
  aussieht) und das Fragment im Fragment-Verzeichnis des Ziels, das dieses über den vorhandenen
  `include harness/mk/*.mk` einbindet. Das Ziel hängt an **keiner** `gates`-Kette des Ziels —
  sonst führte dessen `make gates` bei jedem Lauf einen Klon mit, und ein rotes Ziel-Gate wäre
  nicht mehr vom roten Klon-Lauf zu unterscheiden. **Keine neue Abhängigkeit**
  ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)): die Vorlage
  ruft `git`, `make` und coreutils — kein Netz, kein Paketmanager, kein zweites Bild.
  **Rot:** `make test` — der Go-Zahn hält Ablage, Modus und Klasse, und die Baum-Aussage in
  `internal/emit/baumaussage_test.go` fällt, solange die zwei neuen Pfade nicht in ihrer Liste
  stehen. Die Nicht-Gate-Kante liest (3) im Ziel über `make -n gates`.
- [x] **(2) Beide Ausgänge in einem Lauf — und die drei Marker sind adaptierbar.** In einem
  frischen Klon des Ziel-Repos, dessen `core.hooksPath` **vor** der Aktivierung leer ist
  (gelesen aus `git config --get`, nicht aus einer Meldung): nach dem Aktivierungsschritt
  **scheitert** ein Commit **ohne** Kennung — Exit ≠ 0 **und** `HEAD` bewegt sich nicht — **und
  geht** ein Commit **mit** Kennung durch — Exit 0 **und** `HEAD` trägt danach genau diese
  Message; danach ist `make gates` im Klon grün. Ein Lauf, der nur den durchgelassenen Commit
  beobachtet, löst die Zusage nicht ein. **Adaptierbar**
  ([`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)):
  Träger-Pfad, Aktivierungsschritt und Gate-/Build-Kommando sind überschreibbare Marker mit
  Default-Belegung; ein Lauf mit gesetztem Marker nennt den **gesetzten** Wert, nicht den
  Default. **Die Grenze steht im Kopf der Vorlage**, im Ziel: geprüft sind der Träger und die
  zwei Commit-Ausgänge — **nicht**, ob der Träger jeden Commit-Pfad erreicht
  (Werkzeug-Commits, `--no-verify`, Aufrufformen außerhalb der aktivierten Träger-Form).
  **Rot:** der Lauf aus (3) und der Mutations-Fall aus (3).
- [x] **(3) Der Emitter fährt sie einmal real, und ihr Rot ist gesehen.** `make full-smoke`
  führt am gebootstrappten Ziel eine Stufe, deren `e2e_abdeckung`-Aufruf die Kennung dieser Anforderung deklariert und die dort die
  Selbstprüfung **einmal** durchfährt, ihren Exit 0 liest und **beide** Ausgänge in ihrer
  Ausgabe belegt; die erzeugte Abdeckungs-Sicht ist mit `make e2e-abdeckung` neu geschrieben.
  Dazu ein **gelisteter** Mutations-Fall auf der emittierten Vorlage, dessen Rot mit
  **gelesener** Begründung gesehen ist ([`AGENTS.md`](../../../../AGENTS.md) §3.6): die Meldung
  nennt den fehlenden Ausgang, nicht irgendeinen Abbruch. **Rot:** `make full-smoke`
  (der Lauf), `make test` (die Abdeckungs-Sicht wird von einem Fall in
  `test/e2e-abdeckung.bats` gehalten) und `make mutate` (meldet den Fall als bewacht).
- [x] `make gates` grün; Arbeitsbaum danach sauber.
- [x] `make full-smoke` Exit 0 gefahren — der Beleg ist der Lauf
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)),
  nicht ein Eintrag in einer Liste.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: **entfällt für dieses Repo** — es entsteht kein neues `make`-Ziel hier
  (§1, letzter Ausschluss), und `make full-smoke` steht in
  [`harness/README.md`](../../../../harness/README.md) §Werkzeuge bereits als `kein Gate`. Die
  Doku **des Ziels** ist der Kopf der emittierten Vorlage und Teil von Liefer-Punkt (1).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/enforce/selbstpruefung.sh` | neu | die **emittierte Vorlage**: Klon, leerer `core.hooksPath`, Aktivierung, die zwei Commit-Ausgänge, `make gates` im Klon; Kopf mit der benannten Grenze und den drei Markern (Liefer-Punkte 1 und 2). Fällt automatisch in den `shell-lint`-Prüfbereich — das Rezept nennt `internal/emit/templates/enforce/*.sh` (`grep -c 'templates/enforce/\*\.sh' Makefile` → 1, kein Erwartungswert) |
| `internal/emit/templates/enforce/selbstpruefung.mk` | neu | das Fragment, das die Vorlage über `make` des Ziels fahrbar macht — ein Ziel, **kein** Anhängen an `GATE_CHECKS` (Liefer-Punkt 1) |
| `internal/emit/selbstpruefung.go` | neu | Pfad-Konstanten, `//go:embed`-Anbindung und die zwei `enforceFile`-Einträge (Modus 0755 / 0644, Klasse). Eigene Datei statt Erweiterung von `commitmsg.go`: die Selbstprüfung ist ein anderer Gegenstand als der Träger, den sie prüft |
| `internal/emit/enforce.go` | update | die zwei Einträge in die Liste `enforceFiles()` aufnehmen — die **eine** Stelle, an der der Bootstrap seinen Datei-Satz führt (`grep -n 'commitMsgHookFile()' internal/emit/enforce.go` → 1 Zeile, die Nachbarschaft) |
| `internal/emit/selbstpruefung_test.go` | neu | Go-Zähne nach Liefer-Punkt 1: Ablage-Pfad, Ausführungs-Bit, Klasse, und dass das Fragment `GATE_CHECKS` nicht anfasst (Happy / Boundary / Negative nach AC *Happy Path* und *Minimal*) |
| `internal/emit/baumaussage_test.go` | update | die Baum-Aussage des Ziels führt die Ziel-Pfade der zwei Verzeichnisse namentlich (`grep -c 'harness/mk/hooks-install.mk' internal/emit/baumaussage_test.go` → 1) — ohne die zwei neuen Zeilen fällt sie, und genau das ist das Rot aus (1) |
| `harness/tools/full-smoke.sh` | update | **eine** neue Stufe: sie fährt die Selbstprüfung im gebootstrappten Ziel einmal durch und liest ihre Ausgabe (Liefer-Punkt 3). Der Abschnitt `COMMIT-KENNUNG IM ZIEL` und die Abdeckungs-Gleichung im Dateikopf bleiben unberührt |
| `docs/user/e2e-abdeckung.md` | update (erzeugt) | **derivativ**, per `make e2e-abdeckung` neu geschrieben — nicht von Hand; ihr Inhalt wird von einem Fall in `test/e2e-abdeckung.bats` gehalten und fiele sonst rot |
| `test/mutations/370-selbstpruefung-ohne-fallenden-commit.sh` | neu | der **gelistete Zahn** (Liefer-Punkt 3): nimmt der Vorlage die Prüfung des scheiternden Commits, `# verify: full-smoke`, `# expect:` = die Fehler-Zeile der neuen Stufe. Die Nummer ist die nächste freie (`ls test/mutations/ \| sed 's/-.*//' \| sort -n \| tail -1` → 369, kein Erwartungswert) |

**Optional: Ansatz als Liste, wenn eine Zeile pro Datei nicht trägt** — z. B.
eine Schnittstellenänderung über viele gleichrangige Dateien mit derselben
Begründung, oder ein Ansatz, der sich nicht auf eine Datei herunterbrechen
lässt. Ergänzt die Tabelle, ersetzt sie nicht:

- **Die drei Marker sind Variablen mit Default-Belegung, keine Platzhalter zum Suchen-Ersetzen.**
  Träger-Pfad, Aktivierungsschritt und Gate-Kommando werden über die Umgebung bzw. das Fragment
  überschrieben; eine Vorlage, die der Adopter erst editieren **muss**, wäre beim nächsten
  konvergenten Lauf wieder überschrieben. Welche Klasse die zwei neuen Dateien tragen, entscheidet
  der Umsetzungs-Lauf am Bestand der Liste — die Selbstprüfung ist Werkzeug-Fassung, nicht
  Adopter-Eigentum wie der Träger unter `.githooks/`
  ([`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) Festlegung 1).
- **Die neue Stufe sitzt hinter dem Abschnitt `COMMIT-KENNUNG IM ZIEL`.** Dort ist das Ziel
  aktiviert; die Selbstprüfung legt ihren **eigenen** Klon an und ist von diesem Zustand
  unabhängig — aber der Lauf liest dann beide Lagen nacheinander, die von außen und die von
  innen, und die Trennung der zwei Anforderungen ist im Output ablesbar.
- **Die Ausgabe der Selbstprüfung wird gelesen, nicht nur ihr Exit-Code.** Ein Lauf, der beide
  Ausgänge nur behauptet, ist von einem, der sie fährt, am Exit-Code nicht zu unterscheiden —
  genau die Klasse, die [`AGENTS.md`](../../../../AGENTS.md) §3.6 verbietet. Die Stufe prüft
  darum je eine Zeile für den gefallenen und den durchgelassenen Commit.
- **Die Fehler-Zeilen der neuen Stufe sind einzeilig** und tragen den Wortlaut, den der
  Mutations-Fall als `# expect:` zitiert — der Treiber liest die Erwartung gegen die Zeile, die
  `full-smoke: FEHLER` führt (`harness/tools/mutate.sh`, `failure_form`).

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **kein Vorgänger** — der Slice ist einzeln lieferbar und rein
additiv: er nimmt nichts weg, was heute läuft. Dazu die zwei gewöhnlichen Bedingungen: der Slice
ist priorisiert (`Verantwortlich:` gesetzt) und das WIP-Limit ist frei.

**Reihenfolge gegenüber
[slice-aktivierung-reist-nicht-mit-dem-klon](../open/slice-aktivierung-reist-nicht-mit-dem-klon.md)
— eine Serialisierung, keine Abhängigkeit.** Beide schreiben in `harness/tools/full-smoke.sh`;
derselbe Lauf, zwei Schreibende. Wer zuerst landet, gibt die Datei frei, der zweite zieht nach
(§6 Risiko 1). Inhaltlich hängt keiner am anderen: jener misst das Aktivierungs-**Rezept**, dieser
emittiert eine **Prüfung**, die es benutzt.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Emission und ihre Messung im
  Emitter-Lauf nicht in einer Review-Sitzung prüfbar sind — etwa weil der Klon-Lauf im Ziel eine
  eigene Gate-Bild-Beschaffung braucht und damit zu einer zweiten Mechanik wird. Dann sind
  *Emission* und *Messung* zwei Vorgänge, und der Schnitt wird vor der Umsetzung geteilt.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Selbstprüfung im Ziel aus einem Grund
  rot wird, der **in der Durchsetzungsschicht selbst** liegt (Träger, Prüfung oder
  Aktivierungs-Fragment) — das ist
  [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) und
  nach §1 außerhalb dieses Schnitts; der Befund ist eine Übergabe an den Planner, kein Nachzug
  hier.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

- **Beobachtbar 1:** `make full-smoke` endet Exit 0, und sein Output trägt die neue Stufe mit
  beiden Ausgängen — die Zeile des **gefallenen** Commits ohne Kennung und die des
  **durchgelassenen** mit Kennung, dazu das grüne `make gates` im Klon.
- **Beobachtbar 2:** der Mutations-Fall ist gelistet und sein Rot ist **gesehen**, mit gelesener
  Begründung ([`AGENTS.md`](../../../../AGENTS.md) §3.6) — `make mutate` meldet ihn als bewacht,
  und die Meldung nennt den fehlenden Commit-Ausgang, nicht irgendeinen Abbruch.
- `make gates` grün; Arbeitsbaum sauber; kein Gate behauptet, was kein Lauf fährt
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Review** durch einen Lauf, der die Umsetzung nicht geschrieben hat; danach **Verifikation**
  gegen diese DoD.
- Closure-Notiz §7 mit Lerneintrag und jedes Risiko aus §6 mit genau einem Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Risiko 1 — zwei Schreibende auf `harness/tools/full-smoke.sh`.**
  [slice-aktivierung-reist-nicht-mit-dem-klon](../open/slice-aktivierung-reist-nicht-mit-dem-klon.md)
  führt dieselbe Datei in seinem §3. Landet er zuerst, findet dieser Slice einen veränderten
  Abschnitt vor; landen beide zugleich, schreiben zwei Kontexte dieselbe Datei. — **Ausgang:**
  **entfallen.** Der andere Slice liegt weiter in `open/` und hat nicht geschrieben; dieser Slice
  löscht in der Datei genau **eine** Zeile (den `cleanup()`-Eintrag, um das neue Ziel aufzunehmen),
  alles übrige ist additiv. Ein Nachzug für den zweiten Schreibenden fällt damit nicht an — die
  Serialisierung aus §4 hat getragen.
- **Risiko 2 — die Selbstprüfung fährt `make gates` im Klon, und das kostet.** Der Klon-Lauf zieht
  die Gate-Kette des Ziels ein zweites Mal durch (Doku-Gate im gepinnten Bild). Im Emitter-Lauf
  schlägt das auf die Laufzeit von `make full-smoke` durch, im Adopter-Repo auf die seiner
  Selbstprüfung. — **Ausgang:** **weiter offen**, ins Beobachtungs-Register als
  [`kosten-einer-emittierten-pruefung-im-ziel-ungemessen`](../observations/BEO-ALL/kosten-einer-emittierten-pruefung-im-ziel-ungemessen/observation.md).
  Die Emitter-Hälfte ist gemessen und beziffert: die Stufe ruft `make selbstpruefung` **dreimal**
  (Default, Gate-Marker, Träger-Marker) statt einmal, und zwar am **sprachlosen** Ziel, dessen Kette
  allein das Doku-Gate führt; `make full-smoke` endet trotzdem Exit 0. Die Adopter-Hälfte ist es
  nicht: Das `--lang go`-Ziel der Verifikation fährt im Klon die volle Code-Gate-Kette, und kein
  Lauf dieses Repos misst, was das ein Ziel kostet. *Entfallen* wäre nur für die erste Hälfte wahr
  und für die zweite eine Behauptung.
- **Risiko 3 — der Zahn läuft nur nächtlich.** Ein `# verify: full-smoke`-Fall kostet einen ganzen
  E2E-Lauf (Preis im Kopf von [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh)),
  und `make mutate` ist kein Gate. Zwischen Landung und Nacht-Job ist die neue Stufe **gelistet,
  aber nicht gefahren**; der Rot-Beleg aus DoD (3) ist die Bedingung, unter der ihr Grün trotzdem
  etwas sagt. — **Ausgang:** **entfallen**, und zwar durch die Bedingung, die das Risiko selbst
  nennt: Der Rot-Beleg liegt vor. Der Verifikations-Lauf hat **beide** gelisteten Fälle einzeln über
  `make full-smoke` gefahren, je Exit 2 gesehen und die Meldung gelesen — sie nennt den behaupteten
  Grund, nicht irgendeinen Abbruch. Das Urteil hängt damit nicht am Nacht-Job. Was bleibt, ist die
  Lücke zwischen Landung und Nacht; sie ist eine Eigenschaft der `# verify: full-smoke`-Klasse und
  keine dieses Slice.
- **Risiko 4 — der Klon braucht eine Ausgangslage, die nicht jedes Ziel hat.** Die Prüfung setzt
  ein Repo mit mindestens einem Commit und einem konfigurierten `user.email`/`user.name` voraus;
  ein frisch gebootstrapptes, noch nicht committetes Ziel erfüllt das nicht. Die Vorlage muss den
  Fall **benennen** statt an ihm auszurutschen. — **Ausgang:** **entfallen.** Beide Lagen sind
  benannt statt ausgerutscht und vom Verifier selbst gefahren: Repo ohne Commit → Exit 1 mit dem
  Satz, dass ein erster Commit die Prüfung fahrbar macht; kein git-Repo → Exit 1 mit demselben
  Muster. Die zweite Hälfte des Risikos (`user.email`/`user.name`) ist **strukturell** weggefallen —
  der Lauf bringt die Identität seiner zwei Commit-Versuche selbst mit, statt sie vorauszusetzen.
- **Risiko 5 — der Marker-Nachweis misst die Form statt der Wirkung.** Zu prüfen, *dass* eine
  Variable im Text steht, wäre die falsche Ebene; die Zusage ist, dass ein **gesetzter** Wert den
  Lauf lenkt. Der Nachweis muss den Lauf mit gesetztem Marker fahren und seinen Ausgang lesen —
  sonst ist er ein grüner Test ohne Gegenbeispiel
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6). — **Ausgang:** **entfallen.** Gemessen wird die
  **Spur des gefahrenen Kommandos** in der Ausgabe, nicht die Ankündigungs-Zeile, in der die
  Variable ohnehin stünde. Das Gegenbeispiel ist gebaut und rot gesehen:
  `test/mutations/371-selbstpruefung-ignoriert-den-gate-marker.sh` lässt den Marker
  danebenstehen, statt zu wirken, und färbt die Stufe rot. Der Verifier hat zusätzlich alle fünf
  Marker einzeln gesetzt und je den Ausgang gelesen.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene Beobachtungen **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10). Eingang
sind die drei Review-Reports und der Verifikations-Report, alle vom 2026-09-18. Maßstab sind
Baseline-Regelwerk `v6.9.0` · `modul-05-planning-harness.md` §Closure- und Lerneintrag-Regeln und
`modul-06-roadmap.md` §Das Beobachtungs-Register.

- **Was hat funktioniert:**
  - **Die Zusage ist als Wirkung gebaut, nicht als Form.** Die Stufe liest die **Spur des
    gefahrenen Kommandos**, nicht die Zeile, in der der Marker angekündigt wird — und beide
    Commit-Ausgänge entstehen in **einem** Klon aus `git`, mit Exit-Code *und* HEAD-Lage auf beiden
    Seiten. Genau daran hing Risiko 5, und genau dort greifen die zwei gelisteten Mutations-Fälle
    an. Eine Prüfung, die nur den durchgelassenen Commit sieht, fliegt auf.
  - **Der Schnitt hat gehalten.** Die Verifikation hat jeden der fünf §1-Ausschlüsse einzeln gegen
    den Diff gemessen: die Durchsetzungsschicht selbst, ein neues `make`-Ziel dieses Repos samt
    Prosa, der Abschnitt `COMMIT-KENNUNG IM ZIEL` und der Vergleichs-Sensor sind unberührt. Der
    fünfte ist die Ausnahme — siehe unten.
  - **Drei Review-Runden haben ihre Befunde weitergetragen.** Aus Runde 1 zwei HIGH, aus Runde 2 ein
    MEDIUM, aus Runde 3 ein MEDIUM; alle behoben, jede Behebung in der Folgerunde mit einem selbst
    gefahrenen Kommando nachgemessen. Zweimal hat eine Runde die **Zusage verengt**, statt den Slice
    über seine Schicht hinauszutreiben — die Grenze im Kopf der Vorlage ist das Ergebnis davon.
- **Was ging anders als geplant:**
  - **§3 deckt den gebauten Satz nicht** (Verifikation V-1 und V-3, Review F-8, R2-5, R3-3 — dieselbe
    Klasse in jeder Runde). *Gebaut, nicht geplant:* ein **zweiter** Mutations-Fall
    (`371`, der die Marker-Wirkung deckt), **fünf** statt drei Marker (die zwei Message-Marker
    tragen den Adopter mit eigenem Träger und eigener Kennungs-Menge), ein benannter Vorgabe-Ort
    `vorgaben.mk` im Fragment-Verzeichnis **des Ziels** samt eigenem Go-Zahn (der Pfad entsteht erst
    im gebootstrappten Ziel und steht deshalb ohne Verzeichnis), und ein **eigenes** Bootstrap-Ziel, in dem die
    Stufe `make selbstpruefung` **dreimal** ruft statt einmal. Jede dieser vier Abweichungen ist
    additiv, innerhalb §1 und im Code begründet; keine bricht eine Zusage. **§3 bleibt trotzdem,
    wie er ist:** Der Plan ist das Artefakt *vor* dem Code, und ein nachgetragener Plan behauptete
    Voraussicht, die es nicht gab. Der Befund steht hier, die Klasse ist unten gezählt, und die Zahl
    **drei** steht im Ausgang von Risiko 2 statt einer geschätzten.
  - **Ein §1-Ausschluss war zu weit gefasst** (Verifikation V-2, MEDIUM). §1 schloss *„der Nachweis,
    dass der Träger mit dem Klon reist und seine Aktivierung nicht"* aus und verwies ihn an
    [slice-aktivierung-reist-nicht-mit-dem-klon](../open/slice-aktivierung-reist-nicht-mit-dem-klon.md).
    Geliefert ist er trotzdem — an der Vorbedingung der Emitter-Stufe und an der ersten Ausgabezeile
    der Vorlage. **Kein Verstoß:** Die Akzeptanzkriterien von
    [`LH-FA-11`](../../../../spec/lastenheft.md#lh-fa-11--selbstprüfung-der-durchsetzungsschicht-emittieren)
    verlangen genau das (*der leere `core.hooksPath` vor der Aktivierung*), und das Lastenheft steht
    auf Rang 1 gegenüber einem Slice-Plan. Die Lehre daraus ist eine Schnitt-Regel: Ein §1-Ausschluss
    kann nicht ausschließen, was ein Akzeptanzkriterium der **tragenden** Anforderung verlangt — er
    verschiebt dann nicht Arbeit, sondern widerspricht seiner Quelle. Die Folge hat eine Adresse,
    siehe unten.
- **Entscheidungen zu den Befunden, die offen in die Closure kamen:**
  - **V-2 (MEDIUM): Adresse statt neuem Vorgang.** DoD (1) von
    [slice-aktivierung-reist-nicht-mit-dem-klon](../open/slice-aktivierung-reist-nicht-mit-dem-klon.md)
    ist **teilweise vorweggenommen**: seine Lagen (a) *Träger liegt ausführbar im Klon* und (b)
    *`core.hooksPath` bleibt leer* liefert dieser Slice schon. Nicht vorweggenommen ist (c) — der
    Commit **ohne** Kennung, der im **unaktivierten** Klon durchgeht; das ist die Gegenrichtung und
    bleibt sein Gegenstand, ebenso seine zwei übrigen Liefer-Punkte. Sein Zuschnitt ist beim
    `open → next` neu zu ziehen; der Hinweis steht in seinem Plan, damit die Adresse ihn führt und
    nicht diese Notiz. Kein Folge-Slice und kein Register-Eintrag: Der Befund ist einmalig, seine
    Ursache benannt, und die Arbeit hat einen Träger.
  - **V-1 und V-3 (LOW) sowie R3-3 (LOW):** oben festgehalten; §3 bleibt. **Register**,
    [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
    — ein Beleg, weil die drei Runden und die Verifikation **ein** Vorgang sind.
  - **V-4 (INFO): abgelehnt, mit Messung.** Der Befund nimmt an, ein Fassungs-Sprung von
    `baseline-verify` oder d-check nähme der Stufe die Zähne, **ohne sie rot zu färben**. Das trifft
    nicht zu: Der **Default-Lauf** derselben Stufe verlangt **beide** Zeichenketten positiv
    (`Integritaet + Vollstaendigkeit` und `Datei(en) geprüft`) und bricht mit einer eigenen Meldung
    ab, wenn eine fehlt. Damit ist die Bezugsmenge der negativen Zusicherung im Marker-Lauf durch
    einen zweiten Fall derselben Stufe abgesichert — genau der Ausweg, den
    [`zusicherung-ueber-der-leeren-menge-wahr`](../observations/BEO-ALL/zusicherung-ueber-der-leeren-menge-wahr/observation.md)
    als Form beschreibt; ein Wortlaut-Sprung wird laut, nicht still. Kein Beleg, kein Eintrag.
    **Was stehen bleibt**, ist eine Grenz-Aussage im Kommentar, die **weniger** verspricht, als der
    Code hält (*„kein Sensor hier liest, ob diese zwei Zeichenketten noch entstehen"* — der
    Default-Lauf liest genau das). Eine Grenze, die zu wenig verspricht, ist keine Harness-Lüge
    ([`AGENTS.md`](../../../../AGENTS.md) §3.7); sie zu schärfen wäre Implementer-Arbeit an einer
    Zeile, nicht ein Vorgang.
  - **V-5 (INFO): akzeptiertes Negativ.** Eine tab-eingerückte Zeile, die das Rufmuster des Helpers
    ausdrücklich zulässt und die kein Lauf anders liest. Kein Defekt, keine Route.
- **Steering-Loop-Eintrag:** **Neuer Sensor.** Das gebootstrappte Ziel prüft seine
  Durchsetzungsschicht ab jetzt **selbst** — `make selbstpruefung` klont das Ziel, liest den leeren
  `core.hooksPath`, aktiviert den Träger und belegt in **einem** Lauf den gefallenen und den
  durchgelassenen Commit, je mit Exit-Code und HEAD-Lage. Gehalten wird er zweifach: hermetisch von
  `internal/emit/selbstpruefung_test.go` und den zwei Zeilen in `internal/emit/baumaussage_test.go`
  (`make test`), real von der neuen Stufe in
  [`make full-smoke`](../../../../harness/sensors/full-smoke.md) mit zwei gelisteten
  Mutations-Fällen.
  - **Ohne Anker-Feld.** Der Sensor löst eine Anforderung des Lastenhefts ein
    ([`LH-FA-11`](../../../../spec/lastenheft.md#lh-fa-11--selbstprüfung-der-durchsetzungsschicht-emittieren)),
    nicht einen 3×-Übertritt des Registers; `grundlagen-traceability.md` §Herkunfts-Anker bindet den
    Anker eng an die Schwelle, und `liegt in` steht deshalb hier nicht.
  - **Was er zieht:** Ein Adopter kann nach dem Bootstrap ohne den Emitter belegen, dass sein
    Kennungs-Wächter aufhält — die eine Aussage, die vorher nur der Emitter über ihn treffen konnte.
  - **Was er nicht erreicht:** jeden Commit-Pfad. Werkzeug-Commits, `--no-verify` und Aufrufformen
    außerhalb der aktivierten Träger-Form stehen als Grenze im Kopf der Vorlage und in der
    Schluss-Zeile jedes Laufs; geprüft ist die **Anwesenheit** einer Kennung, nicht ihre Wahrheit.
- **Beobachtungs-Register (`../observations/`):** zwei Belege, beide unter dem Namen
  `evidence/slice-das-ziel-prueft-seine-durchsetzung-selbst.md`. Den Zähler liefert
  `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, die Zahl der Belege aus
  diesem Vorgang
  `ls docs/plan/planning/observations/BEO-ALL/*/evidence/slice-das-ziel-prueft-seine-durchsetzung-selbst.md | wc -l`.
  Keine der Zahlen ist ein Erwartungswert.

  | Eintrag | Quelle | Stand |
  |---|---|---|
  | [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md) | Review F-8, R2-5, R3-3; Verifikation V-1, V-3 | geplant |
  | [`kosten-einer-emittierten-pruefung-im-ziel-ungemessen`](../observations/BEO-ALL/kosten-einer-emittierten-pruefung-im-ziel-ungemessen/observation.md) | §6 Risiko 2, Ausgang *weiter offen* | offen |

  **Ein neues Verzeichnis**, und warum kein vorhandenes es trägt: Der nächste Nachbar,
  [`emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md),
  misst eine **Aussage** gegen das, was im Ziel wirklich geschieht — hier ist die Aussage richtig
  und ihr **Preis** an nur einer Ziel-Variante gemessen. Die Abgrenzung steht im Eintrag selbst.

  **Lese-Schritt.** **Kein** Eintrag erreicht mit diesem Slice zum ersten Mal 3×: Der neue steht bei
  einem Beleg, der andere stand schon deutlich darüber und trägt seit seinem Übertritt den Ausgang
  *geplant* mit Kennung. Es ist damit **keine** Regel zu verkörpern und kein Ausgang zuzuweisen.
- **Folge-Slices:** **keiner, neu.** Der einzige Befund mit Arbeitsfolge ist V-2, und seine Adresse
  besteht bereits:
  [slice-aktivierung-reist-nicht-mit-dem-klon](../open/slice-aktivierung-reist-nicht-mit-dem-klon.md)
  in `open/` — er nimmt den Gegenstand an und zieht seinen Zuschnitt beim `open → next` nach. Die
  drei übrigen Befunde brauchen keinen: zwei sind im Register gezählt, zwei sind mit Begründung
  abgelehnt.
- **Risiken aus §6:** fünf, jedes mit genau **einem** Ausgang — Risiko 1, 3, 4 und 5 *entfallen* mit
  Begründung, Risiko 2 *weiter offen* ins Register. Die Begründungen stehen ausgeschrieben in §6.
- **Drei Paarungen** (Repo ohne Wellen-Betrieb, geprüft zur Closure):
  - **Anker:** kein Gegenstand — der Steering-Loop-Eintrag trägt kein Feld `liegt in`, weil mit
    diesem Slice keine 3×-Regel verkörpert wurde.
  - **Folge-Slice:** `slice-aktivierung-reist-nicht-mit-dem-klon` liegt als Datei im
    Planning-Lifecycle (`open/`).
  - **Register:** jede hier genannte Beobachtung existiert als Verzeichnis unter
    `observations/BEO-ALL/`, und jedes dieser Verzeichnisse trägt mindestens einen Beleg.
    **Die repo-weite Hälfte ist rot, und zwar an zwei Stellen** — gemessen zur Closure, je
    Verzeichnis `ls <eintrag>/evidence/*.md | wc -l`:
    [`einstiegs-datei-weicht-von-der-pflichtgliederung-ab`](../observations/BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab/observation.md)
    und [`planungs-bestand-waechst-schneller-als-er-abgebaut-wird`](../observations/BEO-ALL/planungs-bestand-waechst-schneller-als-er-abgebaut-wird/observation.md)
    tragen keinen Beleg; ihr einziges Vorkommen steht dort jeweils unter *Benannt, nicht gezählt*.
    Beide sind **kein Fund dieser Closure** — dieser Slice zitiert keine von ihnen —, und die
    Lesart dafür entscheidet `slice-beleglose-register-eintraege-bekommen-eine-lesart`. Beim
    vorigen Abschluss war es **eines**; die Zahl wandert, und deshalb steht hier das Kommando.
- **Trigger-Audit** (bei der Slice-Closure, weil dieses Repo ohne Wellen-Betrieb arbeitet):
  - **Carveout:** [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) steht auf *Aktiv —
    Auflösung fällig* mit seiner Adresse in `next/`; [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md)
    steht auf *Permanent*. Dieser Slice berührt keine ihrer Bedingungen — er legt keine `.bats`-Datei
    an und rührt die Erfassungsschicht nicht.
  - **Bootstrap-aware Gate:** keines in diesem Repo.
  - **ADR:** [`ADR-0007`](../../adr/0007-bootstrap-phasen.md) — kein
    Re-Evaluierungs-Trigger eingetreten: Der neue Posten ist sprach-agnostisch, in beiden
    Bootstrap-Varianten identisch abgelegt und macht keinen Gate-Belang sprach-abhängig; die zwei
    neuen Dateien sind **konvergent** klassiert und nach erneutem Bootstrap byte-gleich zur Vorlage.
    [`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) — ebenfalls keiner:
    Der Träger `.githooks/commit-msg` bleibt skip-if-present und unberührt; die Selbstprüfung
    **liest** ihn. Die Klasse färbt nicht auf die zwei neuen Dateien ab — sie hängt an dem Namen, den
    `git` fixiert, und den führt keine von beiden. Der Adopter mit **eigenem** Träger, den die
    Festlegung ihm freistellt, ist über die zwei Message-Marker bedienbar; eine Stichprobe realer
    Ziele mit fremdem Träger liegt weiterhin nicht vor, und das bewegt die Abwägung nicht.
  - **Anforderungen:** [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
    — erfüllt und als **Wirkung** belegt: fünf Marker mit Default-Belegung, jeder einzeln gesetzt und
    sein Ausgang gelesen, und `test/mutations/371` färbt rot, wenn ein Marker nur danebensteht.
  - **Adaptions-Einträge, die dieser Slice fährt:**
    [`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)
    (das **emittierte** Layout ist `tools/harness/`, nicht das lokal adaptierte `harness/tools/` — im
    Konstanten-Kommentar benannt),
    [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
    (keine freistehende Zahl ohne ihr Kommando in den neuen Dateien) und
    [`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
    (der emittierte Prüfbereich bleibt fail-closed — die Selbstprüfung hängt an **keiner**
    `gates`-Kette des Ziels und weitet keinen Bereich). Keiner ihrer Auflösungs-Trigger ist
    eingetreten.
    [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel):
    nicht berührt — kein Modul geht neu ins emittierte Doc-Gate.
- **Archiv:** keines. Dieses Repo archiviert bei einer Slice-Closure nicht.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind **zwei** Sub-Areas.
`*` (gesamtes Repo), Kürzel `ALL`: dort liegt der Produkt-Code (`internal/emit/**`) samt der
emittierten Vorlagen und der Mutations-Fall unter `test/`. `harness/tools/`, Kürzel `TOOLS`: dort
liegt die neue E2E-Stufe. Beide stehen in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) und
erfüllen die Schwelle ≥ 2 von 3 Achsen. Eine feinere Sub-Area *„Emission der
Durchsetzungsschicht"* auszudifferenzieren unterbliebe: sie hätte gegenüber `*` weder eigene
Konventionen-Dichte noch eigenen Reifegrad — dieselben Gates, dieselbe Test-Form.

**Vorgelagert — offene Beobachtungen sichten:** Gesichtet ist der **gemergte** Stand vom
2026-09-18: **144** Verzeichnisse (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`,
kein Erwartungswert). Alle Einträge dieses Repos führen dieselbe Sub-Area `*`, die Sichtung ist
also nach **Gegenstand** geschnitten. Die Auswahl ist ein **Urteil** über Relevanz, keine
Vollständigkeits-Aussage über alle Einträge — ein `grep` über Slugs trifft Muster, nicht
Gegenstände ([`AGENTS.md`](../../../../AGENTS.md) §3.6). **Sechs Einträge berühren diesen Slice**,
je mit ihrem Zähler-Stand aus `ls <eintrag>/evidence/*.md | wc -l`:

| Beobachtung | Stand | berührt wie |
|---|---|---|
| [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md) | **8×**, verkörpert | die verkörperte Regel greift unmittelbar: die neue Zusage bekommt ihren **gelisteten** Fall — DoD (3) und die letzte Zeile von §3 |
| [`gruen-aussage-ohne-herkunft`](../observations/BEO-ALL/gruen-aussage-ohne-herkunft/observation.md) | **2×**, offen | die Gefahr dieses Schnitts in einem Satz: eine emittierte Prüfung, die niemand gefahren hat, wäre eine Grün-Aussage ohne Lauf. DoD (3) ist die Antwort darauf, nicht ein Zusatz |
| [`zusage-nennt-zwei-kanten-der-sensor-deckt-eine`](../observations/BEO-ALL/zusage-nennt-zwei-kanten-der-sensor-deckt-eine/observation.md) | **3×**, verkörpert | die Zusage hat zwei Kanten und §2 hält sie auseinander: die **Emission** hält der Go-Zahn, den **Lauf** hält die E2E-Stufe; keine liest die andere mit |
| [`waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md) | **1×**, offen | die Stufe fährt die **real emittierte** Vorlage im real gebootstrappten Ziel; die Wegwerf-Umgebung ist der Ort, nicht der Prüfgegenstand |
| [`zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`](../observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/observation.md) | **2×**, offen | dieser Slice legt eine Prüfung an, die es **nur** emittiert gibt — dieses Repo führt keine zweite Fassung davon, und damit entsteht die Klasse hier gerade nicht; ausdrücklich ausgeschlossen in §1 |
| [`emittierter-stand-laeuft-dem-dogfood-voraus`](../observations/BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus/observation.md) | **1×**, offen | die andere Achse desselben: die emittierte Selbstprüfung hat im Dogfood kein Gegenstück und braucht auch keines — ob das bei der Closure als Beleg zählt, ist ein Urteil dort, nicht beim Schnitt |

**Keiner der sechs erreicht mit diesem Slice erstmals die Schwelle 3×** — zwei stehen schon
darüber und sind `verkörpert`. Der Schnitt löst darum **keinen** Folge-Slice aus; ob ein Eintrag
einen **Beleg** bekommt, ist ein Urteil beim Schreiben und fällt bei der Slice-Closure.

**Modus-Begründungsblock — Umfang.** Bei reinem GF genügt der Hinweis *"alle berührten Sub-Areas GF"*.

**Alle berührten Sub-Areas GF** — die zwei Blöcke stehen trotzdem, weil das
Evidenz-/Diskrepanz-Kriterium hier je eine Antwort trägt, die über *„GF, also niedrig"* hinausgeht.

### Sub-Area: `*` (gesamtes Repo)

- **Modus:** GF
- **Konventionen-Dichte:** **hoch.** Der Emissions-Pfad ist über eine Liste geführt
  (`enforceFiles()`), jedes Skript unter `internal/emit/templates/enforce/` fällt in den
  `shell-lint`-Prüfbereich, die Baum-Aussage nennt die Ziel-Pfade namentlich, und die
  Mutations-Form (`# files:` / `# expect:` / `# verify:`) ist über den Bestand etabliert
  (`ls test/mutations/*.sh | wc -l` → 355, kein Erwartungswert). Die neuen Dateien treten in
  dieselben Formen.
- **Phase-Reife:** **Phase 5.** Die Emissions-Mechanik läuft seit vielen Slices; hinzu kommt ein
  **weiterer Posten** in einer bestehenden Liste, keine neue Mechanik.
- **Evidenz-/Diskrepanz-Risiko:** **niedrig, mit einer benannten Kante.** Der Bestand wird nicht
  inventarisiert. Die Kante ist die *Reichweite* der neuen Zusage: ihr billigster Zahn läuft nur
  nächtlich (Risiko 3), und die Gate-Kosten im Klon sind noch ungemessen (Risiko 2).
- **Reconciliation-Aufwand:** **keiner** — GF, es gibt keine Inventur-Linie. Gemessen statt
  behauptet: `ls docs/plan/planning/reconciliation.md` → *nicht vorhanden*; dieses Repo hat keinen
  Brownfield-Bootstrap und führt darum kein Inventur-Register. Deshalb trägt §2 das
  Reconciliation-Item der Vorlage nicht. **Graduation:** entfällt (GF).

### Sub-Area: `harness/tools/`

- **Modus:** GF
- **Konventionen-Dichte:** **hoch.** Die Sub-Area steht in der Modus-Deklaration; die
  Abdeckungs-Zusage des E2E-Kopfes hält [`test/full-smoke-ausgang.bats`](../../../../test/full-smoke-ausgang.bats),
  die Stufen-Deklaration erzwingt `e2e_abdeckung`, und die Prosa des Sensors liegt unter
  [`harness/sensors/full-smoke.md`](../../../../harness/sensors/full-smoke.md).
- **Phase-Reife:** **Phase 5.** Die E2E-Struktur läuft seit vielen Slices; verändert wird eine
  **Stufe auf einem reifen Bestand**.
- **Evidenz-/Diskrepanz-Risiko:** **niedrig.** Kein Abschnitt wird umgebaut, kein Exit-Code
  verschoben; die Stufe ist additiv. Die eine offene Frage ist die Laufzeit (Risiko 2).
- **Reconciliation-Aufwand:** **keiner** — GF. **Graduation:** entfällt (GF).
