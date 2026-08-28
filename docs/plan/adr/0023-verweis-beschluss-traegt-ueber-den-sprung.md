# ADR-0023: Der Verweis-Beschluss trägt über den Sprung, und Zeichenketten-Frische ist nicht sein Wächter

**Status:** Accepted

**Datum:** 2026-08-28

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Tag ist die
Reproduzierbarkeits-Klammer; diese ADR hält den Verweis-Beschluss gegen den Stand, der wirklich
adoptiert wird), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(die stille Hälfte bleibt unbewacht und wird hier so benannt — mit dem Werkzeug, das sie zu
bewachen schien, und dem Grund, warum es das nicht tut),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (der Beschluss, der hier neu gehalten wird),
[ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) (die Senkung, die er kostet),
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) (die Prozedur für den Sprung: am
2026-08-28 **Accepted** und damit geltend, angenommen im selben Commit wie diese ADR — was diese
ADR von ihr übernimmt, ist der Zielstand `v5.12.0` als **Mess-Operand**, und jede Messung unten
nennt ihren Tag selbst)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie regelt die **Form** eines Verweises auf die
vendored Baseline und die **Wächter-Frage** darüber, nicht den Inhalt eines Spec-Dokuments.

**Kopplung — diese ADR schreibt [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) nicht fort, sie
hält sie neu.** Jene Entscheidung ist ab *Accepted* unveränderlich
([`AGENTS.md`](../../../AGENTS.md) §3.4) und nennt ihre eigene Grenze: der Nachweis gegen die
Ziel-Fassung deckt genau einen Schritt, *„Für einen weiteren Bump gilt er nicht."* Der Zielstand
steht seither auf einem anderen Tag. Was hier steht, ist deshalb kein Supersede und keine
Korrektur, sondern die **Wieder-Vorlage einer Begründung gegen bewegte Quellen** — plus eine
Frage, die jene Entscheidung nicht kannte.

---

## Kontext

### Was bereits entschieden ist

Die vendored Baseline liegt `<tag>`-gescopt und trägt **einen Tag zur Zeit**
([`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).
Ein Bump ist ein **Tausch**; jeder Verweis mit dem Tag im lokalen Pfad verliert dabei sein Ziel,
auch der in einem Artefakt, das niemand mehr ändern darf.

[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) hat diesen Konflikt entschieden: der Bestand der
Accepted-ADRs wird **nicht geheilt** (Festlegung 1), ein Beleg in einem unveränderlich werdenden
Artefakt trägt **Tag, Dateiname, Abschnitt und Zitat** statt des lokalen Pfades (Festlegung 2 —
*Eigenschaft statt Adresse*), die Regel hat **zwei Träger** (Festlegung 3), und ein Verweis in
einem Zeitdokument **verliert seine Adresse, nicht seinen Text** (Festlegung 4).
[ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) trägt den Preis: `scan.ignore`
nimmt **genau eine namentlich genannte Datei** auf, extensional geschlossen.

### Warum es hier trotzdem etwas zu entscheiden gibt

**Zwei Dinge haben sich bewegt, und beide sind gemessen.**

**Erstens: vier der fünf tragenden Quellen jener Begründung sind seither geändert.** Jene
Begründung maß gegen `v5.3.0` und schloss von dort über einen vollständig gelesenen Delta auf den
adoptierten Stand `v5.3.1` — zwei benachbarte Kurs-Tags. **Bezugspunkt hier ist `v5.3.1`**, das
Ende jener Schließung und der Zielstand, von dem aus
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) ihre zwei Züge protokolliert
(`v5.3.1` → `v5.9.0` → `v5.12.0`). Ab dort misst derselbe
Ausschnitt **31 Dateien, +609/−149 Zeilen**
(`git diff --shortstat v5.3.1 v5.12.0 -- lab/regelwerk lab/templates`, lokaler Kurs-Klon); ab
`v5.3.0`, dem Stand, gegen den jene Sonden liefen, sind es **33 Dateien, +622/−161**
(dasselbe Kommando mit `v5.3.0`). **Die Wahl des Bezugspunkts bewegt genau diese eine Zahl und
keine Folgerung dieser ADR** — gemessen: die Trefferliste des Suchraums unten ist an beiden Tags
byte-gleich (beide Listen whitespace-normalisiert und sortiert, `diff` meldet keinen
Unterschied), die vier tragenden Zitate stehen an beiden mit denselben Zählwerten, und es sind
dieselben vier der fünf Quellen, die im Delta erscheinen. Byte-gleich bleibt allein das
Carveout-Modul
(`git diff --name-only v5.3.1 v5.12.0 -- lab/regelwerk/modul-07-carveouts.md lab/regelwerk/grundlagen-harness-dateien.md lab/regelwerk/modul-04-adrs.md lab/regelwerk/modul-02-harness-bootstrap.md lab/templates/harness/conventions/MR-NNN-titel.template.md`
→ vier Zeilen, das Carveout-Modul fehlt darin; mit `v5.3.0` dieselben vier Zeilen). Eine
Begründung, deren Quellen sich bewegt haben und die niemand nachgehalten hat, ist eine adoptierte
Behauptung.

**Zweitens: ein Kandidat für die stille Hälfte ist aufgetaucht, den jene Entscheidung nicht
kannte.** Sie hat das Verbatim-Modul geprüft und mit Grund verworfen und zwei ungebaute Sensoren
benannt. Das Modul `versions` des Doku-Gate-Werkzeugs kommt darin nicht vor. Es bindet jeden
Versions-Pin an die aktuelle Version seines Paares und meldet gegen die stille Hälfte — das ist
der Anlass dieser ADR und der Grund, warum die Frage *„bleibt die stille Hälfte unbewacht?"* noch
einmal gestellt wird, statt aus jener Entscheidung übernommen zu werden.

### Ist-Bestand: zwei ungleich sichtbare Hälften

**Mess-Basis der Bestands-Zahlen dieser ADR ist der Commit `4e62366`** — dieser Abschnitt,
§*Die Messung, die die Frage neu stellt*, die Zeilen B, C und D der Alternativen-Tabelle und die
Verweis-Zählungen in §Konsequenzen. Die abgedruckten `git grep`-Kommandos laufen über einen
Arbeitsbaum auf dem Stand dieses Commits, die Gate-Sonden über eine Kopie außerhalb des Repos
(`git archive 4e62366 | tar -x -C <Kopie>`); Zeile B nennt ihren eigenen, früheren Stand.
**Diese Zahlen wandern mit dem Bestand und sind keine Erwartungswerte**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2): jedes Markdown-Artefakt, das über den alten Tag schreibt, hebt sie, und ein Lauf über
einen späteren Stand liefert andere Beträge. Reproduzierbar sind sie gegen den genannten Commit
([`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)); tragend ist ihre
**Verteilung** auf die zwei Hälften, nicht ihr Betrag.

**Nenner — was dieses Repo pflegt.** Lebende Artefakte; Zeitdokumente ausgenommen, weil sie die
richtige Aussage über ihren Stand sind:

```sh
git grep -o "\.harness/baseline/v3\.5\.2/[^ )]*" \
  -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' | wc -l
# -> 56   Nennungen; mit "| cut -d: -f1 | sort -u | wc -l" -> 14 Dateien

git grep -oE '\]\([^)]*\.harness/baseline/v3\.5\.2/[^)]*\)' -- <dieselben Pathspecs> | wc -l
# -> 20   LAUTE Haelfte, Markdown-Links

git grep -h "\.harness/baseline/v3\.5\.2/" -- <dieselben Pathspecs> \
  | sed -E 's/\]\([^)]*\)//g' | grep -o "\.harness/baseline/v3\.5\.2/[^ )\`]*" | wc -l
# -> 36   STILLE Haelfte, Inline-Nennungen
```

**Was der Gate wirklich meldet, und er zählt anders.** Gefahren statt hochgerechnet: eine Kopie
des Baums außerhalb des Repos (`git archive 4e62366 | tar -x -C <Kopie>`), darin das
`<tag>`-Verzeichnis der Baseline auf den Ziel-Tag umbenannt, dann das Doku-Gate im gepinnten
Image über den Mount `:ro`. Der Referenzlauf ohne Umbenennung meldet
`440 Datei(en) geprüft, 0 Befund(e)`, der Lauf danach:

```
d-check: 440 Datei(en) geprüft, 24 Befund(e)     # alle target-missing
```

Tragend ist die **Befund**-Zahl und ihre Verteilung; die geprüfte Datei-Zahl ist der
Markdown-Bestand des Repos im genannten Commit und wächst mit ihm — sie gilt für jeden
Sonden-Lauf dieses Abschnitts.

| Quelle | Zahl | Änderbar? |
|---|---|---|
| Technik-Stratum (12) + Adaptions-Block (4) | **16** | ja — lebende Artefakte, der Tausch zieht sie nach |
| eine lebende Plandatei | **3** | ja |
| [ADR-0013](0013-technik-stratum-als-zielort.md) | **1** | **nein** — [`AGENTS.md`](../../../AGENTS.md) §3.4 |
| ein Zeitdokument in `docs/plan/planning/done/` (2) und zwei in `docs/reviews/` (1 + 1) | **4** | Zeitdokument: von §3.4 nicht geschützt, inhaltlich aber datiert |

**Die namentliche Ausnahme aus [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)
trifft heute noch genau.** Unter den 24 Befunden liegt **genau einer** in einem von §3.4
eingefrorenen Artefakt, und es ist dieselbe Datei wie damals — die extensionale Grenze jener
Senkung reicht für diesen Sprung ohne Erweiterung. Das ist eine Aussage über den heutigen
Bestand, kein Versprechen: die Verteilung oben ist der Beleg, und sie wandert.

**Was der Gate nicht sieht: die stille Hälfte.** `codepaths.roots` führt `spec`, `docs`,
`harness` — der Punkt vor `harness` fehlt, und ein Pfad unterhalb des Punkt-Verzeichnisses fällt
damit aus dem Prüfbereich. Von den 36 stillen Nennungen liegen **6** in drei Accepted-ADRs
([ADR-0011](0011-telemetrie-erfassung-policy.md) 1,
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) 3,
[ADR-0014](0014-aufgehobener-eintrag-kopf-statt-rumpf.md) 2 —
`git grep -h "\.harness/baseline/v3\.5\.2/" -- 'docs/plan/adr/0011-*.md' 'docs/plan/adr/0012-*.md' 'docs/plan/adr/0014-*.md' | sed -E 's/\]\([^)]*\)//g' | grep -o "\.harness/baseline/v3\.5\.2/[^ )\`]*" | wc -l`
→ 6).

### Die Messung, die die Frage neu stellt — und was sie wirklich sagt

Trockenlauf des Moduls `versions` gegen eine Kopie des Baums außerhalb des Repos
(`git archive 4e62366 | tar -x -C <Kopie>`), netzlos, Mount `:ro`, Doku-Gate-Image per Digest.
Konfiguration in der Kopie: `versions` in die Modul-Liste aufgenommen, `pin-pattern`
`baseline/(v[0-9]+\.[0-9]+\.[0-9]+)`, `current-from` ein angelegter Span mit dem Ziel-Tag,
`exempt-paths` für beide Zeitdokument-Bäume:

**Das Modul hat in diesem Repo kein Ziel, über das man es fahren könnte** — der Trockenlauf
musste es erst verdrahten. Kein Ziel der Gate-Datei heißt nach ihm
(`grep -c '^doc-versions:' d-check.mk` → 0, Exit 1); es erscheint dort ausschließlich als
Abschalter in den Aufrufen der opt-in-Ziele (`grep -c 'disable versions' d-check.mk` → 6).
Wer es als vorhandenes Ziel führt, führt ein Gate, das es nicht gibt
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

```
d-check: 441 Datei(en) geprüft, 58 Befund(e)     # alle version-stale, ueber 16 Dateien
```

Auch diese zwei Zahlen wandern und sind keine Erwartungswerte
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2); tragend ist, **wo** die Befunde liegen.

**Erste Beobachtung, und sie geht über den Anlass hinaus: getroffen sind SECHS Accepted-ADRs.**
Neben den drei stillen und dem einen lauten meldet das Modul je einen Treffer in
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) und
[ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) — an den Stellen, an denen
diese den Verzeichnisnamen als **Gegenstand ihrer eigenen Umbenennungs-Sonde** nennen. Neun
Befunde in sechs Dateien, die [`AGENTS.md`](../../../AGENTS.md) §3.4 eingefroren hat, und keiner
davon ist behebbar. **Sechs, weil das `pin-pattern` des Moduls den Tag ohne Folgepfad fängt:**
eine Suche, die den Folgepfad verlangt
(`git grep -l "\.harness/baseline/v3\.5\.2/" -- 'docs/plan/adr/*.md'`), findet vier Dateien —
[ADR-0011](0011-telemetrie-erfassung-policy.md),
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md),
[ADR-0013](0013-technik-stratum-als-zielort.md) und
[ADR-0014](0014-aufgehobener-eintrag-kopf-statt-rumpf.md) — und in den zwei anderen nichts. Beide
Zählungen sind richtig; sie zählen verschiedene Mengen.

**Zweite Beobachtung, und sie entscheidet: `versions` misst nicht, was `links` misst.** Sonde
über alle vier Felder der 2 × 2, in einem Minimal-Repo mit beiden Modulen, einem angelegten
Ziel-Baum und einem Span auf den Ziel-Tag:

| Verweis | löst auf? | Zeichenkette aktuell? | `links` | `versions` |
|---|---|---|---|---|
| Link auf eine vorhandene Datei unter dem Ziel-Tag | ja | ja | still | still |
| Inline-Nennung unter dem alten Tag | — | nein | still | **`version-stale`** |
| Link auf eine **fehlende** Datei unter dem **Ziel**-Tag | **nein** | ja | **`target-missing`** | **still** |
| Link auf eine vorhandene Datei unter dem **alten** Tag | nein | nein | **`target-missing`** | **`version-stale`** |

Die dritte Zeile ist der Beleg: ein Verweis, der **ins Leere zeigt** und den **aktuellen** Tag
trägt, lässt `versions` schweigen. Die zweite ist ihr Gegenstück: eine Nennung, die **niemand
auflösen soll**, färbt es rot. Die beiden Module stehen orthogonal zueinander — `versions` ist
ein **Frische-Wächter über Zeichenketten**, kein Auflösungs-Wächter. Es belegt damit, dass die
stille Hälfte **auffindbar** ist; es belegt nicht, dass sie damit bewacht wäre.

**Drei Klassen, die das Modul nicht unterscheiden kann — je mit einem Ist-Beleg.** Was eine
Nennung des alten Tags ist, entscheidet der Satz um sie herum, nicht die Zeichenkette:

1. **Adresse.** Ein Zeiger, der auflösen soll. Der Tausch macht ihn falsch, das Nachziehen ist
   richtig. Ist-Belege: die 20 Markdown-Links des Bestands — und die Inline-Zeiger des
   Adaptions-Blocks, die dieselbe Pflicht tragen, ohne die Link-Form zu haben.
2. **Datierte Aussage.** Der Tag ist Teil der Aussage; sie bleibt wahr, weil die Zeichen die
   Fundstelle selbst datieren. Das Nachziehen machte sie **falsch** — das ist die Begründung von
   [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 1, dort an einer Zeilen-Referenz
   gemessen, deren mechanisch getauschter Tag ein Zitat erzeugte, das die Quelle nicht hergibt.
   Ist-Beleg: die 6 stillen Nennungen in den drei Accepted-ADRs.
3. **Operand.** Der Tag ist Eingabe einer Messung — der Gegenstand einer Sonde oder der
   Tree-Operand eines Vergleichs über den Tausch hinweg. Das Nachziehen zerstört die Messung.
   Ist-Belege: die zwei Sonden-Nennungen in
   [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) und
   [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md), sowie eine lebende
   Plandatei, die den alten Tag als Tree-Operanden der **Vor**-Tausch-Seite führt.

Erkennbar ist allein die **Link-Form** — genau das misst `links`. Klasse 1 ist aber größer
als sie: der Adaptions-Block führt Inline-Zeiger, die der Tausch ebenso nachziehen muss.
Zwischen einem Inline-Zeiger, einer datierten Aussage und einem Operanden verläuft keine
Grenze, die eine Zeichenkette trüge — dieselbe Form steht im Adaptions-Block als
Navigations-Zeiger und in einer Plandatei als Tree-Operand.

**Der Preis ohne Zeitdokument-Ausnahme ist beziffert.** Derselbe Lauf ohne `exempt-paths`:

```
d-check: 441 Datei(en) geprüft, 284 Befund(e)    # ueber 119 Dateien
```

Davon liegen **226** in Zeitdokumenten (`docs/reviews/**` und `docs/plan/planning/done/**` über
die Befundzeilen gezählt) — also auf genau den Sätzen, die
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 4 unangetastet lässt: *„Kein Satz
ändert sich, keine Aussage wird nachgezogen."* Auch diese drei Zahlen wandern, und sie wandern
schneller als die 58: jeder Review-Report und jede abgeschlossene Plandatei, die über den alten
Tag schreibt, hebt sie ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Tragend ist ihr **Verhältnis** zur Zahl mit Ausnahme, nicht ihr Betrag.

**Der einzige zeilengenaue Ausweg ist eine Textänderung.** Sonde im Minimal-Repo: zwei Zeilen mit
demselben veralteten Pin, eine davon mit dem Zeilen-Marker `d-check:ignore` als
HTML-Kommentar — gemeldet wird **die Zeile ohne Marker**, `1 Befund`. In einem von §3.4
eingefrorenen ADR ist dieser Ausweg verschlossen; es bliebe `exempt-paths`, und das wirkt
datei-weit.

**Und es liest Markdown.** Sonde: drei Dateien mit demselben Pin in die Kopie gelegt
(`.md`, `.sh`, `.txt`). Die geprüfte Dateizahl steigt um **eins** statt um drei, gemeldet
wird **eine** Zeile,
und zwar die der Markdown-Datei. Der **autoritative** Pin dieses Repos steht in einer Zeile, die
das Modul aus zwei Gründen nicht erreicht — sie liegt nicht in Markdown, und sie trägt das
Präfix des `pin-pattern` nicht: `grep -n '^BASELINE_TAG ?=' Makefile` → Zeile 26. Kein
getrackter Nicht-Markdown-Träger führt die Zeichenkette überhaupt
(`git grep -l 'baseline/v3\.5\.2' -- ':!.harness/baseline' | grep -cv '\.md$'` → 0, Exit 1). Ein
adoptiertes `versions` bewachte damit 58 abgeleitete Nennungen und **nicht** die eine Zeile, die
den Tag setzt.

### Gegen die Ziel-Fassung gehalten

Diese Prüfung gehört **vor** das Einfrieren, aus demselben Grund wie beim Vorgänger-Beschluss:
eine Folgepflicht, die erst nach der Annahme griffe, könnte an einem
[`AGENTS.md`](../../../AGENTS.md) §3.4-immutablen Artefakt nichts mehr bewirken. Alle Messungen
gegen einen lokalen Kurs-Klon.

**Der Delta der vier bewegten tragenden Quellen ist vollständig gelesen, Zeile für Zeile.** Er
ist klein genug dafür — **4 Dateien, +90/−11 Zeilen**
(`git diff --numstat v5.3.1 v5.12.0 -- lab/regelwerk/grundlagen-harness-dateien.md lab/regelwerk/modul-02-harness-bootstrap.md lab/regelwerk/modul-04-adrs.md lab/templates/harness/conventions/MR-NNN-titel.template.md`
→ 70/6 · 13/4 · 6/0 · 1/1) —, und das ist die Methode des Vorgänger-Beschlusses, angewandt auf
den Ausschnitt, an dem seine Begründung hängt. Was der Delta enthält:

- **Das ADR-Modul (+6):** eine ADR entsteht auch aus einem Rollen-Konflikt, und *„Die Entscheidung
  wird immutabel, Widerspruch braucht danach eine Folge-ADR mit neuer Evidenz."* Das **stützt**
  Festlegung 1 und die Bahn, auf der diese ADR läuft.
- **Das Bootstrap-Modul (+13/−4):** der Adaptions-Delta-Audit bekommt einen dritten Ausgang — das
  Repo darf die neue Baseline-Regel **übernehmen** —, und wer übernehmen will, aber noch nicht
  kann, schreibt einen Carveout statt einer Adaption. Zur Verweis-Form sagt der Zusatz nichts;
  die Formcheck-Zuweisung, die unten zitiert wird, liegt außerhalb des geänderten Blocks.
- **Die Grundlagen-Datei zu den Harness-Dateien (+70/−6):** Zustandsfelder tragen Zustand und
  Beleg statt Chronik, ein lebendes Register trägt keine Status-Kopfzeile, das Agenten-Briefing
  bekommt eine Leseordnung — und ein Block über die **Adressierung von Adaptions-Einträgen**:
  verlinkt wird die Index-Zeile des Registers, nicht die Eintrags-Datei, weil die bei Auflösung
  wandert und ein Pfad-Link *„genau in dem Moment"* bricht, in dem die Adaption sich auflöst.
- **Die Adaptions-Vorlage (1 Zeile, ihre einzige Änderung):** dieselbe Regel in der Vorlage — das
  Feld *Löst auf* trägt einen Link auf die Index-Zeile statt eines Pfades auf die Eintrags-Datei,
  mit derselben Begründung.

**Zwei dieser Stellen schreiben eine Verweis-Form vor — und ihr Grund ist der dieser ADR.** Sie
gelten dem Adaptions-Register, nicht dem vendored Baum, und sie verwerfen eine Adresse, weil ihr
Ziel wandert: Eigenschaft statt Adresse, an einem anderen Gegenstand. Der Negativsatz unten —
*für vendored Bäume* schreibt die Ziel-Fassung keine Form vor — bleibt davon unberührt; **das
Muster unten fängt diese Zeile nicht**, und was das über die Methode sagt, steht in §*Grenze
dieser Aussagen*.

**Die vier tragenden Zitate überleben den Sprung wörtlich.** Je Zitat über beide Tags gezählt
(`for q in 'Der Zeiger ist kein Zitat' 'ein Datei-Link benennt keine Regel' 'wird nicht inhaltlich überschrieben' 'gültige Link-Ziele'; do for t in v5.3.1 v5.12.0; do git grep -c "$q" $t -- lab/regelwerk lab/templates | wc -l; done; done`
→ acht Zeilen, paarweise gleich: 1 1 · 1 1 · 2 2 · 1 1). Die vier geänderten Trägerdateien haben
also die Sätze nicht verloren, an denen jene Begründung hängt.

**Eine allgemeine Verweis-Form für vendored Bäume schreibt die Ziel-Fassung weiterhin nicht
vor.** Der Suchraum ist derselbe wie beim Vorgänger-Beschluss — alle Regelwerk- und
Template-Dateien, ein Muster aus elf Alternativen um Vendoring, Zitat und Fundstelle (unten
abgedruckt; jener Beschluss spricht bei demselben Muster von *zwölf Wörtern* — abgezählt sind es
elf, und an seinem Ergebnis ändert die Zahl nichts). Er wächst von **64** auf
**68** Treffer:

```sh
PAT='vendor|\.harness/baseline|<tag>|verbatim|Zitat|zitier|Fundstelle|Belegstelle|Zeilennummer|Verweis-Form|Referenz-Form'
for t in v5.3.1 v5.12.0; do git grep -nEi "$PAT" $t -- lab/regelwerk lab/templates | wc -l; done
# -> 64   68
```

Die Differenz ist über die Trefferzeilen selbst gebildet und beträgt **vier neue
Zeilen** (beide Trefferlisten whitespace-normalisiert, sortiert, `comm -13`). Alle vier sind
gelesen: zwei stehen in der Grundlagen-Datei zur Source Precedence — die es am Bezugs-Tag bereits
gibt, neu sind die zwei Zeilen —, eine im Quality-Gates-
Modul über die **gelesene Ursache** eines roten Sensors, eine in einer Roadmap-Vorlage über einen
Marker, der bewusst nicht zitiert wird. **Keine schreibt eine Verweis-Form vor.**

**Zwei neue Stellen stützen die Entscheidung, statt sie zu bewegen.**

1. `grundlagen-referenz-richtung.md` (Tag `v5.12.0`), §Spec-Straten: mehr als ein Spec-Dokument, verbatim:
   *„Eine vertraute Dokument-Gattung legt ein Stratum nahe, weil ihre Form an eines erinnert.
   Form ist kein Beleg — sie sagt, wie ein Dokument aussieht, nicht, wer es ändern darf."* Und
   davor, zur Rangfrage zwischen zwei Achsen: *„Der Änderungs-Prozess ist dagegen beobachtbar:
   Wer darf diese Datei ändern, und mit wessen Einverständnis?"* Das ist genau die Linie, an der
   der Vorgänger-Beschluss verläuft — nicht am Verweis-**Ziel**, sondern an der **Änderbarkeit
   der Quelle** —, und es ist zugleich der Satz gegen `versions`: das Modul entscheidet nach der
   **Form** einer Zeichenkette und kann nicht sehen, wer die Datei ändern darf.
2. `grundlagen-source-precedence.md` (Tag `v5.12.0`), §Source Precedence, verbatim:
   *„Wie weit trägt ein zitierter Satz? … Sie ist an jede zitierte Aussage zu stellen, auch an
   einen Satz der Baseline: Gilt er auch außerhalb des Falls, für den er geschrieben wurde?"*
   Diese Frage ist neu und trifft diese ADR selbst; sie ist der Grund, warum Festlegung 4 unten
   ein **Kriterium** setzt und kein Ergebnis.

**Die Zuweisung des Formchecks an das Doku-Gate steht am Zielstand wörtlich.**
`modul-02-harness-bootstrap.md` (Tag `v5.12.0`), §Freshness-Audit der vendored Baseline
(Schritt 2), verbatim: *„Davor steht ein Formcheck — den erledigt das Doku-Gate: Die vendored
Baseline liegt im Repo, ihre Dateien sind gültige Link-Ziele … Einmal prüfen, dass
`.harness/baseline/` im Prüfumfang liegt; danach automatisch."* Verlangt ist Auflösbarkeit als
**Ziel** — das ist die Eigenschaft, die `links` misst und `versions` nicht.

**Kein Versions-Pin-Gate im Regelwerk, an keinem der beiden Tags.**
`git grep -nEi 'version-stale|Versions-Pin|pin-pattern|current-from' <tag> -- lab/regelwerk lab/templates | wc -l`
→ **0** für `v3.5.2` wie für `v5.12.0`. Das Modul nicht zu adoptieren ist damit **keine
Abweichung von der Baseline** und schuldet keinen Eintrag im Adaptions-Block
([`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage)).

**Grenze dieser Aussagen, und sie ist an einem Fall gemessen:** ein Negativ aus einem
aufgezählten Suchraum. Eine Regel ohne eines der elf Alternativen des abgedruckten Musters wird
nicht gefunden — und genau das ist der Adaptions-Vorlage passiert: ihre geänderte Zeile schreibt
eine Verweis-Form vor und trägt dabei blankes *Verweis*, keines der elf Wörter. Sie steht darum
**nicht** unter den vier neuen Zeilen (dieselbe Zeile whitespace-normalisiert gegen die
`comm -13`-Liste gehalten → **0** Treffer, während `grep -c 'Verweis'` über sie **1** liefert).
Gefunden hat sie der vollständig gelesene Delta oben — das ist die Arbeitsteilung der zwei
Methoden: der Muster-Vergleich deckt die 31 Dateien, die niemand Zeile für Zeile liest, das
vollständige Lesen die vier, an denen die Begründung hängt. Und der Vergleich der Trefferlisten
sieht neue **Zeilen**, nicht neue **Bedeutungen** einer unveränderten Zeile in geändertem Umfeld.

## Entscheidung

**Wir wählen Option E: der Beschluss wird gegen die Ziel-Fassung neu gehalten statt
fortgeschrieben, und der stillen Hälfte wird kein Frische-Wächter untergeschoben — sie bleibt
unbewacht und heißt so.** Fünf Festlegungen:

**1. [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegungen 1 bis 4 und
[ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) gelten für diesen Sprung
unverändert fort.** Kein Supersede, kein Byte an beiden. Der Bestand der Accepted-ADRs wird nicht
geheilt; ein Beleg in einem unveränderlich werdenden Artefakt trägt Tag, Dateiname, Abschnitt und
Zitat; ein Verweis in einem Zeitdokument verliert seine Adresse, nicht seinen Text; die
Doku-Gate-Ausnahme bleibt bei ihrer einen namentlich genannten Datei. **Neu ist nicht die
Festlegung, sondern ihr Beleg**: die tragenden Zitate sind gegen den Zielstand gehalten, das
Negativ zur Verweis-Form ist gegen ihn wiederholt, und die Verteilung der Gate-Befunde ist über
den Tausch-Trockenlauf neu gemessen (§Kontext).

**2. Die Regel für künftige Verweise bleibt *Eigenschaft statt Adresse* — ausdrücklich nicht das
Gegenteil.** Wer einen Beleg in ein Artefakt schreibt, das unveränderlich wird, nennt Tag,
Regelwerks-Dateinamen, Abschnitt und Zitat; der lokale `<tag>`-Präfix und die Zeilennummer als
alleiniger Locator gehören nicht dazu. In **änderbaren** Artefakten bleibt der lokale Pfad ein
Navigations-Zeiger, und der Bump zieht ihn nach. Die Ziel-Fassung stützt diese Linie an einer
Stelle, die der Vorgänger-Beschluss noch nicht hatte: *„Form ist kein Beleg — sie sagt, wie ein
Dokument aussieht, nicht, wer es ändern darf."*

**3. Das Modul `versions` wird als Wächter der stillen Hälfte verworfen. Die stille Hälfte bleibt
unbewacht, und dieser Text gibt sie nicht als bewacht aus**
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Drei
gemessene Gründe:

- **Es misst die falsche Eigenschaft.** Zeichenketten-Frische, nicht Verweis-Auflösung; der
  Ausfall ist in **beide** Richtungen gemessen (§Kontext, 2 × 2-Sonde). Ein Verweis, der ins
  Leere zeigt und den aktuellen Tag trägt, bleibt still.
- **Es kann die drei Klassen nicht trennen** und verlangte auf zweien von ihnen eine Änderung,
  die die Aussage **falsch** machte — genau der mechanische Tag-Tausch, den der
  Vorgänger-Beschluss an einem Zitat gemessen und verworfen hat.
- **Sein zeilengenauer Ausweg ist eine Textänderung**, und §3.4 verbietet sie auf sechs
  Accepted-ADRs. Was bliebe, ist die datei-weite Ausnahme — und die nähme dieselben ADRs auch
  aus jeder künftigen Prüfung desselben Moduls.

**Nur der erste dieser Gründe ist eine Eigenschaft des heutigen Werkzeugs.** Der zweite ist eine
Eigenschaft des **Bestands**: die Klasse steht im Satz um die Nennung, nicht in der Zeichenkette.
Der dritte ist zur einen Hälfte Werkzeug — der Ausweg steht im Text statt in der Konfiguration —
und zur anderen [`AGENTS.md`](../../../AGENTS.md) §3.4. Was ein Werkzeug-Release daran bewegt und
was nicht, steht im dritten Re-Evaluierungs-Trigger.

**Was diese Festlegung nicht sagt: dass das Modul untauglich wäre.** Für den Fall, für den es
gebaut ist — ein Pin, der der aktuellen Version **folgen soll** —, trägt es; das ist die Klasse 1
oben. Es ist kein Wächter **dieser** Eigenschaft, weil der Bestand hier aus drei Klassen besteht
und zwei davon nicht folgen dürfen.

**4. Allgemein ist das Kriterium, nicht das Ergebnis.** Ein Sensor über einem `<tag>`-gescopten
Bestand wird nur adoptiert, wenn er die drei Klassen aus §Kontext **trennt**. Wer einen Sensor
vorschlägt, zeigt das an je einem **Ist-Beleg** pro Klasse aus dem laufenden Bestand — nicht an
einer Beschreibung des Werkzeugs. Ein Sensor, der Klasse 1 fängt und die anderen mitreißt, ist
kein halber Wächter, sondern ein Auftrag, wahre Sätze falsch zu machen. **Ohne dieses Kriterium
wäre die Verwerfung oben ein Urteil über ein Werkzeug**; mit ihm ist sie die Anwendung einer
Regel, die den nächsten Kandidaten ebenso bindet.

**5. Diese Entscheidung ist keine Gate-Senkung — und das steht hier, weil
[`AGENTS.md`](../../../AGENTS.md) §3.5 für eine Senkung genau dieses Gefäß verlangt und die Frage
darum beantwortet gehört, nicht übergangen.** Vier Prüfungen, jede mit ihrem Befund:

- Sie **ändert die Gate-Konfiguration nicht.** Diese ADR berührt `.d-check.yml` nicht.
- Sie **nimmt keine Ziele unter dem Baseline-Verzeichnis aus.** Die naheliegende bequeme Antwort
  — Link-Ziele in den vendored Baum vom Check ausnehmen — ist hier **nicht** gewählt; sie nähme
  die 16 heute gate-sichtbaren Verweise aus Technik-Stratum und Adaptions-Block mit aus der
  Prüfung und hätte damit einen weit größeren Geltungsbereich als ihr Anlass.
- Sie **erweitert die bestehende Senkung um keinen Eintrag.** Die eine Senkung in dieser Sache
  ist [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md), extensional geschlossen;
  der Tausch-Trockenlauf zeigt heute genau einen Befund in einem eingefrorenen Artefakt, und es
  ist dieselbe Datei.
- Sie **deaktiviert kein Modul.** `versions` steht heute nicht in der Modul-Liste; der Verzicht
  lässt den Prüfumfang, wie er ist. Umgekehrt gilt: **würde** das Modul je adoptiert, wäre das
  eine Verschärfung — aber **jede** Ausnahme, die dabei ein eingefrorenes ADR oder ein Ziel unter
  dem Baseline-Verzeichnis freistellt, ist eine Senkung nach §3.5 und braucht ihr eigenes Gefäß.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts entscheiden, der Vorgänger-Beschluss gilt einfach weiter | kein Aufwand, kein neues Artefakt | er nennt seine Grenze selbst (*„Für einen weiteren Bump gilt er nicht."*), und **vier von fünf** seiner tragenden Quellen sind seither geändert. Wer nichts entscheidet, adoptiert eine Begründung, deren Quellen er nicht gelesen hat — und lässt zugleich die `versions`-Messung als stummen Widerspruch stehen |
| B — [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) superseden und neu schreiben | die von [`AGENTS.md`](../../../AGENTS.md) §3.4 vorgesehene Bahn für eine Korrektur | die Entscheidung hat sich **nicht geändert**; ein Supersede für eine nachgehaltene Begründung ist ADR-Inflation. **Gemessen, nicht geschätzt:** der Statuswechsel allein erzeugt **23 `matrix-inactive` über 9 Dateien** (Sonde in einer Kopie außerhalb des Repos über dem Commit `363421c` — dem Bestand **ohne** diese ADR, die es nur gibt, weil der Supersede verworfen wurde: Status-Zeile auf *Superseded* gesetzt, Doku-Gate gefahren). In ADR-Dateien liegen davon **15**, über **sieben** Dateien. Zum Stand der Sonde lagen **12 über sechs** in *Accepted*-ADRs, die §3.4 einfriert — dort wäre die Reparatur in keiner erlaubt; die siebte war [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) mit drei Befunden, damals `Proposed` und darum nicht mitgezählt. **Mit ihrer Annahme am 2026-08-28 sind es 15 über sieben:** die Sonde ist unberührt, sie misst den Verweis-Bestand; der Status entscheidet nur, welcher Teil ihres Ergebnisses unreparierbar ist — und das ist jetzt der ganze. Alle diese Zahlen wandern mit dem Verweis-Bestand ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2) |
| C — `versions` adoptieren, die betroffenen Accepted-ADRs per `exempt-paths` freistellen | die 36 stillen Nennungen bekämen einen Sensor; eine Config-Sektion | **gemessen, verworfen:** der Sensor misst die falsche Eigenschaft (2 × 2-Sonde), trennt die drei Klassen nicht und verlangte auf zweien eine falsch machende Änderung. Die Ausnahmeliste trüge sechs Accepted-ADRs plus zwei Zeitdokument-Bäume, wüchse mit jedem Artefakt, das über den alten Tag **schreibt**, und nähme die freigestellten Dateien datei-weit aus jeder künftigen Prüfung desselben Moduls |
| D — `versions` adoptieren, ohne Zeitdokument-Ausnahme | keine Ausnahmeliste zu pflegen | **gemessen:** **284 Befunde über 119 Dateien**, davon **226** in Zeitdokumenten (Beträge wandern, [`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2) — also der Auftrag, genau die Sätze nachzuziehen, die [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 4 stehen lässt (*„Kein Satz ändert sich"*). Ein Gate, dessen Befunde man nicht beheben darf, erzieht dazu, Rot zu übersehen |
| **E — gewählt: neu halten statt fortschreiben · das Modul mit Kriterium verwerfen · die stille Hälfte benennen** | trennt die zwei Fragen, die alle anderen Optionen vermischen — *gilt die Begründung noch?* und *gibt es jetzt einen Wächter?*; die Verwerfung steht auf einer 2 × 2-Messung statt auf einer Werkzeug-Beschreibung; sie hinterlässt ein **Kriterium**, das den nächsten Kandidaten bindet; sie ändert an zwei angenommenen ADRs kein Byte | die stille Hälfte bleibt unbewacht, und diese ADR baut keinen Sensor; sie kostet einen zweiten Lauf gegen die Ziel-Fassung bei **jedem** künftigen Bump; und sie fügt dem ADR-Bestand ein Artefakt hinzu, das eine bestehende Entscheidung bestätigt statt eine neue zu treffen — der Preis dafür, dass §3.4 die Bestätigung nicht in die alte Datei lässt |
| F — den in [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) benannten Form-Sensor jetzt bauen | er misst die richtige Eigenschaft und hat dort sein rot gesehenes Gegenbeispiel | er beantwortet eine **andere** Frage: *nennt ein unveränderlich gewordenes Artefakt einen tag-gepinnten lokalen Pfad?* Er ist der Träger von Festlegung 2, kein Wächter über den Bestand, den Festlegung 1 freistellt — jene ADR sagt das selbst (*„Was er nicht fängt: die 6 Nennungen in Accepted-ADRs"*). Ihn hier zu bauen machte aus einer Entscheidung eine Umsetzung und ließe die Wächter-Frage der stillen Hälfte weiter offen |

## Konsequenzen

- **Positiv:** Zwei Accepted-ADRs bleiben byte-gleich. Kein Supersede, keine Kaskade über
  `matrix.status`, und kein eingehender Verweis wird unzulässig
  (`git grep -oE '\[[^]]*ADR-0016[^]]*\]\([^)]*0016[^)]*\)' -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' | wc -l`
  → 48; mit `-lE` statt `-oE` → 10 lebende Dateien. Dasselbe Paar für die
  andere ADR → 32 und 6. Alle vier Zahlen wachsen mit jedem neuen Verweis).
- **Positiv:** Die Begründung ist **vor** dem Tausch gegen den Stand gehalten, der wirklich
  adoptiert wird, und nicht gegen den, gegen den sie geschrieben wurde.
- **Positiv:** Die Wächter-Frage hat ein **Kriterium** statt eines Einzelurteils. Der nächste
  Sensor-Vorschlag wird an drei Ist-Belegen geprüft, nicht an einer Werkzeug-Beschreibung.
- **Negativ:** **Die stille Hälfte bleibt stumm.** 36 Inline-Nennungen, davon 6 in
  Accepted-ADRs, sehen nach dem Tausch auf einen Baum, den es nicht gibt, und **kein Gate meldet
  das** — heute nicht und nach dieser Entscheidung nicht. Wer die Nennung liest, ohne den
  Tag-String zu lesen, hält sie für aktuell.
- **Negativ:** Ein auffindbarer Bestand ohne Wächter ist schwerer zu ertragen als ein
  unauffindbarer. Das Modul **zeigt** die 58 Stellen; diese Entscheidung sagt, dass Zeigen nicht
  Bewachen ist, und lässt sie liegen.
- **Negativ:** Jeder künftige Bump kostet diesen Lauf erneut — die tragenden Zitate sind gegen
  den jeweiligen Zielstand zu halten, weil ein Delta über neun Releases (`git tag --sort=v:refname | awk '/^v5\.3\.1$/{f=1;next} f{print} /^v5\.12\.0$/{exit}' | wc -l` → 9, lokaler Kurs-Klon) keine Fortschreibung
  erlaubt.
- **Negativ:** Der ADR-Bestand wächst um ein Artefakt, das eine bestehende Entscheidung
  bestätigt. Das ist der Preis von §3.4 und kein Nebeneffekt: die Bestätigung darf nicht in die
  bestätigte Datei.
- **Folgepflicht 1 (der Slice, der den Baum tauscht):** die gate-sichtbaren Links in den
  lebenden Artefakten auf den neuen Tag **und die neuen Dateinamen** ziehen — die
  Konventionen-Grundlagendatei der gepinnten Fassung existiert am Zielstand nicht mehr und ist
  in sechs Dateien zerlegt (`git ls-tree --name-only v5.12.0 -- lab/regelwerk/grundlagen-konventionen.md` → leer), ein reiner Tag-Tausch
  reicht dort nicht, und **jeder Anker wird einzeln geprüft statt per `sed` über den
  Tag-String**. Die lebenden Inline-Nennungen ebenso, **außer** denen der Klasse 3: ein
  Tree-Operand der Vor-Tausch-Seite bleibt stehen. Die Doku-Gate-Ausnahme aus
  [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) ist dabei zu vollziehen; sie
  steht heute noch nicht in der Konfiguration
  (`grep -c '0013-technik-stratum' .d-check.yml` → 0). **Diese ADR ändert keine Datei außer
  sich und dem Index.**
- **Folgepflicht 2 (offen, eigener Slice):** die zwei in
  [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) benannten, ungebauten Sensoren. Sie sind hier
  **nicht** gebaut, und diese ADR fügt keinen dritten hinzu.
- **Folgepflicht 3 (an die planende Rolle):** die drei Klassen aus §Kontext sind eine
  **Sortier-Aufgabe** für den Tausch-Lauf, keine Ableitung aus einer Zahl. Wer die Nennungen
  zieht, entscheidet je Treffer und begründet die Klasse — die Menge wandert, eine Liste hier
  altert zwischen Entscheidung und Ausführung.

## Fitness Function (falls maschinell prüfbar)

**Gebaut:**

| Tooling | Regel | Make-Target |
|---|---|---|
| d-check `links` + `anchors` | Ein Markdown-Link in den vendored Baum löst auf, Ziel **und** Anker — der Formcheck, den die Ziel-Fassung dem Doku-Gate zuweist. Er bewacht die **Link-Form** und nur sie; die Inline-Zeiger derselben Klasse fallen aus seinem Prüfbereich | `make docs-check` |
| `baseline-verify` | Es existiert genau **ein** `<tag>`-Verzeichnis, integer und vollständig — die Mechanik hinter [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache), auf der Festlegung 1 fußt | `make baseline-verify` |

**Ausdrücklich nicht: `versions`.** Der Grund steht in Festlegung 3 und ist gemessen, nicht
abgeleitet. Es wird auch **nicht als Kandidat geführt**
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) — ein
Modul, das die falsche Eigenschaft misst, ist kein Wächter im Wartestand.

**Nicht gebaut und hier nicht beauftragt:** die zwei Sensoren aus
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) §Fitness Function. Der eine trägt Festlegung 2
am Accept-Übergang, der andere prüft den Pin in lebenden Artefakten; keiner von beiden fängt die
6 stillen Nennungen in den Accepted-ADRs, weil Festlegung 1 ihm dort nichts zu tun gibt.

**Diese Deckungs-Aussage hat eine zweite Richtung, und sie trifft diese ADR.** Der Form-Sensor
trägt dort die Eigenschaft *„kein unveränderlich gewordenes Artefakt nennt einen **tag-gepinnten**
lokalen Baseline-Pfad"*, mit einem Prüfbereich, der alle Artefakte umfasst außer den vier von
Festlegung 1 freigestellten Accepted-ADRs und der in
[ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) ausgenommenen Datei. In genau
diesem Prüfbereich liegen heute drei ADRs mit solchen Zeichenketten:
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md), jene
[ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) und diese ADR
(`grep -cE '\.harness/baseline/v[0-9]' docs/plan/adr/001[67]-*.md docs/plan/adr/0023-*.md`
→ `0016` **5**, `0017` **1**, `0023` **6**; die Zahl über diese Datei wandert, bis ihr Status sie
einfriert,
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). **Alle diese Nennungen sind Operanden** — Tag-Strings in `git grep`-Kommandos und der
Verzeichnisname als Gegenstand einer Umbenennungs-Sonde —, also Klasse 3. Der Sensor, wie er dort
beschrieben ist, färbte sie rot, ohne dass eine dieser Zeilen falsch wäre. **Er fällt damit unter
Festlegung 4:** wer ihn baut, zeigt zuerst, wie er die Adresse vom Operanden trennt — sonst ist er
der Auftrag, wahre Sätze falsch zu machen, den Festlegung 4 ausschließt. Gegen
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) ist das kein Befund: dort war die Klasse noch
nicht benannt.

**Vorhanden, nicht verdrahtet, und diese ADR verdrahtet es nicht:** das Werkzeug führt ein
git-basiertes Modul, das die Immutabilität einer Datei-Klasse ab einer Status-Zeile prüft; im
Repo liegt es als eigenes `doc-`Ziel und steht **nicht** in der Modul-Liste des Gate-Laufs. Es
ist der Sensor, der eine verbotene Reparatur an einem Accepted-ADR fangen würde — die Frage
seiner Verdrahtung ist eine andere Entscheidung als diese und wird hier weder getroffen noch
vorbereitet.

**Nicht mechanisierbar aus der Zeichenkette:** zu welcher der drei Klassen eine Nennung gehört.
Das entscheidet der Satz um sie herum. Die **Link-Form** ist die einzige mechanisch fassbare
Teilmenge — sie gehört zu Klasse 1, und genau sie misst `links`; der Rest von Klasse 1 ist von
den anderen beiden nicht zu unterscheiden. **Trennbar würden die Klassen erst, wenn die Nennung
ihre Klasse selbst trüge** — ein Marker je Fundstelle, den ein Sensor liest. Für künftige
Artefakte ist dieser Weg offen; für den Bestand, den Festlegung 1 freistellt, ist er zu, denn
einen Marker nachzutragen wäre eine Textänderung an einem von
[`AGENTS.md`](../../../AGENTS.md) §3.4 eingefrorenen Artefakt. **Das ist die Reichweite von
Festlegung 4:** ihr Kriterium ist auf dem freigestellten Bestand nicht erfüllbar und auf allem
anderen schon.

## Re-Evaluierungs-Trigger

- **Wenn die Ziel-Fassung erneut bewegt wird** *(feedforward — eine Entscheidung über den
  Zielstand, kein Sensor; wer sie trifft und wie sie adressiert wird, regelt
  [ADR-0018](0018-ziel-fassung-regiert-die-migration.md), seit dem 2026-08-28 **Accepted**: die
  Bewegung ist eine Setzung des Auftraggebers, die repo-interne Regel darüber bindet die Rollen
  dieses Repos, und ab dem Umschlag trägt jede weitere Bewegung eine Folge-ADR mit
  `Supersedes`)*:
  dann ist die Messung „vier von fünf tragenden Quellen geändert / vier Zitate überleben" gegen
  den neuen Tag neu zu fahren, und der Delta der bewegten Quellen ist wieder zu **lesen**. Sie
  ist tag-gebunden und kein Erwartungswert.
- **Wenn eine künftige Baseline eine Verweis-Form für vendored Bäume vorschreibt**
  *(feedforward — eine Textänderung upstream, kein Sensor; der Zielstand tut es nicht, gemessen
  im Kontext)*: dann bindet sie unabhängig von ihrer Rezeption hier, und Festlegung 2 ist gegen
  den neuen Wortlaut neu zu begründen oder als Abweichung zu deklarieren.
- **Wenn das Doku-Gate-Werkzeug ein Modul bekommt, das Verweis-Auflösung über einem
  `<tag>`-gescopten Bestand misst** *(feedforward — ein Werkzeug-Release, kein Sensor im Repo)*:
  dann fällt der **erste** der drei Gründe von Festlegung 3 — er ist der einzige, der ganz eine
  Eigenschaft des heutigen Werkzeugs ist. Vom **dritten** fällt die Werkzeug-Hälfte, sobald der
  zeilengenaue Ausweg in der Konfiguration statt im Text steht; seine andere Hälfte ist
  [`AGENTS.md`](../../../AGENTS.md) §3.4 und fällt durch kein Release. Der **zweite** fällt gar
  nicht durch ein Werkzeug: mechanisch trennbar würden die Klassen erst, wenn die Nennung ihre
  Klasse selbst trüge (§Fitness Function), und im freigestellten Bestand ist dieser Weg zu.
  **Festlegung 3 ist deshalb erst dann neu zu stellen, wenn alle drei gefallen sind**; ein
  Kandidat, der nur den ersten erledigt, ändert an ihr nichts. Maßstab bleibt Festlegung 4.
- **Wenn ein zweites von §3.4 eingefrorenes Artefakt gate-sichtbar wird** *(sichtbar im
  Tausch-Trockenlauf, bevor der Tausch fällt)*: dann trägt die extensionale Grenze aus
  [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) nicht mehr, und die
  Erweiterung ist eine neue Senkung mit eigenem Gefäß.
- **Wenn ein Leser eine Inline-Nennung als aktuell missversteht** *(Beobachtung, kein Gate)*:
  das ist der eingestandene Preis von Festlegung 3. Tritt er ein, ist die Kosten-Rechnung falsch
  gewesen, und die stille Hälfte braucht doch eine Behandlung — nach Festlegung 4 aber eine, die
  die drei Klassen trennt, und keine, die alle drei gleich behandelt.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-28 | **Proposed** | Architect-Verdikt zur Tag-Wechsel-Frage vor dem Tausch des vendored Baums. Anlass war eine Messung, die eine planende Rolle nachgetragen hatte: das Modul `versions` meldet die stille Hälfte. Nachgemessen ergab sie **sechs** getroffene Accepted-ADRs — zwei mehr, als eine Suche mit Folgepfad findet, weil das `pin-pattern` des Moduls den Tag auch ohne ihn fängt — und die 2 × 2-Sonde zeigte, dass das Modul Zeichenketten-Frische misst, nicht Verweis-Auflösung |
| 2026-08-28 | Überarbeitet, weiter **Proposed** | Vor der Annahme geschärft, an sechs Stellen: der Bezug auf [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) nennt deren `Proposed`-Status, statt sie als geltend zu führen — dieselbe Unterscheidung, die die Supersede-Sonde in Zeile B der Alternativen trifft. Alle Bestands-Zahlen tragen ihre **Mess-Basis** (ein benannter Commit) und die Kennzeichnung als Nicht-Erwartungswerte ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2). Der Delta der vier bewegten tragenden Quellen ist **vollständig gelesen** statt über ein Muster erschlossen — 4 Dateien, +90/−11 —, und er enthält zwei Verweis-Form-Regeln für das Adaptions-Register, von denen die eine dem Muster entgeht; die Grenze des Suchraums steht damit an einem Fall statt abstrakt. Der Re-Evaluierungs-Trigger zum Werkzeug ist auf das eingeschränkt, was ein Release bewegt: einen der drei Gründe von Festlegung 3 und eine Hälfte des dritten. Die Fitness Function nennt die **zweite** Richtung der Sensor-Deckung — der ungebaute Form-Sensor aus [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) färbte nach seiner dortigen Eigenschaft drei ADRs rot, und er fällt damit unter Festlegung 4. Und die Delta-Messung nennt beide Tags, gegen die sie gehalten werden kann, mit dem Betrag für jeden |
| 2026-08-28 | **Accepted** | **Entscheidung des Auftraggebers vom 2026-08-28, vollzogen in der Architect-Rolle** — im selben Commit wie die Annahme von [ADR-0018](0018-ziel-fassung-regiert-die-migration.md). Dass **keine** Quelle dieses Repos und keine der vendored Baseline einen annehmenden Akteur benennt, ist dort gemessen und wird hier nicht gedoppelt. **Der `Proposed`-Vorbehalt aus der Zeile darüber ist damit gegenstandslos und an vier Stellen gezogen:** Bezug, Bezugspunkt in §Kontext, Zeile B der Alternativen und erster Re-Evaluierungs-Trigger. Zeile B trägt die Folge als Zahl: die Supersede-Sonde über `363421c` misst den Verweis-Bestand und ist unberührt, aber ihre **12 über sechs** unreparierbaren Befunde sind mit der Annahme von [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) **15 über sieben** — die Verwerfung von Option B wird dadurch teurer zu widerrufen, nicht billiger. Was jetzt fällig wird, steht in §Konsequenzen als Folgepflichten 1 bis 3 und gehört den planenden und umsetzenden Rollen; diese ADR ändert dabei keine Datei außer sich und dem Index |
