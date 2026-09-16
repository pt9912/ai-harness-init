# Slice slice-aktivierung-reist-nicht-mit-dem-klon: Der Adopter-Weg der Aktivierung wird gefahren — und die zwei negativen Fälle bekommen ihre Zähne

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case.

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Begründung in §1 *Warum wellenlos* — geprüft gegen
Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht (Modul 6).

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

**Verantwortlich:** `—` — bis zur Priorisierung (Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine: der Übergang `open→next` setzt sie).

**Autor:** Planner. **Datum:** 2026-09-15.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Der Adopter-Weg des Commit-Kennungs-Wächters wird **gefahren** statt behauptet: ein
frischer Klon des gebootstrappten Ziels zeigt, dass der Träger mitreist und seine Aktivierung
**nicht** (ein Commit ohne Kennung geht dort durch), `make -C <klon> hooks-install` schaltet ihn
scharf, und danach fällt derselbe Commit am Träger; die zwei **negativen** Fälle der Aktivierung
— Träger fehlt · Träger ist ein Verzeichnis — enden ≠ 0, **benennen** den Fall und lassen
`core.hooksPath` **ungesetzt**.

### Der Befund, gemessen

Alle Zahlen sind über den Baum vom 2026-09-15 genommen und **keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die erste Handlung der Umsetzung ist, sie neu zu fahren. Jede Zahl steht neben dem
Kommando, das sie liefert:

```sh
grep -c 'core.hooksPath' harness/tools/full-smoke.sh                                    #  6  (alle sechs im Kennungs-Abschnitt, alle ueber das ZIEL)
grep -c 'git clone' harness/tools/full-smoke.sh                                         #  2  (beide im Vorlauf-Waechter-Abschnitt, keiner fuer die Aktivierung)
grep -c 'reist mit dem Klon' harness/tools/full-smoke.sh                                #  1  (die Schluss-Zeile des Kennungs-Abschnitts)
grep -l 'internal/emit/templates/enforce/hooks-install.mk' test/mutations/*.sh | wc -l   #  3  (jeder erwartet einen Go-TEXTANKER)
make -n hooks-install | grep -c 'test -f'                                               #  0  (Dogfood-Rezept)
make -f internal/emit/templates/enforce/hooks-install.mk -n hooks-install | grep -c 'test -f'  # 1 (emittiertes Fragment)
```

1. **Die Klon-Aussage läuft mit und hat keine Messung.** Die Schluss-Zeile des Kennungs-Abschnitts
   sagt zu, der Träger »reist mit dem Klon, seine Aktivierung nicht« — der Lauf legt aber keinen
   Klon für die Aktivierung an: die zwei `git clone`-Aufrufe gehören dem Vorlauf-Wächter-Abschnitt
   und dienen dessen History-Sonde (Tiefe 1 gegen vollständig), und **keiner** von beiden liest
   `core.hooksPath`. Auch der Abschnitts-Kommentar nennt den frischen Klon —
   »Ein frischer Klon ist bis (b) ungeprueft; genau das liest (e)« —, und (e) liest
   `git commit --no-verify`. Die Klasse ist
   [`gruen-aussage-ohne-herkunft`](../observations/BEO-ALL/gruen-aussage-ohne-herkunft/observation.md)
   (2×, offen): eine Grün-Aussage, deren Herkunft kein Lauf ist.
2. **Die zwei negativen Fälle des Fragments sind unbewacht.** Das Fragment trägt die tragende
   Zeile (`test -f`, gemessen: 1) und die zwei Lagen dahinter; die drei Mutations-Fälle auf
   derselben Datei erwarten **Go-Textanker**, keiner fährt das Rezept, und der E2E fährt nur den
   geglückten Fall. Ohne die zweite Hälfte setzt das Rezept einen Pfad, unter dem nichts liegt,
   und jeder Commit liefe ungeprüft durch, *während die Konfiguration einen Wächter behauptet*
   ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
3. **Das Dogfood-Rezept kennt die Zähne nicht.** Der Unterschied ist gemessen (0 gegen 1 in den
   zwei Kommandos oben, die `test -f`-Zeile): die eigene Fassung hat die benannte Abbruch-Zeile
   **nicht** und kennt auch `HOOKS_DIR` nicht (`grep -c 'HOOKS_DIR' Makefile` → 0). Die Klasse trägt
   im Register zwei Einträge
   ([`zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`](../observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/observation.md)
   2× · [`emittierter-stand-laeuft-dem-dogfood-voraus`](../observations/BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus/observation.md)
   1×). **Nicht in diesem Slice** — s. u.

### Warum wellenlos

Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht: Eine Welle liegt vor,
wenn ein Closure-Trigger **mehr** beobachtet, als die DoDs ihrer Slices ohnehin belegen. Hier ist
es ein Slice; sein Closure-Trigger schriebe seine eigene DoD ab — der dort benannte Regelfall für
wellenlose Arbeit. Die zwei repo-weiten Belege (ein `make gates`-Lauf im *eigenen* Baum und ein
Replay) trägt die Welle dieses Repos ohnehin, nicht dieser Schnitt: der E2E ist **kein Gate**
([`harness/README.md`](../../../../harness/README.md) §Werkzeuge, `targets.exempt-targets`) —
Beleg ist der gefahrene Lauf.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Dogfood-Reparatur (`Makefile:hooks-install` bekommt dieselben Zähne)** — **anderer
  Vorgang und Schicht-Abgrenzung.** Der Gegenstand dieses Slice ist die *emittierte* Ebene — was
  ein Adopter bekommt; das Dogfood-Rezept ist dieses Repos eigene Fassung derselben Regel, und
  ihre **Vergleichung** ist ein Sensor (genau der Gegenstand von
  [`zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`](../observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/observation.md),
  2×, offen), nicht ein E2E. Dazu der harte Grund: der E2E kann dieses Rezept **nicht** fahren,
  ohne den **lebenden** Träger dieses Repos beiseitezulegen (`.githooks/commit-msg`) — ein Sensor
  würde den Wächter bewegen, der jeden Commit dieses Klons bewacht, und ein Abbruch zwischen
  Beiseitelegen und Zurücklegen ließe ihn liegen. Einen eigenen Schnitt dafür zu legen ist ein
  Planner-Schnitt, nicht ein Anhängsel dieses Plans.
- **Die Deklaration der neuen Stufe** — **Folge-Slice, mit Adresse:**
  [slice-e2e-abdeckung-ist-deklariert-und-erzeugt](../in-progress/slice-e2e-abdeckung-ist-deklariert-und-erzeugt.md).
  Sein Erzeuger verlangt für jede Stufe eine Deklaration (`echo "full-smoke: … ..."` eröffnet eine
  Stufe, die Region bis zur nächsten muss eine tragen) und sein §1 schließt aus, *was der E2E
  prüft*, zu ändern — eine **Deklaration** ist keine Prüfungs-Änderung, und seine DoD (1) führt
  *jede* Stufe. Die Adresse nimmt den Punkt damit an; die Form legt **er** fest, nicht dieser
  Plan. Die Reihenfolge der zwei Landungen steht als Risiko in §6.
- **Ein Vergleichs-Sensor zwischen Dogfood-Fassung und Fragment** — **anderer Vorgang:** ein
  Sensor ist keine E2E-Stufe. Sein Gegenstand ist gemessen benannt und wäre je Fassung ein
  eigener Bau.
- **Ein Eingriff in die emittierte Ebene (Fragment, Prüfung, `internal/emit/**`)** —
  **Schicht-Abgrenzung: kein Produkt-Code.** Dieser Slice *fährt* das Fragment und *mutiert* es
  nur in einem gelisteten Mutations-Fall; er ändert es nicht.
- **Die drei Commit-Versuche des bestehenden Abschnitts** (ohne Kennung · mit Kennung ·
  `--no-verify`) — **Bestand bleibt bewusst stehen.** Sie messen das *Ziel*; sie in den Klon zu
  ziehen, änderte den gemessenen Gegenstand und nähme dem Abschnitt die eine Messung, die er
  heute trägt.

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

- [ ] **(1) Der Klon-Weg ist gefahren — der Träger reist, seine Aktivierung nicht.** Drei Lagen
  im frischen Klon, jede **gelesen**: (a) `.githooks/commit-msg` liegt **ausführbar** und die
  Prüfung `tools/harness/commit-msg-traceability.sh` liegt daneben (git transportiert nur das
  Ausführungs-Bit, und ein verlorenes Bit wäre ein Wächter, der nur so aussieht); (b) `git config
  --get core.hooksPath` endet ≠ 0 und bleibt leer; (c) ein Commit **ohne** Kennung geht durch —
  Exit 0 **und** `HEAD` trägt danach genau diese Message (ein Durchgang, der keinen Commit
  erzeugt, wäre keiner). **Vorbedingung zuerst:** das Ziel selbst ist zu diesem Zeitpunkt
  aktiviert (`git -C <ziel> config --get core.hooksPath` → `.githooks`) — sonst läse der leere
  Klon-Wert nur, dass *niemand* irgendwo aktiviert hat. **Beleg ist der gefahrene Lauf**
  (`make full-smoke`, kein Gate).
- [ ] **(2) Die zwei negativen Fälle der Aktivierung, und beide werden aus git zurückgelesen.**
  In demselben Klon, **vor** dessen Aktivierung: (a) **Träger fehlt** → `make -C <klon>
  hooks-install` endet ≠ 0, **nennt** den Fall, und `core.hooksPath` bleibt ungesetzt;
  (b) **Träger ist ein Verzeichnis** → ebenso abgelehnt und ebenso ungesetzt — `test -x` ist auch
  für ein Verzeichnis wahr, erst die `test -f`-Zeile fängt das; (c) **die Variable wirkt** —
  derselbe Aufruf mit `HOOKS_DIR=<leer>` bricht ab und nennt **diesen** Pfad, nicht `.githooks`.
  Ohne (a) und (b) setzte das Rezept einen Pfad, unter dem nichts liegt, während die Konfiguration
  einen Wächter behauptet ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
  Gelesen wird die Konfiguration **aus git**, nicht aus der Meldung des Rezepts.
- [ ] **(3) Die neue Stufe hat einen gelisteten Zahn, und sein Rot ist gesehen.**
  `test/mutations/358-aktivierung-ohne-traeger-pruefung.sh` nimmt dem Fragment
  `internal/emit/templates/enforce/hooks-install.mk` die `test -f`-Zeile; `# verify: full-smoke`
  (das gepinnte bats-Image führt kein `git`, und keine bats-Datei dieses Repos fährt
  `git init`/`make -f` — nur der E2E fährt diese Kette, Begründung und Messung in §3),
  `# expect:` ist der Wortlaut der Fehler-Zeile aus (2a). Rot gesehen mit
  **gelesener** Begründung ([`AGENTS.md`](../../../../AGENTS.md) §3.6): die Meldung nennt die
  fehlende Träger-Prüfung, nicht irgendeinen Abbruch; `make mutate` meldet den Fall als bewacht.
- [ ] `make gates` grün; Arbeitsbaum danach sauber.
- [ ] `make full-smoke` Exit 0 gefahren und die neue Stufe in seinem Output belegt — der Beleg ist
  der Lauf ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)),
  nicht ein Eintrag in einer Gate-Liste.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: **entfällt** — [`harness/sensors/full-smoke.md`](../../../../harness/sensors/full-smoke.md)
  nennt ein *Kriterium* (»jeder Abschnitt, der ein Bild anfordern kann«) und keine Stufen-Liste,
  und [`harness/README.md`](../../../../harness/README.md) §Werkzeuge führt `full-smoke` bereits als
  `kein Gate`. Die neue Stufe kann kein Bild anfordern und tritt in keine der drei dort genannten
  Formen ein (Begründung in §3).
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
| `harness/tools/full-smoke.sh` | update | die neue Stufe `aktivierung_reist_nicht_mit_dem_klon` samt Aufruf und Schluss-Zeile (Liefer-Punkte 1 und 2). Der bestehende Kennungs-Abschnitt, seine sechs Aussagen und die Abdeckungs-Gleichung im Dateikopf bleiben unberührt |
| `test/mutations/358-aktivierung-ohne-traeger-pruefung.sh` | neu | der **gelistete Zahn** (Liefer-Punkt 3): nimmt dem Fragment `internal/emit/templates/enforce/hooks-install.mk` die `test -f`-Zeile, `# verify: full-smoke`, `# expect:` = die Fehler-Zeile der neuen Stufe |

**Warum keine bats- und keine Go-Datei daneben.** Eine Stufe unterhalb des E2E, die die Kette
*Repo → `make` → Rezept → `git config`* fahren könnte, gibt es hier nicht, und das ist gemessen:
das gepinnte bats-Image führt kein `git` (benannt im `Makefile` beim Vorlauf-Wächter), und keine
bats-Datei dieses Repos ruft `git init`/`make -f` — der Haus-Weg für eine Zusage, die **beide**
braucht, ist die E2E-Stufe:

```sh
grep -rlE 'git init|make -f' test/*.bats | wc -l    # 0
grep -rl 'verify: full-smoke' test/mutations/ | wc -l   # 14  (der Modus ist etabliert)
```

**Keine Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Ein Zahn, der das Rezept nur über seinem **Text** hält (`test -f` kommt vor
`git config`), wäre die falsche Ebene: die Zusage ist *verhalten* (ohne Träger bleibt die
Konfiguration ungesetzt), nicht *Form* — genau die Klasse, die
[`AGENTS.md`](../../../../AGENTS.md) §3.6 verbietet. Der Preis des E2E-Modus steht im Kopf von
[`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) (*Preis eines
`# verify: full-smoke`-Falls*), damit die nächste Zusage ihn kennt, bevor sie ihn auslöst.

**Optional: Ansatz als Liste, wenn eine Zeile pro Datei nicht trägt** — z. B.
eine Schnittstellenänderung über viele gleichrangige Dateien mit derselben
Begründung, oder ein Ansatz, der sich nicht auf eine Datei herunterbrechen
lässt. Ergänzt die Tabelle, ersetzt sie nicht:

- **Die neue Stufe sitzt hinter dem Kennungs-Abschnitt, und das ist keine Ordnungsliebe.** Der
  Klon ist die **einzige** unaktivierte Instanz derselben Quelle: im Ziel ist `core.hooksPath`
  nach (b) gesetzt, im Klon nicht. Damit sind die zwei Lagen derselben Sache in einem Lauf
  lesbar — und die zwei negativen Fälle sind nur **dort** messbar, wo noch nichts gesetzt ist.
- **Der Klon liegt unter dem bestehenden `$tmpklon`-Elternverzeichnis** (`$tmpklon/kennung`);
  dessen Deklarations-Kommentar nennt danach **drei** Klone statt zwei — die Änderung ist Teil
  dieses Slice (§3.7: der Kommentar beschreibt, was an der Stelle liegt).
- **Die neuen Aufrufe laufen in der `if out="$( … )"; then rc=0; else rc=$?; fi`-Form**, wie die
  drei Commit-Versuche des Abschnitts darüber: so bleibt die Menge (A) der Abdeckungs-Gleichung
  im Dateikopf unverändert, die `test/full-smoke-ausgang.bats` in beiden Richtungen hält. Eine
  Einordnung bekommt die Stufe **nicht** — sie kann kein Bild anfordern (das Fragment ruft `git`
  und coreutils), und der Kopf sagt genau das zu.
- **Die Fehler-Zeilen der neuen Stufe sind einzeilig und tragen den Wortlaut, den der
  Mutations-Fall als `# expect:` zitiert** — der Treiber liest die Erwartung gegen die Zeile, die
  `full-smoke: FEHLER` führt (`harness/tools/mutate.sh`, `failure_form`).

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **kein Vorgänger** — der Slice ist einzeln lieferbar; er ist
rein additiv gegenüber dem, was heute läuft. Dazu die zwei gewöhnlichen Bedingungen: der Slice ist
priorisiert (`Verantwortlich:` gesetzt) und das WIP-Limit frei.

**Reihenfolge — und sie ist keine Abhängigkeit, sondern eine Serialisierung.**
[slice-commit-traeger-wird-skip-if-present](../done/slice-commit-traeger-wird-skip-if-present.md) führt
dieselben zwei Dateien in seinem §3 (das Aktivierungs-Fragment — Kopf **und Fehlermeldung** — und
`harness/tools/full-smoke.sh`); er hängt an seinem eigenen Start-Trigger
([`ADR-0054`](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) `Accepted`). Die zwei
laufen **nicht parallel**: derselbe Wächter, dieselbe Datei, zwei Schreibende. Wer zuerst läuft,
gibt sie frei — der zweite zieht den Nachzug nach (§6 Risiko 4).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die neue Stufe die zwei negativen
  Fälle **nicht ohne Eingriff in das Fragment** fahren kann — etwa weil die Abbruch-Zeile dort
  nicht vor der `git config`-Zeile steht. Dann sind die Zähne des Fragments und ihre Messung zwei
  Vorgänge, und der Schnitt wird vor der Umsetzung geteilt.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Messung zeigt, dass der Träger im Klon
  **nicht ausführbar** ankommt oder `make -C <klon> hooks-install` nicht greift — dann liegt die
  Ursache in `internal/emit/**` (Ablage-Modus, Pfad) und damit **außerhalb der Schicht dieses
  Slice**; der Befund ist eine Übergabe an den Planner, nicht ein Nachzug hier.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

- **Beobachtbar 1:** `make full-smoke` endet Exit 0, und sein Output trägt die neue Stufe: die
  drei Lagen des Klons (Träger ausführbar · `core.hooksPath` leer · Commit ohne Kennung geht
  durch), die drei negativen Fälle der Aktivierung (fehlt · Verzeichnis · `HOOKS_DIR`) und den
  gefallenen Commit danach.
- **Beobachtbar 2:** der Mutations-Fall ist gelistet und sein Rot ist **gesehen**, mit gelesener
  Begründung ([`AGENTS.md`](../../../../AGENTS.md) §3.6) — `make mutate` meldet ihn als bewacht,
  und die Meldung nennt die fehlende Träger-Prüfung, nicht irgendeinen Abbruch.
- `make gates` grün; Arbeitsbaum sauber; kein Gate behauptet, was der Lauf nicht fährt
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Review** durch einen Lauf, der die Umsetzung nicht geschrieben hat; danach **Verifikation**
  gegen diese DoD.
- Closure-Notiz §7 mit Lerneintrag und jedes Risiko aus §6 mit genau einem Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Risiko 1 — die neue Stufe hängt an ihrer Stelle im Lauf.** Der Klon ist nur *dort* die
  unaktivierte Instanz; die zwei negativen Fälle lesen »`core.hooksPath` bleibt ungesetzt« und
  sind an jeder anderen Stelle unmessbar (im Ziel ist er nach (b) gesetzt). Wandert die Stufe
  oder verliert sie ihre zwei Vorbedingungen (das Ziel ist aktiviert · der Klon trägt Commits),
  liest sie einen Zustand, den sie nicht mehr herstellt. — **Ausgang:** <…>
- **Risiko 2 — die Abbruch-Meldung des Fragments ist fremd.** Gelesen wird der **Pfad**, den die
  Meldung nennt (`.githooks/commit-msg` bzw. der `HOOKS_DIR`-Wert), nicht ihr Satz:
  [slice-commit-traeger-wird-skip-if-present](../done/slice-commit-traeger-wird-skip-if-present.md) zieht
  Kopf **und Fehlermeldung** desselben Fragments; eine wörtlich gelesene Zusage bräche dabei, ohne
  dass etwas kaputt wäre. — **Ausgang:** <…>
- **Risiko 3 — der Zahn läuft nur nächtlich und teuer.** Ein `# verify: full-smoke`-Fall kostet
  einen ganzen E2E-Lauf (Preis im Kopf von
  [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh)) und `make mutate` ist kein
  Gate. Bis zum Nacht-Job ist die neue Stufe **gelistet, aber nicht gefahren** — der Rot-Beleg aus
  DoD (3) ist die Bedingung, unter der ihr Grün trotzdem etwas sagt. — **Ausgang:** <…>
- **Risiko 4 — zwei Schreibende auf denselben zwei Dateien.**
  [slice-commit-traeger-wird-skip-if-present](../done/slice-commit-traeger-wird-skip-if-present.md) führt
  das Fragment **und** `harness/tools/full-smoke.sh` in seinem §3. Landet er zuerst, findet dieser
  Slice eine gezogene Meldung vor und misst gegen den dann geltenden Stand; landen beide zugleich,
  schreiben zwei Kontexte dieselben Dateien. — **Ausgang:** <…>
- **Risiko 5 — die Deklaration der neuen Stufe hängt an der Reihenfolge.**
  [slice-e2e-abdeckung-ist-deklariert-und-erzeugt](../in-progress/slice-e2e-abdeckung-ist-deklariert-und-erzeugt.md)
  verlangt für jede Stufe eine Deklaration. Ist sein Erzeuger zur Closure dieses Slice gebaut,
  fällt die neue Stufe dort **laut** aus (die Regel, nicht still) und die Deklaration ist in der
  dann geltenden Form nachzuziehen; ist er es nicht, trägt der Lauf die neue Stufe als einzige
  ohne Deklaration, bis er sie schreibt
  (`grep -cE '^echo "full-smoke: .* \.\.\."$' harness/tools/full-smoke.sh` → 15 heute, kein
  Erwartungswert). — **Ausgang:** <…>

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
- **Drei Paarungen:** dieses **Repo** fährt Wellen — Anker, Folge-Slice und Register prüft die
  nächste Welle-Closure, auch für diesen Slice ohne Wellen-Zugehörigkeit.

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

**Vorgelagert — offene Beobachtungen sichten:** Gesichtet ist der **gemergte** Stand vom
2026-09-15: **120** Verzeichnisse (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`,
kein Erwartungswert). Alle Einträge dieses Repos führen dieselbe Sub-Area `*`, die Sichtung ist
also nach **Gegenstand** geschnitten. Die Auswahl ist ein **Urteil** über Relevanz, keine
Vollständigkeits-Aussage über 120 Einträge — ein `grep` über Slugs trifft Muster, nicht
Gegenstände ([`AGENTS.md`](../../../../AGENTS.md) §3.6). **Acht Einträge berühren diesen Slice**,
je mit ihrem Zähler-Stand aus `ls <eintrag>/evidence/*.md | wc -l`:

| Beobachtung | Stand | berührt wie |
|---|---|---|
| [`gruen-aussage-ohne-herkunft`](../observations/BEO-ALL/gruen-aussage-ohne-herkunft/observation.md) | **2×**, offen | die Schluss-Zeile »reist mit dem Klon« ist heute eine Grün-Aussage ohne Lauf als Herkunft (§1 Befund 1); dieser Slice macht sie zur gemessenen — ob daraus ein **Beleg** wird, ist ein Urteil bei der Closure, nicht beim Schnitt |
| [`zusage-nennt-zwei-kanten-der-sensor-deckt-eine`](../observations/BEO-ALL/zusage-nennt-zwei-kanten-der-sensor-deckt-eine/observation.md) | **3×**, offen | die Zusage hat zwei Kanten (§2 (3), §3): der **E2E** fährt die Kette real (Klon · `make` · `git`), der **Mutations-Fall** fährt sie je Nacht — beide Kanten sind benannt, keine Zusage liest die andere mit |
| [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md) | **16×**, geplant (`slice-181`) | Warnung ohne Gegenstand: der Funktionskopf der neuen Stufe nennt genau die Lagen, die ihr Code hält — nicht mehr |
| [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md) | **8×**, *verkörpert* | jede neue Zusage braucht einen **gelisteten** Fall; DoD (3) und der Zahn in §3 |
| [`waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md) | **1×**, offen | der Zahn fährt den **realen** Gegenstand (Fragment-Quelle, echtes `make`, echtes `git`) in einem Wegwerf-**Repo**: die Fixture ist die Umgebung, nicht der Prüfgegenstand — die Grenze steht dort, wo er nur nächtlich läuft |
| [`zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`](../observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/observation.md) | **2×**, offen | die Dogfood-Fassung bleibt in diesem Schnitt stehen (§1); der Gegenstand ist benannt und **gemessen** (0 gegen 1 in §1) |
| [`emittierter-stand-laeuft-dem-dogfood-voraus`](../observations/BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus/observation.md) | **1×**, offen | derselbe Befund auf der anderen Achse: die Emissions-Vorlage ist schärfer als die eigene Fassung |
| [`rotierender-pruef-gegenstand-ohne-ort`](../observations/BEO-ALL/rotierender-pruef-gegenstand-ohne-ort/observation.md) | **1×**, offen | Nachbar, kein Gegenstand: dieser Prüf-Gegenstand **hat** einen Ort (die Stelle im Lauf) — ob daraus ein Beleg wird, fällt bei der Closure |

**Keiner der acht erreicht mit diesem Slice erstmals die Schwelle 3×** — einer steht schon
darüber und bleibt `offen`; seinen Ausgang weist der **Lese-Schritt** zu (nächste Welle-Closure,
§7), nicht dieser Schnitt. Der Schnitt löst darum **keinen** Folge-Slice aus; ob ein Eintrag einen
**Beleg** bekommt, ist ein Urteil beim Schreiben und fällt bei der Slice-Closure.

**Modus-Begründungsblock — Umfang.** Bei reinem GF genügt der Hinweis *"alle berührten Sub-Areas GF"*.

**Alle berührten Sub-Areas GF** — die zwei Blöcke stehen trotzdem, weil das
Evidenz-/Diskrepanz-Kriterium hier je eine Antwort trägt, die über *„GF, also niedrig"*
hinausgeht.

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
  in §3 auseinandergehalten.
- **Reconciliation-Aufwand:** **keiner** — GF, es gibt keine Inventur-Linie. Gemessen statt
  behauptet: `ls docs/plan/planning/reconciliation.md` → *nicht vorhanden*; dieses Repo hat keinen
  Brownfield-Bootstrap und führt darum kein Inventur-Register. Deshalb trägt §2 das
  Reconciliation-Item der Vorlage nicht — es entfällt, wie die Vorlage es für Repos ohne
  Brownfield-Bootstrap vorsieht. **Graduation:** entfällt (GF).

### Sub-Area: `*` (gesamtes Repo)

- **Modus:** GF
- **Konventionen-Dichte:** **hoch für die Form, offen für den Gegenstand.** Die Prüf-Suite liegt
  unter `test/`, ihre Form (Kopf mit `# files:`/`# expect:`/`# verify:`, Treiber mit
  `failure_form`) ist über 343 Fälle etabliert und von `make mutate` gedeckt
  (`ls test/mutations/*.sh | wc -l`, kein Erwartungswert). **Offen ist der Gegenstand:** das
  Rezept der Aktivierung ist heute in keiner Suite *ausgeführt* — genau die Lücke, die dieser
  Slice mit ihrem ersten Fall schließt.
- **Phase-Reife:** **Phase 5.** Die Mutations-Suite und der E2E laufen seit vielen Slices; der
  neue Fall tritt in eine bestehende Form.
- **Evidenz-/Diskrepanz-Risiko:** **niedrig.** Es wird kein Bestand inventarisiert; der Fall ist
  additiv, und der geprüfte Baum bleibt bis auf seine Mutation unverändert (der Treiber arbeitet
  in einer Kopie außerhalb des Repos).
- **Reconciliation-Aufwand:** **keiner** — GF. **Graduation:** entfällt (GF).
