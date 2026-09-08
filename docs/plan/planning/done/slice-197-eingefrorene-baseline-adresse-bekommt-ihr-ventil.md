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

**Verantwortlich:** Implementer (pt9912) — die Arbeit ist Implementer-Arbeit,
[`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) §Kopplung.

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
  [slice-198](../open/slice-198-hard-rule-311-nennt-den-vendored-baum.md) geschnitten, und diese Kennung
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
  [slice-201](../done/slice-201-codepaths-erreicht-den-vendored-baum-nicht.md).
- **Die Code-Span-Achse des Wächters.** Er zählt die Inline-Markdown-Form und sieht eine
  Code-Span-Referenz nicht; das ist
  [`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Folgepflicht 2 und
  bleibt eine benannte Lücke — auch nach diesem Slice. Sie hier mitzunehmen hieße, den Maßstab und
  seine Achse in einem Zug zu ändern, und keine der zwei Änderungen wäre danach einzeln belegt.
- **Der Closure-Abschluss von [slice-193](../done/slice-193-baum-tausch-v650-pins-ziehen.md).**
  Dieser Slice macht ihn *möglich* (dessen DoD-Punkt `make gates` grün hängt an denselben 36
  Befunden), er vollzieht ihn nicht: Der Abschluss ist Planner-Arbeit in eigenem Kontext
  ([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [x] **Drei `ignore-refs`-Einträge in Glob-Form liegen in
      [`.d-check.yml`](../../../../.d-check.yml), einer je einfrierendem Baum, alle mit demselben
      `refs`-Wert `.harness/baseline/**`.** Die drei `in:`-Werte sind
      `docs/reviews/**`, `docs/plan/planning/done/**` und
      `docs/plan/planning/observations/**` — die Tabelle aus
      [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) Festlegung 1,
      unverändert übernommen. **Der `refs`-Wert ist baum-weit und nicht tag-weit**; ein
      tag-weiter Wert verlangte bei jedem Bump drei neue Einträge und damit eine neue Entscheidung
      je Sprung. Beleg: `make docs-check` meldet `0 Befund(e)`, und der Kommentar jedes der drei
      Einträge nennt seine Entscheidung.
- [x] **Alle sieben Einträge deklarieren am Ort ihrer Definition, wie viele Markdown-Links sie
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
- [x] **[`test/ignore-refs-restbreite.bats`](../../../../test/ignore-refs-restbreite.bats) misst
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
- [x] `make gates` grün. Gemessen in dieser Closure über dem Baum, der sie trägt: EXIT 0, und
      `make docs-check` meldet `0 Befund(e)` — der Nachher-Wert zu den `36 Befund(e)` aus §1, mit
      demselben Kommando erhoben. Tragend ist die Null; die daneben stehende Datei-Zahl (Stichtag
      2026-09-08: 962) ist **kein Erwartungswert** und wandert mit dem Bestand — sie ist zwischen
      zwei Läufen dieser Closure selbst gewachsen, weil die Register-Belege Dateien sind.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8). Der Review-Report vom
      2026-09-08 (1 HIGH / 3 MEDIUM / 4 LOW / 2 INFO) und der Verifikations-Report desselben Tages
      liegen vor; das HIGH ist behoben, kein Befund blockiert die Closure.
- [x] Doku-Update falls öffentlicher Vertrag berührt. **Entfällt:** Der Kopf führt
      `Berührte Spec-Stellen: —`, und weder die Gate-Konfiguration noch der Maßstab des Wächters
      sind in [`spec/spezifikation.md`](../../../../spec/spezifikation.md) festgelegt.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register fortgeschrieben, **falls dieser Slice einen Inventur-Fund auflöst** —
      Zeile mit Datum und auflösendem Artefakt nach *Aufgelöste Einträge* verschoben. **Entfällt
      hier:** Repos ohne Brownfield-Bootstrap haben die Datei nicht, und dieses führt sie nicht
      (`ls docs/plan/planning/reconciliation.md` → nicht vorhanden). Der Pfad steht als
      **Kommando-Operand**, weil die vendored Vorlage ihn als blanken Inline-Code führt und
      `codepaths` ihn dann als fehlendes Ziel meldet — dieselbe Stelle, die
      [slice-193](../done/slice-193-baum-tausch-v650-pins-ziehen.md) §6 als offenen Punkt
      führt.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert. Sieben Belege, zwei neue Einträge — §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen). Fünf von fünf, je genau einer.
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit). **Dieses Repo führt Wellen-Betrieb; der Träger ist benannt, und zwei Befunde für ihn liegen vor:** die zweite Hälfte der Register-Paarung (c) ist unverändert rot (zwei Einträge mit leerem `evidence/`), und vier Einträge stehen bei 3× oder darüber ohne Ausgang (§7, letzter Punkt) — beides Vorbestand, keiner von diesem Slice erzeugt.

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
   [slice-193](../done/slice-193-baum-tausch-v650-pins-ziehen.md) belegt es heute: seine
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
  [slice-193](../done/slice-193-baum-tausch-v650-pins-ziehen.md) liegt in `in-progress/`;
  sein DoD-Punkt `make gates` grün und sein Closure-Kriterium 1 hängen an denselben 36 Befunden,
  die dieser Slice räumt. *„slice-193 liegt in `done/`"* als Start-Bedingung wäre damit eine
  Bedingung, die dieser Slice selbst herstellen muss — beobachtbar, aber unerfüllbar. Die
  Reihenfolge ist die umgekehrte: **dieser Slice zuerst, der Abschluss von slice-193 danach.** Was
  offen bleibt, ist die Frage, ob zwei gleichzeitig beanspruchte Slices desselben Rolleninhabers
  hier zulässig sind oder ob slice-193 vorher zurückgeführt gehört — sie ist eine
  Lifecycle-Entscheidung und keine Arbeit dieses Slice. — **Ausgang: entfallen.** Begründung,
  gemessen und nicht angenommen: Die Doppelbelegung ist nie eingetreten. `CO-006` hat die
  Zirkularität vor der Übernahme aufgelöst, indem es das rote Gate an einen Trigger band statt an
  dessen Herstellung; damit konnte slice-193 schließen, **bevor** dieser Slice beansprucht wurde.
  Die zwei reinen Move-Commits stehen in genau dieser Reihenfolge auf dem Hauptzweig, und zwischen
  ihnen trägt `in-progress/` keinen zweiten `slice-*.md` — `git log --oneline --reverse 6a328c4b..281a1f79`
  nennt als ersten den Abgang von slice-193 aus `in-progress/` und als letzten den Zugang dieses
  Slice. **Das Kommando trägt bewusst kein Pfad-Literal:** Ein Pfad, der einen *vergangenen*
  Aufenthalt bezeichnet, wird vom Verweis-Nachzug des Closure-Moves auf den *heutigen* umgeschrieben
  und misst danach etwas anderes, ohne zu scheitern. Die zwei Kennungen sind Commit-Hashes und
  wandern nicht. Die offen gelassene
  Lifecycle-Frage — ob zwei gleichzeitig beanspruchte Slices desselben Rolleninhabers zulässig
  wären — hat damit keinen Gegenstand mehr und wird nicht stellvertretend beantwortet.
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
  der Preis, den jene Entscheidung in §Konsequenzen benennt. — **Ausgang: entfallen.** Begründung,
  in der Closure nachgemessen statt aus dem Plan übernommen (Stichtag 2026-09-08, **keine
  Erwartungswerte**): Der Korpus ist um die zwei Reports dieses Slice gewachsen, die Deklaration
  `33` steht unverändert richtig, und der Grund ist zählbar — beide Reports tragen jede
  Baseline-Nennung als Inline-Code oder Kennung und **keinen** Markdown-Link in den Baum.

  ```sh
  ls docs/reviews/*.md | wc -l                                                  # 304 (Plan-Stichtag: 302)
  git grep -lE '\]\([^)]*\.harness/baseline/' -- 'docs/reviews/*.md' | wc -l    #  17 (Plan-Stichtag:  17)
  ```

  Die zweite Zahl ist die tragende: Die Zahl der Reports mit Baseline-Link ist trotz zweier neuer
  Dateien gleich geblieben, das Kommando aus
  [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) Festlegung 2 liefert
  für `docs/reviews` weiterhin `33`, und der Wächter ist über allen sieben Einträgen grün. Der
  konkrete Fall — *der Review dieses Slice veraltet die Deklaration* — kann nicht mehr eintreten:
  Die zwei Reports sind geschrieben und eingefroren. **Der allgemeine Mechanismus ist damit nicht
  geschlossen und wird auch nicht als offene Beobachtung geführt:** Dass die Deklaration mit jedem
  künftigen Report wandert und der Wächter dann eine Entscheidung verlangt, steht als entschiedene
  Folge in [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) §Konsequenzen
  und §Re-Evaluierungs-Trigger, mit dem Neu-Messen vor dem Merge als benanntem Träger.
- **Der `in:`-Glob `docs/plan/planning/observations/**` ist breiter als seine Begründung.** Er deckt
  neben `observation.md` und `evidence/*.md` — beide unveränderlich ab Anlage bzw. ab Merge — auch
  `state.md` (der veränderliche Stand) und die `README.md` der Ablage. Für die zwei trägt das
  Argument *„niemand darf sie mehr anfassen"* nicht, und eine tote Baseline-Adresse in ihnen
  verstummt trotzdem. Die Verengung ist **nicht** Arbeit dieses Slice (§1): Sie weicht von der
  `in:`-Tabelle in
  [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) Festlegung 1 ab, die
  Festlegung 3 extensional schließt. Ob eine **Verengung** dafür eine eigene Entscheidung braucht,
  sagt Festlegung 3 nicht — sie nennt Verbreiterungen — und ist damit eine offene Architect-Frage.
  — **Ausgang: weiter offen, ins Beobachtungs-Register.** Der Eintrag ist
  [`BEO-ALL/messung-nimmt-lebendes-register-in-den-eingefrorenen-ausschluss`](../observations/BEO-ALL/messung-nimmt-lebendes-register-in-den-eingefrorenen-ausschluss/observation.md);
  er trägt genau diesen Gegenstand — ein auf Unveränderlichkeit begründeter Ausschluss nimmt das
  lebende Register daneben mit. Beleg `evidence/slice-197.md`, Zähler danach
  `ls docs/plan/planning/observations/BEO-ALL/messung-nimmt-lebendes-register-in-den-eingefrorenen-ausschluss/evidence/*.md | wc -l`
  → 2. Die Verengung selbst bleibt Architect-Arbeit und wird hier nicht vorweggenommen.
- **Der Wächter misst Kardinalität, nicht Identität.** Tauscht ein gedeckter Link gegen einen
  anderen, ohne dass sich die Zahl ändert, bleibt er grün — und ein *neu* stumm geschalteter
  Verweis sieht dann aus wie der alte. Das steht in
  [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) §Fitness Function als
  *„niemand"* und wird von diesem Slice **nicht** geschlossen; er darf es nur nicht als geschlossen
  ausgeben. Die Klasse ist
  [`BEO-ALL/ausnahmeliste-nur-auf-form-geprueft`](../observations/BEO-ALL/ausnahmeliste-nur-auf-form-geprueft/observation.md).
  — **Ausgang: weiter offen, ins Beobachtungs-Register.** Beleg `evidence/slice-197.md`, Zähler
  danach
  `ls docs/plan/planning/observations/BEO-ALL/ausnahmeliste-nur-auf-form-geprueft/evidence/*.md | wc -l`
  → 2. Die Identitäts-Achse bleibt damit unbewacht und ist es auch nach diesem Slice — dieselbe
  Lücke, die [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md)
  §Fitness Function für sich benennt.
- **Der Preis der Entscheidung tritt mit diesem Slice ein: eine heute auflösende Adresse
  verstummt.** Ein Link in den **lebenden** Baum aus einem der drei gedeckten Bäume wird vom Ventil
  mit stumm geschaltet; Stichtag 2026-09-07 ist das genau eine
  (`git grep -oE '\]\([^)]*\.harness/baseline/v6\.5\.0/' -- 'docs/reviews/**' 'docs/plan/planning/done/**' 'docs/plan/planning/observations/**' | wc -l`
  → 1, **kein Erwartungswert**). Das ist entschieden und nicht zu verhandeln; der Slice hat es zu
  **belegen**, nicht abzuwägen. Die Klasse ist
  [`BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse`](../observations/BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse/observation.md).
  — **Ausgang: weiter offen, ins Beobachtungs-Register.** Beleg `evidence/slice-197.md`, Zähler
  danach
  `ls docs/plan/planning/observations/BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse/evidence/*.md | wc -l`
  → 2. **Nicht** *eingetreten*: Der Preis ist mit dem Slice realisiert und belegt, und die
  geschlossene Menge kennt für einen realisierten Preis keinen Träger — weder Carveout noch
  Folge-Slice, weil die Entscheidung steht und nicht zurückzunehmen ist. **Nicht** *entfallen*:
  Die Adresse ist stumm. Was bleibt, ist eine stehende Eigenschaft ohne Beobachtungsstelle, und
  genau dafür ist der dritte Ausgang da.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

**Rolle:** Planner · **Datum:** 2026-09-08.

- **Was hat funktioniert:** Die **Trennung von Entscheidung und Umsetzung**. Der Slice hatte
  nichts abzuwägen: `in:`-Werte, `refs`-Wert und der Maßstab des Wächters standen wörtlich in
  [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md), und die vier rot zu
  sehenden Gegenbeispiele standen als DoD-Punkt statt als Absicht. Beide Prüf-Rollen haben sie
  **nachgefahren statt geglaubt**, je an einer Kopie außerhalb des Arbeitsbaums, und beide haben
  dieselben Detailzeilen gelesen — die Behauptung des Plans ist damit dreifach unabhängig belegt.
  Getragen hat ebenso der **vorab bezifferte Ausgangsstand** in §1: Dieselben zwei Kommandos
  liefern den Vorher- und den Nachher-Wert, und aus 36 Befunden wurde `0 Befund(e)` ohne dass eine
  Datei in einem der drei einfrierenden Bäume angefasst wurde — genau die zweite Hälfte des
  `CO-006`-Triggers, die eine reine Gate-Messung nicht hergibt.
- **Was ging anders als geplant:** Zwei Dinge.

  **Erstens: der blockierende Befund saß nicht in der Logik, sondern in ihrer Beschreibung.** Der
  Wächter nannte an drei Stellen `git ls-files` und fuhr `find` — eine der drei Stellen wird nur
  im Rot ausgegeben und schickte den Leser genau dann zu einem Werkzeug, das nicht gelaufen war.
  Der Plan sah für den Wächter eine Zählung vor und keine Aussage über die Menge, über der
  gezählt wird; dass diese Achse den Prüfumfang bestimmt, hat erst das Review gemessen.

  **Zweitens: die Deklaration misst eine engere Menge, als ihr Eintrag deckt** — der Markdown-Link
  auf das Vendoring-Verzeichnis **selbst** wird vom Werkzeug mit ausgenommen und von der Zählung
  nicht erfasst. Der Ausweg war **nicht**, die Zählung zu erweitern: Das hätte
  `docs/plan/planning/done/**` von der in
  [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) Festlegung 2
  gemessenen `3` auf `4` gehoben und wäre eine Abweichung von einer angenommenen Entscheidung
  gewesen. Verengt wurde die **Zusage**, nicht die Messung — und die verbleibende Grenze steht
  benannt statt repariert.
- **Steering-Loop-Eintrag — benannte Spec-Lücke, gegen
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6):**
  *Eine Referenz-Ausnahme kann ihre **Breite** deklarieren; ihre **Identität** kann sie nicht.*
  Der Wächter misst ab jetzt `genau N` statt `höchstens 1` und meldet damit auch den **Wegfall**
  einer gedeckten Referenz — er misst aber Kardinalität. Fällt im selben Stand eine Referenz weg
  und tritt eine andere hinzu, bleibt er grün, und der neu stumm geschaltete Verweis ist von dem
  alten nicht zu unterscheiden. Kein Modul aus `modules:` der
  [`.d-check.yml`](../../../../.d-check.yml) hält fest, **welche** Referenz gedeckt ist, und
  `make mutate` kennt dafür keine Fehlschlag-Form. **Kein neuer Sensor wird hier behauptet**
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6));
  die Lücke ist dieselbe, die
  [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) §Fitness Function für
  sich benennt, und sie ist **gezählt, nicht verkörpert** — der Eintrag `liegt in` entfällt darum
  ersatzlos.
- **Beobachtungs-Register (`../observations/`):** **sieben** Belege aus diesem Vorgang, je genau
  eine `slice-197.md` — ein Vorgang zählt einmal, auch wo ein Fund mehrfach auftrat. Fünf gehen in
  bestehende Einträge: `verweis-nachzug-schreibt-in-eingefrorenes-artefakt` (→ **3×**) ·
  `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch` (→ **4×**) ·
  `messung-nimmt-lebendes-register-in-den-eingefrorenen-ausschluss` (→ 2×) ·
  `ausnahmeliste-nur-auf-form-geprueft` (→ 2×) ·
  `gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse` (→ 2×). **Zwei Einträge sind neu.**
  `config-kommentar-nennt-anderen-bereich-als-der-eintrag` trägt zwei Belege, weil sein
  Erstauftreten in einem anderen abgeschlossenen Vorgang liegt — `evidence/slice-177.md` und
  `evidence/slice-197.md` (→ 2×), die wiederkehrende Finding-Klasse des Reviews dieses Slice.
  `verweis-nachzug-ersetzt-eine-historisch-richtige-adresse` (→ 1×) entstand **in** der Closure:
  Der Nachzug des Closure-Moves schrieb die Pathspec einer Mess-Aussage über die Vergangenheit von
  `in-progress/` auf `done/` um, das Kommando lief weiter und maß etwas anderes. Er ist **nicht**
  in `verweis-nachzug-bricht-tree-operand` einsortiert: Deren `observation.md` ist ab Anlage
  unveränderlich und nennt die Form `<sha>:<pfad>`, in der derselbe Nachzug laut scheitert — ein
  Beleg dort machte den Eintrags-Text enger als seine Belege, genau die Klasse eine Ebene höher.
  Zähler sind Dateizahlen und stehen in keinem Feld
  (`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`).

  **Ein Eintrag überschreitet mit diesem Slice die Schwelle** —
  `verweis-nachzug-schreibt-in-eingefrorenes-artefakt` — und steht bis zum Lese-Schritt weiter auf
  `offen`; zulässig und vorübergehend nach `v6.5.0` · `regelwerk/modul-06-roadmap.md`
  §Das Beobachtungs-Register. Den Lese-Schritt trägt in einem Repo mit Wellen-Betrieb die
  Welle-Closure, und dieses Repo führt zwei offene Wellen; die Übergabe steht hier, nicht der
  Ausgang.

  **Zwei Funde dieses Vorgangs bekommen bewusst keinen Beleg.** Die Beobachtung
  `gate-flaeche-haengt-am-arbeitsbaum` trifft MEDIUM-2 der Sache nach; der Befund ist im selben
  Vorgang behoben worden (der Wächter benennt seine Bezugsmenge jetzt selbst), und ein Beleg
  zählte hier eine Gelegenheit, keine Wiederholung. Und die vier Deklarations-Zahlen der
  bestehenden Paare sind **nachgemessen und unverändert** — kein Fund.
- **Folge-Slices:** keiner geschnitten. Die zwei Punkte, die §1 ausschließt und die eine eigene
  Kennung brauchen, sind bereits Dateien in `open/`:
  [slice-198](../open/slice-198-hard-rule-311-nennt-den-vendored-baum.md) (die §3.11-Schärfung,
  Architect-Arbeit) und
  [slice-201](../done/slice-201-codepaths-erreicht-den-vendored-baum-nicht.md) (der Prüfbereich
  für Inline-Pfade in den Baum). Die dritte Grenze — die Code-Span-Achse des Wächters — bleibt
  [`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Folgepflicht 2
  und ist als benannte Lücke geführt, nicht als Slice.
- **Carveout:** **`CO-006` ist aufgelöst.** Beide Hälften seines Auflösungs-Triggers sind gemessen,
  und die zweite über der Menge, die sie meint — nicht über den drei Bäumen als Ganzen: Die
  Trigger-Bedingung fragt nach den Dateien, die die Adressen **tragen**, und die drei Bäume nehmen
  seit der Anlage legitim neue Dateien auf (die zwei Reports dieses Slice, den Slice-Plan von
  slice-193, den Verweis-Nachzug seines Reports).

  ```sh
  git grep -lE '\]\([^)]*\.harness/baseline/v6\.0\.0/' 6a328c4b \
    -- 'docs/reviews' 'docs/plan/planning/done' 'docs/plan/planning/observations' | wc -l   # 16 Traeger
  git grep -ohE '\]\([^)]*\.harness/baseline/v6\.0\.0/' 6a328c4b \
    -- 'docs/reviews' 'docs/plan/planning/done' 'docs/plan/planning/observations' | wc -l   # 36 Adressen
  git diff --stat 6a328c4b..HEAD -- <die 16 Traeger>                                        # leer
  ```

  `make docs-check` meldet `0 Befund(e)`, und keine der 16 Träger-Dateien ist seit der Anlage des
  Carveouts angefasst worden — das ist die Hälfte, die den verbotenen Weg ausschließt. Die Datei
  wandert per reinem `git mv` nach `docs/plan/carveouts/done/`, ihre Zeile im Index wechselt von
  *Aktiv* nach *Aufgelöst*. Die `Bindung`-Spalte in
  [`harness/README.md`](../../../../harness/README.md) §Sensors ist **nicht** zurückzusetzen, und
  das ist gemessen statt angenommen: `git grep -c 'CO-006' -- harness/README.md` endet ohne Ausgabe
  mit Exit 1. `CO-006` hatte keine konfigurierte Ausnahme — geduldet war ein **lautes** rotes Gate,
  und ein lautes Rot hinterlässt keine Konfiguration, die zurückzunehmen wäre.
- **Trigger-Audit:** `CO-001` — Trigger weiterhin **eingetreten**, Ausgang unverändert
  *verlängert mit Folge-Slice*; die zwei Träger sind Dateien im Lifecycle
  ([slice-141](../next/slice-141-co-001-aufloesung-ist-vorher-entschieden.md) entscheidet vorher,
  [slice-113](../open/slice-113-co-001-ist-faellig.md) führt aus). Die `Letzte Prüfung:`-Zeile
  jener Datei bleibt beim Stand des welle-10-Audits: In einem Repo mit Wellen-Betrieb ist das
  Carveout-Audit Schritt 2 der Welle-Closure, und eine zweite Eintragung desselben Ergebnisses
  wäre Chronik. `CO-002` — permanent, in
  [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) übergeführt, keine
  Handlung. `CO-006` — aufgelöst, siehe oben. Bootstrap-aware Gates führt dieses Repo keine.
  ADR-Re-Evaluierungs-Trigger im Gegenstand dieses Slice: Von den vier Triggern in
  [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) ist **keiner**
  gefeuert — keine Deklaration ist rot (`make gates` EXIT 0), kein Baum-Tausch steht an, kein
  vierter Baum friert ein, und `ls -d .harness/baseline/*/` führt weiterhin genau eine
  `<tag>`-Ebene. Der offene Acceptance-Beleg von
  [`ADR-0038`](../../adr/0038-ziel-fassung-regiert-den-sprung-v650.md) bleibt
  [slice-199](../open/slice-199-adr-0038-bekommt-ihre-bestaetigungsrunde.md).
- **Risiken aus §6:** alle fünf tragen genau einen Ausgang — **2× entfallen mit Begründung**
  (die WIP-Doppelbelegung ist nie eingetreten, weil `CO-006` die Zirkularität vor der Übernahme
  auflöste; die Deklaration `33` ist nachgemessen und unverändert richtig, weil beide Reports
  dieses Slice keinen Markdown-Link in den Baum tragen), **3× weiter offen ins Register**
  (`messung-nimmt-lebendes-register-in-den-eingefrorenen-ausschluss` ·
  `ausnahmeliste-nur-auf-form-geprueft` · `gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse`).
  Kein Risiko ist *eingetreten*: Der einzige Kandidat — der Preis der Entscheidung — ist realisiert
  und hat keinen Träger in der geschlossenen Menge, seine Begründung steht bei ihm in §6.
- **Drei Paarungen:** dieses Repo führt Wellen-Betrieb; sie prüft die nächste Welle-Closure — auch
  für einen Slice ohne Wellen-Zugehörigkeit. **Nachgesehen und übergeben statt behauptet:** Die
  zweite Hälfte der Register-Paarung (c) — *jede Registerzeile trägt mindestens einen Beleg* —
  ist unverändert **rot**, und zwar an denselben zwei Einträgen wie zuvor,
  `benannte-luecke-ohne-ausgang` und `einstiegs-datei-weicht-von-der-pflichtgliederung-ab`; beide
  führen ein leeres `evidence/`, beide sind in §8 als Nullzähler gesichtet
  (`for d in docs/plan/planning/observations/BEO-ALL/*/; do [ -z "$(ls "$d"evidence/*.md 2>/dev/null)" ] && basename "$d"; done`).
  Dieser Slice hat keinen von beiden erzeugt und schließt keinen. **Ein zweiter Befund für die
  Welle-Closure liegt daneben:** Vier Einträge stehen bei **3×** oder darüber und tragen `offen`
  — `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`,
  `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`, `zaehler-label-nennt-falsche-einheit`,
  `zitat-grep-uebersieht-zeilenumbruch-und-markup`. Der Lese-Schritt, der ihnen einen Ausgang
  zuweist, ist Schritt 3a der Welle-Closure und läuft nicht in dieser Rolle; solange beide Wellen
  offen sind, hat er keinen Termin. Das ist die Klasse
  `schwellen-uebertritt-ohne-zustaendige-rolle` (2×) — **benannt, nicht gezählt**: Ein Beleg käme
  aus einer Closure, die den Lese-Schritt gar nicht trägt, und zählte damit eine Zuständigkeit,
  die sie nie hatte.

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
