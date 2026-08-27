# Slice slice-099: Der Leser nennt seine Abdeckung zuerst, und der Bestand hat ein Aufräum-Kommando

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-12](welle-12-erfassungsschicht-emittieren.md) — er läuft nach
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

- [x] **(1) Die Auswertung meldet ihre Leere — und nennt die Grenze, nicht nur den Zustand.** Über
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
- [x] **(2) Das Aufräum-Kommando liegt im Ziel als Kommando ohne Automatik, und das Ziel sagt, was
      es nicht zusagt.** Ein ausdrückliches Ziel entfernt den Bestand; **kein** Pfad im Hook und
      **kein** Gate ruft es. Daneben steht geschrieben, dass der Bestand ohne diesen Aufruf
      **unbegrenzt wächst**.
      **Rot:** `make test` — ein Go-Wächter über dem emittierten Fragment (Ziel vorhanden, Satz
      vorhanden) und über der Abwesenheit jedes automatischen Aufrufers; dazu ein
      `test/mutations/`-Fall mit `# verify: test-go`, der das Ziel in eine Prerequisite-Kette hängt
      und das Rot erwartet. **Das Gegenbeispiel ist hier die Automatik, nicht das Fehlen** — ein
      Löschpfad, der von selbst läuft, ist genau der teurere Fehlerfall, den die Anforderung
      ausschließt.
- [x] **(3) Die Auswertung ist im Ziel nicht verdrahtet: kein emittiertes Gate hängt an ihr.**
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
- **Berührung mit [slice-092](../open/slice-092-traeger-inventur.md), falls jener zuerst liegt.** Seine
  Zellen für Modul 15 §Token-Attribution und §Cache-Counter nennen als Adresse das
  Gate-Fragment-Verzeichnis des Ziels; sobald dieser Slice dort ablegt, färbt sein Wächter rot —
  **gewollt**, denn genau dann sind die Zellen zu ziehen.

## 7. Closure-Notiz (nach `done/`)

**Was gilt.** Ein frisch gebootstrapptes Zielrepo führt zwei `make`-Ziele — eines, das den
Span-Bestand liest und dabei **zuerst** seine Abdeckung nennt, und eines, das ihn ausdrücklich
entfernt. Beide stehen in einem tool-erzeugten Fragment, das **unbedingt** abgelegt wird, auch wenn
die Platzierung des Trägers scheitert; an keinem von beiden hängt ein Gate des Ziels. Umgesetzt in
`8d77b91` (`git show 8d77b91 --stat --format= | tail -1` → **25 files changed, 1308
insertions(+), 38 deletions(-)**), davon **14** neue Mutations-Fälle
(`git show --pretty=format: --name-only 8d77b91 | grep -c '^test/mutations/1[78]'` → **14**). Alle
Zahlen wandern mit ihrem Bestand und sind **kein** Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Der Closure-Trigger aus §5, Kriterium für Kriterium.**

1. **DoD (1)–(3) erfüllt, mit gefahrenen Kommandos.** Bestätigt in der
   [Verifikation](../../../reviews/2026-08-26-slice-099-verify.md) §2.1–§2.3 (**fremdbelegt**):
   die Kette des Ziels aus `make -qp` in beiden Bootstrap-Varianten, drei hergestellte
   Bestandszustände an einem stehenden Probe-Ziel und acht eigene Rot-Sonden. Urteil dort:
   **ERFÜLLT · ERFÜLLT · ERFÜLLT**, kein Punkt auf einer Behauptung.
2. **`make gates` grün** — **fremdbelegt** (Verifikation L4, **EXIT=0**, 34,26 s; Nachtrag über dem
   Berichts-Baum **EXIT=0**, 45,49 s). Der eigene Lauf über dem Baum, den diese Closure
   hinterlässt, steht unten.
3. **`make full-smoke` grün über beide Varianten** — **fremdbelegt** (L2/L3, **EXIT=0** in
   **88,39 s** und **82,92 s**; `grep 'Leser + Aufraeum-Kommando'` liefert zwei Zeilen, `(golang)`
   und `(sprachlos)`).
4. **`make mutate` grün mit den neuen Fällen** — **fremdbelegt** (L1: `mutate: 179 ok, 0
   Befund(e)`, **1326,26 s**). Der gemessene Bestand **ist** der geschlossene:
   `ls test/mutations/*.sh | wc -l` → **179**, identisch mit der Zahl des Laufs. Das ist der achte
   Posten von [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md), hier zum ersten
   Mal ausdrücklich geprüft statt unterstellt.
5. **Review (Modul 10).** [Bericht](../../../reviews/2026-08-26-slice-099-review.md):
   `grep -c '^### F-' docs/reviews/2026-08-26-slice-099-review.md` → **6** (1 HIGH, 3 MEDIUM,
   2 LOW). **F-1, F-2, F-4 und F-6 sind behoben**; F-3 und F-5 blieben bewusst offen und tragen
   unten ihren Ausgang.
6. **Verifikation (Modul 11).** [Bericht](../../../reviews/2026-08-26-slice-099-verify.md):
   `grep -c '^### V-' docs/reviews/2026-08-26-slice-099-verify.md` → **13**, davon
   `grep -c '^### V-.*(MEDIUM)'` → **3**, keiner blockierend.
7. **Closure-Notiz mit Steering-Loop-Eintrag.** Diese Notiz; der Eintrag steht unten.

**Zwei Plan-vs-Code-Deltas — und das zweite ist keines.**

- **(1) Fünf Dateien stehen im Diff und in keiner Zeile von §3.**
  `git show --pretty=format: --name-only 8d77b91 | grep -E 'templates\.go|emitteddocs_test\.go|enforce_test\.go|enforce\.go|142-'`
  → [`internal/emit/enforce.go`](../../../../internal/emit),
  [`internal/emit/templates.go`](../../../../internal/emit), `internal/emit/emitteddocs_test.go`,
  `internal/emit/enforce_test.go` und `test/mutations/142-report-abdeckung-entfernt.sh`.
  **Eine davon ist implizit gedeckt:** `enforce.go` ist der Wirt des Fragments — ein Fragment
  entsteht nicht ohne den Ort, der es schreibt. **Vier sind es nicht**, und eine davon ist ein
  realer Umbau: `initFragments()` wechselt von `[]string` auf `map[string]string` und bekommt eine
  neue exportierte Fassung, weil der Nicht-Verdrahtungs-Wächter die Ziel-Quellen **mit ihren
  Namen** lesen muss. `142-…sh` ist ein **Update** an einem bestehenden Fall, während §3
  `test/mutations/` als *neu* führt.
  **Dies ist die dritte Beobachtung dieser Klasse in Folge**
  ([slice-097](../done/slice-097-rollen-typen-gehen-mit.md) sauber ·
  [slice-098](../done/slice-098-feldliste-ist-ausdruck-des-traegers.md) einmal, eine Datei ·
  dieser Slice erneut, fünf Dateien), und damit ist sie kein Einzelbefund mehr: Modul 10
  §Ziel-Form verlangt *„bei dreimaligem gleichem Finding Klassifikation schärfen / Folge-ADR bzw.
  `AGENTS.md`-Update / Gate"*
  (`grep -n 'dreimaligem gleichem Finding' .harness/baseline/v3.5.2/regelwerk/modul-10-review-harness.md`).
  **Sie hat deshalb ab hier einen Träger und wird nicht zum dritten Mal einzeln notiert** —
  [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md), **neunter Posten**, mit dem
  gemessenen Grund, warum ein Sensor sie nicht trennt (die §3-Zellen nennen Komponenten, nicht
  Dateien: von den fünf Zeilen ist genau **eine** ein Dateipfad, ein Präfix-Vergleich wäre für alle
  fünf ungenannten Dateien grün).
- **(2) Die zwei mitwandernden Plan-Zahlen sind mitgewandert — das ist die eingelöste Zusage, kein
  Delta.** §2 nennt beide ausdrücklich als *mitwandernd*:
  `sed -n '/^failure_form()/,/^}/p' harness/tools/mutate.sh | grep -cE '^[[:space:]]+[a-z*-]+\)'`
  → **7** (unverändert, der Slice fügt keinen Modus hinzu) und
  `grep -rhoE '"harness/mk/[^" ]+' --include=*.go internal/ | sort -u | wc -l` → **6** gegen die
  Plan-Zahl **5**; die sechste ist `"harness/mk/erfassung.mk"`, genau die eine Konstante, die <!-- d-check:ignore (Pfad im Zielrepo, nicht in diesem) -->
  dieser Slice anlegt. Beide Zahlen wurden von Review und Verifikation unabhängig nachgefahren.
  **Eine als mitwandernd markierte Zahl, die wandert, ist der Normalfall** — sie hier als
  Abweichung zu führen kehrte
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2 um.

**Die 270,50-s-Anomalie ist ein Null-Ergebnis, und das ist etwas anderes als eine Erklärung.** Der
Implementer hat sie mit *„es war die Last, nicht der Zahn"* eingeordnet. **Belegt ist davon die
erste Hälfte, und nur sie:** fünf von sechs Messungen desselben Baums liegen zwischen **79,92 s**
und **88,39 s**, eine bei **270,50 s** (Verifikation §3.6, **fremdbelegt**; zwei der sechs sind
eigene Läufe der Verifikation). Ein dauerhafter Aufschlag von rund +180 s ist damit
**ausgeschlossen** — der Zahn dieses Slice hat `make full-smoke` nicht verteuert. **Nicht belegt
ist die zweite Hälfte:** *„Last"* ist nicht gemessen worden, weder Systemlast noch Cache-Zustand
des Ausreißer-Laufs liegen als Zahl vor. Die richtige Formulierung ist: **der Zahn ist als Ursache
ausgeschlossen, die Ursache selbst ist unbestimmt.** *Ausgeschlossen* und *erklärt* sind zwei
verschiedene Aussagen, und die zweite hätte hier denselben Beleg gebraucht wie eine Zahl —
dieselbe Regel, die [slice-095](../done/slice-095-hook-aufschlag-gemessen.md) als fünften Posten
formuliert hat.

**Eine fremdbelegte Aussage, die beim Nachmessen zu präzisieren war.** Die Verifikation führt den
Satz *„ein erneuter Lauf des Werkzeugs legt ihn wieder ab"* in ihrer Sensor-Tabelle als **kein
Sensor** (V-7). Selbst nachgemessen:
`grep -n 'erneuter Lauf des Werkzeugs legt ihn wieder ab' harness/tools/full-smoke.sh` → **eine**
Zeile, und sie steht **in der Prüfschleife**, die den Träger-fehlt-Zweig gegen drei geforderte
Sätze hält. Der Satz hat also sehr wohl einen **Anwesenheits**-Wächter, gemeinsam mit den zwei
anderen; was ihm fehlt, ist ein Wächter über seiner **Wahrheit** — dass ein erneuter Lauf den
Träger wirklich wieder ablegt — und ein **eigener** Mutations-Fall (Fall `186` nimmt den zweiten
der drei Sätze). Der Befund bleibt gültig, sein Betrag ist ein anderer. Er steht hier, weil genau
diese Unterscheidung — Anwesenheit gegen Wahrheit — der Steering-Loop-Eintrag dieses Laufs ist und
sie sich bis in den Bericht durchgezogen hat, der sie benennt.

**Was am Plan korrigiert wurde, was bewusst stehen blieb.**

Mit dem Zug nach `done/` wird diese Datei zum **Zeitdokument**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
§Geltungsbereich); danach ist eine Korrektur ein Eingriff in die Geschichte. Also entscheidet
diese Closure, und sie sagt, was sie getan hat.

- **Nicht korrigiert: die drei DoD-Punkte und ihre Rot-Kommandos.** Sie sind gefahren und erfüllt;
  jede Nachschärfung hier wäre rückwirkend und machte den Beleg unlesbar. Was die Verifikation an
  ihnen präzisiert hat, steht als **Delta** unten in der Träger-Tabelle, nicht im Kriterium.
- **Nicht korrigiert: DoD (1)s Rot-Kommando, obwohl die schmalere Stufe existiert.** Der Punkt
  nennt `make full-smoke`; ein Go-Wächter über `report.Schreibe` hätte denselben Bruch gefangen
  (`grep -rn 'grundDerZaehler' --include=*_test.go internal/ | wc -l` → **0** — es gibt ihn nicht).
  Die Wahl ist damit eine Entscheidung mit Preis (zwei zusätzliche `full-smoke`-Fälle in einem
  Bestand, dessen Kosten [slice-105](../done/slice-105-mutate-messen-dann-teilen.md) misst), keine
  Notwendigkeit. **Das Kriterium bleibt stehen, der Preis steht hier.**
- **Korrigiert, weil es eine Tatsachenbehauptung ist: der Verzicht auf einen Mutations-Fall für die
  „fehlt"-Richtung der Kommando-Menge.** Der **Verzicht trägt** — die Verifikation hat die Mutation
  in ein echtes Ziel eingespielt, und dessen `make span-report` bricht mit einem Shell-Syntaxfehler
  (`/bin/sh: 2: Syntax error: "done" unexpected`, `EXIT=2`), was `full-smoke` Schritt (b) fängt.
  **Die Begründung dafür trägt nicht:** sie nennt `len(haben) == 0` und die Wörtlichkeit des `rm`,
  und gemessen greift keines von beiden — beim Wegfall einer Rezept-Zeile ist `haben` nicht leer,
  und das `rm` ist unberührt; rot wird der Fall allein über die Schleife `for wort := range wollen`
  (Verifikation V-5, **fremdbelegt**). Beides gehört festgehalten: die **Sache** ist gedeckt, die
  **Begründung** war die falsche Mechanik.

**Was der Slice nicht deckt — die Grenzen, die er für sich selbst zieht.**

- **Die Nicht-Verdrahtung ist über den Ziel**namen** bewacht, nicht über die Wirkung.** Ein
  automatischer Löschpfad, der `rm -rf` direkt in ein fremdes Rezept schriebe, statt `span-clean`
  zu rufen, fiele nicht auf. DoD (2) verlangt *„kein Pfad im Hook und kein Gate ruft **es**"* — der
  Wächter ist mit der Zusage deckungsgleich, aber die Zusage ist enger als die Gefahr.
- **Die Grenze aus [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md)
  Folgepflicht 6 hat an ihrem *laufenden* Ort keinen Gate-Sensor — an ihrem *stehenden* schon, und
  das war der Grund für zwei Orte.** Gemessen: der Grund-Satz des Lesers hat keinen Go-Wächter
  (Kommando oben, **0**), sein einziger Sensor ist `make full-smoke` — Nicht-Gate-Verify. Der
  stehende Ort dagegen, das Feldlisten-Dokument aus
  [slice-098](../done/slice-098-feldliste-ist-ausdruck-des-traegers.md), trägt
  `TestFeldliste_GrenzeVerbrauchsZaehler`
  (`grep -n 'func TestFeldliste_GrenzeVerbrauchsZaehler' internal/emit/fieldlist_test.go` → Zeile
  **177**) samt eigenem Mutations-Fall
  (`grep -rl 'GrenzeVerbrauchsZaehler' test/mutations/ | wc -l` → **1**), und dieser Wächter läuft
  in `make test` und damit in `make gates`
  (`grep -c '^gates:.* test ' Makefile` → **1**). **Die Einlösung hängt also nicht an einem Lauf,
  den nur DoD-Verify und CI fahren** — genau dafür hat §1 die Grenze an zwei Orte geschrieben, und
  genau der Ort, *„der auch dann trägt, wenn niemand den Leser ruft"*, ist der gate-bewachte. Was
  bleibt, ist der schwächere Schutz des laufenden Orts; das ist ein Preis, keine Lücke.
- **Der Nicht-Zusage-Satz lebt als Kommentar in einer `.mk`-Datei, nicht im geprüften Doku-Bereich
  des Ziels.** DoD (2) verlangt *„daneben steht geschrieben"*, und das ist erfüllt; aber kein
  Doku-Gate des Adopters liest ihn, und das Feldlisten-Dokument führt ihn nicht
  (`grep -i 'aufraeum\|waechst\|unbegrenzt' <ziel>/harness/erfassung-feldliste.md` → **kein
  Treffer**, Verifikation §4, **fremdbelegt**). Es ist die schwächere von zwei möglichen Ablagen
  und eine Asymmetrie zu [slice-098](../done/slice-098-feldliste-ist-ausdruck-des-traegers.md).
- **Das konditionale Arch-Gate-Fragment liegt in keiner der beiden Sensor-Mengen** — weder in
  `makeQuellenDesZiels` noch im `full-smoke`-Pfad, der die Prüfung fährt. Es behauptet heute
  nichts über die zwei Ziele (`grep -c 'span-' internal/emit/archgate.go` → **0**), die Lücke ist
  also nicht realisiert; **benannt** war sie im Plan nicht.

**Steering-Loop-Eintrag — geschärfte Regel.**

**Eine Begründung ist eine Zusage über eine Ursache. Ein Wächter über ihrer *Anwesenheit* belegt
die Zeichenkette, nicht die Ursache — die Zusage ist erst eingelöst, wenn der Zustand benannt ist,
in dem die genannte Ursache zutrifft, und der Beleg über genau diesem Zustand erhoben wurde. Das
gilt für den roten Pfad wie für den grünen.**

**Der gemessene Anlass ist die Verteilung der Befunde, nicht ein einzelner.** Alle drei MEDIUM
dieses Laufs stehen in **Begründungstexten**, keiner in einem Zahn
(`grep -c '^### V-.*(MEDIUM)' docs/reviews/2026-08-26-slice-099-verify.md` → **3**): eine
Wächter-Meldung verlangt eine Schreibweise, die derselbe Wächter nicht akzeptiert (V-2) — eine
Zeile mit exakt dem Geforderten bleibt rot, an einer eigenen Sonde gemessen; die Ausgabe des
Lesers begründet einen leeren Bestand mit zwei Ursachen, die im gemeldeten Zustand beide nicht
vorliegen können (V-1); und über einem Bestand mit **null** Agent-Läufen gibt derselbe Leser der
Mechanik des Agenten-Werkzeugs die Schuld, obwohl schlicht kein Subagent gelaufen ist (V-3).

**Warum das eine Weitung ist und nicht die Wiederholung von
[slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) Posten 6.** Jener Posten
setzt voraus, der Begründungstext werde *„ausschließlich im Rot"* ausgegeben — daraus folgt seine
Vorschrift, beim Rot-Sehen die Meldung zu lesen. **Gemessen trifft die Prämisse auf ein Drittel
der Fälle zu:** V-2 liegt im Rot, V-1 und V-3 liegen im **grünen** Pfad. Es sind Sätze, die das
**emittierte Produkt** einem **fremden** Repo über dessen eigenen Zustand sagt; kein roter Lauf
bringt sie je zu Gesicht, und der einzige Wächter darüber prüft, ob die Zeichenkette **da ist**
(`grep -qF "Kein Bestand:"`), nie ob sie zutrifft. Damit fällt auch die Vorschrift aus: *„lies die
Meldung beim Rot"* erreicht einen Satz nicht, den nur der Erfolg druckt. **Die Regel muss an der
Eigenschaft ansetzen — genannte Ursache —, nicht am Pfad, auf dem der Satz erscheint.**

**Und die Weitung hat eine zweite, schärfere Hälfte, die dieser Slice an sich selbst gemessen
hat.** DoD (1) verlangt, dass die Ausgabe *„sagt, dass die Zähler an der Mechanik des
Agenten-Werkzeugs hängen"*, und sein Rot-Kommando prüft, ob der Satz in der Ausgabe steht. Der
Beleg dafür ist über einem Ziel erhoben worden, dessen Bestand **null** Agent-Läufe trägt (V-3) —
also über einem Zustand, für den der Satz nicht die Erklärung ist. **Die Zusage lautete
„der Satz steht da", und genau die ist belegt; gemeint war „der Satz erklärt diesen Fall", und die
ist es nicht.** Der DoD-Punkt selbst hat die Lücke geöffnet, nicht der Implementer: er benennt
einen Text und kein Kriterium für den Zustand, über dem er gelten soll. Das ist Planner-Arbeit,
und es ist der Grund, warum diese und nicht die andere Lehre gewählt ist.

**Warum eine Regel und kein Sensor.** Die Eigenschaft — *ein Satz, der eine Ursache nennt* — ist
ein Urteil über Prosa. Ein Muster darüber trennt die Klasse nicht: `grep -rn 'weil\|deshalb\|darum'`
über den emittierten Textbestand liefert Treffer, deren Mehrzahl keine Ursachen-Zusage ist, und
die beiden Gates in der Nähe können es bauartbedingt nicht — `make comment-claims` prüft, ob ein
**genannter Test existiert**, nicht ob eine Aussage zutrifft, und `make mutate` vergleicht die
Ausgabe gegen `--- FAIL:` und den erwarteten Wächter-Namen, nie gegen die Begründung daneben. **Wo
die Regel dagegen mechanisch wird, ist die DoD:** ein DoD-Punkt, dessen Gegenstand eine Begründung
ist, nennt den Zustand mit, über dem sein Rot erhoben wird — und das ist Form, nicht Urteil.

**Der Regeltext wird hier nicht vorentschieden**; er entsteht im Architect-Lauf
([`AGENTS.md`](../../../../AGENTS.md) §3.8,
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1). Diese Notiz
liefert die Formulierung, den Anlass und die Messung.

**Träger: [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md), Posten 6 —
nachgezogen, nicht als zehnter Posten danebengestellt.** Ein zweiter Posten mit derselben Regel und
einer weiteren Prämisse ergäbe zwei Postens, die einander den Geltungsbereich streitig machen;
was sich geändert hat, ist die **Reichweite** eines vorhandenen, nicht die Zahl. Die Fassung dort
ist entsprechend geweitet, und die Messung steht daneben.

**Offen, mit Träger.** Jeder Befund aus Review und Verifikation trägt einen Ausgang — eigener
Schnitt, vorhandener Träger oder Ablehnung mit Grund. *„Genannt"* ist seit
[slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) keiner.

| Posten | Träger |
|---|---|
| **V-1** — die Meldung des leeren Bestands begründet ihn mit zwei Ursachen, die im gemeldeten Zustand beide nicht vorliegen können (der Träger liegt, und `span-clean` nimmt ihn nicht) | **[slice-071](../open/slice-071-bilanz-nennt-ihren-bestand.md)** — vorhandener Träger, nachgezogen. Dieselbe Datei, dieselbe Ausgabe, dieselbe Lagen-Trennung: sein DoD (1) trennte bisher *fehlender Ablageort* von *leerem Bestand* und trägt jetzt zusätzlich die Begründungs-Hälfte. Ein eigener Schnitt schriebe dieselbe Verzweigung ein zweites Mal um |
| **V-3** — `Zeilen > 0 ∧ AgentLaeufe == 0` ist eine vierte Lage, die der Leser mit der dritten zusammenfasst und mit der Mechanik begründet | **[slice-071](../open/slice-071-bilanz-nennt-ihren-bestand.md)** — vorhandener Träger, als **eigener DoD-Punkt (2)** aufgenommen: die Lage sitzt in derselben Verzweigung, ihr Gegenbeispiel ist aber ein anderer Bestand. Der Slice steht damit bei **drei** slice-eigenen Punkten, der Grenze aus Modul 5 §Ziel-Form |
| **V-2** — die Gate-Tabellen-Meldung verlangt `KEIN GATE`, der Wächter prüft `kein Gate`; wer der Meldung folgt, kommt nicht ins Grün | **[slice-110](../open/slice-110-erfassungs-waechter-fall-meldung-grenze.md)** — neu geschnitten, DoD (1). **Nicht [slice-071](../open/slice-071-bilanz-nennt-ihren-bestand.md):** dort geht es um die Ausgabe des **Produkts**, hier um die Meldung eines **Wächters** — anderer Gegenstand, andere Datei |
| **V-11** — `span-clean` meldet *„entfernt"* auch über bereits leerem Zustand | **[slice-110](../open/slice-110-erfassungs-waechter-fall-meldung-grenze.md)**, dieselbe DoD (1): dieselbe Klasse, im emittierten Fragment statt im Wächter. Folgenlos, aber es ist eine Meldung über einen Lauf, der nicht stattfand |
| **V-4** — `TestAggregiere_ZeilenZaehltAuchUnlesbare` hat Zähne (eigene Sonde der Verifikation), aber keinen Fall: `grep -rl 'ZeilenZaehltAuchUnlesbare' test/mutations/ \| wc -l` → **0** | **[slice-110](../open/slice-110-erfassungs-waechter-fall-meldung-grenze.md)**, DoD (2). **Nicht [slice-108](../open/slice-108-feldlisten-waechter-tragen-ihren-fall.md):** dessen Gegenstand ist die **Feldliste** ([`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 7); hier liegt ein Wächter über dem **Leser**. Gleiche Form, anderer Vertrag |
| **V-7** — *„ein erneuter Lauf des Werkzeugs legt ihn wieder ab"* ist gemessen wahr und hat einen Anwesenheits-, aber keinen Wahrheits-Wächter und keinen eigenen Fall | **[slice-110](../open/slice-110-erfassungs-waechter-fall-meldung-grenze.md)**, DoD (2) — mit **beiden** zulässigen Ausgängen im Plan: Fall **oder** ausgesprochene Grenze. Der Wahrheits-Zahn kostet einen zweiten Init-Lauf im `full-smoke`, und genau diese Klasse misst [slice-105](../done/slice-105-mutate-messen-dann-teilen.md) als Klippe |
| **F-3** — der Gate-Tabellen-Wächter liest für zwei seiner fünf Dokument-Quellen die Fixture `courseSet()` statt des realen vendored Satzes | **[slice-110](../open/slice-110-erfassungs-waechter-fall-meldung-grenze.md)**, DoD (3) — als **benannte Grenze**, nicht als Schließung. Die Ursache ist der Docker-Build-Kontext (`.dockerignore` schließt `.harness/` aus, seit slice-022b) und damit eine vorbestehende Eigenschaft der gesamten Emit-Test-Infrastruktur; sie hier zu schließen wäre ein anderer Schnitt, und §4 jenes Slice führt genau diese Rückführung. **Heute nicht realisiert** (V-12: `grep -rhoE 'make [a-z][a-z0-9-]*' .harness/baseline/*/templates/ \| LC_ALL=C sort -u` → **11** Nennungen, keine davon `span-report`/`span-clean`) |
| **V-6** — das konditionale Arch-Gate-Fragment liegt in keiner der beiden Sensor-Mengen, und die benannte Grenze nennt es nicht | **[slice-110](../open/slice-110-erfassungs-waechter-fall-meldung-grenze.md)**, dieselbe DoD (3): dieselbe Frage (was sieht der Wächter nicht?) an derselben Datei |
| **F-5 / V-8** — fünf Dateien außerhalb der §3-Tabelle, dritte Beobachtung dieser Klasse in Folge | **[slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md)** — als **neunter Posten**, dort eingetragen, mit dem gemessenen Grund gegen einen Sensor. **Kein eigener Schnitt:** sein Ergebnis wäre Norm-Text über die Form eines Plans, und genau dafür existiert jener Durchgang. Zusätzlich trägt [slice-110](../open/slice-110-erfassungs-waechter-fall-meldung-grenze.md) §3 die Zeile für die bewegte gemeinsame Stelle bereits — die erste Anwendung des Postens, bevor er entschieden ist |
| **V-10** — die Ausgabe unseres eigenen `span-report` hat sich geändert, [`AGENTS.md`](../../../../AGENTS.md) §4 und [`harness/README.md`](../../../../harness/README.md) sind unberührt | **[slice-111](../open/slice-111-was-ein-bootstrap-anlegt-steht-in-der-nutzerdoku.md)** — neu geschnitten, **und die Frage ist entschieden: ja, ein öffentlicher Vertrag ist berührt — aber ein anderer als der gefragte.** Begründung unten |
| **V-13** — [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 4 macht die Aufnahme des neuen Init-invarianten Fragments in den `targets:`-Satz fällig, sobald der Block existiert | **[welle-09](../welle-09-modul-15-konformitaet.md), Block 4 → `slice-063`** — vorhandener Träger, dort nachgezogen. **Keine Verletzung heute:** `grep -c 'targets' .d-check.yml` und `grep -c 'targets' internal/emit/templates/d-check.yml` → je **0**; es gibt nichts, dem etwas hinzuzufügen wäre. Die Welle hatte die Schuld in §5 benannt; neu ist, dass sie **scharf** ist |
| **V-9** — weder der Grund-Satz des Lesers noch die drei Träger-Sätze des Fragments haben einen Sensor in `make gates` | **kein Träger, und das ist entschieden** — die Einlösung ist nicht geschwächt; Begründung unten |
| **V-5** — die Begründung des Implementers für den fehlenden Fall der „fehlt"-Richtung nennt zwei Mechanismen, die nicht greifen | **kein Träger, hier erledigt** — die Sache ist gedeckt (`full-smoke` Schritt (b) fängt den Syntaxfehler im Ziel), die Begründung ist oben ersetzt statt wiederholt. Ein Slice hätte keinen Gegenstand |
| **V-12** — Review-F-3s Gefahr ist heute nicht realisiert | **kein Posten** — eine Messung, die einen anderen Posten einordnet, kein eigener Befund |
| **F-1, F-2, F-4, F-6** — der wirkungslose `rm`-Scope-Wächter, der generische `# expect:`-Text von Fall 176, die ungetestete vierte Meldungs-Lage, die einseitige Fehlermeldung in `full-smoke.sh` | **behoben im Umsetzungs-Commit**, sämtlich von der Verifikation nachgemessen: die Präfix-Regel des reparierten `rm`-Wächters ist gegen die reale GNU-Make-Version gemessen (§3.5), beide Richtungen haben Zähne (Fälle 178/184/185 plus eigene Sonde), Fall 176 trägt jetzt das spezifische Zitat, und die vierte Lage hat ihren Zahn samt Fall `186` |

**Die eine Ablehnung, mit Grund: V-9 schwächt die Einlösung nicht.** Drei Gründe, keiner davon
Aufwand. **Erstens** ist die Zusage aus
[`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Folgepflicht 6, *„die Grenze
wird im Ziel genannt"*, bewusst an **zwei** Orte geschrieben (§1), und der stehende Ort trägt
Go-Wächter, Mutations-Fall und damit `make gates` — die Messung steht oben. Eine Zusage, deren
einer Träger gate-bewacht ist, hängt nicht am Nicht-Gate-Verify. **Zweitens** ist die Wahl der
Stufe für die drei Träger-Sätze konstruktionsbedingt: sie leben in einer Shell-Schleife eines
`make`-Rezepts, und kein Go-Test fährt `make` — `full-smoke` ist dort nicht die teurere, sondern
die einzige Stufe. **Drittens** wäre die naheliegende Reparatur — die teuren Sensoren nach
`make gates` zu ziehen — genau die Vermischung, die
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) und die
offline-schlanke Gate-Definition dieses Repos trennen. **Was offen bleibt und hier steht:** für den
Grund-Satz des Lesers wäre ein Go-Wächter möglich und ist nicht gebaut; er steht als Preis oben,
nicht als Lücke.

**Die zweite Entscheidung, mit Grund: V-10 ist ein berührter öffentlicher Vertrag — aber nicht der,
nach dem gefragt wurde.** [`AGENTS.md`](../../../../AGENTS.md) §4 und
[`harness/README.md`](../../../../harness/README.md) beschreiben **unser** `span-report`, und ihre
Aussage — die Ausgabe nenne *„ihren Nenner, den Sammelposten-Anteil und die Abdeckungszahl samt
Bezugsmenge"* — ist nach diesem Diff **weiterhin wahr** (Verifikation V-10, **fremdbelegt**). Sie
nennt die neue Reihenfolge-Eigenschaft nicht, aber sie behauptet auch nichts Falsches; ein Nachzug
dort ist eine Verfeinerung, kein gebrochener Vertrag. **Der wirklich berührte Vertrag liegt eine
Ebene weiter:** was ein Bootstrap im Ziel **anlegt**, ist der Gegenstand von
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), und die Nutzer-Doku
beschreibt ihn in einem Baum, der Vollständigkeit anbietet. Gemessen über die acht Zeichenketten,
die ein Adopter seit dieser Welle in seinem Repo sieht (`span-report`, `span-clean`,
`erfassung.mk`, `erfassung-feldliste`, `span-emit`, `state/bin`, `agent.role`, `Rollen-Typ`):
**null** Nennungen in [`README.md`](../../../../README.md) und
[`docs/user/benutzerhandbuch.md`](../../../user/benutzerhandbuch.md) zusammen (Kommando in
[slice-111](../open/slice-111-was-ein-bootstrap-anlegt-steht-in-der-nutzerdoku.md) §1), und beide
Dokumente haben sich seit **2026-07-28** nicht bewegt
(`git log -1 --format='%h %ad' --date=short -- docs/user/benutzerhandbuch.md README.md`).
**Der Befund ist damit größer als dieser Slice** — vier Slices dieser Welle haben den emittierten
Satz erweitert und die Standard-DoD-Zeile keiner bedient —, und er gehört als eigener Schnitt
geführt, nicht als Nachtrag in einem von vieren.

**Folge-Slices: zwei neue `open/`-Einträge.**
[slice-110](../open/slice-110-erfassungs-waechter-fall-meldung-grenze.md) (die Wächter der
Erfassungs-Ausgabe tragen ihren Fall, ihre Meldung und ihre Grenze) und
[slice-111](../open/slice-111-was-ein-bootstrap-anlegt-steht-in-der-nutzerdoku.md) (was ein
Bootstrap anlegt, steht in der Nutzer-Doku). **Beide sind wellenlos** — die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1 sind in ihren Kopfzeilen einzeln beantwortet, und keiner füllt oder leert eine Zelle der
Abdeckungs-Tabelle von [welle-12](welle-12-erfassungsschicht-emittieren.md): die Zeilen
*„Aufbewahrung"* und *„Leser"* sind mit diesem Slice geliefert. Die Roadmap bekommt daher keinen
Eintrag ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2).

**Die Welle bekommt keinen Fortschritts-Eintrag, aber sie wird mit diesem Zug schließbar.** Der
Zustand jedes Slice ist sein Lifecycle-Verzeichnis; §4 der Welle sagt es. Mit dem Move dieser Datei
liegen alle sechs Mitglieder in `done/`, und damit ist das erste Closure-Kriterium aus
[welle-12](welle-12-erfassungsschicht-emittieren.md) §3 erfüllt. Was die Wellen-Closure danach
noch verlangt, ist ihre eigene Arbeit und nicht die dieses Slice: Carveout-Audit über
`docs/plan/carveouts/`, die Results-Notiz mit eigenem Steering-Loop-Eintrag, der `git mv` der
Welle-Datei und die Fortschreibung der Roadmap samt Meilenstein **M6**.

**Gates.** Eigener Lauf über dem Baum, den diese Closure hinterlässt — Notiz, die zwei neuen
Slices und die vier nachgezogenen Pläne eingerechnet: `make gates` **EXIT=0**,
`baseline-verify: v3.5.2 OK — 42 Dateien`,
`d-check: 403 Datei(en) geprüft, 0 Befund(e)`, golangci-lint `0 issues.`, bats
`grep -c '^ok '` → **153** und `grep -c '^not ok'` → **0**,
`comment-claims: 45 Datei(en) geprueft, 0 Befund(e)`, `span-check` grün; danach sind
`bash harness/tools/working-tree-hash.sh` und `.harness/state/gates-passed.diffsha` byte-gleich.
**Die Wanduhr steht hier nicht als Zahl, und das ist kein Auslassen:** sie schwankt zwischen zwei
Läufen desselben Baums mit dem Docker-Cache (gemessen **31,17 s** und **41,96 s** über zwei
aufeinanderfolgenden Läufen dieser Closure), und ein hier abgedruckter Wert verschöbe zugleich den
Stempel über genau dem Baum, den er beschreibt. Wer sie will, fährt
`/usr/bin/time -f 'GATES_SECONDS=%e' make gates`.
**Der erste Lauf war rot**, und das gehört genannt: `d-check` meldete **sechs**
`codepath-missing`-Befunde über Pfaden, die im **Zielrepo** liegen und nicht in diesem
(`harness/mk/erfassung.mk` und `harness/mk/`) — dieselbe Klasse, die <!-- d-check:ignore (Pfade im Zielrepo, nicht in diesem) -->
[slice-098](../done/slice-098-feldliste-ist-ausdruck-des-traegers.md) für sein Feldlisten-Dokument
schon getroffen hat; sechs `d-check:ignore`-Marken mit ihrem Grund haben ihn geschlossen. Die
Dateizahl des Doku-Gates wandert mit dem Markdown-Bestand und ist **kein** Erwartungswert. Die
teuren Sensoren stehen oben als **fremdbelegt** (`make mutate` einmal, `make full-smoke` zweimal,
`make gates` zweimal — alle aus der Verifikation über dem Umsetzungs-Baum).

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `internal/report/`,
`internal/emit/`, `harness/tools/` und `test/` gehören zum Greenfield-Bestand; der Modus steht in
der Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
