# Slice slice-094: Ein Programm, ein Einstiegspunkt — Schreiber und Auswertung werden Unterkommandos

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-12](../welle-12-erfassungsschicht-emittieren.md) — der erste Slice der Welle. Er
geht der Emission voraus, weil
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Folgepflicht 1 die
Emission an den Dogfood bindet.

**Bezug:**
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (**Accepted** —
Festlegung 2 *„Schreiber und Auswertung sind Unterkommandos desselben Trägers — und der Dogfood
fährt denselben Einstiegspunkt"*; Folgepflichten 1, 2, 3 und 8 sind die Schuld, die dieser Slice
begleicht),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted** — ihre Festlegung 6 nennt
zwei Eigenschaften des Emitters *nicht verhandelbar*: stdout leer, Exit-Code hart auf 0. Sie sind
der Gegenstand, der beim Umzug des Einstiegspunkts zerbrechen kann),
[`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) (**Accepted** — ihre Folgepflicht 1
*„der Beleg emittiert nichts, was der Dogfood nicht selbst fährt"* ist nicht abgelöst, sondern
bindend; dieser Slice ist die Stelle, an der sie eingelöst wird),
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (sie verlangt
Schreiber **und** Auswertung im Ziel — dieser Slice legt nichts ins Ziel, er stellt den
Einstiegspunkt her, den die späteren Slices dorthin tragen),
[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (der Emitter läuft am Hook
auf dem **Host**; die Plattform-Schalter des Baus hängen daran und dürfen beim Umbau nicht
verlorengehen),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(Setzung 2 — jede Zahl unten wandert mit ihrem Bestand).

**Autor:** Planner. **Datum:** 2026-08-25.

---

## 1. Ziel

**Dieses Repo führt für Erfassung und Auswertung genau ein Programm mit zwei Unterkommandos, und
sein Hook ruft denselben Einstiegspunkt, den ein Zielrepo später bekommt.**

Heute sind es drei Programme. `ls -1 cmd/` nennt `ai-harness-init`, `span-emit` und `span-report`
(die Zahl wandert mit dem Verzeichnis). Der Bau führt dafür zwei eigene Stufen —
`grep -nE '^FROM .* AS (span|report)$' Dockerfile` → **zwei** Zeilen —, und `make` ein Bau-Ziel,
das eine davon auf den Host holt (`grep -c '^span-emit-build:' Makefile` → **1**). Nach diesem
Slice bleibt **ein** Programm; die Konstruktion wird kleiner, nicht größer.

**Warum das vor der Emission steht und nicht danach.** Die Entscheidung bindet beides aneinander:
*„ohne diesen Nachzug emittierte der Beleg einen Einstiegspunkt, den der Dogfood nie ausführt"*.
Der Einstiegspunkt trägt die zwei Eigenschaften, die
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 6 nicht verhandelbar nennt —
und ein unerprobter Einstiegspunkt ist genau die Stelle, an der eine fail-open-Zusage **still**
bricht: ein Hook, der mit 2 endet, blockt den Tool-Call; ein Hook, der auf stdout schreibt,
entscheidet über Berechtigungen mit, statt zu beobachten. Beides fällt niemandem auf, solange
niemand es mutiert.

**Die Auswertung wechselt dabei vom Container auf den Host.** Sie läuft heute unter `make` im
Container über einem read-only gemounteten Bestand (`sed -n '251,254p' Makefile`). Im Ziel gibt es
keine Bau-Stufe, aus der sie laufen könnte, und ein Adopter soll für einen Bericht keinen Container
starten müssen. Das ist kein Nebeneffekt des Umbaus, sondern eine Festlegung
([`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 2) —
und sie macht einen heute im Bau stehenden Begründungs-Satz eigenständig falsch (DoD 3).

**Was dieser Slice ausdrücklich nicht tut.** Er legt **nichts** ins Ziel — kein Träger, kein
Wrapper, kein Hook-Eintrag, keine Rollen-Typen. Er ändert auch keine Erfassungs-Policy: Schema,
Redaktion, Ablageort und Strom bleiben, was
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) entschieden hat. Er verschiebt einen
**Einstiegspunkt** und sonst nichts.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt — und wo keines existiert,
steht das dabei (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **(1) Schreiber und Auswertung sind Unterkommandos eines Programms, und beide Bau-Stufen
      samt ihrem Bau-Ziel sind fort.** Der Hook dieses Repos ruft den neuen Einstiegspunkt; der
      Emitter läuft weiterhin am Hook auf dem **Host**, mit den Plattform-Schaltern des Baus
      ([`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)) — ohne sie entstünde
      immer ein Linux-ELF und `make gates` scheiterte auf einem macOS-Host.
      **Rot:** `make gates` — `span-check` fährt den Schreiber über eine synthetische Payload
      (`grep -n '^span-check:' -A 1 Makefile`); zeigt eine Prerequisite oder ein Rezept auf einen
      Einstiegspunkt, den es nicht mehr gibt, bricht der Lauf, bevor der Stempel fällt. Dazu ein
      `test/mutations/`-Fall mit `# verify: test-go`, der das Unterkommando-Routing bricht und das
      Rot erwartet.
- [ ] **(2) Die zwei fail-open-Zähne hängen am neuen Einstiegspunkt, nicht am alten.** Klemme
      entfernt ⇒ rot; stdout gebrochen ⇒ rot — auch für die Kindprozesse des Trägers.
      **Rot:** `make mutate`. **Und der Punkt schuldet die Menge, weil der Sensor Adressen misst und
      der Gegenstand Fälle sind:** die Eigenschaft ist *ein Fall unter `test/mutations/`, der eine
      Datei des umgezogenen Bestands mutiert*. Kommando und Zahl, beide mitwandernd:
      `grep -l 'internal/span' test/mutations/*.sh | wc -l` → **25** und
      `grep -l 'internal/report' test/mutations/*.sh | wc -l` → **10**. Ihre **Richtung**: jeder
      dieser Fälle zeigt heute auf einen Pfad, den der Umbau bewegt, und wird nach dem Umzug
      entweder re-verankert oder er läuft ins Leere — ein Fall, der eine Datei mutiert, die es nicht
      mehr gibt, lässt seinen Wächter **nackt** zurück, ohne dass irgendetwas rot wird. Genau diese
      Klasse ist in diesem Repo bereits zweimal real eingetreten und steht als Roadmap-Kandidat
      *Sensor Wächter↔Fall*.
- [ ] **(3) Keine lebende Zeile begründet noch die getrennte Konstruktion oder behauptet eine
      Eigenschaft, die Festlegung 2 aufhebt.** Der Sensor misst die **Adresse** (Datei, Zeile), der
      Gegenstand ist die **Aussage** — die Menge steht darum hier, aufgezählt und mit ihrer
      Richtung. Die Eigenschaft, über die gezählt wird: *eine Zeile in einem lebenden Bau- oder
      Quell-Artefakt, die das eigene Binär gegen ein Unterkommando begründet oder eine Eigenschaft
      der getrennten Konstruktion behauptet.* Suchhilfe, kein Kriterium:
      `grep -rniE 'kein[e]? subkommando|eigenes binary' Dockerfile Makefile cmd/ internal/ harness/`
      → **4** Zeilen in **2** Dateien (mitwandernd).
      **(a)** [`Dockerfile`](../../../../Dockerfile), Emitter-Stufe: *„EIGENE Stage und EIGENES
      Binary, KEIN Subkommando von ai-harness-init: ob der EMITTIERTE Harness einen Emitter bekommt,
      entscheidet …"* — Richtung: die Entscheidung **ist gefallen**, die Begründung verliert ihren
      Gegenstand; zusätzlich nennt sie einen Slice als Entscheidungs-Ort, was ohnehin keine
      haltbare Adressierung ist.
      **(b)** `cmd/span-report/main.go`: *„EIGENES Binary,
      KEIN Subkommando von ai-harness-init"* — dieselbe Richtung, ebenfalls mit einem Slice als
      Entscheidungs-Ort. Die Datei verschwindet mit dem Umbau; der Satz darf nicht in das
      Unterkommando mitwandern.
      **(c)** [`Dockerfile`](../../../../Dockerfile), Auswertungs-Stufe: dieselbe Begründung
      **ohne** Slice-Nennung — der Fundort, den ein Sweep über das Erkennungsmerkmal *„nennt einen
      Slice"* verfehlte.
      **(d)** [`Dockerfile`](../../../../Dockerfile), Auswertungs-Stufe, zweiter Satz: *„anders als
      der Emitter laeuft die Auswertung nicht am Hook auf dem Host, sondern unter `make` IM
      Container"* und *„Ein Host-Binary waere ein Artefakt ohne Leser"* (`sed -n '106,109p'
      Dockerfile`) — Richtung: **eigenständig falsch**, nicht bloß gegenstandslos. Festlegung 2
      schickt die Auswertung auf den Host, und im Ziel bekommt sie genau einen Leser. Diese Zeile
      trägt das Erkennungsmerkmal aus (a)/(b) **nicht** und ist der zweite Fundort, vor dessen
      Verfehlen die Entscheidung ausdrücklich warnt.
      **Rot:** für (b) färbt `make build` rot, sobald das Verzeichnis verschwindet und eine
      Referenz darauf bleibt. Für (a), (c) und (d) färbt **kein Kommando** rot:
      `make comment-claims` liest `internal/**/*.go`, `cmd/**/*.go`, `harness/tools/*.sh` und
      `.claude/hooks/*.sh` (`sed -n '134p' Makefile`) — das `Dockerfile` steht nicht darunter —, und
      der Gate prüft ohnehin, ob ein **genannter Sensor existiert**, nicht ob eine Begründung noch
      gilt. Dieser Punkt ist damit im Sinne von [`AGENTS.md`](../../../../AGENTS.md) §3.6
      **ungelistet**; er wird im Review gelesen, nicht gemessen, und das steht hier statt einer
      Zusage.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · Doku-Update, falls ein
öffentlicher Vertrag berührt ist · Closure-Notiz mit Steering-Loop-Lerneintrag. **Der Doku-Punkt
ist hier nicht leer:**
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Folgepflicht 3
verlangt den Nachzug von
[`spec/spezifikation.md §5`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) —
deren Gegenstands-Satz nennt das Binär, das mit diesem Slice verschwindet.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`cmd/ai-harness-init`](../../../../cmd/ai-harness-init) — zwei Unterkommandos | update | Festlegung 2: ein Träger trägt beide, ohne dass ein zweites Artefakt entsteht |
| `cmd/span-emit` und `cmd/span-report` | refactor | die Klemme und der Bilanz-Einstieg wandern; die Kommentar-Köpfe wandern **nicht** mit (DoD 3) |
| [`Dockerfile`](../../../../Dockerfile) — die Stufen `span` und `report` | refactor | Festlegung 2: die zwei Stufen entfallen. Die Plattform-Schalter der Emitter-Stufe gehören in die verbleibende Stufe, sonst bricht [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) |
| [`Makefile`](../../../../Makefile) — `span-emit-build`, `span-check`, `span-report` | update | das Bau-Ziel verliert seinen Gegenstand; `span-report` verliert seinen Container und läuft auf dem Host |
| [`.claude/settings.json`](../../../../.claude/settings.json) und [`.claude/hooks`](../../../../.claude/hooks) | update | der Hook dieses Repos ruft denselben Einstiegspunkt wie das Ziel — die Sache, die Folgepflicht 1 verlangt |
| `test/mutations/` — die Fälle über `internal/span` und `internal/report` <!-- d-check:ignore (Bestand, wird re-verankert) --> | update | DoD (2): ein Fall, der eine bewegte Datei mutiert, lässt seinen Wächter sonst nackt zurück |
| [`spec/spezifikation.md §5`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) | update | Folgepflicht 3: der Gegenstands-Satz nennt ein Binär, das es nach diesem Slice nicht mehr gibt |

## 4. Trigger

**`open` → `next`:** der Trigger von [welle-12](../welle-12-erfassungsschicht-emittieren.md) ist
erfüllt — er ist es heute (dort §2, mit Kommandos). Dieser Slice wartet auf keinen anderen.
**`next` → `in-progress`:** WIP-Limit frei.

**Rückführungen, vorab benannt.** `in-progress` → `next`, wenn der Umbau eine dritte Schicht
aufreißt — konkret: wenn die Zusammenlegung die Erfassungs-**Policy** berührt statt nur den
Einstiegspunkt (Schema, Redaktion, Ablageort, Strom). Dann ist der Gegenstand kein Umzug mehr,
sondern eine Änderung an [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md), und die
gehört vor den Architect, nicht in diesen Slice. `in-progress` → `open`, wenn der Bau der
verbleibenden Stufe die Plattform-Schalter des Emitters nicht gleichzeitig mit denen des
Produkt-Binärs tragen kann — dann steht eine Bau-Entscheidung aus, die dieser Slice nicht
entscheidet. Beide Bedingungen sind Eigenschaften, keine Adressen.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt mit gefahrenen Kommandos, `make gates` grün, `make mutate` grün mit den
re-verankerten Fällen, `make full-smoke` grün, der Nachzug aus Folgepflicht 3 geschrieben,
Closure-Notiz in §7 mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der teuerste Fehler wäre ein stiller.** Der Emitter ist auf fail-open geklemmt; ein Umzug, der
  ihn kaputt macht, sieht im Betrieb **wie Erfolg aus** — keine Ausgabe, Exit 0, kein Span. Genau
  deshalb hängt DoD (1) an `span-check` (er prüft *vorhanden **und** funktionsfähig*) und nicht am
  bloßen Bau.
- **Ein Bau-Schalter ist leicht zu verlieren.** Die Emitter-Stufe trägt `TARGET_OS`/`TARGET_ARCH`,
  weil der Emitter am Hook auf dem **Host** läuft; die Auswertungs-Stufe trägt sie ausdrücklich
  nicht, weil sie im Container lief. Nach der Zusammenlegung läuft **beides** auf dem Host — die
  Schalter dürfen nicht der Auswertungs-Regel folgen. Ein `exec format error` auf macOS ist hier
  schon einmal als Review-Befund aufgetreten.
- **Der Bestand an Mutations-Fällen ist der Hauptaufwand, nicht der Umbau.** 25 plus 10 Fälle
  (DoD 2, mit Kommandos) zeigen auf Pfade, die sich bewegen. Wer sie pauschal per Suchen-Ersetzen
  zieht, riskiert einen Fall, der zwar läuft, aber nichts mehr trifft — er wäre grün und leer. Die
  Gegenprobe ist der Zahnlos-Lauf: den Wächter entfernen, der Fall muss melden.
- **`make mutate` ist teuer.** Der Standard-Lauf liegt in der Größenordnung von
  `MUTATE_SECONDS=1128.69` (aus dem Protokoll von `slice-093`, fremdbelegt und als solche
  ausgewiesen). Wer nur die betroffenen Fälle fährt, sieht die Re-Verankerung, nicht die
  Rückwirkung auf den Rest.
- **Offen und nicht in diesem Slice:** ob der zusammengelegte Einstiegspunkt die Schwelle aus
  [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) hält. Das misst
  [slice-095](../open/slice-095-hook-aufschlag-gemessen.md); fällt die Messung negativ aus, ist die Antwort
  Alternative F — ein getrennter Einstiegspunkt —, und dieser Slice wird teilweise rückgebaut. Das
  ist der bewusst gewählte Preis dafür, dass die Messung erst nach dem Umbau möglich ist: gemessen
  werden kann nur, was läuft.

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

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `cmd/`, `internal/`,
`test/`, der Bau (`Dockerfile`/`Makefile`) und `.claude/` gehören zum Greenfield-Bestand; der Modus
steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
