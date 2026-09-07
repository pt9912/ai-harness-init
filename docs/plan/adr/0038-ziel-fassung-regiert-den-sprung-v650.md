# ADR-0038: Die Ziel-Fassung regiert auch den Sprung `v6.0.0` → `v6.5.0`

**Status:** Proposed

**Datum:** 2026-09-07

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) (deren Festlegung 3 stellt das Kriterium;
diese Entscheidung **wendet es an**, statt es zu ändern — ihr zweiter Fall ist zum dritten Mal
eingetreten; ihre Festlegung 2 trennt Prozedur und Ist-Maßstab und trägt hier, weil der Tausch
noch aussteht),
[ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) (die Vorgänger-Entscheidung, ausdrücklich
auf den Sprung davor geschlossen; ihr erster Re-Evaluierungs-Trigger verlangt für diesen Sprung
die zweistufige Messung samt Netto-Frage, ihr zweiter ist gefeuert),
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (deren Festlegung 2 — Ort und
geschlossene Drei-Teil-Form einer Zielstand-Setzung — bleibt unberührt und bindet die Buchung, die
mit dem Baum-Tausch entsteht),
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) (die Wahl der normativen Quelle und der Ort
einer Norm-Buchung sind Architect-Sache),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (Form jedes Belegs in diesem Dokument),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (Festlegung 3 — die Slices
dieses Vorgangs stehen hier als Kennung ohne Pfad-Adresse),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl neben ihrem Kommando),
[`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(jede Baseline-Aussage nennt ihren Tag),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Tag ist die
Reproduzierbarkeits-Klammer; diese ADR entscheidet, welcher der beiden Tags während des Wechsels
das Verfahren stellt),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein Gate
liest, nach welcher Fassung ein Durchgang lief — hier so benannt)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie wählt die **normative Quelle eines Vorgangs**,
nicht den Inhalt eines Spec-Dokuments.

**Kopplung:** keine im Vollzug dieses Laufs. Eine Zielstand-Setzung wird nach
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2 in §Baseline von
`harness/conventions.md` gebucht, mit drei Teilen — Ziel-Tag und Datum, der Slice mit dem
Delta-Nachweis, sonst nichts. Für diesen Sprung existiert der dritte Teil noch nicht; die Buchung
entsteht mit dem Baum-Tausch, nicht hier. Die Datei ist Architect-Eigentum
([`AGENTS.md`](../../../AGENTS.md) §3.8).

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR).

---

## Kontext

[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 gibt für jeden künftigen
Sprung ein **Kriterium** statt eines Ergebnisses: gemessen wird, ob die **gepinnte** Fassung die
Migrations-Prozedur führt. Führt sie sie nicht, regiert die Ziel-Fassung ohne neue Abwägung;
**führen beide sie, ist die Wahl offen und in jenem Sprung begründet zu entscheiden.**
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) hat den zweiten Fall für
`v5.12.0` → `v5.18.0` entschieden, [ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) für
`v5.18.0` → `v6.0.0`. Beide sind auf ihren Sprung geschlossen. Für `v6.0.0` → `v6.5.0` verlangt
der erste Re-Evaluierungs-Trigger von
[ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) eine eigene Messung — *„beide Stufen, und
das Delegat-Delta **netto**"*. Die Abschnitte darunter fahren sie.

### Die Achse: vendored ist der `lab/`-Baum, nicht der Kurstext

Alle Messungen unten stehen auf einer Voraussetzung, die selbst gemessen ist: Der vendored Baum
**ist** `lab/regelwerk` + `lab/templates` des Kurs-Repos am jeweiligen Tag, byte-gleich. Wer statt
dessen `kurs/de` vergleicht, misst einen anderen Gegenstand. Gemessen am 2026-09-07 gegen den
lokalen Kurs-Klon — eine **Host-Voraussetzung**, kein Artefakt dieses Repos:

```sh
K=/Development/KI/ai-harness-course
mkdir -p /tmp/v600 && git -C "$K" archive v6.0.0 lab/regelwerk lab/templates \
  | tar -x -C /tmp/v600 --strip-components=1
mkdir -p /tmp/v650 && git -C "$K" archive v6.5.0 lab/regelwerk lab/templates \
  | tar -x -C /tmp/v650 --strip-components=1
diff -r -x SHA256SUMS .harness/baseline/v6.0.0 /tmp/v600   # -> leer
```

**Grenze, und sie ist die eigentliche Kostenstelle dieser Messung:** Die `v6.0.0`-Seite ist
netzlos aus dem Arbeitsbaum prüfbar, die `v6.5.0`-Seite nicht — jener Tag liegt in diesem Repo
nirgends. Jede Zahl unten, die `/tmp/v650` liest, ist gegen den Kurs-Klon erhoben und dort und nur
dort nachfahrbar; die Gegenprobe oben ist das einzige, was sie an den Arbeitsbaum bindet. **Keine
Erwartungswerte** ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Beträge wandern mit den Tags.

Der Sprung überspannt sechs Releases:

```sh
git -C "$K" diff --numstat v6.0.0 v6.5.0 -- lab/regelwerk lab/templates \
  | awk '{a+=$1;d+=$2;n++} END{printf "%d Dateien  +%d  -%d\n", n,a,d}'
# -> 32 Dateien  +624  -153
```

### Stufe (a) — die gepinnte Fassung führt die Prozedur

```sh
grep -c '^#### Freshness-Audit der vendored Baseline (Schritt 2)$' \
  .harness/baseline/v6.0.0/regelwerk/modul-02-harness-bootstrap.md   # -> 1
```

`v6.0.0`, `modul-02-harness-bootstrap.md`, §Freshness-Audit der vendored Baseline (Schritt 2)
führt den Audit mit sieben Eigenschaften, fünf Ausgängen im Adaptions-Durchgang und dem
Schlusssatz *„Ein neuer Tag löst einen Review aus (Re-Vendoring mit eigenem Diff), keinen stillen
Auto-Bump."* Damit greift **nicht** der erste Fall von
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 — der Fall, dessen tragendes
Argument *„die Wahl steht zwischen einem Verfahren und keinem"* lautet —, sondern zum dritten Mal
der zweite.

### Stufe (b) — der Abschnitt ist byte-gleich, und der Delegat mit dem Delta hat gewechselt

Der Abschnitt steht in beiden Fassungen Zeichen für Zeichen gleich da:

```sh
sed -n '/^#### Freshness-Audit/,/^#### Gate-Fragment/p' \
  .harness/baseline/v6.0.0/regelwerk/modul-02-harness-bootstrap.md > /tmp/fa-600
sed -n '/^#### Freshness-Audit/,/^#### Gate-Fragment/p' \
  /tmp/v650/regelwerk/modul-02-harness-bootstrap.md > /tmp/fa-650
wc -l /tmp/fa-600 /tmp/fa-650   # -> 123  123
diff /tmp/fa-600 /tmp/fa-650    # -> leer
grep -c '^\* \*\*' /tmp/fa-650  # -> 7   (die sieben Eigenschaften)
```

Er beantwortet nicht alles selbst: neun Verweise gehen in vier Dateien seines eigenen Baums,
ungleich verteilt.

```sh
grep -oE '\]\([a-z0-9-]+\.md[^)]*\)' /tmp/fa-650 | sort | uniq -c | sort -rn
# -> 3 grundlagen-harness-dateien.md#harnessconventionsmd-als-konventionsspeicher
#    2 modul-07-carveouts.md
#    1 modul-07-carveouts.md#werkzeug-wahl
#    1 modul-04-adrs.md
#    1 grundlagen-harness-dateien.md#harnessreadmemd-als-einstiegspunkt
#    1 grundlagen-bootstrap.md#modus-pro-sub-area-greenfield-vs-brownfield
```

Zwei der vier Zieldateien ändern eine Regel, zwei ändern keine — **netto**, also ohne die reine
Tabellenform (der Abschnitt darunter sagt, warum das nötig ist):

```sh
norm() { sed -E '/^\|/ s/[[:space:]]*\|[[:space:]]*/|/g' "$1"; }
for f in grundlagen-harness-dateien modul-07-carveouts modul-04-adrs grundlagen-bootstrap; do
  printf '%s: roh=%s netto=%s\n' "$f" \
    "$(diff ".harness/baseline/v6.0.0/regelwerk/$f.md" "/tmp/v650/regelwerk/$f.md" \
       | grep -c '^[<>]')" \
    "$(diff <(norm ".harness/baseline/v6.0.0/regelwerk/$f.md") \
            <(norm "/tmp/v650/regelwerk/$f.md") | grep -c '^[<>]')"
done
# -> grundlagen-harness-dateien: roh=137 netto=111
#    modul-07-carveouts:         roh=5   netto=3
#    modul-04-adrs:              roh=12  netto=0
#    grundlagen-bootstrap:       roh=36  netto=0
```

**Und die 111 liegen nicht dort, wo die zwei Vorgänger-Entscheidungen sie fanden.** In beiden
früheren Sprüngen trug §harness/conventions.md als Konventionsspeicher das Delta — die Sektion,
auf die drei der neun Verweise zeigen. Diesmal ist sie netto null, und das Delta sitzt in
§harness/README.md als Einstiegspunkt, auf die **ein** Verweis zeigt:

```sh
sec() { awk -v s="$2" '/^### /{p=index($0,s)>0} p' "$1"; }
for S in 'harness/README.md als Einstiegspunkt' \
         'harness/conventions.md als Konventionsspeicher' \
         'Was ein Kommentar' 'Verzeichniskonvention' 'Template-Schichtung' 'Konsumenten'; do
  printf '%-46s netto=%s\n' "$S" \
    "$(diff <(sec .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md "$S" \
              | sed -E '/^\|/ s/[[:space:]]*\|[[:space:]]*/|/g') \
            <(sec /tmp/v650/regelwerk/grundlagen-harness-dateien.md "$S" \
              | sed -E '/^\|/ s/[[:space:]]*\|[[:space:]]*/|/g') | grep -c '^[<>]')"
done
# -> harness/README.md als Einstiegspunkt           netto=109
#    harness/conventions.md als Konventionsspeicher netto=0
#    Was ein Kommentar                              netto=0
#    Verzeichniskonvention                          netto=2
#    Template-Schichtung                            netto=0
#    Konsumenten                                    netto=0
```

Die Häufigkeits-Begründung von [ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) — *„ihr
Delegat mit Delta ist der, auf den sie am häufigsten zeigt"* — trägt hier also **nicht**. Was
trägt, ist die delegierte **Frage**: `v6.5.0`, `modul-02-harness-bootstrap.md`, §Freshness-Audit
der vendored Baseline (Schritt 2) stellt sie wörtlich — *„Ob ein Feld Pflicht ist, entscheidet
nicht die Feldzahl im Template, sondern die Pflichtgliederung im vendored Regelwerk — für
harness/conventions.md in §Konventionsspeicher, für harness/README.md in §Einstiegspunkt."* Genau
diese Pflichtgliederung für `harness/README.md` ist gekippt: Ihre `## Sensors`-Zeile trägt in
`v6.5.0` eine zweite Kommentarzeile — *„Prosa je Gate unter harness/sensors/<target>.md"* —, und
die Sektion darunter führt die neue Artefakt-Klasse aus (`v6.5.0`,
`grundlagen-harness-dateien.md`, §harness/README.md als Einstiegspunkt: *„Ein Gate je Datei,
sobald sein Vertrag mehr braucht als einen Satz"*, mit der Abgrenzung *„Ob der Überhang schon
unter der Tabelle steht oder in die Zelle gedrängt wurde, ist dieselbe Sache — eine Zelle, die zum
Absatz geworden ist, ist der Fund, nicht die Ausnahme"*).

### Was das Messinstrument diesmal mitzählt — die Tabellenform, nicht der Herkunfts-Kommentar

[ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) misst als Rauschquelle den
Herkunfts-Kommentar `<!-- Quelle: … -->` des vendored Baums. Der trägt in diesem Sprung **null**
— beide Seiten sind derselbe Upstream-Baum, sein Ziel hat sich nicht bewegt:

```sh
for f in grundlagen-harness-dateien modul-07-carveouts modul-04-adrs grundlagen-bootstrap; do
  printf '%s: %s\n' "$f" \
    "$(diff ".harness/baseline/v6.0.0/regelwerk/$f.md" "/tmp/v650/regelwerk/$f.md" \
       | grep -c '^[<>].*<!-- Quelle:')"
done
# -> alle vier: 0
```

An seine Stelle tritt eine andere: `v6.5.0` normalisiert die Markdown-Tabellen des ganzen Baums.
Über den letzten Release-Schritt gemessen — 17 der 25 berührten Dateien ändern **nur** die
Tabellenform:

```sh
mkdir -p /tmp/v640 && git -C "$K" archive v6.4.0 lab/regelwerk lab/templates \
  | tar -x -C /tmp/v640 --strip-components=1
n=0
for f in $(git -C "$K" diff --name-only v6.4.0 v6.5.0 -- lab/regelwerk lab/templates); do
  g="${f#lab/}"
  diff <(sed -E '/^\|/ s/[[:space:]]*\|[[:space:]]*/|/g' "/tmp/v640/$g") \
       <(sed -E '/^\|/ s/[[:space:]]*\|[[:space:]]*/|/g' "/tmp/v650/$g") >/dev/null && n=$((n+1))
done
echo "$n"                                                                        # -> 17
git -C "$K" diff --name-only v6.4.0 v6.5.0 -- lab/regelwerk lab/templates | wc -l  # -> 25
```

**Was daraus folgt und was nicht.** Die Netto-Rechnung von
[ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) bleibt richtig und ist hier
gegenstandslos; die Klasse, die sie beschreibt, ist nicht die einzige ihrer Art. Eine allgemeine
Rausch-Regel entsteht daraus **nicht** — welche Klassen ein Zeilen-Diff über zwei Baseline-Bäume
mitzählt, hängt am jeweiligen Upstream-Vorgang und ist je Sprung zu messen.

### Die Zwei-Fassungen-Phase lebt — anders als in den zwei Sprüngen davor

```sh
ls -1 .harness/baseline/   # -> v6.0.0
```

Gemessen am 2026-09-07 trägt der Arbeitsbaum `v6.0.0`, und der Baum-Tausch steht als `slice-193`
noch aus. Damit ist der **zweite** tragende Grund von
[ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) — *„Die gepinnte Fassung liegt nicht mehr
vendored"* — hier nicht verfügbar; ihr zweiter Re-Evaluierungs-Trigger ist gefeuert und verweist
für diesen Fall auf den ersten Grund allein. Die Lage ist die von
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 2: Prozedur und Ist-Maßstab sind
während des Wechsels zwei verschiedene Fassungen, und bis der Baum getauscht ist, bleibt `v6.0.0`
für **jede Konformitäts-Frage** maßgeblich.

### Die Wirkung ist am Bestand ablesbar

Gemessen am 2026-09-07 trägt der Einstiegspunkt dieses Repos eine Sensors-Sektion, die zu vier
Fünfteln aus Prosa besteht, und das Verzeichnis, das die Ziel-Fassung dafür vorsieht, existiert
nicht:

```sh
awk '/^## Sensors/{p=1} /^## Traceability/{p=0} p' harness/README.md | wc -l           # -> 80
awk '/^## Sensors/{p=1} /^## Traceability/{p=0} p' harness/README.md | grep -c '^|'    # -> 13
ls -d harness/sensors 2>/dev/null | wc -l                                              # ->  0
```

Ein Durchgang nach der gepinnten Fassung liest diese Stelle grün — deren Pflichtgliederung kennt
die Klasse nicht. Ein Durchgang nach der Ziel-Fassung findet sie. Das ist die Wahl in einem Satz,
und sie ist dieselbe Bauart wie in den zwei Sprüngen davor, nur an einer anderen Sektion und für
eine andere Datei.

### Auch `v6.5.0` beantwortet die Frage dieser ADR nicht

Der dritte Re-Evaluierungs-Trigger von
[ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) fragt, ob eine künftige Baseline die
Meta-Frage selbst beantwortet. Geprüft über die hinzugefügten Zeilen, mit denselben dreizehn
Suchbegriffen:

```sh
diff -ruN -x SHA256SUMS .harness/baseline/v6.0.0 /tmp/v650 | grep '^+' | grep -cE \
  'welche Fassung|maßgeblich|regiert|gepinnte Fassung|alte Fassung|Prozedur|Migration|Re-Vendor|Bump|adoptiert|Adoption|Übergang|Reihenfolge des Wechsels'
# -> 13
```

**Dreizehn Zeilen, alle gelesen.** Sie sprechen von Glossar-Einträgen (Konventionsspeicher, Change
Request, Brownfield, Acceptance-Trigger, DoD), von der Kennung-statt-Adresse-Regel und ihrer
eigenen Begründung, und von Ausfüll-Hinweisen in Vorlagen. Eine Meta-Regel darüber, welche Fassung
einen Wechsel regiert, ist nicht darunter — der Trigger ist **nicht** gefeuert. **Grenze**,
unverändert die der Vorgänger: ein Negativ aus dreizehn aufgezählten Zeichenketten; eine Regel
ohne eines dieser Wörter wäre nicht gefunden worden.

## Entscheidung

**Eine Festlegung.**

**Für den Sprung `v6.0.0` → `v6.5.0` regiert die Prozedur der Ziel-Fassung `v6.5.0`**
(`v6.5.0`, `modul-02-harness-bootstrap.md`, §Freshness-Audit der vendored Baseline (Schritt 2)) —
mit ihren sieben Eigenschaften, ihren fünf Ausgängen und den Abschnitten, in die sie delegiert.

Tragend ist **ein** gemessener Grund, nicht zwei:

**Die Prozedur ist nicht abgeschlossen, und der Delegat, der ihre Form-Frage für
`harness/README.md` beantwortet, ändert die Pflichtgliederung.** §harness/README.md als
Einstiegspunkt gewinnt netto 109 Zeilen und eine neue Artefakt-Klasse, die in der
Pflichtgliederung selbst steht. Die Wahl entscheidet damit, gegen welche Pflichtgliederung der
Form-Vergleich misst — am Bestand dieses Repos an einer Stelle ablesbar, die heute keine Entsprechung
hat.

Der zweite Grund aus [ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) — die gepinnte
Fassung liege nicht mehr vendored — steht hier **nicht** zur Verfügung und wird ausdrücklich nicht
in Anspruch genommen: Der Tausch steht aus, `v6.0.0` liegt im Baum, und
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 2 hält es als Ist-Maßstab bis
dahin ausdrücklich in Kraft.

**Was diese Festlegung nicht tut.**

- **Kein `Supersedes`.** An [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) ändert sie
  nichts: Deren Festlegung 3 ist so gebaut, dass jeder Sprung sie **erfüllt** statt sie zu
  ersetzen. An [ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) und
  [ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) ebenfalls nichts: Beide
  bleiben für ihren Sprung wahr, und Festlegung 2 der letzteren gilt unverändert.
- **Keine allgemeine Regel.** *„Es regiert stets die Ziel-Fassung"* entsteht hier ausdrücklich
  nicht; sie bleibt verworfen ([ADR-0018](0018-ziel-fassung-regiert-die-migration.md)
  §Verglichene Alternativen, Option C), und der nächste Sprung misst erneut — beide Stufen.
- **Sie deutet die fünf Ausgänge nicht** und entscheidet keinen einzelnen Eintrag des
  Adaptions-Blocks. Beides bleibt bei
  [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 4.
- **Sie inventarisiert das Delta nicht.** Welche Regel des Sprungs welchen Eintrag, welches
  Artefakt und welchen Sensor dieses Repos trifft, ist Gegenstand des Durchgangs, nicht dieser
  Entscheidung.

### Was diese Festlegung nicht entscheidet — die Frage nach §3.11 ¶1 und den Rollen-Reports

**Die Ziel-Fassung wirft diese Frage auf; sie beantwortet sie nicht, und sie gehört in eine eigene
ADR.** `v6.5.0` schließt die **Zugehörigkeits**-Hälfte: `grundlagen-harness-dateien.md`,
§harness/README.md als Einstiegspunkt nennt die einfrierende Klasse namentlich — *„Einfrierend
sind die Zeitdokumente — Review-Report, Closure-Notiz, Archiv-Stub, Accepted-ADR, geschlossener
Slice"* — und legt für **neue** Instanzen einen Träger in vier Vorlagen ab, deren Zitier-Form-Block
sich selbst als *„bleibt stehen — Norm, kein Ausfüll-Hinweis"* ausweist. Beides bestätigt, was
[`AGENTS.md`](../../../AGENTS.md) §3.11 ¶1 mit *„ein Rollen-Report"* bereits sagt. Offen bleibt die
**Träger**-Hälfte am Bestand dieses Repos, und sie ist eine Abwägung mit eigenen Optionen: Zwei
Artefakte sagen über denselben Baum Gegenteiliges — `exempt-paths` im `codepaths`-Block von
[`.d-check.yml`](../../../.d-check.yml) nimmt `docs/reviews/**` aus, `make slice-mv` zieht die
Verweise ebendort nach. Die Ziel-Fassung **charakterisiert** die Ausnahme (*„ein Ausnahme-Ventil im
Prüfbereich, also eine Gate-Senkung mit eigener Begründungslast"*), sie wählt nicht zwischen ihr
und ihrem Wegfall — und nach [`AGENTS.md`](../../../AGENTS.md) §3.5 ist die Senkung selbst ein
ADR-Gegenstand. Der Gegenstand dieser ADR hier ist die normative Quelle eines Vorgangs; jener ist
ein Ventil gegen einen Nachzug. Zwei Gegenstände, zwei Entscheidungen. Die Folgepflicht unten
benennt sie.

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`. Sie wird `Accepted`, **wenn eine Reviewer-Runde sie gegen
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md),
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) und
[ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) auf Konsistenz geprüft hat und ihr Report
ohne blockierenden Befund in `docs/reviews/` liegt** — die Aufteilung, die das Baseline-Regelwerk
`modul-08-agentenrollen.md` §Rollen-Regeln verbatim vorschreibt: *„ADR-Änderung: Architect
schreibt; Reviewer prüft auf Konsistenz; Implementer liest als Constraint"*.

Bis dahin ist sie ein Architect-Verdikt und als solches das Übergabe-Artefakt, das der Schnitt von
`slice-193` als Constraint liest; sie ist nicht eingefroren
([`AGENTS.md`](../../../AGENTS.md) §3.4 bindet ab `Accepted`).

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts entscheiden, die Wahl fällt faktisch beim ersten Durchgang | kein Aufwand; der Abschnitt ist byte-gleich, also „egal" | *egal* ist gemessen falsch: die Prozedur delegiert, und einer der Delegate ändert die Pflichtgliederung, die sie abfragt. [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 verlangt für diesen Fall ausdrücklich eine Begründung; sie zu unterlassen hieße, ihr drittes Anwendungsereignis auszulassen. Und der Schnitt von `slice-193` wäre blockiert: er braucht eine entschiedene normative Quelle |
| B — die gepinnte Fassung `v6.0.0` regiert | sie liegt im Baum und ist netzlos lesbar — anders als in den zwei Sprüngen davor ist das hier ein echtes Argument; sie ist zudem bis zum Tausch der Ist-Maßstab | ihre Pflichtgliederung für `harness/README.md` kennt die Sensor-Datei-Klasse nicht; ein Form-Vergleich nach B liest die 80-Zeilen-Sektion des Einstiegspunkts grün und fordert die Auflösung nie. Der Ist-Maßstab bleibt davon unberührt — [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 2 trennt ihn von der Prozedur, und B verwechselt beide |
| C — allgemeine Regel *„stets die Ziel-Fassung"*, in Ablösung von [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 | jeder künftige Sprung startet ohne Vorlauf; die Messung entfiele | dort verworfen und hier unverändert gültig: sie bände Prozeduren, deren Wortlaut niemand kennt, und wäre der stille Auto-Bump eine Ebene höher — den **beide** Fassungen wortgleich verbieten. Dieser Sprung ist zudem ihr Gegenbeispiel: Der Delegat mit dem Delta hat gewechselt, was eine Blankett-Regel nie bemerkt hätte. Zusätzlich verlangte sie ein `Supersedes` auf eine ADR, auf die 73 Verweis-Vorkommen aus 14 lebenden Dateien zeigen (`git grep -oE '\]\([^)]*0018-ziel-fassung-regiert-die-migration\.md[^)]*\)' -- ':!docs/reviews' ':!docs/plan/planning/done' \| wc -l`, dazu dieselbe Abfrage mit `-l`; beide wandern und sind keine Erwartungswerte, [`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2), und `matrix.status` in [`.d-check.yml`](../../../.d-check.yml) verbietet Verweise auf superseded ADRs |
| D — die Prozedur aus der Ziel-Fassung, die Delegate aus der gepinnten | nähme den Text, der die Frage stellt, und ließe die Antworten in dem Baum, der netzlos vorliegt | der Abschnitt adressiert seine Delegate **relativ im eigenen Baum**; die Aufteilung stünde in keiner Fassung und wäre eine Erfindung dieses Repos — derselbe Fehler wie Option D in [ADR-0018](0018-ziel-fassung-regiert-die-migration.md). Und sie hätte genau die Wirkung von B, denn das Delta liegt vollständig in einem Delegat |
| E — Übernahme der Begründung von [ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) statt eigener Messung | die Bauart ist dieselbe, das Ergebnis wäre dasselbe | zwei ihrer drei Stützen sind hier gemessen falsch: Der Delegat mit dem Delta ist ein anderer, und die gepinnte Fassung liegt sehr wohl noch vendored. Ein abgeschriebener Grund hätte beide Unterschiede verdeckt — und der erste Re-Evaluierungs-Trigger jener ADR verlangt genau diese Messung |
| **F — gewählt: Ziel-Fassung für diesen Sprung, auf einer für dieses Fassungspaar gefahrenen Messung** | entscheidet den anstehenden Fall auf Gründen, die hier gemessen sind — Delegat-Verteilung, Netto-Delta je Delegat und je Sektion, die Tabellenform als neue Rauschklasse, der ausstehende Tausch —, und trägt auf **einem** Grund statt auf zweien, weil der zweite hier nachweislich fehlt; das Kriterium aus [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) bleibt für den nächsten Sprung unangetastet | der nächste Sprung erbt dieselbe Pflicht ein viertes Mal; die Messung ist gewachsen (Achse, beide Stufen, Netto, Sektions-Ebene); und die `v6.5.0`-Seite ist bis zum Tausch nur am Kurs-Klon nachfahrbar |

## Konsequenzen

- **Positiv:** Der Schnitt von `slice-193` und der Adaptions-Durchgang danach haben eine benannte,
  zitierte Quelle, bevor das erste Konformitäts-Urteil fällt.
- **Positiv:** Die Vendoring-**Achse** ist gemessen und steht als Voraussetzung über allen Zahlen:
  vendored ist `lab/`, nicht der Kurstext. Wer künftig gegen `kurs/de` misst, hat die Gegenprobe
  hier stehen.
- **Positiv:** *Byte-gleich* ist zum dritten Mal entkräftet, und diesmal an einem **anderen**
  Delegaten als bei den Vorgängern. Die Lesart *„es ist immer der Konventionsspeicher"* ist damit
  widerlegt, bevor sie zur Abkürzung werden konnte.
- **Positiv:** Die Netto-Frage hat eine zweite Rauschklasse — die Tabellenform —, und sie ist
  beziffert. Ein Roh-Diff über diesen Sprung überschätzt das Regel-Delta in drei der vier
  Delegate.
- **Negativ:** Die Wahl gilt für diesen Sprung und für keinen weiteren. Der nächste erbt die
  Messpflicht, inzwischen um die Achsen- und die Sektions-Ebene gewachsen.
- **Negativ:** Diese Entscheidung trägt auf **einem** Grund. Fiele der Delegat-Delta-Befund weg,
  bliebe nichts — anders als bei den zwei Vorgängern, die einen zweiten hatten.
- **Negativ:** Bis zum Tausch ist die regierende Fassung nicht im Arbeitsbaum. Ein netzloser Lauf
  kann die Prozedur, nach der er arbeiten soll, nicht öffnen; er ist auf den Kurs-Klon oder auf
  diese ADR angewiesen. Das ist die Kehrseite von
  [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 2 und wird hier nicht geheilt.
- **Negativ / [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6):**
  **Kein Sensor.** Kein Gate liest, nach welcher Fassung ein Durchgang lief. Träger ist der Zeiger
  in §Baseline von `harness/conventions.md` und der Review des Durchgangs-Ergebnisses.
- **Folgepflicht (Architect), fällig mit dem Baum-Tausch:** §Baseline von
  `harness/conventions.md` bekommt die Buchung der Zielstand-Setzung in der Drei-Teil-Form von
  [ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2 und zeigt für
  die regierende Fassung dieses Sprungs hierher. Sie entsteht dort, nicht hier: Ihr dritter Teil —
  der Slice mit dem Delta-Nachweis — existiert zum Zeitpunkt dieser Entscheidung nicht.
- **Folgepflicht (Architect), fällig mit der Annahme dieser ADR:** eine eigene Entscheidung über
  den Träger von [`AGENTS.md`](../../../AGENTS.md) §3.11 ¶1 für Rollen-Reports und über das
  Verhältnis der `exempt-paths`-Ausnahme zum Nachzug durch `make slice-mv`. Sie ist durch die
  Ziel-Fassung fällig geworden und in dieser ADR ausdrücklich nicht entschieden.
- **Darüber hinaus ändert diese ADR keine Datei außer sich selbst und dem ADR-Index.**

## Fitness Function (falls maschinell prüfbar)

**Gebaut: keine** — und das ist die Eigenschaft der Frage, nicht ein Versäumnis.

| Kandidat | Warum er die Regel nicht misst |
|---|---|
| `make baseline-verify` | belegt, **welcher Tag vendored** ist (genau einer, integer, vollständig). Nach welcher Fassung ein Durchgang **gelaufen** ist, sieht er nicht |
| `make docs-check` | prüft Auflösbarkeit von Zielen und Ankern, nicht die Herkunft eines Verfahrens |
| `make comment-claims` | hat keine Markdown-Datei im Prüfbereich |
| `make regelwerk-check` | hält den gepinnten Tag gegen sein Release-Asset (Netz, nicht in `make gates`) — eine Aussage über **einen** Tag, keine über die Wahl zwischen zweien |

**Nicht mechanisierbar:** ob ein Durchgang der gewählten Prozedur *gefolgt* ist, ist ein Urteil
über einen Vorgang — dieselbe Grenze, die
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md),
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) und
[ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) für sich benennen.

**Teilweise mechanisierbar, hier nicht gebaut:** die Netto-Rechnung ist ein Muster — ein
Zeilen-Diff über zwei Baseline-Bäume, abzüglich der Zeilen, die nur die Tabellenform ändern. Sie
setzt jedoch beide Bäume voraus, und der zweite liegt bis zum Tausch nicht im Repo; ein Sensor
darüber wäre netz- oder klon-abhängig. Ihn hier als vorhanden auszugeben wäre
[`AGENTS.md`](../../../AGENTS.md) §3.1 eine Ebene tiefer.

## Re-Evaluierungs-Trigger

- **Wenn der nächste Sprung ansteht** *(feedforward — die Messung aus
  [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 läuft in jenem Sprung, kein
  Gate meldet sie)*: Diese Festlegung gilt **nur** für `v6.0.0` → `v6.5.0`. Der nächste Sprung
  misst neu — die Achse, beide Stufen, und das Delegat-Delta netto **je Sektion**, weil die
  Datei-Ebene hier zu grob gewesen wäre.
- **Wenn ein Sprung sein Delegat-Delta ausschließlich in Sektionen trägt, in die der
  Freshness-Audit nicht delegiert** *(beobachtbar am Sektions-Netto-Diff der vier Zieldateien)*:
  dann trägt der einzige Grund dieser Entscheidung nicht, und der Fall braucht eine eigene
  Begründung — diese ADR liefert sie nicht.
- **Wenn der Baum vor dem Schnitt des Durchgangs getauscht wird** *(beobachtbar an
  `ls -1 .harness/baseline/`)*: dann endet die Zwei-Fassungen-Phase, der Contra-Punkt von Option B
  und die dritte Negativ-Konsequenz oben entfallen — am Ergebnis ändert das nichts, wohl aber an
  der Begründungslast eines künftigen Sprungs, der in derselben Lage steht.
- **Wenn ein künftiger Upstream-Vorgang eine dritte Rauschklasse einführt** *(beobachtbar daran,
  dass die Zahl der nur-Tabellenform-Dateien den Netto-Diff nicht mehr erklärt)*: dann ist die
  Netto-Rechnung um sie zu erweitern, bevor ein Delegat-Delta als Regel-Delta gilt.
- **Wenn eine künftige Baseline die Meta-Frage selbst beantwortet** *(feedforward, Textänderung
  upstream)*: dann bindet sie unabhängig von ihrer Rezeption hier, und diese Festlegung ist gegen
  den neuen Wortlaut neu zu begründen oder als Abweichung zu deklarieren.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-07 | **Proposed** | Architect-Lauf vor dem Schnitt von `slice-193`. Anlass ist der dritte Eintritt des zweiten Falls aus [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 und der erste Re-Evaluierungs-Trigger von [ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md), der für diesen Sprung eine eigene zweistufige Messung samt Netto-Frage verlangt |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0038` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
