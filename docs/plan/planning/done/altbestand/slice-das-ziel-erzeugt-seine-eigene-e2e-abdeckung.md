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

- [x] **Der Erzeuger reist ins Ziel und läuft dort.** Das Paar
      `tools/harness/e2e-abdeckung.sh` + `harness/mk/e2e-abdeckung.mk` <!-- d-check:ignore (der Pfad entsteht mit diesem Slice) --> wird emittiert
      (konvergent, ausführbar), seine vier ziel-spezifischen Stellen — Quell-Skript, Wort
      der Stufen-Kopfzeile, Spec-Datei, Zielort der Sicht — stehen als **gesetzte,
      überschreibbare Marker**
      ([`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)),
      der Aggregator des Ziels bindet das Fragment über `include harness/mk/*.mk` ein, der
      Lauf endet mit Exit 0 und die Sicht liegt am **deklarierten** Zielort. Gemessen ist
      ein gesetzter Marker an dem, **was entsteht**, nicht an seiner Erwähnung in der
      Ausgabe. **Der Spec-Marker lenkt dabei keine Ableitung**, sondern nennt den Maßstab,
      gegen den der Leser die Sicht hält — die Kennungs-Zelle der ausgelieferten Fassung
      ist ein Code-Span (LP3). **Zeigt er auf nichts, sagt der Lauf das:** eine Sicht, die
      einen Maßstab nennt, den es im Ziel nicht gibt, behauptet Prüfbarkeit, die niemand
      einlösen kann — derselbe Satz wie in
      [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
      eine Ebene tiefer. Ein Abbruch ist es nicht: die Sicht entsteht ohne die Spec-Datei
      vollständig, nur ihr Maßstab fehlt. **Rot durch:** den Hinweis herausnehmen und den
      Marker auf einen Pfad setzen, den das Ziel nicht führt → der Fall in
      [`test/e2e-abdeckung.bats`](../../../../test/e2e-abdeckung.bats) sieht eine Ausgabe
      ohne den Hinweis und fällt. Der Erzeuger fügt dem Ziel keine Abhängigkeit hinzu: er liest Text — kein
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
      die Kennung in dieser Zeile. **Kein Gate wird davon rot:** unsere Fassung prüft, ob
      die genannte Kennung im Lastenheft eine **Überschrift** hat — nicht, ob es die
      **richtige** Kennung für diese Stufe ist; die ausgelieferte prüft auch das erste
      nicht, und `make docs-check` prüft an der Tabelle nur die Verweise. Träger sind
      dieser DoD-Punkt und das Review.
- [x] **Die Sicht entsteht aus den Deklarationen des Ziels, und beide Lücken-Richtungen
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
- [x] **Die Tabellen-Form: Spaltenfolge in beiden Fassungen, und die Kennungs-Zelle trägt
      nur, was die Deklaration hergibt.** Die Folge lautet
      `| Spec-Kennung | Kurzbeschreibung | Stufe | Ort |`; gedreht sind der Erzeuger dieses
      Repos, die emittierte Fassung und die Kopf-Prosa, die die Spalten erklärt;
      [`docs/user/e2e-abdeckung.md`](../../../../docs/user/e2e-abdeckung.md) ist mit
      `make e2e-abdeckung` neu erzeugt, nicht von Hand gedreht — dieselbe Mechanik, die im
      Ziel läuft, ist damit hier real erprobt. **Die zwei Fassungen trennt genau eine
      Regel, und sie hängt am Träger:** Die **ausgelieferte** Fassung schreibt **jede**
      Kennung als Code-Span und leitet keinen Anker ab — ein Verweis brauchte einen Anker,
      den dieses Werkzeug aus einer fremden Überschrift nachbilden müsste, und eine
      Nachbildung im fremden Repo kann es weder kalibrieren noch halten; ein Code-Span
      behauptet nichts. **Unsere** Fassung leitet ab und verweist, weil ihr Träger hier
      existiert: `make docs-check` prüft in `make gates` genau den Ausgang dieses Erzeugers,
      und eine Kennung ohne Überschrift im Lastenheft bricht den Lauf ab, statt einen Link
      ohne Ziel zu schreiben. Wer die zwei angleicht, nimmt der einen ihren Träger oder der
      anderen ihre Zurückhaltung. **Rot durch:** (a) eine der zwei Fassungen in der
      Spaltenfolge stehen lassen → `make test` fällt zweifach (Halter-Fall gegen den
      Ausgang des Erzeugers, Fall gegen die Kopfzeile der ausgelieferten Fassung); (b) der
      ausgelieferten Fassung die Verweis-Form geben — die Zelle als Link statt als
      Code-Span → der Fall, der die Kennungs-Zelle der emittierten Sicht gegen die
      Code-Span-Form hält, fällt; (c) einer Deklaration in `harness/tools/full-smoke.sh`
      eine Kennung ohne Überschrift im Lastenheft geben → unser `make e2e-abdeckung` endet
      mit `hat keine Ueberschrift`, Exit 1. Nimmt man **diesen Abbruch** heraus, schreibt
      unsere Fassung einen Link ohne Ziel und `make docs-check` fällt im Modul `anchors` —
      damit ist auch der Träger, auf dem ihre Ableitung ruht, einmal rot gesehen.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: [`harness/README.md`](../../../../harness/README.md) §Werkzeuge nennt,
      dass `make e2e-abdeckung` dieses Repos und die emittierte Fassung dieselbe Mechanik
      fahren; die Sensor-Datei [`harness/sensors/full-smoke.md`](../../../../harness/sensors/full-smoke.md)
      führt die neue Stufe. Der öffentliche Vertrag ist berührt: ein Adopter bekommt ein
      Kommando mehr.
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
  nicht dieser Slice-Lauf. — **Ausgang: entfallen.** Der Zustand, den das Risiko benennt,
  kann nicht mehr eintreten:
  [`LH-FA-12`](../../../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren)
  steht im Lastenheft — gesetzt vom Architect als angenommener Change Request (`4c033b4e`)
  und damit **vor** dem Abschluss dieses Slice —, und die Verifikation hat alle acht
  Akzeptanzkriterien einzeln gegen die drei Liefer-Punkte gehalten. Ein Adopter bekommt das
  Kommando mit seinem Rang, nicht ohne. **Warum nicht *eingetreten*:** Die drei Ausgänge
  sind eine geschlossene Menge, und *eingetreten* verlangt einen Carveout oder einen
  Folge-Slice mit Kennung (`modul-05-planning-harness.md` §Offene Risiken); beides hätte
  hier kein Objekt, weil nichts mehr aufzufangen ist. Dass die Arbeit **vor** ihrem Vertrag
  geplant wurde, bleibt wahr und steht in §7 — ausgeblieben ist der Schaden, den das Risiko
  benennt, nicht die Reihenfolge.
- **Die Spaltenfolge ändert die Ableitung, und die Zusagen daneben bleiben stehen** — die
  Kopf-Prosa der erzeugten Datei erklärt die Spalten, `harness/sensors/full-smoke.md` und
  `harness/README.md` sprechen über sie. — **Ausgang: weiter offen**, ins
  Beobachtungs-Register als
  [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md).
  Vier der fünf Stellen tragen die neue Folge — unser Erzeuger, die Vorlage, die Kopf-Prosa
  der erzeugten Datei und `harness/sensors/full-smoke.md`, je vom Verifier nachgelesen. Die
  **fünfte** zählte §6 nicht auf und steht unverändert:
  [`LH-FA-12`](../../../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren)
  §Benannte Grenze trägt einen Konditional, dessen anderer Fall im Code nicht mehr vorkommt
  (V-3). Ihr Text ist Vertrags-Stratum und gehört dem Architect
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8) — die Adresse steht in §7. *Eingetreten*
  verlangte Carveout oder Folge-Slice; ein Slice, der fremden Vertragstext schriebe, wäre
  eine Adresse, die die Rolle umgeht. *Entfallen* wäre falsch, solange der Satz so dasteht.
  Der dritte Ausgang hängt ihn an den Zähler.
- **Zwei Fassungen derselben Mechanik driften** — der Erzeuger hier und seine Vorlage; das
  ist die Lage, die `commit-msg-traceability.sh` schon hat, und sie kostet erst beim
  nächsten Eingriff. Träger ist ein Test, keine Absicht. — **Ausgang: entfallen.** Der
  Träger ist gebaut und dreifach: die bats-Fälle `kopplung: die zwei Fassungen teilen die
  Form und trennen sich in EINER Sache — dem Verweis` und `trennlinie: die ausgelieferte
  Fassung schreibt nie einen Verweis, unsere immer einen aufloesenden` sowie der Go-Fall
  `TestE2eAbdeckung_DieMarkerStehenInBeidenDateienUndSonstKeiner`, der eine Umbenennung in
  nur einer der zwei Dateien fallen lässt. Damit deckt ein Sensor genau das, was das Risiko
  meint: eine Änderung in einer Fassung ohne die andere wird laut. **Grenze, und sie ist
  nicht hier gezählt:** Keiner der drei steht in `test/mutations/`, ihre Haltbarkeit ist
  ungemessen — das ist Risiko 4 und dort im Register belegt, nicht ein zweites Mal hier.
- **Der neue Wächter bekommt keinen Mutations-Fall** und ist damit ungelistet — `make
  mutate` misst nur, was in `test/mutations/` steht. — **Ausgang: weiter offen**, ins
  Beobachtungs-Register als
  [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md).
  Der Verifier hält ein einzelnes *entfallen* für breiter als seinen Beleg, und das trifft:
  gelistet ist **einer** (`363-ziel-e2e-stufe-ohne-deklaration.sh`, rot gesehen), die
  übrigen elf bats-Fälle dieses Slice sind es nicht — der Plan führte den Posten im Singular
  und traf die gebaute Menge nicht. *Entfallen* wäre über die Gesamtmenge falsch;
  *eingetreten* verlangte Carveout oder Folge-Slice, und der Register-Eintrag trägt seit
  seinem Übertritt den Ausgang *verkörpert* ([`AGENTS.md`](../../../../AGENTS.md) §3.6) —
  ein zweiter Mechanismus daneben ist genau der, den `modul-05-planning-harness.md` §Offene
  Risiken ausschließt. Der dritte Ausgang hängt das Risiko an den Zähler.
- **Der emittierte Erzeuger bricht im Ziel laut ab, wenn ein Adopter sein E2E ersetzt** —
  null Stufen sind hier Exit 1, und das ist die Zusage von
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6);
  im fremden Repo ist es aber das erste, was der Adopter von dem Kommando sieht. Ob die
  Meldung ihn zur Deklaration führt statt ihn anzuschreien, ist ein Urteil am Text. —
  **Ausgang: entfallen.** Die Meldung führt den Adopter, statt ihn anzuschreien, und zwar
  gemessen statt geurteilt: Der Verifier hat den Null-Stufen-Fall selbst gefahren und
  gelesen — sie nennt die **Form** der Stufen-Kopfzeile wörtlich, die Form der Deklaration,
  die Funktion, die dazugehört, und die zwei Marker mit einem lauffähigen Aufruf. Die zweite
  Lücken-Richtung nennt Stufe, Region und ein `Nachweis:`-Kommando zum Nachsehen. Was das
  Risiko fürchtete — ein Abbruch ohne Weg nach vorn —, kann an dieser Meldung nicht mehr
  eintreten.

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

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10). Eingang
sind die vier Review-Reports und der Verifikations-Report, alle vom 2026-09-18. Maßstab sind
Baseline-Regelwerk `v6.9.0` · `modul-05-planning-harness.md` §Closure- und Lerneintrag-Regeln und
`modul-06-roadmap.md` §Das Beobachtungs-Register.

- **Was hat funktioniert:**
  - **Die Mechanik ist im Ziel gemessen, nicht im Emitter behauptet.** Die neue Stufe von
    [`make full-smoke`](../../../../harness/sensors/full-smoke.md) bootstrappt, ruft
    `make e2e-abdeckung` im Ziel und liest dessen Ausgabe; der Verifier hat beide
    Bootstrap-Varianten (sprachlos und `--lang go`) selbst gefahren und ihre Sichten
    byte-gleich gefunden. Der Adopter bekommt damit eine Sicht, die aus **seinen**
    Deklarationen entsteht — mit Gedankenstrich statt geratener Kennung, weil das Werkzeug
    seine Anforderungen nicht kennt.
  - **Beide Lücken-Richtungen fallen laut, und sie sind unterscheidbar.** Stufe ohne
    Deklaration und Quell-Skript ohne Stufen-Kopfzeile enden je mit Exit ≠ 0 und mit der
    **anderen** Meldung — im Ziel gefahren, nicht hier simuliert. Eine Sicht über null Stufen
    entsteht nicht; das ist
    [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
    eine Ebene tiefer.
  - **Vier Review-Runden haben ihre Befunde weitergetragen, und die vierte war die
    entscheidende.** Sie fand keinen Defekt mehr am Lauf, sondern drei Sätze, die neben ihrer
    bewegten Ableitung stehengeblieben waren — genau die Klasse, die der Slice bei sich selbst
    im Blick hatte. Zwei davon hat der Slice behoben, die dritte ist eine Adresse an den
    Architect.
- **Was ging anders als geplant:**
  - **Der Verweis-Zweig der ausgelieferten Fassung ist ganz entfallen.** Geplant war eine
    Fassung, die im Ziel Anker ableitet; drei Runden lang fiel dieselbe Klasse auf — ein
    abgeleiteter Anker, der gegen die Zieldatei nicht geprüft ist —, und die Auflösung war
    nicht die vierte Kalibrierung, sondern der Wegfall: Die emittierte Fassung schreibt jede
    Kennung als Code-Span und leitet nie einen Anker ab. Das ist enger als der Plan und
    trägt besser: Ein Werkzeug, das im fremden Repo einen Renderer nachbildet, den es weder
    kalibrieren noch halten kann, verspricht mehr, als ein Lauf einlöst. Der Beleg liegt im
    Register (unten).
  - **§3 deckt den gebauten Satz nicht** (Verifikation V-2, Review in den Runden 1–3).
    *Gebaut, nicht geplant:* der `help`-Filter in `Makefile` und `internal/emit/makefile.go`
    (er ließ Ziffern im Target-Namen nicht durch, und `e2e-abdeckung` trägt eine), zwei
    Zeilen in `internal/emit/baumaussage_test.go` und eine vierte Form in der
    Ausnahmeliste von `test/full-smoke-ausgang.bats`. Alle vier sind notwendige Folgen der
    Emission, keine verletzt §1. **§3 bleibt trotzdem, wie er ist:** Der Plan ist das
    Artefakt *vor* dem Code; ein nachgetragener Plan behauptete Voraussicht, die es nicht
    gab. Der Befund steht hier und im Register.
- **Entscheidungen zu den Befunden, die offen in die Closure kamen:**
  - **V-1 (MEDIUM): Register, kein Folge-Slice.** Der Befund misst die Differenz zwischen
    zwölf neuen bats-Fällen und **einem** gelisteten Mutations-Fall. Er verschwindet nicht
    spurlos — er hängt am Ausgang von §6 Risiko 4 und ist dort *weiter offen* — und er
    wiederkehrt real: der Eintrag
    [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
    steht längst über der Schwelle und trägt seinen Ausgang *verkörpert*. Ein eigener
    Vorgang daneben wäre der zweite Mechanismus, den `modul-05-planning-harness.md` §Offene
    Risiken ausschließt; die Regel steht, was fehlt, ist ihre Anwendung im nächsten Lauf,
    der diese Wächter anfasst.
  - **V-2 (LOW): Register, und §3 bleibt.** Begründung oben; der Beleg liegt unter
    [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
    zusammen mit den zwei übrigen Funden derselben Klasse aus diesem Vorgang — **ein**
    Vorgang, **ein** Beleg.
  - **V-4 (INFO): abgelehnt, mit Grund.** Der Befund nennt eine ungemessene Größe (ob
    `docs/user/e2e-abdeckung.md` im Scan-Bereich des ziel-eigenen `docs-check` liegt) und
    sagt selbst, dass sie folgenlos ist: Die emittierte Fassung schreibt **null** Verweise,
    das Doku-Gate des Ziels hätte dort nichts zu finden. Was der Befund verhindert, ist eine
    zu breite Lesart des grünen Ziel-`docs-check` — und diese Grenze steht bereits im
    Verifikations-Report. Ein Vorgang ohne Gegenstand entsteht daraus nicht; träte die Größe
    je in eine Zusage ein, wäre **dann** ihr Maß fällig.
- **Trigger-Audit** (`modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 2, hier bei der
  Slice-Closure): **Carveouts** — `CO-001` (bats-Hilfsfunktionen mit Verzweigung) hat nicht
  gefeuert: die zwölf neuen bats-Fälle sind lineare `run`+`assert`-Zeilen; `CO-002` ist
  ausgegangen und wartet auf nichts mehr. **ADRs** —
  [`ADR-0007`](../../../../docs/plan/adr/0007-bootstrap-phasen.md) (drei Trigger: gate-belang
  sprach-abhängig, Mono-Repo-Bedarf entfällt, interaktive Ergonomie) ist unberührt; der Slice
  fügt der bestehenden Phasen-Reihe ein konvergentes Paar hinzu, und beide Bootstrap-Varianten
  erzeugen dieselbe Sicht.
  [`ADR-0054`](../../../../docs/plan/adr/0054-emittierter-commit-traeger-skip-if-present.md)
  (drei Trigger um die Herkunfts-Entscheidung des Werkzeugs) ist ebenfalls unberührt: das neue
  Paar ist **konvergent**, nicht skip-if-present, und ändert an der Klassen-Wahl des
  Commit-Trägers nichts. **Anforderungen** —
  [`LH-FA-12`](../../../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren) ist
  mit diesem Slice eingelöst (acht Akzeptanzkriterien, einzeln verifiziert);
  [`LH-FA-11`](../../../../spec/lastenheft.md#lh-fa-11--selbstprüfung-der-durchsetzungsschicht-emittieren)
  bleibt in ihrem Umfang — die Selbstprüfung bekam ihre Deklaration, keine zusätzliche
  Prüfung;
  [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) trägt
  die vier Marker, jeder an dem gemessen, was entsteht. **Adaptions-Einträge** — berührt sind
  [`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)
  (der Erzeuger liegt unter `harness/tools/`) und
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  (jede Zahl dieses Slice steht neben ihrem Kommando); keiner der beiden trägt einen
  Auflösungs-Trigger, der durch diesen Slice fiele.
- **Steering-Loop-Eintrag:** **Neuer Sensor.** Das gebootstrappte Ziel erzeugt seine
  E2E-Abdeckungs-Sicht ab jetzt **selbst** — `make e2e-abdeckung` liest die
  Stufen-Kopfzeilen und Deklarationen seines eigenen E2E und schreibt daraus eine Tabelle in
  der Folge `| Spec-Kennung | Kurzbeschreibung | Stufe | Ort |`; fehlt einer Stufe ihre
  Deklaration oder dem Quell-Skript seine Stufen-Kopfzeile, endet der Lauf mit Exit ≠ 0 und
  je eigener Meldung. Gehalten wird er dreifach: hermetisch von
  `internal/emit/e2eabdeckung_test.go` und den zwei Zeilen in
  `internal/emit/baumaussage_test.go` (`make test`), über Kopien von
  [`test/e2e-abdeckung.bats`](../../../../test/e2e-abdeckung.bats), und real von der neuen
  Stufe in [`make full-smoke`](../../../../harness/sensors/full-smoke.md) mit einem
  gelisteten Mutations-Fall.
  - **Ohne Anker-Feld.** Der Sensor löst eine Anforderung des Lastenhefts ein
    ([`LH-FA-12`](../../../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren)),
    nicht einen 3×-Übertritt des Registers; `grundlagen-traceability.md` §Herkunfts-Anker
    bindet den Anker eng an die Schwelle, und `liegt in` steht deshalb hier nicht.
  - **Was er zieht:** Ein Adopter kann nach dem Bootstrap ohne den Emitter sagen, welche
    Stufe seines E2E welche Anforderung trägt — und sieht beide Lücken-Richtungen, statt eine
    Sicht zu bekommen, die schweigt.
  - **Was er nicht erreicht:** die Wahrheit der Zuordnung. Ob eine Stufe die genannte
    Anforderung wirklich prüft, misst er nicht; das schließt
    [`LH-FA-12`](../../../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren)
    §Abgrenzung ausdrücklich aus und bleibt ausgeschlossen. Und die Kennungs-Zelle der
    ausgelieferten Fassung trägt einen Code-Span, nie einen Verweis.
- **Beobachtungs-Register (`../observations/`):** drei Belege, alle unter dem Namen
  `evidence/slice-das-ziel-erzeugt-seine-eigene-e2e-abdeckung.md`. Den Zähler je Eintrag
  liefert `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, die Zahl
  der Belege aus diesem Vorgang
  `ls docs/plan/planning/observations/BEO-ALL/*/evidence/slice-das-ziel-erzeugt-seine-eigene-e2e-abdeckung.md | wc -l`.
  Keine der Zahlen ist ein Erwartungswert.

  | Eintrag | Quelle | Stand |
  |---|---|---|
  | [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md) | §6 Risiko 2 (*weiter offen*); Verifikation V-2, V-3; Review Runden 1–4 | geplant |
  | [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md) | §6 Risiko 4 (*weiter offen*); Verifikation V-1 | verkörpert |
  | [`emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md) | Review Runden 1–3, dieselbe Finding-Klasse in jeder Summary-Zeile | offen |

  **Der dritte Beleg kommt aus dem Review, nicht aus einem Risiko** — die dritte Quelle, die
  `modul-05-planning-harness.md` §Closure- und Lerneintrag-Regeln für den Closure-Eintrag
  nennt. Die Klasse *abgeleiteter Anker wird geschrieben, ohne gegen die Zieldatei geprüft zu
  sein* trat in drei Runden dreimal auf, jedes Mal mit verschobener Ursache; **ein Vorgang
  zählt einmal**, deshalb ein Beleg und nicht drei. Kein vorhandener Nachbar trägt sie: Der
  Eintrag selbst grenzt sich gegen
  [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  ab — dort hat sich eine Ableitung **bewegt**, hier war die Aussage von Anfang an weiter als
  ihr Zweig.

  **Lese-Schritt.** **Kein** Eintrag erreicht mit diesem Slice zum ersten Mal 3×: zwei
  standen schon deutlich darüber und tragen seit ihrem Übertritt einen Ausgang (*geplant*
  mit Kennung, *verkörpert* mit Zielort), der dritte steht mit diesem Beleg bei zwei. Es ist
  damit **keine** Regel zu verkörpern und kein Ausgang neu zuzuweisen.
- **Folge-Slices:** **keiner.** Kein Befund dieses Slice verschwände ohne einen: V-1 und V-2
  sind im Register gezählt, V-4 ist mit Grund abgelehnt, V-3 ist eine Adresse an eine andere
  Rolle. Der einzige Posten mit Arbeitsfolge ist der Vertragstext von [`LH-FA-12`](../../../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren), und den
  schreibt der Architect, kein Slice-Plan.
- **Risiken aus §6:** fünf, jedes mit genau **einem** Ausgang — Risiko 1, 3 und 5 *entfallen*
  mit Begründung, Risiko 2 und 4 *weiter offen* ins Register. Die Begründungen stehen
  ausgeschrieben in §6; die zwei *weiter offen* sind die beiden Fälle, in denen ein
  *entfallen* breiter wäre als sein Beleg.
- **Drei Paarungen** (geprüft zur Closure, nach dem `git mv`; das Repo führt offene Wellen,
  deren Closure sie für ihre eigene Menge erneut prüft):
  - **Anker:** kein Gegenstand — der Steering-Loop-Eintrag trägt kein Feld `liegt in`, weil
    mit diesem Slice keine 3×-Regel verkörpert wurde.
  - **Folge-Slice:** kein Gegenstand — dieser Slice nennt keinen.
  - **Register:** jede hier genannte Beobachtung existiert als Verzeichnis unter
    `observations/BEO-ALL/`, und jedes dieser Verzeichnisse trägt mindestens einen Beleg.
    **Die repo-weite Hälfte ist an zwei Stellen rot** — gemessen zur Closure über
    `for d in docs/plan/planning/observations/BEO-ALL/*/; do ls "$d"evidence/*.md >/dev/null 2>&1 || echo "$d"; done`:
    [`einstiegs-datei-weicht-von-der-pflichtgliederung-ab`](../observations/BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab/observation.md)
    und
    [`planungs-bestand-waechst-schneller-als-er-abgebaut-wird`](../observations/BEO-ALL/planungs-bestand-waechst-schneller-als-er-abgebaut-wird/observation.md)
    tragen keinen Beleg; ihr einziges Vorkommen steht dort jeweils unter *Benannt, nicht
    gezählt*. Beide sind **kein Fund dieser Closure** — dieser Slice zitiert keine von ihnen
    —, und die Lesart dafür entscheidet `slice-beleglose-register-eintraege-bekommen-eine-lesart`.
    Der Stand ist gegenüber dem vorigen Abschluss unverändert; die Zahl wandert, und deshalb
    steht hier das Kommando.
- **Adressen, die bei Abschluss zu entscheiden sind** *(hier notiert, nicht hier
  entschieden)*:
  - **Architect —** [`LH-FA-12`](../../../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren)
    §Benannte Grenze ist wörtlich wahr und ihre Implikatur nicht mehr: Sie stellt den
    Code-Span als **Ausnahme** für die nicht auflösende Kennung dar, während die
    ausgelieferte Fassung ihn als **Regel** für jede schreibt. Der Verifier hat den Befund
    bestätigt (V-3) und eine Fassung vorgeschlagen: den Konditional durch eine Feststellung
    ersetzen — *die Kennungsspalte der emittierten Sicht trägt Code-Spans; ein Verweis
    entsteht dort nie*. Das Lastenheft ist Vertrags-Stratum und wird hier nicht angefasst
    (§1 *Ausdrücklich NICHT* Punkt 2) — die Adresse steht, den Text schreibt der Architect.
  - **Beobachtung — erledigt, und deshalb keine Adresse mehr:** Der Hinweis auf eine fehlende
    Spec-Datei war mit dem Verweis-Zweig weggefallen, während die geschriebene Sicht sie
    weiter als Maßstab des Lesers nennt; `ac814e63` stellt ihn an beiden zugesagten Stellen
    wieder her, der Verifier hat beide gelesen. Der Beleg liegt unter
    [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md).

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
