# ADR-0052: Ein host-lokaler Pfad bleibt im eingefrorenen Artefakt stehen — der lebende Bestand trägt keinen

**Status:** Proposed

**Datum:** 2026-09-15

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) (**Accepted** — Festlegung 2 bindet den
Kern dieser Entscheidung: *„Eine `Accepted`-ADR ist ausgenommen — kein Byte, auch nicht an der
Adresse"*; Festlegung 4 trennt die mechanisch trennbare Gegenform von den Urteils-Fällen),
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md) (**Accepted**, **unberührt** — keine ihrer
Festlegungen wird geändert, keiner ihrer Re-Evaluierungs-Trigger ist gefeuert, kein `Supersedes`; die
zwei Stellen, um die es geht, liegen in §Was heute gemessen ist und §Verglichene Alternativen und
tragen keine Festlegung),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (**Accepted** — Festlegung 1
*„§3.4 bindet das Artefakt, nicht nur seine Aussage"*, hier über
[ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 2 zitiert und von einer
Datei auf die Klasse geweitet),
[ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) (**Accepted** — die Form, in der
dieses Repo **genau eine** Datei aus einem Gate nimmt, und ihre Aufnahme-Grenze: jeder weitere
Eintrag ist eine neue Senkung),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (Festlegung 2 — Eigenschaft statt Adresse: jede
Baseline-Stelle unten trägt Tag und Zitat und keinen Pfad-Link),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert),
[`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(jede Baseline-Aussage nennt den Tag, gegen den sie gemessen ist),
[`MR-053`](../../../harness/conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)
(die Werkzeug-Aussage trägt ihren Stand, nicht den lebenden Pin),
[`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
(die Form der Kennung, die der Kandidat unten trägt),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine Klasse,
deren Wächter existiert und nicht läuft, ist eine Zusage ohne Deckung),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (jeder Befund unten wird
netzlos und digest-gepinnt gezogen)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie entscheidet über die Adress-Form in eingefrorenen
Artefakten und über den Träger einer Wächter-Klasse; keine Spec-Aussage wird geändert.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR). Die zwei
Baseline-Aussagen unten messen gegen die regierende Fassung `v6.8.0`
([`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)).
Den lebenden d-check-Pin führt [`d-check.mk`](../../../d-check.mk); er steht hier nicht als zweite
Fassung.

---

## Kontext

### Der Gegenstand, sein Wächter — und daß der Wächter hier nicht läuft

Die Anweisung des Auftraggebers lautet: **keine Pfade, die aus dem Repo zeigen, in die Dokumente.**
Der Wächter dieser Klasse **existiert** und ist in diesem Repo **nicht adoptiert**: das
d-check-Modul `hostpaths` (Anforderung `DC-FA-HOST-001` des Werkzeugs, an dem Stand, den
[`MR-052`](../../../harness/conventions.md#mr-052--d-check-pin-v0741-zwei-module-verfügbar-vierte-ausgabe-spalte)
als Pin führt). Es meldet host-lokale absolute Pfade in Prosa **einschließlich Inline-Code**; Fences
sind ausgenommen, und das Modul trägt **keinen** Opt-out-Marker und **kein** `exempt-paths` — seine
einzigen Ventile sind die Fences, `hostpaths.prefixes` und der generische Schlüssel
`hostpaths.scope`. Der Grund-Code ist `hostpath-forbidden`.

Gemessen wird er über den Baum, netzlos und digest-gepinnt:

```sh
docker run --rm --network none -v "$PWD:/repo:ro" \
  ghcr.io/pt9912/d-check@sha256:e31a372b66dbde26305982424854cfce7c9ab7ce555a94debeee7ee26e6d4641 --enable hostpaths
```

**Die Klasse zerfällt in zwei Hälften, und nur eine davon ist ein lebendes Artefakt.** Über dem Stand
`873f470e` meldet der Lauf **95** Befunde in fünf Bäumen:

```sh
git archive 873f470e | tar -x -C "$T"        # $T = Wegwerf-Baum außerhalb des Repos
docker run --rm --network none -v "$T:/repo:ro" <digest> --enable hostpaths 2>&1 |
  grep 'hostpath-forbidden' | cut -f1 | sed 's/:[0-9]*$//' |
  sed -E 's#^(docs/reviews)/.*#\1#; s#^(docs/plan/planning/done)/.*#\1#;
          s#^(docs/plan/carveouts/done)/.*#\1#; s#^(docs/plan/adr)/.*#\1#;
          s#^(harness/conventions)/.*#\1#' | sort | uniq -c
#   47 docs/reviews · 42 docs/plan/planning/done · 3 harness/conventions
#    2 docs/plan/adr     ·  1 docs/plan/carveouts/done
```

**Drei** dieser fünfundneunzig liegen in **einem lebenden, repo-eigenen** Artefakt — dem
Adaptions-Block, und der gehört nach [`AGENTS.md`](../../../AGENTS.md) §3.8 dem **Architect**;
**zwei** liegen in einer `Accepted`-ADR. Die **neunzig** übrigen liegen in **drei**
Zeitdokument-Bäumen — `docs/reviews/` 47, `docs/plan/planning/done/` 42 und
`docs/plan/carveouts/done/` 1 —, also in Chronik abgeschlossener Vorgänge: erklärt und nicht
gelöscht. **Keine Erwartungswerte**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — beide Zahlen wandern mit dem Baum.

### Was in zwei Bäumen daneben steht, und warum es die Rechnung ändert

Zwischen den zwei Messungen dieses Abschnitts hat ein Lauf die Zeitdokumente gezogen: über `d4bf9b29`
meldet derselbe Aufruf **8** Befunde — **3** im Adaptions-Block, **2** in der `Accepted`-ADR und
**3** in Review-Reports. Von diesen drei ist **keiner** ein host-lokaler Pfad im Sinne der Anweisung:
zwei sind ein **Fund der Windows-Laufwerk-Regel des Moduls über keinen Pfad** — ein
Laufwerksbuchstabe mit folgendem Backslash in einem escapten Ersatztext —, und einer ein Home-Pfad.
**Die Anweisung ist damit an den Zeitdokumenten vollzogen. Über dem Arbeitsbaum nach dem
Architect-Zug bleiben fünf: zwei in der `Accepted`-ADR — der Gegenstand dieser Entscheidung — und
drei in Review-Reports, von denen keiner ein Host-Pfad der Anweisung ist.**

### Warum eine Folge-ADR die zwei Stellen nicht erreicht

[`AGENTS.md`](../../../AGENTS.md) §3.4 schreibt den Weg vor und begrenzt ihn im selben Satz:
*„Korrekturen entstehen als neue ADR mit Supersedes, **nicht durch Überschreiben**."* Die Korrektur
wohnt damit im **neuen** Artefakt; der Rumpf der alten ADR behält seine Bytes. Eine Folge-ADR auf
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md) ändert ihre **Status-Zeile** — den
Übergang, den der `vcs`-Block in `.d-check.yml` über `head-allow` ausdrücklich zulässt — und setzt
eine zweite Aussage daneben. Die zwei Operanden bleiben, wo sie stehen. **Ein `Supersedes` ist keine
Adress-Ersetzung**, und keine Form der Folge-ADR macht eine daraus.

### Annahmen, auf denen diese Entscheidung steht

- **(a) §3.4 bindet das Artefakt, nicht nur seine Aussage.** Wortlaut wie oben; ausgelegt und
  angewandt von [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 1 und
  [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 2. Kippt die Auslegung,
  kippt Festlegung 1 unten — dann ist der Weg die Adress-Ersetzung, nicht die Folge-ADR.
- **(b) Die Anweisung des Auftraggebers meint die Klasse, die das Modul misst — nicht die Fences.**
  Die Anweisung nennt keinen Vorbehalt; das **Modul** nimmt Fences aus und begründet das selbst
  (*Beispiel- und Lehrinhalte mit bewussten Host-Pfaden gehören in Fences*). Wo beides auseinander
  fällt, gilt die Anweisung, und der Lauf, der schreibt, wählt eine Form ohne Pfad-Literal, statt
  den Pfad durch die Fence-Ausnahme zu rechtfertigen.
- **(c) Der Auftraggeber bewegt den Zielstand der Klasse, nicht diese Datei.** Ob die Anweisung
  überhaupt eine Wächter-Pflicht erzeugt, entscheidet nicht der Architect; ihn bindet die
  Anweisung als Quelle.

## Entscheidung

**Wir wählen Alternative C: die zwei Operanden bleiben stehen, der lebende Bestand trägt keinen, und
der Wächter der Klasse wird als Kandidat benannt statt hier adoptiert.** Zwei Festlegungen.

**1. Ein host-lokaler Pfad in einem eingefrorenen Artefakt bleibt stehen. Gebunden sind die zwei
Kommando-Operanden in [ADR-0033](0033-wellen-archivierung-als-unterkommando.md) und jede künftige
Fundstelle derselben Klasse in einem Artefakt, dessen Bytes §3.4 bindet.**

Der tragende Satz ist §3.4 selbst, über die zwei zitierten Auslegungen (Annahme (a)). Er hat für
diese Klasse keine Ausnahme: Der Pfad ist **Gegenstand eines Mess-Kommandos**, und das Kommando
beantwortet nach einer Ersetzung eine andere Frage — dieselbe Fehlerrichtung, die
[ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 4 für den Operanden im
Mess-Kommando benennt. Ein `Supersedes` hilft nicht (s. §Kontext): Es läge in der neuen Datei, nicht
an diesen zwei Stellen. **Der Gegenstand dieser Festlegung ist damit eine benannte Grenze, keine
geschlossene Regel** — und das ist die Antwort, die §3.4 zulässt.

**Die zwei Stellen sind nicht austauschbar gegen eine Form ohne Pfad-Literal**, und der Preis dieser
Festlegung ist damit beziffert: es bleibt bei zwei Host-Pfaden in einem einfrierenden Artefakt. Die
Alternative — die Datei doch schreiben — ist Alternative D unten.

**2. Der lebende Bestand trägt keinen host-lokalen Pfad; sein Wächter ist das Modul `hostpaths`, und
seine Adoption ist hier nicht entschieden.** Festgestellt ist die **Pflicht**, nicht ihr Träger: Die
Klasse hat heute **kein** Gate, denn kein Modul von
`grep -n '^modules:' .d-check.yml` vergleicht eine Prosa-Zeile mit einer Host-Lokalität
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

**Der Kandidat trägt eine Kennung: `hostpfade-bekommen-ihren-waechter`**
([`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)).
Der Schnitt selbst — ein Slice, seine Priorisierung, seine Zeile in der Vorschau — ist **Planner-Arbeit**
(Baseline-Regelwerk `v6.8.0`, `modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle und
[ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) Festlegung 2); dieser Lauf liefert
ihr die Messung und die Kennung, nicht den Plan.

**Was der Kandidat als Arbeit enthält, ist gemessen statt geschätzt:**

- **Die Aktivierung** — der Modulname in `modules:` — ist ein **Anheben** und kein ADR
  ([`MR-001`](../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)),
  mit Trockenlauf und rotem Gegenbeispiel wie jeder Modul-Zuwachs.
- **Die Ausnahme** ist eine **Senkung** und damit ADR-pflichtig
  ([`AGENTS.md`](../../../AGENTS.md) §3.5). Ihr einziger Hebel ist `hostpaths.scope.ignore` — das
  Modul trägt weder `exempt-paths` noch einen Marker —, und sie muß nach den zwei Messungen oben
  **fast nichts** decken: die zwei Operanden aus Festlegung 1, die drei Review-Fundstellen, die
  **keine** Host-Pfade der Anweisung sind, und die `Proposed`-ADRs, die **lebend** sind und darum
  aus einer baum-weiten ADR-Ausnahme nicht mit ausgenommen werden dürften. Eine datei-**genaue**
  Aufnahme nach [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) ist damit die Form
  — jede weitere bleibt eine neue Senkung.
- **Die zwei Windows-Fundstellen sind kein Gegenstand der Ausnahme, sondern des Werkzeugs.** Ein
  Fund über einen escapten Text ist kein Pfad; er gehört als Befund an das d-check-Lastenheft und
  nicht in eine Ausnahme dieses Repos.

## Verglichene Alternativen

Regeln dieser Sektion: **mindestens drei Optionen mit Pro/Contra** — „nichts tun" ist eine davon.
Eine ADR ohne Alternativen ist ein Postulat, kein Entscheidungsprotokoll (Baseline-Regelwerk
`v6.8.0`, `modul-04-adrs.md` §Ziel-Form: ADR (MADR)).

| Option | Pro | Contra |
|---|---|---|
| A — Folge-ADR mit `Supersedes` auf [ADR-0033](0033-wellen-archivierung-als-unterkommando.md) | der Weg, den §3.4 für eine Korrektur vorschreibt, und er läßt die alte Datei unangetastet | **er erreicht die zwei Stellen nicht:** §3.4 legt die Korrektur in das neue Artefakt; der alte Rumpf behält seine Bytes, und ein `Supersedes` ändert die Status-Zeile, nicht den Operanden (§Kontext). Er kostet eine ADR und zwei Acceptance-Trigger und zahlt die Klasse nicht aus |
| B — nichts tun und nichts aufschreiben | kein Artefakt, kein Trigger, keine Senkung | die Klasse lebt als Satz in einem Lauf-Bericht; der nächste Durchgang entscheidet sie neu, und die zwei Stellen stehen dann als unentschiedener Befund. Dieselbe Klasse, die dieses Repo an `BEO-ALL/verweis-nachzug-bricht-tree-operand` als *benannt, nicht gezählt* führt |
| **C — Festlegung 1 benennen, den Träger als Kandidat mit Kennung (gewählt)** | die Grenze steht an einem auflösbaren Ort statt in einem Bericht; der Wächter-Bedarf bekommt eine Kennung und eine Rolle; die Kosten der Ausnahme sind gemessen, nicht geschätzt; keine `Accepted`-ADR wird angefaßt | die zwei Stellen bleiben; die Pflicht-Hälfte der Klasse ist damit **feedforward** — benannt, nicht durchgesetzt, bis der Kandidat gearbeitet ist |
| D — die zwei Operanden direkt ersetzen | der Baum wird in beiden Hälften frei von der Klasse | §3.4 verbietet es wörtlich; der Baum führt mit `make adr-immutable` einen Wächter für genau diesen Übergang (§Fitness Function), und ein Befund, den niemand beheben darf, erzieht dazu, Rot zu überlesen ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine Ebene tiefer) |

## Konsequenzen

- **Positiv:** Die Klasse hat eine Adresse statt eines Berichts. Der **lebende** Bestand trägt keinen
  host-lokalen Pfad mehr — die drei Stellen im Adaptions-Block sind gezogen —, und der Kandidat nennt
  den Träger samt dem, was seine Ausnahme decken müßte und was sie kostet.
- **Positiv:** Keine `Accepted`-ADR wird angefaßt. [ADR-0033](0033-wellen-archivierung-als-unterkommando.md)
  bindet unverändert fort, ohne `Supersedes` und ohne einen zweiten Acceptance-Trigger.
- **Negativ, und das ist der Preis:** Zwei Host-Pfade bleiben in einem einfrierenden Artefakt stehen.
  Sie sind ab dem Accept dieser Datei **nicht mehr heilbar** — jede spätere Runde erbt sie
  ([ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 2).
- **Negativ:** Die Pflicht-Hälfte ist bis zur Arbeit des Kandidaten **ungedeckt**. Diese Entscheidung
  behauptet **kein** Gate für die Klasse — das Modul, das eines wäre, ist nicht adoptiert
  ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Übergabe an den Planner:** der Kandidat `hostpfade-bekommen-ihren-waechter` — Schnitt,
  Priorisierung, Vorschau-Zeile. Die Messungen in §Kontext sind seine Eingabe; die Vorschau nennt das
  Modul bereits unter der Wellen-Kennung `Doc-Gate-Härtung`, und diese Entscheidung ersetzt diesen
  Hinweis nicht durch eine zweite Zeile.
- **Übergabe an einen Reviewer:** Ein Durchgang `d4bf9b29` hat acht ADR-Dateien im Kern geschrieben
  (Platzhalter in Fences) — und `make adr-immutable RANGE=d4bf9b29^..d4bf9b29` meldet darüber
  **0 Befunde**, Exit 0. **Was daraus folgt, entscheidet diese Datei nicht.** Eine Nachprüfung im
  Wegwerf-Klon konnte den im Sensordokument belegten Positiv-Fall (ein reiner `git mv` einer
  `Accepted`-ADR) **nicht** reproduzieren — auch er meldete 0. Damit ist **weder** die Zahnheit
  **noch** die Blindheit des Sensors gemessen; §3.6 verlangt für beides ein rot gesehenes
  Gegenbeispiel, und das steht aus.

## Fitness Function (falls maschinell prüfbar)

**Diese Entscheidung behauptet den Wächter der Klasse nicht — sie benennt ihn als Kandidaten.** Was
heute läuft, deckt die zwei Festlegungen nicht:

| Tooling | Regel | Make-Target |
|---|---|---|
| **kein Gate** — das Modul `hostpaths` ist nicht in `modules:` | die Regel *„der lebende Bestand trägt keinen host-lokalen Pfad"* liegt im Feedforward-Quadranten; ihr Träger ist der Lauf, der schreibt, nicht ein Sensor danach | — |
| `vcs` (`make adr-immutable RANGE=<base>..<head>`) | hält den Kern einer über die Range `Accepted` gebliebenen ADR — die Zusage, auf der Festlegung 1 ruht. Das Modul ist hier **gemessen** und gibt über dem Stand `d4bf9b29` **0 Befunde** bei Exit 0, obwohl jener Commit acht ADR-Dateien schreibt | `make adr-immutable` (kein Gate — die Range variiert pro Aufruf) |

## Re-Evaluierungs-Trigger

1. **Der Kandidat `hostpfade-bekommen-ihren-waechter` ist gearbeitet** — dann steht der Wächter der
   Klasse, und Festlegung 2 bekommt ihren Sensor statt ihres Kandidaten. Feuert er, ist die
   Entfernung des Kandidaten-Hinweises aus dieser Datei kein Nachtrag
   (eine `Accepted`-ADR wird nicht geschrieben), sondern ein Feld in der verkörpernden Regel.
2. **Ein eingefrorenes Artefakt muß ohnehin geschrieben werden** — dann ist die Adress-Frage für
   genau dieses Artefakt neu zu stellen, und Festlegung 1 ist an ihr zu messen.
3. **Der Auftraggeber bewegt den Gegenstand** — eine andere Anweisung, ein anderer Zielstand, oder
   eine ausdrückliche Erlaubnis, eingefrorene Artefakte zu schreiben. Dann ist Festlegung 1
   gegenstandslos und diese Datei zu supersedieren.
4. **`make adr-immutable` legt seine Zähne vor** — ein rot gesehenes Gegenbeispiel über einer
   Kern-Änderung einer `Accepted`-ADR. Bis dahin trägt Festlegung 1 allein die Hard Rule und keinen
   Sensor.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-15 | **Proposed** | Architect-Lauf zum Auftrag der Klasse „keine Pfade, die aus dem Repo zeigen, in die Dokumente". Die Messungen in §Kontext stehen neben ihren Kommandos; der Weg der Folge-ADR ist an §3.4 gemessen und nicht gewählt. Der Reviewer-Konsistenz-Durchgang steht aus ([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)) |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0052` (Baseline-Regelwerk `v6.8.0`, `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
