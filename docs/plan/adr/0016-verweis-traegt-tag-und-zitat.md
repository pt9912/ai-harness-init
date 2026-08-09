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

**Kopplung:** Festlegung 1 lässt einen gate-sichtbaren Verweis in einem §3.4-immutablen Artefakt
zurück. Was daraus für den Doku-Gate folgt, entscheidet
[ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) — eine Gate-Senkung nach
[`AGENTS.md`](../../../AGENTS.md) §3.5 und damit eine andere Art Entscheidung. Sie hat hier ihre
Voraussetzung; diese ADR hat in ihr ihren Preis.

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

### Ist-Bestand: zwei Nenner, zwei ungleich sichtbare Hälften

Gemessen 2026-08-09.

**Nenner 1 — was dieses Repo pflegt.** Lebende Artefakte; Zeitdokumente unter `docs/reviews` und
`docs/plan/planning/done` ausgenommen, weil sie die richtige Aussage über ihren Stand sind und
nicht nachgezogen werden:

```sh
git grep -o "\.harness/baseline/v3\.5\.2/[^ )]*" \
  -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' | wc -l
# -> 34   (aus 9 lebenden Artefakten)

git grep -oE '\]\([^)]*\.harness/baseline/v3\.5\.2/[^)]*\)' -- <dieselben Pathspecs> | wc -l
# -> 17   LAUTE Haelfte, Markdown-Links
#         spec/spezifikation.md 12 · harness/conventions.md 4 · ADR-0013 1

git grep -h "\.harness/baseline/v3\.5\.2/" -- <dieselben Pathspecs> \
  | sed -E 's/\]\([^)]*\)//g' | grep -o "\.harness/baseline/v3\.5\.2/[^ )\`]*" | wc -l
# -> 17   STILLE Haelfte, Inline-Nennungen
#         harness/conventions.md 7 · ADR-0012 3 · ADR-0014 2 · je 1 in
#         spec/spezifikation.md und ADR-0011 sowie drei Plandateien
```

**Nenner 2 — was das Doku-Gate liest, und er ist größer.** `scan.ignore` führt weder
`docs/reviews` noch `docs/plan/planning/done`, und `links` und `anchors` tragen überhaupt keine
Options-Sektion, also auch kein `exempt-paths` (`d-check --print-config`, gepinnter Digest).
Deshalb **gefahren** statt hochgerechnet: `.harness/baseline/v3.5.2` nach `v5.3.0` umbenannt,
`make docs-check`, zurückbenannt — danach `baseline-verify: v3.5.2 OK — 42 Dateien`, Arbeitsbaum
sauber.

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

**Was der Gate über den vendored Baum überhaupt sieht.** Sonde im Arbeitsbaum (eine temporäre
Markdown-Datei unter `docs` mit vier Links, `make docs-check`, danach gelöscht; Baum wieder
sauber):

| Sonde | Befund |
|---|---|
| Link auf einen **verschwundenen Tag** | `target-missing` |
| Link auf den gepinnten Tag, echter Anker | **kein Befund** — auflösbar |
| Link auf den gepinnten Tag, **erfundener Anker** | `anchor-missing` |
| Link auf eine Datei, die es **erst bei `v5.3.0`** gibt, unter dem alten Tag | `target-missing` |

`scan.ignore` nimmt die Baseline als **Quelle** aus, nicht als **Ziel** — Link *und* Anker in den
vendored Baum werden aufgelöst.

**Was er nicht sieht: die stille Hälfte.** `codepaths.roots` führt `spec`, `docs`, `harness` —
der Punkt vor `harness` fehlt, und ein Pfad `.harness/…` fällt damit aus dem Prüfbereich.
[ADR-0011](0011-telemetrie-erfassung-policy.md), [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md)
und [ADR-0014](0014-aufgehobener-eintrag-kopf-statt-rumpf.md) tragen zusammen **6** solcher
Nennungen. [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) trägt **keine** — sie steht auf
*Proposed*, und für ein Artefakt, das noch geschrieben wird, gilt Festlegung 3 statt des Cutoffs.

**Und eine fünfte Accepted-ADR, die keiner der beiden Nenner sieht.**
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

Ein mechanischer Tausch des Tag-Strings ist damit **keine Pfad-Reparatur, sondern eine
Inhaltsänderung**: er ließe die ADR etwas zitieren, was die Quelle nicht sagt. Was die beiden
Referenzen unterscheidet, ist nicht Glück, sondern Form — die eine nennt neben der Zeilennummer
das **Zitat**, die andere nur die **Adresse**.

### Gegen die Ziel-Fassung gehalten

Diese Frage gehört **vor** das Einfrieren: eine Folgepflicht, die erst nach der Annahme griffe,
könnte an einer §3.4-immutablen ADR nichts mehr bewirken. Suchraum: **alle** 26 Regelwerk- und
25 Template-Dateien der Ziel-Fassung.

```sh
git grep -nEi 'vendor|\.harness/baseline|<tag>|verbatim|Zitat|zitier|Fundstelle|Belegstelle|Zeilennummer|Verweis-Form|Referenz-Form' \
  v5.3.0 -- lab/regelwerk lab/templates | wc -l          # -> 64 Treffer, einzeln gelesen
```

**Eine allgemeine Verweis-Form für vendored Bäume schreibt `v5.3.0` nicht vor.** Die beiden
Stellen, an denen sie stehen müsste, tun es nicht: `modul-04-adrs.md` trägt die Accepted-Hard-Rule
im **selben Wortlaut** wie die gepinnte Fassung (*„Eine ADR mit Status `Accepted` wird nicht
inhaltlich überschrieben."*) und kein Wort über Verweise; `grundlagen-referenz-richtung.md` führt
drei Abschnitte, alle über **wer wen referenzieren darf** (SDP), keinen über die Form. **Grenze
dieser Aussage:** ein Negativ aus einem aufgezählten Suchraum — eine Regel ohne eines dieser
zwölf Wörter wäre nicht gefunden worden.

Vier Stellen sagen etwas, und alle vier sind einschlägig:

1. **Für *eine* Artefakt-Klasse schreibt `v5.3.0` sehr wohl eine Form vor** — den
   Adaptions-Eintrag (`templates/harness/conventions/MR-NNN-titel.template.md`):
   *„`Ersetzt-Baseline-Regel` nennt **genau eine** Regel der Baseline … als Link mit
   Abschnitts-Anker in die vendored Fassung; **ein Datei-Link benennt keine Regel**."* Das
   Beispiel ist ein `<tag>`-gescopter lokaler Pfad. **Kein Widerspruch zu Festlegung 2:** der
   Adaptions-Eintrag ist ein **lebendes** Artefakt — in diesem Repo belegt an
   [`MR-020`](../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf):
   ein aufgehobener Eintrag wird **am Ort bearbeitet** (Kopf und Zeiger bleiben, der Rumpf
   entfällt), und genau das kann ein eingefrorenes Artefakt nicht. Dort erlaubt Festlegung 2 den
   lokalen Pfad ausdrücklich. Die zweite Satzhälfte
   **stützt** sie sogar: dass ein Datei-Link ohne Abschnitts-Anker keine Regel benennt, ist
   *Eigenschaft statt Adresse* in der Formulierung der Baseline. Dasselbe Template führt den Tag
   zudem als **eigenes Feld** (`Ausgelöst durch Baseline-Stand: <tag>`) — den Tag als Datum zu
   tragen statt als Pfad-Segment ist genau Festlegung 2, Teil eins.
2. **`grundlagen-harness-dateien.md`: *„Der Zeiger ist kein Zitat. Ein Template, das den
   Normtext ausschreibt, führt ihn ein zweites Mal — und zwei Fassungen driften."*** Diese Regel
   zieht die **Grenze** von Festlegung 2: Das Drift-Argument setzt ein Artefakt voraus, das
   **aktuell bleiben soll**. Ein unveränderliches Artefakt soll das nicht — sein Zitat ist durch
   den Tag datiert und driftet per Konstruktion nicht, es *bleibt* bei seinem Stand. Daraus folgt
   beides: **Zitat im unveränderlich werdenden Artefakt, Zeiger im lebenden.**
3. **Die Ziel-Prozedur verlangt genau die Gate-Lage, die dieses Repo hat.** Der Freshness-Audit
   in `modul-02-harness-bootstrap.md` sagt zum Formcheck: *„den erledigt das Doku-Gate: Die
   vendored Baseline liegt im Repo, ihre Dateien sind **gültige Link-Ziele** … Einmal prüfen,
   dass `.harness/baseline/` im Prüfumfang liegt; danach automatisch."* Verlangt ist
   Auflösbarkeit als **Ziel** — genau das ist oben rot gesehen. Verlangt ist **nicht** `.harness`
   in `codepaths.roots`.
4. **Eine Kollision, die nicht in diese ADR gehört, aber benannt sein muss.** Dieselbe Prozedur
   setzt für den Form-Vergleich voraus, dass **beide** Tag-Verzeichnisse vorübergehend
   nebeneinander liegen: *„Weil der Vendoring-Pfad `<tag>`-gescopt ist, liegen alte und neue Form
   nebeneinander … Das alte Verzeichnis fällt erst, wenn der Review durch ist."*
   [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
   setzt „ein Tag zur Zeit", und `make baseline-verify` färbt bei zwei Tag-Verzeichnissen rot —
   belegt, nicht vermutet: der bats-Fall *„verify: zwei `<tag>`-Verzeichnisse → rot (Setzung: ein
   Tag zur Zeit)"* läuft in `make gates` mit. **Das ist eine Prozedur-Kollision der Migration,
   keine Verweis-Frage**; sie gehört in den Form-Vergleichs-Durchgang der Welle. Diese ADR löst
   sie nicht und tut nicht so.

**Die Messung oben lief gegen `v5.3.0`; adoptiert wird `v5.3.1`. Sie trägt weiter — nachgewiesen
über den Delta, nicht über eine Wiederholung.** Der vendored Delta ist vollständig überschaubar,
und jede geänderte Zeile ist gelesen:

```sh
git diff --stat v5.3.0 v5.3.1 -- lab/regelwerk lab/templates
# -> 7 Dateien, 14 Einfuegungen, 13 Loeschungen
git diff -U0 v5.3.0 v5.3.1 -- lab/regelwerk lab/templates | grep -cE '^[+-]#{1,6} '
# -> 0   keine einzige Ueberschrift im Delta: alle Anker halten
```

| Was sich ändert | Dateien | Regel-Wirkung |
|---|---|---|
| Werkzeugname `check-references` → **Referenz-Richtungs-Gate** | 4 Regelwerk-Dateien + das ADR-Template | keine — ein Name weicht der Eigenschaft, dieselbe Bewegung, die Festlegung 2 verlangt. Kostet dieses Repo nichts: `git grep -c 'check-references' -- ':!.harness/baseline'` → **0** eigene Vorkommen |
| Stand-Zeile (Kurs-Welle 71 → 72) | `README.md` | keine — Metadatum |
| Paraphrase-Reparatur der Artefaktklassen-Tabelle | `modul-08-agentenrollen.md`, Zeilen 150–159 | die **Spiegelung** gewinnt die Exklusivität zurück, die sie verloren hatte (*„genau die Artefaktklasse"*, *„und das ist meistens kein Skill"*). Gegen die kanonische Kurs-Quelle ändert sich damit nichts; gegen den vorigen Spiegel-Text ist es eine Schärfung |

**Keine der tragenden Quellen dieser ADR ist berührt** — `modul-07-carveouts.md` (die Zeile-129-
Messung), `grundlagen-harness-dateien.md` (*„Der Zeiger ist kein Zitat"*),
`modul-04-adrs.md`, `modul-02-harness-bootstrap.md` und
`templates/harness/conventions/MR-NNN-titel.template.md` erscheinen im Delta nicht und sind damit
byte-gleich (`git diff --name-only v5.3.0 v5.3.1 -- <die fünf>` → leer). Auch die Verbatim-Messung
in Festlegung 2 trägt: `modul-08-agentenrollen.md` ist in den Zeilen 1–149 byte-gleich, und das
Zitat steht dort in Zeile 37.

**Was daraus folgt und was nicht.** Die Aussage *„eine allgemeine Verweis-Form schreibt die
Ziel-Fassung nicht vor"* gilt für `v5.3.1` mit: der Delta fügt keine Regel hinzu. Die
64-Treffer-Lektüre wird dafür **nicht** wiederholt — sie ist datiert und wahr, und ein
vollständiger Delta ohne neue Regel ist der kürzere Beweis. **Grenze:** dieser Nachweis deckt nur
den Schritt `v5.3.0` → `v5.3.1`. Für einen weiteren Bump gilt er nicht.

## Entscheidung

**Wir wählen Option G: die Aussagen des Bestands bleiben unberührt und werden ausgesprochen; die
Zukunft bindet sich an Tag und Zitat statt an den lokalen Pfad; wo ein Verweis in einem
Zeitdokument nach dem Tausch ins Leere zeigt, entfällt die Adresse und nicht der Text.** Vier
Festlegungen:

**1. Der Bestand der Accepted-ADRs wird nicht geheilt — kein Supersede, keine Migration.**
Die vier bleiben byte-gleich. Begründung, und sie ist empirisch, nicht formal: ihre Aussagen
werden durch den Tausch **nicht falsch**. Der Tag steht *im String*; die Zeichen `v3.5.2`
datieren die Fundstelle selbst, und wer nachschlägt, findet auf Platte einen anderen Tag und
sieht die Differenz sofort. Was bricht, ist die **lokale Auflösbarkeit** — eine Eigenschaft des
Arbeits-Cache, der laut [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
nie ein Archiv war. §3.4 gewinnt hier nicht als Formalie, sondern weil es nichts zu korrigieren
gibt — und weil die einzige Korrektur, zu der ein mechanischer Lauf greifen würde (Tag-String
ersetzen), an Zeile 129 nachweislich eine falsche Aussage erzeugte.

**Cutoff, wie ihn [`AGENTS.md`](../../../AGENTS.md) §3.7 führt:** gebunden ist der Verweis, der
geschrieben oder geändert wird. Der Bestand ist **kein Arbeitsauftrag**. **Bestand ist, was §3.4
bereits eingefroren hat** — ein Artefakt auf *Proposed* wird noch geschrieben und fällt unter
Festlegung 3, nicht unter diesen Cutoff.

**Was diese Festlegung kostet, trägt [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md):**
einer der nicht geheilten Verweise ist gate-sichtbar, und ohne eine Ausnahme bliebe
`make docs-check` nach dem Tausch dauerhaft rot.

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

**Was „verbatim" heißt: der Wortlaut ohne Auszeichnung, Whitespace normalisiert.** Nicht die
Quell-Bytes. Gemessen am ersten realen Fall — [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md)
zitiert *„keine Rolle springt rückwärts in eine vorhergehende, ohne Übergabe-Artefakt"*, die
Quelle schreibt `ohne *Übergabe-Artefakt*` und bricht den Satz über zwei Zeilen um; gegen den
whitespace-normalisierten Quelltext beider Tags gehalten: **mit** Auszeichnung je 1 Treffer,
**ohne** je 0. Drei Gründe: die Auszeichnung der Quelle trägt im zitierenden Text keine Bedeutung
mehr; der erste reale Anwendungsfall ist substanziell einwandfrei und fiele unter einer
byte-exakten Regel; und weil die Quelle umbricht, muss ohnehin jede Regel Whitespace
normalisieren — wer das tut, hat „Text statt Bytes" bereits zugestanden.

**Was Festlegung 2 nicht verbietet: den tag-losen Platzhalter in einer Layout-Beschreibung.**
Gebunden ist der **Beleg** — der Verweis, der eine Regelwerks-Aussage stützt —, nicht die Nennung
eines Pfad-Musters. Der Unterschied ist am Tag ablesbar: ein Beleg nennt einen konkreten Tag,
sonst belegt er nichts; eine Layout-Beschreibung nennt keinen, sonst beschriebe sie einen
Einzelfall. [ADR-0007](0007-bootstrap-phasen.md) ist der Ist-Beleg für die erlaubte Seite.

**Und sie ist kein Freibrief zum Ausschreiben von Normtext.** In **lebenden** Artefakten und in
Templates gilt die Baseline-Regel *„Der Zeiger ist kein Zitat"* unverändert: dort führte eine
zweite Fassung zur Drift. Festlegung 2 greift nur, wo Drift per Konstruktion ausgeschlossen ist.

**Der lokale Pfad bleibt erlaubt — in änderbaren Artefakten.** In
[`AGENTS.md`](../../../AGENTS.md), `harness/conventions.md`, den Spec-Straten, `CLAUDE.md` und
lebenden Plandateien ist er ein **Navigations-Zeiger**, und der Bump zieht ihn nach. Die Linie
dieser ADR verläuft damit nicht am Verweis-*Ziel*, sondern an der **Änderbarkeit der Quelle**.

**3. Träger der Regel: zwei Übergänge, nicht einer.**

- **(a) Der Accept-Übergang.** Bevor der Status eines ADR auf *Accepted* wechselt, werden seine
  Baseline-Belege in die Form aus Festlegung 2 gebracht.
- **(b) Der Abschluss eines Rollen-Reports oder einer Closure-Notiz.** Dieser zweite Träger ist
  der praktisch wirksamere: **alle vier** gate-sichtbaren Zeitdokument-Verweise stammen aus
  **Kopf-Metadaten von Rollen-Reports** — einer Konvention, die sich mit jedem Report
  reproduziert. Ohne Träger an diesem Übergang entsteht die verbotene Form fortlaufend neu, und
  jede Aufräumaktion wäre eine Momentaufnahme.

**Der Fall eines noch nicht angenommenen ADR ist entschieden, nicht offengelassen:** Ein
Proposed-Artefakt ist **kein Bestand**, sondern wird geschrieben — der Cutoff aus Festlegung 1
deckt es nicht, Träger (a) bindet es. Sein Beleg wird vor der Annahme in die Form gebracht, und
zwar aus einem Kosten-Grund: nach der Annahme ist derselbe Satz durch §3.4 unerreichbar, und der
Preis steigt von einer Zeile auf eine Folge-ADR. Gemessen am heutigen Bestand trägt **kein**
Proposed-ADR die verbotene Form
(`grep -c '\.harness/baseline/v[0-9]' docs/plan/adr/0015-*.md` → 0).

**Der Träger kann einen Sensor haben — gemessen, gegen die naheliegende Gegenbehauptung.** Zum
Accept-Zeitpunkt steht der Baum noch, also hat `links` über einen verbotenen Verweis nichts zu
melden. Daraus folgt **nicht**, dass an diesem Übergang kein Sensor stehen kann, sondern dass
`links` nicht der richtige ist: `links` fragt nach **Auflösbarkeit**, die Regel fragt nach
**Form**, und eine Form-Frage ist tag-unabhängig. Sonde, außerhalb des Repos gebaut und
zurückgenommen — eine Probe-ADR mit Status *Accepted* und genau der verbotenen Verweis-Form,
beide Sensoren am **selben Baum zum selben Zeitpunkt**:

| Sensor | Frage | Ausgang |
|---|---|---|
| `make docs-check` (`links`) | löst das Ziel auf? | **310 Dateien, 0 Befunde** — grün |
| Form-Sonde (bash + `grep`) | nennt ein Accepted-ADR einen **tag-gepinnten** Baseline-Pfad? | **1 Befund, Exit 1** — rot |

Der Träger ist damit **mechanisierbar**, nicht bloß menschlich. **Gebaut ist er nicht.**

**4. Ein Verweis in einem Zeitdokument verliert seine Adresse, nicht seinen Text.** Zeigt er nach
dem Tausch ins Leere, wird der Markdown-Link zur reinen Nennung: der sichtbare Text bleibt Zeichen
für Zeichen stehen, die tag-gepinnte Adresse entfällt. **Kein Satz ändert sich, keine Aussage wird
nachgezogen** — Zeitdokumente sind nicht von §3.4 geschützt, geschützt ist ihre Aussage. Der
Grund: nach dem Tausch ist die Wahl nicht *Link oder kein Link*, sondern **toter Link oder kein
Link**, und der Text trägt den Beleg ohnehin — die vier heute betroffenen Verweise nennen die
Eigenschaft im sichtbaren Text, einer sogar den Tag verbatim in derselben Tabellenzelle, die ein
Nachziehen gegen sich selbst stellte.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts entscheiden | kein Aufwand | der Tausch entscheidet die Frage faktisch, und zwar in Richtung „stumm falsch": drei Accepted-ADRs trügen eine unauflösbare Aussage ohne Sensor, und die naheliegende Reparatur (Tag-String ersetzen) verstieße gegen §3.4 **und** erzeugte an Zeile 129 ein falsches Zitat |
| B — beide Bäume **dauerhaft** nebeneinander vendoren | jeder Verweis bleibt auflösbar, keine Senkung nötig | der Baum wüchse mit jedem Bump, und „die adoptierte Baseline" wäre keine Menge von eins mehr — die Reproduzierbarkeits-Klammer aus [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) verlöre ihren Sinn, [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) fiele. **Abzugrenzen vom transienten Fall:** die Ziel-Prozedur *verlangt* beide Bäume während des Form-Vergleichs und lässt den alten danach fallen (Kontext, Punkt 4) — das ist kein Gegenargument gegen die Verwerfung des **dauerhaften** Nebeneinanders |
| C — Alias/Umleitung, die den Tag-Wechsel absorbiert | ein Pfad, der jeden Tausch überlebt | er überlebt ihn, **indem er lügt**: die ADR sagt `v3.5.2`, die Platte liefert `v5.3.0`. Gemessen an `modul-07-carveouts.md` Zeile 129 — bei `v3.5.2` *„Slice schlägt Memo"*, bei `v5.3.0` unverwandter Text: der Alias verwandelte einen toten Link in ein falsches Zitat, also einen lauten Fehler in einen stummen. Für den einen realen Fall trägt er ohnehin nicht: `grundlagen-konventionen.md` existiert in der Ziel-Fassung nicht mehr |
| D — `codepaths.roots` um `.harness` erweitern, um die stille Hälfte zu bewachen | 17 Inline-Nennungen bekämen einen Sensor; eine Zeile Config | **gemessen, verworfen** (Sonde: Root gesetzt, `make docs-check`, Config zurückgenommen): **44 `codepath-missing` in 17 Dateien**, davon **null** aus der gesuchten Klasse — der gepinnte Tag existiert ja noch. Die vier Klassen sind strukturell: **20**× der mit [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) entfernte Regelwerk-Cache (10 davon im lebenden `harness/conventions.md`), **10**× historische Tags in Zeitdokumenten, **11**× Pfade im **emittierten** Zielrepo, **3**× **Vorwärts-Verweise** auf den Baum, den der Tausch erst anlegt. Die letzte ist der Killer und nicht wegkonfigurierbar: `codepaths` kann *„soll existieren"* nicht von *„wird existieren"* unterscheiden, und eine Ausnahmeliste trüge den Tag-String, der laut Makefile-Kommentar allein in `BASELINE_TAG` leben soll — ~44 Einträge, bei jedem Bump neu zu pflegen, dauerhaft rot auf genau den Artefakten, deren Aufgabe es ist, abwesende Pfade zu nennen. Die Ziel-Fassung verlangt es auch nicht (Kontext, Punkt 3) |
| E — [ADR-0013](0013-technik-stratum-als-zielort.md) mit einer Folge-ADR superseden | formal die von §3.4 vorgesehene Bahn | die Entscheidung hat sich nicht geändert; ein Supersede für einen kaputten Pfad ist ADR-Inflation und macht aus einem Doku-Defekt einen Entscheidungs-Vorgang. Der Preis ist zudem groß: **16** Verweis-Vorkommen aus **10** lebenden Dateien zeigen auf ADR-0013, und `matrix.status` verbietet Verweise auf superseded ADRs |
| **G — gewählt: Bestands-Aussage aussprechen · Zukunft an Tag und Zitat binden · Zeitdokument-Adressen auflösen** | trennt die zwei Defekte, die alle anderen Optionen vermischen — *unauflösbar* und *unwahr*; die Regel hat zwei Träger, und einer davon ist mit einem gemessenen Gegenbeispiel mechanisierbar; sie ist gegen die Ziel-Fassung gehalten, nicht auf sie vertagt | die stille Hälfte bleibt unbewacht, und diese ADR baut den Sensor nicht; sie erzeugt eine Gate-Senkung als Folgeentscheidung ([ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)); Zeitdokumente werden angefasst, wenn auch nur an ihren Adressen |

## Konsequenzen

- **Positiv:** Die vier Accepted-ADRs bleiben, was sie sind — Geschichtsdokumente. Kein
  Supersede, kein Byte, keine Kaskade über `matrix.status`.
- **Positiv:** Die Frage ist **vor** dem Tausch beantwortet, und zwar für **21** Befunde statt
  für 17.
- **Positiv:** Die Entscheidung ist **vor dem Einfrieren** gegen die Ziel-Fassung gehalten. Was
  die Ziel-Fassung zur Verweis-Form sagt, steht im Kontext mit Kommando und Fundstelle.
- **Negativ:** Die **stille Hälfte bleibt stumm.** 17 Inline-Nennungen, davon 6 in
  Accepted-ADRs, sehen nach dem Tausch auf einen Baum, den es nicht gibt, und **kein Gate meldet
  das** — heute nicht und nach dieser Entscheidung nicht. Wer die Nennung liest, ohne den
  Tag-String zu lesen, hält sie für aktuell. Der Preis wird hier nicht als bewacht ausgegeben
  ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Negativ:** Sie erzwingt eine Gate-Senkung als Folgeentscheidung; deren eigener Preis steht in
  [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md).
- **Negativ:** Zeitdokumente werden angefasst. Das ist eine Ausnahme von der Linie
  *„Zeitdokumente bleiben unberührt"*, und sie ist eng: berührt wird die Adresse, nie der Text.
- **Negativ:** Festlegung 2 ist teurer im Schreiben. Ein Beleg mit Zitat ist länger als ein
  Pfad, und wer ihn schreibt, muss die Quelle gelesen haben. Das ist die Absicht, aber es ist
  Aufwand.
- **Folgepflicht 1 (der Slice, der den Baum tauscht):** die **16** gate-sichtbaren Links in den
  Spec-Straten und im Adaptions-Block auf den neuen Tag **und die neuen Dateinamen** ziehen —
  `grundlagen-konventionen.md` ist bei `v5.3.1` in sechs Dateien zerlegt, ein reiner Tag-Tausch
  reicht dort nicht, und **jeder Anker wird einzeln geprüft statt per `sed` über den Tag-String**
  (die Lehre aus Zeile 129); die lebenden Inline-Nennungen ebenso; die Zeitdokument-Adressen nach
  Festlegung 4 auflösen. **Diese ADR ändert keine Datei.**
- **Folgepflicht 2 (offen, eigener Slice):** die zwei Sensoren aus der Fitness Function.
  Sie sind hier **nicht** gebaut.

## Fitness Function (falls maschinell prüfbar)

**Gebaut:**

| Tooling | Regel | Make-Target |
|---|---|---|
| d-check `links` + `anchors` | Ein Markdown-Link in den vendored Baum löst auf, Ziel **und** Anker — auch wenn `scan.ignore` den Baum als Quelle ausnimmt. Zugleich der Formcheck, den die Ziel-Prozedur dem Doku-Gate zuweist | `make docs-check` |
| `baseline-verify` | Es existiert genau **ein** Tag-Verzeichnis, integer und vollständig — die Mechanik hinter [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache), auf der Festlegung 1 fußt | `make baseline-verify` |

**Nicht gebaut, aber mechanisierbar** — und diese ADR baut beides nicht:

1. **Form-Sensor zu Festlegung 2** (der Träger aus Festlegung 3). Eigenschaft: *kein
   unveränderlich gewordenes Artefakt nennt einen **tag-gepinnten** lokalen Baseline-Pfad.*
   Prüfbereich: alle Artefakte außer den vier Accepted-ADRs, die Festlegung 1 freistellt, und der
   in [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) ausgenommenen Datei —
   **einschließlich** der Zeitdokumente, denn dort ist die Form bisher entstanden.
   Tag-unabhängig, hermetisch, netzlos, bash + `grep`. **Gegenbeispiel rot gesehen**
   ([`AGENTS.md`](../../../AGENTS.md) §3.6): Tabelle in Festlegung 3. Der tag-lose Platzhalter
   darf ihn **nicht** färben — am Bestand belegt: mit der groben Regel *„kein
   `.harness/baseline/`"* meldet er [ADR-0007](0007-bootstrap-phasen.md) falsch-positiv, mit der
   tag-gepinnten Regel nicht.
2. **Pin-Sensor für lebende Artefakte.** Eigenschaft: *jede Zeichenkette
   `.harness/baseline/<X>/` in einem lebenden Artefakt erfüllt `<X> == BASELINE_TAG`.* Sein
   Gegenbeispiel: der Zustand unmittelbar nach dem Tausch, solange die 16 Links noch auf den
   alten Tag zeigen. **Was er nicht fängt:** die 6 Nennungen in Accepted-ADRs; dort gibt
   Festlegung 1 ihm nichts zu tun.

**Und ausdrücklich *nicht* d-checks `citations`-Modul.** Es wäre das naheliegende Werkzeug für
die Zitat-Hälfte; es ist es nicht, aus zwei gemessenen Gründen. Seine Direktive ist
**zeilenbereichs-adressiert** — das Werkzeug nennt die Form in seiner eigenen Fehlermeldung:
*„erwartet `d-check:cite <pfad>:<von>-<bis>`"*. Damit trüge jedes Zitat genau die Adresse, deren
Verfall diese ADR trägt. Zweitens ist das Modul **fail-closed** und bricht den ganzen Lauf ab,
sobald irgendwo eine syntaktisch unvollständige Direktive steht — gemessen bricht es heute an
einer **Prosa-Erwähnung** in `docs/plan/planning/done/slice-015-zitat-sensor.md`, also an einem
Zeitdokument, das über das Modul *schreibt*. Es wird deshalb nicht als Kandidat geführt
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
**Ungemessen geblieben** ist, ob es Auszeichnung normalisiert — das ließe sich nur feststellen,
indem man jenes Zeitdokument ändert, und Festlegung 4 gibt dafür keinen Grund her.

**Nicht mechanisierbar:** ob ein Beleg das *richtige* Zitat führt, ist ein Urteil. Der Form-Sensor
sieht, dass eine Adresse fehlt — nicht, ob das, was stattdessen dasteht, die Quelle trifft.

## Re-Evaluierungs-Trigger

- **Wenn eine künftige Baseline eine Verweis-Form für vendored Bäume vorschreibt**
  *(feedforward — eine Textänderung upstream, kein Sensor; die adoptierte Ziel-Fassung tut es nicht, siehe Kontext)*:
  dann bindet sie unabhängig von ihrer Rezeption hier, und diese Entscheidung ist gegen den neuen
  Wortlaut neu zu begründen oder als Abweichung zu deklarieren.
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
| 2026-08-09 | Überarbeitet, weiter **Proposed** | Bestätigungsrunde zur Gate-Senkung, `docs/reviews/2026-08-09-adr-0016-festlegung-4-bestaetigungsrunde.md` (2 HIGH). Der Ist-Bestand zählte lebende Artefakte, der Gate zählt mehr — Tausch gefahren: **21** statt 17 Befunde, vier davon in drei Zeitdokumenten. Die Senkung von einer intensionalen Aufnahme-Regel auf eine extensional geschlossene Liste umgestellt, ihr Preis über alle fünf Module beziffert, [`MR-001`](../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) als Zähl-Ort aufgenommen. Festlegung 3 bekommt den Report-/Closure-Abschluss als zweiten Träger. **Widerlegt:** dass an diesem Träger *per Konstruktion* kein Sensor stehen könne |
| 2026-08-09 | Überarbeitet, weiter **Proposed** | Auftraggeber-Einwand vor der Annahme: die Prüfung gegen die Ziel-Fassung stand als Folgepflicht und wäre nach dem Einfrieren wirkungslos gewesen. Sie ist **vorgezogen und gemessen** (64 Treffer über alle 26 Regelwerk- und 25 Template-Dateien von `v5.3.0`, einzeln gelesen). Zwei Baseline-Regeln aufgenommen: *„ein Datei-Link benennt keine Regel"* stützt Festlegung 2, *„Der Zeiger ist kein Zitat"* begrenzt sie auf unveränderliche Artefakte. *Verbatim* definiert, [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) als erster Anwendungsfall entschieden, `citations` als Werkzeug verworfen |
| 2026-08-09 | Überarbeitet, weiter **Proposed** | Auftraggeber-Entscheid: die Gate-Senkung ist eine andere Art Entscheidung und lebt als [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) — mit ihrem Preis, ihrer extensionalen Grenze und ihren Triggern; die Kopplung steht in beiden Köpfen. Die Zeitdokument-Festlegung auf ihre Regel reduziert, die vier Adressen an die Ausführung abgegeben. Sechs mess-tragende Abschnitte zu **zwei** zusammengelegt und die Verwerfung von Option D in die Alternativen-Tabelle gefaltet — **ohne Verlust einer Messung**; 509 → 401 Zeilen |
| 2026-08-09 | Überarbeitet, weiter **Proposed** | Der adoptierte Ziel-Stand der Welle ist `v5.3.1`. Die Prüfung gegen die Ziel-Fassung wird **nicht wiederholt**, sondern über den Delta geschlossen: 7 Dateien, **0** Überschriften im Delta (alle Anker halten), keine der fünf tragenden Quellen dieser ADR berührt, `modul-08-agentenrollen.md` in den Zeilen 1–149 byte-gleich. Gezogen sind nur die vorwärts gerichteten Zeiger; die datierten Messungen gegen `v5.3.0` bleiben stehen, weil sie wahr sind |
