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

### Ist-Bestand: 34 Verweise, zwei gleich große und ungleich sichtbare Hälften

Gemessen 2026-08-09 am Stand `6bf9950`. Nenner (Zeitdokumente unter `docs/reviews` und
`docs/plan/planning/done` ausgenommen — sie sind die richtige Aussage über ihren Stand und
werden nicht nachgezogen):

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

**Was der Gate von beiden Hälften sieht** — von dieser ADR selbst gemessen, mit einer Sonde im
Arbeitsbaum (eine temporäre Markdown-Datei unter `docs` mit vier Links, `make docs-check`, danach
gelöscht; Baum wieder sauber):

| Sonde | Befund |
|---|---|
| Link auf einen **verschwundenen Tag** | `target-missing` |
| Link auf den gepinnten Tag, echter Anker | **kein Befund** — auflösbar |
| Link auf den gepinnten Tag, **erfundener Anker** | `anchor-missing` |
| Link auf eine Datei, die es **erst bei `v5.3.0`** gibt, unter dem alten Tag | `target-missing` |

Daraus folgen zwei Dinge. Erstens: `scan.ignore` nimmt die Baseline als **Quelle** aus, nicht
als **Ziel** — Link *und* Anker in den vendored Baum werden aufgelöst. Zweitens: nach dem
Tausch wird von den vier Accepted-ADRs **genau eine** rot, nämlich
[ADR-0013](0013-technik-stratum-als-zielort.md), weil sie als einzige einen Markdown-Link
führt. [ADR-0011](0011-telemetrie-erfassung-policy.md),
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) und
[ADR-0014](0014-aufgehobener-eintrag-kopf-statt-rumpf.md) tragen zusammen **6** Inline-Nennungen
in einen Baum, den es dann nicht mehr gibt, und **kein Sensor sagt es**:
`codepaths.roots` führt `spec`, `docs`, `harness` — der Punkt vor `harness` fehlt, und ein
Pfad `.harness/…` fällt damit aus dem Prüfbereich. ([ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md)
steht auf *Proposed* und fällt nicht unter §3.4.)

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

## Entscheidung

**Wir wählen Option G: der Bestand bleibt unberührt und wird ausgesprochen; die Zukunft bindet
sich an Tag und Zitat statt an den lokalen Pfad; der eine gate-sichtbare Konflikt bekommt eine
benannte, auslöser-gebundene Senkung.** Vier Festlegungen:

**1. Der Bestand wird nicht geheilt — kein Supersede, keine Ausnahme, keine Migration.**
Die vier Accepted-ADRs bleiben byte-gleich. Begründung, und sie ist empirisch, nicht formal:
ihre Aussagen werden durch den Tausch **nicht falsch**. Der Tag steht *im String*; die Zeichen
`v3.5.2` datieren die Fundstelle selbst, und wer nachschlägt, findet auf Platte einen anderen
Tag und sieht die Differenz sofort. Was bricht, ist die **lokale Auflösbarkeit** — eine
Eigenschaft des Arbeits-Cache, der laut [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
nie ein Archiv war. §3.4 gewinnt hier nicht als Formalie, sondern weil es nichts zu korrigieren
gibt — und weil die einzige Korrektur, zu der ein mechanischer Lauf greifen würde (Tag-String
ersetzen), an Zeile 129 nachweislich eine falsche Aussage erzeugte.

**Cutoff, wie ihn [`AGENTS.md`](../../../AGENTS.md) §3.7 führt:** gebunden ist der Verweis, der
geschrieben oder geändert wird. Der Bestand ist **kein Arbeitsauftrag**.

**2. Form eines Verweises in einem Artefakt, das unveränderlich wird.** Ein solches Artefakt —
eine ADR ab *Accepted*, ein Zeitdokument, jedes Artefakt, das nach Abschluss nicht mehr
angefasst wird — belegt eine Regelwerks-Aussage mit drei Teilen:

- dem **Tag** (`v3.5.2`) — die Reproduzierbarkeits-Klammer,
- dem **Regelwerks-Dateinamen und dem Abschnittsnamen** — die Eigenschaft,
- dem **Zitat verbatim** — der Substanz.

**Nicht** dazu gehören der lokale Präfix `.harness/baseline/<tag>/` und die Zeilennummer als
alleiniger Locator. Beides sind Adressen; die eine verfällt beim Tausch, die andere schon bei
einer eingefügten Zeile. Das ist dieselbe Regel, die
[ADR-0014](0014-aufgehobener-eintrag-kopf-statt-rumpf.md) eine Ebene tiefer für den
Adaptions-Block gezogen hat: **Eigenschaft statt Adresse.**

**Der lokale Pfad bleibt erlaubt — in änderbaren Artefakten.** In
[`AGENTS.md`](../../../AGENTS.md), `harness/conventions.md`, den Spec-Straten, `CLAUDE.md` und
lebenden Plandateien ist er ein **Navigations-Zeiger**, und der Bump zieht ihn nach. Die Linie
dieser ADR verläuft damit nicht am Verweis-*Ziel*, sondern an der **Änderbarkeit der Quelle**.

**3. Träger der Regel: der Accept-Übergang.** Bevor der Status eines ADR auf *Accepted*
wechselt, werden seine Baseline-Verweise in die Form aus Festlegung 2 gebracht. Das ist der
einzige Moment, an dem die Regel überhaupt binden kann — danach verbietet §3.4 jede Nachbesserung.
Wer ein ADR annimmt, prüft das; wer es schreibt, liefert es so.

**4. Der Gate: eine Senkung nach [`AGENTS.md`](../../../AGENTS.md) §3.5, auslöser-gebunden und
nach oben geschlossen.** `.d-check.yml` nimmt unter `scan.ignore` **genau die Accepted-ADRs**
auf, deren Markdown-Link in den vendored Baum ein Tausch tatsächlich bricht. Heute ist das
**genau eine Datei**: `docs/plan/adr/0013-technik-stratum-als-zielort.md`.

Zwei Grenzen gehören zur Festlegung:

- **Auslöser-gebunden, nicht vorbeugend.** Ein ADR kommt auf die Liste, wenn ein Tausch seinen
  Verweis bricht — nicht, weil es die Klasse „Accepted" trägt. Der Gate über einem Accepted-ADR
  ist im Übrigen *nicht* wertlos: er wirkt als Sperre gegen das Umbenennen von Zielen, die ein
  eingefrorenes Dokument zitiert. Diese Sperre gilt weiter — sie fällt nur dort, wo das Ziel
  **außerhalb der Reichweite dieses Repos** liegt.
- **Nach oben geschlossen.** Festlegung 2 sorgt dafür, dass kein *neues* ADR auf die Liste kommt.
  Die Liste ist durch den heutigen Bestand begrenzt; sie kann nicht wachsen. Das ist die
  Eigenschaft, die diese Senkung erträglich macht: sie hat einen Boden.

**Der Preis, gemessen und nicht kleingeredet.** `scan.ignore` wirkt datei-weit über **alle**
Module. Die betroffene Datei führt 27 Markdown-Link-Vorkommen über 12 verschiedene Ziele,
davon 5 anker-tragend (vier davon repo-intern: zwei Abschnitte in
[`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder) und zwei
Anforderungs-Anker). Sie alle verlassen den Prüfbereich, nicht nur der eine Baseline-Link.
**Der Grund für diese Grobheit ist ein fehlender Knopf, kein Wunsch:** `codepaths` trägt
`ignore-refs` (referenz-weit, [`MR-008`](../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)-Muster),
`ids` und `matrix` tragen `exempt-paths` — `links` und `anchors` tragen **keines von beidem**
(`d-check --print-config`). Der präzise Knopf hieße `links.ignore-refs`; solange es ihn nicht
gibt, ist der datei-weite Ausschluss die stellvertretende Grobheit, und sie steht hier als
solche.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts entscheiden | kein Aufwand | der Tausch entscheidet die Frage faktisch, und zwar in Richtung „stumm falsch": drei Accepted-ADRs trügen eine unauflösbare Aussage ohne Sensor, und die naheliegende Reparatur (Tag-String ersetzen) verstieße gegen §3.4 **und** erzeugte an Zeile 129 ein falsches Zitat |
| B — Link-Check-Ausnahme für alle Ziele unter `.harness/baseline/` | vier ADRs auf einen Schlag grün, eine Zeile Config | nimmt die **16** heute gate-sichtbaren Links in `spec/spezifikation.md` (12) und `harness/conventions.md` (4) mit aus der Prüfung — also genau den einzigen Sensor, der den Bump zwingt, sie nachzuziehen. Eine Senkung, deren Geltungsbereich um Faktor 16 größer ist als ihr Anlass, und die mit jedem neuen Baseline-Verweis weiter wächst: kein Boden |
| C — beide Bäume nebeneinander vendoren | jeder Verweis bleibt auflösbar, keine Senkung | bricht [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) („ein Tag zur Zeit"); `make baseline-verify` bricht bei zwei Tag-Verzeichnissen ab. Der Baum wüchse mit jedem Bump, und „die adoptierte Baseline" wäre keine Menge von eins mehr — die Reproduzierbarkeits-Klammer aus [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) verlöre ihren Sinn |
| D — Alias/Umleitung, die den Tag-Wechsel absorbiert | ein Pfad, der jeden Tausch überlebt; keine Config-Senkung | er überlebt ihn, **indem er lügt**: die ADR sagt `v3.5.2`, die Platte liefert `v5.3.0`. Gemessen an `modul-07-carveouts.md` Zeile 129 — bei `v3.5.2` *„Slice schlägt Memo"*, bei `v5.3.0` unverwandter Text: der Alias verwandelte einen toten Link in ein falsches Zitat, also einen lauten Fehler in einen stummen. Für den einen realen Fall trägt er ohnehin nicht: `grundlagen-konventionen.md` existiert bei `v5.3.0` nicht mehr |
| E — `codepaths.roots` um `.harness` erweitern | die stille Hälfte bekäme einen Sensor; eine Zeile Config | **gemessen, verworfen** — siehe unten: 44 Befunde am heutigen Bestand, keiner aus der gesuchten Klasse, und die Klassen sind strukturell unauflösbar |
| F — [ADR-0013](0013-technik-stratum-als-zielort.md) mit einer Folge-ADR superseden | formal die von §3.4 vorgesehene Bahn | die Entscheidung hat sich nicht geändert; ein Supersede für einen kaputten Pfad ist ADR-Inflation und macht aus einem Doku-Defekt einen Entscheidungs-Vorgang. Der Preis ist zudem groß: **16** Verweis-Vorkommen aus **10** lebenden Dateien zeigen auf ADR-0013, und `matrix.status` verbietet Verweise auf superseded ADRs (wie viele davon der Gate genau trifft, ist ungemessen — die Größenordnung trägt die Verwerfung) |
| **G — gewählt: Bestand aussprechen · Zukunft an Tag und Zitat binden · eine auslöser-gebundene Senkung** | trennt die zwei Defekte, die alle anderen Optionen vermischen — *unauflösbar* und *unwahr*; die Senkung hat einen Boden und wächst nicht; die Zukunftsregel hat mit dem Accept-Übergang einen Träger und ist nicht nur ein Merksatz | die stille Hälfte bleibt unbewacht, und diese ADR baut den Sensor nicht; der datei-weite Ausschluss ist gröber als nötig, weil `links` keinen referenz-weiten Knopf hat; ein Leser, der `v3.5.2` im Pfad überliest, hält den Verweis für aktuell |

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
- **Positiv:** Die Frage ist **vor** dem Tausch beantwortet. Der Slice, der den Baum tauscht,
  hat eine Regel statt einer Ermessensentscheidung — und insbesondere eine, die ihm den
  bequemen `sed` über alle Tag-Strings **verbietet**, wo eine Zeilennummer im Spiel ist.
- **Positiv:** Die Senkung ist klein, benannt und nach oben geschlossen. Sie trifft eine Datei
  und kann per Konstruktion keine zweite hinzugewinnen, solange Festlegung 2 gilt.
- **Negativ:** Die **stille Hälfte bleibt stumm.** 17 Inline-Nennungen, davon 6 in
  Accepted-ADRs, sehen nach dem Tausch auf einen Baum, den es nicht gibt, und **kein Gate meldet
  das** — heute nicht und nach dieser Entscheidung nicht. Wer die Nennung liest, ohne den
  Tag-String zu lesen, hält sie für aktuell. Das ist der Preis, und er wird hier nicht als
  bewacht ausgegeben ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Negativ:** Die betroffene ADR-Datei verlässt den Doku-Gate **ganz**, nicht nur für ihren
  Baseline-Link — 27 Link-Vorkommen über 12 Ziele verlieren ihren Wächter.
- **Negativ:** Festlegung 2 ist teurer im Schreiben. Ein Verweis mit Zitat ist länger als ein
  Pfad, und wer ihn schreibt, muss die Quelle wirklich gelesen haben. Das ist die Absicht,
  aber es ist Aufwand.
- **Folgepflicht 1 (der Slice, der den Baum tauscht):** die 16 gate-sichtbaren Links in den
  Spec-Straten und im Adaptions-Block auf den neuen Tag **und die neuen Dateinamen** ziehen —
  `grundlagen-konventionen.md` ist bei `v5.3.0` in sechs Dateien zerlegt, ein reiner Tag-Tausch
  reicht dort nicht. Ebenso die lebenden Inline-Nennungen. Dazu der `scan.ignore`-Eintrag aus
  Festlegung 4. Diese ADR ändert **keine** Konfiguration.
- **Folgepflicht 2 (der Adaptions-Durchgang der Re-Baseline):** prüfen, ob die Ziel-Fassung des
  Regelwerks selbst eine Verweis-Form für vendored Bäume vorschreibt. Tut sie es, ist diese
  Entscheidung gegen sie zu halten; weicht sie ab, ist die Abweichung im Adaptions-Block zu
  deklarieren.
- **Folgepflicht 3 (offen, eigener Slice):** der Sensor für lebende Artefakte aus der Fitness
  Function unten. Er ist hier **nicht** gebaut.

## Fitness Function (falls maschinell prüfbar)

**Gebaut — und was es prüft:**

| Tooling | Regel | Make-Target |
|---|---|---|
| d-check `links` + `anchors` | Ein Markdown-Link in den vendored Baum löst auf, Ziel **und** Anker — auch wenn `scan.ignore` den Baum als Quelle ausnimmt. Belegt durch die vier Sonden oben (`target-missing`, kein Befund, `anchor-missing`, `target-missing`) | `make docs-check` |
| d-check `baseline-verify` | Es existiert genau **ein** Tag-Verzeichnis, integer und vollständig — die Mechanik hinter [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache), auf der Festlegung 1 fußt | `make baseline-verify` |

Nach Festlegung 4 sieht der erste die eine ausgenommene Datei nicht mehr. Das ist der
deklarierte Preis, keine Eigenschaft.

**Nicht gebaut, aber mechanisierbar** — und diese ADR baut es nicht:

- *Ein lebendes Artefakt nennt nur den gepinnten Tag.* Eigenschaft: jede Zeichenkette
  `.harness/baseline/<X>/` in einem lebenden Artefakt erfüllt `<X> == BASELINE_TAG` aus dem
  Makefile. Prüfbereich: alles außer `docs/reviews`, `docs/plan/planning/done` und den nach
  Festlegung 4 ausgenommenen ADRs. Hermetisch, netzlos, bash+grep. Das Gegenbeispiel, das ihn
  rot färben müsste ([`AGENTS.md`](../../../AGENTS.md) §3.6): ein lebendes Artefakt nennt den
  alten Tag, während der Pin schon auf dem neuen steht — also genau der Zustand unmittelbar
  nach dem Tausch. **Was er nicht fängt:** die 6 Nennungen in Accepted-ADRs; dort gibt
  Festlegung 1 ihm nichts zu tun.
- *Zitat gegen Quelle.* d-check trägt ein verbatim-Modul `citations`, das auf
  `d-check:cite`-Direktiven feuert ([`MR-011`](../../../harness/conventions.md#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines)).
  Es könnte die Zitat-Hälfte von Festlegung 2 prüfen — **aber nur, solange die Quelle lokal
  liegt.** Für ein Zitat aus einem nicht mehr vendored Tag kann es per Konstruktion nichts
  sagen. Hier ist es nicht aktiviert: null Direktiven im Repo, also ein nie feuerndes Gate
  ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

**Nicht mechanisierbar:** ob ein Verweis eine *Eigenschaft* oder eine *Adresse* nennt, ist ein
Urteil. Ein Muster gäbe es allein für den Sonderfall Zeilennummer — und der ist über
`codepaths` nicht erreichbar, siehe Option E.

## Re-Evaluierungs-Trigger

- **Wenn `links` einen referenz-weiten Ausschluss bekommt** *(feedforward — eine Tool-Version,
  kein Sensor)*: dann ist der datei-weite `scan.ignore`-Eintrag aus Festlegung 4 durch den
  präzisen zu ersetzen, und der Preis (27 Link-Vorkommen ohne Wächter) entfällt.
- **Wenn ein zweites Accepted-ADR auf die Ausnahmeliste käme** *(am Zustand ablesbar)*: dann hat
  Festlegung 2 nicht getragen — ihr Träger, der Accept-Übergang, ist zu schwach, und die Frage
  ist die nach dem Träger, nicht nach der Ausnahme.
- **Wenn die Baseline aufhört, `<tag>`-gescopt zu liegen** *(feedforward)*: fällt der Anlass
  weg, aber auch die Reproduzierbarkeits-Klammer. Dann ist zuerst
  [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) neu zu
  entscheiden, und diese ADR folgt.
- **Wenn der Sensor für lebende Artefakte gebaut ist und rot steht, ohne dass jemand ihn
  bedient** *(am Lauf ablesbar)*: dann ist er ein zweiter dauerhaft roter Sensor neben
  `baseline-freshness`, und die Frage ist, ob er der Regel dient oder sie entwertet.
- **Wenn ein Leser eine Inline-Nennung als aktuell missversteht** *(Beobachtung, kein Gate)*:
  das ist der eingestandene Preis von Festlegung 1. Tritt er ein, ist die Kosten-Rechnung
  falsch gewesen, und die stille Hälfte braucht doch eine Behandlung — vermutlich eine
  einmalige, deklarierende statt einer sensorischen.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-09 | **Proposed** | Architect-Verdikt zur Tag-Wechsel-Frage der Re-Baseline `v3.5.2` → `v5.3.0`; Anlass war die Messung, dass von 34 lebenden Baseline-Verweisen genau die Hälfte gate-sichtbar ist und ein mechanischer Tag-Tausch an einer Zeilen-Referenz ein falsches Zitat erzeugte |
