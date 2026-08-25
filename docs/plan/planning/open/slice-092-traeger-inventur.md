# Slice slice-092: Die Träger-Inventur — je Regelblock ein Wert, Inventar gegen Abdeckung

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-11](../welle-11-traeger-aussage.md) — er schließt die Liste und ist damit der
Slice, an dem das Closure-Kriterium der Welle wahr wird. Er läuft **nach**
[slice-090](slice-090-freshness-audit-im-ziel.md) und
[slice-091](slice-091-vendored-baum-ohne-anspruch.md), deren Werte er entgegennimmt statt sie zu
erarbeiten.

**Bezug:**
[`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) (das Regelwerk geht
vollständig ins Ziel — diese Inventur ist die Aussage darüber, was davon dort trägt),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (nichts
behaupten, was nicht läuft — hier auf die **Abwesenheit** angewandt: eine Regel ohne Träger, die
sich nicht als solche zu erkennen gibt, ist dieselbe Lüge mit umgekehrtem Vorzeichen),
[`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (die
Aufzählung der emittierten Durchsetzungs-Mechanik — dieser Slice lässt sie nicht wachsen; die
Schranke, an der sein Schnitt gemessen wird),
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (*out-of-the-box grün* —
die Zusage, die ein Text nicht bricht, ein Sensor aber bräche),
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (die
Erfassungsschicht geht ins Ziel — die Anforderung, aus der vier Zellen dieser Inventur ihren
Auflösungs-Trigger beziehen),
[`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) (**Accepted** — sie trägt den Wert des
Doku-Konsistenz-Blocks, den diese Inventur entgegennimmt: Festlegungen 4 und 5),
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (**Accepted** —
sie setzt für Erfassung, Token-Attribution, Cache-Counter und Rollen-Typen den Wert *geht mit*:
Träger, Schreiber und Auswertung als Unterkommandos eines Binärs, die Rollen-Typen generisch.
Solange ihre Emission nicht liegt, ist sie der **Auflösungs-Trigger** dieser vier Zellen, nicht ihr
Zellwert — §1),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(Setzung 2 — der Nenner misst seinen Gegenstand, nicht sein Umfeld).

**Autor:** Planner. **Datum:** 2026-08-23.

---

## 1. Ziel

**Das gebootstrappte Repo führt je Abschnitt seines mitgelieferten Regelwerks einen Wert dazu, ob
ein Träger mitkommt — vollständig über das Verzeichnis, nicht über die auffälligen Fälle.**

**Der Wert-Vorrat ist geschlossen, drei Werte:**

| Wert | Bedeutung | Beispiel nach heutigem Stand |
|---|---|---|
| **Träger kommt mit** | die Mechanik oder Ziel-Form liegt im Ziel und ist dort benutzbar | Modul 10 §Ziel-Form: Reviewer-Skill — `.harness/skills/reviewer.md` wird emittiert |
| **liegt bei, nicht verdrahtet** | der Träger ist da, hängt aber an keinem Trigger | Modul 15 §Doku-Konsistenz-Drift — `doc-targets` existiert im Ziel, `modules:` führt ihn nicht |
| **kommt nicht mit** | mit Grund und Dauer: bei permanenter Entscheidung mit Zeiger auf sie, sonst mit dem **Auflösungs-Trigger**, an dem die Zelle kippt | Modul 15 §Erfassung — beschlossen ist *geht mit* ([`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 1), abgelegt ist sie nicht; Auflösungs-Trigger ist ihre Emission |

**Die Zelle sagt den Zustand des Repos, nicht den Stand der Entscheidung — und der dritte Wert
trägt die Unterscheidung selbst.** Ein Adopter liest die Inventur, um zu wissen, was in *seinem*
Verzeichnis liegt. Für einen Träger, der beschlossen und nicht gebaut ist, ist *geht mit* die
Falschaussage, die dieser Slice verhindern soll — dieselbe
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Klasse
eine Ebene weiter. Der Wert-Vorrat bleibt darum bei drei: die Beschlusslage steht in der
Grund-und-Dauer-Pflicht des dritten Werts, als Auflösungs-Trigger. **Vier Zellen tragen ihn heute**
— Modul 15 §Erfassung, §Token-Attribution, §Cache-Counter und Modul 8
§Rollen-Trennung —, und sie kippen alle vier an derselben Bedingung: die Erfassungsschicht wird
emittiert. Dass sie kippen, ist terminiert und nicht bloß möglich; wer sie hält, ist DoD (3), nicht
eine Zusage im Text.

**Vollständigkeit heißt Inventar gegen Abdeckung.** Der **Nenner** wird zur Laufzeit gelesen
(`ls .harness/baseline/*/regelwerk/*.md | wc -l` im gebootstrappten Ziel), nicht notiert. Eine
notierte Zahl bräche beim nächsten Baseline-Sprung, ohne dass am Gegenstand etwas bricht —
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2 schließt genau diese Form von Erwartungswert aus. Dieselbe Lücke — *kuratierte Liste
statt Inventar* — führt die Roadmap seit dem 2026-07-25 als eigenen Kandidaten, und
[welle-10](../welle-10-re-baseline.md) hängt ihren Adaptions-Durchgang an dieselbe Mechanik.

**Was verwiesen und nicht abgeschrieben wird.** Wo eine angenommene Entscheidung den Wert schon
setzt — [`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) für den
Doku-Konsistenz-Block, [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
für die drei übrigen Modul-15-Blöcke und die Rollen-Typen —, zeigt die Inventur auf sie. Eine
zweite Fassung derselben Festlegung wäre die zweite Wahrheit, die driftet; und sie stünde in einem
emittierten Dokument, das kein Lauf dieses Repos je gegen die ADR hält.

**Was der Slice ausdrücklich nicht ist.** Kein Sensor, der Träger und Regel automatisch aufeinander
abbildet. Der Nenner ist mechanisch, die **Zuordnung** ist ein Urteil — sie mechanisch auszugeben
hieße, ein Muster als Kriterium zu verkaufen, das keines ist
([`AGENTS.md`](../../../../AGENTS.md) §3.6). DoD (3) ist nicht diese Abbildung: er prüft **eine
Richtung über einer Teilmenge** — dass keine Zelle eine Abwesenheit behauptet, die der Emit
desselben Laufs widerlegt. Ob ein behaupteter Träger der **richtige** ist, prüft er nicht; die
Grenze steht in §6.

**Und der emittierte Datei-Satz ist nicht die Aufzählung aus
[`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren).** Diese
Inventur schreibt in Dokumente, die das Ziel ohnehin bekommt, und legt keinen neuen Pfad an — die
Schranke des Wellen-Ziels, hier unverändert. Dass der Datei-Satz durch die Erfassungsschicht
wächst, ist die Sache eines anderen Slice; die **Aufzählung** aus jener Anforderung wächst auch
dort nicht ([`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
§Konsequenzen). Die zwei sind verschiedene Mengen, und nur die erste bindet diesen Schnitt.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **(1) Jeder Abschnitt des mitgelieferten Regelwerks trägt genau einen der drei Werte** —
      Nenner gegen Einträge, keine leere Zelle. Der Punkt hängt an **zwei** Sensoren, weil er zwei
      Ebenen hat: die Einträge entstehen hier, der Nenner steht im Ziel.
      **Rot (Dogfood, hermetisch):** `make test` — ein Go-Test hält die Einträge gegen die
      `*.md`-Dateien des committeten `regelwerk/`-Verzeichnisses; er fällt, sobald eine Datei ohne
      Eintrag bleibt. Dazu ein `test/mutations/`-Fall mit `# verify: test-go`, der einen Eintrag
      entfernt und das Rot erwartet.
      **Rot (Ziel, real):** `make full-smoke` — dieselbe Differenz gegen den zur Laufzeit
      gelesenen Nenner des gebootstrappten Ziels. Nur dieser Lauf fängt den Fall, in dem das Ziel
      einen anderen Baum bekommt als dieses Repo führt.
- [ ] **(2) Die Aussage steht out-of-the-box in beiden Bootstrap-Varianten, und ihre Rücknahme
      wird rot gesehen** — beide Richtungen, wie in welle-08 etabliert. Nur die erste wäre die
      [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Falle
      eine Ebene weiter.
      **Rot:** `make full-smoke` über `tmprepo` **und** `tmprepo_doc`
      ([`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh)); rot gesehen,
      indem die Aussage emit-seitig zurückgenommen wird.
      **Ein Mutations-Fall existiert für diesen Punkt nicht, und das steht hier statt einer
      Zusage:** der Treiber kennt `full-smoke` nicht — `failure_form` in
      [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) führt den Modus
      (`grep -c 'full-smoke' harness/tools/mutate.sh` → **7**, mitwandernd), der Fall ist also
      anlegbar und läuft im Standard-`make mutate` mit; solange keiner angelegt ist, ist dieser Punkt in `make mutate`
      **ungelistet**, und ungelistet heißt nach [`AGENTS.md`](../../../../AGENTS.md) §3.6
      unbewacht.
- [ ] **(3) Keine Zelle behauptet die Abwesenheit eines Trägers, den derselbe Lauf ablegt.**
      **Rot:** `make test` — ein Go-Test über der Vereinigung der Emit-Pfad-Listen
      (`grep -n 'func TemplateTargets\|func EnforcePaths\|func CommandPaths' internal/emit/*.go`
      → **3** Zeilen) fällt, sobald eines der unten genannten Präfixe über seinen gepinnten
      Bestand hinauswächst, während seine Zelle noch Abwesenheit behauptet; dazu ein
      `test/mutations/`-Fall mit `# verify: test-go`, der einen Pfad einträgt und das Rot erwartet.
      **Die Adresse ist das Präfix samt Bestand, nie ein geratener Dateiname:** eine
      Abwesenheits-Stichprobe auf einen Namen, den der Emit nie schreibt, kann unter keiner
      Mutation rot werden. Die Klasse ist hier gemessen, und die Antwort darauf steht als
      geschlossener Ist-Bestands-Vergleich in
      [`internal/emit/templates_test.go`](../../../../internal/emit/templates_test.go) —
      sein Prüfbereich ist die Kurs-Vorlagen-Schicht, nicht der ganze Emit.
      Der Sensor misst damit **Adressen**, der Gegenstand sind **Aussagen**; die Aussagen-Menge,
      aufgezählt und mit ihrer Richtung — jede steht heute auf *kommt nicht mit* samt
      Auflösungs-Trigger und geht auf *Träger kommt mit*, sobald ihre Adresse erscheint:
      **(a)** Modul 15 §Erfassung → Präfix `.claude/hooks/`, heute mit **zwei** Einträgen
      (`grep -c '".claude/hooks/' internal/emit/enforce.go` → **2**). Der Träger selbst liegt
      gitignored und steht in keiner Pfad-Liste; die Adresse ist sein committeter Zwilling, der
      Hook-Wrapper, an den
      [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
      Festlegung 5(a) ihn koppelt — kein Träger, kein Wrapper, kein Hook-Eintrag.
      **(b)** Modul 15 §Token-Attribution und §Cache-Counter → Präfix des
      Gate-Fragment-Verzeichnisses **des Ziels**, in dem das Aufräum- und Berichts-Fragment landet;
      in diesem Repo existiert es nicht, seine Konstanten liegen in
      [`internal/emit`](../../../../internal/emit)
      (`grep -rhoE '"harness/mk/[^" ]+' --include=*.go internal/ | sort -u | wc -l` → **5**).
      **(c)** Modul 8 §Rollen-Trennung → Präfix `.claude/agents/`, heute leer
      (`grep -rl '".claude/agents/' --include=*.go internal/ | wc -l` → **0**).

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · Doku-Update, falls ein
öffentlicher Vertrag berührt ist · Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`internal/emit`](../../../../internal/emit) — der Schritt, der die Inventur in ein bereits emittiertes Dokument trägt | update | die Aussage landet in einem Dokument, das das Ziel ohnehin bekommt; kein neuer Ziel-Pfad. Präzedenz für emit-seitige Nachbearbeitung: `NeutralizeRoadmap` in [`internal/emit/templates.go`](../../../../internal/emit/templates.go) |
| [`internal/emit`](../../../../internal/emit) — zwei Go-Wächter: Einträge ↔ `regelwerk/`-Bestand und Abwesenheits-Aussage ↔ Emit-Pfad-Satz | neu | DoD (1) hermetisch und DoD (3); beide in der Stufe, die `make mutate` erreicht |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | update | dieselbe Differenz gegen den zur Laufzeit gelesenen Nenner, über beide Varianten (DoD 1/2) |
| `test/mutations/` — je ein Fall für die zwei Go-Wächter <!-- d-check:ignore (geplante Datei) --> | neu | [`AGENTS.md`](../../../../AGENTS.md) §3.6: wer keinen Fall hat, gilt als unbewacht. `# verify: test-go` — der Modus, den der Treiber führt |

## 4. Trigger

**`open` → `next`:** [slice-090](slice-090-freshness-audit-im-ziel.md) **und**
[slice-091](slice-091-vendored-baum-ohne-anspruch.md) liegen in `done/` — beide setzen einen Wert,
den diese Inventur sonst als offen führte. **`next` → `in-progress`:** WIP-Limit frei.

**Der Slice wartet nicht auf die Emission der Erfassungsschicht, und das ist eine Entscheidung.**
Die vier Zellen aus §1 tragen dann den Auflösungs-Trigger statt den Endwert; jede andere Reihenfolge
hängte das Closure-Kriterium der Welle an einen Slice, den niemand geschnitten hat — ein Trigger,
den kein Zweiter ohne Rückfrage beurteilen kann (Modul 6 §Trigger). Was der Weg kostet, steht in §6.

**Rückführungen, vorab benannt.** `in-progress` → `next`, wenn die Inventur in einem Dokument nicht
lesbar bleibt (mehr als eine Bildschirmseite) — dann ist der Gegenstand zu grob geschnitten und
zerfällt nach Phase, nicht nach Schicht. `in-progress` → `open`, wenn die Inventur auf einen
Abschnitt trifft, für den keine vorhandene Entscheidung einen Wert hergibt — dann schuldet die
Welle eine Entscheidung, und dieser Slice wartet auf sie. Die Bedingung ist eine Eigenschaft, keine
Adresse: welcher Abschnitt es trifft, sagt erst der Nenner-Lauf.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt mit gefahrenen Kommandos, `make gates` grün, `make full-smoke` grün,
`make mutate` grün mit den neuen Fällen, Closure-Notiz in §7 mit Steering-Loop-Eintrag geschrieben.

## 6. Risiken und offene Punkte

- **Der Preis der gewählten Reihenfolge: vier Zellen sind terminiert.** Wer zwischen diesem Slice
  und der Emission der Erfassungsschicht bootstrappt, liest für Erfassung, Token-Attribution,
  Cache-Counter und Rollen-Trennung *kommt nicht mit* mit Auflösungs-Trigger. Für sein Repo ist das
  wahr; als Dauerzustand wäre es falsch, und der Umschlagpunkt liegt außerhalb dieses Slice. Er
  wird deshalb nicht versprochen, sondern gehalten: der Wächter aus DoD (3) färbt rot, sobald eine
  der drei Adressen im Emit-Pfad-Satz erscheint — der Slice, der die Erfassungsschicht ablegt,
  kommt an den vier Zellen nicht vorbei. **Was der Weg zusätzlich kostet:** dieser Wächter wird
  auch von jeder anderen Emissions-Erweiterung an denselben Präfixen rot; das ist Reibung, und sie
  ist gewollt — sie zwingt einen Blick auf die Inventur, den sonst niemand tut.
- **Bewacht ist die Abdeckung, nicht die Richtigkeit — mit einer Ausnahme in einer Richtung.** Der
  Wächter aus DoD (1) zählt, ob jeder Abschnitt einen Wert trägt; ob der Wert **stimmt**, prüft er
  nicht. DoD (3) schließt davon genau eine Richtung: eine behauptete Abwesenheit, die der Emit
  desselben Laufs widerlegt. Die Gegenrichtung — ein behaupteter Träger, den es nicht gibt, oder
  ein falsch zugeordneter — bleibt offen; ein Sensor darüber wäre der Doku-Konsistenz-Agent aus
  Modul 15, der hier ausdrücklich nicht Gegenstand ist.
- **DoD (2) hängt allein an `make full-smoke` — der Treiber erreicht ihn.** `failure_form` in
  [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) führt den Modus
  (`grep -c 'full-smoke' harness/tools/mutate.sh` → **7**, mitwandernd), der Fall ist damit
  anlegbar und läuft im Standard-Lauf mit. Was bleibt, ist sein **Preis**: der Grün-Vorlauf fährt
  `make full-smoke` einmal mit, und der ist die Untergrenze — der Fall-Lauf selbst liegt darunter,
  weil er am getroffenen Wächter abbricht.
- **Die Inventur altert mit dem Baum.** Sie steht deshalb hinter
  [welle-10](../welle-10-re-baseline.md) (§2 der Welle) und nennt ihren Nenner als Kommando, nicht
  als Ziffer. Kommt upstream ein Abschnitt hinzu, meldet der Wächter die Differenz — das ist der
  gewollte Ausgang, kein Fehlalarm.
- **Ein Wert ist fremdbestimmt:** *Doku-Konsistenz-Drift* hängt am Ausgang von slice-063 in
  [welle-09](../welle-09-modul-15-konformitaet.md). Er wird **entgegengenommen**, nicht hier
  entschieden; die Trigger-Reihenfolge stellt sicher, dass er vorliegt.

## 7. Closure-Notiz (nach `done/`)

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `internal/emit/`,
`harness/tools/` und `test/` gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
