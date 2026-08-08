# Slice slice-071: Cache-Zähler getrennt — drei Counter, vier Angaben je Counter

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-09](../welle-09-modul-15-konformitaet.md) — Block 3, setzt auf
[slice-060](../done/slice-060-rollen-achse.md) auf.

**Bezug:** [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (Baseline ohne
inhaltliche Adaption — Modul 15 ist adoptiert und in Block 3 unumgesetzt),
[`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
(das Span-Schema, aus dem die Zähler gelesen werden, und der Ort der Festlegung aus DoD (2)),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted** — die Policy, unter
der der ausgewertete Bestand entstanden ist),
[`ADR-0003`](../../adr/0003-go-native-binaries.md) (**Accepted** — die Auswertung ist ein
Go-Binary, Docker-only gebaut),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (dieselbe Zusage
auf der **Dogfood-Ebene**: das Werkzeug dieses Repos, nicht das emittierte Zielprojekt).
Regelwerk-Quelle: `.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md`
§Cache-Counter-Regeln.

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-31.

---

## 1. Ziel

**Was der Cache getragen hat, steht als eigene Rechnung da — getrennt nach gelesen und
geschrieben.** Aus denselben Spans wie die Token-Bilanz, aber mit einer anderen Frage: nicht
*wer hat verbraucht*, sondern *was davon musste überhaupt neu in den Kontext*.

## 2. Definition of Done

- [ ] **(1) Die drei Zähler stehen getrennt im Ergebnis — mit allen vier Angaben, die die Regel
  je Counter verlangt.** `cache_creation_input_tokens` und `cache_read_input_tokens` werden
  **nie** zu einer Zahl verrechnet. Modul 15 §Cache-Counter-Regeln stellt **vier** Fragen je
  Counter, und alle vier gehören beantwortet:
  1. **Name** — `prompt_cache_hits_total`, `prompt_cache_misses_total`,
     `prompt_cache_input_tokens_total`. Ausgeschrieben, damit die Ausgabe und eine spätere
     Metrik-Ausleitung denselben Namen führen.
  2. **Unit/Cardinality** — alle drei **Counter** (monoton, Einheit Token), nicht Gauge und nicht
     Histogram: sie summieren einen Bestand, sie messen keinen Momentanwert und keine Verteilung.
  3. **Labels** — mindestens `slice.id`, `agent.role`, **`model.version`**; letzteres liegt als
     `resolvedModel` in denselben Spans.
  4. **Aggregation** — `hits / (hits + misses)`, und **wo die Division läuft**. Hier: im
     Auswerter, weil dieses Repo weder Metrik-DB noch Dashboard hat. **Und welcher Zähler
     welcher ist, steht hier und nicht nur in der Welle:** `hits` = `cache_read_input_tokens`
     (aus dem Cache gelesen), `misses` = `cache_creation_input_tokens` (in den Cache
     geschrieben, also gerade **nicht** getroffen).

  **Und die Zahl stimmt nicht:** das Modul spricht von **drei** Countern, die Payload liefert
  **zwei** (`cache_creation_input_tokens`, `cache_read_input_tokens`). Der dritte ist die
  Token-Eingabe-Metrik, gegen die das Modul den Miss-Spike erkennt (*„Anstieg der
  Token-Eingabe-Metrik ohne Anstieg der Cache-Hit-Rate"*) — sie liegt als `input_tokens` in
  derselben `usage`. Ein Verifier, der die Zahl gegen den Modul-Text prüft, soll die Differenz
  hier finden und nicht als Abweichung melden.
  **Der Zahn:** ein Go-Test auf die getrennten Zeilen der Ausgabe und ein Fall in
  `test/mutations/`, der die beiden Zähler zu einer Summe zusammenzieht — er muss rot werden.
- [ ] **(2) Die Festlegung steht in
  [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5,
  nicht nur im Code.** Welche drei Zähler geführt werden, unter welchen Namen, in welcher
  Counter-Form und **wo die Division läuft** — eine einzelne `cache.hit_ratio` reicht
  ausdrücklich nicht, weil sie Kosten- und Sicherheits-Indikator vermischt. Sie trifft die
  [Aufnahme-Regel](../../../../spec/spezifikation.md#aufnahme-regel) auf allen drei Achsen und
  setzt fort, was Abweichung 1 dort bereits verlangt: die Zähler sind für Vordergrund-Läufe
  erfasst und dürfen **nicht** als unerreichbar geführt werden. **Auflösungs-Trigger, als
  beobachtbare Bedingung und ohne Planungs-Kennung im bindenden Text:** Namen, Counter-Form und
  Ort der Division werden neu entschieden, **sobald dieses Repo eine Metrik-Senke bekommt** — dann
  wandert die Division dorthin und die Namen folgen deren Konvention. Bis dahin gilt die
  Festlegung unverändert.
- [ ] `make gates` grün, `make mutate` ohne Befund.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Voraussetzung, die [slice-060](../done/slice-060-rollen-achse.md) liefert:** die
`Agent`-Spans tragen `spawned_role` (normalisiert), `resolvedModel` und die `usage` mit ihren
vier Zählern — zwei davon sind die Cache-Zähler, `resolvedModel` ist das Pflicht-Label
`model.version`. **Gemessen am 2026-07-29:** diese Felder kommen **nur bei
Vordergrund-Läufen** an.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| Auswertung (Go, eigenes Kommando) | neu oder update | der Cache-Abschnitt der Ausgabe; dieselbe Linie wie der Emitter — Docker-only gebaut ([`ADR-0003`](../../adr/0003-go-native-binaries.md)), **kein** Subkommando des Produkt-Binaries, damit slice-062 nicht vorweggenommen wird. Ob das Kommando hier entsteht oder schon steht, entscheidet die Reihenfolge gegen [slice-066](../in-progress/slice-066-telemetrie-auswertung.md) |
| `Makefile` | update | das `make`-Ziel der Auswertung, falls es noch keines gibt. **Kein Gate:** eine Rechnung prüft nichts, und ein Gate über einem Bericht wäre eines über leerem Prüfbereich ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) |
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md) | update | die Festlegung aus DoD (2) — Namen, Counter-Form, Ort der Division, Auflösungs-Trigger — in §5 neben Abweichung 1, die die Cache-Counter-Regeln bereits verlinkt. **Kein Adaptions-Eintrag:** eine adoptierte Modul-Regel umzusetzen ist keine Abweichung von ihr, und dass das Label `model.version` nur im Vordergrund vorliegt, steht dort schon als Abweichung 1 |
| `test/` + `test/mutations/` | neu | der Zahn aus DoD (1) |

**Offen, vor dem Code zu entscheiden:**

| # | Frage | Warum sie den Schnitt entscheidet |
|---|---|---|
| A | ~~Summiert die Rechnung **eine Sitzung** oder den **Bestand**?~~ **BEANTWORTET (2026-08-03): der Bestand** — übernommen, nicht neu entschieden | Im Ablageort liegen Ströme mehrerer Sitzungen, und `make span-clean` ändert den Bestand erneut. Dieselbe Frage stellt [slice-066](../in-progress/slice-066-telemetrie-auswertung.md) (dort Frage B); **jener lief zuerst und hat sie entschieden** — Begründung und Messung stehen dort, hier gilt die Antwort. Was dieser Slice davon mitträgt: die Ausgabe nennt **Sitzungszahl und Zeitraum**, weil `span-clean` die Basis zurücksetzt — zwei Ausgaben über verschieden großen Beständen wären nicht vergleichbar |

## 4. Trigger

**`open` → `next`:** [slice-060](../done/slice-060-rollen-achse.md) ist **done** — vorher
trägt kein Span eine Rolle, und `agent.role` ist eines der drei Pflicht-Labels aus DoD (1).

**`next` → `in-progress`:** WIP-Limit; dazu **Frage A entschieden**.

Rückführungen:

- `in-progress` → `next`: falls die Namensgebung ohne Metrik-Senke nicht festlegbar ist — dann
  ist zuerst zu entscheiden, wofür die Namen gelten, und der Slice zerfällt in Festlegung und
  Rechnung.
- `in-progress` → `open`: falls der erfasste Bestand keine Cache-Zähler trägt (kein
  Vordergrund-`Agent`-Lauf darin) — dann stünde die Rechnung über leerem Bestand.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10) mit **ausgestelltem** Verdikt; Verifikation bestätigt
(Modul 11); `make gates` und `make mutate` grün; `git mv` nach `done/` (eigener Move-Commit,
eingehende Links im Zug danach); Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Die Hit-Rate ist eine Verhältniszahl über der erfassten Teilmenge.** Sie rechnet über
  dieselben `Agent`-Spans wie die Token-Bilanz und deckt damit dieselben Läufe ab — die
  Vordergrund-Läufe. Was sie über den Haupt-Kontext sagt, ist nichts
  ([`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md)).
- **Zwei gelieferte Zähler, drei geführte Namen.** Der dritte Name ruht auf `input_tokens` aus
  derselben `usage` — kein eigener Cache-Zähler, sondern die Größe, gegen die der Miss-Spike
  sichtbar wird. Wer die drei später an eine Metrik-Senke gibt, muss diese Herkunft mitliefern,
  sonst liest sich der dritte wie ein Cache-Wert.
- **Zwei Posten kommen aus dem Auswerter mit, weil dieser Slice denselben Leser fortschreibt.**
  (a) Ein **nicht existierender** Ablageort liefert dieselbe wohlgeformte leere Ausgabe wie ein
  **leerer**: `filepath.Glob` meldet über einem fehlenden Verzeichnis weder Treffer noch Fehler,
  und das vorangestellte `mkdir -p` des `make`-Ziels maskiert den Fall — ein vertippter Mount
  liest sich als Ergebnis. Das ist die Grenze aus
  [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt 4: *leer und als
  leer erkennbar*, nicht geraten. (b) Die Bestandszeile nennt die **Sitzungs-Ströme des
  Ablageorts**, nicht die **Streuung der Summe** — beides fällt auseinander, sobald ein Strom
  keine Zähler trägt oder einer die Summe dominiert. Wer den Nenner druckt, druckt beides oder
  benennt, welches er meint.
- **Nicht in diesem Slice:** die Token-Bilanz je Rolle ([slice-066](../in-progress/slice-066-telemetrie-auswertung.md)),
  die Rollen-Achse ([slice-060](../done/slice-060-rollen-achse.md)) und die Tool-Ebene
  (slice-062/063).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `cmd/`, `internal/`,
`Makefile`, `spec/` und `test/` gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
