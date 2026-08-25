# Slice slice-098: Die Feldliste im Ziel ist der Ausdruck des Trägers und führt ihre Grenzen stehend

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-12](../welle-12-erfassungsschicht-emittieren.md) — er läuft nach
[slice-096](../in-progress/slice-096-traeger-liegt-im-ziel.md), weil das Dokument **aus** dem Träger erzeugt wird
und seinen Emissions-Zweig teilt. Er hängt **nicht** an
[slice-099](slice-099-leser-und-aufraeum-kommando.md).

**Bezug:**
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (§Redaktion:
*„Erfasst wird ausschließlich, was in einer geschlossenen, im Zielrepo lesbaren Feldliste steht"*,
samt der ausgesprochenen Nicht-Zusage über Pfadnamen und den Bestand; und §Benannte Grenze, deren
stehender Ort dieses Dokument ist),
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (**Accepted** —
Festlegung 7 wählt den Zielort und die Erzeugungsart, Festlegung 6 Stück 1 und 3 nennen die zwei
Stücke, die jene Quelle offenließ, Festlegung 8 den zweiten Grenz-Satz; Festlegung 5(a) ordnet das
Dokument dem Zweig des Trägers zu),
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) (**Accepted** — *das Gefäß folgt dem
Gegenstand*; ihr Re-Evaluierungs-Trigger stellt die Frage nach dem Zielort der Feldtabelle im
Zielrepo, und Festlegung 7 der obigen Entscheidung beantwortet sie mit **Nein**: nicht ins
Technik-Stratum des Adopters),
[`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) (**Accepted** — ihre
Folgepflicht 6 verlangt, dass die Grenze im Ziel *„genannt, nicht stillschweigend mitgeliefert"*
wird; dieses Dokument ist ihr **stehender** Ort, der auch dann trägt, wenn niemand die Auswertung
ruft),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted** — ihre Festlegung 2 legt
die Redaktion zur Erfassungs-Zeit fest: von Argument-Werten wandert eine **Ableitung**, nie der
Inhalt; die Feldliste ist die lesbare Fassung davon),
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) (die
Konstruktion, die Festlegung 7 übernimmt: tool-generiert, **verbatim** ins Ziel),
[`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
(die Präzedenz auf **unserer** Ebene: das Span-Schema lebt im Technik-Stratum dieses Repos — im
Ziel gibt es kein Stratum, das uns gehört, und genau daraus folgt der andere Ort).

**Autor:** Planner. **Datum:** 2026-08-25.

---

## 1. Ziel

**Das gebootstrappte Zielrepo führt im geprüften Bereich seiner Doku ein tool-erzeugtes Dokument,
das byte-gleich mit dem ist, was der Träger über sein eigenes Schema ausgibt — und das die Grenzen
stehend nennt, die kein Sensor hält.**

**Warum aus dem Träger erzeugt und nicht von Hand gepflegt.** Damit ist Drift zwischen **erfasstem**
und **dokumentiertem** Feld **konstruktiv** ausgeschlossen statt per Regel verboten: ein Feld, das
erfasst wird und dort fehlt, kann es nicht geben, weil beide aus derselben Quelle kommen. Dieselbe
Konstruktion trägt schon das Doc-Gate-Fragment verbatim ins Ziel
([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)).

**Warum in den geprüften Doku-Bereich und nicht unter `.harness/**` und nicht ins Technik-Stratum
des Adopters.** Der Baum unter `.harness/**` ist derivativer, nicht repo-autoritativer Inhalt, und
die emittierte `.d-check.yml` nimmt ihn aus. Die Feldliste dagegen ist eine **Aussage an den
Adopter** — sie gehört dorthin, wo sein Doku-Gate sie liest. Das Technik-Stratum wiederum ist
`skip-if-present` und gehört ihm: eine Tabelle, die wir dort hineinschrieben, könnte ein Re-Lauf
nie nachziehen und driftete mit der ersten Schema-Änderung. Der Zielort ist stattdessen ein
**tool-eigenes, konvergentes** Dokument.

**Die zwei Grenz-Sätze sind der zweite Gegenstand, nicht ein Anhang.** Das Dokument nennt (i), dass
die emittierte Ebene **keinen Wächter über die Aufrufform des Agenten-Werkzeugs** führt — die
Rollen-Achse ruht dort auf Adopter-Disziplin —, und (ii), dass die **Verbrauchs-Zähler aus der
Mechanik des Agenten-Werkzeugs nicht kommen** und kein Lauf des Adopters sie herbeiführt. Beide
gehören hierher, **weil sie auch dann gelten, wenn niemand die Auswertung ruft**. Eine
Abdeckungs-Zeile im Bericht meldet einen **Zustand**; erst der stehende Satz nennt die **Grenze**.

**Ein dritter Satz gehört fachlich dazu, und sein Ort ist hier gewählt, nicht vorgefunden.**
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) §Redaktion sagt
ausdrücklich, **nicht** zugesagt sei, dass Pfadnamen unkritisch sind und dass der Bestand geschützt
ist — er ist gitignored, nicht verschlüsselt, nicht zugriffsbeschränkt.
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) verlangt diesen
Satz (Festlegung 6 Stück 3: *„Im Ziel wird daraus ein **geschriebener** Satz"*), benennt ihm aber
**keinen** stehenden Ort. Dieser Slice wählt ihn: dasselbe Dokument, das die Feldliste führt, denn
die Nicht-Zusage ist die Kehrseite genau dieser Liste — wer liest, *was* erfasst wird, muss dort
lesen, *wie wenig* darüber zugesagt ist. Die Wahl ist eine Plan-Entscheidung und steht als solche
hier.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **(1) Das emittierte Dokument ist byte-gleich mit dem, was der Träger über sein eigenes
      Schema ausgibt.** Ein Feld, das erfasst wird und dort fehlt, färbt rot; ein Eintrag, den der
      Träger nicht erfasst, ebenso. Damit ist die Drift konstruktiv ausgeschlossen statt per Regel
      verboten.
      **Rot:** `make test` — ein Go-Wächter hält das emittierte Dokument gegen die Schema-Ausgabe
      des Trägers; dazu ein `test/mutations/`-Fall mit `# verify: test-go`, der ein Pflichtfeld
      erfasst, ohne den Ausdruck nachzuziehen, und das Rot erwartet. Ein Sensor darüber existiert
      heute nicht (`grep -rln 'Feldliste' internal/emit/*.go` → leer, Exit 1).
- [ ] **(2) Das Dokument führt seine drei Sätze stehend — fehlt einer, färbt es rot.**
      **Der Sensor misst die Adresse (eine Datei), der Gegenstand sind Aussagen — darum die
      Aussagen-Menge, aufgezählt und mit ihrer Richtung.** Die Eigenschaft: *ein Satz, der eine
      Grenze der emittierten Ebene nennt, die kein Sensor hält und die auch ohne Aufruf der
      Auswertung gilt.*
      **(a)** Die emittierte Ebene führt **keinen** Wächter über die Aufrufform des
      Agenten-Werkzeugs — Richtung: die Rollen-Achse ruht dort auf **Adopter-Disziplin**; benennt
      er seine Typen um, bleibt `agent.role` leer, und leer heißt *unbekannt*, nie *rollenlos*.
      Quelle: [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
      Festlegung 7 nennt ihn als geschuldet.
      **(b)** Die **Verbrauchs-Zähler kommen aus der Mechanik des Agenten-Werkzeugs nicht** —
      Richtung: das ist keine Eigenschaft unseres Aufbaus, und **kein Lauf des Adopters** führt sie
      herbei. Quelle: [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md)
      Folgepflicht 6, hier eingelöst statt weitergereicht.
      **(c)** Über den **Bestand** ist nichts zugesagt — Richtung: er ist gitignored, **nicht**
      verschlüsselt und **nicht** zugriffsbeschränkt, und Pfadnamen sind **nicht** als unkritisch
      zugesagt. Quelle:
      [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)
      §Redaktion und
      [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 6
      Stück 3 — **ohne** benannten stehenden Ort; dieser Slice wählt ihn (§1).
      **Rot:** `make test` und `make mutate` — ein Go-Wächter je Satz; der `test/mutations/`-Fall
      (`# verify: test-go`) nimmt einen heraus und erwartet das Rot.
- [ ] **(3) Das Dokument teilt den Zweig des Trägers und liegt im geprüften Bereich der
      Ziel-Doku.** Es entsteht mit dem Träger; scheitert dessen Ablage, entsteht es **nicht** — ein
      unbedingt formulierter Wächter fiele im Zweig aus Festlegung 5(a) und stünde gegen die Zusage
      aus [slice-096](../in-progress/slice-096-traeger-liegt-im-ziel.md) DoD (2). Es liegt **nicht** unter
      `.harness/**`, das die emittierte `.d-check.yml` ausnimmt, sondern dort, wo das Doku-Gate des
      Ziels es liest — und es hält dieses Gate.
      **Rot:** `make full-smoke` über beide Bootstrap-Varianten — das gebootstrappte Ziel fährt sein
      **eigenes** `make gates` über dem Dokument, und der Fehlerzweig zeigt seine Abwesenheit. Dazu
      ein `test/mutations/`-Fall mit `# verify: full-smoke`; der Treiber führt den Modus
      (`sed -n '/^failure_form()/,/^}/p' harness/tools/mutate.sh | grep -cE '^[[:space:]]+[a-z*-]+\)'`
      → **7** Arme, mitwandernd).

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · Doku-Update, falls ein
öffentlicher Vertrag berührt ist · Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`internal/span`](../../../../internal/span) — eine Ausgabe des eigenen Schemas | neu | Festlegung 7: das Dokument wird **aus dem Träger erzeugt**, nicht von Hand gepflegt; nur so ist Drift konstruktiv ausgeschlossen |
| [`internal/emit`](../../../../internal/emit) — Ablage des erzeugten Dokuments im geprüften Doku-Bereich des Ziels, im Zweig des Trägers | neu | Festlegung 7 und 5(a); Muster [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert): tool-generiert, verbatim, konvergent |
| [`internal/emit`](../../../../internal/emit) — Go-Wächter: Ausdruck ↔ Dokument, die drei Sätze, der bedingte Anwesenheits-Wächter | neu | DoD (1)–(3); ein Sensor über der Feldliste existiert heute nicht (`grep -rln 'Feldliste' internal/emit/*.go` → leer, Exit 1) |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | update | DoD (3): das eigene `make gates` des Ziels über dem Dokument, beide Varianten, beide Zweige |
| `test/mutations/` — je ein Fall für DoD (1), (2) und (3) <!-- d-check:ignore (geplante Dateien) --> | neu | [`AGENTS.md`](../../../../AGENTS.md) §3.6: wer keinen Fall hat, gilt als unbewacht |

## 4. Trigger

**`open` → `next`:** [slice-096](../in-progress/slice-096-traeger-liegt-im-ziel.md) liegt in `done/` — erst dann
gibt es einen Träger, aus dem das Dokument erzeugt wird, und einen Zweig, den es teilen kann.
Beobachtbar ohne Rückfrage: die Plan-Datei liegt in `done/`. **`next` → `in-progress`:** WIP-Limit
frei. **Nicht Trigger:** [slice-099](slice-099-leser-und-aufraeum-kommando.md) — die beiden hängen
nicht aneinander und dürfen parallel laufen.

**Rückführungen, vorab benannt.** `in-progress` → `next`, wenn das Dokument mehr trägt als Feldliste
und Grenz-Sätze — etwa eine Betriebsanleitung; dann ist es zwei Gegenstände in einer Datei und
zerfällt nach Leser, nicht nach Abschnitt. `in-progress` → `open`, wenn der geprüfte Doku-Bereich
des Ziels das Dokument nicht aufnehmen kann, ohne das Gate eines frischen Ziels rot zu färben —
dann steht eine Entscheidung über den Zielort aus, und die gehört vor den Architect. Beide
Bedingungen sind Eigenschaften, keine Adressen.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt mit gefahrenen Kommandos, `make gates` grün, `make full-smoke` grün über beide
Varianten und beide Zweige, `make mutate` grün mit den neuen Fällen, Closure-Notiz in §7 mit
Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Byte-Gleichheit ist eine harte Zusage und bricht leicht aus dem falschen Grund.** Zeilenenden,
  abschließende Leerzeilen und die Sortierung der Felder gehören zur Gleichheit. Wer den Vergleich
  auf „enthält alle Felder" abschwächt, hat den konstruktiven Ausschluss der Drift wieder auf eine
  Regel zurückgestuft — genau das, was Festlegung 7 vermeiden wollte.
- **Der dritte Grenz-Satz hat keinen Rückhalt in der Entscheidung, nur in der Anforderung.** Sätze
  (a) und (b) benennt
  [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 7 als
  stehend; Satz (c) verlangt Festlegung 6 Stück 3 als *geschrieben*, **ohne** Ort. Die Wahl dieses
  Dokuments ist eine Plan-Entscheidung (§1) und kein Zitat. Wer sie umstößt, schuldet einen anderen
  stehenden Ort — nicht das Streichen des Satzes, denn
  [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) verlangt ihn
  auf Rang 1.
- **Bewacht ist die Anwesenheit der Sätze, nicht ihre Wahrheit.** Ein Wächter über einem Satz prüft,
  dass er dasteht; ob die emittierte Ebene wirklich keinen Agent-Guard führt, prüft er nicht. Diese
  Richtung bleibt offen und ist es bewusst — ein Sensor darüber wäre einer über einem fremden
  Vertrag.
- **Das Dokument liegt im geprüften Bereich und wird damit zum Gate-Gegenstand des Adopters.** Ein
  toter Verweis darin färbt sein `make gates` rot, und er kann ihn nicht heilen: das Dokument ist
  **konvergent**, ein Re-Lauf setzt es zurück. Es darf darum keine relativen Verweise tragen, die
  nur in diesem Repo aufgehen — dieselbe Falle wie bei den Rollen-Typen
  ([slice-097](slice-097-rollen-typen-gehen-mit.md) DoD 3), hier aber schärfer, weil die
  `skip-if-present`-Ausweichmöglichkeit fehlt.
- **Ein frischer Klon hat den Träger nicht, aber das Dokument schon.** Es ist committet, er ist
  gitignored. Der Leser findet dann eine Feldliste über einer Erfassung, die gerade nicht läuft —
  das ist **richtig** (die Liste sagt, was erfasst *würde*), aber es ist erklärungsbedürftig, und
  die Erklärung gehört in dasselbe Dokument.

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

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `internal/span/`,
`internal/emit/`, `harness/tools/` und `test/` gehören zum Greenfield-Bestand; der Modus steht in
der Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
