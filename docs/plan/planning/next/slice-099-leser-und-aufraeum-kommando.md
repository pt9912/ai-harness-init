# Slice slice-099: Der Leser nennt seine Abdeckung zuerst, und der Bestand hat ein Aufräum-Kommando

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-12](../welle-12-erfassungsschicht-emittieren.md) — er läuft nach
[slice-096](../done/slice-096-traeger-liegt-im-ziel.md), weil das Fragment auf den Träger zeigt und der
Leser dessen Bestand liest. Er hängt **nicht** an
[slice-098](../done/slice-098-feldliste-ist-ausdruck-des-traegers.md).

**Bezug:**
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (§Leser:
*„Emittiert werden **Schreiber und Auswertung**. Die Auswertung nennt ihre **Abdeckung zuerst** und
meldet damit ihre eigene Leere"*; und §Aufbewahrung: ein ausdrückliches Aufräum-Kommando, **ohne**
automatische Rotation, samt dem Satz über unbegrenztes Wachstum),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (der
Grund, warum die Auswertung im Ziel **nicht verdrahtet** wird: ein Gate über ihr wäre eines über
leerem Prüfbereich — sie prüft nichts, sie rechnet),
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (**Accepted** —
Festlegung 8 *„emittiert wird der **Leser**, nicht die **Zahl**"*, Festlegung 6 Stück 2 macht das
Aufräum-Kommando vom Betriebsgewohnheit zur **Zusage**, Festlegung 4 gibt dem Fragment seine
Idempotenz-Klasse),
[`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) (**Accepted** — das
**Zähler-Glied** bleibt verschlossen und wird hier **nicht** revidiert; ihre Folgepflicht 6
verlangt, dass die Grenze im Ziel genannt wird, und dieser Slice liefert dafür den **laufenden**
der zwei Orte),
[`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) (**Accepted** — *„Jede Token-Bilanz
aus diesen Spans ist eine Bilanz über SUBAGENTEN-Läufe und nennt ihren Nenner"*; die Präzedenz, auf
der die emittierte Auswertung steht),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted** — ihre Festlegung 3 nennt
für den Dogfood *„ein `make`-Ziel, kein Automatismus"*; im Ziel wird daraus eine Zusage),
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) (das
Muster für ein tool-generiertes Gate-Fragment im Ziel).

**Autor:** Planner. **Datum:** 2026-08-25.

---

## 1. Ziel

**Das gebootstrappte Zielrepo bekommt einen Leser, der seine Abdeckung zuerst nennt und über einem
Bestand ohne Verbrauchs-Zähler seine Leere samt ihrem Grund meldet — und ein ausdrückliches
Aufräum-Kommando, dessen Nicht-Aufruf das Repo selbst benennt.**

**Emittiert wird der Leser, nicht die Zahl — und das ist kein Rückzug.** Das Zähler-Glied ist
verschlossen: die Verbrauchs-Zähler kommen aus der **Mechanik des Agenten-Werkzeugs** nicht, und
kein Aufwand dieses Repos oder eines Adopters bringt sie herbei. Ein Bericht, der über leerem
Bestand eine Bilanz behauptete, wäre die Gate-Lüge als Kennzahl; ein Bericht, der seinen **Nenner**
und seine **Abdeckung** nennt, ist das Gegenteil — genau die Form, die
[`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) für den Dogfood erzwungen hat.

**Leere melden reicht nicht, der Grund gehört dazu.** Eine Abdeckungs-Zeile über einem Bestand ohne
Zähler meldet einen **Zustand** und lässt offen, ob er morgen anders ist. Die Grenze ist eine
andere Aussage: dass die Zähler an der Mechanik hängen und kein Lauf des Adopters sie herbeiführt.
Sie steht darum an **zwei** Orten — hier beim Leser, der sie dort nennt, wo er seine Leere meldet,
und stehend im Feldlisten-Dokument
([slice-098](../done/slice-098-feldliste-ist-ausdruck-des-traegers.md)), das auch dann trägt, wenn niemand
den Leser ruft.

**Das Aufräum-Kommando ist eine Zusage mit ausgesprochener Nicht-Zusage.** Das Ziel bekommt das
Kommando **und** den Satz, dass sein Bestand ohne dessen Aufruf unbegrenzt wächst. Eine
**automatische Rotation ist nicht Teil der Zusage** — *„ein Löschpfad in einem fail-open-Hook über
fremden Daten wäre der teurere Fehlerfall"*. Die Präzedenz steht in diesem Repo bereits als
`span-clean`, ausdrücklich als *„kein Automatismus"* geführt
(`grep -n '^span-clean:' Makefile`).

**Und die Auswertung wird im Ziel nicht verdrahtet.** Sie prüft nichts und färbt nichts rot; ein
Gate über ihr wäre eines über leerem Prüfbereich. Das Ziel bekommt das **Kommando**, nicht die
Aufhängung — dieselbe Einordnung, die dieses Repo für seinen eigenen Bericht schon trifft
(`grep -n 'span-report' Makefile` nennt ihn *„NICHT in gates (Bericht, kein Sensor)"*).

**Warum Leser und Aufräum-Kommando ein Slice sind.** Sie sind **ein** Artefakt: die
Idempotenz-Tabelle der Entscheidung führt *„das **Aufräum- und Berichts**-Fragment im
Gate-Fragment-Verzeichnis des Ziels"* als eine Zeile, eine Klasse, ein Muster
([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)). Zwei
Slices erzeugten zwei Fragmente an derselben Adresse.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **(1) Die Auswertung meldet ihre Leere — und nennt die Grenze, nicht nur den Zustand.** Über
      einem Bestand ohne Verbrauchs-Zähler nennt sie ihre **Abdeckung zuerst**, weist **keine**
      Bilanz aus und sagt, dass die Zähler an der Mechanik des Agenten-Werkzeugs hängen. Eine
      Ausgabe, die über leerem Bestand eine Zahl trägt, ist der Befund — und ebenso eine, die die
      Leere **ohne ihren Grund** meldet.
      **Rot zu sehen ist:** den Grund-Satz aus der Ausgabe nehmen, dann muss der Wächter fallen.
      Ohne dieses Rot ist die Einlösung von
      [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Folgepflicht 6 eine
      Absicht ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
      **Rot:** `make full-smoke` — der Leser läuft im gebootstrappten Ziel über dessen eigenem
      Bestand; dazu ein `test/mutations/`-Fall mit `# verify: full-smoke`. Der Treiber führt den
      Modus (`sed -n '/^failure_form()/,/^}/p' harness/tools/mutate.sh | grep -cE
      '^[[:space:]]+[a-z*-]+\)'` → **7** Arme, mitwandernd).
- [ ] **(2) Das Aufräum-Kommando liegt im Ziel als Kommando ohne Automatik, und das Ziel sagt, was
      es nicht zusagt.** Ein ausdrückliches Ziel entfernt den Bestand; **kein** Pfad im Hook und
      **kein** Gate ruft es. Daneben steht geschrieben, dass der Bestand ohne diesen Aufruf
      **unbegrenzt wächst**.
      **Rot:** `make test` — ein Go-Wächter über dem emittierten Fragment (Ziel vorhanden, Satz
      vorhanden) und über der Abwesenheit jedes automatischen Aufrufers; dazu ein
      `test/mutations/`-Fall mit `# verify: test-go`, der das Ziel in eine Prerequisite-Kette hängt
      und das Rot erwartet. **Das Gegenbeispiel ist hier die Automatik, nicht das Fehlen** — ein
      Löschpfad, der von selbst läuft, ist genau der teurere Fehlerfall, den die Anforderung
      ausschließt.
- [ ] **(3) Die Auswertung ist im Ziel nicht verdrahtet: kein emittiertes Gate hängt an ihr.**
      **Der Sensor misst Adressen (Prerequisite-Ketten), der Gegenstand ist die Aussage *„das ist
      kein Sensor"* — darum die Aussagen-Menge, aufgezählt und mit ihrer Richtung.** Die
      Eigenschaft: *ein Ort im emittierten Bestand, an dem ein Berichts- oder Aufräum-Ziel zu einem
      Prüf-Versprechen würde.* **(a)** die Prerequisite-Kette des emittierten `gates`-Ziels —
      Richtung: erscheint dort eines der beiden Ziele, ist es ein Gate über leerem Prüfbereich.
      **(b)** die Hook-Konfiguration des Ziels — Richtung: ein Bericht im Hook-Pfad macht aus einem
      Leser einen Blockierer und bricht die fail-open-Klemme. **(c)** die emittierten Gate-Tabellen
      der Ziel-Doku — Richtung: ein Eintrag dort **behauptet** einen Sensor; das Ziel führt eine
      Zeile, die ausdrücklich *kein Gate* sagt, oder gar keine. Das Präfix des
      Gate-Fragment-Verzeichnisses ist die Adresse; seine Konstanten liegen in
      [`internal/emit`](../../../../internal/emit)
      (`grep -rhoE '"harness/mk/[^" ]+' --include=*.go internal/ | sort -u | wc -l` → **5**,
      mitwandernd).
      **Rot:** `make test` plus ein `test/mutations/`-Fall mit `# verify: test-go` je Richtung, der
      die Verdrahtung herstellt und das Rot erwartet.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · Doku-Update, falls ein
öffentlicher Vertrag berührt ist · Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`internal/report`](../../../../internal/report) — die Abdeckungs-Zeile zuerst, der Grund-Satz bei Leere | update | Festlegung 8: der Leser nennt seine Abdeckung und den **Grund** seiner Leere, nicht nur den Zustand |
| [`internal/emit`](../../../../internal/emit) — das Aufräum- und Berichts-Fragment im Gate-Fragment-Verzeichnis des Ziels | neu | Festlegung 4 und 6 Stück 2; Muster [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert): tool-generiert, verbatim, konvergent |
| [`internal/emit`](../../../../internal/emit) — Go-Wächter: Fragment-Inhalt, Nicht-Verdrahtung, Nicht-Zusage-Satz | neu | DoD (2) und (3), in der Stufe, die `make mutate` erreicht |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | update | DoD (1): der Leser läuft im Ziel über dessen eigenem Bestand, beide Bootstrap-Varianten |
| `test/mutations/` — Fälle für DoD (1), (2) und (3) <!-- d-check:ignore (geplante Dateien) --> | neu | [`AGENTS.md`](../../../../AGENTS.md) §3.6: wer keinen Fall hat, gilt als unbewacht |

## 4. Trigger

**`open` → `next`:** [slice-096](../done/slice-096-traeger-liegt-im-ziel.md) liegt in `done/` — erst dann
gibt es im Ziel einen Träger, auf den das Fragment zeigt, und einen Bestand, den der Leser liest.
Beobachtbar ohne Rückfrage: die Plan-Datei liegt in `done/`. **`next` → `in-progress`:** WIP-Limit
frei. **Nicht Trigger:** [slice-098](../done/slice-098-feldliste-ist-ausdruck-des-traegers.md) — die beiden
hängen nicht aneinander und dürfen parallel laufen.

**Rückführungen, vorab benannt.** `in-progress` → `next`, wenn der Leser über die Abdeckungs-Aussage
hinaus zu rechnen beginnt — dann trägt er eine Bilanz, die
[`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) ausschließt, und der Slice ist
nach *Aussage* gegen *Rechnung* neu zu schneiden. `in-progress` → `open`, wenn das
Gate-Fragment-Verzeichnis des Ziels ein Ziel nicht aufnehmen kann, ohne in eine bestehende
Prerequisite-Kette zu geraten — dann steht eine Entscheidung über die Fragment-Aufhängung aus.
Beide Bedingungen sind Eigenschaften, keine Adressen.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt mit gefahrenen Kommandos, `make gates` grün, `make full-smoke` grün über beide
Varianten, `make mutate` grün mit den neuen Fällen, Closure-Notiz in §7 mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der Leser sagt einem Adopter etwas, das wie ein Mangel klingt.** *„Keine Verbrauchs-Zähler im
  Bestand"* liest sich als kaputte Erfassung, ist aber eine Aussage über einen **fremden Vertrag**.
  Der Grund-Satz aus DoD (1) trägt genau diese Unterscheidung; wird er weichgespült, entsteht
  entweder eine Entschuldigung oder eine Anklage — beides falsch.
- **Ein leerer Bestand und eine Erfassung, die nicht läuft, sehen beim Leser gleich aus.** Ein
  frischer Klon hat den Träger nicht (der Preis aus
  [slice-096](../done/slice-096-traeger-liegt-im-ziel.md) §6), und der Leser meldet dann dieselbe Leere wie
  bei einem Repo, das nur noch nichts getan hat. Das ist die Stelle, an der *„der Verlust wird beim
  LESER sichtbar"* seine Grenze hat — die Abdeckungs-Zeile sollte beide Fälle unterscheiden, und
  ob sie es kann, entscheidet der Implementer am Bestand, nicht dieser Plan.
- **Die Nicht-Verdrahtung ist eine Abwesenheits-Zusage und darum leicht falsch zu bewachen.** Ein
  Wächter über *„erscheint nicht in dieser Kette"* muss die Kette **des Ziels** lesen, nicht die
  dieses Repos; misst er die falsche, ist er dauerhaft grün. Die Adresse ist das Präfix des
  Gate-Fragment-Verzeichnisses samt Bestand, nie ein geratener Ziel-Name.
- **Ein Aufräum-Kommando löscht fremde Daten.** Es entfernt den Bestand eines Adopters, und ein
  Fehler darin ist unumkehrbar. Der Prüfbereich gehört eng gefasst; ein Ziel, das mehr entfernt als
  den Span-Bestand, ist ein Befund, kein Komfort.
- **Der Bestand wächst unbegrenzt, und das bleibt so.** Der Slice sagt es, er ändert es nicht. Wer
  eine Rotation nachrüsten will, stößt
  [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) §Aufbewahrung
  um — das ist ein Change Request, kein Slice.
- **Berührung mit [slice-092](slice-092-traeger-inventur.md), falls jener zuerst liegt.** Seine
  Zellen für Modul 15 §Token-Attribution und §Cache-Counter nennen als Adresse das
  Gate-Fragment-Verzeichnis des Ziels; sobald dieser Slice dort ablegt, färbt sein Wächter rot —
  **gewollt**, denn genau dann sind die Zellen zu ziehen.

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

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `internal/report/`,
`internal/emit/`, `harness/tools/` und `test/` gehören zum Greenfield-Bestand; der Modus steht in
der Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
