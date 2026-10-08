# Slice slice-zeilenenden-meldungstest-bindet-das-verzeichnis: Der Meldungs-Test der Zeilenenden misst das Verzeichnis, das die Meldung nennt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Der Slice hat keine Closure-Bedingung, die von seiner eigenen DoD verschieden
ist: sein Beleg ist ein rot und grün gesehener Test samt Mutations-Fall und ein grüner Gate-Lauf, und
sie stehen in §2 (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Ebene: Test-Code der Emission und ein Fall im Mutations-Set — Dogfood.** Eine Schicht:
`internal/emit/` (ein Test). Der Fall in `test/mutations/` ist Konfiguration des Mutations-Sensors und
keine zweite Schicht; Produktions-Code und emittiertes Verhalten bleiben unberührt (§1).

**Bezug:**
[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (Scope: erstklassig auf
Windows; die Zusage, deren Wächter dieser Slice schärft, hält die Zeilenenden emittierter Dateien),
[`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (die
Durchsetzungs-Mechanik, deren Skripte der Klon mit LF braucht),
[`ADR-0067`](../../adr/0067-emittierte-zeilenenden-ein-attribut-je-verzeichnis-mit-interpreter-konsument.md)
(**Accepted** — Festlegung 3 und 4: die Klasse je Pfad und die Meldung, die den belegten Pfad nennt
und sagt, was dann gilt),
[`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
(die Anlage des Falls misst ihr `sed`-Muster gegen den Quell-Bestand),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl dieses Plans steht neben dem Kommando, das sie ausgibt),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (der Grund des Slice: ein Test, dessen Name eine
Eigenschaft behauptet, misst die Eigenschaft).

**Berührte Spec-Stellen:**
[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) ·
[`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) — beide nur
als Gegenstand, den der Test hält; keine Spec-Aussage ändert sich, und kein Change Request entsteht.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-25.

---

## 1. Ziel und Abgrenzung

<!-- BEDIENHINWEIS: Ziel = ein Satz, Liefer-Fokus, kein "wir machen
aufraeumen". Abgrenzung = je Punkt eine Begruendung, nicht nur eine Nennung:
ein Ausschluss ohne Grund ist eine Behauptung. Keine Mindestzahl — ein echter
Ausschluss ist besser als vier erfundene. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Der Test der Meldung an einem belegten skip-if-present-Pfad hält, dass die Meldung in ihrer
Aussage das **Verzeichnis nennt, dessen Dateien sie betrifft** — mit einer Erwartung aus einer Quelle,
die von der geprüften Meldung unabhängig ist —, und ein Fall in `test/mutations/` färbt ihn rot, sobald
die Meldung ein anderes Verzeichnis nennt.

**Die gemessene Lage** (Stand 2026-09-25; **keine Erwartungswerte**,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)):

- Die Aussage-Schleife in `TestZeilenenden_BelegterPfadBleibtUndWirdGemeldet` prüft vier Zeichenketten
  gegen die Meldungszeile eines belegten Pfades, darunter `path.Dir(rel) + "/"`
  (`grep -n 'path.Dir(rel)' internal/emit/zeilenenden_test.go` nennt die Zeile der Schleife und eine
  weitere in einer Fehlermeldung des Anlegens). Die Meldungszeile beginnt mit dem Pfad `rel` selbst
  (`.githooks/.gitattributes`), und der trägt `.githooks/` bereits. Die Bedingung ist damit durch
  Konstruktion erfüllt, gleich, welches Verzeichnis der Aussagesatz nennt.
- Die Sonde des Verifiers am Stand `HEAD`: nennt der Aussagesatz des Eintrags `.githooks` das Verzeichnis
  `x/`, bleibt `make test-go` grün. Der Doc-Kommentar des Tests beansprucht, die Meldung nenne „den Pfad
  UND die Aussage, was dann gilt" — für das Verzeichnis in der Aussage misst der Test das nicht.
- Fall-Muster: die sechs Fälle des Vorgänger-Slice liegen bei den Nummern 446 bis 451 und ankern am
  Quelltext der Emission (`grep -l 'internal/emit/zeilenenden' test/mutations/*.sh | wc -l` → **3**; die
  Fälle, die einen `TestZeilenenden_`-Test erwarten:
  `grep -l 'TestZeilenenden_' test/mutations/*.sh | wc -l` → **6**). Der Treiber führt jeden Fall mit
  `bash <Fall>` aus (`grep -n 'bash "\$case_file"' harness/tools/mutate.sh` → Zeile 687), der Modus der Datei
  wirkt also nicht; das Set führt beide Modi
  (`git ls-files -s 'test/mutations/*.sh' | awk '{print $1}' | sort | uniq -c` → 114 × `100644`,
  325 × `100755`), und der neue Fall trägt `100755` wie seine Nachbarn 446 bis 451.

**Warum ein eigener Slice und keine Nacharbeit im Vorgänger:** der Vorgänger-Slice
(`slice-emittierte-dateien-behalten-lf-im-autocrlf-klon`) ist geschlossen; der Verifikations-Report vom
2026-09-25 hat die Lücke als LOW-V1 an den Planner übergeben, der Auftraggeber hat den Folge-Slice
freigegeben. Die Zusage der DoD dort („die Meldung nennt den Pfad und die Aussage") war bestätigt, und
sie bleibt es; die Tiefe des Wächters ist der Gegenstand hier.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Klasse je Pfad im `TestEnforce_IdempotenzKlasseJePfad` gegen die ADR halten (Verifier LOW-V2).**
  Bestand bleibt bewusst stehen. Der Test liest die Klasse aus `PathClass` und hält `Enforce` gegen sie;
  sein Doc-Kommentar schließt eine zweite Klassen-Liste im Test ausdrücklich aus, weil zwei Fassungen der
  Klassifikation auseinanderliefen. Die Klasse der fünf Zeilenenden-Pfade gegen die Festlegung der ADR
  ([`ADR-0067`](../../adr/0067-emittierte-zeilenenden-ein-attribut-je-verzeichnis-mit-interpreter-konsument.md)
  Festlegung 3) hält `TestZeilenenden_BelegterPfadBleibtUndWirdGemeldet` aus einer eigenen Aufzählung, und
  der Verifier hat sie rot gesehen: mit dem Klassenwechsel eines Pfades fällt genau dieser Test (die
  `--- FAIL:`-Liste des Laufs nennt einen Test). Der Doc-Kommentar des Idempotenz-Tests behauptet nichts
  über die Klassen der Zeilenenden-Pfade; was LOW-V2 benennt, ist die Abweichung zwischen dem Plantext des geschlossenen Slice und
  dem Ort der Deckung, keine ungehaltene Zusage. Eine zweite Liste wäre Aufwand ohne Deckungsgewinn und
  ein Bruch mit dem Kommentar des Bestands. Wandert die Klassen-Deckung je aus dem Meldungs-Test heraus,
  ist die Lücke real und braucht dann einen eigenen Schnitt; solange sie dort liegt, hat sie keine Adresse
  nötig.
- **Die drei übrigen Aussage-Zeichenketten (`* text=auto eol=lf`, `core.autocrlf=true`, `CRLF`) bekommen
  keinen eigenen Fall je Zeichenkette.** Sie stehen in einem Satz, den ein vorhandener Fall (der die
  Aussage aus der Meldung nimmt) als Gruppe färbt; der Verifier hat die Gruppe entwaffnet und den Fall
  grün gesehen, also bindet er sie. Je Zeichenkette ein Fall wären drei Fälle für einen Satz. Gemessen
  wird jede einzeln als **Sonde** (§3), nicht als Fall — zeigt eine Sonde eine ungebundene Zeichenkette,
  ist das ein Befund dieses Slice und geht ins Register (§6), nicht in einen vierten Liefer-Punkt.
- **Produktions-Code (`internal/emit/zeilenenden.go`, die Meldung selbst).** Andere Schicht: die Meldung
  ist richtig (sie nennt das Verzeichnis, dessen Pfad sie belegt meldet), es fehlte der Test, der es
  misst. Änderte dieser Slice den Wortlaut, verschöbe er die Anker der Fälle, die dort ankern
  (`grep -l 'internal/emit/zeilenenden' test/mutations/*.sh | wc -l` → **3**), und mischte Gegenstand und
  Wächter.
- **Ein Wächter für die Klasse „Erwartung stammt aus dem geprüften Gegenstand".** Das wäre ein anderer
  Vorgang: ein Sensor über Assertions statt ein Test über eine Meldung. Das Register führt die Klasse mit
  einem Beleg (`ls docs/plan/planning/observations/BEO-ALL/erwartung-stammt-aus-dem-geprueften-gegenstand/evidence/*.md | wc -l`
  → **1**), unter der Schwelle; die Klasse hat ihre Wächter-Frage im Eintrag benannt (kein Sensor, Träger
  ist die Gegenprobe des Verifiers), und dieser Slice fügt ihr weder einen Beleg noch einen Sensor hinzu.
- **Ein voller `make mutate`-Lauf als Bedingung.** Der Lauf dauert je Fall einen vollen Sensor-Lauf und
  läuft nächtlich (`mutate.yml`); die DoD verlangt die engste tragfähige Messung (§3, Messweg), nicht den
  Vollauf, und sie benennt, was sie nicht deckt.
- **Die Klon-Stufe `zeilenenden_im_klon` und Windows.** Der Slice ändert weder die Stufe noch die
  Grenze der Messmethode aus
  [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix); sein Gegenstand ist ein Go-Test.

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

<!-- BEDIENHINWEIS: je Zeile ein pruefbares Kriterium. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

**Liefer-Punkte dieses Slice — zwei** (die Größenregel lässt drei):

- [ ] **Liefer-Punkt 1 — die Assertion bindet das Verzeichnis.** In
      `TestZeilenenden_BelegterPfadBleibtUndWirdGemeldet` prüft die Aussage-Schleife für jeden der drei
      skip-if-present-Pfade, dass die Meldungszeile das Verzeichnis dieses Pfades **im Aussage-Teil**
      nennt — der Teil der Zeile nach dem Pfad, nicht das Pfad-Token selbst. Die Erwartung kommt aus
      der eigenen `skip`-Liste des Tests (die Festlegung der ADR), nicht aus der Meldung und nicht aus
      einem Wert, den die Meldungszeile durch Konstruktion trägt. Die zwei Kommentare (der Doc-Kommentar
      des Tests und der an der Schleife) sagen im Indikativ, was die Schleife misst, und der Doc-Kommentar
      nennt den neuen Fall unter den Rot-Gegenbeispielen. **Was passieren müsste, damit die Zusage
      bricht:** ein Aussagesatz, der ein anderes Verzeichnis nennt — der Beleg dafür ist Liefer-Punkt 2.
      **Vorzustand rot-belegt:** die Sonde des Verifiers (Aussagesatz nennt `x/`) ist vor der Änderung
      am Stand `HEAD` in einer Scratchpad-Kopie **selbst** gefahren und `make test-go` dort **grün**, nach
      der Änderung **rot**; die gelesene Meldung des roten Laufs nennt das erwartete Verzeichnis und den
      Pfad, dessen Zeile es nicht trägt.
- [ ] **Liefer-Punkt 2 — ein Fall in `test/mutations/` färbt die Assertion, mit Gegenprobe.** Der Fall
      trägt die nächste freie Nummer
      (`ls test/mutations | grep -oE '^[0-9]+' | sort -n | tail -1` → **451** am Stand `HEAD`), den Modus
      `100755` und die Kopfzeilen `# files: internal/emit/zeilenenden.go` und
      `# expect: TestZeilenenden_BelegterPfadBleibtUndWirdGemeldet`. Seine Mutation lässt den Aussagesatz
      der Meldung ein anderes Verzeichnis nennen. Belegt sind vier Dinge, jedes mit gelesener Ausgabe:
      **(a)** der `sed`-Anker ist gegen den Quell-Bestand gemessen
      ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)):
      `grep -c` des Ankers im Quelltext → 1 vor der Mutation, 0 danach, der Datei-Hash ändert sich;
      **(b)** `make test-go` in der Scratchpad-Kopie mit angewandter Mutation färbt rot, die
      `--- FAIL:`-Liste nennt den erwarteten Test, und die Meldung nennt das falsche Verzeichnis — das Rot
      trägt die **behauptete** Ursache; **(c)** die Gegenprobe: dieselbe Mutation bei entwaffneter neuer
      Assertion (Bedingung entfernt) läuft **grün** — grün heißt hier „bindet"; **(d)** die bestehenden
      Fälle, die einen `TestZeilenenden_`-Test erwarten oder in `internal/emit/zeilenenden.go` ankern
      (`grep -l 'TestZeilenenden_' test/mutations/*.sh` und
      `grep -l 'internal/emit/zeilenenden' test/mutations/*.sh`), färben nach der Änderung des Tests
      weiter rot — je Fall in einer eigenen Scratchpad-Kopie emuliert (Anker trifft, erwarteter Test rot),
      kein `make mutate`.

**Konstante Pflichten** (zählen nicht als Liefer-Punkte):

- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update entfällt: kein öffentlicher Vertrag berührt (Test und Fall, kein Produktions-Code).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register entfällt: das Repo führt die Datei nicht
      (`ls docs/plan/planning/reconciliation.md` → nicht vorhanden).
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben, soweit etwas angefallen ist — neues Verzeichnis oder eine weitere Datei in einem `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

<!-- BEDIENHINWEIS: Datei- oder Komponenten-Ebene reicht; der
Implementer-Agent erweitert die Liste in seinem ersten Lauf, inklusive
einer Testdatei-Zeile mit der Akzeptanzkriterien-ID in `Begründung`
(Modul 9 §Minimal Agent Workflow). -->

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/zeilenenden_test.go` | update | Aussage-Schleife des Meldungs-Tests: die Verzeichnis-Zeichenkette wird im Aussage-Teil der Zeile gesucht, Erwartung aus `skip`; die Kommentare sagen im Indikativ, was gemessen wird — nach [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix), [`ADR-0067`](../../adr/0067-emittierte-zeilenenden-ein-attribut-je-verzeichnis-mit-interpreter-konsument.md) Festlegung 4 |
| `test/mutations/` | neu (ein Fall) | Zahn: der Aussagesatz nennt ein falsches Verzeichnis; der Anker ist gegen `internal/emit/zeilenenden.go` gemessen |

**Ansatz — Reihenfolge, in der der Rot-Beleg entsteht:**

1. **Vorzustand messen** (Scratchpad-Kopie von `HEAD`, ohne `.git`): die Mutation des neuen Falls von
   Hand anwenden und `make test-go` fahren — **grün** erwartet. Die Sonde des Verifiers ist eine
   Behauptung, bis sie dieser Lauf gesehen hat.
2. **Assertion ändern:** im Aussage-Teil suchen, nicht im Pfad-Token — etwa die Zeile am Pfad
   teilen und nur den Rest prüfen, oder den Ort als Teil des Aussagesatzes (`in <Verzeichnis>/`)
   verlangen; die Form wählt der Implementer, sie ist so wenig an die Wortfolge gekoppelt, wie die Sonde
   es zulässt.
3. **Dieselbe Mutation** erneut fahren — **rot**, Meldung lesen.
4. **Sonden je Zeichenkette** (kein Fall): in einer Kopie den Aussagesatz nacheinander um jede der
   drei übrigen Zeichenketten kürzen; je Sonde `make test-go`. Rot heißt: die Zeichenkette bindet.
5. **Fall anlegen** nach der Form der Nachbarn 446 bis 451 (`# files:`, `# expect:`, Kommentar in
   Zustandsform, `set -euo pipefail`, ein `sed`), Anker mit `grep -c` gegen den Quelltext messen.
6. **Gegenprobe (c)** und **Emulation (d)**.

**Messweg statt Vollauf:** die engste tragfähige Messung ist der Fall einzeln in einer Scratchpad-Kopie
mit Gegenprobe, dazu die Emulation der betroffenen Fälle wie im Verifikations-Report des Vorgängers
(Kopie ohne `.git`, `# files:`/`# expect:` gelesen, Skript angewandt, `make test-go`, `--- FAIL:` nennt den
erwarteten Test). Sie ersetzt den Treiber nicht: Isolation, Fingerabdruck und die Bedingungen des Treibers
sind nicht gemessen; der nächtliche Vollauf trägt sie.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): der Slice `slice-emittierte-dateien-behalten-lf-im-autocrlf-klon`
liegt in `done/` (`ls docs/plan/planning/done/slice-emittierte-dateien-behalten-lf-im-autocrlf-klon.md`
nennt eine Datei), der Test und der Wortlaut der Meldung, die dieser Slice hält, stehen also fest. Keine
weitere Abhängigkeit; das WIP-Limit ist frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): eine der Sonden je Zeichenkette (Ansatz, Schritt
  4) färbt **nicht** rot und die Reparatur der Zeichenkette bräuchte einen eigenen Fall — mehr als zwei
  Liefer-Punkte, dann gehört die zweite Assertion in einen eigenen Schnitt.
- `in-progress` → `open` (blockiert): die Verzeichnis-Angabe der Meldung lässt sich nur durch einen Umbau
  von `internal/emit/zeilenenden.go` verschieben — der Fall fände keinen Anker, der die Angabe allein
  bewegt, und der Slice bräuchte eine Entscheidung über Produktions-Code, die §1 ausschließt.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. Die beiden Liefer-Punkte der DoD sind belegt: der Rot-Beleg der Assertion mit dem Vorzustand grün,
   und der Fall mit den vier Belegen (a) bis (d), jeder mit gelesener Ausgabe im Verifikations-Report.
2. `make gates` grün auf dem Stand, den der Stempel deckt.

Lerneintrag: eine der drei Formen. Erwartet ist *neuer Sensor* (der Fall ist der Zahn); verkörpert wird
mit diesem Slice nichts, was ein `liegt in` bräuchte, es sei denn, der Lauf findet etwas darüber hinaus.
Ob der Slice dem Register einen Beleg hinzufügt, hängt an den Sonden (§6), nicht an der Reparatur der
gefundenen Stelle.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht. Die Ausgänge unten sind die **vorab benannten**; der Closure-Lauf bestätigt oder ersetzt sie
nach dem, was die Messung zeigte.

- **Eine Sonde je Zeichenkette zeigt eine weitere Assertion, die unter keiner Mutation rot wird.**
  Dann trägt der Slice ein zweites Auftreten derselben Klasse, in einem anderen Vorgang als dem
  ersten — **Ausgang:** eingetreten → ein Beleg unter dem `evidence/`
  des Eintrags `BEO-ALL/erwartung-stammt-aus-dem-geprueften-gegenstand`, der Dateiname ist die Kennung
  dieses Slice (Zähler dort von 1 auf 2); zeigt
  keine Sonde eine, entfällt das Risiko: die vier Zeichenketten binden, jede mit gesehenem Rot.
- **Der Wortlaut der Meldung wandert und entwaffnet den Fall** (der `sed`-Anker zitiert den Satz, den er
  verschiebt). **Ausgang:** entfallen — die Klasse ist als Regel verkörpert
  ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)),
  der Anker ist bei der Anlage gegen den Quell-Bestand gemessen (Liefer-Punkt 2 (a)), und der Treiber
  meldet einen verschobenen Anker fail-closed; das Restrisiko trägt der Review über den Fall.
- **Der neue Fall ist in keinem Vollauf von `make mutate` gefahren, wenn der Slice schließt.** Die Messung
  ist Emulation (Messweg, §3), nicht der Treiber; Isolation und Fingerabdruck des Treibers sind nicht
  gemessen. **Ausgang:** weiter offen → der nächtliche Lauf (`mutate.yml`) fährt den Fall mit dem Satz;
  ein Register-Eintrag entsteht nur, wenn der Closure-Lauf keinen bestehenden für „Zahn außerhalb eines
  Vollaufs" findet — er sucht zuerst im Register, bevor er neu anlegt.
- **Die neue Erwartung koppelt den Test an den Wortlaut der Meldung enger, als die ADR sie bindet.** Eine
  berechtigte Umformulierung des Aussagesatzes färbte den Test rot, ohne dass die Zusage bricht.
  **Ausgang:** entfallen — die Erwartung verlangt das Verzeichnis im Aussage-Teil, nicht eine Wortfolge
  (Ansatz, Schritt 2); färbt eine Umformulierung trotzdem, ist das ein Befund des Reviews über die Form der
  Assertion, kein offenes Risiko des Plans.

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

Der Abschnitt wird bei der Closure gefüllt, im Commit vor dem `git mv` (Ausnahme: die Paarungen, nach
dem `git mv`).

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —
- **Drei Paarungen:** —

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area, `*` (`ALL`): der Test liegt in
`internal/emit/`, der Fall in `test/mutations/`. `harness/tools/` (`TOOLS`) ist nicht berührt — der
Treiber `mutate.sh` bleibt, wie er steht; `.codex/` (`CODEX`) ist nicht berührt. Alle deklarierten
Sub-Areas sind GF.

**Vorgelagert — offene Beobachtungen sichten:** Das Register unter
[`../observations/`](../observations/) ist durchgegangen; die Zähler sind als Dateizahl unter `evidence/`
abgelesen (`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, **keine
Erwartungswerte** —
[`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2, gelesen am gemergten Stand `HEAD` vom 2026-09-25). Diese Einträge betreffen den Vorgang:

| Eintrag | Zähler | Stand | Bezug zu diesem Slice |
|---|---|---|---|
| `erwartung-stammt-aus-dem-geprueften-gegenstand` | 1× | offen | **unmittelbar** — die Assertion aus LOW-V1 ist die Instanz der Klasse; die Klasse hat ihren einen Beleg aus dem Vorgänger-Slice, und dieser Slice repariert die Instanz, er **findet** keine neue. Mit ihm erreicht der Eintrag **nicht** 3×; ein zweiter Beleg entsteht nur, wenn eine Sonde eine weitere Instanz zeigt (§6) — dann steht er bei 2×, unter der Schwelle |
| `weite-assertion-verdeckt-die-bindung-der-engen` | 1× | offen | die Nachbar-Klasse mit zwei Assertions verschiedener Weite: die neue Assertion ändert die Aussage-Schleife, und die Gegenprobe (c) entwaffnet **genau eine** Assertion, um zu zeigen, dass der Fall an ihr hängt und nicht an einer weiteren |
| `zusicherung-ueber-der-leeren-menge-wahr` | 2× | offen | die Schleife läuft über `skip`, eine feste Liste von drei Pfaden; die Menge ist nicht leer, und der Test führt die Liste selbst |
| `neuer-waechter-ohne-mutations-fall` | 13× | verkörpert | Liefer-Punkt 2 **ist** der Fall, den die Regel für die geschärfte Assertion verlangt |
| `mutations-fall-wird-von-berechtigter-aenderung-entwaffnet` | 5× | verkörpert | der Anker des neuen Falls zitiert Wortlaut der Emission; [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand) verlangt ihn gegen den Quell-Bestand gemessen (Liefer-Punkt 2 (a)) |

Nach Stichwort gesichtet
(`ls docs/plan/planning/observations/BEO-ALL | grep -E 'mutations-fall|zahn|assertion|zusicherung|erwartung|zeilenende'`):
die übrigen `mutations-fall-*`-Einträge betreffen die Anlage eines Falls (Anker an einer Zeilennummer,
falsche `# files:`-Datei, umbenannter Wächter, mehrere gefärbte Tests, lauter statt stiller Pfad). Der
Implementer liest sie bei der Anlage des Falls und nennt einen Treffer im Bericht; kein Eintrag erreicht
mit diesem Slice 3×.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF — der Block entfällt.
