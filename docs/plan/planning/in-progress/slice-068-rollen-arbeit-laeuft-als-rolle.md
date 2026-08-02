# Slice slice-068: Rollen-Arbeit läuft als Rolle — die Konvention und ihre Berichtsgröße

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-09](../welle-09-modul-15-konformitaet.md) — er berührt die **Welle-Aussage**
selbst (die 4 × 2-Matrix), nicht nur einen Slice.

**Bezug:** [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
§5 (die Start-Konvention, deren zweite Hälfte hier entsteht — ihre Abgrenzung benennt die Lücke
wörtlich: *„**DASS** Rollen-Arbeit überhaupt als Rolle läuft, ist eine andere Regel und steht nicht
hier"*), [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted** — Festlegung 1
Punkt 5, die Reihenfolge Prüfung vor Abweichung). Regelwerk-Quelle:
`.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md` §Token-Attributions-Regeln sowie
`modul-08-agentenrollen.md` §Rollen-Regeln.

**Bewusst KEINE `LH-*`-Kennung.** Geprüft: keine der zwölf Anforderungen trifft die
Dogfood-Prozessebene. Die naheliegende
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) verlangt
*„jeder **emittierte** Gate-Target läuft auf frischem Checkout"* — die emittierte Ebene, nicht
diese; sie hier zu führen war schon in slice-059 ein Befund. Die `requirement`-Achse dieses Slice
bleibt deshalb **leer und erkennbar** statt gefüllt und falsch.

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-30, neu geschnitten 2026-07-31.

---

## 1. Ziel

**Die Konvention sagt, WAS als Rolle läuft — nicht nur, WIE.**
[slice-060](../done/slice-060-rollen-achse.md) hat die Betriebsart geregelt: **wie** ein
Rollen-Lauf startet (@-Erwähnung + Vordergrund), erzwungen vom `PreToolUse`-Guard. Was fehlt, ist
der Satz davor — **dass** Rollen-Arbeit überhaupt unter einem Rollen-Typ läuft. Die Festlegung
benennt die Lücke selbst und grenzt sich gegen sie ab.

Der Unterschied ist keine Wortklauberei: der Guard erzwingt den Vordergrund für Rollen, die man
**startet**, und schweigt, wenn man den Reviewer gar nicht startet, sondern selbst reviewt.

**Die zweite Hälfte ist die Messgröße.** Modul 15 §Token-Attributions-Regeln unterstellt, der
Sammelposten sei die **Ausnahme**; in diesem Repo ist er die **Regel**. Ob die Konvention gelebt
wird, ist am Sammelposten-Anteil ablesbar — und nur dort, denn eine mechanische Durchsetzung gibt
es nicht.

## 2. Definition of Done

- [ ] **(1) Die Konvention steht in
  [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5,
  und ihre Grenze steht daneben.** Wortlaut-Kern: Arbeit, die einer Harness-Rolle zugeordnet ist,
  läuft **unter dem Rollen-Typ**; der Haupt-Kontext orchestriert und ist der Sammelposten.
  **Die Grenze gehört in denselben Absatz:** eine mechanische Durchsetzung ist **nicht möglich**,
  weil niemand maschinell entscheiden kann, ob eine Haupt-Kontext-Handlung „Planner-Arbeit" war.
  Ein Guard wie der aus slice-060 kann hier also nicht entstehen — und das ist zu **sagen**, nicht
  durch Schweigen offenzulassen; in der Sensor-Spalte steht dann *kein Wächter* mit diesem Grund.
  **Der bindende Text trägt keine Entscheidungs- und keine Planungs-Kennung** — auch keine nackte
  `slice-`-Kennung, die dort kein Muster trifft und trotzdem verboten ist.
- [ ] **(2) Die Berichtsgröße ist festgelegt — samt der Falle, die sie wertlos machen würde.**
  Der Sammelposten-Anteil aus [slice-066](../open/slice-066-telemetrie-auswertung.md) DoD (1) ist die
  Messgröße: groß heißt „nicht gelebt". Zwei Festlegungen gehören dazu, beide aus gemessenen
  Gründen:
  1. **Die Größe steht im Bericht, nicht als bestandene Schwelle.** Eine Kennzahl mit Grenze
     erzeugt den Anreiz, Arbeit zu verlagern, damit die Zahl stimmt — statt weil die
     Rollen-Trennung trägt.
  2. **„Span mit Zählern" ist die falsche Definition von gedeckt.** **Gemessen** ist, dass die
     Antwort eines **Hintergrund**-Laufs `resolvedModel` trägt und **keinen** der acht übrigen
     Werte — keine Zähler, kein `agentType`. Ob daraus im Span ein `model_version` wird, hängt
     an der strukturellen Schranke aus
     [`spec/spezifikation.md`](../../../../spec/spezifikation.md#3-defaults-und-konstanten) §3
     und ist an keinem Span **beobachtet**; die Festlegung braucht das auch nicht: kommt der
     eine Wert an, zählt eine Abdeckungszahl über „Span mit irgendeinem erfassten Wert" genau
     die Läufe als gedeckt, deren Fehlen sie zeigen soll — kommt er nicht an, ruht dieselbe Zahl
     auf einer Schranke, die niemand vermessen hat. Beide Ausgänge sagen dasselbe: die
     Definition muss an den **Zählern** hängen.
- [ ] **(3) Die Welle-Aussage steht als Festlegung, nicht als Zelle.** welle-09 verlangt je
  Matrix-Zelle *„einen laufenden Sensor, eine deklarierte Entscheidung mit Auflösungs-Trigger
  oder das Verdikt einer ADR, dass die Abweichung permanent ist; und nichts dazwischen"*. Für
  *Token-Attribution × Repo* ist heute genau **dazwischen**. Dieser Slice schreibt die
  **Festlegung**, dass die Zelle keinen „Sensor" trägt — ein Bericht ist kein Wächter — und
  welchen der übrigen Werte sie je Abweichung führt. **Ihre Belegart ist zweigeteilt, und das
  gehört in die Festlegung:** der Hintergrund-Teil (Abweichung 5) trägt **deklariert** samt
  Auflösungs-Trigger, der Haupt-Kontext das **ADR-Verdikt** *permanent* aus
  [`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) — dort fällt der Trigger nach
  Modul 7 §Werkzeug-Wahl weg. Wer die Zelle mit einem Trigger für **beides** ausfüllt, schreibt
  einen hin, den es nicht mehr gibt. Die Zelle selbst entsteht bei der Wellen-Closure in
  `welle-09-results.md`; sie hier abhaken zu wollen wäre eine Zusage über ein Artefakt, das es
  noch nicht gibt.

- [ ] `make gates` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

**Was aus diesem Slice ENTFALLEN ist (2026-07-31):** der frühere DoD (2) — die
Nicht-Erreichbarkeit der Haupt-Kontext-Token als erklärte Abweichung mit Auflösungs-Trigger — ist
von [slice-060](../done/slice-060-rollen-achse.md) DoD (3) geliefert worden und steht als
Abweichung 6 in
[`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5:
dieselbe Reihenfolge (Prüfung → Abweichung → Einordnung) und dieselbe Sache. Ihn hier stehen zu
lassen hätte eine zweite Wahrheit über denselben Sachverhalt erzeugt. **Die Einordnung ist
inzwischen eine andere als die des entfallenen DoD-Punktes:** wo er einen Auflösungs-Trigger
vorsah, trägt Abweichung 6 das Verdikt *permanent* — der Modul-7-Trichter hat sie in
[`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) übergeführt.
**Die Prüfschritte sind nicht dieselben, und das gehört genannt, damit niemand die Gleichheit
statt der Sache prüft:** der frühere DoD (2) führte (a) Zähler nur in `tool_response`,
(b) Transkripte als Quelle ausgeschlossen, (c) `SubagentStart` trägt keine Token. Abweichung 6
führt (a) unverändert als ihren ersten Schritt, fasst (b) und (c) zum dritten („eine zweite
Quelle?") zusammen und schiebt als **zweiten** einen neuen dazwischen: ob die Token aus den
bereits erfassten Feldern (`result_bytes`, `duration_ms`) **ableitbar** wären — mit der Antwort
nein und dem Verweis auf
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt 4. Drei gegen
drei ist damit ein Zufall der Zählung: geliefert wurde ein Schritt mehr, und zwei sind
verschmolzen.
**Es gibt keinen Auflösungs-Trigger mehr, an dem ein Slice hängen könnte** — auch nicht an
diesem. Abweichung 6 sagt das inzwischen selbst und begründet es aus Modul 7: die Bedingung ist
nicht durch Aufwand herbeizuführen, also ist die Ausnahme permanent und gehört in eine ADR statt
in einen Folge-Slice. Wer hier einen Träger sucht, findet keinen — und soll auch keinen aus
dieser Notiz ableiten.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md) | update | die Konvention aus DoD (1) und die Festlegungen aus DoD (2) in §5, unmittelbar an der Start-Konvention, deren Abgrenzung die Lücke wörtlich benennt. Beides trifft die [Aufnahme-Regel](../../../../spec/spezifikation.md#aufnahme-regel): messbar an der Berichtsgröße, ohne Vertragsänderung fortschreibbar, mit jeder weiteren Rolle wachsend. **Kein Adaptions-Eintrag:** die Umkehrung *Sammelposten = Regel statt Ausnahme* steht dort bereits bindend (Abweichung 3 und 6); ein zweiter Ort driftet |
| [`slice-066`](../open/slice-066-telemetrie-auswertung.md) | update | die Definition des Sammelposten-Anteils an den **Zählern** statt an „irgendeinem Wert"; die Lesart als Konventions-Messgröße |
| [welle-09](../welle-09-modul-15-konformitaet.md) | update | DoD (3) legt die Belegart der Zelle *Token-Attribution × Repo* fest. Der Welle-Plan führt dieselbe Aussage an zwei Stellen — in der Wert-Tabelle seines Closure-Triggers und in der Slice-Zeile zu diesem Slice. Kommt die Festlegung anders heraus als dort beschrieben, ziehen beide Stellen nach; sonst steht dieselbe Aussage zweimal verschieden im Repo |

**Kein Code, kein neuer Wächter.** Das ist beabsichtigt; der Grund steht in §6.

## 4. Trigger

**`open` → `next`:** [slice-060](../done/slice-060-rollen-achse.md) ist **done** — er
schreibt in denselben
[§5](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder)-Abschnitt, und zwei
gleichzeitige Änderungen daran erzeugen vermeidbare Konflikte.

**`next` → `in-progress`:** WIP-Limit.

Rückführungen:

- `in-progress` → `next`: falls sich zeigt, dass die Konvention ohne Frage C (Rollen-Ableitung
  für den Haupt-Kontext, slice-060 §3) unvollständig bleibt. Dann ist Frage C zuerst zu
  entscheiden und dieser Slice neu zu schneiden.
- `in-progress` → `open`: falls die Berichtsgröße vor slice-066 nicht festlegbar ist, weil ihre
  Form dort noch offen ist. Dann kehrt die Reihenfolge sich um.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10); Verifikation bestätigt (Modul 11); `make gates` grün;
`git mv` nach `done/` (eigener Move-Commit); Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Ein Slice ohne Zahn ist in diesem Repo ein Geruch.** Hier ist er begründet: der Gegenstand
  *ist* eine Aussage darüber, was messbar ist und was nicht. Ein Wächter, der eine Unmessbarkeit
  bewacht, wäre die Zusage ohne Abdeckung, gegen die
  [`AGENTS.md`](../../../../AGENTS.md) §3.6 steht. Der Zahn liegt bei
  [slice-066](../open/slice-066-telemetrie-auswertung.md): fällt der Sammelposten-Anteil aus dem Bericht,
  muss ein Fall rot werden.
- **Eine Konvention ohne Durchsetzung wird gebrochen — auch von mir.** Belegt an der Arbeit an
  slice-060: Planner und Implementation liefen über weite Strecken in **einem** Kontextfenster,
  genau das, was Modul 8 §Rollen-Regeln ausschließt (*„aber nicht im selben Kontextfenster, sonst
  wiederholen sich die blinden Flecken"*). Der Sammelposten-Anteil macht das sichtbar; er
  verhindert es nicht.
- **Die Berichtsgröße hängt an slice-066.** Wird dort die Definition anders geschnitten, hängt
  DoD (2) in der Luft. Deshalb die Rückführungskante in §4.
- **Nicht in diesem Slice:** Frage C (Rollen-Ableitung für den Haupt-Kontext) und die emittierte
  Ebene — ob die Konvention ins Ziel-Repo mitgeht, entscheidet slice-062.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `spec/` und
`docs/plan/` gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
