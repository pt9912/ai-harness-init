# Slice slice-197: Die eingefrorene Baseline-Adresse bekommt ihr Ventil, und die Ausnahme sagt, wie breit sie ist

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Es gibt keine Closure-Bedingung, die von der DoD dieses Slice verschieden
wäre: Sein Beleg ist `make gates` grün, und das steht in seiner eigenen DoD. Ein Trigger, der
nichts beobachtet, was der Slice ohnehin belegt, ist Zeremonie (Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Gate, das über einem stumm geschalteten Bereich grün meldet, behauptet mehr als es prüft — die
Deklaration ist die Antwort darauf),
[`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) (die Entscheidung, deren
Implementer-Folgepflicht dieser Slice ist — Festlegung 1 die drei Einträge, Festlegung 2 der
Maßstab, Festlegung 3 die Grenze),
[`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) (Folgepflicht 2
stellt den Wächter, dessen Konstante dieser Slice ersetzt),
[`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (das Paar mit
Deklaration `0` und die Code-Span-Lücke, die auch danach niemand misst),
[`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md),
[`ADR-0032`](../../adr/0032-eingefrorene-referenz-folgt-ihrem-rumpf.md),
[`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
(die drei übrigen bestehenden Paare — sie bekommen ihre Deklaration und ändern damit ihr
Verhalten),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl neben ihrem Kommando — die Deklaration ist selbst eine solche Zahl)

**Berührte Spec-Stellen:** `—`. Der Slice berührt keine Stelle des Technik- oder Sicht-Stratums:
Er ändert die Konfiguration eines Gates und den Maßstab eines Wächters, und beide sind in
[`spec/spezifikation.md`](../../../../spec/spezifikation.md) nicht festgelegt.
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) steht im
Bezug als **Vertrag**, nicht als berührte Stelle — der Slice erfüllt ihn, er ändert ihn nicht.

**Verantwortlich:** — (bis zur Priorisierung; die Arbeit ist Implementer-Arbeit,
[`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) §Kopplung).

**Autor:** Planner. **Datum:** 2026-09-07.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** `make docs-check` ist grün, ohne dass eine Prüffläche außerhalb der drei einfrierenden
Bäume verloren geht — und jede der sieben `ignore-refs`-Ausnahmen sagt am Ort ihrer Definition, wie
viele Markdown-Links sie deckt, gehalten von einem Wächter, der in **beide** Richtungen rot wird.

Der Ausgangsstand ist gemessen, nicht angenommen (Stand 2026-09-07; **keine Erwartungswerte**,
beide Zahlen wandern mit dem Bestand):

```sh
make docs-check     # d-check: 920 Datei(en) geprüft, 36 Befund(e) — alle target-missing, EXIT 2
PS=( 'docs/reviews/**' 'docs/plan/planning/done/**' 'docs/plan/planning/observations/**' )
git grep -oE '\]\([^)]*\.harness/baseline/v6\.0\.0/' -- "${PS[@]}" | wc -l   # 36 Adressen
git grep -lE '\]\([^)]*\.harness/baseline/v6\.0\.0/' -- "${PS[@]}" | wc -l   # 16 Dateien
```

Alle 36 liegen in Artefakten, die niemand mehr anfassen darf, und keine ist reparierbar
([`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) §Der Bestand). Der Slice
setzt die Entscheidung um; er trifft sie nicht.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die §3.11-Schärfung um die vendored-Baseline-Adresse.** Sie ist die *präventive* Hälfte
  derselben Entscheidung und **Architect-Arbeit**
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8); ein Implementations-Lauf, der sie mitnähme, schriebe
  ein fremdes Rollen-Artefakt. Sie ist als
  [slice-198](slice-198-hard-rule-311-nennt-den-vendored-baum.md) geschnitten, und diese Kennung
  nimmt den Punkt an.
- **Die Verengung des `in:`-Globs `docs/plan/planning/observations/**` auf die einfrierende
  Teilmenge.** Der Glob deckt neben den unveränderlichen `observation.md` und `evidence/*.md` auch
  `state.md` und die `README.md` der Ablage, und die frieren **nicht** ein — der Slice legt damit
  eine Ausnahme, die breiter ist als ihre Begründung. Sie zu verengen heißt, von der Tabelle in
  [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) Festlegung 1 abzuweichen,
  deren `in:`-Werte Festlegung 3 extensional schließt; ob eine Verengung dafür eine eigene
  Entscheidung braucht, ist eine Architect-Frage und **kein** Nachzug. Sie steht als Risiko in §6
  und bekommt dort ihren Ausgang.
- **Die tote Baseline-Adresse in *lebenden* Artefakten.** Sie bleibt ein Befund und wird nachgezogen
  ([`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) §Was diese Festlegungen
  nicht tun). Dass ein solcher Pfad in **Inline-Code** heute von keinem Modul gesehen wird, ist ein
  eigener Vorgang mit eigener Bezugsmenge:
  [slice-201](slice-201-codepaths-erreicht-den-vendored-baum-nicht.md).
- **Die Code-Span-Achse des Wächters.** Er zählt die Inline-Markdown-Form und sieht eine
  Code-Span-Referenz nicht; das ist
  [`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Folgepflicht 2 und
  bleibt eine benannte Lücke — auch nach diesem Slice. Sie hier mitzunehmen hieße, den Maßstab und
  seine Achse in einem Zug zu ändern, und keine der zwei Änderungen wäre danach einzeln belegt.
- **Der Closure-Abschluss von [slice-193](../in-progress/slice-193-baum-tausch-v650-pins-ziehen.md).**
  Dieser Slice macht ihn *möglich* (dessen DoD-Punkt `make gates` grün hängt an denselben 36
  Befunden), er vollzieht ihn nicht: Der Abschluss ist Planner-Arbeit in eigenem Kontext
  ([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [ ] **Drei `ignore-refs`-Einträge in Glob-Form liegen in
      [`.d-check.yml`](../../../../.d-check.yml), einer je einfrierendem Baum, alle mit demselben
      `refs`-Wert `.harness/baseline/**`.** Die drei `in:`-Werte sind
      `docs/reviews/**`, `docs/plan/planning/done/**` und
      `docs/plan/planning/observations/**` — die Tabelle aus
      [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) Festlegung 1,
      unverändert übernommen. **Der `refs`-Wert ist baum-weit und nicht tag-weit**; ein
      tag-weiter Wert verlangte bei jedem Bump drei neue Einträge und damit eine neue Entscheidung
      je Sprung. Beleg: `make docs-check` meldet `0 Befund(e)`, und der Kommentar jedes der drei
      Einträge nennt seine Entscheidung.
- [ ] **Alle sieben Einträge deklarieren am Ort ihrer Definition, wie viele Markdown-Links sie
      decken — die vier bestehenden ebenso wie die drei neuen.** Die Deklaration ist der **am
      Lauf-Tag gemessene** Wert, geschrieben neben dem Kommando, das ihn liefert
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).
      **Dieser Plan schreibt keinen Zielwert fest**, und das ist kein Versäumnis: Die Zahl für
      `docs/reviews/**` wächst mit jedem Review-Lauf, der in den Baum verlinkt — auch mit dem
      Review dieses Slice (§6, zweites Risiko). Am Stand des Plans lauten die sieben Werte
      `1 · 1 · 0 · 1` für die bestehenden und `33 · 3 · 2` für die neuen; **keine
      Erwartungswerte**, Stichtag 2026-09-07, gemessen mit den zwei Kommandos aus
      [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) Festlegung 2. Der
      Lauf misst neu und trägt ein, was er misst.
- [ ] **[`test/ignore-refs-restbreite.bats`](../../../../test/ignore-refs-restbreite.bats) misst
      gegen die deklarierte Zahl statt gegen die Konstante 1 und liest die Glob-Form auf beiden
      Achsen.** Vier Bedingungen, alle urteilsfrei: ein Eintrag **ohne** Deklaration ist rot · er
      deckt **mehr** als deklariert → rot · er deckt **weniger** → rot · die Deklaration `0` ist
      eine Deklaration und **keine fehlende**. Der bisherige Zahn `Quelldatei fehlt` trägt für einen
      Glob nicht — ein Glob ist keine existierende Datei — und wird durch die Glob-Auflösung
      ersetzt; der Zahn *„der Block wird vollständig und in bekannter Form gelesen"* bleibt.
      **Vier rot gesehene Gegenbeispiele** ([`AGENTS.md`](../../../../AGENTS.md) §3.6), je einzeln
      gefahren und im Lauf-Bericht mit der **gelesenen** Fehlermeldung belegt — die Begründung im
      Rot ist Teil des Wächters und wird nur dort ausgegeben:

      1. Deklaration an einem Eintrag entfernt → rot.
      2. Deklaration um eins **erhöht** → rot.
      3. Deklaration um eins **gesenkt** → rot.
      4. Am Null-Paar
         ([`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md)) die
         Deklaration von `0` auf `1` gesetzt → rot.

      **Der vierte ist der, den
      [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) Festlegung 2 eigens
      verlangt, und er ist kein Sonderfall von 2.** Er misst, ob der Eintrag mit Deklaration `0`
      überhaupt **gemessen** wird — ein Wächter, der `0` als *keine Deklaration* liest und den
      Eintrag darum überspringt, bliebe bei jeder Zahl grün. Fällt er rot, ist belegt, dass `0`
      gezählt statt übersprungen wird. **Die Gegenprobe ist die Kalibrierung und kein fünftes
      Gegenbeispiel:** mit `0` deklariert und null gedeckten Links ist derselbe Eintrag grün. Eine
      Unterschranken-Ausnahme für ihn braucht der Wächter **nicht** —
      [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) Festlegung 2 misst
      das über alle Wertepaare bis 6 als `0 Unterschiede`.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update für <Schnittstelle X> falls öffentlicher Vertrag berührt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register fortgeschrieben, **falls dieser Slice einen Inventur-Fund auflöst** —
      Zeile mit Datum und auflösendem Artefakt nach *Aufgelöste Einträge* verschoben. **Entfällt
      hier:** Repos ohne Brownfield-Bootstrap haben die Datei nicht, und dieses führt sie nicht
      (`ls docs/plan/planning/reconciliation.md` → nicht vorhanden). Der Pfad steht als
      **Kommando-Operand**, weil die vendored Vorlage ihn als blanken Inline-Code führt und
      `codepaths` ihn dann als fehlendes Ziel meldet — dieselbe Stelle, die
      [slice-193](../in-progress/slice-193-baum-tausch-v650-pins-ziehen.md) §6 als offenen Punkt
      führt.
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
| [`.d-check.yml`](../../../../.d-check.yml), Top-Level-`ignore-refs` | update | drei Einträge in Glob-Form (Liefer-Punkt 1) und die Deklaration an allen sieben (Liefer-Punkt 2) |
| [`test/ignore-refs-restbreite.bats`](../../../../test/ignore-refs-restbreite.bats) | update | neuer Maßstab: deklarierte Zahl statt Konstante, Glob-Auflösung auf beiden Achsen (Liefer-Punkt 3) |

**Zwei Schichten, nicht mehr:** Gate-Konfiguration und Wächter. Der Prüfbereich der Gate-Läufe
wächst dadurch nicht — er schrumpft um die gedeckten Referenzen, und genau das misst die
Deklaration.

**Wo die Deklaration steht, ist eine Form-Entscheidung des Laufs und keine Zahl:** Sie muss vom
Wächter maschinell lesbar sein und am **Ort der Definition** liegen. Der Block trägt heute
freistehende `#`-Kommentare je Eintrag, eingerückt, weil der Block-Schnitt des Wächters bei der
ersten Zeile in Spalte 0 endet — dieselbe Einrückungs-Bedingung gilt für die neue Zeile.

**Commit-Zuschnitt.** Ein Commit für Konfiguration und Wächter zusammen: Getrennt wäre der erste
rot (drei undeklarierte Einträge) oder der zweite (ein Maßstab ohne Deklarationen) — die zwei
Hälften sind wechselseitig die Bedingung der anderen, und ein rot durchgereichter Zwischenstand
entwertet den Gate-Nachweis, an dem der Stop-Hook hängt.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`) — **zwei Bedingungen, beide beobachtbar:**

1. **[`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) steht auf
   `Accepted`.** Beobachtbar an
   `grep -m1 '^\*\*Status:\*\*' docs/plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md`.
   Sie ist das Constraint dieses Slice, nicht seine Arbeit; solange sie `Proposed` trüge, wäre die
   Ausnahme eine Senkung ohne Entscheidung ([`AGENTS.md`](../../../../AGENTS.md) §3.5). **Die
   Bedingung ist am Tag dieses Plans erfüllt** — sie steht hier trotzdem, weil ein Start-Trigger
   die Bedingung nennt und nicht ihren heutigen Wert.
2. **Das WIP-Limit ist frei.** Es zählt **pro Rolleninhaber**, nicht pro Rolle (Baseline-Regelwerk
   `modul-08-agentenrollen.md` §Rollen-Regeln), und
   [slice-193](../in-progress/slice-193-baum-tausch-v650-pins-ziehen.md) belegt es heute: seine
   Arbeit liegt vor, sein Abschluss steht aus. **Der Ausweg ist nicht, ihn zu übergehen, und auch
   nicht, auf sein `done/` zu warten** — das wäre zirkulär, denn sein DoD-Punkt `make gates` grün
   hängt an eben den 36 Befunden, die dieser Slice räumt (§6, erstes Risiko).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn der neue Maßstab mehr verlangt als
  eine Zählung — etwa weil die Glob-Auflösung im Wächter eine eigene Pfad-Semantik braucht, die
  gegen die des Werkzeugs gehalten werden muss. Dann trennt der Schnitt die drei Einträge
  (Liefer-Punkt 1) vom Maßstab (Liefer-Punkte 2 und 3), und der erste Teil-Slice trägt seine
  Einträge bis dahin **undeklariert** — was der heutige Wächter grün lässt und der neue rot machen
  wird; genau diese Reihenfolge gehört dann entschieden statt unterlaufen.
- `in-progress` → `open` (blockiert — Carveout?): wenn das gepinnte d-check die Glob-Form auf einer
  der zwei Achsen **nicht** honoriert, obwohl die Sonden-Tabelle in
  [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) §Das Instrument sie an
  einem synthetischen Repo misst. Dann ist die tragende Voraussetzung der Entscheidung falsch, und
  der Weg ist die Rückmeldung an den Architect — nicht ein zweiter Versuch mit einer anderen
  Ausnahme-Form.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. `make docs-check` meldet `0 Befund(e)`, und `make gates` ist grün — mit gültigem Stempel über
   dem Baum, der die Closure trägt. Das ist die Nachmessung genau des Kommandos, das den
   Ausgangsstand in §1 liefert.
2. Die vier Gegenbeispiele aus Liefer-Punkt 3 sind **einzeln rot gesehen**, und der Lauf-Bericht
   nennt je Fall die gelesene Fehlermeldung. Ein Gegenbeispiel, das nur behauptet wird, belegt
   nichts ([`AGENTS.md`](../../../../AGENTS.md) §3.6).

**Lerneintrag** in einer der drei Formen (geschärfte Regel · neuer Sensor · benannte Spec-Lücke).
Ein Kandidat steht fest und ist keine Erfindung der Closure: Der Wächter wechselt von *„höchstens
1"* auf *„genau N"* und wird damit von einer Obergrenze zu einer **Kardinalitäts-Messung** — er
meldet ab dann auch den *Wegfall* einer gedeckten Referenz. Ob das eine geschärfte Regel, einen
neuen Sensor oder eine benannte Lücke ergibt, entscheidet die Closure.

**Den Abschluss schreibt der Planner, nicht der Lauf, der die Einträge gelegt hat**
([`AGENTS.md`](../../../../AGENTS.md) §3.10) — in eigenem Kontext und in einem Commit, der
ausschließlich Closure-Artefakte berührt.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Das WIP-Limit ist belegt, und der naheliegende Start-Trigger wäre zirkulär.**
  [slice-193](../in-progress/slice-193-baum-tausch-v650-pins-ziehen.md) liegt in `in-progress/`;
  sein DoD-Punkt `make gates` grün und sein Closure-Kriterium 1 hängen an denselben 36 Befunden,
  die dieser Slice räumt. *„slice-193 liegt in `done/`"* als Start-Bedingung wäre damit eine
  Bedingung, die dieser Slice selbst herstellen muss — beobachtbar, aber unerfüllbar. Die
  Reihenfolge ist die umgekehrte: **dieser Slice zuerst, der Abschluss von slice-193 danach.** Was
  offen bleibt, ist die Frage, ob zwei gleichzeitig beanspruchte Slices desselben Rolleninhabers
  hier zulässig sind oder ob slice-193 vorher zurückgeführt gehört — sie ist eine
  Lifecycle-Entscheidung und keine Arbeit dieses Slice. — **Ausgang:** offen; die Closure setzt ihn.
- **Die Deklaration für `docs/reviews/**` veraltet durch den Review dieses Slice selbst.** Der
  Korpus wächst mit jeder Runde, und ein Report, der in den vendored Baum verlinkt, hebt die Zahl
  — der Wächter wird dann **rot, ohne dass jemand etwas falsch gemacht hat**. Das ist keine
  Vermutung: Stichtag 2026-09-07 tragen 17 von 302 Reports einen Baseline-Link, und in den Runden
  seit dem 2026-09-01 sind es 15 von 57 —

  ```sh
  ls docs/reviews/*.md | wc -l                                                          # 302
  git grep -lE '\]\([^)]*\.harness/baseline/' -- 'docs/reviews/*.md' | wc -l            #  17
  ls docs/reviews/2026-09-*.md | wc -l                                                  #  57
  git grep -lE '\]\([^)]*\.harness/baseline/' -- 'docs/reviews/2026-09-*.md' | wc -l    #  15
  ```

  **Keine Erwartungswerte**, und die Zahlen sind mit Stichtag genannt statt roh: Sie wachsen mit
  dem Verfahren, das diesen Slice prüft, und wären in dem Moment falsch, in dem diese Datei nach
  `done/` einfriert. Der Ausweg ist **nicht**, die Deklaration weit zu setzen — das wäre das vorab
  bewilligte Budget, das
  [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) Festlegung 2
  ausdrücklich verhindert —, sondern sie im letzten Lauf vor dem Merge neu zu messen. Genau das ist
  der Preis, den jene Entscheidung in §Konsequenzen benennt. — **Ausgang:** offen; die Closure
  setzt ihn.
- **Der `in:`-Glob `docs/plan/planning/observations/**` ist breiter als seine Begründung.** Er deckt
  neben `observation.md` und `evidence/*.md` — beide unveränderlich ab Anlage bzw. ab Merge — auch
  `state.md` (der veränderliche Stand) und die `README.md` der Ablage. Für die zwei trägt das
  Argument *„niemand darf sie mehr anfassen"* nicht, und eine tote Baseline-Adresse in ihnen
  verstummt trotzdem. Die Verengung ist **nicht** Arbeit dieses Slice (§1): Sie weicht von der
  `in:`-Tabelle in
  [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) Festlegung 1 ab, die
  Festlegung 3 extensional schließt. Ob eine **Verengung** dafür eine eigene Entscheidung braucht,
  sagt Festlegung 3 nicht — sie nennt Verbreiterungen — und ist damit eine offene Architect-Frage.
  — **Ausgang:** offen; die Closure setzt ihn.
- **Der Wächter misst Kardinalität, nicht Identität.** Tauscht ein gedeckter Link gegen einen
  anderen, ohne dass sich die Zahl ändert, bleibt er grün — und ein *neu* stumm geschalteter
  Verweis sieht dann aus wie der alte. Das steht in
  [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) §Fitness Function als
  *„niemand"* und wird von diesem Slice **nicht** geschlossen; er darf es nur nicht als geschlossen
  ausgeben. Die Klasse ist
  [`BEO-ALL/ausnahmeliste-nur-auf-form-geprueft`](../observations/BEO-ALL/ausnahmeliste-nur-auf-form-geprueft/observation.md).
  — **Ausgang:** offen; die Closure setzt ihn.
- **Der Preis der Entscheidung tritt mit diesem Slice ein: eine heute auflösende Adresse
  verstummt.** Ein Link in den **lebenden** Baum aus einem der drei gedeckten Bäume wird vom Ventil
  mit stumm geschaltet; Stichtag 2026-09-07 ist das genau eine
  (`git grep -oE '\]\([^)]*\.harness/baseline/v6\.5\.0/' -- 'docs/reviews/**' 'docs/plan/planning/done/**' 'docs/plan/planning/observations/**' | wc -l`
  → 1, **kein Erwartungswert**). Das ist entschieden und nicht zu verhandeln; der Slice hat es zu
  **belegen**, nicht abzuwägen. Die Klasse ist
  [`BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse`](../observations/BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse/observation.md).
  — **Ausgang:** offen; die Closure setzt ihn.

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
  Auslöser: `BEO-<NNN>` (<slice-NNN>, <slice-MMM>, <slice-KKK> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-NNN.md` | `evidence/slice-NNN.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-NNN (<Titel>) — ist eine Datei in `open/`>
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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area, `*` (`ALL`). Die
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md) führt daneben
`harness/tools/` (`TOOLS`) und `.codex/` (`CODEX`); beide sind **nicht** berührt — der Slice fasst
kein Skript und keine Hook-Konfiguration unter diesen Pfaden an (§3). `ALL` erfüllt die Schwelle als
deklarierte Sub-Area mit eigenem Kürzel; eine feinere Aufteilung wäre hier Erfindung — die
Gate-Konfiguration adressiert das ganze Repo.

**Vorgelagert — offene Beobachtungen sichten:** Das Register unter
[`../observations/`](../observations/) ist durchgegangen; es führt **65** Verzeichnisse
(`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, kein Erwartungswert), alle unter
`BEO-ALL`, die damit die berührte Sub-Area formal treffen. Aufgeführt sind die, die **diesen
Vorgang** betreffen — Zähler abgelesen als Dateizahl unter `evidence/`, nicht aus einem Feld
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`; **keine
Erwartungswerte**, gelesen wird der gemergte Stand):

| Eintrag | Zähler | Stand | Bezug zu diesem Slice |
|---|---|---|---|
| `vorgeschriebener-ortswechsel-macht-adresse-tot` | 4× | verkörpert | die 36 Adressen sind sein Bestand; die verkörperte Regel deckt den **künftigen** Schreibfall, nicht diesen |
| `ausnahmeliste-nur-auf-form-geprueft` | 1× | offen | der Wächter prüft Form und Zahl, nie die inhaltliche Berechtigung eines Eintrags — §6 viertes Risiko |
| `gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse` | 1× | offen | der Preis dieses Slice: eine heute auflösende Adresse verstummt — §6 fünftes Risiko |
| `extensionale-zahl-unterschreitet-die-eigene-fundmenge` | 1× | offen | die Deklaration **ist** eine extensionale Zahl neben ihrer Fundmenge; sie trägt hier ihr Kommando, und der Wächter hält beide gegeneinander |
| `benannte-luecke-ohne-ausgang` | 0× | offen | **gesichtet, hier nicht aufgelöst** — die Code-Span-Achse bleibt nach diesem Slice benannt und ungemessen ([`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Folgepflicht 2), §1 vierter Ausschluss |

**Kein Eintrag erreicht mit diesem Slice 3×.** Der einzige bei 4× steht auf `verkörpert` und
braucht keinen weiteren Ausgang; die drei bei 1× blieben bei 2×, falls die Closure ihnen einen
Beleg gibt — das entscheidet die Closure, nicht dieser Plan. Der Eintrag bei 0× trägt heute kein
`evidence/`-Verzeichnis; das ist der abgelesene Stand und keine Auslassung
(`find docs/plan/planning/observations/BEO-ALL/benannte-luecke-ohne-ausgang -type f`). Alle
Bezeichnungen sind **zitiert**, nicht neu formuliert, damit das Register sie nicht als zwei Pfade
zählt.

**Modus:** alle berührten Sub-Areas **GF** — der Begründungsblock entfällt damit nach der
Umfangs-Regel dieser Sektion. Der Modus ist keine Folge der Slice-Größe, sondern der Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md) §Modus-Deklaration pro Sub-Area, die
`*` als Greenfield führt.
