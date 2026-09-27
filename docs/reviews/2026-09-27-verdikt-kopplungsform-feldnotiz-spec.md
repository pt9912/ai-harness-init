# Architect-Verdikt: Kopplungsform zwischen Feldnotiz im Träger und Spec §5 — `slice-kopplungsform-feldnotiz-spec-braucht-architektur-verdikt`

**Rolle:** Architect (Modul 8), Zug „Planner → Architect → Planner". Kein Review, keine
Verifikation, kein Code- oder Spec-Diff; dieses Verdikt ist das **Übergabe-Artefakt** an den
Planner (DoD (1) des Slice) und mittelbar an den Implementer des noch zu schneidenden
Folge-Slice.

**Gelesen:** der Slice vollständig
(`docs/plan/planning/open/slice-kopplungsform-feldnotiz-spec-braucht-architektur-verdikt.md`);
`AGENTS.md` §3 (§3.4, §3.6, §3.8, §3.10);
[`ADR-0013`](../plan/adr/0013-technik-stratum-als-zielort.md) vollständig, `Accepted`;
[`ADR-0022`](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 7
und ihr Umfeld (Bezug, Schärft, Fitness-Function-Zeilen 449/450), `Accepted`;
[`MR-021`](../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
vollständig; [`MR-010`](../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert);
Baseline-Regelwerk `modul-11-verification.md` §Fitness Function ohne Standard-Tool;
`modul-08-agentenrollen.md` §Rollen-Regeln; `modul-05-planning-harness.md` §4 (Rückführungs-Vorbild);
§1 von [`slice-109`](../plan/planning/done/slice-109-feldliste-jede-aussage-hat-ihre-quelle.md)
(Herkunft der Frage); §6/§7 von
[`slice-096`](../plan/planning/done/slice-096-traeger-liegt-im-ziel.md) (Präzedenz zirkuläre
Kopplung); `observation.md`/`state.md`/beide `evidence/*.md` von
[`zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`](../plan/planning/observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/observation.md).

---

## 0. Selbst nachgemessen (nicht nur den Slice-Text übernommen)

```sh
sed -n '/^| ID | Feld | Pflicht | Incident-Frage | Sensor |/,/^$/p' spec/spezifikation.md | grep -c '^| `'
# 26
grep -c '{Field: "' internal/span/fieldlist.go
# 32
sed -n '/^| ID | Feld | Pflicht | Incident-Frage | Sensor |/,/^$/p' spec/spezifikation.md | grep '^| `' \
  | awk -F'|' '{n=gsub(/`[a-z_0-9]+`/,"&",$3); if(n>1) c++} END{print c}'
# 6  (26 + 6 = 32 — jedes Feld hat heute eine §5-Entsprechung, keine Lücke in der reinen Existenz)
```

**Sechs Zeilenpaare gelesen** (mehr als die geforderten sechs, mit mindestens einem Vertreter je
Kategorie): `seq`, `slice`, `session`/`agent`, `program`/`argc`, `tool_use_id`, `total_tokens`.
Ergebnis — die Drei-Kategorien-Einteilung des Slice trägt:

| Feld | Kategorie | Beleg |
|---|---|---|
| `seq` | reine Umformulierung | Spec: *„Fehlt ein Span? — je Strom monoton steigend, damit der Leser eine Lücke sieht"*; Träger: *„Fehlt eine Zeile? — je Strom vergeben und steigend, damit eine Lücke sichtbar wird"* — dieselbe Behauptung |
| `slice` | reine Umformulierung, Spec mit einer Zusatz-Klausel | Spec ergänzt *„(kein Slice ⇒ leer und als leer erkennbar)"*, sonst deckungsgleich |
| `session`/`agent` | strukturelle Differenz | Spec bündelt beide in **einer** Frage (`SPEC-008`); der Träger stellt für `agent` eine **eigene, zweite** Frage, die in der Spec-Zeile fehlt |
| `program`/`argc` | Substanz-Gefälle | `SPEC-021` verweist auf `SPEC-031` — mit **3773** Zeichen die mit Abstand längste Zeile der Datei (`awk '{print length, NR}' spec/spezifikation.md \| sort -rn \| head -1` → `3773 132`); der Träger bleibt bei einem Satz |
| `tool_use_id` | reine Umformulierung | beide: *„Welche Ereignisse gehören zu einem Aufruf?"* — wortgleich |
| `total_tokens` | strukturelle Differenz, geringer | Spec nennt zusätzlich die Rechenprobe (*„am eigenen Bestand nachgerechnet …"*), Träger bleibt bei der Frage |

Die Kategorisierung des Slice ist damit **bestätigt**, nicht nur übernommen.

**MR-021 nachgemessen — trägt die Feedforward-Messung heute noch?**

```sh
grep -n "codepaths:" -A 2 .d-check.yml
# roots: [spec, docs, harness]     — test/ weiterhin nicht Teil des Prüfbereichs
```

`harness/sensors/comment-claims.md` §Grenze bestätigt zusätzlich: der Prüfbereich ist auf vier
Pfad-Muster begrenzt (`internal/**/*.go`, `cmd/**/*.go`, `harness/tools/*.sh`,
`.claude/hooks/*.sh`) — *„dauerhaft draußen … jede Markdown-Datei"*. `spec/spezifikation.md` ist
eine Markdown-Datei. **Beide Sonden aus MR-021 tragen unverändert**, auch nach `slice-204`, das
`SPEC-021`/`SPEC-031` stark erweitert hat: die Erweiterung hat den Prüfbereich nicht verschoben,
nur den Text innerhalb eines weiterhin ungeprüften Bereichs vergrößert.

---

## 1. Die Entscheidung

**Ich bestätige keine der drei in Frage A vorgezeichneten Lesarten unverändert — ich wähle eine
vierte, die aus den Kosten der ersten drei folgt: Option E — bidirektionaler Existenz-Abgleich.**
`internal/span/fieldlist.go` (`SchemaNotes()`) und `spec/spezifikation.md` §5 bleiben zwei
unabhängig, von Hand verfasste Artefakte. Ein neuer, noch zu bauender Sensor
(Pre-commit-Hook- oder Make-Target-Ebene) prüft **nur Existenz**: jedes `{Field: "X"}`-Literal im
Träger hat ein Token `` `X` `` irgendwo in der §5-Tabelle, und umgekehrt — **beide Richtungen**.
Wortlaut, Detailgrad und Zahl der Incident-Fragen je Feld bleiben ausdrücklich **nicht**
Gegenstand des Sensors.

**Gegen die drei vorgezeichneten Optionen, einzeln:**

- **Option 1 (erzeugt) — abgelehnt.** Zwei Gründe, nicht nur einer. *Erstens* der im Slice bereits
  benannte Substanzverlust-vs-Prosa-Aufblähung-Zielkonflikt: SchemaNotes() bedient über
  [`ADR-0022`](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 7
  bereits ein **anderes** Publikum (den Adopter, verbatim, terse) als §5 (Rang-2, normativ, mit
  Raum für `SPEC-031`s mehrere hundert Wörter Rand-Fälle). Eine Quelle für beide Zielorte zu
  machen heißt, eines der beiden Publika falsch zu bedienen. *Zweitens*, gemessen an der
  Ziel-**Festlegung** selbst: Festlegung 7 begründet "erzeugt" ausdrücklich mit einer Eigenschaft,
  die für §5 nicht gilt — *„Das Technik-Stratum des Ziels ist `skip-if-present` und gehört dem
  Adopter"*. `spec/spezifikation.md` in **diesem** Repo ist weder `skip-if-present` noch fremd; der
  tragende Grund für "erzeugt" trägt hier nicht.
- **Option 2 (verglichen, wortgleich) — abgelehnt, und zwar auf der Sache, nicht nur an den
  Kosten.** Der Slice benennt die Kosten (22 von 26 Zeilen sofort rot); ich ergänze: selbst wenn
  man die Angleichung bezahlte, wäre das Ziel falsch. Die Substanz-Differenz bei `program`/`argc`
  ist **gewollt** — Rang-2 braucht die Rand-Fälle, der Adopter-Text braucht sie nicht. Ein Sensor,
  der Wortgleichheit erzwingt, optimiert auf die falsche Invariante.
- **Option 3 (verglichen, Kernaussage, inferentiell) — nicht jetzt gebaut, als Vorrat benannt.**
  Modul 11 stuft diese Sensor-Schicht als teuerste ein (*„hoch — wenn semantische Prüfung nötig
  ist"*), nicht-deterministisch, ohne bestehendes Werkzeug im Repo. Dem steht kein belegter
  Schadensfall gegenüber: kein `LH-*`-Akzeptanzkriterium verlangt Kernaussage-Gleichheit zwischen
  Träger und Spec, und die zwei bisher gefundenen echten Abweichungen (slice-109, Zutat-Satz und
  `program`-Notiz) wurden von einem **Menschen beim Lesen** gefunden, nicht von einem Sensor
  vermisst. Nach AGENTS.md's eigener Linie — die billigste Lösung, die real trägt, geht vor der
  saubersten, die einen neuen, teuren Mechanismus verlangt — baue ich diese Schicht nicht auf
  Vorrat.

**Warum eine vierte Option und keine der drei:** Die drei vorgezeichneten Antworten spannen einen
falschen Trade-off auf — entweder Substanz/Prosa-Konflikt (1), erzwungene Homogenisierung (2)
oder teuerste Sensor-Schicht (3). Der bidirektionale Existenz-Abgleich trifft den **einen**
konkreten, im Slice selbst benannten Schadensfall — Risiko 4, *„ein Feld existiert nur auf einer
Seite"* — mit der billigsten Sensor-Schicht (Modul 11: *„niedrig/mittel"*), ohne die anderen zwei
Kosten einzukaufen. Er ist bewusst **unvollständig** gegenüber dem, was Option 3 leisten könnte —
das steht unten offen, nicht verschwiegen.

## 2. ADR-Bezug

**Ergänzende Folge-ADR, nicht Supersede.** `ADR-0013` bleibt vollständig gültig und unangetastet;
sie hat die Zielort-Frage entschieden und die Kopplungsform-Frage ausdrücklich offengelassen
(*„welche Form dieser Zielort trägt, entscheidet dieser Slice nicht"*, so der Slice-Bezug). Ich
habe diese Lücke mit einer neuen ADR gefüllt statt sie in einer Prosa-Zeile dieses Verdikts zu
vergraben — die Entscheidung bindet künftige Slices (den Folge-Slice unten) und ist damit
ADR-würdig nach derselben Messlatte wie `ADR-0013`/`ADR-0022` selbst (eine Sensor-Architektur-
Entscheidung mit Bestand über den einzelnen Slice hinaus).

**Neu geschrieben:** [`ADR-0071`](../plan/adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md)
— *„Die Kopplung zwischen der Feldliste des Trägers und Spec §5 ist ein bidirektionaler
Existenz-Abgleich — keine Wortgleichheit, keine Erzeugung"*. **Status: `Proposed`** — die Annahme
ist Sache des Auftraggebers, nicht meine (§Zustimmung unten). ADR-Index
(`docs/plan/adr/README.md`) ist fortgeschrieben.

## 3. Umsetzungsaufwand — ein Folge-Slice, nicht mehrere

Anders als der Slice-Text befürchtet (*„Dann sind es zwei Slices"*, Modul 5 §4-Vorbild: Kopplung
getrennt von Wortlaut-Angleichung), **reicht hier ein Folge-Slice** — und zwar genau **weil**
Option E keine Wortlaut-Angleichung verlangt. Der teure zweite Schnitt (22 Zeilen inhaltlich
angleichen) entfällt strukturell, nicht nur organisatorisch: Es gibt nichts anzugleichen, weil
Wortgleichheit nicht das Ziel ist.

**Benannter Folge-Slice (Titel-/Kennungsvorschlag, Scope — nicht angelegt, das ist Planner-Arbeit
nach §3.10):**

- **`slice-feldabdeckung-existenz-sensor`** (oder eine vom Planner gewählte äquivalente Kennung
  nach [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)).
  **Scope:** ein Skript/Make-Target, das (a) jedes `{Field: "X"}`-Literal in
  `internal/span/fieldlist.go` gegen ein Token `` `X` `` irgendwo in der §5-Tabelle von
  `spec/spezifikation.md` prüft, (b) umgekehrt jedes Feld-Token der §5-Tabelle gegen ein
  `{Field: "X"}`-Literal im Träger, (c) beide Richtungen fail-closed bei unbekannter Zeilenform
  (analog `LH-QA-01`), (d) in `harness/README.md` §Sensors oder §Werkzeuge eingetragen wird —
  Gate oder `kein Gate` ist Teil der Umsetzungsentscheidung des Folge-Slice, nicht dieses
  Verdikts. **Nicht** im Scope: jede inhaltliche Änderung an §5 oder am Träger — der heutige
  Bestand ist bereits deckend (26 + 6 = 32, siehe §0), der Sensor hat beim Bau also **kein**
  sofortiges Rot zu beheben.

Kein zweiter Folge-Slice für Wortlaut-Angleichung — er entfällt durch die getroffene Wahl, nicht
weil er vergessen wäre.

## 4. Die vier Risiken aus §6 des Slice, einzeln

**Risiko 1 — zirkuläre Kopplung.** Adressiert durch die Wahl selbst: Ich kombiniere **nicht**
"erzeugt" mit einem nachgelagerten Vergleich. Der Existenz-Sensor hängt an **zwei echt
unabhängigen Artefakten** — `internal/span/fieldlist.go` (Go-Quelltext, von Hand gepflegt) und
`spec/spezifikation.md` §5 (Markdown-Tabelle, von Hand gepflegt) — plus einem dritten, dem Skript
selbst, das keines der beiden erzeugt. Präzedenz, selbst gelesen:
[slice-096](../plan/planning/done/slice-096-traeger-liegt-im-ziel.md) §7 (Steering-Loop-Eintrag)
zeigt am Fall `TestEnforce_WrapperSuchtDenAblageort`, dass ein Wächter, der seine Erwartung aus
**derselben** Funktion ableitet, die er prüfen soll, strukturell nicht rot werden kann — genau das
Muster, das "erzeugt + verglichen" hier reproduziert hätte.

**Risiko 2 — die vierte Spalte von §5 ist der teuerste Teil und der leiseste.** Entschärft durch
Ablehnung von Option 1: Mein Sensor generiert nichts, überschreibt nichts. Die Sensor-Spalte von
§5 bleibt exakt, was sie heute ist — von Hand gepflegt, ungebunden, Feedforward
([`MR-021`](../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben),
nachgemessen in §0 dieses Verdikts, unverändert). Das Risiko materialisiert sich für meine
Entscheidung nicht — es bliebe nur bei Option 1 real, die ich verwerfe.

**Risiko 3 — den Wortlaut anzugleichen heißt, einen von zwei Registern zu wählen.** Das ist der
Kern der Architect-Frage, und ich **löse** ihn, statt ihn weiter offen zu lassen: Es wird
**keiner** der beiden Wortlaute an den anderen angeglichen. Beide bleiben in ihrem eigenen
Register — Adopter-terse im Träger (über `ADR-0022` Festlegung 7), Rang-2-normativ in §5. Die
Kopplung bindet **Existenz**, nicht **Formulierung**.

**Risiko 4 — `make gates` sieht den Gegenstand nur zum Teil, und: ist es dieselbe Beobachtung wie
`zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`?**

Erste Hälfte (Doku-Gate-Blindheit): **teilweise adressiert.** Der neue Existenz-Sensor deckt die
Teilmenge *„ein Feld fehlt komplett auf einer Seite"*. Er deckt **nicht** die Teilmenge *„beide
Zeilen existieren, tragen aber unterschiedliche Kernaussagen"* — das bleibt offen, benannt in
`ADR-0071` §Konsequenzen als **akzeptiertes Negativ**, nicht als stillschweigend gelöst.

Zweite Hälfte — Zuordnung zur Register-Beobachtung, **selbst gemessen:**

```sh
ls docs/plan/planning/observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/evidence/*.md | wc -l
# 2
```

Beide Belege gelesen (`slice-174-archivierung-emittieren`,
`slice-vorlauf-waechter-geht-ins-ziel`). **Mein Urteil: NICHT dieselbe Beobachtung — eine
verwandte, aber andersartige Beobachtung.** Begründung:

- Die Registerbeobachtung selbst grenzt sich in ihrem Abschnitt *„Benannt, nicht gezählt"* von
  einem Nachbarn ab, indem sie ihre eigene Fehlerrichtung präzise benennt: *„hier **sollen** beide
  Fassungen gleich sein und dürfen nicht auseinanderlaufen"*. Beide Belege bestätigen das exakt:
  eine Dogfood-Fassung eines Ablaufs/Wächters (Bash-Skript, Command-Workflow) gegen die
  **emittierte Vorlage** desselben Ablaufs — zwei Kopien, die byte- bzw. verhaltens-identisch sein
  sollen, weil es dieselbe Regel für zwei Ausführungsorte ist.
- Unser Fall ist strukturell anders: `SchemaNotes()` und §5 **sollen nicht** gleich sein — sie
  dürfen (und sollen, siehe `program`/`argc`) im Detailgrad divergieren, weil sie zwei
  verschiedene **Publika** (Adopter vs. Rang-2-Leser) bedienen. Es gibt hier keine
  "Dogfood-Fassung gegen Emissions-Vorlage"-Achse: `spec/spezifikation.md` wird nicht emittiert
  (`ADR-0013` Folgepflicht 3: *„An der Emission ändert sich nichts"*), und `SchemaNotes()` bedient
  über `ADR-0022` Festlegung 7 ein anderes Dokument als unser eigenes §5.
- Die Fehlerrichtung, die unser Fall trägt, ist eine **dritte**, die weder die bestehende
  Beobachtung noch ihr im `observation.md` genannter Nachbar
  (`emittierter-stand-laeuft-dem-dogfood-voraus`) beschreibt: *„zwei Fassungen sollen in der
  Substanz übereinstimmen (Kernaussage je Feld), dürfen aber in Form und Detailgrad legitim
  divergieren, und kein Sensor hält auch nur die Existenz-Achse."*

**Empfehlung an die Slice-Closure (Planner-Arbeit, nicht meine):** eine **neue** Beobachtung
registrieren — Arbeitstitel *„feldnotiz-traeger-und-spec-koennen-in-der-kernaussage-abweichen-ohne-sensor"*
oder eine vom Planner gewählte treffendere Kennung —, **nicht** einen dritten Beleg an
`zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor` anhängen. Ein dritter Beleg dort wäre
falsch gezählt: Modul 6 verlangt, dass eine Kennung dieselbe Beobachtung über Läufe hinweg trägt,
und die Fehlerrichtung ist hier nachweislich eine andere. Die Entscheidung selbst bleibt beim
Planner (§8 des nächsten Slice, *„Vorgelagert — offene Beobachtungen sichten"*, oder direkt bei
der Closure dieses Slice) — ich liefere das Urteil, nicht den Eintrag.

## 5. MR-021-Einordnung

**Unverändert.** Die Feedforward-Messung von MR-021 (*„die Sensor-Spalte hat einen Namen und
keinen Sensor"*) betrifft die **vierte Spalte** von §5 (den Sensor-Bezug je Zeile). Meine
Entscheidung generiert, überschreibt und liest diese Spalte nicht — sie führt einen **zusätzlichen**
Sensor auf einer anderen Achse ein (Feld-**Existenz** zwischen Träger und §5-**Spalte 2**, nicht
Spalte 4). Selbst nachgemessen (§0): `codepaths.roots` bleibt `[spec, docs, harness]`, `test/`
bleibt draußen, `comment-claims` nimmt weiterhin jede Markdown-Datei aus. Beide tragenden Sonden
von MR-021 gelten unverändert — auch nach `slice-204`, das nur den **Text** innerhalb des
weiterhin ungeprüften Bereichs vergrößert hat, nicht den Prüfbereich selbst.

## 6. Zustimmung des Auftraggebers

**Ja, nötig.** [`ADR-0071`](../plan/adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md)
steht als `Proposed`; der Übergang nach `Accepted` ist Sache des Auftraggebers
([`AGENTS.md`](../../AGENTS.md) §3.4). Bis dahin ist der Folge-Slice aus §3 formal noch nicht
angelegt — der Planner kann ihn vorbereiten, aber sein Bezug hängt an einer akzeptierten ADR.

## Übergaben

| An | Artefakt |
|---|---|
| **Planner** | dieses Verdikt (DoD (1) des Slice); Empfehlung, den Folge-Slice `slice-feldabdeckung-existenz-sensor` (oder Äquivalent) zu schneiden, sobald `ADR-0071` `Accepted` ist; Empfehlung, bei der Closure dieses Slice eine **neue** Register-Beobachtung anzulegen (Risiko 4, §4 oben) statt einen dritten Beleg an die bestehende zu hängen; alle vier Risiko-Ausgänge aus §6 des Slice sind mit diesem Verdikt beantwortet (kein Risiko bleibt „weiter offen" ohne Adressierung — siehe §4) |
| **Auftraggeber** | Annahme-Entscheidung für [`ADR-0071`](../plan/adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md) |
| **Implementer** (künftig, Folge-Slice) | Scope aus §3: bidirektionaler Existenz-Sensor, keine Wortlaut-Angleichung |

## Was offen bleibt

- Die Kernaussage-Abweichung bei **existierenden** Zeilenpaaren bleibt ohne automatisierten Sensor
  (bewusst, `ADR-0071` §Konsequenzen und §Re-Evaluierungs-Trigger) — Träger ist die Sichtung bei
  künftiger Slice-Planung, kein Gate.
- Die konkrete Register-Kennung für die neue Beobachtung aus §4 lege ich nicht fest — das ist
  Planner-Arbeit bei der Closure.
- `ADR-0071` ist `Proposed`, nicht `Accepted`; der Folge-Slice hat bis zur Annahme keinen
  bindenden ADR-Bezug.
