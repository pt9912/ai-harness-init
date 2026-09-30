# ADR-0075: Die Begründungen des Fließtexts von Spec §5 stehen hier, nicht in der Spezifikation — die Sammel-ADR aus ADR-0074 Festlegung 6

**Status:** Accepted

**Datum:** 2026-09-30

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (der Träger, dessen Schema §5 führt),
[ADR-0074](0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) (**Accepted** — Festlegung 1 setzt die Klasse
Begründung, Festlegung 6 verlangt diese ADR; Festlegung 13 und E3 den Ort der Prozess-Konventionen),
[ADR-0011](0011-telemetrie-erfassung-policy.md),
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md),
[ADR-0019](0019-agent-guard-prueft-die-aufrufform.md),
[ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (**Accepted**; jede trägt eine der Begründungen
bereits oder als Beleg, s. Kontext),
[`MR-025`](../../../harness/conventions.md#mr-025) (Zahl neben Kommando),
[`AGENTS.md`](../../../AGENTS.md) §3.4, §3.6, §3.7, §3.8,
der [Klassifikationsbericht](../../reviews/2026-09-30-slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert-klassifikation.md)
(Zeitdokument in der stehenden Ablage `docs/reviews/`; „Einheit Unn" unten meint eine Zeile seiner Tabelle)

**Schärft:**
[`spec/spezifikation.md §5 Metriken und Tracing-Felder`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder).
§5 trägt keine Unterabschnitte und die Zeilen ab `SPEC-035` existieren noch nicht; die Festlegungen unten sind
deshalb nach dem **Gegenstand** benannt, den sie begründen, und stehen in der Reihenfolge, in der §5 diese
Gegenstände führt (ADR-0074 Festlegung 6). Aufwärts-Deklaration: wer diese ADR ändert, zieht §5 nach. Die
Spezifikation nennt diese ADR nie.

---

## Kontext

**Was diese ADR ist.** [ADR-0074](0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) Festlegung 1 führt
die Klasse *Begründung* (`b`) — *warum diese Regel und nicht die andere* — und weist sie einer Sammel-ADR zu,
nie der Spezifikation; Festlegung 6 verlangt sie vor dem ersten Umbau, der einen Begründungstext entfernt. Diese ADR
trägt die Begründungen der Klasse `b` und die Begründungs-Anteile der Einheiten mit zwei Klassen. **Sie entscheidet
nichts Neues:** jede Festlegung unten gibt wieder, was §5 heute begründet, wörtlich oder verdichtet. Was eine
Zeile der Spezifikation *festlegt*, steht dort; hier steht nur das *Warum*.

**Menge.** Der Klassifikationsbericht führt 10 Zeilen der Klasse `b` (3293 Byte); sie sind U04, U12b, U13, U15b,
U16, U24b, U34, U35, U52b und U62b:

```sh
F=docs/reviews/2026-09-30-slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert-klassifikation.md
awk -F'|' '/^\| U[0-9]+b? / {gsub(/ /,"",$5); if($5=="b"){n++; s+=$8}} END{print n, s}' $F      # 10 3293
awk -F'|' '/^\| U[0-9]+b? / {gsub(/ /,"",$5); if($5=="b") print $2}' $F | tr -d ' ' | tr '\n' ' '   # U04 U12b U13 U15b U16 U24b U34 U35 U52b U62b
```

Die Zahlen messen den Stand des Berichts und sind keine Erwartungswerte
([`MR-025`](../../../harness/conventions.md#mr-025)). **Nach ADR-0074 Festlegung 2 ändern sich vier Zuordnungen:**
U16 und U35 sind Klasse `a` (die Grenze der Kennzahl gehört in ihre Zeile; die Regel ist keine Messung), U42 trägt
einen Begründungsanteil, U15b bleibt Begründung, gehört aber zu einer Einheit der Klasse `p`. Diese ADR nimmt darum
U04, U12b, U15b, U34, den Begründungsanteil von U42, U52b und U62b auf und benennt U13 und U24b als bereits
getragen. **Nicht aufgenommen sind U16 und U35:** nach ADR-0074 Klasse `a`, ihr Satz bleibt Zeile.

**Was schon in einer `Accepted`-ADR steht, wird nicht kopiert** (ADR-0074 Festlegung 6). Geprüft am Wortlaut, am
Stand vor dieser ADR (`3a5ccf54`, der Annahme-Commit von ADR-0074):

| Einheit | Begründung | Träger | Kommando (Ausgabe) |
|---|---|---|---|
| U13 | der Guard entscheidet die Aufrufform, nicht die Betriebsart; eine Forderung nach einer Betriebsart, die kein Aufruf mehr tragen kann, verweigert alles und schützt nichts | [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) Festlegung 1 („…sie verweigert die Läufe, die sie regeln sollte, und schützt dabei nichts") | `git grep -c 'schützt dabei nichts' 3a5ccf54 -- docs/plan/adr/0019-agent-guard-prueft-die-aufrufform.md` → 1 |
| U24b | eine Doppelvergabe von `seq` erzeugt keine Lücke und sieht wie Vollständigkeit aus; der Nummernkreis gehört zu `(Sitzung, Agent)` | [ADR-0011](0011-telemetrie-erfassung-policy.md) Folgepflicht 4 | `git grep -c 'Doppelvergabe erzeugt keine Lücke' 3a5ccf54 -- docs/plan/adr/0011-telemetrie-erfassung-policy.md` → 1 |

Für die übrigen Begründungen trägt keine `Accepted`-ADR den Wortlaut; die Suchmuster (ein Kernsatz je Begründung)
finden vor dieser ADR nichts:

```sh
for p in 'Negativ-Liste' 'Dauer des Aufrufs' 'Aufruf, den er sähe' 'Slice→Rolle' 'geraten, nicht gelesen' 'falsch geroutet' 'Namen in der Fehlschlag' 'neues Feld ist eine Entscheidung'; do
  git grep -il "$p" 3a5ccf54 -- docs/plan/adr | wc -l; done | tr '\n' ' '                # 0 0 0 0 0 0 0 0
```

Der Beleg der Begründung zu U04 ist in [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) §Re-Evaluierungs-Trigger
festgehalten (die Payload-Fläche wächst belegbar); er wird dort gelesen, nicht hier wiederholt.

**Grenze.** Die Zuordnung *Begründung gegen Festlegung* ist Urteil, kein Sensor prüft sie
([ADR-0074](0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) Fitness Function, Zeile 6). Akzeptiertes
Negativ: eine Zeile der Spezifikation zeigt nicht auf ihre Begründung; die Auffindbarkeit läuft über den
Gegenstands-Namen der Festlegung unten.

## Entscheidung

**Wir wählen Option C: eine Sammel-ADR, deren Festlegungen je einen Gegenstand aus §5 begründen.** Die Begründungen
verlassen die Spezifikation (Klasse `b`, [ADR-0074](0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md)
Festlegung 1); die Festlegungen der Spezifikation selbst bleiben Zeilen der Tabellen. Diese ADR schreibt keinen
Spec-Text und ändert keine Zeile der Spezifikation.

### Festlegung 1 — die Erfassung aus `tool_response` ist eine Positiv-Liste (Einheit U04)

**Gegenstand in §5:** *„Positiv und nicht negativ"* (Erfassung aus `tool_response`).

Erfasst wird, was eine Liste namentlich nennt, und nicht alles außer einer Liste des Verbotenen. Eine
Negativ-Liste altert mit jedem neuen Antwortfeld des Werkzeugs: was sie nicht kennt, läuft durch. Eine Positiv-Liste
hält auch beim nächsten Freitext-Feld, denn ein neuer Schlüssel steht auf ihr nicht und bleibt draußen. Die Fläche der
Antwort wächst belegbar weiter ([ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) §Re-Evaluierungs-Trigger), und
ein Freitext-Feld — `prompt` insbesondere — darf nie ins Log; die Form ist deshalb tragend, nicht bequem.

### Festlegung 2 — ein Ereignis nach dem Aufruf: die kleine Dauer ist die Dauer des Aufrufs (Einheit U12b)

**Gegenstand in §5:** *„Die zwei Bedingungen sind UNABHÄNGIG"* (die Messung eines per @-Erwähnung angeforderten Laufs
ohne Schalter).

Der Hook feuert nach dem Aufruf (`PostToolUse`); die Dauer im Span ist damit die Dauer des **Aufrufs**, nicht die des
Laufs. Das Werkzeug gibt bei einem Hintergrund-Lauf sofort nach dem Start zurück. Genau darum trägt die Beobachtung
etwas: feuerte der Hook beim Start, stünde bei jedem Lauf dieselbe kleine Zahl da, und sie wäre leer. Die Messung, die
das zeigt, steht in
[`docs/reviews/2026-08-02-span-schema-messreihen.md`](../../reviews/2026-08-02-span-schema-messreihen.md); die
@-Erwähnung wählt den Typ, nicht die Betriebsart.

### Festlegung 3 — Rollen-Arbeit als Rolle läuft ohne Wächter, und warum (Einheit U15b)

**Gegenstand in §5:** *„DASS Rollen-Arbeit als Rolle läuft — die Regel, und warum sie keinen Wächter trägt"*. Die Regel
selbst ist Prozess-Konvention (`p`, [ADR-0074](0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) R3) und liegt
in [`docs/user/rollen-laeufe.md`](../../user/rollen-laeufe.md); diese Festlegung trägt ihr *Warum*.

Ein Wächter wie der Agent-Guard ([ADR-0019](0019-agent-guard-prueft-die-aufrufform.md)) entscheidet über eine
**Aufrufform**, die ihm vor dem Start vorliegt. Hier unterbleibt gerade der Aufruf, den er sähe: wer den Schritt selbst
im Haupt-Kontext tut, ruft keinen Subagenten. Das ist konstruktiv, nicht aus Aufwand. Was die Splitting-Regel
(Festlegung 4) aus zwei erfassten Feldern ableitet, teilt den Sammelposten **im Nachhinein** auf; eine Entscheidung vor
der Handlung ist es nicht. Die Regel trägt deshalb keinen Wächter, und sie kann gebrochen werden, ohne dass etwas rot
wird — diese Grenze steht in der Konvention selbst.

### Festlegung 4 — die Splitting-Regel: anteilig nach Tool-Calls (Einheiten U34, U32, U17)

**Gegenstand in §5:** *„Warum diese und nicht die andere"* (Splitting-Regel zu `agent_role`), *„Der Rest der
Ganzzahl-Division wird weitergegeben"* (U32) und *„Der Anteil steht im Bericht, nie als bestandene Schwelle"* (U17).
Die Regel selbst ist Festlegung (`a`) und bleibt Zeile.

- **Warum nicht dem auslösenden Slice zuschlagen.** Das Modul bietet zwei Regeln an (anteilig nach Tool-Calls; dem
  auslösenden Slice zugeschlagen,
  [`modul-15-observability.md`](../../../.harness/baseline/v6.13.0/regelwerk/modul-15-observability.md)). Die zweite
  scheidet aus, weil sie die falsche Größe liefert: die Prüfreihenfolge der Spezifikation verlangt, dass am Ende jedes
  Token auf einer **realen Rolle** liegt, und ein Slice läuft durch **alle** Rollen — das Glied Slice→Rolle liefert das
  Modul nicht mit. Dass das `slice`-Feld das stärkere Signal ist, ändert daran nichts: Signal-Stärke ersetzt keine
  Zuordnung.
- **Warum der Rest weitergegeben wird.** Damit die Summe der Zuteilungen **genau** dem Sammelposten entspricht. Ein
  liegengebliebenes Token stünde auf keiner Zeile, während die Ausgabe es als verteilt nennt.
- **Warum der Anteil nie eine Schwelle ist.** Eine Kennzahl mit Grenze erzeugt den Anreiz, Arbeit zu verlagern, damit
  die Zahl stimmt, statt weil die Rollen-Trennung trägt. Gezeigt wird die Größe; entschieden wird an ihr nichts.
- **Was die Regel nicht ist:** eine Messung. Sie verteilt Etiketten auf gemessene Token
  ([ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) Festlegung 3 sagt dasselbe von der offenen Rollen-Frage); sie
  erzeugt keine.

### Festlegung 5 — der Agent-Guard: ein fehlender Typ gilt als unlesbar (Begründungsanteil von U42)

**Gegenstand in §5:** *„Der Guard entscheidet die Lesbarkeit der Aufrufform"* (Prüfschritt zur Abweichung 5, jetzt
Zeile mit Bezug `Lücke`). Die Aufrufform-Entscheidung als Ganzes trägt
[ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) Festlegung 1; die Begründung des einen Zweigs stand bisher nur
in §5.

Der Hook hängt an `"matcher": "Agent"` und sieht deshalb keinen Nicht-Agenten-Aufruf. Ohne Subagent-Typ ist die Form
geraten, nicht gelesen; ein fehlender Typ gilt darum als unlesbarer Aufruf und wird abgewiesen. Das ist keine
Selbstverständlichkeit, sondern die Stelle, an der ein Guard still durchlässig würde. Dass Abweichung 5 keine
Abweichung von einer Modul-Regel ist, ist Einstufung ([ADR-0074](0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md)
Festlegung 3 und R4), keine Begründung dieser Stelle.

### Festlegung 6 — zwei Wächter-Sätze der Zusicherungs-Liste (Einheiten U52b, U62b)

**Gegenstand in §5:** *„Bewacht"*, Punkt *Der Einstiegspunkt selbst* und Punkt *Die Draht-Form von `spawned_role`*. Die
Zuordnung Test ↔ Zusicherung selbst gehört zu ADR-0074 Festlegung 12 und E4; hier stehen nur die zwei *Warum*.

- **Warum der Einstiegspunkt einen eigenen Fall braucht (U52b).** Seit die zwei Unterkommandos (Schreiber und
  Auswertung) in einem Träger liegen
  ([ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 2), trennt kein eigenes Binär mehr,
  was läuft; allein der Zweig entscheidet. Ein falsch geroutetes `span-emit` sieht im Betrieb aus wie Erfolg. Ein Fall,
  der den Zweig umhängt, ist darum die einzige Stelle, an der es auffällt.
- **Warum zwei Einträge zwei Zähne brauchen (U62b).** Der Treiber sucht je Fall genau **einen** Namen in der
  Fehlschlag-Ausgabe; ein Fall kann höchstens einen `mustNotContain`-Eintrag binden, auch wenn seine Mutation beide
  Wächter rot färbt. Die zwei Zähne tragen deshalb dieselbe Mutation und unterscheiden sich nur in ihrer
  `# expect:`-Zeile. Die Struktur-Prüfung `s.SpawnedRole != ""` deckt den Eintrag nicht ab: das Feld ist in **beiden**
  Draht-Formen `""`, über An- oder Abwesenheit entscheidet allein das JSON-Tag — darum ist der Eintrag tragend.

### Festlegung 7 — `prompt_id` bleibt abgelehnt (Begründungsanteil von U19)

**Gegenstand in §5:** *„Die Payload ist die Quelle, die Doku ist Herkunft"* (abgelehnte Felder `cwd`, `effort`,
`prompt_id`). Die Ablehnung selbst bleibt Zeile.

`prompt_id` ist ein ernsthafter Kandidat (*„welche Aufrufe gehören zu einer Nutzer-Anweisung?"*), aber ein neues Feld
ist eine Entscheidung und keine Gelegenheit: ein Feld kommt mit einer Incident-Frage ins Schema, nicht weil die Payload
es führt. `cwd` steht implizit im Pfad, `effort` beantwortet keine Incident-Frage.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun: die Begründungen bleiben im Fließtext von §5 | kein Aufwand | die Klasse `b` bliebe in der Spezifikation, die nach der Aufnahme-Regel nur Festlegungen trägt; jeder Umbau-Schritt entschiede für sich, ob eine Begründung fällt |
| B — je Block eine ADR | jede ADR nennt ihre `SPEC-<NNN>` in `Schärft:` | braucht die Zeilen zuerst: ein Architect-Schritt in der Mitte jedes Umbaus ([ADR-0074](0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) Verglichene Alternativen, E) |
| **C — eine Sammel-ADR, nach Gegenstand gegliedert (gewählt)** | ein Architect-Schritt vor dem ersten Umbau; jede Begründung hat eine Adresse | die Rückwärts-Auffindbarkeit läuft über den Gegenstands-Namen, nicht über eine Kennung |
| D — die Begründungen in Adaptions-Einträge | der Konventionsspeicher trägt Begründungen bereits | ein Eintrag registriert eine Abweichung; die Begründungen hier sind keine ([`MR-000`](../../../harness/conventions.md#mr-000)) |

## Konsequenzen

- **Positiv:** jede Begründung, die aus §5 fällt, hat einen Ort; die Umbau-Schritte brauchen keinen Architect-Schritt in
  der Mitte; wo eine `Accepted`-ADR die Begründung schon trägt, steht ein Link statt einer Kopie.
- **Negativ, benannt:** die Sammel-ADR ist nach Gegenstand gegliedert, nicht nach Zeile; wer eine Zeile ändert, sucht
  die Begründung über den Gegenstands-Namen. Sie ist ab `Accepted` unveränderlich — eine später gefundene Begründung
  kommt in eine Folge-ADR.
- **Folgepflichten:** (1) der Umbau-Schritt, der eine Begründung aus §5 entfernt, prüft, ob sie unter den
  Festlegungen 1 bis 7 oder unter den Trägern der Kontext-Tabelle steht; fehlt sie, meldet er die Lücke an den
  Architect statt sie zu streichen. (2) Die Prozess-Konvention, deren *Warum* Festlegung 3 trägt, steht in
  [`docs/user/rollen-laeufe.md`](../../user/rollen-laeufe.md); der Umbau-Schritt entfernt sie aus §5. (3) Die
  Begründungen der echten Abweichungen (Klasse `d`) stehen nicht hier, sondern in den Adaptions-Einträgen
  ([ADR-0074](0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) Festlegung 3, E1).

## Fitness Function (falls maschinell prüfbar)

Keine Festlegung dieser ADR trägt ein Gate: sie setzt Begründungen ab, keine prüfbare Eigenschaft.
[`AGENTS.md`](../../../AGENTS.md) §3.6: wo kein Rot herstellbar ist, steht die Lücke.

| Zusage | Tooling | Regel | rot, wenn |
|---|---|---|---|
| Sammel-ADR ändert sich nach Annahme nicht | `make adr-immutable` | Kern einer `Accepted`-ADR über der Range unverändert | eine inhaltliche Änderung dieser ADR nach `Accepted` |
| Die Begründungen stehen nicht mehr in §5 | Messkommando (Block unter der Tabelle) | nach dem Umbau der Blöcke 0 Treffer der Kernsätze im Fließtext | ein Kernsatz einer Festlegung 1 bis 7 steht noch in §5. **Lücke:** die Kernsätze sind Auswahl, kein Vollständigkeits-Sensor; die Zuordnung *Begründung gegen Festlegung* bleibt Urteil der Review des Umbau-Schritts |
| Jede Begründung hat einen Träger | — | **keiner** | eine aus §5 entfernte Begründung steht weder hier noch in einer `Accepted`-ADR. Träger ist die Review des Umbau-Schritts |

Messkommando (Stand `3a5ccf54`: 6 Zeilen; nach dem Umbau 0). Der Bereich läuft vom Anker `SPEC-034`
(letzte Tabellenzeile heute; der Anker wandert mit neuen Zeilen, der Umbau-Schritt passt ihn an) bis `## 6. Externe`:

```sh
awk '/^\| `SPEC-034`/{f=1;next} /^## 6\. Externe/{f=0} f' spec/spezifikation.md | grep -v '^|' | grep -cE 'Negativ-Liste|Dauer des \*\*Aufrufs\*\*|Slice→Rolle|geraten, nicht|falsch geroutetes|EIGENEN'
```

## Re-Evaluierungs-Trigger

- **Wenn ein Umbau-Schritt eine Begründung findet, die unter keiner Festlegung steht und in keiner `Accepted`-ADR**
  *(feedforward — Beobachtung im Bericht des Schrittes)*: Folge-ADR mit `supersedes` oder eine ergänzende Sammel-ADR;
  diese ADR wird nicht ergänzt.
- **Wenn [ADR-0074](0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) per Folge-ADR die Klasse `b` neu
  schneidet** *(feedforward)*: die Zuordnung der Festlegungen 1 bis 7 ist neu zu prüfen.
- **Wenn die schreibende Rolle der Spec-Straten entschieden ist** *(feedforward)*: die Zuordnung von
  [`docs/user/rollen-laeufe.md`](../../user/rollen-laeufe.md) ist neu zu prüfen (Geschichte, Zeile 2).

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-30 | Proposed und Accepted im selben Schritt | Architect-Schritt zu [ADR-0074](0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) Festlegung 6. Die Annahme folgt der Anordnung des Auftraggebers, den Umbau ohne Rückfragen umzusetzen; die ADR trägt nur, was aus der Spezifikation stammt, und entscheidet nichts Neues. |
| 2026-09-30 | Prozess-Konvention nach `docs/user/` | Empfehlung E3 der ADR-0074 (Option A) übernommen: [`docs/user/rollen-laeufe.md`](../../user/rollen-laeufe.md). **Grenze:** für `docs/user/` benennt keine Quelle eine schreibende Rolle ([ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md): wo keine Quelle die Rolle benennt, bleibt die Frage offen; [ADR-0074](0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) Festlegung 7). Der Architect-Lauf schreibt die Datei als Übergabe-Artefakt; wer sie künftig ändert, ist nicht entschieden. |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-NNNN` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
