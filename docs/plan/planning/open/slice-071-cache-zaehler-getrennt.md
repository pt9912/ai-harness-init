# Slice slice-071: Cache-Zähler getrennt — die Festlegung, die ohne Bestand steht

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-09](../welle-09-modul-15-konformitaet.md) — Block 3, setzt auf
[slice-060](../done/slice-060-rollen-achse.md) auf.

**Bezug:** [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (Baseline ohne
inhaltliche Adaption — Modul 15 ist adoptiert und in Block 3 unumgesetzt),
[`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
(das Span-Schema, aus dem die Zähler gelesen werden, und der Ort der Festlegung aus DoD (1)),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted** — die Policy, unter
der der Bestand entsteht, für den die Festlegung gilt),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (der Grund, aus
dem die Division im Auswerter läuft und nicht in einer Senke: dieses Repo installiert keine —
**Dogfood-Ebene**, nicht das emittierte Zielprojekt),
[`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) (der ausgefallene Eingang; er trennt
die Festlegung von der Rechnung, §3).
Regelwerk-Quelle: `.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md`
§Cache-Counter-Regeln.

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-31.

---

## 1. Ziel

**Was der Cache getragen hat, ist als Rechnung festgelegt, bevor es sie gibt — getrennt nach
gelesen und geschrieben.** Die Frage ist eine andere als die der Token-Bilanz: nicht *wer hat
verbraucht*, sondern *was davon musste überhaupt neu in den Kontext*. Beantwortet wird sie aus
denselben `Agent`-Spans — sobald die wieder Zähler tragen.

**Die Rechnung selbst ist nicht Gegenstand dieses Slice, und das ist der Schnitt, keine
Vertagung.** Sie braucht einen Bestand mit Zählern; der ist ausgefallen und wird als
[`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) geführt. Eine Festlegung braucht
keinen — sie sagt, was gerechnet wird, und sie ist heute entscheidbar (§3).

## 2. Definition of Done

- [ ] **(1) Die Festlegung steht in
  [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5,
  nicht im Code — mit allen vier Angaben, die die Regel je Counter verlangt.**
  `cache_creation_input_tokens` und `cache_read_input_tokens` werden
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

  Eine einzelne `cache.hit_ratio` reicht ausdrücklich nicht, weil sie Kosten- und
  Sicherheits-Indikator vermischt. Die Festlegung trifft die
  [Aufnahme-Regel](../../../../spec/spezifikation.md#aufnahme-regel) auf allen drei Achsen.
  **Sie regelt die Rechnung, nicht die Erreichbarkeit der Zähler:** dass die `usage` eines
  Vordergrund-Aufrufs nicht mehr entsteht, führt Abweichung 1 dort als
  [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) — eine zweite Aussage darüber an
  dieser Stelle wäre der zweite Ort, der driftet. Was hier festgelegt wird, gilt für den
  Bestand, sobald die Zähler wieder ankommen. **Auflösungs-Trigger, als
  beobachtbare Bedingung und ohne Planungs-Kennung im bindenden Text:** Namen, Counter-Form und
  Ort der Division werden neu entschieden, **sobald dieses Repo eine Metrik-Senke bekommt** — dann
  wandert die Division dorthin und die Namen folgen deren Konvention. Bis dahin gilt die
  Festlegung unverändert.

  **Der Zahn gehört zur Rechnung und entsteht mit ihr — das ist eine Aussage, kein Auslassen**
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6): was diese Festlegung bricht, ist eine Rechnung, die
  die beiden Cache-Zähler zu einer Summe zusammenzieht. Solange keine Rechnung läuft, gibt es
  nichts, was dieser Fall rot färben könnte; er wird mit ihr geschnitten, nicht vorgezogen. Was
  heute prüfbar ist, prüft das Doku-Gate: die Festlegung steht im Spec-Stratum und ist von dort
  verlinkt.
- [ ] `make gates` grün, `make mutate` ohne Befund.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Voraussetzung, die [slice-060](../done/slice-060-rollen-achse.md) liefert:** die
`Agent`-Spans tragen `spawned_role` (normalisiert), `resolvedModel` und die `usage` mit ihren
vier Zählern — zwei davon sind die Cache-Zähler, `resolvedModel` ist das Pflicht-Label
`model.version`. **Diese Felder kommen nur bei Vordergrund-Läufen an, und der Vordergrund ist
nicht mehr anforderbar** ([`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md)): die
Erfassung steht unverändert und nimmt die Zähler, sobald sie wieder ankommen — heute stünde die
Rechnung über einem Bestand ohne Eingang.

### Der Schnitt: Festlegung hier, Rechnung hinter dem Auflösungs-Trigger

**Zwei Gegenstände, und nur einer ist heute lieferbar.** Namen, Counter-Form, Pflicht-Labels und
der Ort der Division sind eine **Festlegung**; sie braucht keinen Bestand und ist heute
entscheidbar. Die **Rechnung** braucht einen und hat keinen. Beide in einem Schnitt zu führen
hieße, den lieferbaren Teil an eine fremde Entscheidung zu hängen — Modul 5 §Ziel-Form verlangt
das Gegenteil: *kein Slice wartet auf den nächsten*.

**Die Rechnung ist deshalb nicht Gegenstand dieses Slice und auch kein zweiter offener Slice
daneben.** Ihr Träger ist der Carveout: eine bewusste Nicht-Umsetzung mit Geltungsbereich,
Begründung und Auflösungs-Trigger ist genau das Instrument, das Modul 7 dafür vorsieht. Fällt
der Trigger von [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) positiv, wird die
Rechnung geschnitten, und mit ihr ihr Zahn. **Was „positiv" heißt, steht dort und nur dort**
(§Auflösungs-Trigger): **eine** Schwelle mit **zwei** Gliedern — hier verwiesen statt
abgeschrieben, weil eine zweite Fassung derselben Schwelle von ihr wegdriftet. Für diesen
Schnitt zählt daran, was das zweite Glied verhindert: ein Span, den ein zurückgenommener
Messaufbau hinterlassen hat, erfüllt die Schwelle **nicht** — solange kein Checkout mehr
herstellt, was Zähler trägt, hat die Rechnung ihren Eingang nicht. Fällt er negativ, hat sie nie
einen Gegenstand, und der Carveout geht in eine Folge-ADR über. **Was heute daraus folgt, ist ein
leeres `open/` statt einer Vorplanung, die auf einen Zustand zeigt, den es womöglich nie
gibt** — dieselbe Linie, mit der
[welle-09](../welle-09-modul-15-konformitaet.md) §4 ihre ungeschnittenen Slices führt.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md) | update | die Festlegung aus DoD (1) — Namen, Counter-Form, Pflicht-Labels, Ort der Division, Auflösungs-Trigger — in §5 neben Abweichung 1, die die Cache-Counter-Regeln bereits verlinkt. **Kein Adaptions-Eintrag:** eine adoptierte Modul-Regel umzusetzen ist keine Abweichung von ihr, und dass das Label `model.version` nur im Vordergrund vorliegt, steht dort schon als Abweichung 1 |
| Auswertung (Go), `Makefile`, `test/` + `test/mutations/` | **unverändert** | sie tragen die Rechnung und ihren Zahn; beide entstehen hinter dem Auflösungs-Trigger (oben). Ein `make`-Ziel über einem Bestand ohne Eingang wäre eine Ausgabe, die eine Rechnung behauptet ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) |

**Was die Rechnung mitbringt, wenn sie geschnitten wird** — hier festgehalten, weil es schon
entschieden ist und nicht zweimal entschieden werden soll: sie summiert den **Bestand**, nicht
eine Sitzung, und ihre Ausgabe nennt **Sitzungszahl und Zeitraum**, weil `make span-clean` die
Basis zurücksetzt und zwei Ausgaben über verschieden großen Beständen sonst nicht vergleichbar
wären. Entschieden hat das [slice-066](../done/slice-066-telemetrie-auswertung.md) (dort Frage
B), mit Begründung und Messung; hier gilt die Antwort.

## 4. Trigger

**`open` → `next`:** [slice-060](../done/slice-060-rollen-achse.md) ist **done** — vorher trägt
kein Span eine Rolle, und `agent.role` ist eines der drei Pflicht-Labels, über die die Festlegung
verfügt. **Der Zustand von
[`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) ist KEINE Eintritts-Bedingung**, und
das ist die Entscheidung des Schnitts (§3): eine Festlegung, die ohne Bestand gilt, darf nicht
auf eine Messung warten, die über den Bestand entscheidet. Der Carveout entscheidet die
**Rechnung**, und die liegt außerhalb dieses Slice.

**`next` → `in-progress`:** WIP-Limit — kein anderer Slice in `in-progress/`.

Rückführungen:

- `in-progress` → `next`: falls die Namensgebung ohne Metrik-Senke nicht festlegbar ist — dann
  ist zuerst zu entscheiden, wofür die Namen gelten, und der Slice hat keinen Gegenstand mehr,
  bis diese Frage beantwortet ist.
- `in-progress` → `open`: falls [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md)
  währenddessen **negativ** entschieden wird. Dann gilt die Festlegung für eine Rechnung, die es
  dauerhaft nicht gibt, und zuerst ist zu entscheiden, ob das Spec-Stratum sie trotzdem trägt
  oder ob die Zelle *Cache-Counter × Repo* von **deklariert** auf **ADR-Verdikt** wechselt. Das
  ist eine Architect-Frage und keine Implementierungs-Frage.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10) mit **ausgestelltem** Verdikt; Verifikation bestätigt
(Modul 11); `make gates` und `make mutate` grün; `git mv` nach `done/` (eigener Move-Commit,
eingehende Links im Zug danach); Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Die Hit-Rate, die hier festgelegt wird, ist eine Verhältniszahl über einer Teilmenge — und
  das gehört in die Festlegung, nicht erst in die Rechnung.** Sie rechnet über dieselben
  `Agent`-Spans wie die Token-Bilanz und deckt damit dieselben Läufe ab: die Vordergrund-Läufe,
  die es bis zur Auflösung von
  [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) nicht gibt. Was sie über den
  Haupt-Kontext sagt, ist nichts
  ([`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md)).
- **Zwei gelieferte Zähler, drei geführte Namen.** Der dritte Name ruht auf `input_tokens` aus
  derselben `usage` — kein eigener Cache-Zähler, sondern die Größe, gegen die der Miss-Spike
  sichtbar wird. Wer die drei später an eine Metrik-Senke gibt, muss diese Herkunft mitliefern,
  sonst liest sich der dritte wie ein Cache-Wert.
- **Zwei Posten aus dem Auswerter sind an diesen Slice übergeben und gehören zur Rechnung**
  ([slice-066](../done/slice-066-telemetrie-auswertung.md) §7, *Offen, mit Träger*): sie fallen an, wenn die
  Rechnung geschnitten wird, und stehen bis dahin hier, weil ihr Leser derselbe ist.
  (a) Ein **nicht existierender** Ablageort liefert dieselbe wohlgeformte leere Ausgabe wie ein
  **leerer**: `filepath.Glob` meldet über einem fehlenden Verzeichnis weder Treffer noch Fehler,
  und das vorangestellte `mkdir -p` des `make`-Ziels maskiert den Fall — ein vertippter Mount
  liest sich als Ergebnis. Das ist die Grenze aus
  [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt 4: *leer und als
  leer erkennbar*, nicht geraten. (b) Die Bestandszeile nennt die **Sitzungs-Ströme des
  Ablageorts**, nicht die **Streuung der Summe** — beides fällt auseinander, sobald ein Strom
  keine Zähler trägt oder einer die Summe dominiert. Wer den Nenner druckt, druckt beides oder
  benennt, welches er meint.
- **Nicht in diesem Slice:** die **Cache-Rechnung selbst** samt ihrem Zahn — sie wird geschnitten,
  wenn der Auflösungs-Trigger von
  [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) fällt (§3); die Token-Bilanz je Rolle
  ([slice-066](../done/slice-066-telemetrie-auswertung.md)),
  die Rollen-Achse ([slice-060](../done/slice-060-rollen-achse.md)) und die Tool-Ebene
  (slice-062/063).
- **Der Carveout führt die Rechnung heute nicht in seiner Verifikations-Liste.** Löst sich
  [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) positiv auf, ist der Cache-Teil von
  Block 3 fällig — und nichts im Carveout sagt es. Die Zeile gehört dorthin und damit dem
  Architect; dieser Slice benennt die Lücke, er schließt sie nicht.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Berührt wird eine Sub-Area, und sie ist GF (siehe Kurs Modul 5 §Worked Mini-Example): `spec/`
gehört zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
