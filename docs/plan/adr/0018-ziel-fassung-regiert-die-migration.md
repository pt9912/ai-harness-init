# ADR-0018: Welche Regelwerks-Fassung die Re-Baseline-Migration regiert

**Status:** Proposed

**Datum:** 2026-08-09

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Baseline ist auf
einen Tag gepinnt; diese ADR entscheidet, welcher der beiden Tags während des Wechsels das
Verfahren stellt),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein Gate
liest, nach welcher Fassung ein Durchgang lief — hier so benannt),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (Form jedes Belegs in diesem Dokument),
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) (die Rolle, die diese Entscheidung
schreibt)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie regelt die **normative Quelle eines Vorgangs**,
nicht den Inhalt eines Spec-Dokuments.

**Kopplung:** Die Entscheidung trägt das Closure-Kriterium der Re-Baseline-Welle — deren drei
Durchgänge sind aus den Eigenschaften genau der Prozedur gebaut, die hier gewählt wird. Der
Wellenplan zeigt hierher; er entscheidet nichts davon selbst.

---

## Kontext

Ein Re-Baseline tauscht das Regelwerk, nach dem dieses Repo arbeitet. Damit stellt sich eine
Frage, die kein anderer Vorgang stellt: **welche Fassung regiert den Tausch selbst** — die
gepinnte, die das Repo adoptiert hat, oder die Ziel-Fassung, die es adoptieren will? Beide
Antworten sind vertretbar formulierbar, und solange sie nicht entschieden ist, entscheidet sie
faktisch der Lauf, der zuerst anfängt.

Der laufende Sprung ist `v3.5.2` → `v5.12.0`. Adoptiert ist heute `v3.5.2`
([`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage), Adoptions-Erklärung;
vendored nach [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).

### Was die beiden Fassungen zum Freshness-Audit führen — gemessen

Der Abschnitt ist in **beiden** Fassungen vollständig gelesen, nicht überflogen; die Zählungen
darunter sind die Gegenprobe, nicht die Messung.

**Gepinnt, `v3.5.2`, `modul-02-harness-bootstrap.md`, §Freshness-Audit der vendored Baseline
(Schritt 2):** *„Der Freshness-Audit hat drei Eigenschaften"* — beobachtbarer Auslöser,
Netz-Operation außerhalb der Gates, Release-*Liste* statt Asset. Alle drei beschreiben, **wann und
wie man merkt**, dass ein neuer Tag existiert. Was danach zu tun ist, steht in einem Satz:
*„Ein neuer Tag löst einen Review aus (Re-Vendoring mit eigenem Diff), keinen stillen
Auto-Bump."*

**Ziel, `v5.12.0`, `modul-02-harness-bootstrap.md`, §Freshness-Audit der vendored Baseline
(Schritt 2):** *„Der Freshness-Audit hat sieben Eigenschaften"*. Die ersten drei sind die der
gepinnten Fassung; die vier neuen sind der Vorgang selbst — der Durchgang durch die
Adaptions-Liste (*„Der Review geht durch die Adaptions-Liste, nicht nur durch den Diff"*, mit
**fünf Ausgängen**), der Form-Vergleich (*„Der Review vergleicht auch die Form, nicht nur die
Regeln"*), die Rückbau-Disziplin (*„Rückbau ist ein neuer Eintrag, kein Edit"*) und die
Stichprobe (*„Eine Stichprobe gegen den Bestand, nicht gegen das Delta"*).

Die gepinnte Fassung nennt also das **Ereignis**, nicht das **Verfahren**. Gegenprobe über den
gesamten `regelwerk/`-Baum der gepinnten Fassung (21 Dateien) — vier Begriffe der Ziel-Prozedur,
je **0** Treffer: *fünf Ausgänge*, *Adaptions-Liste*, *gegenstandslos*, *Rückbau ist ein neuer
Eintrag*. **Grenze der Gegenprobe:** ein Negativ aus vier aufgezählten Zeichenketten; eine Regel,
die keines dieser Wörter führt, hätte sie nicht gefunden. Sie stützt die Lektüre, sie ersetzt sie
nicht.

### Dass der Freshness-Audit überhaupt das zuständige Werkzeug ist, sagt die Ziel-Fassung selbst

`v5.12.0`, `grundlagen-bootstrap.md`, §Modus pro Sub-Area: Greenfield vs Brownfield: *„Wer eine
Regelwerks-Migration für einen Brownfield-Fall hält, weil dort „Inventur des Bestands" steht,
greift zum falschen Werkzeug: BF regelt, ob Code oder Doku führt — bei einer Migration sind beide
längst da und stimmen miteinander überein; abweichen kann das Artefakt von der adoptierten Norm.
Für diese Achse ist der Freshness-Audit zuständig …, nicht die Modus-Wahl."* Die gepinnte Fassung
führt diese Zuordnung nicht; ihre Grundlagen liegen in `grundlagen-konventionen.md`, das in der
Ziel-Fassung in **sechs** Dateien zerfällt
(`comm -13 <(git ls-tree --name-only v3.5.2 lab/regelwerk/ | grep grundlagen | xargs -n1 basename | sort) <(git ls-tree --name-only v5.12.0 lab/regelwerk/ | grep grundlagen | xargs -n1 basename | sort) | wc -l`
→ **6**, lokaler Kurs-Klon).

### Keine der beiden Fassungen beantwortet die Frage dieser ADR

Gesucht wurde in **beiden** Tags über Regelwerk **und** Templates nach einer Meta-Regel, welche
Fassung während eines Wechsels gilt (Suchbegriffe: *welche Fassung · maßgeblich · regiert ·
gepinnte Fassung · alte Fassung · Prozedur · Migration · Re-Vendor · Bump · adoptiert · Adoption ·
Übergang · Reihenfolge des Wechsels*; 33 Treffer bei `v3.5.2`, 63 bei `v5.3.1`, gelesen — die
Suche lief am 2026-08-09 gegen **diese zwei** Tags und bleibt als Aussage über sie stehen; die
Schritte auf `v5.9.0` und `v5.12.0` deckt der Delta-Nachweis darunter). Die einzigen Aussagen über Normativität
gelten dem Verhältnis Spiegel ↔ Kurs, nicht dem Verhältnis gepinnt ↔ Ziel.

Daraus folgt zweierlei. Erstens ist diese Entscheidung eine **Lücke**, keine Abweichung — sie
weicht von keiner Baseline-Regel ab, weil keine existiert, und schuldet deshalb **keinen** Eintrag
im Adaptions-Block ([`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage)).
Zweitens ist die naheliegende Gegenposition — *„das Repo hat `v3.5.2` adoptiert, also gilt
`v3.5.2`"* — an dieser Stelle leer: sie verweist auf eine Regel, die es dort nicht gibt.

### Der Zielstand ist von `v5.3.1` über `v5.9.0` auf `v5.12.0` gezogen — der Aufpreis ist gemessen

Die Lektüre der Abschnitte davor lief gegen `v5.3.1`. Sie trägt weiter — nachgewiesen über den
Delta, nicht über eine Wiederholung, und **je Schritt einmal**. Das ist die Form, die
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) §Kontext eine Fassung früher für denselben
Vorgang gewählt hat; ihr eigener Nachweis deckt ausdrücklich nur den Schritt, den er misst.

```sh
git diff --shortstat v3.5.2 v5.3.1 -- lab/regelwerk lab/templates
# -> 52 files changed, 3471 insertions(+), 1297 deletions(-)
git diff --shortstat v5.3.1 v5.9.0 -- lab/regelwerk lab/templates
# -> 27 files changed, 438 insertions(+), 134 deletions(-)    <- Aufpreis Schritt 1
git diff --shortstat v3.5.2 v5.9.0 -- lab/regelwerk lab/templates
# -> 53 files changed, 3845 insertions(+), 1367 deletions(-)
git diff --shortstat v5.9.0 v5.12.0 -- lab/regelwerk lab/templates
# -> 10 files changed, 172 insertions(+), 16 deletions(-)     <- Aufpreis Schritt 2
git diff --shortstat v3.5.2 v5.12.0 -- lab/regelwerk lab/templates
# -> 53 files changed, 4005 insertions(+), 1371 deletions(-)  <- der Zielstand
```

Schritt 1 kostete rund ein Zehntel des Gesamt-Deltas, Schritt 2 kostet **172 + 16 = 188**
geänderte Zeilen gegen **4005 + 1371 = 5376** — rund **3,5 %**. Er fügt dem Änderungs-Satz
**keine** Datei hinzu (53 in beiden Gesamt-Zeilen) und dem vendored Baum auch nicht: **26 + 25 =
51** Dateien in beiden Tags
(`for t in v5.9.0 v5.12.0; do for d in lab/regelwerk lab/templates; do git ls-tree -r --name-only $t -- $d | wc -l; done; done`
→ **26 25 26 25**). Der Sprung wird größer, nicht anders.

**Die gewählte Prozedur behält ihre Form** — im zweiten Schritt buchstäblich:
`modul-02-harness-bootstrap.md` ist zwischen `v5.9.0` und `v5.12.0` **byte-gleich**
(`git diff --shortstat v5.9.0 v5.12.0 -- lab/regelwerk/modul-02-harness-bootstrap.md` → leer),
womit jede Messung dieses Absatzes bis zum Zielstand trägt, ohne wiederholt zu werden. Im ersten
Schritt ändert die Datei sich in
**einem** Hunk (`git diff v5.3.1 v5.9.0 -- lab/regelwerk/modul-02-harness-bootstrap.md | grep -c '^@@'`
→ **1**, über +13/−4 Zeilen). Der Abschnitt heißt unverändert §Freshness-Audit der vendored
Baseline (Schritt 2), führt unverändert das Zahlwort *„sieben Eigenschaften"* — gegengeprüft an
den Aufzählungspunkten selbst
(`git show v5.9.0:lab/regelwerk/modul-02-harness-bootstrap.md | sed -n '/^#### Freshness-Audit/,/^#### Gate-Fragment/p' | grep -c '^\* \*\*'`
→ **7**) — und unverändert **fünf** Ausgänge, die Festlegung 4 einzeln beim Namen nennt
(Handzählung über diese fünf Namen, kein Kommando zählt sie).

**Der eine Hunk trifft den fünften Ausgang.** *widerspricht* bekommt eine zweite Verzweigung —
das Repo kann die neue Regel statt ihrer Fortgeltung auch **übernehmen** — und dazu die
Abgrenzung `MR` ↔ Carveout. **Diese ADR liest das nicht vor** (Festlegung 4, erster Punkt); sie
hält fest, dass die gewählte Quelle an dieser Stelle gewachsen ist, und überlässt die Deutung
dem Durchgang, der sie anwendet.

**Keine tragende Quelle dieser ADR verliert ihren Wortlaut.** Im zweiten Schritt sind alle drei
byte-gleich
(`git diff --name-only v5.9.0 v5.12.0 -- lab/regelwerk/modul-02-harness-bootstrap.md lab/regelwerk/modul-04-adrs.md lab/regelwerk/grundlagen-bootstrap.md`
→ leer). Im ersten erscheint `grundlagen-bootstrap.md` im Delta nicht und ist damit byte-gleich
(`git diff --name-only v5.3.1 v5.9.0 -- lab/regelwerk/grundlagen-bootstrap.md` → leer); in
`modul-04-adrs.md` bleibt die zitierte Hard Rule unberührt — der Delta setzt einen Punkt
**davor**, keine Zeile des Zitats erscheint in ihm
(`git diff v5.3.1 v5.9.0 -- lab/regelwerk/modul-04-adrs.md | grep -c '^[+-].*Accepted. wird nicht inhaltlich'`
→ **0**). Auch die vier Begriffe der Gegenprobe oben führt die Ziel-Fassung weiter, und der
gepinnte Baum führt keinen von ihnen — je Begriff die Zahl der Dateien, die ihn führen:

```sh
for t in 'fünf Ausgänge' 'Adaptions-Liste' 'gegenstandslos' 'Rückbau ist ein neuer Eintrag'; do
  for tag in v5.12.0 v5.9.0 v3.5.2; do echo -n "$tag/$t: "; git grep -c "$t" "$tag" -- lab/regelwerk | wc -l; done
done
# -> v5.12.0: 1, 1, 2, 1     v5.9.0: 1, 1, 2, 1     v3.5.2: 0, 0, 0, 0
```

**Und die Frage dieser ADR beantwortet auch `v5.12.0` nicht.** Die Lektüre von oben wird dafür
nicht wiederholt; geprüft ist der Delta — dieselben dreizehn Suchbegriffe, nur über die
**hinzugefügten** Zeilen, je Schritt einmal:

```sh
for step in 'v5.3.1 v5.9.0' 'v5.9.0 v5.12.0'; do
  git diff $step -- lab/regelwerk lab/templates | grep '^+' | grep -cE \
    'welche Fassung|maßgeblich|regiert|gepinnte Fassung|alte Fassung|Prozedur|Migration|Re-Vendor|Bump|adoptiert|Adoption|Übergang|Reihenfolge des Wechsels'
done
# -> 10   (v5.3.1 -> v5.9.0)
#     6   (v5.9.0 -> v5.12.0)
```

**Zehn** Zeilen im ersten Schritt, alle gelesen. Sie tragen vier der Begriffe (*Übergang*,
*Prozedur*, *Bump*, *adoptiert*) und sprechen von Slice-Lifecycle, Closure-Prozedur und dem
Version-Bump der Spezifikation. **Sechs** im zweiten, ebenfalls alle gelesen: der Change Request
als bewusst **Nicht**-Harness-Konstrukt, der Version-Bump des Lastenhefts als Fußabdruck ab
`Accepted`, die Vollständigkeits-Regel der Source Precedence und der Übergang nach `done`. Eine
Meta-Regel darüber, welche Fassung einen Wechsel regiert, ist in keiner der beiden Mengen.

Die nächste Nachbarin ist die Vollständigkeits-Regel (`v5.12.0`,
`grundlagen-source-precedence.md`, §Source Precedence: *„Jede Regel, der ein Agent folgen muss,
steht in einer gerankten Quelle, im Konventionsspeicher oder in der adoptierten Baseline"*). Sie
sagt, **wo** eine bindende Regel stehen darf, nicht **welche Fassung** einen Wechsel regiert —
und sie widerspricht dieser Entscheidung nicht: Was ein Lauf hier befolgt, steht in einer
gerankten Quelle, nämlich in dieser ADR auf Rang 4, nicht in der Ziel-Fassung selbst. Genau
diese Trennung ist Festlegung 2.

**Grenze:** dieser Nachweis deckt die zwei Schritte `v5.3.1` → `v5.9.0` → `v5.12.0`. Für einen
weiteren Bump gilt er nicht, und die Gegenprobe teilt die Grenze der Gegenprobe oben — sie ist
ein Negativ aus aufgezählten Zeichenketten.

### Wer den Zielstand bewegt — und wen die Defekt-Regel des Wellenplans bindet

Beide Züge — `v5.3.1` → `v5.9.0` und `v5.9.0` → `v5.12.0` — gehen auf eine **Setzung des
Auftraggebers** zurück, nicht auf einen gemessenen Defekt im bisherigen Zielstand. Der Wellenplan
führt dafür eine Regel, die das dem Wortlaut nach ausschließt
(`docs/plan/planning/welle-10-re-baseline.md`, §1 Welle-Ziel): *„Er wandert, wenn in ihm ein
**gemessener Defekt** liegt, der eine Entscheidung dieses Repos berührt; **nicht**, weil ein
neuerer Tag existiert."* Zweimal angewandt und zweimal überholt — eine Regel, die so läuft,
beschreibt entweder etwas anderes als ihren Anwendungsfall, oder sie ist falsch.

**Sie beschreibt etwas anderes: sie ist an die Rollen adressiert, nicht an den Auftraggeber.**
Ihr Ertrag ist, dass kein Lauf im Repo den Zielstand einer Release-Liste nachführt — der stille
Auto-Bump eine Ebene höher, den Festlegung 3 schon für die Wahl der Prozedur abwehrt. Welche
Fassung dieses Repo adoptieren **will**, ist dagegen keine Ableitung aus einer Messung, sondern
dieselbe Art Akt wie die Adoption selbst —
[`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) heißt nicht umsonst
Adoptions-*Erklärung*. Eine repo-interne Regel kann diesen Akt nicht binden; sie kann ihn nur
belegpflichtig machen.

**Die Baseline widerspricht dem an dieser Stelle nicht.** Beide Fassungen führen wortgleich
*„Ein neuer Tag löst einen **Review** aus (Re-Vendoring mit eigenem Diff), keinen stillen
Auto-Bump."* (`v3.5.2` und `v5.12.0`, je `modul-02-harness-bootstrap.md`, §Freshness-Audit der
vendored Baseline (Schritt 2)). Ein neuer Tag **ist** dort ein zulässiger Anlass; unzulässig ist,
dass er ohne Review zum Bump wird. Der Review ist der Abschnitt davor, und der Preis der Setzung
ist damit benannt und bezahlt: ein Delta-Nachweis je Schritt und eine Zeile in §Geschichte.

**Was diese ADR damit nicht tut.** Sie macht daraus keine fünfte Festlegung. Ihr Gegenstand ist
die **normative Quelle der Migrations-Prozedur**; wer den Zielstand bewegen darf, ist deren
Prämisse und wird hier benannt, weil sie hier gebraucht wird. Bräuchte diese Frage eine eigene
Bindung — etwa einen Beleg-Mindestumfang je Setzung —, wäre das eine eigene ADR. Die Formulierung
im Wellenplan bleibt Planner-Eigentum ([ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md));
diese ADR sagt, **was** die Regel bindet, nicht, wie ein Plan sie schreibt.

## Entscheidung

**Wir wählen Option E: für diesen Sprung regiert die Prozedur der Ziel-Fassung; allgemein gilt
nicht „stets die Ziel-Fassung", sondern ein Kriterium, das jeder Sprung neu misst.** Vier
Festlegungen.

**1. Für den Sprung `v3.5.2` → `v5.12.0` ist die Migrations-Prozedur der Freshness-Audit der
Ziel-Fassung** (`v5.12.0`, `modul-02-harness-bootstrap.md`, §Freshness-Audit der vendored Baseline
(Schritt 2)) — mit seinen sieben Eigenschaften, seinen drei Durchgängen und seinen fünf Ausgängen.
**Die drei Durchgänge sind drei dieser sieben Eigenschaften** — Adaptions-Liste, Form-Vergleich,
Stichprobe — und damit eine Lesart dieser ADR; *„drei Durchgänge"* ist kein Zahlwort
der Quelle, *„sieben Eigenschaften"* und *„fünf Ausgänge"* sind es.

Der Grund ist die Messung im Kontext, und der erste trägt allein: die gepinnte Fassung
**beschreibt diesen Fall nicht**. Ihr zu folgen hieße nicht, einer älteren Regel zu folgen,
sondern **gar keiner** — die Wahl steht zwischen einem Verfahren und keinem, nicht zwischen zwei
Verfahren.

**2. Die Wahl gilt für die Prozedur, nicht für den Ist-Zustand.** Bis der Baum getauscht ist,
bleibt `v3.5.2` die adoptierte Baseline und für **jede Konformitäts-Frage** maßgeblich. Prozedur
und Maßstab sind während der Welle zwei verschiedene Fassungen. Wer das umdreht, misst den
Ist-Zustand an einer Fassung, die dieses Repo nicht adoptiert hat, und erzeugt Befunde, die keine
sind.

**3. Allgemein ist das Kriterium, nicht das Ergebnis.** Vor jedem künftigen Sprung wird gemessen,
ob die **gepinnte** Fassung die Migrations-Prozedur führt:

- **Führt sie sie nicht** — der Fall dieser ADR —, regiert die Ziel-Fassung, ohne neue Abwägung.
- **Führen beide sie**, ist die Wahl **offen** und wird in jenem Sprung begründet entschieden.
  Diese ADR entscheidet sie nicht vor.

Warum nicht die stärkere Regel *„es regiert stets die Ziel-Fassung"*: Sie bände Prozeduren,
deren Wortlaut niemand kennt — eine Zusage ohne Gegenbeispiel
([`AGENTS.md`](../../../AGENTS.md) §3.6). Und sie liefe der einen Regel zuwider, die **beide**
Fassungen an dieser Stelle wortgleich führen: *„Ein neuer Tag löst einen Review aus (Re-Vendoring
mit eigenem Diff), keinen stillen Auto-Bump."* Eine Blankett-Vorwahl der Ziel-Prozedur wäre genau
dieser stille Auto-Bump eine Ebene höher — sie nähme dem Review sein Ergebnis vorweg, bevor der
Text vorliegt, den er lesen soll. Die tragende Messung dieser ADR ist zudem eine Eigenschaft
**dieses Fassungspaars**: dass die gepinnte den Fall nicht führt. Für das nächste Paar ist sie
eine Vermutung.

**4. Geltungsbereich — vier Grenzen, die zur Entscheidung gehören.**

- **Sie deutet die fünf Ausgänge nicht.** Was *gegenstandslos*, *bleibt gültig*, *teilweise
  überholt*, *Bezug ist entfallen* und *widerspricht* bedeuten, sagt die Baseline; diese ADR fügt
  dem nichts hinzu und zieht nichts ab. Sie wählt die Quelle, sie liest sie nicht vor.
- **Sie entscheidet keinen einzelnen Eintrag des Adaptions-Blocks.** **Jeder** Eintrag bekommt
  seinen Ausgang **einzeln, mit eigenem Beleg** — am 2026-08-22 sind es **26**
  (`grep -c '^### MR-' harness/conventions.md`); die Zahl **wandert** mit jedem neuen Eintrag
  und ist kein Erwartungswert
  ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Eine Pauschale wäre auch gegen die gewählte Prozedur selbst, deren Frage
  ausdrücklich pro Eintrag gestellt wird: *„Frage pro Eintrag in `harness/conventions.md`: Regelt
  die neue Fassung das, wofür diese Adaption angelegt wurde?"*
- **Der Adaptions-Durchgang erfasst ADRs nicht.** Sein Gegenstand ist der Eintrag in
  `harness/conventions.md`, nicht die ADR, die ihn begründet. Für ADRs gilt
  [`AGENTS.md`](../../../AGENTS.md) §3.4 und dieselbe Regel in der Ziel-Fassung (`v5.12.0`,
  `modul-04-adrs.md`, §Hard Rule für Accepted-ADRs: *„Eine ADR mit Status `Accepted` wird nicht
  inhaltlich überschrieben."*). Wo die Prozedur ADRs überhaupt nennt, tut sie es im
  **Form**-Durchgang und stellt bestehende Instanzen frei: *„Für wiederkehrende Templates (ADR,
  Slice, Welle, Carveout, Review-Report) gilt die Append-only-Logik: Neue Instanzen folgen der
  neuen Form, bestehende werden nicht rückwirkend umgeschrieben."* Zwei Regime, eine Grenze —
  ergibt ein Durchgang, dass eine begründende ADR überholt ist, ist die Antwort eine **Folge-ADR
  mit `Supersedes`**, nie ein Edit.
- **Sie ordnet den Vorgang keinem Bootstrap-Modus zu.** Greenfield/Brownfield regeln die Achse
  Doc ↔ Code; eine Regelwerks-Migration liegt auf der Achse adoptierte Norm ↔ ausgefülltes
  Artefakt (Kontext).

### Dass die Wahl Folgen hat, ist belegt — an einem Fall, den sie nicht entscheidet

[`MR-020`](../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
weicht von der Disziplin-Regel der vendored Vorlage ab; die tragende
[ADR-0014](0014-aufgehobener-eintrag-kopf-statt-rumpf.md) nennt das in ihrer Alternativen-Tabelle
*„eine Lockerung der Baseline-Disziplin"*. Die Ziel-Fassung **verschärft** an genau dieser Stelle
(`v5.12.0`, `modul-02-harness-bootstrap.md`, §Freshness-Audit der vendored Baseline (Schritt 2):
*„Rückbau ist ein neuer Eintrag, kein Edit"*) und benennt für genau diese Konstellation einen
Ausgang: *„War die Adaption eine Lockerung und die neue Baseline verschärft, ist die richtige
Antwort ein Carveout mit Auflösungs-Trigger (Modul 7), keine stille Dauer-`MR`."* Die gepinnte
Fassung führt weder die Verschärfung noch den Ausgang.

Unter Festlegung 1 wird diese Frage also **gestellt**; unter der Gegenoption entstünde sie nicht —
nicht, weil sie anders beantwortet würde, sondern weil niemand sie stellte. Genau das ist der
Beleg, dass die Wahl der regierenden Fassung eine Entscheidung mit Wirkung ist und kein
Formalismus. **Der Fall selbst gehört dem Adaptions-Durchgang und wird hier nicht entschieden** —
weder in Richtung Carveout noch in Richtung Fortbestand.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts entscheiden, die Festlegung bleibt im Wellenplan | kein Aufwand; sie steht ja da und ist begründet | sie steht auf Rang 5 der Source Precedence (Planung) statt Rang 4 (ADR), in einem Artefakt, das mit der Welle nach `done/` wandert und dort nicht mehr gelesen wird — die Frage *„wer hat das entschieden?"* bleibt beim nächsten Sprung unbeantwortbar. Und sie stünde unter fremdem Eigentum: der Wellenplan gehört dem Planner, die Wahl der normativen Quelle ist eine Architektur-Frage ([ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md)) |
| B — die gepinnte Fassung regiert | formal der saubere Status quo: adoptiert ist `v3.5.2`, und man arbeitet nach dem, was man adoptiert hat | gemessen führt `v3.5.2` die Prozedur **nicht** — der Migration bliebe ein Auslöser ohne Verfahren. Adaptions-Durchgang, Form-Vergleich und Stichprobe entstünden ad hoc, und das Closure-Kriterium der Welle, das aus genau diesen drei gebaut ist, hätte keine Quelle |
| C — allgemeine Regel *„stets die Ziel-Fassung"* | eine Frage, die nie wieder gestellt werden muss; jeder künftige Sprung startet ohne Vorlauf | bindet Prozeduren, deren Wortlaut niemand kennt, und wäre der stille Auto-Bump eine Ebene höher — den **beide** Fassungen wortgleich verbieten. Die tragende Messung gilt diesem Fassungspaar, nicht dem nächsten; als allgemeine Regel wäre sie eine Zusage ohne Gegenbeispiel ([`AGENTS.md`](../../../AGENTS.md) §3.6) |
| D — mischen: Ziel-Prozedur, aber nur ihre Eigenschaften, die die gepinnte schon kennt | bliebe im adoptierten Rahmen und bräuchte keine Entscheidung über eine fremde Fassung | die drei Eigenschaften der gepinnten Fassung sind **Auslöser**-Eigenschaften (Trigger, Netz-Operation, Release-Liste); ihr Schnitt mit der Ziel-Prozedur enthält nichts, was den Vorgang beschreibt. Die Teilmenge wäre zudem eine Erfindung dieses Repos — sie stünde in keiner Fassung und hätte damit dieselbe Lücke wie B, nur verdeckt |
| **E — gewählt: Ziel-Fassung für diesen Sprung, Kriterium statt Ergebnis für die künftigen** | entscheidet den Fall, der ansteht, auf der Messung, die ihn trägt — und bindet den nächsten nur an eine **Prüfung**, nicht an ein Ergebnis; die Grenze zwischen Prozedur und Ist-Maßstab ist mitentschieden statt implizit | zwei Fassungen sind für die Dauer der Welle gleichzeitig relevant, und die Rollenverteilung muss man wissen; künftige Sprünge bekommen eine Pflicht (messen), keine Antwort |

## Konsequenzen

- **Positiv:** Die Wahl der normativen Quelle liegt auf Rang 4 der Source Precedence und überlebt
  die Welle, in deren Plan sie entstanden ist.
- **Positiv:** Die drei Durchgänge des Wellen-Closure-Kriteriums haben eine benannte, zitierte
  Quelle statt einer Plausibilität.
- **Positiv:** Die Grenze *Prozedur ≠ Ist-Maßstab* ist entschieden, bevor der erste Durchgang
  läuft. Ohne sie wäre der naheliegende Fehler, den Bestand gegen `v5.12.0` zu messen, obwohl das
  Repo `v3.5.2` adoptiert hat.
- **Negativ:** Die Migration läuft nach einem Text, den dieses Repo noch nicht adoptiert hat. Das
  ist unbequem und beabsichtigt; es verlangt von jedem Lauf, die Rollen der zwei Fassungen
  auseinanderzuhalten.
- **Negativ:** Künftige Sprünge erben eine **Pflicht ohne Antwort**. Wer den zweiten Fall aus
  Festlegung 3 trifft (beide Fassungen führen die Prozedur), findet hier kein Ergebnis, sondern
  eine Aufgabe. Der Preis für die Zurückhaltung ist Arbeit im nächsten Sprung.
- **Negativ / [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6):**
  **Kein Sensor.** Kein Gate liest, nach welcher Fassung ein Durchgang gelaufen ist. Träger sind
  der Zeiger im Wellenplan und der Review der Durchgangs-Ergebnisse.
- **Folgepflicht (Planner-Eigentum):** Der Wellenplan ersetzt seine Festlegung durch einen Zeiger
  auf diese ADR und behält nur, was Plan-Sache ist. Mit dem Retarget kommt hinzu: er nennt am
  2026-08-27 an **10** Stellen `v5.3.1`, seinen Titel eingeschlossen, und den beschlossenen
  Zielstand an **keiner**
  (`for t in 'v5\.3\.1' 'v5\.9\.0' 'v5\.12\.0'; do grep -c "$t" docs/plan/planning/welle-10-re-baseline.md; done`
  → **10 · 0 · 0**); die Zahlen **wandern** mit dem Plan und sind keine Erwartungswerte
  ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Dazu gehört seine Regel darüber, wann der Zielstand wandert: **dass** sie die Rollen
  im Repo bindet und nicht den Auftraggeber, steht in §*Wer den Zielstand bewegt*; wie ein Plan
  das formuliert, ist Plan-Sache. Das Nachziehen ist Planner-Sache. **Diese ADR ändert keine Datei
  außer sich selbst und dem ADR-Index.**
- **Folgepflicht (Adaptions-Durchgang):** Die
  [`MR-020`](../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)-Konstellation
  aus dem Kontext ist dort zu **entscheiden**, nicht zu übernehmen — Fortbestand, Carveout mit
  Auflösungs-Trigger oder ein anderer der fünf Ausgänge, mit Beleg. Ebenso, und vom bewegten
  Zielstand ausgelöst:
  [`MR-023`](../../../harness/conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung)
  misst den ersten Zweig von
  [`MR-022`](../../../harness/conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline)
  gegen `v5.3.1` vorab, und diese Vorab-Messung trägt bis zum Zielstand **nicht** —
  `templates/AGENTS.template.md` ist dorthin nicht byte-gleich
  (`git diff --shortstat v5.3.1 v5.12.0 -- lab/templates/AGENTS.template.md` → **1 Datei,
  +12/−6**), und §3.7 wächst dort um einen Absatz (*„Zustandsfelder ebenso"*), während Nummer,
  Titel, die fünf Klassen und die zwei Falsch/Richtig-Paare unverändert stehen. Ob der Zweig
  weiter zutrifft, misst der Durchgang gegen den Zielstand; **diese ADR entscheidet es nicht**
  (Festlegung 4).

## Fitness Function (falls maschinell prüfbar)

**Gebaut: keine.** Und das ist kein Versäumnis, sondern die Eigenschaft der Frage.

| Kandidat | Warum er die Regel nicht misst |
|---|---|
| `make baseline-verify` | belegt, **welcher Tag vendored** ist (genau einer, integer, vollständig — die Mechanik hinter [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)). Nach welcher Fassung ein Durchgang **gelaufen** ist, sieht er nicht |
| `make docs-check` | prüft Auflösbarkeit von Zielen und Ankern, nicht die Herkunft eines Verfahrens |

**Nicht mechanisierbar:** ob ein Durchgang der gewählten Prozedur *gefolgt* ist, ist ein Urteil
über einen Vorgang. Ein Sensor könnte allenfalls die **Zitat-Form** eines Belegs prüfen — das ist
die Fitness Function von [ADR-0016](0016-verweis-traegt-tag-und-zitat.md), nicht die dieser
Entscheidung. Prüfbar ist am Ende nur, ob **jeder Eintrag** einen Ausgang mit Beleg trägt
(Inventar gegen Abdeckung); das ist das Closure-Kriterium der Welle und misst die Vollständigkeit
des Durchgangs, nicht seine normative Quelle.

## Re-Evaluierungs-Trigger

- **Wenn ein künftiger Sprung ansteht** *(feedforward — die Messung aus Festlegung 3 läuft in
  jenem Sprung, kein Gate meldet sie)*: Führt die dann gepinnte Fassung die Migrations-Prozedur,
  greift der zweite Fall, und die Wahl ist neu zu begründen.
- **Wenn eine künftige Baseline die Frage selbst beantwortet** — eine Regel darüber, welche
  Fassung einen Wechsel regiert *(feedforward, Textänderung upstream)*: dann bindet sie unabhängig
  von ihrer Rezeption hier, und diese Entscheidung ist gegen den neuen Wortlaut neu zu begründen
  oder als Abweichung zu deklarieren.
- **Wenn die Ziel-Fassung während der laufenden Welle upstream wandert** *(der Zielstand ist
  beweglich: ihn bewegt eine Setzung des Auftraggebers oder ein gemessener Defekt im bisherigen
  Zielstand; ein neuer Tag allein löst den Review aus, der beides prüft — Kontext, §Wer den
  Zielstand bewegt)*: dann ist zu prüfen, ob die geänderte Prozedur die schon gelaufenen
  Durchgänge noch trägt — sonst verliert die Welle rückwirkend ihre Messlatte.
- **Wenn die Baseline aufhört, `<tag>`-gescopt zu liegen** *(feedforward)*: dann gibt es keine
  zwei nebeneinanderliegenden Fassungen mehr, und die Frage dieser ADR stellt sich anders. Zuerst
  ist [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
  neu zu entscheiden.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-09 | **Proposed** | Architect-Verdikt zur Frage, welche Regelwerks-Fassung die Re-Baseline `v3.5.2` → `v5.3.1` regiert. Die Festlegung stand bis dahin im Wellenplan der Re-Baseline und damit unter Planner-Eigentum auf Rang 5 der Source Precedence; Anlass war die Frage nach ihrem Urheber, die dort kein Gefäß hatte |
| 2026-08-22 | Zielstand auf `v5.9.0` gezogen, weiter **Proposed** | Entscheidung des Auftraggebers: die Re-Baseline zielt auf `v5.9.0` statt `v5.3.1`. Anlass ist der Stand upstream — `make baseline-freshness` meldet VERALTET, gepinnt `v3.5.2`, latest `v5.9.0` (die latest-Angabe **wandert** mit jedem Release und ist kein Erwartungswert, [`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2) — bei einem Aufpreis von rund einem Zehntel des Gesamt-Deltas (§*Der Zielstand ist … gezogen*). Die ADR steht auf *Proposed*; [`AGENTS.md`](../../../AGENTS.md) §3.4 bindet ab *Accepted*, weshalb hier retargetet und **keine** Folge-ADR geschrieben wird — später wäre dieselbe Bewegung eine Folge-ADR mit `Supersedes`. **Festlegung 3 gilt für diesen Lauf selbst:** ihr Kriterium hängt an der **gepinnten** Fassung, und die bleibt `v3.5.2` — ihr erster Fall greift unverändert, während die Ziel-Seite neu gemessen wurde, genau wie sie es verlangt. Der dritte Re-Evaluierungs-Trigger ist **nicht** gefeuert: er setzt eine laufende Welle voraus, und es ist kein Durchgang gelaufen — die Slices der Re-Baseline-Welle liegen sämtlich in `docs/plan/planning/open/`, rückwirkend verliert also keine Messlatte ihren Gegenstand. **Ziel-Aussagen sind gezogen, Mess-Zeitbezüge auf `v5.3.1` stehen geblieben** — eine Messung, die gegen `v5.3.1` lief, würde durch einen Tag-Tausch zu einem Lauf, den niemand gefahren hat |
| 2026-08-27 | Zielstand auf `v5.12.0` gezogen, weiter **Proposed** | Entscheidung des Auftraggebers: die Re-Baseline zielt auf `v5.12.0` statt `v5.9.0`. Der Aufpreis ist **10 Dateien, +172/−16** — rund **3,5 %** des Gesamt-Deltas, nach rund einem Zehntel beim Schritt davor —, und die Dateizahl des vendored Baums bleibt **26 + 25 = 51** (§*Der Zielstand ist … gezogen*; beide Angaben **wandern** mit dem Upstream-Stand und sind keine Erwartungswerte, [`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2). Die ADR steht auf *Proposed*; [`AGENTS.md`](../../../AGENTS.md) §3.4 bindet ab *Accepted*, weshalb hier retargetet und **keine** Folge-ADR geschrieben wird — später wäre dieselbe Bewegung eine Folge-ADR mit `Supersedes`. **Festlegung 1 ist unberührt:** ihre Quelle `modul-02-harness-bootstrap.md` ist zwischen `v5.9.0` und `v5.12.0` byte-gleich, womit sieben Eigenschaften und fünf Ausgänge unverändert tragen. **Erster Re-Evaluierungs-Trigger:** die **gepinnte** Fassung bleibt `v3.5.2`, der erste Fall von Festlegung 3 greift unverändert. **Zweiter:** nicht gefeuert — die dreizehn Suchbegriffe über die hinzugefügten Zeilen des Schritts finden **6** Zeilen, alle gelesen, keine eine Meta-Regel über die regierende Fassung. **Dritter:** nicht gefeuert — es ist kein Durchgang gelaufen, die sechs Slices der Re-Baseline-Welle liegen sämtlich in `docs/plan/planning/open/` (`find docs/plan/planning -name 'slice-08[0-5]-*' -path '*/open/*' | wc -l` → **6** von **6**). **Ziel-Aussagen sind gezogen, Mess-Zeitbezüge auf `v5.3.1` und `v5.9.0` stehen geblieben** — eine Messung, die gegen `v5.3.1` oder `v5.9.0` lief, würde durch einen Tag-Tausch zu einem Lauf, den niemand gefahren hat. **Anlass ist eine Setzung, kein gemessener Defekt** — was das für die Ziel-Regel des Wellenplans heißt, entscheidet §*Wer den Zielstand bewegt* |
