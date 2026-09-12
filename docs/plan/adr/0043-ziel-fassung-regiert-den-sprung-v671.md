# ADR-0043: Die Ziel-Fassung regiert auch den Sprung `v6.5.0` → `v6.7.1`, und der Durchgang misst ab dem Stand, gegen den zuletzt einer lief

**Status:** Accepted

**Datum:** 2026-09-12

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) (deren Festlegung 3 stellt das Kriterium;
diese Entscheidung **wendet es an**, statt es zu ändern — ihr zweiter Fall ist zum vierten Mal
eingetreten; ihre Festlegung 2 trennt Prozedur und Ist-Maßstab und trägt hier, weil der Tausch
noch aussteht),
[ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) (die Vorgänger-Entscheidung, ausdrücklich
auf den Sprung davor geschlossen; ihr erster Re-Evaluierungs-Trigger verlangt für diesen Sprung
die Messung von Achse, beiden Stufen und Netto-Delta **je Sektion**, ihr vierter fragt nach einer
dritten Rauschklasse),
[ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) (die Netto-Frage und die
Herkunfts-Kommentar-Rauschklasse stammen von dort),
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (deren Festlegung 2 — Ort und
geschlossene Drei-Teil-Form einer Zielstand-Setzung — bleibt unberührt und bindet die Buchung, die
mit dieser Entscheidung und später mit dem Vollzug entsteht),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (der Accept-Übergang dieser
Datei nennt den Beleg, den ihr Acceptance-Trigger verlangt; deren Festlegung 2 schließt die
Nachmessung desselben Kontexts als Beleg aus),
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) (die Wahl der normativen Quelle und der Ort
einer Norm-Buchung sind Architect-Sache),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (Form jedes Belegs in diesem Dokument),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (Festlegung 3 — die Slices
dieses Vorgangs stehen hier als Kennung ohne Pfad-Adresse),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl neben ihrem Kommando),
[`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(jede Baseline-Aussage nennt ihren Tag),
[`MR-054`](../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
(die Modul-Zusammensetzung der emittierten Doc-Gate-Startkonfiguration hat einen eigenen Träger;
diese Entscheidung greift ihr nicht vor),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Tag ist die
Reproduzierbarkeits-Klammer; diese ADR entscheidet, welcher der beiden Tags während des Wechsels
das Verfahren stellt),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein Gate
liest, nach welcher Fassung ein Durchgang lief, und keines liest, ab welchem Stand er misst — hier
so benannt)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie wählt die **normative Quelle eines Vorgangs**
und die **Basis seiner Messung**, nicht den Inhalt eines Spec-Dokuments.

**Kopplung:** §Baseline von `harness/conventions.md` — dort ist die Zielstand-Setzung auf `v6.7.1`
verbucht, und dort steht der Zeiger auf diese Entscheidung als regierende Fassung des Sprungs. Der
**Ort** ist der von [ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
Festlegung 2; deren geschlossene Drei-Teil-Form gilt der Buchung des **Vollzugs**, und die entsteht
mit dem Baum-Tausch, nicht hier — ihr zweiter Teil, der Slice mit dem Delta-Nachweis, existiert
noch nicht. Die Datei ist Architect-Eigentum ([`AGENTS.md`](../../../AGENTS.md) §3.8).

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR).

---

## Kontext

[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 gibt für jeden künftigen
Sprung ein **Kriterium** statt eines Ergebnisses: gemessen wird, ob die **gepinnte** Fassung die
Migrations-Prozedur führt. Führt sie sie nicht, regiert die Ziel-Fassung ohne neue Abwägung;
**führen beide sie, ist die Wahl offen und in jenem Sprung begründet zu entscheiden.** Den zweiten
Fall haben [ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) für
`v5.12.0` → `v5.18.0`, [ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) für
`v5.18.0` → `v6.0.0` und [ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) für
`v6.0.0` → `v6.5.0` entschieden. Alle drei sind auf ihren Sprung geschlossen.

**Der Zielstand steht, und er ist gesetzt, nicht abgeleitet:** Der Auftraggeber hat ihn am
2026-09-12 auf `v6.7.1` gezogen — der Akt, den
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) §Wer den Zielstand bewegt ihm vorbehält,
weil kein Lauf im Repo den Zielstand einer Release-Liste nachführen darf. Diese Entscheidung wählt
nicht **ob** dorthin gesprungen wird, sondern nach welcher Fassung — und, neu, **ab welchem Stand**
der Durchgang misst.

### Die Achse ist nicht mehr die von ADR-0038 — der vendored Baum ist das Release-Asset

[ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) §Die Achse stellt fest, der vendored Baum
**sei** `lab/regelwerk` + `lab/templates` des Kurs-Repos am Tag, byte-gleich, und belegt das für
`v6.0.0`. Für den heute gepinnten Stand gilt das **nicht mehr**. Gemessen am 2026-09-12 gegen den
lokalen Kurs-Klon — eine **Host-Voraussetzung**, kein Artefakt dieses Repos:

```sh
K=/Development/KI/ai-harness-course
mkdir -p /tmp/v650 && git -C "$K" archive v6.5.0 lab/regelwerk lab/templates \
  | tar -x -C /tmp/v650 --strip-components=1
diff -rq -x SHA256SUMS .harness/baseline/v6.5.0 /tmp/v650 | wc -l                       # -> 28
diff -r  -x SHA256SUMS .harness/baseline/v6.5.0 /tmp/v650 | grep -c '^[<>]'             # -> 58
diff -r  -x SHA256SUMS .harness/baseline/v6.5.0 /tmp/v650 | grep '^[<>]' \
  | grep -v 'github\.com/pt9912/ai-harness-course' | grep -vE '\.\./\.\./' | wc -l      # ->  0
```

**28 Dateien, 58 Zeilen, und keine davon außerhalb einer Klasse:** Der vendored Baum entsteht seit
`v6.5.0` aus dem **Release-Asset** (`make vendor-baseline`), und das Asset trägt die
`<!-- Quelle: … -->`-Ziele sowie zwei Download-URLs `<tag>`-gescopt, wo der `git`-Baum relative
Pfade bzw. `releases/latest/…` führt. Dieselbe Zahl **28** führt
[`harness/README.md`](../../../harness/README.md) §vendor-baseline als Anlass jenes Ziels; sie ist
hier unabhängig nachgefahren, nicht von dort übernommen. **Keine Erwartungswerte**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Beträge wandern mit den Tags.

**Was daraus für jede Zahl unten folgt:** Beide Seiten werden aus **derselben** Quelle gezogen —
`git archive` über beide Tags —, damit die Asset-Umschrift sich aufhebt. Wer die vendored Seite
gegen eine `git`-Seite hält, bekommt 58 Zeilen geschenkt, die keine Regel bewegen. **Grenze — die
Kostenstelle dieser Messung:** Keine Seite dieses Vergleichs liegt netzlos im Arbeitsbaum; beide
kommen aus dem Kurs-Klon. Die `v6.5.0`-Seite ist über die Gegenprobe oben an den Arbeitsbaum
gebunden, die `v6.7.1`-Seite an nichts als den Klon.

### Der Sprung überspannt drei Releases, davon zwei übersprungene

```sh
git -C "$K" log --oneline --decorate v6.5.0..v6.7.1
# -> b9baaad (tag: v6.7.1) feat(docs+regelwerk): Welle 133 - Linkerhalt bei Operation 3 (Anbinden)
#    cbe9edf docs(roadmap): Meilenstein v6.7.0 mit Beleg eintragen
#    4256bb2 (tag: v6.7.0) feat(kurs+regelwerk+templates): Welle 132 - Plan vor Code bindet an Akzeptanzkriterien
#    80b0968 feat(kurs+regelwerk+templates+example+lab+docs): Wellen 130-131 - Welle- und Slice-Kennungen sind Namen
#    4822b35 docs(roadmap): Meilenstein v6.6.0 mit Belegen eintragen
#    da689a0 (tag: v6.6.0) feat(kurs+regelwerk+templates+example+lab+ci): Welle 129 — Der Gate-Index steht einmal
#    ac94c33 docs(roadmap): Meilensteine v6.4.0 und v6.5.0 mit Belegen eintragen
```

**Vier Wellen-Commits tragen fünf Wellen** — 129, das Paar 130–131 in *einem* Commit, 132 und 133
—, und sie verteilen sich auf drei Releases. **`v6.6.0` und `v6.7.0` werden übersprungen**, nicht
eines: Der gesetzte Zielstand ist `v6.7.1`. Der Umfang des Sprungs selbst ist dagegen klein:

```sh
git -C "$K" diff --numstat v6.5.0 v6.7.1 -- lab/regelwerk lab/templates \
  | awk '{a+=$1;d+=$2;n++} END{printf "%d Dateien  +%d  -%d\n", n,a,d}'
# -> 33 Dateien  +289  -260
```

### Stufe (a) — die gepinnte Fassung führt die Prozedur

```sh
grep -c '^#### Freshness-Audit der vendored Baseline (Schritt 2)$' \
  .harness/baseline/v6.5.0/regelwerk/modul-02-harness-bootstrap.md   # -> 1
```

`v6.5.0`, `modul-02-harness-bootstrap.md`, §Freshness-Audit der vendored Baseline (Schritt 2)
führt den Audit mit sieben Eigenschaften, fünf Ausgängen im Adaptions-Durchgang und dem
Schlusssatz *„Ein neuer Tag löst einen **Review** aus (Re-Vendoring mit eigenem Diff), keinen
stillen Auto-Bump."* Damit greift **nicht** der erste Fall von
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 — der Fall, dessen tragendes
Argument *„die Wahl steht zwischen einem Verfahren und keinem"* lautet —, sondern zum vierten Mal
der zweite. Die Ziel-Fassung führt ihn ebenso
(`grep -c` wie oben gegen `lab/regelwerk/modul-02-harness-bootstrap.md` des Klons am Tag `v6.7.1`
→ **1**).

### Stufe (b) — der Abschnitt ist zum vierten Mal byte-gleich

```sh
mkdir -p /tmp/v671 && git -C "$K" archive v6.7.1 lab/regelwerk lab/templates \
  | tar -x -C /tmp/v671 --strip-components=1
sed -n '/^#### Freshness-Audit/,/^#### Gate-Fragment/p' \
  /tmp/v650/regelwerk/modul-02-harness-bootstrap.md > /tmp/fa-650
sed -n '/^#### Freshness-Audit/,/^#### Gate-Fragment/p' \
  /tmp/v671/regelwerk/modul-02-harness-bootstrap.md > /tmp/fa-671
wc -l /tmp/fa-650 /tmp/fa-671   # -> 123  123
diff /tmp/fa-650 /tmp/fa-671    # -> leer
grep -c '^\* \*\*' /tmp/fa-671  # -> 7   (die sieben Eigenschaften)
```

Er beantwortet nicht alles selbst: neun Verweise gehen in vier Dateien seines eigenen Baums,
unverändert ungleich verteilt.

```sh
grep -oE '\]\([a-z0-9-]+\.md[^)]*\)' /tmp/fa-671 | sort | uniq -c | sort -rn
# -> 3 grundlagen-harness-dateien.md#harnessconventionsmd-als-konventionsspeicher
#    2 modul-07-carveouts.md
#    1 modul-07-carveouts.md#werkzeug-wahl
#    1 modul-04-adrs.md
#    1 grundlagen-harness-dateien.md#harnessreadmemd-als-einstiegspunkt
#    1 grundlagen-bootstrap.md#modus-pro-sub-area-greenfield-vs-brownfield
```

Zwei der vier Zieldateien ändern etwas, zwei nichts — **roh und netto identisch**, also ohne
Abzug (der Abschnitt §Rauschklassen unten sagt, warum hier keiner nötig ist):

```sh
norm() { sed -E '/^\|/ s/[[:space:]]*\|[[:space:]]*/|/g' "$1"; }
for f in grundlagen-harness-dateien modul-07-carveouts modul-04-adrs grundlagen-bootstrap; do
  printf '%-28s roh=%-4s netto=%-4s quelle=%s\n' "$f" \
    "$(diff "/tmp/v650/regelwerk/$f.md" "/tmp/v671/regelwerk/$f.md" | grep -c '^[<>]')" \
    "$(diff <(norm "/tmp/v650/regelwerk/$f.md") <(norm "/tmp/v671/regelwerk/$f.md") \
       | grep -c '^[<>]')" \
    "$(diff "/tmp/v650/regelwerk/$f.md" "/tmp/v671/regelwerk/$f.md" \
       | grep -c '^[<>].*<!-- Quelle:')"
done
# -> grundlagen-harness-dateien   roh=39   netto=39   quelle=0
#    modul-07-carveouts           roh=2    netto=2    quelle=0
#    modul-04-adrs                roh=0    netto=0    quelle=0
#    grundlagen-bootstrap         roh=0    netto=0    quelle=0
```

Der erste Re-Evaluierungs-Trigger von
[ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) verlangt die Sektions-Ebene, *„weil die
Datei-Ebene hier zu grob gewesen wäre"*. Auf ihr liegen die 39 so:

```sh
sec() { awk -v s="$2" '/^### /{p=index($0,s)>0} p' "$1"; }
for S in 'harness/README.md als Einstiegspunkt' \
         'harness/conventions.md als Konventionsspeicher' \
         'Was ein Kommentar' 'Verzeichniskonvention' 'Template-Schichtung' 'Konsumenten'; do
  printf '%-48s netto=%s\n' "$S" \
    "$(diff <(sec /tmp/v650/regelwerk/grundlagen-harness-dateien.md "$S" \
              | sed -E '/^\|/ s/[[:space:]]*\|[[:space:]]*/|/g') \
            <(sec /tmp/v671/regelwerk/grundlagen-harness-dateien.md "$S" \
              | sed -E '/^\|/ s/[[:space:]]*\|[[:space:]]*/|/g') | grep -c '^[<>]')"
done
# -> harness/README.md als Einstiegspunkt           netto=21
#    harness/conventions.md als Konventionsspeicher netto=4
#    Was ein Kommentar                              netto=2
#    Verzeichniskonvention                          netto=12
#    Template-Schichtung                            netto=0
#    Konsumenten                                    netto=0
```

**Die delegierte Pflichtgliederung für `harness/README.md` kippt zum zweiten Mal in Folge, und
diesmal nimmt sie etwas weg.** Der Abschnitt fragt wörtlich *„Ob ein Feld **Pflicht** ist,
entscheidet nicht die Feldzahl im Template, sondern die Pflichtgliederung im vendored Regelwerk —
für `harness/conventions.md` in §Konventionsspeicher, für `harness/README.md` in
§Einstiegspunkt"* (`v6.5.0`, `modul-02-harness-bootstrap.md`, §Freshness-Audit der vendored
Baseline (Schritt 2), byte-gleich in `v6.7.1`). Genau diese Sektion trägt in der Ziel-Fassung
eine neue Setzung, die den Gate-Index an **einen** Ort bindet (`v6.7.1`,
`lab/regelwerk/grundlagen-harness-dateien.md`, §harness/README.md als Einstiegspunkt):

> **Der Gate-Index steht einmal, und zwar hier.** `AGENTS.md` trägt die *Regel*
> (kein behauptetes Gate ohne Deckung) und den *Zeiger* auf diese Sektion — nicht
> die Liste.

Dieselbe Setzung steht in der Ziel-Fassung an zwei weiteren Stellen: Die AGENTS-Vorlage streicht
ihre Gate-Tabelle ersatzlos und ersetzt sie durch *„Der Gate-Index steht **einmal**, in
`harness/README.md` §Sensors … Diese Datei führt die Liste nicht."* (`v6.7.1`,
`lab/templates/AGENTS.template.md`), und `modul-13-quality-gates.md` §Hard Rule nennt den Index
*„die **Autoritäts-Doku**, und es gibt genau eine"*.

Die vier Zeilen in §Konventionsspeicher sind dagegen ein Anker-Nachzug
(`#vergabe-woher-die-nächste-nummer-kommt` → `#…-kennung-kommt`), und die zwölf in
§Verzeichniskonvention liegen in einer Sektion, in die der Freshness-Audit **nicht** delegiert —
dieselbe Lage, die [ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) für ihren Sprung
gemessen hat.

### Die Wirkung ist am Bestand ablesbar — und sie steht heute in der Gate-Config

Gemessen am 2026-09-12 deckt der Gate-Index dieses Repos jedes Rezept genau einmal, und die
Autoritäts-Datei ist `AGENTS.md`:

```sh
grep -n 'authority:' .d-check.yml                                                       # -> authority: AGENTS.md
grep -hoE '^[a-zA-Z][a-zA-Z0-9_.-]*:' Makefile d-check.mk | tr -d ':' | sort -u | wc -l # -> 48 Rezepte
grep -oE '^\| `make [a-z-]+`' AGENTS.md | wc -l                                         # -> 11 Tabellenzeilen
sed -n '/^targets:/,/^ignore-refs:/p' .d-check.yml | grep -c '^    - '                  # -> 37 exempt-targets
```

**48 = 11 + 37, Rest null** — nachgerechnet über die Namen, nicht über die Summe:

```sh
grep -hoE '^[a-zA-Z][a-zA-Z0-9_.-]*:' Makefile d-check.mk | tr -d ':' | sort -u > /tmp/rec
grep -oE '^\| `make [a-z-]+`' AGENTS.md | sed 's/^| `make //;s/`$//' | sort -u > /tmp/auth
sed -n '/^targets:/,/^ignore-refs:/p' .d-check.yml | sed -n 's/^    - //p' | sort -u > /tmp/ex
comm -23 /tmp/rec <(cat /tmp/auth /tmp/ex | sort -u) | wc -l                            # -> 0
```

Folgt das Repo der Pflichtgliederung der Ziel-Fassung, verliert `AGENTS.md` §4 seine Liste — und
ohne Mitziehen von `authority` stünden genau die 11 Rezepte ohne Deckung da, die heute allein von
jener Tabelle getragen werden. **Der Nachzug ist am selben Bestand bereits möglich**, und auch das
ist gemessen, nicht vermutet:

```sh
grep -oE '^\| \[?`make [a-z-]+`' harness/README.md | grep -oE 'make [a-z-]+' \
  | sed 's/^make //' | sort -u > /tmp/r2
wc -l < /tmp/r2                                                                         # -> 28
comm -23 /tmp/rec <(cat /tmp/r2 /tmp/ex | sort -u) | wc -l                              # -> 0
```

**Keine Erwartungswerte** — die vier Beträge wandern mit dem Makefile und mit dem Einstiegspunkt,
der gerade selbst in Arbeit ist. Tragend ist nicht ihre Höhe, sondern dass der Rest auf **beiden**
Seiten null ist: Die Ziel-Fassung fordert eine Umstellung, die dieses Repo ohne Deckungsverlust
vollziehen kann — ein Durchgang nach der gepinnten Fassung fordert sie **nie**, denn deren
Pflichtgliederung kennt den Satz nicht. Das ist die Wahl in einem Satz, dieselbe Bauart wie in den
drei Sprüngen davor, an derselben Sektion wie beim letzten Mal.

Dieselbe Setzung erreicht die **emittierte** Ebene: `v6.7.1`, `lab/templates/.d-check.yml` legt
einen auskommentierten `targets:`-Block mit `authority: harness/README.md` und dem Kommentar
*„dieselbe Datei — es gibt nur einen Index"* nach. Die **Modul-Zusammensetzung** der Vorlage
bleibt dabei unberührt (`modules: [links, anchors]` in beiden Tags), der Block ist Kommentar —
[`MR-054`](../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
ist dadurch nicht ausgelöst und behält seinen eigenen Träger. Benannt gehört es trotzdem: Dogfood
und emittierte Ebene stünden nach der Ziel-Fassung mit verschiedener Autoritäts-Datei da, solange
der Dogfood nicht nachzieht.

### Rauschklassen: zwei tragen null, und der Kandidat für eine dritte ist keine

[ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) misst den Herkunfts-Kommentar als
Rauschquelle, [ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) die Tabellenform. Beide
tragen hier **null** — der Herkunfts-Kommentar, weil beide Seiten aus derselben Quelle kommen
(§Die Achse), die Tabellenform, weil `roh` und `netto` je Delegat gleich sind (Messung oben). Der
vierte Re-Evaluierungs-Trigger jener Entscheidung fragt nach einer **dritten** Klasse. Der
Kandidat ist die Kennungs-Notation aus dem Wellen-Paar 130–131:

```sh
diff -ruN -x SHA256SUMS /tmp/v650 /tmp/v671 | grep '^[+-][^+-]' | grep -c '<Kennung>'  # -> 46
grep -rl '<Kennung>' /tmp/v671 | wc -l                                                 # -> 22
```

**Sie ist keine Rauschklasse, sondern die Regeländerung selbst.** `v6.7.1`,
`lab/regelwerk/grundlagen-source-precedence.md`, §Vergabe: woher die nächste Kennung kommt setzt
*„Welle- und Slice-Kennungen sind Namen, nicht Nummern"* und verlangt die Form-Deklaration im
Konventionsspeicher des Repos. Ein Normalisierer, der `slice-NNN` und `slice-<Kennung>` gleich
zöge, löschte genau das, worum es geht. Der Trigger ist damit **nicht** gefeuert: Die
Netto-Rechnung bleibt bei zwei Klassen.

### Die Zwei-Fassungen-Phase lebt

```sh
ls -1 .harness/baseline/   # -> v6.5.0
```

Der Arbeitsbaum trägt `v6.5.0`, der Tausch steht aus, und ein Slice dafür ist nicht geschnitten.
Damit ist der zweite tragende Grund von
[ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) — *„Die gepinnte Fassung liegt nicht mehr
vendored"* — wie schon beim letzten Sprung nicht verfügbar. Die Lage ist die von
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 2: Prozedur und Ist-Maßstab sind
während des Wechsels zwei verschiedene Fassungen, und bis der Baum getauscht ist, bleibt `v6.5.0`
für **jede Konformitäts-Frage** maßgeblich.

### Der Durchgang zu `v6.5.0` ist nie gelaufen, und die Buchung sagt es

```sh
grep -n 'Delta-Nachweis' harness/conventions.md
# -> …  **auf `v5.18.0`:** 2026-09-03, Delta-Nachweis in slice-155;
#    …  **auf `v6.0.0`:**  2026-09-04, Delta-Nachweis in slice-176;
#    …  **auf `v6.5.0`:**  2026-09-07, Delta-Nachweis steht aus.
grep -rln 'Adaptions-Durchgang' docs/plan/planning/open docs/plan/planning/next \
  docs/plan/planning/in-progress   # -> ein Slice zur Träger-Inventur und die Roadmap, kein Durchgang
```

Der Vollzug liegt fünf Tage zurück, der Nachweis fehlt, und die Fläche, die er hätte abschreiten
müssen, bewegt mehr Zeilen als dieser Sprung:

```sh
git -C "$K" diff --numstat v6.0.0 v6.5.0 -- lab/regelwerk lab/templates \
  | awk '{a+=$1;d+=$2;n++} END{printf "%d Dateien  +%d  -%d\n", n,a,d}'   # -> 32 Dateien  +624  -153
git -C "$K" diff --numstat v6.0.0 v6.7.1 -- lab/regelwerk lab/templates \
  | awk '{a+=$1;d+=$2;n++} END{printf "%d Dateien  +%d  -%d\n", n,a,d}'   # -> 42 Dateien  +904  -404
git -C "$K" ls-tree -r --name-only v6.7.1 -- lab/regelwerk lab/templates | wc -l  # -> 54 Dateien insgesamt
```

**Die Prozedur bindet ihre fünf Ausgänge ausdrücklich ans Delta** — `v6.5.0`,
`modul-02-harness-bootstrap.md`, §Freshness-Audit der vendored Baseline (Schritt 2): *„Dann **fünf
Ausgänge** — sie beziehen sich auf das *Delta* der neuen Fassung, nicht auf den Zustand der
Baseline"*. Dieselbe Basis zieht die Stichprobe, nur als Komplement: *„aus den Baseline-Abschnitten
ziehen, die seit dem adoptierten `<tag>` **kein Delta** hatten — die Komplementärmenge zu
`git diff <alt> <neu> -- .harness/baseline/`"*. Beide Hälften hängen also an der Frage, was `<alt>`
ist — und genau die beantwortet die Prozedur nicht, weil sie den Fall *„der letzte Durchgang fiel
aus"* nicht führt. Nimmt man `<alt>` als den zuletzt **vendored** Stand, fällt der
`v6.0.0`→`v6.5.0`-Anteil still heraus: Er ist in keinem Diff mehr enthalten, in keiner
Komplementärmenge, und die Buchung, die ihn als *steht aus* führt, wird beim nächsten Vollzug von
einer neuen Zeile überholt.

### Auch `v6.7.1` beantwortet die Frage dieser ADR nicht

Der fünfte Re-Evaluierungs-Trigger von
[ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) fragt, ob eine künftige Baseline die
Meta-Frage selbst beantwortet. Geprüft über die hinzugefügten Zeilen, mit denselben dreizehn
Suchbegriffen wie in beiden Vorgängern:

```sh
diff -ruN -x SHA256SUMS /tmp/v650 /tmp/v671 | grep '^+' | grep -cE \
  'welche Fassung|maßgeblich|regiert|gepinnte Fassung|alte Fassung|Prozedur|Migration|Re-Vendor|Bump|adoptiert|Adoption|Übergang|Reihenfolge des Wechsels'
# -> 0
```

**Null.** Der Trigger ist **nicht** gefeuert. **Grenze**, unverändert die der Vorgänger: ein
Negativ aus dreizehn aufgezählten Zeichenketten — eine Regel ohne eines dieser Wörter wäre nicht
gefunden worden.

## Entscheidung

**Zwei Festlegungen.**

### 1. Für den Sprung `v6.5.0` → `v6.7.1` regiert die Prozedur der Ziel-Fassung `v6.7.1`

(`v6.7.1`, `lab/regelwerk/modul-02-harness-bootstrap.md`, §Freshness-Audit der vendored Baseline
(Schritt 2)) — mit ihren sieben Eigenschaften, ihren fünf Ausgängen und den Abschnitten, in die
sie delegiert.

Tragend ist **ein** gemessener Grund: **Die Prozedur ist nicht abgeschlossen, und der Delegat, der
ihre Form-Frage für `harness/README.md` beantwortet, nimmt eine Pflicht weg.** §harness/README.md
als Einstiegspunkt bindet den Gate-Index an genau einen Ort und spricht `AGENTS.md` die Liste ab;
die AGENTS-Vorlage und `modul-13-quality-gates.md` §Hard Rule tragen dieselbe Setzung. Die Wahl
entscheidet damit, gegen welche Pflichtgliederung der Form-Vergleich misst — und der Unterschied
steht nicht im Konjunktiv, sondern als `authority: AGENTS.md` in der Gate-Config dieses Repos.

Der zweite Grund aus [ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) — die gepinnte
Fassung liege nicht mehr vendored — wird ausdrücklich **nicht** in Anspruch genommen
(§Die Zwei-Fassungen-Phase lebt).

### 2. Der Adaptions-Durchgang misst ab dem Stand, gegen den zuletzt ein Durchgang lief — hier `v6.0.0`

Die Delta-Basis `<alt>` der fünf Ausgänge **und** der Stichproben-Komplementärmenge ist **nicht**
der zuletzt vendored Stand, sondern der letzte, für den §Baseline von `harness/conventions.md`
einen Slice mit Delta-Nachweis ausweist. Heute ist das `v6.0.0`. **Damit schließt dieser Sprung
den ausstehenden `v6.5.0`-Nachweis ein**: Er läuft nicht daneben, und er entfällt nicht.

Zwei Gründe, beide oben gemessen:

1. **Ohne diese Setzung verschwindet der Anteil still.** Der `v6.0.0`→`v6.5.0`-Diff wäre in keinem
   künftigen Delta mehr enthalten und in keiner Komplementärmenge der Stichprobe; die Buchung, die
   ihn heute als *steht aus* führt, bekommt beim Vollzug eine neue Zeile darunter und behält ihre
   alte unverändert — sie meldet nichts. Der Anteil bewegt mit +624/−153 mehr Zeilen als der
   Sprung, der ihn überholen würde.
2. **Der Aufpreis ist der Unterschied zweier Diffs, nicht zweier Durchgänge.** Ein Durchgang gegen
   `v6.7.1` ab `v6.0.0` sieht 42 statt 33 Dateien. Er ist ein Vorgang, keine zwei, und beantwortet
   jede Frage der fünf Ausgänge gegen **die Fassung, die adoptiert wird** — eine Regel, die
   `v6.5.0` einführte und `v6.7.1` zurücknahm, bindet niemanden und fehlt zu Recht.

**Was Festlegung 2 nicht tut.** Sie ändert die Prozedur nicht — sie füllt die Lücke, die deren
Delta-Begriff für den Fall *„der letzte Durchgang fiel aus"* lässt. Sie erlaubt **nicht**, einen
Durchgang auszulassen: Fällt auch dieser aus, wächst die Basis weiter, und die Kosten wachsen mit.
Und sie schreibt **keine** Zeile in §Baseline vor, die dort nicht schon vorgesehen ist — die
Drei-Teil-Form von [ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
Festlegung 2 bleibt unberührt; ihr zweiter Teil ist genau das Feld, das diese Festlegung lesbar
macht.

### Was beide Festlegungen nicht tun

- **Kein `Supersedes`.** [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 ist so
  gebaut, dass jeder Sprung sie **erfüllt** statt sie zu ersetzen;
  [ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md),
  [ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) und
  [ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) bleiben für ihren Sprung wahr.
- **Keine allgemeine Regel.** *„Es regiert stets die Ziel-Fassung"* entsteht hier ausdrücklich
  nicht; sie bleibt verworfen ([ADR-0018](0018-ziel-fassung-regiert-die-migration.md)
  §Verglichene Alternativen, Option C), und der nächste Sprung misst erneut — Achse, beide Stufen,
  Netto je Sektion.
- **Sie deutet die fünf Ausgänge nicht** und entscheidet keinen einzelnen Eintrag des
  Adaptions-Blocks. Beides bleibt bei
  [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 4.
- **Sie inventarisiert das Delta nicht.** Welche Regel des Sprungs welchen Eintrag, welches
  Artefakt und welchen Sensor dieses Repos trifft, ist Gegenstand des Durchgangs.
- **Sie entscheidet die `authority`-Frage nicht.** Ob `targets.authority` auf den Einstiegspunkt
  wandert, ob die Gate-Tabelle in `AGENTS.md` §4 einem Zeiger weicht und ob das eine Senkung nach
  [`AGENTS.md`](../../../AGENTS.md) §3.5 ist, entscheidet der Durchgang bzw. die ADR, die er
  auslöst. Gemessen ist hier allein, dass der Deckungs-Rest auf beiden Seiten null ist.
- **Sie entscheidet die Kennungs-Form nicht.** Ob dieses Repo `slice-NNN` behält oder auf Namen
  umstellt, ist eine Deklaration im Konventionsspeicher und gehört in den Durchgang.
- **Sie greift [`MR-054`](../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  nicht vor.** Die Modul-Zusammensetzung der emittierten Startkonfiguration bleibt dort; die
  Ziel-Fassung ändert sie nicht.

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`. Sie wird `Accepted`, **wenn eine Reviewer-Runde in
frischem Kontext sie gegen [ADR-0018](0018-ziel-fassung-regiert-die-migration.md),
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md),
[ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) und
[ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) auf Konsistenz geprüft hat und ihr Report
ohne blockierenden Befund in `docs/reviews/` liegt** — die Aufteilung, die das Baseline-Regelwerk
`modul-08-agentenrollen.md` §Rollen-Regeln verbatim vorschreibt: *„ADR-Änderung: Architect
schreibt; Reviewer prüft auf Konsistenz; Implementer liest als Constraint"*. **Der Accept-Übergang
nennt diesen Report namentlich**, und eine Nachmessung durch denselben Kontext, der einen Befund
auflöste, ist kein Beleg
([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegungen 1 und 2).

Bis dahin ist sie ein Architect-Verdikt und das Übergabe-Artefakt, das der Schnitt des
Tausch-Slice und der des Durchgangs als Constraint lesen; sie ist nicht eingefroren
([`AGENTS.md`](../../../AGENTS.md) §3.4 bindet ab `Accepted`).

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts entscheiden, die Wahl fällt faktisch beim ersten Durchgang | kein Aufwand; der Abschnitt ist byte-gleich, also „egal" | *egal* ist gemessen falsch: die Prozedur delegiert, und einer der Delegate nimmt der `AGENTS.md` eine Pflicht weg, die heute als `authority: AGENTS.md` in der Gate-Config steht. [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 verlangt für diesen Fall ausdrücklich eine Begründung; sie zu unterlassen hieße, ihr viertes Anwendungsereignis auszulassen. Und die Basis-Frage bliebe offen — mit ihr der ganze `v6.0.0`→`v6.5.0`-Anteil |
| B — die gepinnte Fassung `v6.5.0` regiert | sie liegt im Baum und ist netzlos lesbar; sie ist bis zum Tausch ohnehin der Ist-Maßstab | ihre Pflichtgliederung für `harness/README.md` kennt die Ein-Index-Setzung nicht; ein Form-Vergleich nach B liest `AGENTS.md` §4 grün und fordert den Nachzug nie. Der Ist-Maßstab bleibt unberührt — [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 2 trennt ihn von der Prozedur, und B verwechselt beide |
| C — allgemeine Regel *„stets die Ziel-Fassung"*, in Ablösung von [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 | jeder künftige Sprung startet ohne Vorlauf; die Messung entfiele | dort verworfen und hier unverändert gültig: sie bände Prozeduren, deren Wortlaut niemand kennt, und wäre der stille Auto-Bump eine Ebene höher — den **beide** Fassungen wortgleich verbieten. Dieser Sprung ist ihr Gegenbeispiel gleich zweimal: Die Achse hat sich geändert, und die Basis-Frage entsteht überhaupt erst aus einem ausgefallenen Durchgang — beides hätte eine Blankett-Regel nie bemerkt. Sie verlangte zudem ein `Supersedes` auf eine ADR, auf die viele Verweis-Vorkommen aus vielen lebenden Dateien zeigen (`git grep -oE '\]\([^)]*0018-ziel-fassung-regiert-die-migration\.md[^)]*\)' -- ':!docs/reviews' ':!docs/plan/planning/done' \| wc -l`, dazu dieselbe Abfrage mit `-l`; beide wandern, [`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2), und `matrix.status` in [`.d-check.yml`](../../../.d-check.yml) verbietet Verweise auf superseded ADRs |
| D — die Prozedur aus der Ziel-Fassung, die Delegate aus der gepinnten | nähme den Text, der die Frage stellt, und ließe die Antworten in dem Baum, der netzlos vorliegt | der Abschnitt adressiert seine Delegate **relativ im eigenen Baum**; die Aufteilung stünde in keiner Fassung und wäre eine Erfindung dieses Repos — derselbe Fehler wie Option D in [ADR-0018](0018-ziel-fassung-regiert-die-migration.md). Und sie hätte genau die Wirkung von B, denn das gesamte tragende Delta liegt in einem Delegaten |
| E — Ziel-Fassung, aber Delta-Basis `v6.5.0`; der ausstehende Nachweis läuft **daneben** als eigener Slice | trennt zwei Sprünge sauber; jeder Durchgang bleibt klein und einzeln prüfbar | er läuft gegen eine Fassung, die dann nicht mehr im Baum liegt — dieselbe Lage, die [ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) als Contra von Option B führt, nur eine Runde später. Zwei Durchgänge über überlappende Deltas fällen zu denselben `MR`-Einträgen zwei Urteile gegen **verschiedene** Fassungen; wo sie sich widersprechen, entscheidet nichts. Und die Reihenfolge ist nicht frei: Läuft der `v6.5.0`-Durchgang nach dem Tausch, misst er gegen einen Text, den ein netzloser Lauf nicht öffnet |
| F — Ziel-Fassung, Delta-Basis `v6.5.0`; der ausstehende Nachweis **entfällt** | der billigste Weg; die Buchung *steht aus* verschwindet unter einer neuen Zeile | er streicht 32 Dateien und +624/−153 Zeilen Prüffläche, ohne dass jemand sie gesehen hat — mehr bewegte Zeilen, als dieser Sprung selbst mitbringt. Und das Feld *„Slice mit dem Delta-Nachweis"* der Buchung bliebe für `v6.5.0` dauerhaft leer — eine Lücke, die die Drei-Teil-Form sichtbar macht und niemand schließt |
| **G — gewählt: Ziel-Fassung für diesen Sprung, Delta-Basis `v6.0.0`** | entscheidet den anstehenden Fall auf Gründen, die hier gemessen sind — korrigierte Achse, beide Stufen, Netto je Sektion, die Gate-Config als ablesbare Wirkung — und schließt den ausgefallenen Durchgang ein, statt ihn zu verlieren; die Basis wird aus einem Feld gelesen, das §Baseline ohnehin führt, statt neu erfunden zu werden; das Kriterium aus [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) bleibt für den nächsten Sprung unangetastet | der Durchgang wird größer (42 statt 33 Dateien) und ist damit schwerer in *einer* Review-Sitzung zu prüfen — das kann ihn in zwei Slices zwingen; der nächste Sprung erbt die Messpflicht ein fünftes Mal; und beide Seiten der Messung liegen bis zum Tausch nur im Kurs-Klon |

## Konsequenzen

- **Positiv:** Der Sprung auf den gesetzten Zielstand hat eine benannte, zitierte Quelle, bevor das
  erste Konformitäts-Urteil fällt — für den Schnitt des Tausch-Slice wie für den
  Adaptions-Durchgang danach.
- **Positiv:** Die Vendoring-**Achse** ist korrigiert und beziffert. Die Aussage von
  [ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md), der vendored Baum sei byte-gleich mit
  dem `lab/`-`git`-Baum, gilt für den heute gepinnten Stand nicht mehr; wer sie ungeprüft
  fortschreibt, bekommt 58 Zeilen Rauschen. Der Befund wird hier **benannt**, nicht dort
  nachgetragen: Jene Datei ist `Accepted` und nach [`AGENTS.md`](../../../AGENTS.md) §3.4
  eingefroren, und ihre Aussage war für ihren Stand richtig.
- **Positiv:** *Byte-gleich* ist zum vierten Mal entkräftet. Die Lesart *„der Abschnitt ändert sich
  nie, also ist die Frage entschieden"* hat nun vier Gegenbeispiele an drei verschiedenen
  Sektionen.
- **Positiv:** Der ausgefallene Durchgang ist nicht mehr unsichtbar. Die Basis ist an ein Feld
  gebunden, das §Baseline führt — wer sie wissen will, liest die letzte Zeile mit gefülltem
  Nachweis-Feld.
- **Negativ:** Diese Entscheidung trägt in Festlegung 1 auf **einem** Grund, wie ihr Vorgänger.
  Fiele der Delegat-Delta-Befund weg, bliebe nichts.
- **Negativ:** Der Durchgang wird größer, und *„in einer Review-Sitzung prüfbar"* ist die
  Slice-Größen-Schranke des Baseline-Regelwerks `modul-05-planning-harness.md` §Ziel-Form: Slice.
  Ob 42 Dateien das noch tragen, ist eine Planner-Frage; diese Entscheidung beantwortet sie nicht
  und schließt einen Schnitt in zwei Slices ausdrücklich nicht aus.
- **Negativ:** Bis zum Tausch ist die regierende Fassung nicht im Arbeitsbaum, und diesmal ist auch
  die **gepinnte** Seite der Messung nur über den Klon exakt reproduzierbar (§Die Achse). Ein
  netzloser Lauf ist auf diese ADR angewiesen. Das ist die Kehrseite von
  [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 2 und wird hier nicht geheilt.
- **Negativ:** Festlegung 2 macht die Kosten eines ausgefallenen Durchgangs sichtbar, aber nicht
  kleiner. Wer den nächsten ebenfalls ausfallen lässt, erbt eine noch größere Basis — die Regel
  verhindert den Ausfall nicht, sie verhindert nur, dass er folgenlos aussieht.
- **Negativ / [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6):**
  **Kein Sensor.** Kein Gate liest, nach welcher Fassung ein Durchgang lief, und keines liest, ab
  welchem Stand er misst. Träger sind der Zeiger in §Baseline von `harness/conventions.md` und der
  Review des Durchgangs-Ergebnisses.
- **Folgepflicht (Architect), im selben Commit eingelöst:** §Baseline von `harness/conventions.md`
  trägt die Zielstand-**Setzung** auf `v6.7.1` und den Zeiger auf diese Entscheidung als regierende
  Fassung. Den **Vollzug** bucht der Lauf, der ihn ausführt, in der Drei-Teil-Form von
  [ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2 — ihr zweiter
  Teil, der Slice mit dem Delta-Nachweis, existiert heute nicht.
- **Folgepflicht (Planner), fällig vor dem Vollzug:** zwei Slices sind zu schneiden — der
  **Baum-Tausch** samt Nachzug der fünf Pins auf `v6.7.1` und den sha256
  `5d3dba9c8dc2df25d5b7dc0bd9b6f5aa123b0ef876dcd9330fe1254898ec72ac` des Assets `lab-regelwerk.zip`
  (kanonisch ist das Makefile-Paar; die vier übrigen sind fail-closed daran gekoppelt), und der
  **Adaptions-Durchgang** mit Delta-Basis `v6.0.0`; weil er den `v6.5.0`-Nachweis einschließt,
  ist seine Kennung der Wert **beider** offenen Nachweis-Felder der Buchung — das der
  `v6.5.0`-Zeile und das der Zeile, die der Vollzug anlegt. **Eingetragen wird er nicht in diesem
  Punkt:** §Baseline von `harness/conventions.md` ist Architect-Eigentum
  ([`AGENTS.md`](../../../AGENTS.md) §3.8), und die Buchung steht in der Architect-Folgepflicht
  darüber. Der Wortlaut beider Pläne ist Planner-Eigentum
  ([ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md)); diese Entscheidung ist das
  Übergabe-Artefakt, nicht der Text.
- **Folgepflicht (Architect), fällig im Durchgang, nicht hier:** die Entscheidung über
  `targets.authority` und die Gate-Tabelle in `AGENTS.md` §4 — beide Dateien sind
  Architect-Eigentum ([`AGENTS.md`](../../../AGENTS.md) §3.8), und ob der Nachzug eine Senkung nach
  §3.5 ist, gehört in jene Abwägung.
- **Darüber hinaus ändert diese ADR keine Datei außer sich selbst, dem ADR-Index und §Baseline von
  `harness/conventions.md`.**

## Fitness Function (falls maschinell prüfbar)

**Gebaut: keine** — und das ist die Eigenschaft der Frage, nicht ein Versäumnis.

| Kandidat | Warum er die Regel nicht misst |
|---|---|
| `make baseline-verify` | belegt, **welcher Tag vendored** ist (genau einer, integer, vollständig). Nach welcher Fassung ein Durchgang **gelaufen** ist und ab welchem Stand er maß, sieht er nicht |
| `make docs-check` | prüft Auflösbarkeit von Zielen und Ankern, nicht die Herkunft eines Verfahrens; sein `targets`-Modul prüft Deckung gegen **eine** `authority`-Datei, nicht, ob diese die richtige ist |
| `make comment-claims` | hat keine Markdown-Datei im Prüfbereich |
| `make regelwerk-check` | hält den gepinnten Tag gegen sein Release-Asset (Netz, nicht in `make gates`) — eine Aussage über **einen** Tag, keine über die Wahl zwischen zweien |
| `make baseline-freshness` | meldet einen neueren Upstream-Tag (Netz, nicht in `make gates`) — der Auslöser eines Sprungs, nicht seine Basis |

**Nicht mechanisierbar:** ob ein Durchgang der gewählten Prozedur *gefolgt* ist, ist ein Urteil
über einen Vorgang — dieselbe Grenze, die
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md),
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md),
[ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) und
[ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) für sich benennen.

**Teilweise mechanisierbar, hier nicht gebaut:** Festlegung 2 hat eine urteilsfreie Hälfte — *die
letzte Re-Baseline-Zeile mit gefülltem Nachweis-Feld nennt die Basis*. Ein Sensor darüber läse
§Baseline und verglich mit dem Tag, den ein Durchgangs-Slice als Basis nennt; er setzte ein Feld
voraus, das jener Slice heute nicht führt. Ihn hier als vorhanden auszugeben wäre
[`AGENTS.md`](../../../AGENTS.md) §3.1 eine Ebene tiefer.

## Re-Evaluierungs-Trigger

- **Wenn der nächste Sprung ansteht** *(feedforward — die Messung aus
  [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 läuft in jenem Sprung, kein
  Gate meldet sie)*: Festlegung 1 gilt **nur** für `v6.5.0` → `v6.7.1`. Der nächste Sprung misst
  neu — die Achse **zuerst**, dann beide Stufen und das Delegat-Delta netto je Sektion.
- **Wenn der vendored Baum wieder byte-gleich mit dem `lab/`-`git`-Baum wird oder seine
  Umschrift-Klasse wechselt** *(beobachtbar an `diff -rq -x SHA256SUMS .harness/baseline/<tag>`
  gegen ein `git archive` desselben Tags)*: dann ist die Achsen-Korrektur oben gegenstandslos oder
  anders zu ziehen, und der Rausch-Abzug ändert sich mit ihr.
- **Wenn ein Sprung sein Delegat-Delta ausschließlich in Sektionen trägt, in die der
  Freshness-Audit nicht delegiert** *(beobachtbar am Sektions-Netto-Diff der vier Zieldateien)*:
  dann trägt der einzige Grund von Festlegung 1 nicht, und der Fall braucht eine eigene
  Begründung — diese ADR liefert sie nicht.
- **Wenn ein Durchgang seine Basis erreicht, ohne dass eine Re-Baseline-Zeile ein leeres
  Nachweis-Feld trägt** *(beobachtbar an §Baseline von `harness/conventions.md`)*: dann fallen
  zuletzt-vendored und zuletzt-geprüft zusammen, Festlegung 2 ist für jenen Sprung wirkungslos und
  kostet nichts — sie bleibt trotzdem die Leseregel, damit der nächste Ausfall wieder auffällt.
- **Wenn die Prozedur selbst ihre Delta-Basis benennt** *(feedforward, Textänderung upstream im
  Abschnitt §Freshness-Audit der vendored Baseline)*: dann bindet sie unabhängig von ihrer
  Rezeption hier, und Festlegung 2 ist gegen den neuen Wortlaut neu zu begründen oder als
  Abweichung zu deklarieren.
- **Wenn eine künftige Baseline die Meta-Frage selbst beantwortet** *(feedforward, Textänderung
  upstream)*: dann bindet sie unabhängig von ihrer Rezeption hier, und Festlegung 1 ist gegen den
  neuen Wortlaut neu zu begründen oder als Abweichung zu deklarieren.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-12 | **Proposed** | Architect-Lauf auf die Zielstand-Setzung des Auftraggebers vom selben Tag. Anlass sind der vierte Eintritt des zweiten Falls aus [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3, der erste und der vierte Re-Evaluierungs-Trigger von [ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) und die in §Baseline von `harness/conventions.md` als *steht aus* gebuchte Lücke des `v6.5.0`-Durchgangs |
| 2026-09-12 | **Accepted** | Vollzogen in der Architect-Rolle. **Der Acceptance-Trigger ist eingelöst**, und der Beleg, den er verlangt, ist die **Reviewer-Bestätigungsrunde vom 2026-09-12 zu ADR-0043, Runde 2** — gefahren in frischem Kontext gegen [ADR-0018](0018-ziel-fassung-regiert-die-migration.md), [ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md), [ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) und [ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md); ihre Kategorie-Summary nennt **kein HIGH, kein MEDIUM und kein LOW**, ihr Report liegt damit ohne blockierenden Befund in `docs/reviews/`. Dass es die **zweite** Runde ist, fordert [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2: Runde 1 meldete mit MEDIUM-1 einen blockierenden Befund, Beleg ist darum eine erneute Runde derselben prüfenden Rolle und nicht die Nachmessung des Kontexts, der ihn auflöste. **Der eine INFO jener Runde ist vor diesem Umschlag behoben** — die Aussage über die zwei offenen Nachweis-Felder nennt jetzt den Architect-Ort ihrer Buchung, statt im Planner-Punkt als Schreibauftrag zu stehen; Festlegung 2 deckt das, denn sie verlangt eine weitere Runde nur nach einem **blockierenden** Befund. Wer eine ADR annimmt, sagt keine Quelle dieses Repos — gemessen in [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) §Geschichte, hier nicht gedoppelt. **Ab hier bindet [`AGENTS.md`](../../../AGENTS.md) §3.4:** Korrekturen entstehen als Folge-ADR mit `Supersedes`. |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0043` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
