# Slice slice-104: Die Rollen-Namen haben eine Quelle — drei Fundorte leiten ab, die Test-Tabelle bleibt unabhängig

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Sensor-Wartung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, hier beantwortet: **(1) Bündel?** Nein — Quelle, Ableitungen und Zähne landen in
**einem** Schnitt; er wartet auf keinen zweiten Slice und keiner wartet auf ihn. **(2) Gemeinsames
Closure-Kriterium?** Nein — jedes denkbare wäre die Abschrift seiner eigenen DoD. **Auch nicht in
[welle-12](../welle-12-erfassungsschicht-emittieren.md):** deren Abdeckungs-Tabelle führt die Zeile
*„Rolle besetzt"* als von [slice-097](../in-progress/slice-097-rollen-typen-gehen-mit.md) geliefert; dieser
Slice füllt keine Zelle und leert keine. **(3) Auslöser reaktiv oder gewollt?** Reaktiv — eine
gemessene Lücke am Dogfood-Sensor, kein Fähigkeits-Sprung: das Werkzeug lernt nichts, was es nicht
schon kann, und das Ziel bekommt keine Datei, die es nicht schon bekommt. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: die Quelle des Werkzeugs, kein neues emittiertes Artefakt.** Zwei der drei Fundorte liegen
im Go-Bestand, der als Produkt-Binär ins Ziel kopiert wird; der dritte,
[`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh), geht **nicht** mit
(`ls internal/emit/templates/full-smoke* internal/emit/templates/*/full-smoke* 2>/dev/null | wc -l`
→ **0**). Was sich für einen Adopter ändert: **nichts** — er bekommt dieselben sechs Typ-Dateien
unter denselben Namen. Geändert wird, an wie vielen Stellen dieses Repo diese Namen **schreibt**.

**Bezug:**
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (**Accepted** —
Festlegung 3 lässt die Kopplung *„der Träger füllt `agent.role` genau dann, wenn der Agenten-Typ
eine der sechs kanonischen Rollen **nennt**"* ausdrücklich **benannt, nicht geschlossen**. Dieser
Slice **schließt** sie; er erfindet sie nicht, und er trägt darum keine neue Entscheidung nach —
eine *Accepted*-ADR wird gelesen, nicht ergänzt, [`AGENTS.md`](../../../../AGENTS.md) §3.4),
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (die
Rollen-Achse und ihre §Benannte Grenze — der Name **ist** der Vertrag, und ein zweiter Ort, an dem
er steht, ist ein zweiter Ort, an dem er falsch werden kann),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die
Klasse, gegen die Klausel (i) der schließenden Eigenschaft gerichtet ist: ein Wächter über einem
leeren Bestand ist grün und prüft nichts),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (*wer keinen Fall in `test/mutations/` hat, ist
unbewacht* — der dritte Fundort hat keinen, gemessen in §1),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert, und wandert mit ihrem Bestand),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(Verortung).

**Autor:** Planner. **Datum:** 2026-08-25.

---

## 1. Ziel

**Der Satz der sechs kanonischen Rollen-Namen steht im Produktionsbestand an genau einer Stelle;
die Abbildung des Trägers und der Voll-E2E-Sensor leiten ihn ab, statt ihn zu wiederholen — und die
Aussage darüber wird über einem nachweislich **nicht-leeren** Bestand gemessen.**

### Die Ausgangslage: drei Fundorte, einer davon neu

Die Eigenschaft, über die gezählt wird: *eine Zeile im Produktionsbestand, die die sechs Namen als
Literale nebeneinander schreibt.* Kommando und Stand:
`grep -rn 'planner.*architect.*implementer' --include='*.go' --include='*.sh' . | grep -v '_test.go'`
→ **3**, mitwandernd:

| Fundort | Rolle der Zeile |
|---|---|
| [`internal/emit/agents.go`](../../../../internal/emit/agents.go), `canonicalRoles()` | die Quelle der Emission — aus ihr entstehen Dateiname und eingebettete Vorlage je Typ |
| [`internal/span/emit.go`](../../../../internal/span/emit.go), `roleFromAgentType()` | die Abbildung des Trägers — sie entscheidet, ob `agent.role` besetzt ist oder leer |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh), die Schleife in `rollen_typen_im_ziel()` | der Voll-E2E-Sensor — er prüft Anwesenheit und Frontmatter-Namen im gebootstrappten Ziel |

**Den dritten hat [slice-097](../in-progress/slice-097-rollen-typen-gehen-mit.md) selbst angelegt**,
und er ist der einzige der drei, den **kein** Sensor hält:
`grep -l '^# files:.*full-smoke' test/mutations/*.sh` → **leer**. Streicht man eine Rolle aus seiner
Schleife, bleiben `make shell-lint`, `make comment-claims`, `make docs-check` und `make test-go`
**alle grün** — gemessen in der [Verifikation zu slice-097](../../../reviews/2026-08-25-slice-097-verify.md)
§1.3 (Sonde P9) und hier als **fremdbelegt** ausgewiesen, nicht als eigener Lauf. Nach
[`AGENTS.md`](../../../../AGENTS.md) §3.6 ist er damit unbewacht.

**Ein vierter Fundort existiert und bleibt, wo er ist** — siehe §Die Grenze unten.

### Die schließende Eigenschaft, in drei Klauseln

Nicht der Umbau macht den Slice fertig, sondern diese Eigenschaft. Sie ist **am gebootstrappten
Ziel** formuliert, weil dort alle drei Fundorte zusammenlaufen:

1. **(i) Der Typ-Bestand des Ziels ist nicht leer und deckungsgleich mit dem einen geschriebenen
   Namens-Satz.** Bindet die Quelle **und** die Verdrahtung, die sie aufruft: fällt der Aufruf aus
   `emitAll`, ist der Bestand leer, und die Klausel bricht.
2. **(ii) Jeder Name dieses Bestands normalisiert über die Abbildung des Trägers auf ein
   nicht-leeres Rollen-Feld.** Bindet [`internal/span`](../../../../internal/span).
3. **(iii) Für diese Prüfung führt der Voll-E2E-Sensor keine eigene Namensliste.** Bindet
   [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh).

**Warum die naheliegende Ein-Satz-Fassung nicht reicht — zwei gemessene Löcher.** Die Fassung
*„jeder emittierte Typ-Name normalisiert über die Abbildung des Trägers auf ein nicht-leeres
Rollen-Feld"* trifft die Sache, bindet aber nur zwei der drei Fundorte:

- **Sie lässt den dritten frei.** Die Schleife in
  [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) ist weder ein emittierter
  Typ-Name noch die Abbildung des Trägers; nimmt man ihr eine Rolle, bleibt der Satz wahr. Deshalb
  Klausel (iii).
- **Sie ist über der leeren Menge wahr.** Ohne emittierte Typ-Namen normalisiert jeder von null
  Namen — dieselbe Falle, die
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) für
  Gates über leerem Prüfbereich benennt. Gemessen: entfernt man `emit.Agents(targetDir)` aus
  `emitAll`, bleibt `make test` grün (Sonde P6 derselben Verifikation, **fremdbelegt**). Deshalb
  trägt Klausel (i) das Wort *nicht leer*, und zwar vor allem anderen.

### Die Grenze: die Test-Tabelle wird nicht eingesammelt

`TestSpawnedRoleIsNormalised` in
[`internal/span/response_test.go`](../../../../internal/span/response_test.go) führt eine
Literal-Tabelle: `sed -n '/cases := map\[string\]string{/,/^\t}$/p' internal/span/response_test.go | grep -oE ': "[^"]*"' | wc -l`
→ **16** Einträge, davon `… | grep -oE ': "[^"]+"' | wc -l` → **6** mit nicht-leerer Erwartung. Die
übrigen **zehn** sind **Verneinungen** — `general-purpose`, der Leerstring, ein Großbuchstabe, ein
angehängtes Leerzeichen, eine Zahl, `null`, ein Objekt, eine Liste.

**Diese Tabelle ist der vierte Fundort, und der Träger sammelt sie nicht ein.** Ein Test, der seine
Erwartung aus dem geprüften Code ableitet, ist zirkulär: er kann unter keiner Mutation der Quelle
rot werden, und genau diese Bauart hat dieses Repo schon einmal gemessen — ein Wächter, dessen
Erwartung aus der mutierten Funktion stammte, blieb unter seinem eigenen Fall grün
([slice-096](../done/slice-096-traeger-liegt-im-ziel.md) §7). Die Tabelle hält den **Vertrag** — die
sechs Namen **und** ihre Verneinungen —, nicht den Bestand. Sie darf die Namen darum ein zweites Mal
schreiben; jede andere Stelle darf es nicht.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6). Sie folgen den drei Klauseln aus §1, in der Reihenfolge,
in der sie tragen.

- [ ] **(1) Die Namen stehen einmal; die Abbildung des Trägers leitet ab (Klausel ii).** Nach dem
      Lauf schreibt genau **ein** Ort des Produktionsbestands die sechs Literale; die Zahl aus §1
      steht dann auf **1**, gemessen mit demselben Kommando. Ein Wächter verlangt für **jeden** Namen
      der Quelle ein nicht-leeres Rollen-Feld und für einen Namen daneben ein leeres — beide
      Richtungen, sonst prüft er eine Teilmenge.
      **Rot:** `make test` — dazu ein `test/mutations/`-Fall, der die Quelle um eine Rolle kürzt,
      und einer, der die Abbildung um denselben Namen kürzt; unter jedem muss der Wächter fallen.
- [ ] **(2) Der Bestand, über dem gemessen wird, ist nachweislich nicht leer — die Verdrahtung hat
      ihren eigenen Zahn (Klausel i).** Heute deckt sie kein `test/mutations/`-Fall, und `make test`
      bleibt grün, wenn `emit.Agents(targetDir)` aus `emitAll` fällt (§1, fremdbelegt).
      **Rot:** `make full-smoke` — plus ein `test/mutations/`-Fall mit `# verify: full-smoke`, der
      genau diesen Aufruf entfernt. **Die Stufe ist nicht frei wählbar:** ein Go-Test im Paket
      [`internal/emit`](../../../../internal/emit) sieht den Aufruf in
      [`cmd/ai-harness-init/main.go`](../../../../cmd/ai-harness-init/main.go) nicht.
- [ ] **(3) Der Voll-E2E-Sensor führt keine eigene Namensliste und hat erstmals einen Fall über
      sich (Klausel iii).** Nach dem Lauf liefert
      `grep -l '^# files:.*full-smoke' test/mutations/*.sh` mindestens **einen** Treffer — heute
      **leer**.
      **Rot:** `make full-smoke` — ein Fall, der der abgeleiteten Liste ihre Ableitung nimmt (eine
      Rolle im Ziel fehlt, ohne dass der Sensor sie vermisst), muss rot werden. **Was dieser Punkt
      ausdrücklich nicht verlangt:** dass der Sensor seine Liste aus dem **Ziel** liest — das wäre
      die Zirkularität aus §Die Grenze, eine Ebene tiefer.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Doku-Update, falls ein öffentlicher Vertrag berührt ist · Closure-Notiz mit
Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`internal/emit/agents.go`](../../../../internal/emit/agents.go) | update | die eine Quelle. **Hier bekommt `AgentFile()` seinen Aufrufer oder fällt:** `grep -rn 'AgentFile' --include=*.go . \| wc -l` → **1**, die Definition selbst; ihr Doc-Kommentar nennt eine Nutzung *„(fuer Tests/Inspektion)"*, die es nicht gibt ([`AGENTS.md`](../../../../AGENTS.md) §3.7). Der Bestands-Nachweis aus DoD (1) braucht genau diesen Zugriff — die Zeile steht hier und nicht in §6, weil ein Posten ohne Ort in der Plan-Tabelle in diesem Repo gemessen wirkungslos bleibt |
| [`internal/span/emit.go`](../../../../internal/span/emit.go) | update | `roleFromAgentType` leitet ab statt zu wiederholen. **Kein Import-Zyklus im Weg:** `grep -rn 'ai-harness-init/internal/span' internal/emit/*.go \| wc -l` → **0** und `grep -rn 'ai-harness-init/internal/emit' internal/span/*.go \| wc -l` → **0**; heute kennt keines der zwei Pakete das andere, beide Richtungen sind offen. Welche gewählt wird, ist Frage A |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | update | der dritte Fundort verliert seine eigene Liste (Klausel iii) |
| [`internal/emit/agents_test.go`](../../../../internal/emit/agents_test.go) | update | zwei Ein-Zeilen-Korrekturen aus der Closure von [slice-097](../in-progress/slice-097-rollen-typen-gehen-mit.md): der Klassen-Kommentar beziffert die Emissions-Menge unter `docs/plan/` mit *zwei* (gemessen **6**), und das `richtung`-Feld derselben Klasse sagt *„unter `docs/plan/`"*, während sein Muster nur `planning\|adr` deckt. Die Datei wird für DoD (1) ohnehin angefasst |
| `test/mutations/` <!-- d-check:ignore (geplante Dateien) --> | neu | die Zähne aus DoD (1)–(3); Nummern im Anschluss an die höchste vergebene (`ls -1 test/mutations/*.sh \| wc -l` → **157**, beim Anlegen neu auszuzählen) |
| [`internal/span/response_test.go`](../../../../internal/span/response_test.go) | **unverändert** | §Die Grenze: die Tabelle hält den Vertrag samt seiner zehn Verneinungen und leitet nichts ab |
| [`docs/plan/adr`](../../adr) | **unverändert** | [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 3 lässt die Kopplung *benannt, nicht geschlossen*; sie auszuführen ist keine neue Entscheidung, und eine *Accepted*-ADR wird nicht nachgetragen ([`AGENTS.md`](../../../../AGENTS.md) §3.4) |
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | **unverändert** | wellenlose Arbeit wird dort nicht geführt ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 2/3) |

**Offen, vor dem Code zu entscheiden — beide entscheiden den Schnitt, nicht nur den Stil:**

| # | Frage | Warum sie den Schnitt entscheidet |
|---|---|---|
| A | **Wer leitet von wem ab: liest der Träger die Quelle des Emitters, oder liest der Emitter die Abbildung des Trägers?** | Beide Richtungen sind heute frei (Messung oben). *Emitter → Träger* macht die Emission von der Erfassung abhängig, obwohl die Rollen-Typen ausdrücklich **keinen** Laufzeit-Ausgang haben ([`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 5(a)); *Träger → Emitter* macht die Erfassung von einer Vorlagen-Liste abhängig. Ein drittes, gemeinsames Paket ist die dritte Antwort und der teuerste Schnitt |
| B | **Woraus leitet der Voll-E2E-Sensor seine Liste ab?** | Aus dem **Ziel** wäre zirkulär (§Die Grenze). Aus `internal/emit/templates/agents/` ist ein Vergleich zweier verschiedener Bäume und damit eine echte Aussage. Aus einem Unterkommando des Trägers wäre die stärkste Fassung — sie kostet aber ein neues Stück öffentlicher Oberfläche, und die gehört begründet, nicht nebenbei |

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): nichts blockiert ihn außer dem WIP-Limit — und das ist
der Termin, den dieser Slice trägt.** Frage A und B aus §3 sind ohne Vorarbeit eines anderen Slice
entscheidbar; der Gegenstand liegt vollständig in diesem Repo, berührt keine Anforderung und keine
Entscheidung und hängt an keiner Welle. Er wartet insbesondere **nicht** auf den `done/`-Zug von
[slice-097](../in-progress/slice-097-rollen-typen-gehen-mit.md): der dritte Fundort liegt bereits im
Baum, und die Messung in §1 gilt über ihm.

**Was dieser Slice ausdrücklich nicht ist: eine Nennung.** Die drei Postens, die er aufnimmt —
dritter Fundort, unbewachte Verdrahtung, aufruferloses `AgentFile()` — sind in einer Closure
gemessen und benannt worden. Ein Träger ohne Termin ist in diesem Repo dreimal vergeben und
nullmal eingelöst worden
([slice-101](slice-101-norm-postens-bekommen-einen-termin.md) §1, dort mit Kommando); der Termin ist
dieser Schnitt.

Die zwei Rückführungen, vorab benannt:

- **`in-progress` → `next` (zu groß):** wenn Frage A auf ein **drittes, gemeinsames Paket**
  hinausläuft. Dann sind es zwei Slices — einer, der das Paket schafft und die zwei Go-Fundorte
  zieht, und einer für den Sensor. Ein Paket-Schnitt quer durch
  [`internal/emit`](../../../../internal/emit) und [`internal/span`](../../../../internal/span) ist
  in **einer** Review-Sitzung nicht prüfbar, und das ist die Schwelle aus Modul 5 §Ziel-Form.
- **`in-progress` → `open` (blockiert):** wenn sich zeigt, dass die Ableitungs-Richtung aus Frage A
  eine Aussage von
  [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) berührt, statt
  sie auszuführen — etwa weil sie den Rollen-Typen doch einen Laufzeit-Ausgang gäbe. Dann wartet
  der Slice auf eine Entscheidung, statt an einer *Accepted*-ADR vorbeizubauen
  ([`AGENTS.md`](../../../../AGENTS.md) §3.4).

## 5. Closure-Trigger

DoD (1)–(3) erfüllt mit gefahrenen Kommandos; die Zahl der Literal-Fundorte im Produktionsbestand
steht auf **1** (Kommando in §1); Frage A und B sind mit ihrer Begründung im Plan beantwortet;
Review konform (Modul 10); Verifikation bestätigt (Modul 11); `make gates` grün; `make full-smoke`
grün; `make mutate` grün mit den neuen Fällen; `git mv` nach `done/` als eigener Move-Commit;
Closure-Notiz mit Steering-Loop-Eintrag in einer der drei Formen (geschärfte Regel · neuer Sensor ·
benannte Spec-Lücke).

## 6. Risiken und offene Punkte

- **Die schließende Eigenschaft kann formal erfüllt und sachlich leer werden.** Wer Klausel (i) über
  einer Liste misst, die er selbst aus derselben Quelle erzeugt, hat die Zirkularität nur verschoben
  — dieselbe Bauart, die §Die Grenze für die Test-Tabelle ausschließt. Der Prüfpunkt: **an welchen
  zwei verschiedenen Artefakten** der Vergleich hängt. Steht auf beiden Seiten dasselbe Artefakt,
  ist die Klausel keine.
- **Klausel (iii) kann die Aussage des Sensors verkleinern.** Nimmt man
  [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) die Liste und lässt ihn
  über das lesen, was er im Ziel findet, prüft er hinterher, dass da ist, was da ist. Das ist
  **schlechter** als die heutige Literal-Schleife, nicht besser. Frage B entscheidet das, und sie
  gehört vor den Code.
- **Zwei Zähne kosten `full-smoke`-Laufzeit.** DoD (2) und (3) verlangen Fälle auf der teuersten
  Stufe des Treibers; heute tragen `grep -l '^# verify: full-smoke' test/mutations/*.sh | wc -l` →
  **2** Fälle diesen Modus. Dass das teuer ist, ist kein Grund für eine schmalere Stufe — es ist der
  Gegenstand von [slice-105](slice-105-mutate-messen-dann-teilen.md), und die zwei Slices sind
  voneinander unabhängig: keiner wartet auf den anderen.
- **Der Slice berührt die Rollen-Achse, ohne sie zu verbreitern.** Er schließt eine Kopplung im
  Werkzeug; die Grenze, dass ein umbenannter Typ im Ziel ein **leeres** Feld ergibt, bleibt
  unangetastet und unbewacht — sie ist die von
  [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) selbst
  ausgesprochene, und ein Wächter darüber wäre einer über einem fremden Vertrag.
- **`make gates` deckt Klausel (i) nicht.** Sie hängt an `make full-smoke`, und der steht
  ausdrücklich **nicht** in `make gates` ([`AGENTS.md`](../../../../AGENTS.md) §4). Wer nach diesem
  Slice nur `make gates` fährt, sieht die Verdrahtung weiterhin nicht — das ist eine Eigenschaft der
  Stufe, keine Lücke des Schnitts, und sie gehört in die Closure-Notiz statt in eine Zusage.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

**Status:** Pflicht-Sektion bei mindestens einer berührten Sub-Area
in BF oder Hybrid. Bei reinem GF genügt der Hinweis
*"alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked
Mini-Example)"*. Optional bei reinem Refactor ohne neue
Sub-Area-Berührung. Die vier Pflichtkriterien (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand)
stehen in
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Worked Mini-Example](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#worked-mini-example-bootstrap-modus-pro-sub-area-für-einen-slice-begründen).

### Sub-Area: Rollen-Namen im Werkzeug (Emitter · Träger · Voll-E2E-Sensor)

Eine Sub-Area, kein zweiter Block: drei Dateien, **ein** Gegenstand — der Satz der sechs Namen —
und eine Frage, nämlich wo er geschrieben steht. Das Inklusionskriterium trägt über alle drei
Achsen: eigener Bestand, eigener Sensor, eigene Konvention.

- **Modus:** GF. Alle drei Fundorte sind in diesem Repo entstanden und von Anfang an gegen den Kurs
  geführt; es gibt keinen vorgefundenen Bestand, gegen den zu inventarisieren wäre.
- **Konventionen-Dichte:** hoch. [`AGENTS.md`](../../../../AGENTS.md) §3.6 (wer keinen Fall hat, ist
  unbewacht) trägt DoD (2) und (3),
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) trägt
  die Nicht-Leerheit in Klausel (i), und
  [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 3
  benennt den Gegenstand selbst.
- **Phase-Reife:** Phase 5 (Betrieb). Emitter, Träger und Voll-E2E-Sensor laufen; was fehlt, ist
  nicht Reife, sondern die Zusammenführung der Namensliste.
- **Evidenz-/Diskrepanz-Risiko:** niedrig und gemessen — die Zahl der Fundorte hängt an einem
  Kommando (§1). Das Restrisiko ist ein Urteils-Risiko: das Muster
  `planner.*architect.*implementer` findet nur Zeilen, die die Namen **nebeneinander** schreiben;
  eine über sechs Zeilen verteilte vierte Liste bliebe unentdeckt. Die Zahl ist damit eine
  **Untergrenze**, und der Lauf, der sie senkt, prüft das mit.
- **Reconciliation-Aufwand:** gering, aber nicht null — die Ableitungs-Richtung (Frage A) berührt
  die Paket-Grenze zwischen [`internal/emit`](../../../../internal/emit) und
  [`internal/span`](../../../../internal/span). Graduation-Trigger entfällt; die Sub-Area ist
  bereits GF.
