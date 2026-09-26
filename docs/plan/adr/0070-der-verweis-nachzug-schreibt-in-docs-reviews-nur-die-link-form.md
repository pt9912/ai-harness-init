# ADR-0070: Der Verweis-Nachzug schreibt in `docs/reviews/**` nur die Adresse in Link-Form — ein Pfad im Code-Span ist dort Chronik, die das Doku-Gate ausdrücklich nicht prüft

**Status:** Proposed

**Datum:** 2026-09-26

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) (**Accepted** — Festlegung 1 ist der
Gegenstand, den diese Entscheidung an **einer** Stelle schneidet; Festlegung 2 bis 5 bleiben),
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md) (**Accepted** — der zweite Träger des
Nachzugs; sein Abnahme-Kriterium 1 ist hier gelesen, nicht geändert),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (**Accepted** — Festlegung 3
bindet den Schreiber, Festlegung 4 den Beweger; beide unberührt),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (**Accepted** — der Beleg des
Accept-Übergangs),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (das Gate
sagt nur über seinen Prüfbereich etwas; der Prüfbereich wird hier nicht verkleinert),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert; keine ist ein Erwartungswert)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie ändert die Reichweite eines Werkzeugs, keine
Spec-Aussage und keine Gate-Schwelle.

**Supersedes (Teil):** [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md)
§Entscheidung Festlegung 1, und dort **genau einen Wert** — die Reichweite *„ersetzt die
Pfad-Adresse"* für den Baum `docs/reviews/`: Sie gilt dort künftig für die Link-Form, nicht mehr
für jede Form. Alles andere jener Festlegung bindet unverändert fort — das Kriterium (*ändert sich
die Aussage?*), die drei übrigen Bäume, die Aussage *„beide Träger behalten ihre heutige
Ausnahmeliste; keiner bekommt einen weiteren ausgenommenen Baum"* — und die Festlegungen 2 bis 5
bleiben vollständig unberührt. Das ist **kein** ausgenommener Baum, sondern eine Form-Regel.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR); Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Regeln
(ADR-Änderung: Architect schreibt; Accepted-ADRs überschreibt niemand — Folge-ADR).

---

## Kontext

### Der Anlass: der Nachzug hat in einem Report eine Tatsache umgeschrieben

Ein Verifikations-Report nennt in einer Mess-Zeile die Ausgabe eines Kommandos: es *„nennt … einen
fremden Slice"* unter dem Pfad, unter dem der Slice **zu diesem Zeitpunkt** lag. Der Nachzug eines
späteren Lifecycle-Moves ersetzte den Pfad; der Report behauptete danach einen Ort, an dem die
Datei nie lag. Wiederhergestellt hat es ein Planner-Commit von Hand
(`git show --stat bd76d800`), begründet mit [`AGENTS.md`](../../../AGENTS.md) §3.11 und dem
Abnahme-Kriterium 1 aus [ADR-0033](0033-wellen-archivierung-als-unterkommando.md). **Der Ausgang
war richtig, die Begründung trägt nicht:**

- [`AGENTS.md`](../../../AGENTS.md) §3.11 bindet den **Schreiber** und den Lauf, der einen Move
  **plant**; ein Verbot für den Nachzug steht dort nicht.
- Abnahme-Kriterium 1 von [ADR-0033](0033-wellen-archivierung-als-unterkommando.md) lautet
  verbatim: *„Der fail-closed-Wächter gegen einen lebenden Verweis auf einen zu löschenden
  Review-Report schließt `docs/reviews/**` nicht aus."* Es spricht über den **Suchraum des
  Hänger-Wächters**, nicht über den Nachzug
  (`grep -c 'Der fail-closed-Wächter gegen einen lebenden Verweis' docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md`
  → **1**). Ein Wächter, der auf `docs/reviews/**` **liest**, und ein Nachzug, der dort **schreibt**,
  sind zwei Zweige desselben Trägers; die Zeile in `harness/tools/slice-mv.sh`, die das Kriterium
  für die Ausnahmeliste zitiert, überträgt es auf den falschen Zweig.

Für den Nachzug in `docs/reviews/**` steht die Quelle in
[ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 1 — und die kennt in
diesem Baum **eine** Adress-Form, nicht zwei.

### Das Doku-Gate unterscheidet die zwei Formen dort schon

```sh
grep -n 'exempt-paths: \["docs/reviews/\*\*"\]' .d-check.yml    # unter codepaths: — der Kommentar darüber sagt,
                                                                # Lifecycle-Pfade in Reviews veralten per Definition
```

Ein Pfad im **Code-Span** wird in `docs/reviews/**` nicht geprüft (`codepaths`), die
`ids`-Regeln nehmen den Baum ebenso aus; der **Markdown-Link** wird geprüft (`links`, `anchors`
tragen keine Ausnahme). Der Nachzug einer Code-Span-Adresse in einem Report beweist damit
nichts und schreibt trotzdem — und was er schreibt, ist dort oft eine Tatsachenaussage über den
damaligen Ort.

### Gemessen — je Baum, je Form

```sh
export LC_ALL=C
for t in docs/plan/planning/done docs/reviews; do
  echo "$t"
  git grep -noE '\]\([^)#]*/(open|next|in-progress)/[^)#]*\)' -- "$t" | wc -l           # Markdown-Link-Vorkommen
  git grep -noE '`[^`]*(open|next|in-progress)/slice-[^`]*`' -- "$t" | wc -l            # Code-Span-Vorkommen
done
# docs/plan/planning/done  527 Links · 59 Code-Spans
# docs/reviews              55 Links · 610 Code-Spans
git grep -lE '`[^`]*(open|next|in-progress)/slice-[^`]*`' -- docs/reviews | wc -l       # 213 Dateien
```

**Keine Erwartungswerte** — die Zahlen wandern mit dem Bestand. Tragend ist das Verhältnis: In
`docs/reviews/**` ist die Code-Span-Form die **überwiegende** Adress-Form, und sie ist die, die das
Gate nicht liest.

### Vier Ausnahme-Politiken, an einem Move gemessen

Derselbe Move (ein Slice, auf den zwei Link-Zeilen und weitere Code-Span-Zeilen in Reports und
sechzehn Zeilen in `done/` zeigen) in vier Kopien von `git archive HEAD` außerhalb des Repos, je ein
`make docs-check`; A bis C stellt die Kopie durch eine Zeile in der Ausnahmeliste her, D bildet einen Link-Nachzug per `sed` auf B nach. Rezept
und Skript stehen im Verdikt
[`2026-09-26-architect-verdikt-slice-mv-und-eingefrorene-adressen.md`](../../reviews/2026-09-26-architect-verdikt-slice-mv-und-eingefrorene-adressen.md).
Alle vier tragen denselben **einen** Befund, den der Zustand `in-progress/` ohne Roadmap-Marker
erzeugt (`planning-drift`); tragend ist die Differenz.

| Politik | `target-missing` (Differenz zu A) | Code-Span-Zeilen in Reports geändert | geprüfte Dateien |
|---|---|---|---|
| A — heute: Nachzug in jeder Form, jeder Baum | 0 | **ja** (Tatsache umgeschrieben) | 1964 |
| B — `docs/reviews` ganz ausgenommen | **+2** (die zwei Links sterben) | nein | 1964 |
| C — `docs/plan/planning/done` ganz ausgenommen | **+15** | ja | 1964 |
| **D — `docs/reviews` nur Link-Form** | **0** | **nein** | 1964 |

**D erreicht, was B will (die Tatsache bleibt stehen), ohne was B kostet (tote Links).** Die Zahl der
geprüften Dateien ist in allen vier Zeilen dieselbe: keine dieser Politiken nimmt eine Datei aus dem
Prüfbereich; B und C lassen ein **Gate rot** werden, das in den Baum hineinschaut, D nicht.

### Der Schreiber trägt nur zum Teil — und das ist hier kein Grund für eine neue Pflicht

Seit der Einführung von §3.11 (`git log -S'3.11 Eine Adresse, die der Prozess bewegt' --format=%h -- AGENTS.md`)
sind Pfad-Links auf bewegliche Slices in Zeitdokumente **hineingeschrieben** worden:

```sh
git log --format='C %h' --invert-grep --grep='^slice-mv:' --grep='^archive-welle' 05332d63..HEAD -p -U0 \
    -- docs/plan/planning/done docs/reviews |
  awk '/^\+\+\+ /{f=$2} /^\+[^+]/ && /\]\([^)]*\/(open|next|in-progress)\/slice-/{ if (f ~ /docs\/reviews/) {r++} else {d++} }
       END{print "done " d+0 " Zeilen · reviews " r+0 " Zeilen"}'    # done 67 · reviews 81
```

(**keine Erwartungswerte**; die Zahl zählt Zeilen, ohne Werkzeug-Commits.) Die Schreiber-Regel
([ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 3) hält also für
Markdown-Links **nicht vollständig**, und sie muss es nicht: Der Nachzug ist für diese Form die
entschiedene Antwort ([ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 1),
und unterbleibt er, färbt sich `make docs-check` rot (B, C oben). **Eine zusätzliche Pflicht am
Closure-Commit wäre ein Urteil je Link ohne Sensor** — und sie sparte nur, was das Werkzeug
kostenlos und gate-geprüft tut. **Akzeptiertes Negativ, mit Grund:** die Link-Form im Zeitdokument
bleibt zulässig, der Nachzug ist ihr Träger, und der Schreiber-Verzicht bleibt eine Empfehlung mit
dem Rang, den ihr [`AGENTS.md`](../../../AGENTS.md) §3.11 gibt — *Adresse, die der Prozess bewegt, steht
nicht in einem einfrierenden Artefakt* —, ohne dass ein Lauf daran scheitert.

## Entscheidung

**Wir wählen Option D: in `docs/reviews/**` ersetzt der Nachzug die Adresse nur in der Link-Form;
jede andere Form bleibt Byte für Byte.** Vier Festlegungen.

**1. Form-Regel für den Baum `docs/reviews/`.** Beide Träger des Verweis-Nachzugs — `make slice-mv`
(eingehend) und der Nachzug von `archive-welle` — ersetzen in einer Datei unter `docs/reviews/`
ausschließlich die Adresse, die als **Ziel eines Markdown-Links** steht: die Inline-Form `](ziel)`
und die Referenz-Definition `[name]: ziel`. Eine Pfad-Adresse als Code-Span, im Code-Block oder im
Fließtext wird **nicht** ersetzt. In den übrigen Bäumen aus
[ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 1 —
`docs/plan/planning/done/`, `docs/plan/carveouts/done/`, dem eingefrorenen Glied des
Beobachtungs-Registers — gilt der Nachzug in **jeder** Form wie bisher; dort prüft `codepaths` die
Code-Span-Form, und ein unterbliebener Nachzug färbte sie rot.

**2. Die Ausnahmeliste beider Träger bleibt, wie sie ist.** `.harness/baseline/**` und
`docs/plan/adr/**` — kein Baum kommt hinzu, und `docs/reviews/**` ist **kein** Eintrag der Liste.
Ein ganz ausgenommener `docs/reviews/**` oder `done/**` ist verworfen (Tabelle oben, B und C): er
macht tote Links, die niemand reparieren darf, und schaltete sie nur durch ein baum-weites
`ignore-refs` wieder stumm, also durch eine Senkung nach [`AGENTS.md`](../../../AGENTS.md) §3.5. **Diese
Entscheidung ist keine Senkung:** `.d-check.yml` bleibt unberührt, `codepaths.exempt-paths` steht
wie zuvor, und die Zahl der geprüften Dateien bewegt sich nicht (Tabelle, letzte Spalte).

**3. Abnahme-Kriterium 1 von [ADR-0033](0033-wellen-archivierung-als-unterkommando.md) ist die Regel
über den Suchraum des Hänger-Wächters und keine über den Nachzug.** Es gilt unverändert weiter —
der Wächter liest `docs/reviews/**` vollständig —, und **kein** Wort jener ADR wird hier
überschrieben. Wer es für die Ausnahmeliste des Nachzugs zitiert, zitiert eine Quelle, die diese
Frage nicht regelt; die Quelle des Nachzugs in `docs/reviews/**` ist
[ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 1 in der Fassung dieser
Entscheidung.

**4. Eine von Hand wiederhergestellte Code-Span-Adresse in `docs/reviews/**` bleibt zulässig — bis der
Träger die Regel hält, und danach ist sie überflüssig.** Zeitdokumente sind für den Nachzug **nicht**
von §3.4 geschützt ([ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 1), und
die Wiederherstellung der Code-Span-Form ist für das Gate neutral (`codepaths` nimmt den Baum aus).
Für die **Link-Form** gilt das nicht: ein von Hand zurückgesetzter Link ist ein toter Link und ein
rotes Gate (Politik B). **Die Übergangsregel ist damit dieselbe wie die Dauerregel; der Aufwand
entfällt, sobald der Träger die Form-Regel führt.**

**Was diese Entscheidung nicht tut.**

- **Sie ändert nichts an einer Zustandsaussage neben dem Link.** *„lag in `open/`"* neben einem
  nachgezogenen Link bleibt stehen ([ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md)
  Festlegung 4, erste Gegenform) — der Text ist die Tatsachenaussage und wird nicht angefasst.
- **Sie sagt nichts über `done/**` in der Code-Span-Form.** Dort ist der Nachzug gate-notwendig; die
  Gegenform *„der Operand eines Mess-Kommandos"* bleibt, was Festlegung 4 dort benennt.
- **Sie sagt nichts über ein emittiertes Repo.** Die Ausnahmeliste ist dort setzbar Politik; die
  Form-Regel gilt für dieses Repo, und was ein Zielrepo bekommt, entscheidet der Vorgang, der die
  Tool-Ebene entscheidet.
- **Sie schafft keine neue Schreiber-Pflicht** — Kontext, letzter Abschnitt.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun, die Restores von Hand fortsetzen | keine Änderung | die Restores sind ein Lauf pro betroffenem Report, ohne Sensor und mit falscher Begründung in der Historie; und ohne Regel überschreibt der nächste Move sie wieder. Der Report-Bestand fällt pro Move an derselben Stelle |
| B — `docs/reviews/**` in die Ausnahmeliste beider Träger | eine Zeile pro Träger; nichts in Reports wird je geschrieben | gemessen **+2** tote Links an einem Move, und jeder weitere Move mit einem Report-Link verlängert die Liste; das Gate färbte rot, und der einzige Ausweg wäre ein baum-weites `ignore-refs`, also **eine Senkung nach §3.5**, um zwei Zeichen zu sparen |
| C — `done/**` in die Ausnahmeliste | schützt Ergebnis-Notizen und Slices | gemessen **+15** an einem Move; dort prüft `codepaths` beide Formen, und die Ergebnis-Notiz ist die Stelle, an der Links auf bewegliche Träger stehen (67 geschriebene Zeilen seit §3.11, Kontext) |
| D′ — Kennungs-Umschreibung im selben Akt: der Nachzug macht aus dem Link eine Kennung | löst die Adresse dauerhaft | aus einem Zeiger wird Text: ein **Urteil je Fundstelle** ([ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 4 verwirft es), und es ändert die Aussage, die die Regel hält |
| **D — gewählt: Form-Regel für `docs/reviews/**`, Nachzug sonst wie bisher** | Prüfbereich unverändert (1964 in allen Politiken); Tatsachen in Reports bleiben stehen; der Nachzug bleibt dort, wo er das Gate hält; keine Senkung | eine Erkennung im Träger, die die Link-Form von der Code-Span-Form trennt — zwei Fassungen (Shell, Go), und die Kopplung an `codepaths.exempt-paths` ist eine Zusage zwischen zwei Dateien, die nur ein Test hält |

## Konsequenzen

- **Positiv:** Die Zeile *„Ein Nachzug in `docs/reviews/**` umschreibt eine Tatsache"* verschwindet als
  Klasse; die Restores von Hand entfallen; die Bestands-Beobachtung zur historisch richtigen Adresse
  ist für diesen Baum an der Quelle geschlossen.
- **Positiv:** Kein Gate wird gesenkt, kein `ignore-refs`-Paar entsteht, die Zahl der Paare bleibt.
- **Negativ:** Code-Span-Adressen in `docs/reviews/**` sterben **still**: nach einem Move zeigen sie
  auf den alten Ort, und kein Gate sieht es — das ist der Zustand, den
  [`codepaths.exempt-paths`](../../../.d-check.yml) für den Baum schon heute deklariert, nur ohne
  dass der Nachzug ihn bisher mitgetragen hätte.
- **Negativ:** Die Regel hängt an einer Eigenschaft der Config (`exempt-paths` für `docs/reviews/**`).
  Fällt jene, fällt der Grund dieser (Re-Evaluierungs-Trigger 1).
- **Folgepflicht 1 — ein Implementer-Slice** (dieselbe Größe wie ein Nachzug-Schnitt: drei
  Liefer-Punkte). (a) `make slice-mv`: `harness/tools/slice-mv.sh` ersetzt in `docs/reviews/`
  nur die Link-Form; der Kommentar an der Ausnahmeliste zitiert
  [ADR-0033](0033-wellen-archivierung-als-unterkommando.md) Abnahme-Kriterium 1 für den falschen
  Zweig und wird auf diese Entscheidung umgestellt; Fall in `test/slice-mv.bats`, der die
  Byte-Gleichheit der Code-Span-Adresse **und** den Nachzug des Links in derselben Datei hält.
  (b) `archive-welle`: `internal/archive` (Nachzug) mit demselben Verhalten, Test und
  Mutations-Fall unter `test/mutations/`. (c) `harness/sensors/slice-mv.md` und
  `harness/sensors/archive-welle.md` nennen die Form-Regel in ihrer Grenze. Ob die Erkennung in
  den Funktionen der Liste `KERN` aus `test/slice-mv.bats` liegt — dann zieht die emittierte Fassung
  mit oder die Regel liegt außerhalb der Liste —, entscheidet der Implementer und sagt es in seinem
  Bericht; die Zusage gilt für dieses Repo.
- **Folgepflicht 2 — der Planner schreibt den Register-Stand nach**, wenn diese Entscheidung
  `Accepted` ist: die Beobachtung *„der Nachzug ersetzt eine historisch richtige Adresse"* nennt für den
  Baum `docs/reviews/` diese Entscheidung als Zielort; das Register gehört nicht dem Architect.

## Fitness Function (falls maschinell prüfbar)

**Noch nicht gebaut — sie ist die Abnahme von Folgepflicht 1, und für jede Zusage steht das
Gegenbeispiel, das rot werden muss** ([`AGENTS.md`](../../../AGENTS.md) §3.6):

| Tooling | Zusage | Rot ist zu sehen, wenn |
|---|---|---|
| bats (`test/slice-mv.bats`) · Go-Test in `internal/archive` | in einer Datei unter `docs/reviews/` bleibt die Code-Span-Adresse des bewegten Slice Byte für Byte, und der Link auf ihn wird nachgezogen | die Form-Regel entfällt (dann ist die Code-Span-Adresse umgeschrieben — Politik A) **oder** der Link-Nachzug in `docs/reviews/` entfällt (dann ist der Link tot — Politik B, gemessen **+2** `target-missing`) |
| `make mutate` (Fall je Träger, `test/mutations/`) | beide Mutationen färben je einen Fall rot | der Fall bindet **beide** Hälften einer Datei (Link und Code-Span nebeneinander): ein Fall mit nur einer Hälfte bleibt bei der geschwächten Regel grün |
| `make docs-check` | nach dem Move löst jeder nachgezogene Link auf | der Nachzug in `docs/reviews/` unterbleibt (Politik B) |
| bats | in `docs/plan/planning/done/` wird jede Form weiter ersetzt | die Form-Regel wird auf einen zweiten Baum ausgedehnt (dann ist die Code-Span-Adresse in `done/` stehen geblieben, und `codepaths` färbt rot) |

**Nicht gebaut, und hier benannt.** Die **Kopplung** zwischen der Form-Regel und
`codepaths.exempt-paths` hält kein Test: Fällt die Ausnahme in `.d-check.yml`, bleibt die Regel
stehen und schützt eine Form, die das Gate nun prüfte. Träger ist Re-Evaluierungs-Trigger 1 und der
Lauf, der die Config ändert. Die **Zustandsaussage neben dem Link** bleibt ein Urteil
([ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 4).

## Re-Evaluierungs-Trigger

1. **Wenn `codepaths.exempt-paths` den Baum `docs/reviews/**` nicht mehr ausnimmt** *(an
   [`.d-check.yml`](../../../.d-check.yml) ablesbar)*: dann prüft das Gate die Code-Span-Form dort, und
   Festlegung 1 schützt eine Form, die ein unterbliebener Nachzug rot färbte — die Regel ist zu
   streichen.
2. **Wenn `links` für `docs/reviews/**` eine Ausnahme bekommt** *(an derselben Datei ablesbar)*: dann
   trägt der Nachzug der Link-Form dort nichts mehr, und die Frage, ob er noch schreiben soll, ist neu.
3. **Wenn ein Träger den Nachzug nach Status schneiden kann** ([ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md)
   Re-Evaluierungs-Trigger 3): dann ist die Form-Regel gegen den Status-Schnitt zu halten.
4. **Wenn eine Form auftritt, die weder Link noch Code-Span ist und eine Tatsache umschreibt** *(am
   Bericht eines Laufs ablesbar)*: dann ist die Trennlinie *„Link"* zu grob, und die Klasse ist größer als
   gemessen.

## Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`. Sie wird `Accepted`, **wenn eine Reviewer-Runde sie gegen
[ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md),
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md) und
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) auf Konsistenz geprüft hat und ihr
Report gegen den Gegenstand dieser Entscheidung selbst keinen blockierenden Befund führt.** Die
Accept-Zeile der §Geschichte nennt den Beleg als Kennung
([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1). Der Vollzug
liegt beim Auftraggeber.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-26 | **Proposed** | Architect-Lauf zu zwei Fragen des Auftraggebers; das Verdikt trägt die Begründung, das Skript der Kopien-Probe und die Gegenwahl je Frage |
