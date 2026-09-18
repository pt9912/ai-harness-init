# Slice slice-das-ziel-erzeugt-seine-eigene-e2e-abdeckung: Das gebootstrappte Ziel erzeugt die Abdeckungs-Sicht über seine eigenen E2E-Stufen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Der Closure-Trigger dieses Slice wäre seine eigene DoD; ein
repo-weiter Beleg, den sie nicht schon trägt, kommt nicht hinzu — siehe
Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht (Modul 6).

**Bezug:** [`LH-FA-12`](../../../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren)
(**tragend** — sie sagt genau diese Emission zu und stellt die acht Akzeptanzkriterien,
gegen die §2 aufgeht),
[`LH-FA-11`](../../../../spec/lastenheft.md#lh-fa-11--selbstprüfung-der-durchsetzungsschicht-emittieren)
(der **Gegenstand**, über den die Sicht spricht — das ziel-eigene E2E; es läuft, die Sicht
sagt, welche Anforderung das Laufende trägt),
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
(der Erzeuger reist mit adaptierbaren Markern, nicht mit unseren Pfaden),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(kein Gate — eine Sicht über null Stufen entsteht nicht, der Lauf bricht laut),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
(bash + coreutils, kein Docker, kein Netz).

**Berührte Spec-Stellen:** `ARC-005`
([`spec/architecture.md`](../../../../spec/architecture.md#1-komponenten-übersicht) §1) —
der Durchsetzungs-Emitter legt die zwei neuen Dateien ab, wie er das Ziel-E2E und den
Commit-Träger ablegt; seine Zeile in §1 und §2 bleibt wörtlich, weil sie die Rolle nennt
und keine Datei-Liste führt. Eine Änderung an Vertrags-, Technik- oder Sicht-Stratum
liefert dieser Slice nicht.

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-18.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Ein gebootstrapptes Ziel bekommt den **Erzeuger** der E2E-Abdeckungs-Sicht und
kann sie über sein eigenes `make` aus den Deklarationen seiner E2E-Stufen erzeugen; sein
mitgeliefertes E2E trägt dafür die erste Deklaration, und die Spaltenfolge der Tabelle
lautet in **beiden** Fassungen `| Spec-Kennung | Kurzbeschreibung | Stufe | Ort |`.

**Wieviel Sicht im Ziel heute entsteht — gemessen, bevor geschnitten wurde.** Das einzige
ziel-eigene E2E ist die Selbstprüfung, und sie trägt heute weder eine Stufen-Kopfzeile in
der Form, die der Erzeuger liest, noch eine Deklaration:

```sh
grep -cE '^echo "[^"]*: .* \.\.\."$' internal/emit/templates/enforce/selbstpruefung.sh   # 0
grep -c 'e2e_abdeckung' internal/emit/templates/enforce/selbstpruefung.sh                # 0
grep -cE '^echo "full-smoke: .* \.\.\."$' harness/tools/full-smoke.sh                     # 17
```

**Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)) —
alle drei wandern mit dem Baum. Die Sicht des Ziels hat damit heute **null** Zeilen, mit
der Deklaration dieses Slice **eine**; unsere hat aus derselben Mechanik 17.

**Und warum der Schnitt trotzdem trägt.** Geliefert wird die **Mechanik samt Form**, nicht
die eine Zeile: Der Wert wächst mit der Zahl der Stufen, die der Adopter in sein E2E
schreibt — dieselbe Kurve, die unsere Fassung von 1 auf 17 gelaufen ist —, und die erste
Zeile ist der Beleg, dass sie im Ziel läuft statt nur dort zu liegen. Zurück nach `open/`
gehörte der Slice, wenn die Mechanik im Ziel nichts fände, worüber sie spricht; sie findet
genau eine Stufe, und das ist keine leere Menge, sondern eine kleine. Dazu kommt ein
Grund, der nicht wartet: die Spaltenfolge ist in **beiden** Fassungen zu ändern, und wer
sie heute nur hier ändert, ändert dieselbe Ableitung zweimal — die Klasse, die das
Beobachtungs-Register unter `zusage-neben-geaenderter-ableitung-bleibt-stehen` führt (§8).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Keine zweite Fassung unserer Kennungs-Menge im Ziel** — der emittierte Erzeuger
  leitet seine Anker aus der Spec-Datei ab, die sein Marker nennt, und kennt weder
  `LH-FA-*` noch unser Anker-Schema. Grund: die 14 Kennungen unserer Tabelle
  (`grep -oE 'LH-(FA|QA)-[0-9]{2}' docs/user/e2e-abdeckung.md | sort -u | wc -l`) sind
  Inhalt **dieses** Repos; mitgeliefert wären sie eine Zusage über ein fremdes Lastenheft,
  die kein Lauf einlöst. *(Schicht-Abgrenzung: der Erzeuger ist Werkzeug, die Kennungen
  sind Inhalt.)*
- **Keine Änderung am Lastenheft in diesem Slice** — die tragende Anforderung
  [`LH-FA-12`](../../../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren)
  steht, und sie ist **außerhalb** dieses Slice entstanden. Grund: das Lastenheft ist
  Vertrags-Stratum, seine Änderung ist ein **anderer Vorgang** — ein Change Request des
  Auftraggebers
  ([`MR-036`](../../../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)),
  nicht die Selbstermächtigung des Slice, der die Mechanik baut. Was der Slice liefert,
  ist die Einlösung; was der Vertrag sagt, entscheidet er nicht.
- **Kein Gate, weder hier noch im Ziel** — der Erzeuger urteilt über den Quelltext eines
  Skripts, nicht über den Zustand des Baums. Grund: das ist die bestehende Einordnung
  unseres Werkzeugs (`harness/README.md` §Werkzeuge, `kein Gate`), und sie kippt nicht
  dadurch, dass dieselbe Mechanik in einem zweiten Repo liegt
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Keine weiteren Stufen im ziel-eigenen E2E** — die Selbstprüfung bekommt ihre
  Deklaration, keine zusätzliche Prüfung. Grund: was sie prüft, setzt
  [`LH-FA-11`](../../../../spec/lastenheft.md#lh-fa-11--selbstprüfung-der-durchsetzungsschicht-emittieren);
  ihr Umfang zu ändern wäre ein Vorgang am Gegenstand, dieser Slice arbeitet am Werkzeug.
- **Keine Sicht-Datei im Ziel-Baum committen** — der Lauf legt den Erzeuger ab, nicht
  dessen Ausgang. Grund: **Bestand des Adopters** — wohin seine Sicht schreibt, sagt sein
  Marker, und eine mitgelieferte Tabelle wäre der Ausgang unseres Laufs über seinem Baum.

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

Drei Liefer-Punkte, jeder mit dem Kommando, das ihn **rot** färbt
([`AGENTS.md`](../../../../AGENTS.md) §3.6 — die Zusage ist erst fertig, wenn das
Gegenbeispiel benannt **und** einmal rot gesehen ist). **Die acht Akzeptanzkriterien von**
[`LH-FA-12`](../../../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren)
**gehen in diesen drei Punkten auf** — Happy Path, Adaptierbarkeit, Minimalität und der
zweite Lauf im ersten; die Herkunft aus den Deklarationen und beide Lücken-Richtungen im
zweiten; die Form der Tabelle samt Kennungs-Zelle und *kein aus dem Nichts* im dritten.
Keines steht daneben.

- [ ] **Der Erzeuger reist ins Ziel und läuft dort.** Das Paar
      `tools/harness/e2e-abdeckung.sh` + `harness/mk/e2e-abdeckung.mk` <!-- d-check:ignore (der Pfad entsteht mit diesem Slice) --> wird emittiert
      (konvergent, ausführbar), seine vier ziel-spezifischen Stellen — Quell-Skript, Wort
      der Stufen-Kopfzeile, Spec-Datei, Zielort der Sicht — stehen als **gesetzte,
      überschreibbare Marker**
      ([`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)),
      der Aggregator des Ziels bindet das Fragment über `include harness/mk/*.mk` ein, der
      Lauf endet mit Exit 0 und die Sicht liegt am **deklarierten** Zielort. Gemessen ist
      ein gesetzter Marker an dem, **was entsteht**, nicht an seiner Erwähnung in der
      Ausgabe. Der Erzeuger fügt dem Ziel keine Abhängigkeit hinzu: er liest Text — kein
      Container, kein Netz
      ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)). **Und
      ein zweiter Lauf ohne geänderte Deklaration schreibt die Sicht nicht neu und sagt
      es** — sonst wäre sie der Lauf-Beleg, den
      [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)
      trägt und diese Anforderung ausschließt.
      **Rot durch:** den Eintrag des Paares aus dem Emitter nehmen → `make test`
      meldet FAIL im neuen Go-Fall (Ablage, Modus, Marker-Liste); zusätzlich fällt die
      neue Stufe von `make full-smoke`, weil `make e2e-abdeckung` im gebootstrappten Ziel
      dann kein Rezept hat. Für den zweiten Lauf: die Schreib-nur-bei-Abweichung aufheben
      → die `full-smoke`-Stufe sieht beim zweiten Aufruf keine Unverändert-Meldung und
      fällt.
      **Dazu ein Posten, den kein Sensor hält:** Die Deklarations-Zeile *unserer* Stufe in
      `harness/tools/full-smoke.sh`, die genau diese Emission prüft, nennt
      [`LH-FA-12`](../../../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren)
      als die Anforderung, die sie trägt, neben
      [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
      für die Marker; [`LH-FA-11`](../../../../spec/lastenheft.md#lh-fa-11--selbstprüfung-der-durchsetzungsschicht-emittieren)
      steht dort nicht mehr — die Stufe prüft die **Sicht**, nicht das E2E, und das ist
      dieselbe Grenze, die [`LH-FA-12`](../../../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren)
      §Abgrenzung zieht. Damit führt [`docs/user/e2e-abdeckung.md`](../../../../docs/user/e2e-abdeckung.md)
      die Kennung in dieser Zeile. **Kein Gate wird davon rot:** der Erzeuger prüft, ob der
      Anker auflöst, nicht *welche* Kennung dasteht, und `make docs-check` prüft an der
      Tabelle nur die Verweise. Träger sind dieser DoD-Punkt und das Review.
- [ ] **Die Sicht entsteht aus den Deklarationen des Ziels, und beide Lücken-Richtungen
      fallen laut.** Die emittierte `selbstpruefung.sh` führt eine Stufen-Kopfzeile in der
      Form, die der Erzeuger liest, und darin den Aufruf, der die Stufe deklariert — die
      Sicht des Ziels hat damit eine Zeile statt null, mit dem **Ort** der Stufe. Ihre
      Kennungs-Zelle trägt den **Gedankenstrich**, keine geratene Anforderung: welche
      Anforderung *seines* Repos diese Stufe trägt, weiß das Werkzeug nicht. Eine
      mitgelieferte Kennungs-Liste gibt es nicht. **Rot durch:** (a) der Stufe ihre
      Deklaration nehmen → der emittierte Erzeuger endet im Ziel mit `Stufe ohne
      Deklaration`, Exit 1, und die `full-smoke`-Stufe fällt; (b) dem Quell-Skript seine
      einzige Stufen-Kopfzeile nehmen → derselbe Exit ≠ 0 mit der **anderen** Richtung in
      der Meldung, statt einer Sicht über null Stufen; (c) die Kennungs-Zelle auf eine
      geratene Kennung setzen → der Fall fällt. Hermetisch laufen alle drei über Kopien in
      [`test/e2e-abdeckung.bats`](../../../../test/e2e-abdeckung.bats) unter `make test`.
- [ ] **Die Tabellen-Form: Spaltenfolge in beiden Fassungen, und die Kennungs-Zelle trägt
      nur, was die Deklaration hergibt.** Die Folge lautet
      `| Spec-Kennung | Kurzbeschreibung | Stufe | Ort |`; gedreht sind der Erzeuger dieses
      Repos, die emittierte Fassung und die Kopf-Prosa, die die Spalten erklärt;
      [`docs/user/e2e-abdeckung.md`](../../../../docs/user/e2e-abdeckung.md) ist mit
      `make e2e-abdeckung` neu erzeugt, nicht von Hand gedreht — dieselbe Mechanik, die im
      Ziel läuft, ist damit hier real erprobt. **Die zwei Fassungen trennt genau eine
      Regel, und sie ist gewollt:** Löst eine deklarierte Kennung in der Spec des Ziels
      nicht auf, schreibt die **emittierte** Fassung sie als Code-Span **ohne Verweis** und
      läuft weiter — die benannte Grenze von
      [`LH-FA-12`](../../../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren);
      unsere Fassung bricht an derselben Stelle ab, weil sie über *unser* Lastenheft
      urteilt. Wer die zwei angleicht, hebt eine Zusage auf. **Rot durch:** eine der zwei
      Fassungen in der Spaltenfolge stehen lassen → `make test` fällt zweifach (Halter-Fall
      gegen den Ausgang des Erzeugers, neuer Fall gegen die Kopfzeile der emittierten
      Fassung); und eine nicht auflösende Kennung in eine Ziel-Deklaration setzen → bricht
      die emittierte Fassung ab, statt den Code-Span zu schreiben, fällt der Fall.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: [`harness/README.md`](../../../../harness/README.md) §Werkzeuge nennt,
      dass `make e2e-abdeckung` dieses Repos und die emittierte Fassung dieselbe Mechanik
      fahren; die Sensor-Datei [`harness/sensors/full-smoke.md`](../../../../harness/sensors/full-smoke.md)
      führt die neue Stufe. Der öffentliche Vertrag ist berührt: ein Adopter bekommt ein
      Kommando mehr.
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
| `internal/emit/templates/enforce/e2e-abdeckung.sh` | neu | die Vorlage des Erzeugers — dieselbe Mechanik wie hier, ihre ziel-spezifischen Stellen als Marker statt als Pfad |
| `internal/emit/templates/enforce/e2e-abdeckung.mk` | neu | macht sie über `make` des Ziels erreichbar; hängt an keiner Gate-Kette (`kein Gate`) |
| `internal/emit/e2eabdeckung.go` | neu | Zielorte, Marker-Liste und Idempotenz-Klasse des Paares — eigene Datei neben `commitmsg.go`/`selbstpruefung.go`, weil der Gegenstand ein anderer ist |
| `internal/emit/enforce.go` | update | nimmt das Paar in die abgelegte Datei-Menge auf |
| `internal/emit/templates/enforce/selbstpruefung.sh` | update | Stufen-Kopfzeile in der lesbaren Form + der Aufruf, der die Anforderung der Stufe nennt |
| `harness/tools/e2e-abdeckung.sh` | update | Spaltenfolge und die Kopf-Prosa, die die Spalten erklärt |
| `docs/user/e2e-abdeckung.md` | update | **erzeugt**, nicht editiert: `make e2e-abdeckung` schreibt sie neu |
| `harness/tools/full-smoke.sh` | update | neue Stufe: das gebootstrappte Ziel erzeugt seine eigene Sicht — samt eigener Deklaration |
| `harness/sensors/full-smoke.md`, `harness/README.md` | update | die Stufen-Liste und die Werkzeug-Zeile nennen, was dazugekommen ist |
| `internal/emit/e2eabdeckung_test.go` | neu | Happy (Ablage, Modus, Marker vollständig) · Negative (fehlender Marker, belegter Pfad) · Kopplung: Vorlage und Fragment nennen dieselben Marker-Namen |
| `test/e2e-abdeckung.bats` | update | Halter auf die neue Spaltenfolge; neuer Fall: die **emittierte** Fassung trägt dieselbe Kopfzeile wie unsere · Negative: Stufe ohne Deklaration über einer Kopie |
| `test/mutations/<NNN>-ziel-e2e-stufe-ohne-deklaration.sh` | neu | der kuratierte Mutations-Fall zum neuen Wächter — ohne ihn ist er ungelistet (`make mutate`) |

- **Ein Ansatz-Satz, weil er sich nicht auf eine Zeile herunterbrechen lässt:** Der
  Erzeuger dieses Repos und seine Vorlage sind **zwei Fassungen derselben Mechanik** —
  dieselbe Lage wie bei `commit-msg-traceability.sh`. Was sie zusammenhält, ist ein Test,
  nicht die Absicht; welche Stellen die Vorlage parametrisiert (Quelle, Spec-Datei,
  Sicht-Ort, Stufen-Präfix) und welche sie wörtlich behält, entscheidet der Implementer
  entlang der Marker-Liste und schreibt es in den Kopf beider Dateien.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): `in-progress/` trägt keinen Slice (WIP-Limit 1 je
Rolleninhaber), und der Auftrag des Auftraggebers vom 2026-09-18 steht — beides ist heute
erfüllt, der Wechsel läuft in diesem Planungs-Lauf.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Die Parametrisierung des
  Erzeugers kostet mehr als die Marker-Liste — sobald der Anker-Ableitung des Ziels ein
  **eigener Schema-Begriff** fehlt (etwa: die Spec des Ziels führt keine `### <Kennung> —
  <Titel>`-Überschriften und der Slug wird zur Konfiguration), ist die Anker-Hälfte ein
  eigener Schnitt und dieser Slice geht zurück.
- `in-progress` → `open` (blockiert — Carveout?): Die neue `full-smoke`-Stufe läuft nicht
  grün, weil das gebootstrappte Ziel den Erzeuger nicht fahren kann, ohne eine Abhängigkeit
  über `bash + git + docker` hinaus zu bekommen
  ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)). Dann
  ist die Emission blockiert, nicht zu groß.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **(1)** `make gates` endet mit Exit 0, und `make full-smoke`
fährt die neue Stufe durch — das gebootstrappte Ziel erzeugt seine Sicht mit **einer**
Zeile, und der Lauf liest deren Ausgabe. **(2)** Jeder der drei Liefer-Punkte ist einmal
**rot gesehen** worden, mit dem Kommando und der Meldung aus §2, nicht nur grün
([`AGENTS.md`](../../../../AGENTS.md) §3.6). Dazu der **Lerneintrag** in §7 in einer der
drei Formen (geschärfte Regel · neuer Sensor · benannte Spec-Lücke). Die Spec-Lücke, die
dieser Slice bei seinem Schnitt fand, ist mit
[`LH-FA-12`](../../../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren)
geschlossen; welche der drei Formen der Lerneintrag trägt, entscheidet die Closure am
Lauf, nicht dieser Plan.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Leistung entsteht vor ihrem Vertrag** — der Slice wurde geschnitten, als keine
  Anforderung die Emission einer Abdeckungs-Sicht zusagte; ein Adopter bekäme dann ein
  Kommando, dessen Zusage nur in diesem Plan steht. Das ist die Richtung eines behaupteten
  Gates, nur umgekehrt: die Leistung ist da, der Rang fehlt. Der Vertrag entsteht nicht
  hier (§1 *Ausdrücklich NICHT* Punkt 2), also entscheidet den Ausgang die Closure und
  nicht dieser Slice-Lauf. — **Ausgang:** <eingetreten: der angenommene Change Request
  setzt [`LH-FA-12`](../../../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren)
  und fängt es auf | entfallen: Grund | weiter offen: → Beobachtung im Register>
- **Die Spaltenfolge ändert die Ableitung, und die Zusagen daneben bleiben stehen** — die
  Kopf-Prosa der erzeugten Datei erklärt die Spalten, `harness/sensors/full-smoke.md` und
  `harness/README.md` sprechen über sie. — **Ausgang:** <eingetreten: → Beleg in
  `../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/` | entfallen:
  Grund | weiter offen: Register>
- **Zwei Fassungen derselben Mechanik driften** — der Erzeuger hier und seine Vorlage; das
  ist die Lage, die `commit-msg-traceability.sh` schon hat, und sie kostet erst beim
  nächsten Eingriff. Träger ist ein Test, keine Absicht. — **Ausgang:** <eingetreten:
  Folge-Slice mit Kennung | entfallen: der Kopplungs-Test deckt beide Fassungen | weiter
  offen: → Beobachtung im Register>
- **Der neue Wächter bekommt keinen Mutations-Fall** und ist damit ungelistet — `make
  mutate` misst nur, was in `test/mutations/` steht. — **Ausgang:** <eingetreten: → Beleg
  in `../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/` | entfallen: der Fall
  liegt und färbt rot | weiter offen: Register>
- **Der emittierte Erzeuger bricht im Ziel laut ab, wenn ein Adopter sein E2E ersetzt** —
  null Stufen sind hier Exit 1, und das ist die Zusage von
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6);
  im fremden Repo ist es aber das erste, was der Adopter von dem Kommando sieht. Ob die
  Meldung ihn zur Deklaration führt statt ihn anzuschreien, ist ein Urteil am Text. —
  **Ausgang:** <eingetreten: Folge-Slice mit Kennung | entfallen: die Meldung nennt die
  Form und den Ort | weiter offen: → Beobachtung im Register>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Gegenstand:** <übernommen von `slice-<Kennung>` | entfallen: <Grund>>
  *(nur beim Ausgang ohne Arbeit; sonst Zeile löschen)*
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

**Vorgelagert — Sub-Area-Wahl prüfen:** Zwei berührte Sub-Areas, beide aus der
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area — keine wird für diesen Slice erfunden.
**`harness/tools/` (`TOOLS`)** erfüllt die Schwelle: eigener Pfad, eigene
Konventions-Verankerung (Adaptions-Block), eigene Werkzeug-Klasse — der Erzeuger und das
E2E liegen dort. **`*` (`ALL`)** trägt den Rest: die Doku-Fläche (`docs/user/`,
`harness/README.md`, `harness/sensors/`) **und die Emitter-Fläche `internal/emit/`**, für
die **keine eigene Sub-Area deklariert ist**. Das ist eine Feststellung, keine Lücke
dieses Slice: Die Deklaration steht in `harness/conventions.md`, und die schreibt der
Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8) — ein Slice, der sich selbst eine
Sub-Area ausstellt, umgeht die Rolle. Ausdifferenziert wird hier also nichts.

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist durchgegangen; es trägt
**145** Einträge (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`), alle mit
Sub-Area `*`, damit trifft die Sub-Area-Frage sie formal alle. Genannt sind die vier, die
**dieser** Slice realistisch berührt, mit dem Zähler-Stand als Zahl der Belege
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`) —
**keine Erwartungswerte**, sie wandern:

| Eintrag | Stand | warum er diesen Slice trifft |
|---|---|---|
| `zusage-neben-geaenderter-ableitung-bleibt-stehen` | 30 | die Spaltenfolge **ist** eine geänderte Ableitung; vier Stellen sprechen über sie (§6 Risiko 2) |
| `zusage-nennt-sensor-der-form-nicht-sieht` | 17 | die neue Zusage nennt `make test` und `make full-smoke` — beide müssen die **Form** sehen, nicht nur den Lauf |
| `zahl-ohne-kommando-trifft-ihren-gegenstand-nicht` | 16 | jede Zahl dieses Plans steht neben ihrem Kommando; die Kopf-Prosa der erzeugten Tabelle führt keine |
| `neuer-waechter-ohne-mutations-fall` | 8 | §6 Risiko 4 — der Fall liegt in §3 als eigene Zeile |

**Keiner erreicht mit diesem Slice 3×** — alle vier liegen längst darüber und tragen ihren
Ausgang im Register; dieser Slice fügt ihnen höchstens einen Beleg hinzu. Eine neue Lücke
mit eigenem Folge-Slice entsteht daraus nicht.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** — `harness/tools/` und `*` stehen in der
Modus-Deklaration als Greenfield; die Blöcke darunter stehen trotzdem, weil dieser Slice
in `harness/tools/` eine gewachsene Mechanik anfasst und die Einordnung dann eine Aussage
ist und keine Formalie.

### Sub-Area: `harness/tools/` (`TOOLS`)

- **Modus:** GF
- **Konventionen-Dichte:** hoch — der Ort ist als Adaption deklariert
  ([`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)),
  der Erzeuger trägt seinen Vertrag im Kopf, und `harness/sensors/full-smoke.md` hält die
  Stufen-Form.
- **Phase-Reife:** Phase 4 — Doku führt, Code folgt, und beide Richtungen der Lücke sind
  bereits bewacht (Deklaration ohne Stufe, Stufe ohne Deklaration).
- **Evidenz-/Diskrepanz-Risiko:** niedrig für den Code, **mittel für die Prosa** — die
  vier Stellen aus §6 Risiko 2 sprechen über eine Spaltenfolge, die dieser Slice dreht.
- **Reconciliation-Aufwand:** keiner (GF). Graduation entfällt.

### Sub-Area: `*` (`ALL`)

- **Modus:** GF
- **Konventionen-Dichte:** hoch — Emission und Idempotenz-Klassen stehen in
  [`ADR-0007`](../../../../docs/plan/adr/0007-bootstrap-phasen.md) und
  [`ADR-0054`](../../../../docs/plan/adr/0054-emittierter-commit-traeger-skip-if-present.md);
  das neue Paar ist konvergent wie die übrigen tool-eigenen Dateien.
- **Phase-Reife:** Phase 4 — die emittierte Ebene hat Vorlage, Test und E2E; dieser Slice
  fügt ein Paar in eine bestehende Reihe ein.
- **Evidenz-/Diskrepanz-Risiko:** niedrig — die Emission ist durch `make full-smoke` real
  gemessen, nicht behauptet.
- **Reconciliation-Aufwand:** keiner (GF). Graduation entfällt.
