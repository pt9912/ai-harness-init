# ADR-0016: Ein Verweis auf das Regelwerk trägt Tag und Zitat, nicht den Pfad in den Arbeits-Cache

**Status:** Proposed

**Datum:** 2026-08-09

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Tag ist die
Reproduzierbarkeits-Klammer — diese ADR entscheidet, wo er steht und was er trägt),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die
stille Hälfte des Bestands bleibt unbewacht und wird hier so benannt),
[ADR-0014](0014-aufgehobener-eintrag-kopf-statt-rumpf.md) (dieselbe Regel eine Ebene
tiefer: ein unveränderliches Artefakt bindet sich an eine Eigenschaft, nicht an eine Adresse)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie regelt die **Form** eines Verweises auf die
vendored Baseline, nicht den Inhalt eines Spec-Dokuments.

---

## Kontext

Die vendored Baseline liegt `<tag>`-gescopt unter `.harness/baseline/<tag>/` und trägt
**einen Tag zur Zeit** ([`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).
Ein Bump ist deshalb kein Update, sondern ein **Tausch**: das alte Verzeichnis verschwindet
vollständig. Jeder Verweis, der den Tag im lokalen Pfad führt, verliert dabei sein Ziel — auch
der in einem Artefakt, das niemand mehr ändern darf ([`AGENTS.md`](../../../AGENTS.md) §3.4).
Zwei Regeln des Repos kollidieren also an einem Artefakt, das keine von beiden anfassen kann.

Der anstehende Sprung macht die Kollision konkret: das Regelwerk wächst von 21 auf 26 Dateien,
aber nicht additiv — `grundlagen-konventionen.md` zerfällt in sechs Grundlagen-Dateien,
`modul-03-lastenheft` wird `modul-03-spec`, `modul-04-architektur-adrs` wird `modul-04-adrs`
(gemessen an einem lokalen Kurs-Klon, `git ls-tree -r --name-only v5.3.0 lab/regelwerk`).

### Ist-Bestand nach Artefakt-Klasse: 34 Verweise, zwei ungleich sichtbare Hälften

Gemessen 2026-08-09. Nenner: die **lebenden** Artefakte — Zeitdokumente unter `docs/reviews` und
`docs/plan/planning/done` sind ausgenommen, weil sie die richtige Aussage über ihren Stand sind
und nicht nachgezogen werden:

```sh
git grep -o "\.harness/baseline/v3\.5\.2/[^ )]*" \
  -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' | wc -l
# -> 34   (aus 9 lebenden Artefakten)
```

**Laute Hälfte — Markdown-Links, 17:**

```sh
git grep -oE '\]\([^)]*\.harness/baseline/v3\.5\.2/[^)]*\)' \
  -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' | wc -l
# -> 17   (spec/spezifikation.md 12 · harness/conventions.md 4 · ADR-0013 1)
```

**Stille Hälfte — Inline-Nennungen, 17** (dieselbe Trefferliste, Link-Ziele vorher entfernt):

```sh
git grep -h "\.harness/baseline/v3\.5\.2/" \
  -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' \
  | sed -E 's/\]\([^)]*\)//g' | grep -o "\.harness/baseline/v3\.5\.2/[^ )\`]*" | wc -l
# -> 17   (harness/conventions.md 7 · ADR-0012 3 · ADR-0014 2 · je 1 in
#          spec/spezifikation.md, ADR-0011, ADR-0015 und zwei Plandateien)
```

### Ist-Bestand nach Gate-Sicht: 21 Befunde — der Gate teilt diesen Nenner nicht

Die Kommandos oben zählen, was **wir** pflegen. Das Doku-Gate zählt, was **es** liest, und das ist
mehr: `scan.ignore` führt weder `docs/reviews` noch `docs/plan/planning/done`, und `links` und
`anchors` tragen überhaupt keine Options-Sektion, also auch kein `exempt-paths`
(`d-check --print-config`, gepinnter Digest). Der gate-seitige Bestand ist deshalb **gefahren**
statt hochgerechnet: `.harness/baseline/v3.5.2` nach `v5.3.0` umbenannt, `make docs-check`,
zurückbenannt — danach `baseline-verify: v3.5.2 OK — 42 Dateien`, Arbeitsbaum sauber.

```
d-check: 309 Datei(en) geprüft, 21 Befund(e)     # alle target-missing
```

| Quelle | Zahl | Änderbar? |
|---|---|---|
| `spec/spezifikation.md` (12) + `harness/conventions.md` (4) | **16** | ja — lebende Artefakte, der Tausch zieht sie nach |
| [ADR-0013](0013-technik-stratum-als-zielort.md) | **1** | **nein** — §3.4 |
| `docs/plan/planning/done/slice-076-mr-018-umzug-technik-stratum.md` | **2** | Zeitdokument: von §3.4 **nicht** geschützt, inhaltlich aber datiert |
| `docs/reviews/2026-07-26-slice-050-impl-review-runde-5.md` | **1** | dito |
| `docs/reviews/2026-07-26-slice-050-verification.md` | **1** | dito |

**Die Zahl „17 gate-sichtbar" ist damit eine Aussage über lebende Artefakte, nicht über den
Gate.** Wer nur sie liest, plant den Tausch mit vier Befunden zu wenig.

### Eine fünfte Accepted-ADR, die keiner der beiden Nenner sieht

[ADR-0007](0007-bootstrap-phasen.md) nennt `.harness/baseline/<tag>/` — mit **Platzhalter, ohne
Tag**. Ein `v3.5.2`-gescoptes Kommando findet sie nicht, und der Tausch bricht sie nicht: *was
keinen Tag nennt, hat keinen zu verlieren.* Sie beschreibt zudem das Layout des **emittierten**
Zielrepos, belegt also keine Regelwerks-Aussage. Beide Beobachtungen tragen Festlegung 2.

### Die Messung, die die Entscheidung dreht

Die stille Hälfte enthält **zwei** Zeilen-Referenzen, beide in
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md), beide auf `modul-07-carveouts.md`. Gegen
den Ziel-Tag gehalten (`git show v5.3.0:lab/regelwerk/modul-07-carveouts.md`):

- Die Zeilen **26–29** stehen bei `v5.3.0` **byte-gleich** dort, wo die ADR sie zitiert.
- Zeile **129** trägt bei `v3.5.2` den Satz *„Slice schlägt Memo"*, den die ADR in Anspruch
  nimmt — bei `v5.3.0` steht dort ein unverwandter Satz über die Aufgaben des Implementers.

Ein mechanischer Tausch des Tag-Strings in einem Verweis ist damit **keine Pfad-Reparatur,
sondern eine Inhaltsänderung**: er ließe die ADR etwas zitieren, was die Quelle nicht sagt.
Was die beiden Referenzen unterscheidet, ist nicht Glück, sondern Form — die eine nennt neben
der Zeilennummer das **Zitat**, die andere nur die **Adresse**. Genau diese Unterscheidung
entscheidet diese ADR.

### Was der Gate über den vendored Baum überhaupt sieht

Sonde im Arbeitsbaum (eine temporäre Markdown-Datei unter `docs` mit vier Links,
`make docs-check`, danach gelöscht; Baum wieder sauber):

| Sonde | Befund |
|---|---|
| Link auf einen **verschwundenen Tag** | `target-missing` |
| Link auf den gepinnten Tag, echter Anker | **kein Befund** — auflösbar |
| Link auf den gepinnten Tag, **erfundener Anker** | `anchor-missing` |
| Link auf eine Datei, die es **erst bei `v5.3.0`** gibt, unter dem alten Tag | `target-missing` |

`scan.ignore` nimmt die Baseline als **Quelle** aus, nicht als **Ziel** — Link *und* Anker in den
vendored Baum werden aufgelöst. Die **stille** Hälfte dagegen sieht kein Sensor:
`codepaths.roots` führt `spec`, `docs`, `harness` — der Punkt vor `harness` fehlt, und ein Pfad
`.harness/…` fällt damit aus dem Prüfbereich. [ADR-0011](0011-telemetrie-erfassung-policy.md),
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) und
[ADR-0014](0014-aufgehobener-eintrag-kopf-statt-rumpf.md) tragen zusammen **6** solcher
Nennungen. ([ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) steht auf *Proposed* und fällt
nicht unter §3.4.)

## Entscheidung

**Wir wählen Option G: der Bestand bleibt in seiner Aussage unberührt und wird ausgesprochen; die
Zukunft bindet sich an Tag und Zitat statt an den lokalen Pfad; die Gate-Senkung ist auf eine
namentlich genannte Datei extensional geschlossen; die vier Zeitdokument-Adressen entfallen,
ohne dass ein Text sich ändert.** Fünf Festlegungen:

**1. Der Bestand der Accepted-ADRs wird nicht geheilt — kein Supersede, keine Ausnahme, keine
Migration.** Die vier bleiben byte-gleich. Begründung, und sie ist empirisch, nicht formal: ihre
Aussagen werden durch den Tausch **nicht falsch**. Der Tag steht *im String*; die Zeichen
`v3.5.2` datieren die Fundstelle selbst, und wer nachschlägt, findet auf Platte einen anderen
Tag und sieht die Differenz sofort. Was bricht, ist die **lokale Auflösbarkeit** — eine
Eigenschaft des Arbeits-Cache, der laut [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
nie ein Archiv war. §3.4 gewinnt hier nicht als Formalie, sondern weil es nichts zu korrigieren
gibt — und weil die einzige Korrektur, zu der ein mechanischer Lauf greifen würde (Tag-String
ersetzen), an Zeile 129 nachweislich eine falsche Aussage erzeugte.

**Cutoff, wie ihn [`AGENTS.md`](../../../AGENTS.md) §3.7 führt:** gebunden ist der Verweis, der
geschrieben oder geändert wird. Der Bestand ist **kein Arbeitsauftrag**.

**2. Form eines Belegs in einem Artefakt, das unveränderlich wird.** Ein solches Artefakt —
eine ADR ab *Accepted*, ein Rollen-Report, eine Closure-Notiz, jedes Artefakt, das nach Abschluss
nicht mehr angefasst wird — belegt eine Regelwerks-Aussage mit drei Teilen:

- dem **Tag** (`v3.5.2`) — die Reproduzierbarkeits-Klammer,
- dem **Regelwerks-Dateinamen und dem Abschnittsnamen** — die Eigenschaft,
- dem **Zitat verbatim** — der Substanz.

**Nicht** dazu gehören der lokale Präfix `.harness/baseline/<tag>/` und die Zeilennummer als
alleiniger Locator. Beides sind Adressen; die eine verfällt beim Tausch, die andere schon bei
einer eingefügten Zeile. Das ist dieselbe Regel, die
[ADR-0014](0014-aufgehobener-eintrag-kopf-statt-rumpf.md) eine Ebene tiefer für den
Adaptions-Block gezogen hat: **Eigenschaft statt Adresse.**

**Was Festlegung 2 nicht verbietet: den tag-losen Platzhalter in einer Layout-Beschreibung.**
Gebunden ist der **Beleg** — der Verweis, der eine Regelwerks-Aussage stützt —, nicht die Nennung
eines Pfad-Musters. Der Unterschied ist am Tag ablesbar: ein Beleg nennt einen konkreten Tag,
sonst belegt er nichts; eine Layout-Beschreibung nennt keinen, sonst beschriebe sie einen
Einzelfall. [ADR-0007](0007-bootstrap-phasen.md) ist der Ist-Beleg für die erlaubte Seite.

**Der lokale Pfad bleibt erlaubt — in änderbaren Artefakten.** In
[`AGENTS.md`](../../../AGENTS.md), `harness/conventions.md`, den Spec-Straten, `CLAUDE.md` und
lebenden Plandateien ist er ein **Navigations-Zeiger**, und der Bump zieht ihn nach. Die Linie
dieser ADR verläuft damit nicht am Verweis-*Ziel*, sondern an der **Änderbarkeit der Quelle**.

**3. Träger der Regel: zwei Übergänge, nicht einer.**

- **(a) Der Accept-Übergang.** Bevor der Status eines ADR auf *Accepted* wechselt, werden seine
  Baseline-Belege in die Form aus Festlegung 2 gebracht.
- **(b) Der Abschluss eines Rollen-Reports oder einer Closure-Notiz.** Bevor ein Zeitdokument
  abgeschlossen wird, gilt dasselbe. Dieser zweite Träger ist nicht symmetrisch nachgereicht,
  sondern der praktisch wirksamere: **alle vier** gate-sichtbaren Zeitdokument-Verweise stammen
  aus **Kopf-Metadaten von Rollen-Reports** — einer Konvention, die sich mit jedem Report
  reproduziert. Ohne Träger an diesem Übergang entsteht die verbotene Form fortlaufend neu, und
  jede Aufräumaktion wäre eine Momentaufnahme.

**Der Träger kann einen Sensor haben — gemessen, gegen die naheliegende Gegenbehauptung.** Zum
Accept-Zeitpunkt steht der Baum noch, also hat `links` über einen verbotenen Verweis nichts zu
melden. Daraus folgt **nicht**, dass an diesem Übergang kein Sensor stehen kann, sondern dass
`links` nicht der richtige ist: `links` fragt nach **Auflösbarkeit**, die Regel fragt nach
**Form**, und eine Form-Frage ist tag-unabhängig. Sonde, außerhalb des Repos gebaut und
zurückgenommen — eine Probe-ADR mit Status *Accepted* und genau der von Festlegung 2 verbotenen
Verweis-Form, beide Sensoren am **selben Baum zum selben Zeitpunkt**:

| Sensor | Frage | Ausgang |
|---|---|---|
| `make docs-check` (`links`) | löst das Ziel auf? | **310 Dateien, 0 Befunde** — grün |
| Form-Sonde (bash + `grep`) | nennt ein Accepted-ADR einen **tag-gepinnten** Baseline-Pfad? | **1 Befund, Exit 1** — rot |

Der Träger ist damit **mechanisierbar**, nicht bloß menschlich. **Gebaut ist er nicht** — die
Sonde lag außerhalb des Repos; ihr Bau ist Folgepflicht 3.

**4. Der Gate: eine Senkung nach [`AGENTS.md`](../../../AGENTS.md) §3.5, extensional geschlossen.**
`.d-check.yml` nimmt unter `scan.ignore` **genau eine namentlich genannte Datei** auf:

- `docs/plan/adr/0013-technik-stratum-als-zielort.md`

**Und keine weitere.** Das ist eine Aufnahme-**Grenze**, keine Aufnahme-**Regel**: **jeder
zusätzliche Eintrag ist eine neue Senkung und löst §3.5 erneut aus — auch dann, wenn er
dieselbe Bedingung erfüllt wie dieser.** Ein zweites Accepted-ADR mit gebrochenem Baseline-Link
ist durch diese ADR **nicht** gedeckt und braucht eine eigene Entscheidung.

Damit hängt der Boden nicht mehr an einer Prognose über die Wirksamkeit von Festlegung 2,
sondern an §3.5, der bei jedem Zuwachs erneut greift. Eine intensional formulierte Regel
(*„alle Dateien, die die Bedingung X erfüllen"*) hätte den zweiten Eintrag im Voraus autorisiert
und §3.5 stillgelegt — das ist der Unterschied zwischen einer Schranke und einer Beobachtung.

Der Eintrag trägt im Config-Kommentar seine Begründung und einen Zeiger auf diese ADR, wie die
vier bestehenden Einträge auch.

**Der Preis, gemessen über alle Module — nicht nur über `links`.** `scan.ignore` liest die Datei
**nicht mehr**; die geprüfte Datei-Zahl fällt um eins. Betroffen sind fünf aktive Module:

| Modul | was die Datei verliert | gemessen mit |
|---|---|---|
| `links` / `anchors` | 27 Link-Vorkommen über 12 Ziele, 5 anker-tragend (4 davon repo-intern) | `grep -oE '\]\([^)]+\)'` |
| `ids` | 18 Kennungs-Nennungen (8 eindeutig) unter der Linkpflicht | `grep -oE 'ADR-[0-9]{4}\|LH-[A-Z]{2}-[0-9]{2}\|MR-[0-9]{3}'` |
| `codepaths` (samt `check-lines`) | 4 eindeutige Inline-Code-Pfade | `grep -oE '`(\.{1,2}/\|spec/\|docs/\|harness/)[^`]*`'` |
| `matrix` | die Datei als **Quelle**, inklusive des Verbots, auf superseded ADRs zu zeigen | — |

**Entlastend, ebenfalls gemessen:** `scan.ignore` wirkt **quellenseitig**. Eingehende Links,
eingehende Anker und `matrix.status` über eingehende Verweise auf die ausgenommene Datei bleiben
vollständig bewacht — dieselbe Sonde, die das für den vendored Baum zeigt, zeigt es hier. Der
Preis wächst also **nicht** mit den 16 Verweisen *auf* ADR-0013, sondern bleibt auf ihre
27 ausgehenden begrenzt.

**Der Grund für diese Grobheit ist ein fehlender Knopf, kein Wunsch:** `codepaths` trägt
`ignore-refs` (referenz-weit, [`MR-008`](../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)-Muster),
`ids` und `matrix` tragen `exempt-paths` — `links` und `anchors` tragen **keines von beidem**
(`d-check --print-config`). Der präzise Knopf hieße `links.ignore-refs`; solange es ihn nicht
gibt, ist der datei-weite Ausschluss die stellvertretende Grobheit, und sie steht hier als
solche.

**Registrierung.** [`MR-001`](../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
ist der einzige Ort im Repo, der die `scan.ignore`-Einträge zählt und klassifiziert — heute vier,
alle als *Scoping, keine Gate-Lockerung nach §3.5*. Dieser Eintrag ist der erste, für den beides
nicht mehr stimmt: er nimmt Bestand aus, den dieses Repo autoritativ schreibt. Der Eintrag zählt
erst als vollzogen, wenn [`MR-001`](../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
Zahl **und** Klassifikation nachführt und die Grenze aus dieser Festlegung dort wiederholt — dort
liest sie, wer den nächsten Eintrag anlegen will.

**5. Die vier Zeitdokument-Verweise verlieren ihre Adresse, nicht ihren Text.** In den drei
genannten Zeitdokumenten wird der Markdown-Link zur reinen Nennung: der sichtbare Text bleibt
Zeichen für Zeichen stehen, die tag-gepinnte Adresse entfällt. **Kein Satz ändert sich, keine
Aussage wird nachgezogen.**

Drei Gründe, und der erste trägt allein:

- **Nach dem Tausch ist die Wahl nicht *Link oder kein Link*, sondern *toter Link oder kein
  Link*.** Ein Verweis, der ins Leere zeigt, ist keine Navigationshilfe, die man bewahrt.
- **Der Text ist ohnehin der Beleg.** Alle vier Verweise nennen die **Eigenschaft** schon im
  sichtbaren Text (*„Modul 15 §Span-/Audit-Attribut-Regeln"*, *„Modul 11"*), und einer nennt den
  Tag verbatim in derselben Tabellenzelle (*„Agents-Regelwerk v3.5.2, …"*). Ein Nachziehen auf
  den neuen Tag stellte diese Zelle gegen sich selbst — dieselbe Falschaussage, die Zeile 129
  vorführt. Die Adresse war nur der Weg zum Beleg, nie der Beleg.
- **Die Aufnahme in Festlegung 4 wäre siebenmal teurer, dauerhaft.** Die drei Dateien führen
  zusammen **185** Link-Vorkommen (120 · 48 · 17, `grep -oE '\]\([^)]+\)' | wc -l`) gegenüber
  27 der einen Datei dort — und zwar über alle fünf Module. Vor allem aber machte sie die Liste
  zu dem, was sie nicht sein darf: einer, die bei jedem Bump um jeden neuen Report wächst.

**Zeitdokumente sind nicht von §3.4 geschützt** — die Hard Rule nennt ADRs. Geschützt ist ihre
**Aussage**, und die bleibt unberührt. Wer bei dieser Gelegenheit einen Satz ändert, statt nur
die Adresse aufzulösen, verstößt gegen die Begründung dieser Festlegung.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts entscheiden | kein Aufwand | der Tausch entscheidet die Frage faktisch, und zwar in Richtung „stumm falsch": drei Accepted-ADRs trügen eine unauflösbare Aussage ohne Sensor, und die naheliegende Reparatur (Tag-String ersetzen) verstieße gegen §3.4 **und** erzeugte an Zeile 129 ein falsches Zitat |
| B — Link-Check-Ausnahme für alle Ziele unter `.harness/baseline/` | vier ADRs auf einen Schlag grün, eine Zeile Config | nimmt die **16** heute gate-sichtbaren Links in `spec/spezifikation.md` (12) und `harness/conventions.md` (4) mit aus der Prüfung — also genau den einzigen Sensor, der den Bump zwingt, sie nachzuziehen. Eine Senkung, deren Geltungsbereich um Faktor 16 größer ist als ihr Anlass, und die mit jedem neuen Baseline-Verweis weiter wächst: kein Boden |
| C — beide Bäume nebeneinander vendoren | jeder Verweis bleibt auflösbar, keine Senkung | bricht [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) („ein Tag zur Zeit"); `make baseline-verify` bricht bei zwei Tag-Verzeichnissen ab. Der Baum wüchse mit jedem Bump, und „die adoptierte Baseline" wäre keine Menge von eins mehr — die Reproduzierbarkeits-Klammer aus [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) verlöre ihren Sinn |
| D — Alias/Umleitung, die den Tag-Wechsel absorbiert | ein Pfad, der jeden Tausch überlebt; keine Config-Senkung | er überlebt ihn, **indem er lügt**: die ADR sagt `v3.5.2`, die Platte liefert `v5.3.0`. Gemessen an `modul-07-carveouts.md` Zeile 129 — bei `v3.5.2` *„Slice schlägt Memo"*, bei `v5.3.0` unverwandter Text: der Alias verwandelte einen toten Link in ein falsches Zitat, also einen lauten Fehler in einen stummen. Für den einen realen Fall trägt er ohnehin nicht: `grundlagen-konventionen.md` existiert bei `v5.3.0` nicht mehr |
| E — `codepaths.roots` um `.harness` erweitern | die stille Hälfte bekäme einen Sensor; eine Zeile Config | **gemessen, verworfen** — siehe unten: 44 Befunde am heutigen Bestand, keiner aus der gesuchten Klasse, und die Klassen sind strukturell unauflösbar |
| F — [ADR-0013](0013-technik-stratum-als-zielort.md) mit einer Folge-ADR superseden | formal die von §3.4 vorgesehene Bahn | die Entscheidung hat sich nicht geändert; ein Supersede für einen kaputten Pfad ist ADR-Inflation und macht aus einem Doku-Defekt einen Entscheidungs-Vorgang. Der Preis ist zudem groß: **16** Verweis-Vorkommen aus **10** lebenden Dateien zeigen auf ADR-0013, und `matrix.status` verbietet Verweise auf superseded ADRs |
| **G — gewählt: Bestands-Aussage aussprechen · Zukunft an Tag und Zitat binden · extensional geschlossene Senkung für eine Datei · vier Zeitdokument-Adressen auflösen** | trennt die drei Defekte, die alle anderen Optionen vermischen — *unauflösbar*, *unwahr* und *unbewacht*; die Senkung hat mit §3.5 eine Schranke statt einer Prognose; die Zukunftsregel hat zwei Träger, und einer davon ist mit einem gemessenen Gegenbeispiel mechanisierbar | die stille Hälfte bleibt unbewacht, und diese ADR baut den Sensor nicht; der datei-weite Ausschluss ist gröber als nötig, weil `links` keinen referenz-weiten Knopf hat; drei Zeitdokumente werden angefasst, wenn auch nur an ihren Adressen |

### Option E im Detail — die Messung, die sie verwirft

Sonde im Arbeitsbaum: `codepaths.roots` um `.harness` erweitert, `make docs-check`, Config
danach zurückgenommen (Baum wieder sauber). **44 `codepath-missing`-Befunde in 17 Dateien** —
und **null** davon aus der Klasse, um deren willen der Root gedacht war (der gepinnte Tag
existiert ja noch). Die 44 zerfallen in vier Klassen, und jede ist strukturell:

| Klasse | Zahl | Warum sie nicht weggeht |
|---|---|---|
| der mit [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) entfernte Regelwerk-Cache (`.harness/cache/…`) | 20 | Tombstones bewusst entfernter Artefakte; 10 davon in `harness/conventions.md`, also im lebenden Bestand |
| historische Tags in Zeitdokumenten (`v3.1.0`, `v3.5.0`, `v3.5.1`) | 10 | sie sind die richtige Aussage über ihren Stand und werden nie nachgezogen |
| Pfade im **emittierten** Zielrepo (`.harness/skills/…`, `.harness/skeleton/`, `.harness/.gitignore`) | 11 | sie existieren im Ziel, nicht im Dogfood — zwei Ebenen, ein Namensraum |
| **Vorwärts-Verweise** auf den Baum, den der Tausch erst anlegt (`.harness/baseline/v5.3.0/`) | 3 | ein Planungsartefakt nennt den Zustand, den es herstellt |

Die letzte Klasse ist der Killer, und sie ist nicht wegkonfigurierbar: `codepaths` kann *„soll
existieren"* nicht von *„wird existieren"* unterscheiden, und eine Ausnahmeliste für sie trüge
den Tag-String — der laut Makefile-Kommentar allein in `BASELINE_TAG` leben soll. Der Root
verlangte also ~44 Einträge, wäre bei jedem Bump neu zu pflegen und färbte dauerhaft genau die
Artefakte rot, deren Aufgabe es ist, abwesende Pfade zu nennen. **Damit ist der offene Punkt
geschlossen: `codepaths.roots` nimmt den Punkt nicht auf.**

## Konsequenzen

- **Positiv:** Die vier Accepted-ADRs bleiben, was sie sind — Geschichtsdokumente. Kein
  Supersede, kein Byte, keine Kaskade über `matrix.status`.
- **Positiv:** Die Frage ist **vor** dem Tausch beantwortet, und zwar für **21** Befunde statt
  für 17. Der ausführende Slice erbt keine §3.5-Entscheidung, die er nicht treffen darf.
- **Positiv:** Die Senkung trifft eine namentlich genannte Datei, und ihr Wachstum ist nicht
  prognostiziert, sondern durch §3.5 verstellt.
- **Negativ:** Die **stille Hälfte bleibt stumm.** 17 Inline-Nennungen, davon 6 in
  Accepted-ADRs, sehen nach dem Tausch auf einen Baum, den es nicht gibt, und **kein Gate meldet
  das** — heute nicht und nach dieser Entscheidung nicht. Wer die Nennung liest, ohne den
  Tag-String zu lesen, hält sie für aktuell. Das ist der Preis, und er wird hier nicht als
  bewacht ausgegeben ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Negativ:** Die eine ausgenommene ADR-Datei verlässt den Doku-Gate **ganz** — fünf Module,
  nicht nur `links`.
- **Negativ:** Drei Zeitdokumente werden angefasst. Das ist eine Ausnahme von der Linie
  *„Zeitdokumente bleiben unberührt"*, und sie ist eng: berührt wird die Adresse, nie der Text.
- **Negativ:** Festlegung 2 ist teurer im Schreiben. Ein Beleg mit Zitat ist länger als ein
  Pfad, und wer ihn schreibt, muss die Quelle gelesen haben. Das ist die Absicht, aber es ist
  Aufwand.
- **Folgepflicht 1 (der Slice, der den Baum tauscht) — fünf Posten, alle vor seiner Closure:**
  (a) die **16** gate-sichtbaren Links in den Spec-Straten und im Adaptions-Block auf den neuen
  Tag **und die neuen Dateinamen** ziehen — `grundlagen-konventionen.md` ist bei `v5.3.0` in
  sechs Dateien zerlegt, ein reiner Tag-Tausch reicht dort nicht, und **jeder Anker wird einzeln
  geprüft statt per `sed` über den Tag-String** (die Lehre aus Zeile 129);
  (b) die lebenden Inline-Nennungen ebenso;
  (c) den `scan.ignore`-Eintrag aus Festlegung 4 **samt Config-Kommentar und ADR-Zeiger**;
  (d) [`MR-001`](../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  nachführen — Zahl, Klassifikation und die Grenze aus Festlegung 4;
  (e) die vier Adressen aus Festlegung 5 auflösen.
  **Diese ADR ändert keine Konfiguration und kein Zeitdokument.**
- **Folgepflicht 2 (der Adaptions-Durchgang der Re-Baseline):** prüfen, ob die Ziel-Fassung des
  Regelwerks selbst eine Verweis-Form für vendored Bäume vorschreibt. Tut sie es, ist diese
  Entscheidung gegen sie zu halten; weicht sie ab, ist die Abweichung im Adaptions-Block zu
  deklarieren.
- **Folgepflicht 3 (offen, eigener Slice):** die zwei Sensoren aus der Fitness Function unten.
  Sie sind hier **nicht** gebaut.

## Fitness Function (falls maschinell prüfbar)

**Gebaut — und was es prüft:**

| Tooling | Regel | Make-Target |
|---|---|---|
| d-check `links` + `anchors` | Ein Markdown-Link in den vendored Baum löst auf, Ziel **und** Anker — auch wenn `scan.ignore` den Baum als Quelle ausnimmt | `make docs-check` |
| d-check `baseline-verify` | Es existiert genau **ein** Tag-Verzeichnis, integer und vollständig — die Mechanik hinter [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache), auf der Festlegung 1 fußt | `make baseline-verify` |

Nach Festlegung 4 sieht der erste die eine ausgenommene Datei nicht mehr. Das ist der
deklarierte Preis, keine Eigenschaft.

**Nicht gebaut, aber mechanisierbar** — und diese ADR baut beides nicht:

1. **Form-Sensor zu Festlegung 2** (der Träger aus Festlegung 3). Eigenschaft: *kein
   unveränderlich gewordenes Artefakt nennt einen **tag-gepinnten** lokalen Baseline-Pfad.*
   Prüfbereich: alle Artefakte **außer** der in Festlegung 4 namentlich genannten Datei und den
   vier Accepted-ADRs des Bestands, die Festlegung 1 freistellt — **einschließlich** der
   Zeitdokumente, denn genau dort ist die Form bisher entstanden. Tag-unabhängig, hermetisch,
   netzlos, bash + `grep`. **Gegenbeispiel rot gesehen** ([`AGENTS.md`](../../../AGENTS.md) §3.6):
   eine Probe-ADR mit Status *Accepted* und der verbotenen Form → 1 Befund, Exit 1, während
   `make docs-check` am selben Baum 0 Befunde meldet. Der tag-lose Platzhalter darf ihn **nicht**
   färben — auch das ist am Bestand belegt: mit der groben Regel *„kein `.harness/baseline/`"*
   meldet er [ADR-0007](0007-bootstrap-phasen.md) falsch-positiv, mit der tag-gepinnten Regel
   nicht.
2. **Pin-Sensor für lebende Artefakte.** Eigenschaft: *jede Zeichenkette
   `.harness/baseline/<X>/` in einem lebenden Artefakt erfüllt `<X> == BASELINE_TAG`.* Sein
   Gegenbeispiel: der Zustand unmittelbar nach dem Tausch, solange die 16 Links noch auf den
   alten Tag zeigen. **Was er nicht fängt:** die 6 Nennungen in Accepted-ADRs; dort gibt
   Festlegung 1 ihm nichts zu tun.

**Nicht aktiviert und ausdrücklich kein Gate:** d-checks verbatim-Modul `citations` feuert nur
auf `d-check:cite`-Direktiven ([`MR-011`](../../../harness/conventions.md#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines));
das Repo trägt null davon, und für ein Zitat aus einem nicht mehr vendored Tag könnte es per
Konstruktion nichts sagen ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

**Nicht mechanisierbar:** ob ein Beleg das *richtige* Zitat führt, ist ein Urteil. Der Form-Sensor
sieht, dass eine Adresse fehlt — nicht, ob das, was stattdessen dasteht, die Quelle trifft.

## Re-Evaluierungs-Trigger

- **Wenn ein zweiter Eintrag für `scan.ignore` beantragt wird** *(am Vorgang ablesbar, §3.5
  greift von selbst)*: dann ist zu entscheiden, ob Festlegung 2 nicht getragen hat oder ob der
  Fall neu ist. Die Entscheidung fällt in einer eigenen ADR, nicht hier.
- **Wenn `links` einen referenz-weiten Ausschluss bekommt** *(feedforward — eine Tool-Version,
  kein Sensor)*: dann ist der datei-weite `scan.ignore`-Eintrag durch den präzisen zu ersetzen,
  und der Preis über fünf Module entfällt.
- **Wenn ein neues Zeitdokument einen tag-gepinnten Baseline-Link trägt** *(sichtbar, sobald der
  Form-Sensor gebaut ist — vorher nur im Report-Review)*: dann trägt Festlegung 3 (b) nicht, und
  die Frage ist die nach der Report-Vorlage, nicht nach einer weiteren Ausnahme.
- **Wenn die Baseline aufhört, `<tag>`-gescopt zu liegen** *(feedforward)*: fällt der Anlass
  weg, aber auch die Reproduzierbarkeits-Klammer. Dann ist zuerst
  [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) neu zu
  entscheiden, und diese ADR folgt.
- **Wenn ein Leser eine Inline-Nennung als aktuell missversteht** *(Beobachtung, kein Gate)*:
  das ist der eingestandene Preis von Festlegung 1. Tritt er ein, ist die Kosten-Rechnung
  falsch gewesen, und die stille Hälfte braucht doch eine Behandlung — vermutlich eine
  einmalige, deklarierende statt einer sensorischen.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-09 | **Proposed** | Architect-Verdikt zur Tag-Wechsel-Frage der Re-Baseline `v3.5.2` → `v5.3.0`; Anlass war die Messung, dass ein mechanischer Tag-Tausch an einer Zeilen-Referenz ein falsches Zitat erzeugte |
| 2026-08-09 | Überarbeitet, weiter **Proposed** | Bestätigungsrunde zur Gate-Senkung, `docs/reviews/2026-08-09-adr-0016-festlegung-4-bestaetigungsrunde.md` (2 HIGH). Der Ist-Bestand zählte lebende Artefakte, der Gate zählt mehr — Tausch gefahren: **21** statt 17 Befunde, vier davon in drei Zeitdokumenten, die keine Festlegung trug (neue Festlegung 5). Die Senkung ist von einer intensionalen Aufnahme-Regel auf eine **extensional geschlossene** Liste umgestellt; ihr Preis ist über alle fünf Module beziffert und [`MR-001`](../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) als Zähl-Ort in die Folgepflicht genommen. Festlegung 3 bekommt den Report-/Closure-Abschluss als zweiten Träger. **Widerlegt:** dass an diesem Träger *per Konstruktion* kein Sensor stehen könne — gemessen steht `links` dort grün, ein Form-Sensor rot. Nebenbefund am Bestand: [ADR-0007](0007-bootstrap-phasen.md) nennt den Pfad tag-los und ist deshalb gar nicht betroffen |
