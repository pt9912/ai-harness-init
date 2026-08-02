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
wird, ist am Sammelposten-Anteil **zum Teil** ablesbar: wer delegiert, aber nicht unter dem
Rollen-Typ, hebt ihn — sofern die Antwort seines Laufs Zähler trägt; wer den Schritt selbst im
Haupt-Kontext tut, erzeugt gar keinen Span. Eine mechanische Durchsetzung gibt es nicht.

## 2. Definition of Done

- [x] **(1) Die Konvention steht in
  [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5,
  und ihre Grenze steht daneben.** Wortlaut-Kern: Arbeit, die einer Harness-Rolle zugeordnet ist,
  läuft **unter dem Rollen-Typ**; der Haupt-Kontext orchestriert und ist der Sammelposten.
  **Die Grenze gehört in denselben Absatz:** eine mechanische Durchsetzung ist **nicht möglich**,
  weil ein Wächter über eine **Aufrufform** entscheidet, die ihm vor dem Start vorliegt — und
  hier unterbleibt gerade der Aufruf, den er sähe.
  Ein Guard wie der aus slice-060 kann hier also nicht entstehen — und das ist zu **sagen**, nicht
  durch Schweigen offenzulassen; in der Sensor-Spalte steht dann *kein Wächter* mit diesem Grund.
  **Der bindende Text trägt keine Entscheidungs- und keine Planungs-Kennung** — auch keine nackte
  `slice-`-Kennung, die dort kein Muster trifft und trotzdem verboten ist.
- [x] **(2) Die Berichtsgröße ist festgelegt — samt der Falle, die sie wertlos machen würde.**
  Der Sammelposten-Anteil aus [slice-066](../open/slice-066-telemetrie-auswertung.md) DoD (1) ist die
  Messgröße: groß heißt „nicht gelebt". Zwei Festlegungen gehören dazu, beide aus gemessenen
  Gründen:
  1. **Die Größe steht im Bericht, nicht als bestandene Schwelle.** Eine Kennzahl mit Grenze
     erzeugt den Anreiz, Arbeit zu verlagern, damit die Zahl stimmt — statt weil die
     Rollen-Trennung trägt.
  2. **„Span mit irgendeinem erfassten Wert" ist die falsche Definition von gedeckt.**
     **Gemessen** ist, dass die
     Antwort eines **Hintergrund**-Laufs `resolvedModel` trägt und **keinen** der acht übrigen
     Werte — keine Zähler, kein `agentType`. Ob daraus im Span ein `model_version` wird, hängt
     an der strukturellen Schranke aus
     [`spec/spezifikation.md`](../../../../spec/spezifikation.md#3-defaults-und-konstanten) §3
     und ist an keinem Span **beobachtet**; die Festlegung braucht das auch nicht: kommt der
     eine Wert an, zählt eine Abdeckungszahl über „Span mit irgendeinem erfassten Wert" genau
     die Läufe als gedeckt, deren Fehlen sie zeigen soll — kommt er nicht an, ruht dieselbe Zahl
     auf einer Schranke, die niemand vermessen hat. Beide Ausgänge sagen dasselbe: die
     Definition muss an den **Zählern** hängen.
- [x] **(3) Die Welle-Aussage steht als Festlegung, nicht als Zelle.** welle-09 verlangt je
  Matrix-Zelle *„einen laufenden Sensor, eine deklarierte Entscheidung mit Auflösungs-Trigger
  oder das Verdikt einer ADR, dass die Abweichung permanent ist; und nichts dazwischen"*. Für
  *Token-Attribution × Repo* ist heute genau **dazwischen**. Dieser Slice schreibt die
  **Festlegung**, dass die Zelle keinen „Sensor" trägt — ein Bericht ist kein Wächter — und
  welchen der übrigen Werte sie je Abweichung führt. **Ihre Belegart ist zweigeteilt, und das
  gehört in die Festlegung:** der Hintergrund-Teil (Abweichung 5) trägt **deklariert** samt
  Auflösungs-Trigger, der Haupt-Kontext das **ADR-Verdikt** *permanent* aus
  [`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) (**Proposed** — die Zelle trägt
  den Wert erst mit der Annahme) — dort fällt der Trigger nach
  Modul 7 §Werkzeug-Wahl weg. Wer die Zelle mit einem Trigger für **beides** ausfüllt, schreibt
  einen hin, den es nicht mehr gibt. Die Zelle selbst entsteht bei der Wellen-Closure in
  `welle-09-results.md`; sie hier abhaken zu wollen wäre eine Zusage über ein Artefakt, das es
  noch nicht gibt.

- [x] `make gates` grün.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md) | update | die Konvention aus DoD (1) und die Festlegungen aus DoD (2) in §5, unmittelbar an der Start-Konvention, deren Abgrenzung die Lücke wörtlich benennt. Beides trifft die [Aufnahme-Regel](../../../../spec/spezifikation.md#aufnahme-regel): gemessen wird gegen die **Festlegung** — welcher Lauf in den Sammelposten fällt, und was die Berichtsgröße zeigt und was nicht —, nicht an der Größe allein, die nur die delegierte Hälfte trägt; ohne Vertragsänderung fortschreibbar; die nächste Festlegung zur Größe ist ein weiterer Punkt ihrer Liste und verdrängt keinen anderen Text. **Kein Adaptions-Eintrag:** die Umkehrung *Sammelposten = Regel statt Ausnahme* steht dort bereits bindend (Abweichung 3 und 6); ein zweiter Ort driftet |
| [`slice-066`](../open/slice-066-telemetrie-auswertung.md) | keine Änderung | dort stehen in DoD (1) beide Größen, die diese Festlegung braucht, und sie stehen **getrennt**: der Sammelposten-Anteil (*„wie groß der aufgeteilte Anteil war"*, an leerem `spawned_role`) und die Abdeckungszahl (*„wie viele `Agent`-Spans überhaupt Zähler trugen"*). Die Lesart als Konventions-Messgröße steht im Stratum; sie ein zweites Mal in eine fremde DoD zu schreiben erzeugte den zweiten Ort, den die Zeile darüber vermeidet |
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
  Ebene — ob die Konvention ins Ziel-Repo mitgeht, entscheidet slice-062. Ebenso die
  **Nicht-Erreichbarkeit der Haupt-Kontext-Token**: sie steht als Abweichung 6 in
  [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
  und nennt dort **keinen Auflösungs-Trigger**. Wer an ihr einen Träger für einen Folge-Slice
  sucht, findet keinen — auch nicht in diesem Plan.
- **Die Belegart der Zelle hat einen ganzen und einen halben Träger, und der halbe ist
  Wellen-Ebene.** Der Hintergrund-Teil trägt *deklariert* und ist einlösbar: Geltungsbereich,
  Begründung und Auflösungs-Trigger stehen als erklärte Abweichung in Rang 2
  ([`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5),
  und die Wert-Tabelle von [welle-09](../welle-09-modul-15-konformitaet.md) macht den Wert an
  diesen drei Angaben fest statt am Gefäß — der Zielort folgt dem Gegenstand nach
  [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md). Das *ADR-Verdikt* für den
  Haupt-Kontext bindet dagegen erst mit der Annahme von
  [`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md); bis dahin steht für diese
  Hälfte ein Wert fest, dessen Träger noch *Proposed* ist. Die Zelle selbst wird bei der
  Wellen-Closure gefüllt, nicht hier — und sie ist erst füllbar, wenn über
  [`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) entschieden ist.

## 7. Closure-Notiz (nach `done/`)

**Was gilt.** Die Start-Konvention hat ihre zweite Hälfte: **dass** Arbeit, die einer
Harness-Rolle zugeordnet ist, unter dem Rollen-Typ läuft, steht in
[`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5,
und ihre Grenze steht im selben Absatz. Die Grenze ist kein Vorbehalt, sondern der Kern: ein
Wächter entscheidet über eine **Aufrufform**, die ihm vor dem Start vorliegt, und hier
unterbleibt gerade der Aufruf, den er sähe. **Diese Regel trägt deshalb keinen Wächter** — als
Satz, nicht als Schweigen. Daneben die Berichtsgröße mit zwei Festlegungen: der
Sammelposten-Anteil steht im **Bericht**, nie als bestandene Schwelle (eine Kennzahl mit Grenze
erzeugt den Anreiz, Arbeit zu verlagern, damit die Zahl stimmt), und *gedeckt* heißt *Span mit
**Zählern***, nicht *Span mit irgendeinem erfassten Wert*.

Für die Matrix-Zelle *Token-Attribution × Repo* ist der Wert *Sensor* ausgeschlossen — ein
Bericht läuft nicht als Gate, färbt nichts rot und hat keinen `test/mutations/`-Fall. Ihre
Belegart ist zweigeteilt: der Hintergrund-Teil trägt *deklariert*, und er ist einlösbar —
Geltungsbereich, Begründung und Auflösungs-Trigger stehen als erklärte Abweichung 5 in Rang 2,
und die Wert-Tabelle von [welle-09](../welle-09-modul-15-konformitaet.md) macht den Wert an
diesen drei Angaben fest statt an einem Gefäß, dessen Zielort
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) inzwischen anders setzt. Der
Haupt-Kontext trägt das ADR-Verdikt *permanent*; es bindet erst mit der Annahme von
[`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md).

**Die Auszählung, an der die Zusage hängt.** Sammelposten heißt nach der Feldtabelle
*„`Agent`-Span **ohne** `spawned_role`"*, und gehoben wird ein Anteil nur von Token. Über die
Formen, die ein delegierter Lauf annehmen kann, hebt **genau eine** den Anteil:

| Form | hebt den Anteil |
|---|---|
| Nicht-Rollen-Typ im Hintergrund — der Guard greift nur bei einer Datei in `.claude/agents/`, der Lauf fällt in den Sammelposten und trägt keinen der acht Werte an `usage`/`total*`/`agentType` | nein |
| Rollen-Typ im Hintergrund, Guard verdrahtet — abgelehnt, es entsteht gar kein Span | nein |
| Rollen-Typ im Hintergrund, Guard fehlend, abgeschaltet oder umgangen — fällt zählerlos hinein | nein |
| fehlgeschlagener Agenten-Aufruf — keine `tool_response`, kein erfasster Wert | nein |
| Vordergrund-Lauf, dessen Antwort keine Zähler trägt — im Bestand **beobachtet**: ein `Agent`-Span eines Rollen-Typs, dessen erfasster Wert-Satz aus genau `model_version` besteht | nein |
| Vordergrund-Lauf eines Nicht-Rollen-Typs, dessen Antwort Zähler trägt | **ja** — ein Bruch dieser Konvention ist er nur, wenn die delegierte Arbeit Rollen-Arbeit war |

Damit ist die Zusage so breit wie ihr Gegenstand: sichtbar ist die eine Form, und von ihr nur,
was Zähler trägt.

**Was der Slice nicht deckt.**

- **Kein Zahn, und der Grund ist der Gegenstand.** Zugesagt ist eine Aussage darüber, was
  messbar ist und was nicht; ein Wächter über einer Unmessbarkeit wäre die Zusage ohne
  Abdeckung, gegen die [`AGENTS.md`](../../../../AGENTS.md) §3.6 steht. Der Zahn liegt bei
  [slice-066](../open/slice-066-telemetrie-auswertung.md): fällt der Sammelposten-Anteil aus dem
  Bericht, muss ein Fall rot werden.
- **Die tragende Zusage ist *kein Wächter*, und ihre Folge steht mit ihr.** Die Konvention kann
  gebrochen werden, ohne dass irgendetwas rot wird. Die einzige Rückmeldung ist eine Größe, die
  eine der beiden Formen gar nicht erreicht — wer den Schritt selbst im Haupt-Kontext tut,
  erzeugt keinen `Agent`-Span und steht weder im Zähler noch im Nenner. **Klein heißt deshalb
  nicht „gelebt"**, und nur *groß* trägt eine Aussage.
- **Frage C** (Rollen-Ableitung für den Haupt-Kontext) bleibt offen; sie ist Vorbedingung für
  jede Splitting-Regel, nicht für diese Konvention.
- **Die emittierte Ebene.** Ob die Konvention ins Ziel-Repo mitgeht, entscheidet slice-062.
- **Die Nicht-Erreichbarkeit der Haupt-Kontext-Token** steht als Abweichung 6 in Rang 2 und
  nennt dort **keinen** Auflösungs-Trigger. Wer an ihr einen Träger für einen Folge-Slice sucht,
  findet keinen.
- **Die zweite Hälfte der Belegart** hängt an einer Entscheidung, die dieser Slice nicht trifft
  ([`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md), *Proposed*).

**Steering-Loop-Eintrag — geschärfte Regel.**

**Eine Zusage darüber, was eine Kennzahl sichtbar macht, wird in der Größe formuliert, aus der
die Zahl gebildet wird — nicht in den Umständen, die diese Größe üblicherweise erzeugen.** Die
Umstände (Aufrufform, Betriebsart, Delegations-Weg) sind empirische Begleiter der Größe, und
jeder Begleiter hat Gegenbeispiele, die einzeln gefunden werden müssen. Jede Einschränkung, die
einen Umstand nennt, ist deshalb nicht der Abschluss der Korrektur, sondern ihre nächste,
feinere Runde: *„sichtbar an der Berichtsgröße"* → *„sichtbar, wer delegiert, aber nicht unter
dem Rollen-Typ"* → *„nur im Vordergrund"* — drei Formulierungen derselben Zusage, drei Mengen,
und keine davon die, die die Zahl misst. Hier war die Größe **Token im Sammelposten**; erst
*„und von ihr nur, was Zähler trägt"* hat kein Gegenbeispiel, weil das die Definition der Zahl
ist und kein Korrelat.

**Warum die Nähe des Kriteriums nicht genügt.** *„Gedeckt heißt Span mit Zählern"* stand als
Punkt 2 derselben Festlegung zwei Zeilen unter dem Satz, den es korrigiert — und der Satz blieb
falsch. Ein Kriterium, das **neben** einer Zusage steht, wird nicht automatisch **auf** sie
angewandt.

**Anwendung, prüfbar am Text:** wer schreibt *„sichtbar ist …"*, *„gedeckt ist …"*,
*„erfasst ist …"*, nennt die Größe, aus der die Zahl entsteht, und prüft, ob das Prädikat in
deren Vokabular formuliert ist. Steht dort ein Umstand statt einer Größe, ist ein Gegenbeispiel
zu suchen, bevor der Satz steht — für die naheliegende Einschränkung *„nur im Vordergrund"* lag
es bereits **beobachtet** im Bestand.

**Offen, mit Träger.**

| Posten | Träger |
|---|---|
| Die Rollen-Liste steht zweimal und ist nicht gekoppelt: der Guard leitet sie aus `.claude/agents/` **ab**, `roleFromAgentType` in `internal/span/emit.go` führt sie als **hart notierte** Liste von sechs Namen (kein `.go` liest das Verzeichnis — gemessen: 0 Treffer). Eine siebte Rollen-Datei erzwänge den Vordergrund, der Lauf trüge Zähler, `spawned_role` bliebe leer — er hübe den Sammelposten-Anteil, **ohne ein Bruch zu sein**, und der Kommentar am Ort (*„wird ein Subagent unter dem Namen seiner Harness-Rolle gestartet, IST der Agenten-Typ die Rolle"*) wäre für ihn falsch. Heute 0 Instanzen: `ls -1 .claude/agents/` führt genau die sechs kanonischen Namen | kein Schnitt gelegt — Planner-Arbeit. Der Trigger ist beobachtbar und braucht kein Urteil: die **siebte** Datei in `.claude/agents/`. Die Zusage ist eine neue und braucht ihren eigenen rot gesehenen Zahn ([`AGENTS.md`](../../../../AGENTS.md) §3.6) |
| Ein gehobener Sammelposten-Anteil belegt keinen Bruch — die Zahl trägt beide Fälle. Wer sie druckt, sagt das dazu | [slice-066](../open/slice-066-telemetrie-auswertung.md) DoD (1), wo die Größe entsteht |
| Zwei Textmängel in Rang 2: die Historie-Zeile zählt den Inhalt von §5 auf und nennt die zwei hier hinzugekommenen Festlegungen nicht; im bindenden Absatz zeigen *er* und *seiner* auf ein Substantiv (*der Bruch*), das im Dokument nicht mehr steht | die nächste Änderung an §5 — geplant ist [slice-066](../open/slice-066-telemetrie-auswertung.md) DoD (3). Keine Wirkung auf eine DoD, kein Gate greift |
| [`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) steht auf *Proposed*; ohne Verdikt ist die Matrix-Zelle nicht füllbar | Architect — Vorbedingung der welle-09-Closure, nicht dieses Slice |

**Gates.** `make gates` **Exit 0**: `baseline-verify: v3.5.2 OK — 42 Dateien`,
`d-check: 287 Datei(en) geprüft, 0 Befund(e)`, `1..150` bats ohne `not ok`,
`comment-claims: 38 Datei(en) geprueft, 0 Befund(e)`, `span-check` ok.
`make mutate` deckt diesen Baum, ohne neu zu laufen: der Bogen des Slice besteht ausschließlich
aus Markdown unter `spec/` und `docs/` (`git diff --name-only ddb27d1..HEAD | grep -v '\.md$'` →
0 Treffer), und von den **36** eindeutigen `# files:`-Zielen der 135 Fälle liegt **keines** darin
(`comm -12` → 0 Zeilen). Der Beleg ist der CI-Vollauf auf `13e9ac9`: `mutate: 135 ok, 0
Befund(e)`. Ein neuer Zahn ist nicht fällig — kein Code, kein neuer Wächter.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `spec/` und
`docs/plan/` gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
