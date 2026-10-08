# Slice slice-aktivierung-reist-nicht-mit-dem-klon: Der Adopter-Weg der Aktivierung wird gefahren — und die zwei negativen Fälle bekommen ihre Zähne

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case.

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-adopter-weg-im-ziel](../welle-adopter-weg-im-ziel.md) — Closure verlangt `make gates` und `make full-smoke` grün auf demselben Commit, das *Mehr* über diese DoD.

**Bezug:** [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (der Voll-E2E
ist sein Beleg), [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)
(der Commit-Kennungs-Wächter ist Teil der emittierten Durchsetzungsschicht),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(tragend, in **zwei** Richtungen: eine Konfiguration, die einen Wächter behauptet, unter dem
nichts liegt — und eine Schluss-Zeile, die eine Klon-Reise nennt, die kein Lauf macht),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne benanntes und rot gesehenes
Gegenbeispiel), [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
(Kennungs-Form), [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl dieses Plans steht neben ihrem Kommando).

**Berührte Spec-Stellen:** `—` . Der Slice führt Messungen am **emittierten** Ziel und am
eigenen E2E; kein Zielelement der Spec-Straten wird angefasst. Die Spec ist über
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) und
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
Prüfgegenstand, nicht Änderungsziel.

**Verantwortlich:** pt9912

**Autor:** Planner. **Datum:** 2026-09-15.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Der Adopter-Weg des Commit-Kennungs-Wächters wird dort gefahren, wo er heute noch
unbelegt ist: im **unaktivierten** Klon geht ein Commit **ohne** Kennung durch (die Gegenrichtung
zur Selbstprüfung des Ziels), und die zwei **negativen** Fälle der Aktivierung — Träger fehlt ·
Träger ist ein Verzeichnis — enden ≠ 0, **benennen** den Fall und lassen `core.hooksPath`
**ungesetzt**; die neue Stufe trägt ihre Deklaration und einen gelisteten Zahn.

### Der Befund, gemessen

Gemessen über den Baum vom 2026-10-08, **keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Umsetzung fährt sie zuerst neu:

```sh
grep -c 'core.hooksPath' harness/tools/full-smoke.sh                                    # 10
grep -c 'reist mit dem Klon' harness/tools/full-smoke.sh                                #  1  (Schluss-Zeile COMMIT-KENNUNG)
grep -l 'internal/emit/templates/enforce/hooks-install.mk' test/mutations/*.sh | wc -l   #  4  (keiner faehrt das Rezept)
make -n hooks-install | grep -c 'test -f'                                               #  0  (Dogfood-Rezept)
make -f internal/emit/templates/enforce/hooks-install.mk -n hooks-install | grep -c 'test -f'  # 1 (emittiertes Fragment)
grep -c 'HOOKS_DIR' Makefile                                                            #  0
```

1. **Zwei der drei Klon-Lagen sind geliefert, die dritte nicht.**
   [slice-das-ziel-prueft-seine-durchsetzung-selbst](../done/slice-das-ziel-prueft-seine-durchsetzung-selbst.md)
   fährt in der `full-smoke`-Stufe *Selbstpruefung im Ziel* (Satz *„der frische Klon traegt lokal
   keinen core.hooksPath"*) über `internal/emit/templates/enforce/selbstpruefung.sh` einen frischen
   Klon: Träger liegt (`test -f`), `core.hooksPath` leer, nach Aktivierung fällt ein Commit ohne
   Kennung — Letzteres belegt mittelbar auch das Ausführungs-Bit im Klon (git verwirft einen nicht
   ausführbaren Hook still, der Commit ginge dann durch). **Ungefahren** ist der Commit ohne
   Kennung, der im Klon **vor** der Aktivierung durchgeht: kein `full-smoke`-Abschnitt und keine
   Vorlage fährt ihn.
2. **Die zwei negativen Fälle des Fragments sind unbewacht.** Das Fragment trägt die `test -f`-Zeile
   (gemessen: 1); die vier Mutations-Fälle auf derselben Datei lesen Text, keiner fährt das Rezept,
   und beide E2E-Stufen fahren nur den geglückten Fall. Ohne die Zähne setzte das Rezept einen Pfad,
   unter dem nichts liegt, *während die Konfiguration einen Wächter behauptet*
   ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
3. **Das Dogfood-Rezept kennt die Zähne nicht** (0 gegen 1 oben, kein `HOOKS_DIR`). **Nicht in diesem
   Slice** — s. u.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Klon-Lagen „Träger reist mit" und „`core.hooksPath` bleibt leer"** — **geliefert:**
  [slice-das-ziel-prueft-seine-durchsetzung-selbst](../done/slice-das-ziel-prueft-seine-durchsetzung-selbst.md)
  fährt sie in der Stufe *Selbstpruefung im Ziel* (§1 Befund 1); sie hier zu wiederholen hieße,
  dieselbe Zusage zweimal zu liefern. Die neue Stufe darf sie als **Vorbedingung** lesen, nicht als
  eigene Aussage.
- **Die Dogfood-Reparatur (`Makefile:hooks-install` bekommt dieselben Zähne)** — **anderer
  Vorgang und Schicht-Abgrenzung.** Gegenstand ist die *emittierte* Ebene; der E2E kann das
  Dogfood-Rezept nicht fahren, ohne den lebenden Träger dieses Klons (`.githooks/commit-msg`)
  beiseitezulegen.
- **Ein Vergleichs-Sensor zwischen Dogfood-Fassung und Fragment** — **anderer Vorgang:** ein Sensor
  ist keine E2E-Stufe. Die Klasse ist im Register auf
  [slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor](../open/slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor.md)
  geplant; das Paar `hooks-install` nennt jener Plan nicht (`grep -c hooks-install` darüber → 0) —
  ob er es aufnimmt, entscheidet sein eigener Schnitt.
- **Ein Eingriff in die emittierte Ebene (Fragment, Prüfung, `internal/emit/**`)** —
  **Schicht-Abgrenzung: kein Produkt-Code.** Der Slice *fährt* das Fragment und *mutiert* es nur im
  gelisteten Fall.
- **Die drei Commit-Versuche des Abschnitts COMMIT-KENNUNG** (ohne Kennung · mit Kennung ·
  `--no-verify`) — **Bestand bleibt stehen:** sie messen das *Ziel*, nicht den Klon.

## 2. Definition of Done

- [x] **(1) Die Stufe im unaktivierten Klon — ein Commit ohne Kennung geht durch, die negativen
  Fälle lehnen ab.** Ein frischer Klon des Ziels, **vor** dessen Aktivierung. **Vorbedingungen
  zuerst, gelesen statt angenommen:** das Ziel selbst ist aktiviert
  (`git -C <ziel> config --get core.hooksPath` → `.githooks`), im Klon ist er leer, und
  `.githooks/commit-msg` liegt dort ausführbar — sonst läse der Durchgang nur, dass *niemand*
  irgendwo aktiviert hat oder kein Träger da ist. Dann: (a) ein Commit **ohne** Kennung endet
  Exit 0 **und** `HEAD` trägt danach genau diese Message; (b) **Träger fehlt** →
  `make -C <klon> hooks-install` endet ≠ 0, nennt den Pfad, `core.hooksPath` bleibt ungesetzt;
  (c) **Träger ist ein Verzeichnis** → ebenso (`test -x` ist für ein Verzeichnis wahr, erst
  `test -f` fängt es); (d) `HOOKS_DIR=<leer>` bricht ab und nennt **diesen** Pfad, nicht
  `.githooks`. Die Konfiguration wird **aus git** zurückgelesen, nicht aus der Meldung. Beleg ist
  der gefahrene `make full-smoke`.
- [x] **(2) Die Stufe ist deklariert.** Ihre `echo "full-smoke: … ..."`-Zeile trägt einen
  `e2e_abdeckung`-Aufruf mit den Kennungen, die sie misst, und einer Kurzbeschreibung, die nur das
  Gemessene nennt ([`AGENTS.md`](../../../../AGENTS.md) §3.6, emittierte Abdeckungs-Aussage);
  `make e2e-abdeckung` erzeugt [`docs/user/e2e-abdeckung.md`](../../../../docs/user/e2e-abdeckung.md)
  neu, und die Datei ist mit dem Commit byte-gleich (`test/e2e-abdeckung.bats`).
- [x] **(3) Die Stufe hat einen gelisteten Zahn, und sein Rot ist gesehen.**
  `test/mutations/<NNN>-aktivierung-ohne-traeger-pruefung.sh` (nächste freie Nummer bei Anlage;
  `ls test/mutations/*.sh | sed 's#.*/##' | sort -n | tail -1` → `587-…` heute, kein
  Erwartungswert) nimmt dem Fragment `internal/emit/templates/enforce/hooks-install.mk` die
  `test -f`-Zeile; `# verify: full-smoke`, `# expect:` ist der Wortlaut der Fehler-Zeile aus (1b).
  Rot gesehen mit **gelesener** Begründung: die Meldung nennt die fehlende Träger-Prüfung, nicht
  irgendeinen Abbruch; `make mutate` (`MUTATE_CASES`) meldet den Fall als bewacht.
- [x] `make gates` grün; Arbeitsbaum danach sauber.
- [x] `make full-smoke` Exit 0 gefahren und die neue Stufe in seinem Output belegt.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`),
  kein Self-Review.
- [x] Doku-Update: **entfällt** über (2) hinaus — [`harness/sensors/full-smoke.md`](../../../../harness/sensors/full-smoke.md)
  führt keine Stufen-Liste, und `full-smoke` steht in [`harness/README.md`](../../../../harness/README.md)
  §Werkzeuge bereits als `kein Gate`.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben oder „keine Beobachtung" in §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen prüft die Closure von welle-adopter-weg-im-ziel; für diesen Slice nach dem `git mv` geprüft (§7).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/full-smoke.sh` | update | neue Stufe hinter COMMIT-KENNUNG samt `e2e_abdeckung`-Aufruf (DoD 1, 2); der Kennungs-Abschnitt, seine Aussagen (a)–(f) und die Abdeckungs-Gleichung im Dateikopf bleiben unberührt; die Schluss-Zeile »reist mit dem Klon« bekommt ihren Lauf |
| `docs/user/e2e-abdeckung.md` | update (erzeugt) | `make e2e-abdeckung` nach der Deklaration (DoD 2) |
| `test/mutations/<NNN>-aktivierung-ohne-traeger-pruefung.sh` | neu | der gelistete Zahn (DoD 3) |

**Warum keine bats- und keine Go-Datei daneben.** Die Kette *Repo → `make` → Rezept → `git config`*
fährt nur der E2E: das gepinnte bats-Image führt kein `git`, und keine bats-Datei ruft
`git init`/`make -f` (`grep -rlE 'git init|make -f' test/*.bats | wc -l` → 0;
`grep -rl 'verify: full-smoke' test/mutations/ | wc -l` → 30, der Modus ist etabliert — keine
Erwartungswerte). Ein Zahn über dem **Text** des Rezepts wäre die falsche Ebene (§3.6).

- **Ort im Lauf:** hinter `kennungs_traeger_im_ziel` — dort ist das Ziel aktiviert, der Klon ist
  die einzige unaktivierte Instanz derselben Quelle. Der Klon liegt unter dem bestehenden
  `$tmpklon`-Elternverzeichnis; dessen Deklarations-Kommentar wird mitgezogen (§3.7).
- **Aufrufe in der `if out="$( … )"; then rc=0; else rc=$?; fi`-Form**, damit die Menge (A) der
  Abdeckungs-Gleichung unverändert bleibt (`test/full-smoke-ausgang.bats`); keine Einordnung — die
  Stufe fordert kein Bild an.
- **Fehler-Zeilen einzeilig**, mit dem Wortlaut, den der Fall als `# expect:` zitiert
  (`harness/tools/mutate.sh`, `failure_form`).

## 4. Trigger

**Start** (`next` → `in-progress`): **kein Vorgänger** — der Slice ist rein additiv; die zwei
Schreibenden auf denselben Dateien, die früher eine Serialisierung verlangten, liegen in `done/`
([slice-commit-traeger-wird-skip-if-present](../done/slice-commit-traeger-wird-skip-if-present.md),
[slice-das-ziel-prueft-seine-durchsetzung-selbst](../done/slice-das-ziel-prueft-seine-durchsetzung-selbst.md)).
Dazu `Verantwortlich:` gesetzt und das WIP-Limit frei.

**Rückführungen:**

- `in-progress` → `next`: wenn die negativen Fälle **nicht ohne Eingriff in das Fragment** fahrbar
  sind (etwa: die Abbruch-Zeile steht nicht vor `git config`) — dann sind Zähne und Messung zwei
  Vorgänge.
- `in-progress` → `open`: wenn der Träger im Klon **nicht ausführbar** ankommt oder
  `make -C <klon> hooks-install` nicht greift — Ursache in `internal/emit/**`, außerhalb der Schicht;
  Übergabe an den Planner.

## 5. Closure-Trigger

- **Beobachtbar 1:** `make full-smoke` Exit 0, sein Output trägt die neue Stufe (Commit ohne
  Kennung im unaktivierten Klon geht durch · fehlt · Verzeichnis · `HOOKS_DIR`), und
  `docs/user/e2e-abdeckung.md` führt ihre Zeile.
- **Beobachtbar 2:** der Mutations-Fall ist gelistet, sein Rot gesehen mit gelesener Begründung.
- `make gates` grün; Review und Verifikation durch fremde Läufe; §7 mit Lerneintrag, jedes Risiko
  mit Ausgang.

## 6. Risiken und offene Punkte

- **Risiko 1 — die neue Stufe hängt an ihrer Stelle im Lauf.** Nur hinter COMMIT-KENNUNG ist das
  Ziel aktiviert und der Klon nicht; wandert die Stufe oder verliert sie ihre Vorbedingungen, liest
  sie einen Zustand, den sie nicht herstellt. — **Ausgang:** **entfallen** — die Stufe liest ihre
  Vorbedingungen aus git und Dateisystem (Ziel `core.hooksPath` = `.githooks`, Klon leer, Träger
  `-f`/`-x`) und bricht mit Exit 1 ab, wenn eine fehlt; ein verlorener Zustand wird laut
  (Verifikation, Negativbefunde).
- **Risiko 2 — die Abbruch-Meldung des Fragments ist fremd.** Gelesen wird der **Pfad**, den sie
  nennt, nicht ihr Satz; ein späterer Nachzug des Wortlauts bräche sonst die Stufe, ohne dass etwas
  kaputt wäre. — **Ausgang:** **entfallen** — (b)–(d) lesen eine Zeile `^hooks-install: `, die den
  Pfad nennt, und die Konfiguration aus git, nicht den Satz der Meldung (Verifikation DoD 1).
- **Risiko 3 — der Zahn läuft nur nächtlich und teuer.** Ein `# verify: full-smoke`-Fall kostet
  einen E2E-Lauf, `make mutate` ist kein Gate; bis zum Nacht-Job trägt allein der Rot-Beleg aus
  DoD (3). — **Ausgang:** **entfallen** durch die Bedingung, die das Risiko nennt: der Rot-Beleg
  liegt vor — `make mutate MUTATE_CASES=588-aktivierung-ohne-traeger-pruefung` → `mutate: ok 588-…
  -> aber keine Zeile des Ziels nennt .githooks/commit-msg rot`, `1 ok, 0 Befund(e)`, Meldung mit
  der behaupteten Ursache gelesen (Verifikation DoD 3). Die Lücke zwischen Landung und Nacht-Job ist
  eine Eigenschaft der `# verify: full-smoke`-Klasse, nicht dieses Slice.
- **Risiko 4 — die Kurzbeschreibung der Deklaration sagt mehr, als die Stufe misst.** Sie liegt
  neben der Selbstprüfungs-Zeile, die die zwei übrigen Klon-Lagen trägt; eine Beschreibung „Klon-Weg
  der Aktivierung" läse sich als Ganz-Abdeckung. Den Inhalt prüft kein Sensor
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6). — **Ausgang:** **entfallen** — die Kurzbeschreibung
  nennt nur das Gemessene und die Grenze (Klon-Reise als Vorbedingung, Dogfood, Ausführrecht),
  gegen den Körper der Stufe gelesen (Verifikation DoD 2).

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10). Eingang:
Review `docs/reviews/2026-10-08-aktivierung-im-klon-review.md` (0/0/0/1) und Verifikation
`docs/reviews/2026-10-08-aktivierung-im-klon-verifikation.md` (DoD 1–3 bestätigt, CI-Run
`37751930957` auf `4986c611` grün, Job `full-smoke` trägt *„Aktivierung im Klon (golang)"*).

- **Was hat funktioniert:** Der Schnitt hat gehalten — Diff in genau den drei Dateien aus §3, kein
  Eingriff in `internal/emit/**`, die Abdeckungs-Sicht erzeugt byte-gleich (33 Stufen, 33
  Deklarationen laut `make e2e-abdeckung`). Die Stufe liest Vorbedingungen und Konfiguration aus git
  statt aus Meldungen; damit entfielen Risiko 1, 2 und 4 ohne Nacharbeit.
- **Was ging anders als geplant:** nichts am Gebauten. Die Zusage der Stufe ist vierteilig, der
  gelistete Zahn bindet einen Teil (b) — so wie DoD (3) es verlangt; (c) und (d) halten nur die
  Stufe selbst (Review INFO-1).
- **Steering-Loop-Eintrag:** **Neuer Sensor** — die `full-smoke`-Stufe *Aktivierung im Klon* fährt
  das emittierte Rezept `hooks-install` real: der unaktivierte Klon lässt einen Commit ohne Kennung
  durch, und die negativen Fälle enden ≠ 0 mit ungesetztem `core.hooksPath`; der gelistete Fall
  `test/mutations/588-aktivierung-ohne-traeger-pruefung.sh` bindet die `test -f`-Kante des
  Fragments. Kein `liegt in`: es wurde keine 3×-Regel verkörpert.
- **Beobachtungs-Register (`../observations/`):** `evidence/slice-aktivierung-reist-nicht-mit-dem-klon.md`
  in [`zusage-nennt-zwei-kanten-der-sensor-deckt-eine`](../observations/BEO-ALL/zusage-nennt-zwei-kanten-der-sensor-deckt-eine/observation.md)
  ergänzt (Quelle Review INFO-1; Zähler `ls <eintrag>/evidence/*.md | wc -l`, kein
  Erwartungswert). Der Eintrag stand schon über der Schwelle mit Ausgang *geplant*; der Beleg weist
  ihm keinen neuen zu. Kein Beleg für
  [`gleichzeitig-laufender-slice-macht-adresse-tot`](../observations/BEO-ALL/gleichzeitig-laufender-slice-macht-adresse-tot/observation.md):
  die Adresse traf den Plan in `open/`, nicht zwei gleichzeitig laufende Slices. Kein Beleg für
  [`gruen-aussage-ohne-herkunft`](../observations/BEO-ALL/gruen-aussage-ohne-herkunft/observation.md):
  keine Grün-Aussage dieses Slice verwechselt Lauf und Beleg — jede nennt ihren Lauf.
  **Lese-Schritt:** kein Eintrag erreicht mit diesem Slice erstmals 3×.
- **Folge-Slices:** keine.
- **Risiken aus §6:** vier, jedes *entfallen* mit Begründung in §6.
- **Paarungen geprüft am 2026-10-08:** (a) Anker — kein Gegenstand, §7 trägt kein Feld `liegt in`; (b) Folge-Slice — keiner genannt; (c) Register — alle drei genannten Verzeichnisse existieren, `ls <eintrag>/evidence/*.md | wc -l` je ≥ 1. Repo-weite zweite Hälfte von (c): 2 Verzeichnisse ohne Beleg (`cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`, `einstiegs-datei-weicht-von-der-pflichtgliederung-ab`; Kommando in `close-welle.md` Schritt 3), kein Fund dieser Closure, nicht als getragen behauptet.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind **zwei** Sub-Areas. `harness/tools/`,
Kürzel `TOOLS`: die neue E2E-Stufe liegt dort, und die Sub-Area steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area).
`*` (gesamtes Repo), Kürzel `ALL`: dort liegt der gelistete Mutations-Fall (`test/mutations/`),
und dort liegt der Quellbaum, den sein `# files:`-Pfad nennt — das Aktivierungs-Fragment der
**emittierten** Ebene. Diese Ebene ist keine Sub-Area dieses Repos (sie ist ein anderer Vertrag,
der an Adopter ausgeliefert wird); soweit dieser Slice sie berührt, berührt er sie als
**Prüfgegenstand** unter `*`. Beide erfüllen die Schwelle ≥ 2 von 3 Achsen; eine feinere Sub-Area
*„Commit-Kennung"* auszudifferenzieren hätte weder eigene Konventionen-Dichte noch eigenen
Reifegrad gegenüber `*` und unterbliebe darum.

**Vorgelagert — offene Beobachtungen sichten:** gemergter Stand vom 2026-10-08, **232**
Verzeichnisse (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, kein Erwartungswert);
alle unter `*`, die Auswahl ist ein **Urteil** nach Gegenstand, keine Vollständigkeits-Aussage.
Zähler je `ls <eintrag>/evidence/*.md | wc -l`:

| Beobachtung | Stand | berührt wie |
|---|---|---|
| [`gruen-aussage-ohne-herkunft`](../observations/BEO-ALL/gruen-aussage-ohne-herkunft/observation.md) | 2×, offen | die Schluss-Zeile »reist mit dem Klon« bekommt für die Gegenrichtung ihren Lauf; ob das ein Beleg wird, urteilt die Closure |
| [`traeger-wirkt-nur-nach-lokaler-aktivierung`](../observations/BEO-ALL/traeger-wirkt-nur-nach-lokaler-aktivierung/observation.md) | 1×, offen | der Gegenstand selbst: DoD (1a) macht die unaktivierte Lage messbar |
| [`emittierter-stand-laeuft-dem-dogfood-voraus`](../observations/BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus/observation.md) | 2×, offen | Dogfood-Fassung ohne `test -f` bleibt stehen (§1) — erreicht dieser Slice keinen dritten Beleg, bleibt der Eintrag unter der Schwelle |
| [`rotierender-pruef-gegenstand-ohne-ort`](../observations/BEO-ALL/rotierender-pruef-gegenstand-ohne-ort/observation.md) | 2×, offen | Nachbar: dieser Prüf-Gegenstand hat einen Ort (Risiko 1) |
| [`gleichzeitig-laufender-slice-macht-adresse-tot`](../observations/BEO-ALL/gleichzeitig-laufender-slice-macht-adresse-tot/observation.md) | 1×, offen | derselbe Mechanismus traf diesen Plan: seine Folge-Adresse für die Deklaration schloss vor ihm — beim Nachschnitt behoben (DoD 2), Beleg-Urteil bei der Closure |
| [`zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`](../observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/observation.md) | 5×, geplant | Vergleichs-Sensor ist außerhalb (§1) |
| [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md) | 17×, geplant | DoD (3) |
| [`zusage-nennt-zwei-kanten-der-sensor-deckt-eine`](../observations/BEO-ALL/zusage-nennt-zwei-kanten-der-sensor-deckt-eine/observation.md) | 5×, geplant | E2E fährt die Kette, der Fall bindet die `test -f`-Kante — beide in §2 getrennt |
| [`waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md) | 6×, geplant | der Zahn mutiert die reale Fragment-Quelle, nicht eine Kopie |

Keiner der offenen Einträge erreicht mit diesem Schnitt 3×; die Schnitt-Sichtung löst **keinen**
Folge-Slice aus.

**Alle berührten Sub-Areas GF** — die zwei Blöcke stehen, weil das Evidenz-Kriterium je eine
eigene Antwort trägt.

### Sub-Area: `harness/tools/`

- **Modus:** GF
- **Konventionen-Dichte:** **hoch.** Die Sub-Area ist in der Modus-Deklaration von
  [`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
  geführt; `make shell-lint` deckt jedes Skript dort, die Abdeckungs-Zusage des E2E-Kopfes hält
  [`test/full-smoke-ausgang.bats`](../../../../test/full-smoke-ausgang.bats), und die Prosa des
  Sensors liegt unter [`harness/sensors/full-smoke.md`](../../../../harness/sensors/full-smoke.md).
  Die neue Stufe tritt in dieselbe Form — und in **beide** Wächter: die Gleichung bleibt wahr, und
  der Zahn ist gelistet.
- **Phase-Reife:** **Phase 5.** Die E2E-Struktur (Abschnitts-Funktionen, Einordnung,
  Zähne-Muster) läuft seit vielen Slices; verändert wird eine **Stufe auf einem reifen Bestand**.
- **Evidenz-/Diskrepanz-Risiko:** **niedrig, mit einer benannten Kante.** Der Bestand wird nicht
  angefasst (kein Abschnitt umgebaut, kein Exit-Code verschoben); die Kante ist die *Reichweite*
  der neuen Zusage — ihr billigster Zahn läuft nur nächtlich (Risiko 3), und die zwei Kanten sind
  in §2 auseinandergehalten.
- **Reconciliation-Aufwand:** **keiner** — GF, es gibt keine Inventur-Linie. Gemessen statt
  behauptet: `ls docs/plan/planning/reconciliation.md` → *nicht vorhanden*; dieses Repo hat keinen
  Brownfield-Bootstrap und führt darum kein Inventur-Register. Deshalb trägt §2 das
  Reconciliation-Item der Vorlage nicht — es entfällt, wie die Vorlage es für Repos ohne
  Brownfield-Bootstrap vorsieht. **Graduation:** entfällt (GF).

### Sub-Area: `*` (gesamtes Repo)

- **Modus:** GF
- **Konventionen-Dichte:** **hoch für die Form, offen für den Gegenstand.** Die Prüf-Suite liegt
  unter `test/`, ihre Form (Kopf mit `# files:`/`# expect:`/`# verify:`, Treiber mit
  `failure_form`) ist über 574 Fälle etabliert und von `make mutate` gedeckt
  (`ls test/mutations/*.sh | wc -l`, kein Erwartungswert). **Offen ist der Gegenstand:** das
  Rezept der Aktivierung ist heute in keiner Suite *ausgeführt* — genau die Lücke, die dieser
  Slice mit ihrem ersten Fall schließt.
- **Phase-Reife:** **Phase 5.** Die Mutations-Suite und der E2E laufen seit vielen Slices; der
  neue Fall tritt in eine bestehende Form.
- **Evidenz-/Diskrepanz-Risiko:** **niedrig.** Es wird kein Bestand inventarisiert; der Fall ist
  additiv, und der geprüfte Baum bleibt bis auf seine Mutation unverändert (der Treiber arbeitet
  in einer Kopie außerhalb des Repos).
- **Reconciliation-Aufwand:** **keiner** — GF. **Graduation:** entfällt (GF).
