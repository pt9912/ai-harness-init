# ADR-0044: Die Ziel-Fassung regiert auch den Sprung `v6.5.0` → `v6.7.2` — der bewegte Zielstand löst die Sprung-Festlegung ihres Vorgängers ab, samt dem Auftrag, der sie vollzieht

**Status:** Accepted

**Datum:** 2026-09-12

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Supersedes (Teil):** [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) in **zwei
Stücken**, die denselben Gegenstand tragen — die Grenze läuft am Gegenstand, nicht an der
Überschrift: §Entscheidung **Festlegung 1** mit ihrem vollen Gegenstand, der Wahl der regierenden
Fassung für einen Sprung, dessen Ziel `v6.7.1` ist; **und** in §Konsequenzen die **erste Hälfte**
des Punktes *„Folgepflicht (Planner), fällig vor dem Vollzug"* — den **Baum-Tausch** samt
*„Nachzug der fünf Pins auf `v6.7.1`"* und dem dort vollständig genannten sha256 des Assets
`lab-regelwerk.zip`, den Auftrag also, der Festlegung 1 vollzieht. Dieser Sprung wird nicht
vollzogen — der Zielstand steht auf `v6.7.2`, und keine Pin-Stelle dieses Repos hat je `v6.7.1`
getragen. **Die zweite Hälfte jenes Punktes — der Adaptions-Durchgang mit Delta-Basis `v6.0.0` —
ist nicht abgelöst**: Sie vollzieht Festlegung 2, und die bindet unverändert fort. Deren
normativer Satz nennt kein Sprungziel; er bindet die Basis an den Stand, den sie als *„der letzte,
für den §Baseline von `harness/conventions.md` einen Slice mit Delta-Nachweis ausweist"*
bezeichnet. Festlegung 2 dieser Entscheidung **wendet sie an**, statt sie zu ersetzen. Unberührt
bleiben ebenso die Achsen-Korrektur jener Datei (§Die Achse ist nicht mehr die von ADR-0038) und
ihre Feststellung, dass *byte-gleich* die Frage nicht beantwortet. Was die Ablösung **nicht**
umfasst und was sie offen lässt, steht in §Was der Teil-Supersede umfasst — und was nicht.

**Bezug:**
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) (deren Festlegung 3 stellt das Kriterium;
diese Entscheidung **wendet es an**, statt es zu ändern — ihr zweiter Fall ist zum fünften Mal
eingetreten; ihre Festlegung 2 trennt Prozedur und Ist-Maßstab und trägt hier, weil der Tausch
aussteht; ihr §*Wer den Zielstand bewegt* behält die Setzung dem Auftraggeber vor),
[ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) (die teilweise abgelöste Vorgängerin;
ihre Festlegung 2 liefert die Leseregel für die Delta-Basis, ihr erster Re-Evaluierungs-Trigger
verlangt für diesen Sprung Achse, beide Stufen und das Delegat-Delta netto je Sektion),
[ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) (der Sprung davor; ihr vierter
Re-Evaluierungs-Trigger fragt nach einer dritten Rauschklasse),
[ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) (die Netto-Frage und die
Herkunfts-Kommentar-Rauschklasse stammen von dort),
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (**`Proposed`**, und sie führt
keinen Acceptance-Trigger; deren Festlegung 2 — Ort und geschlossene Drei-Teil-Form einer
Zielstand-Setzung — bleibt unberührt und bindet die Buchung, die mit dieser Entscheidung und später
mit dem Vollzug entsteht. Ob eine nicht angenommene Entscheidung so zitiert werden darf, ist hier
nicht entschieden und steht als eigener Vorgang in §Konsequenzen),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (der Accept-Übergang dieser
Datei nennt den Beleg, den ihr Acceptance-Trigger verlangt; deren Festlegung 2 schließt die
Nachmessung desselben Kontexts als Beleg aus, deren Festlegung 3 bindet eine Trigger-Änderung an
den `Proposed`-Zustand),
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
und stellt die **Basis seiner Messung** fest, nicht den Inhalt eines Spec-Dokuments.

**Kopplung:** §Baseline von `harness/conventions.md` — dort ist die Zielstand-Setzung auf `v6.7.2`
verbucht, und dort steht der Zeiger auf diese Entscheidung als regierende Fassung des Sprungs. Der
**Ort** ist der von [ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
Festlegung 2 (`Proposed`, siehe Bezug-Feld); deren geschlossene Drei-Teil-Form gilt der Buchung des
**Vollzugs**, und die entsteht
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
`v5.18.0` → `v6.0.0`, [ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) für
`v6.0.0` → `v6.5.0` und [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) für
`v6.5.0` → `v6.7.1` entschieden. Alle vier sind auf ihren Sprung geschlossen.

**Der Zielstand steht auf `v6.7.2`, und er ist gesetzt, nicht abgeleitet:** Der Auftraggeber hat
ihn am 2026-09-12 dorthin gezogen — der Akt, den
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) §Wer den Zielstand bewegt ihm vorbehält,
weil kein Lauf im Repo den Zielstand einer Release-Liste nachführen darf. Die bloße **Existenz**
eines Releases ist diese Setzung nicht; sie ist ihr Anlass.

**Der Zielstand des vorigen Sprungs ist damit unerreichbar geworden, nicht widerlegt.** `v6.7.1`
liegt in keinem Pin dieses Repos und in keinem vendored Baum; die Frage *„welche Fassung regiert
den Weg von `v6.5.0` nach `v6.7.1`"* hat kein Objekt mehr. Was sie hatte — einen offenen Sprung
vom vendored Stand zum gesetzten Zielstand —, hat jetzt die Frage dieser Entscheidung.

### Die Achse: der vendored Baum ist das Release-Asset, unverändert

Gemessen am 2026-09-12 gegen den lokalen Kurs-Klon — eine **Host-Voraussetzung**, kein Artefakt
dieses Repos:

```sh
K=/Development/KI/ai-harness-course
mkdir -p /tmp/v650 && git -C "$K" archive v6.5.0 lab/regelwerk lab/templates \
  | tar -x -C /tmp/v650 --strip-components=1
diff -rq -x SHA256SUMS .harness/baseline/v6.5.0 /tmp/v650 | wc -l                       # -> 28
diff -r  -x SHA256SUMS .harness/baseline/v6.5.0 /tmp/v650 | grep -c '^[<>]'             # -> 58
diff -r  -x SHA256SUMS .harness/baseline/v6.5.0 /tmp/v650 | grep '^[<>]' \
  | grep -v 'github\.com/pt9912/ai-harness-course' | grep -vE '\.\./\.\./' | wc -l      # ->  0
```

**28 Dateien, 58 Zeilen, keine davon außerhalb einer der zwei Umschrift-Klassen** —
`<!-- Quelle: … -->`-Ziele und `<tag>`-gescopte Download-URLs. Der vendored Baum entsteht seit
`v6.5.0` aus dem **Release-Asset** (`make vendor-baseline`), nicht aus dem `git`-Baum. **Keine
Erwartungswerte**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Beträge wandern mit den Tags.

**Was daraus für jede Zahl unten folgt:** Beide Seiten werden aus **derselben** Quelle gezogen —
`git archive` über beide Tags —, damit die Asset-Umschrift sich aufhebt. **Grenze — die
Kostenstelle dieser Messung:** Keine Seite dieses Vergleichs liegt netzlos im Arbeitsbaum. Die
`v6.5.0`-Seite ist über die Gegenprobe oben an den Arbeitsbaum gebunden, die `v6.7.2`-Seite an
nichts als den Klon.

### Der Sprung überspannt vier Releases, davon drei übersprungene

```sh
git -C "$K" log --oneline --decorate v6.7.1..v6.7.2
# -> 54d344b (tag: v6.7.2) feat(kurs+regelwerk+templates): Welle 134 - Sensor-Vorlage referenziert, auf allen drei Ebenen
#    03f6af9 docs(roadmap): Meilenstein v6.7.1 mit Beleg eintragen
```

`v6.6.0`, `v6.7.0` und `v6.7.1` werden übersprungen. Der Umfang bleibt klein:

```sh
git -C "$K" diff --numstat v6.5.0 v6.7.2 -- lab/regelwerk lab/templates \
  | awk '{a+=$1;d+=$2;n++} END{printf "%d Dateien  +%d  -%d\n", n,a,d}'
# -> 33 Dateien  +295  -263
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
Argument *„die Wahl steht zwischen einem Verfahren und keinem"* lautet —, sondern zum fünften Mal
der zweite. Die Ziel-Fassung führt ihn ebenso:

```sh
git -C "$K" show v6.7.2:lab/regelwerk/modul-02-harness-bootstrap.md \
  | grep -c '^#### Freshness-Audit der vendored Baseline (Schritt 2)$'   # -> 1
```

### Stufe (b) — der Abschnitt ist zum fünften Mal byte-gleich

```sh
mkdir -p /tmp/v672 && git -C "$K" archive v6.7.2 lab/regelwerk lab/templates \
  | tar -x -C /tmp/v672 --strip-components=1
sed -n '/^#### Freshness-Audit/,/^#### Gate-Fragment/p' \
  /tmp/v650/regelwerk/modul-02-harness-bootstrap.md > /tmp/fa-650
sed -n '/^#### Freshness-Audit/,/^#### Gate-Fragment/p' \
  /tmp/v672/regelwerk/modul-02-harness-bootstrap.md > /tmp/fa-672
wc -l /tmp/fa-650 /tmp/fa-672   # -> 123  123
diff /tmp/fa-650 /tmp/fa-672    # -> leer
grep -c '^\* \*\*' /tmp/fa-672  # -> 7   (die sieben Eigenschaften)
```

Er beantwortet nicht alles selbst: neun Verweise gehen in vier Dateien seines eigenen Baums.

```sh
grep -oE '\]\([a-z0-9-]+\.md[^)]*\)' /tmp/fa-672 | sort | uniq -c | sort -rn
# -> 3 grundlagen-harness-dateien.md#harnessconventionsmd-als-konventionsspeicher
#    2 modul-07-carveouts.md
#    1 modul-07-carveouts.md#werkzeug-wahl
#    1 modul-04-adrs.md
#    1 grundlagen-harness-dateien.md#harnessreadmemd-als-einstiegspunkt
#    1 grundlagen-bootstrap.md#modus-pro-sub-area-greenfield-vs-brownfield
```

Zwei der vier Zieldateien ändern etwas, zwei nichts — **roh und netto identisch**, also ohne
Abzug:

```sh
norm() { sed -E '/^\|/ s/[[:space:]]*\|[[:space:]]*/|/g' "$1"; }
for f in grundlagen-harness-dateien modul-07-carveouts modul-04-adrs grundlagen-bootstrap; do
  printf '%-28s roh=%-4s netto=%-4s quelle=%s\n' "$f" \
    "$(diff "/tmp/v650/regelwerk/$f.md" "/tmp/v672/regelwerk/$f.md" | grep -c '^[<>]')" \
    "$(diff <(norm "/tmp/v650/regelwerk/$f.md") <(norm "/tmp/v672/regelwerk/$f.md") \
       | grep -c '^[<>]')" \
    "$(diff "/tmp/v650/regelwerk/$f.md" "/tmp/v672/regelwerk/$f.md" \
       | grep -c '^[<>].*<!-- Quelle:')"
done
# -> grundlagen-harness-dateien   roh=43   netto=43   quelle=0
#    modul-07-carveouts           roh=2    netto=2    quelle=0
#    modul-04-adrs                roh=0    netto=0    quelle=0
#    grundlagen-bootstrap         roh=0    netto=0    quelle=0
```

Der erste Re-Evaluierungs-Trigger von
[ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) verlangt die Sektions-Ebene. Auf ihr
liegen die 43 so:

```sh
sec() { awk -v s="$2" '/^### /{p=index($0,s)>0} p' "$1"; }
for S in 'harness/README.md als Einstiegspunkt' \
         'harness/conventions.md als Konventionsspeicher' \
         'Was ein Kommentar' 'Verzeichniskonvention' 'Template-Schichtung' 'Konsumenten'; do
  printf '%-48s netto=%s\n' "$S" \
    "$(diff <(sec /tmp/v650/regelwerk/grundlagen-harness-dateien.md "$S" \
              | sed -E '/^\|/ s/[[:space:]]*\|[[:space:]]*/|/g') \
            <(sec /tmp/v672/regelwerk/grundlagen-harness-dateien.md "$S" \
              | sed -E '/^\|/ s/[[:space:]]*\|[[:space:]]*/|/g') | grep -c '^[<>]')"
done
# -> harness/README.md als Einstiegspunkt           netto=25
#    harness/conventions.md als Konventionsspeicher netto=4
#    Was ein Kommentar                              netto=2
#    Verzeichniskonvention                          netto=12
#    Template-Schichtung                            netto=0
#    Konsumenten                                    netto=0
```

**Die delegierte Pflichtgliederung für `harness/README.md` kippt zum dritten Mal in Folge, und sie
nimmt etwas weg.** Der Abschnitt fragt wörtlich *„Ob ein Feld **Pflicht** ist, entscheidet nicht
die Feldzahl im Template, sondern die Pflichtgliederung im vendored Regelwerk — für
`harness/conventions.md` in §Konventionsspeicher, für `harness/README.md` in §Einstiegspunkt"*
(`v6.5.0`, `modul-02-harness-bootstrap.md`, §Freshness-Audit der vendored Baseline (Schritt 2),
byte-gleich in `v6.7.2`). Genau diese Sektion trägt in der Ziel-Fassung eine Setzung, die den
Gate-Index an **einen** Ort bindet (`v6.7.2`, `lab/regelwerk/grundlagen-harness-dateien.md`,
§harness/README.md als Einstiegspunkt):

> **Der Gate-Index steht einmal, und zwar hier.** `AGENTS.md` trägt die *Regel*
> (kein behauptetes Gate ohne Deckung) und den *Zeiger* auf diese Sektion — nicht
> die Liste.

Dieselbe Setzung steht in der Ziel-Fassung an zwei weiteren Stellen: Die AGENTS-Vorlage führt
*„Der Gate-Index steht **einmal**, in `harness/README.md` §Sensors"* (`v6.7.2`,
`lab/templates/AGENTS.template.md`), und `modul-13-quality-gates.md` §Hard Rule nennt den Index
*„die **Autoritäts-Doku**, und es gibt genau eine"*.

Die vier Zeilen in §Konventionsspeicher sind ein Anker-Nachzug
(`#vergabe-woher-die-nächste-nummer-kommt` → `#…-kennung-kommt`), und die zwölf in
§Verzeichniskonvention liegen in einer Sektion, in die der Freshness-Audit **nicht** delegiert.

### Was `v6.7.2` gegenüber `v6.7.1` hinzufügt — und was es diesem Repo kostet

Der Zuwachs ist drei Dateien groß und liegt ganz in einem Delegaten:

```sh
git -C "$K" diff --numstat v6.7.1 v6.7.2 -- lab/regelwerk lab/templates \
  | awk '{a+=$1;d+=$2;n++} END{printf "%d Dateien  +%d  -%d\n", n,a,d}'   # -> 3 Dateien  +7  -4
```

Vier der 25 Netto-Zeilen in §harness/README.md als Einstiegspunkt stammen daraus:

```sh
sekt() { awk -v s="$1" '/^### /{p=index($0,s)>0} p'; }
diff <(git -C "$K" show v6.7.1:lab/regelwerk/grundlagen-harness-dateien.md \
        | sekt 'harness/README.md als Einstiegspunkt') \
     <(git -C "$K" show v6.7.2:lab/regelwerk/grundlagen-harness-dateien.md \
        | sekt 'harness/README.md als Einstiegspunkt') | grep -c '^[<>]'   # -> 4
```

Sie geben der Sensor-Datei
eine benannte Ziel-Form (`v6.7.2`, `lab/regelwerk/grundlagen-harness-dateien.md`,
§harness/README.md als Einstiegspunkt): *„`harness/sensors/<target>.md` (Ziel-Form
`templates/harness/sensors/gate.template.md`)"*. Das **Auswahl-Kriterium** bleibt, was es war —
*„Ein Gate je Datei, sobald sein Vertrag mehr braucht als einen Satz"*, byte-gleich in `v6.5.0`
und `v6.7.2`.

**Die Vorlage selbst ist kein Zuwachs.** Sie liegt im vendored Baum und ist über die drei Tags
unverändert:

```sh
cmp .harness/baseline/v6.5.0/templates/harness/sensors/gate.template.md \
    /tmp/v672/templates/harness/sensors/gate.template.md   # -> still, EXIT 0
```

**Und der Bestand dieses Repos trägt ihre Gliederung bereits.** Gemessen am 2026-09-12:

```sh
ls harness/sensors/*.md | wc -l                                        # -> 15
for f in harness/sensors/*.md; do grep -q '^## Vertrag' "$f" \
  && grep -q '^## Grenze' "$f" && grep -q '^## Bindung' "$f" && echo x; done | wc -l   # -> 15
for f in harness/sensors/*.md; do \
  grep -qF "sensors/$(basename "$f")" harness/README.md && echo x; done | wc -l        # -> 15
```

**Keine Erwartungswerte** — alle drei wandern mit dem Baum. Tragend ist, dass die zweite und die
dritte Zahl die erste erreichen: Die drei unbedingten Abschnitte der Vorlage stehen in jeder
Datei, und jede Datei hängt an einer verlinkten Target-Zelle. Der Zuwachs von `v6.7.2` fordert
deshalb **keinen Nachzug am Bestand**; er gibt dem Durchgang eine Adresse, gegen die er den
Form-Vergleich führen kann, wo er bisher nur ein Muster hatte. Auf der **Harness-Ebene** steht
diese Adresse in diesem Repo noch in keinem lebenden Artefakt — weder
[`harness/README.md`](../../../harness/README.md) noch eine Datei unter `harness/sensors/` nennt
die Vorlage; auf der **Emissions-Ebene** steht sie sehr wohl:

```sh
git grep -l 'gate\.template\.md' \
  -- ':!docs/reviews' ':!docs/plan/planning/done' ':!.harness/baseline'
# -> diese Datei, internal/emit/templates.go, internal/emit/templates_test.go,
#    test/courseset-fixture.bats   (kein Erwartungswert)
```

Die Harness-Ebene ist bereits Gegenstand von Planungsarbeit — `slice-222` führt sie in `open/`,
und ihr Wortlaut ist Planner-Eigentum
([ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md)).

### Die Wirkung auf die Gate-Config ist unverändert ablesbar

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
jener Tabelle getragen werden. Der Nachzug ist am selben Bestand bereits möglich:

```sh
grep -oE '^\| \[?`make [a-z-]+`' harness/README.md | grep -oE 'make [a-z-]+' \
  | sed 's/^make //' | sort -u > /tmp/r2
wc -l < /tmp/r2                                                                         # -> 28
comm -23 /tmp/rec <(cat /tmp/r2 /tmp/ex | sort -u) | wc -l                              # -> 0
```

**Keine Erwartungswerte** — die vier Beträge wandern mit dem Makefile und mit dem Einstiegspunkt.
Tragend ist nicht ihre Höhe, sondern dass der Rest auf **beiden** Seiten null ist: Die
Ziel-Fassung fordert eine Umstellung, die dieses Repo ohne Deckungsverlust vollziehen kann — ein
Durchgang nach der gepinnten Fassung fordert sie **nie**, denn deren Pflichtgliederung kennt den
Satz nicht.

Dieselbe Setzung erreicht die **emittierte** Ebene: `v6.7.2`, `lab/templates/.d-check.yml` legt
einen auskommentierten `targets:`-Block mit `authority: harness/README.md` nach. Die
**Modul-Zusammensetzung** der Vorlage bleibt unberührt (`modules: [links, anchors]` in beiden
Tags), der Block ist Kommentar —
[`MR-054`](../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
ist dadurch nicht ausgelöst und behält seinen eigenen Träger.

### Rauschklassen: zwei tragen null, der Kandidat für eine dritte ist keine

[ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) misst den Herkunfts-Kommentar als
Rauschquelle, [ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) die Tabellenform. Beide
tragen hier **null** — der Herkunfts-Kommentar, weil beide Seiten aus derselben Quelle kommen
(§Die Achse), die Tabellenform, weil `roh` und `netto` je Delegat gleich sind. Der vierte
Re-Evaluierungs-Trigger jener Entscheidung fragt nach einer **dritten** Klasse; der Kandidat ist
weiterhin die Kennungs-Notation:

```sh
diff -ruN -x SHA256SUMS /tmp/v650 /tmp/v672 | grep '^[+-][^+-]' | grep -c '<Kennung>'  # -> 46
grep -rl '<Kennung>' /tmp/v672 | wc -l                                                 # -> 22
```

**Sie ist keine Rauschklasse, sondern die Regeländerung selbst.** `v6.7.2`,
`lab/regelwerk/grundlagen-source-precedence.md`, §Vergabe: woher die nächste Kennung kommt setzt
*„Welle- und Slice-Kennungen sind Namen, nicht Nummern"*. Ein Normalisierer, der `slice-NNN` und
`slice-<Kennung>` gleich zöge, löschte genau das, worum es geht. Der Trigger ist damit **nicht**
gefeuert: Die Netto-Rechnung bleibt bei zwei Klassen.

### Die Zwei-Fassungen-Phase lebt

```sh
ls -1 .harness/baseline/   # -> v6.5.0
```

Der Arbeitsbaum trägt `v6.5.0`, der Tausch steht aus, und ein Slice dafür ist nicht geschnitten.
Die Lage ist die von [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 2: Prozedur
und Ist-Maßstab sind während des Wechsels zwei verschiedene Fassungen, und bis der Baum getauscht
ist, bleibt `v6.5.0` für **jede Konformitäts-Frage** maßgeblich.

### Die Basis, aus der die Delta-Frage gelesen wird, steht unverändert

[ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) Festlegung 2 bindet die Delta-Basis an
ein Feld: den letzten Stand, für den §Baseline von `harness/conventions.md` einen Slice mit
Delta-Nachweis ausweist. Das Feld sagt heute:

```sh
grep -c 'Delta-Nachweis' harness/conventions.md                        # -> 5
grep -o '\*\*auf `v[0-9.]*`:\*\* [0-9-]*, Delta-Nachweis[^.;]*' harness/conventions.md
# -> **auf `v5.18.0`:** 2026-09-03, Delta-Nachweis in slice-155
#    **auf `v6.0.0`:** 2026-09-04, Delta-Nachweis in slice-176
#    **auf `v6.5.0`:** 2026-09-07, Delta-Nachweis steht aus
grep -rln 'Adaptions-Durchgang' docs/plan/planning/open docs/plan/planning/next \
  docs/plan/planning/in-progress | wc -l                               # -> 3
```

Die drei Treffer des letzten Kommandos sind `slice-092`, `slice-222` und die Roadmap — **kein
Durchgangs-Slice**. **Keine Erwartungswerte**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2): Die `5` wandert mit §Baseline, die `3` mit dem Planungs-Baum. Tragend ist, dass unter
den Treffern am 2026-09-12 kein Durchgang steht; geschnitten wird er von der Folgepflicht (Planner)
unten.

Der letzte gefüllte Nachweis steht bei `v6.0.0`. Der Aufpreis, den das kostet, ist der Unterschied
zweier Diffs:

```sh
git -C "$K" diff --numstat v6.0.0 v6.5.0 -- lab/regelwerk lab/templates \
  | awk '{a+=$1;d+=$2;n++} END{printf "%d Dateien  +%d  -%d\n", n,a,d}'   # -> 32 Dateien  +624  -153
git -C "$K" diff --numstat v6.0.0 v6.7.2 -- lab/regelwerk lab/templates \
  | awk '{a+=$1;d+=$2;n++} END{printf "%d Dateien  +%d  -%d\n", n,a,d}'   # -> 42 Dateien  +907  -404
git -C "$K" ls-tree -r --name-only v6.7.2 -- lab/regelwerk lab/templates | wc -l  # -> 54 Dateien insgesamt
```

**Und der bewegte Zielstand ändert am Umfang des Durchgangs nichts Zählbares:** Die Dateimenge ist
dieselbe wie gegen `v6.7.1`, der Zuwachs sind drei Zeilen.

```sh
diff <(git -C "$K" diff --name-only v6.0.0 v6.7.1 -- lab/regelwerk lab/templates) \
     <(git -C "$K" diff --name-only v6.0.0 v6.7.2 -- lab/regelwerk lab/templates)   # -> leer
```

### Auch `v6.7.2` beantwortet die Frage dieser ADR nicht

Der fünfte Re-Evaluierungs-Trigger von
[ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) fragt, ob eine künftige Baseline die
Meta-Frage selbst beantwortet. Geprüft über die hinzugefügten Zeilen, mit denselben dreizehn
Suchbegriffen wie in allen Vorgängern:

```sh
diff -ruN -x SHA256SUMS /tmp/v650 /tmp/v672 | grep '^+' | grep -cE \
  'welche Fassung|maßgeblich|regiert|gepinnte Fassung|alte Fassung|Prozedur|Migration|Re-Vendor|Bump|adoptiert|Adoption|Übergang|Reihenfolge des Wechsels'
# -> 0
```

**Null.** Der Trigger ist **nicht** gefeuert. **Grenze**, unverändert die der Vorgänger: ein
Negativ aus dreizehn aufgezählten Zeichenketten — eine Regel ohne eines dieser Wörter wäre nicht
gefunden worden.

## Entscheidung

**Zwei Festlegungen.**

### 1. Für den Sprung `v6.5.0` → `v6.7.2` regiert die Prozedur der Ziel-Fassung `v6.7.2`

(`v6.7.2`, `lab/regelwerk/modul-02-harness-bootstrap.md`, §Freshness-Audit der vendored Baseline
(Schritt 2)) — mit ihren sieben Eigenschaften, ihren fünf Ausgängen und den Abschnitten, in die
sie delegiert.

Tragend ist **ein** gemessener Grund: **Die Prozedur ist nicht abgeschlossen, und der Delegat, der
ihre Form-Frage für `harness/README.md` beantwortet, hat ein Delta, das eine Pflicht wegnimmt und
eine benennt.** §harness/README.md als Einstiegspunkt bindet den Gate-Index an genau einen Ort und
spricht `AGENTS.md` die Liste ab; dieselbe Sektion gibt der Sensor-Datei eine Ziel-Form mit
Adresse. Die Wahl entscheidet damit, gegen welche Pflichtgliederung der Form-Vergleich misst — und
der Unterschied steht nicht im Konjunktiv, sondern als `authority: AGENTS.md` in der Gate-Config
dieses Repos.

Der zweite Grund aus [ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) — die gepinnte
Fassung liege nicht mehr vendored — wird ausdrücklich **nicht** in Anspruch genommen
(§Die Zwei-Fassungen-Phase lebt).

### 2. Die Delta-Basis des Adaptions-Durchgangs ist `v6.0.0` — sie bewegt sich mit dem Zielstand nicht

Die Basis wird nach [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) Festlegung 2 aus
§Baseline von `harness/conventions.md` **gelesen**, nicht je Sprung neu gesetzt: Sie ist der
letzte Stand, für den dort ein Slice mit Delta-Nachweis steht. Gemessen ist das heute `v6.0.0`
(§Die Basis). **Damit schließt dieser Sprung den ausstehenden `v6.5.0`-Nachweis ein**; er läuft
nicht daneben, und er entfällt nicht.

Diese Festlegung ist eine **Anwendung**, keine zweite Fassung der Leseregel. Was sie hinzufügt,
ist die Antwort auf die Frage, die der bewegte Zielstand aufwirft — ob ein neues Ziel die Basis
mitzieht. Zwei Gründe, beide oben gemessen:

1. **Der Zielstand ist die obere Grenze des Deltas, nicht seine untere.** Die Leseregel bindet die
   untere an den letzten *geprüften* Stand; dass der obere sich bewegt, berührt sie nicht. Wer sie
   mit dem Ziel mitzöge, machte aus einer Regel über Prüfstände eine über Release-Nummern.
2. **Es kostet nichts, es einzuschließen.** Die Dateimenge des Durchgangs ist dieselbe wie gegen
   `v6.7.1`, der Zuwachs sind drei Zeilen in einer Datei; der `v6.0.0`→`v6.5.0`-Anteil bewegt mit
   +624/−153 dagegen mehr, als der ganze Sprung mitbringt. Fiele er heraus, wäre er in keinem
   künftigen Delta und in keiner Komplementärmenge der Stichprobe mehr enthalten.

### Was der Teil-Supersede umfasst — und was nicht

**Die Grenze läuft am Gegenstand, nicht an der Überschrift.** Abgelöst ist, was durch den bewegten
Zielstand unerreichbar geworden ist; was sein Objekt behalten hat, bleibt — auch wenn es im selben
Abschnitt, im selben Aufzählungspunkt oder im selben Satz steht wie das Abgelöste. Ein Schnitt
entlang einer Überschrift ließe den operativen Auftrag in Kraft, der die abgelöste Festlegung
vollzieht; er steht nicht in §Entscheidung.

Abgelöst sind danach **zwei Stücke** von
[ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md):

1. **§Entscheidung Festlegung 1**, mit ihrem ganzen Gegenstand: die Wahl der regierenden Fassung
   für einen Sprung, dessen Ziel `v6.7.1` ist. Ihr Sprung hat sein Ziel verloren, bevor eine
   Pin-Stelle ihn trug. Sie bleibt für ihren Sprung wahr und wird nicht widerlegt — sie ist
   unerreichbar.
2. **In §Konsequenzen die erste Hälfte des Punktes *„Folgepflicht (Planner), fällig vor dem
   Vollzug"*** — der Auftrag, der Festlegung 1 vollzieht: der **Baum-Tausch** samt *„Nachzug der
   fünf Pins auf `v6.7.1`"* und dem dort vollständig genannten sha256 des Assets
   `lab-regelwerk.zip`, *„(kanonisch ist das Makefile-Paar; die vier übrigen sind fail-closed
   daran gekoppelt)"*. Er nennt einen Tag, den keine Pin-Stelle trägt, und einen an diesem Tag
   gemessenen Hash; an seine Stelle tritt der gleichnamige Punkt in §Konsequenzen dieser Datei.
   Der Hash steht hier nicht noch einmal — er ist in jener Datei vollständig nachzulesen, und eine
   gekürzte zweite Fassung wäre kein Beleg. Fundweg:
   `grep -n 'Folgepflicht (Planner)' docs/plan/adr/0043-ziel-fassung-regiert-den-sprung-v671.md`.

**Nicht abgelöst ist die zweite Hälfte desselben Punktes:** der *„**Adaptions-Durchgang** mit
Delta-Basis `v6.0.0`"* samt dem Satz, dass seine Kennung der Wert **beider** offenen
Nachweis-Felder der Buchung ist, und samt den zwei Eigentums-Sätzen am Schluss des Punktes. Sie
vollzieht nicht Festlegung 1, sondern Festlegung 2, und die bindet fort. Eine Ablösung des ganzen
Punktes nähme sie mit — das ist der Grund, warum hier eine Hälfte benannt wird und nicht ein
Aufzählungspunkt.

**Nicht abgelöst** ist im Übrigen alles andere jener Datei: Festlegung 2 (die Leseregel für die
Delta-Basis), die Achsen-Korrektur, die Netto-Rechnung über zwei Rauschklassen, die Entkräftung
von *byte-gleich*, ihre Grenzen und ihre Re-Evaluierungs-Trigger. Drei davon sind mit dieser
Entscheidung eingelöst statt beseitigt: der erste (Achse, beide Stufen, Netto je Sektion), der
dritte (das Delegat-Delta liegt in einer Sektion, in die delegiert wird) und der vierte (die Basis
ist erreicht, das Nachweis-Feld der `v6.5.0`-Zeile ist leer).

**Drei Präsens-Aussagen jener Datei sind durch den bewegten Zielstand falsch geworden — abgelöst
sind sie nicht, benannt schon.** Zwei davon sprechen über §Baseline: Das Kopffeld `Kopplung:` sagt
*„dort ist die Zielstand-Setzung auf `v6.7.1` verbucht"*, und der Punkt *„Folgepflicht (Architect),
im selben Commit eingelöst"* sagt, §Baseline *„trägt die Zielstand-**Setzung** auf `v6.7.1`"*;
beide waren für ihren Stand richtig und beschreiben einen abgeschlossenen Akt. Die dritte steht in
§Kontext und beschreibt einen Zustand: *„Der gesetzte Zielstand ist `v6.7.1`."* Keine der drei
ordnet etwas an, und eine Ablösung hätte hier kein Objekt — es gäbe keine Entscheidung, die an ihre
Stelle träte. Sie bleiben stehen und sind in jener Datei nicht korrigierbar
([`AGENTS.md`](../../../AGENTS.md) §3.4); der geltende Zustand steht in §Baseline von
[`harness/conventions.md`](../../../harness/conventions.md) selbst.

**Ihre Statuszeile bleibt, wie sie steht — und der Grund ist der Umfang, nicht ein Verbot.** Die
Datei ist nicht ganz abgelöst, und für *teilweise abgelöst* kennt das Vokabular keinen Statuswert:
`vcs.head-allow` in [`.d-check.yml`](../../../.d-check.yml) führt genau drei — `Accepted`,
`Deprecated` und die Link-Form `Superseded by [ADR-NNNN](NNNN-titel.md)`. Der **volle**
Supersede-Übergang ist damit ausdrücklich zugelassen und im Bestand gelebt: `vcs.status-line`
nimmt die Statuszeile aus dem unveränderlichen Kern,
[`harness/sensors/adr-immutable.md`](../../../harness/sensors/adr-immutable.md) führt ihn als
erlaubten Übergang, und zwei Dateien tragen ihn heute
(`grep -h '^\*\*Status:\*\* Superseded by' docs/plan/adr/[0-9]*.md \| wc -l` → **2**, kein
Erwartungswert). Eine Teil-Ablösung wird deshalb nicht durch ein Verbot, sondern mangels
Statuswert an **keinem** Byte jener Datei sichtbar, sondern in der Status-Spalte des ADR-Index —
die Form, die [ADR-0032](0032-eingefrorene-referenz-folgt-ihrem-rumpf.md) und
[ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) für ihre
Teil-Ablösungen tragen. Der Index ist derivativ und gehört der Rolle seines Originals
([ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md)).

**Diese Entscheidung ordnet jenen Zusatz an, und er wird mit ihrer Annahme geschrieben.**
[`docs/plan/adr/README.md`](README.md) §Konventionen trägt einen Zusatz in der Status-Zelle
*„nur, wo eine `Accepted`-ADR ihn anordnet"*. Solange diese Datei `Proposed` ist, ist die
Bedingung nicht erfüllt, und die Zelle von
[ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) steht unverändert. Der Zusatz nennt dann
den Umfang — §Entscheidung Festlegung 1 **und** den sie vollziehenden Baum-Tausch-Auftrag in
§Konsequenzen — und diese ADR, sonst nichts; was fortgilt, steht hier und nicht dort.

### Was beide Festlegungen nicht tun

- **Kein `Supersedes` auf [ADR-0018](0018-ziel-fassung-regiert-die-migration.md).** Deren
  Festlegung 3 ist so gebaut, dass jeder Sprung sie **erfüllt** statt sie zu ersetzen;
  [ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md),
  [ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md) und
  [ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) bleiben für ihren Sprung wahr.
- **Keine allgemeine Regel.** *„Es regiert stets die Ziel-Fassung"* entsteht hier ausdrücklich
  nicht; sie bleibt verworfen ([ADR-0018](0018-ziel-fassung-regiert-die-migration.md)
  §Verglichene Alternativen, Option C), und der nächste Sprung misst erneut.
- **Keine Regel darüber, was ein bewegter Zielstand mit einer angenommenen Entscheidung macht.**
  Entschieden ist dieser Fall; dass ein unerreichbar gewordener Sprung eine Teil-Ablösung
  rechtfertigt, ist hier begründet und nicht als Muster gesetzt.
- **Sie deutet die fünf Ausgänge nicht** und entscheidet keinen einzelnen Eintrag des
  Adaptions-Blocks. Beides bleibt bei
  [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 4.
- **Sie inventarisiert das Delta nicht.** Welche Regel des Sprungs welchen Eintrag, welches
  Artefakt und welchen Sensor dieses Repos trifft, ist Gegenstand des Durchgangs.
- **Sie entscheidet die `authority`-Frage nicht.** **Dass** die Pflichtgliederung der Ziel-Fassung
  übernommen wird, steht als Vorgabe des Auftraggebers in §Konsequenzen und nicht in dieser
  Festlegung; **wie** `targets.authority` und die Gate-Tabelle in `AGENTS.md` §4 nachgezogen werden
  und ob das eine Senkung nach [`AGENTS.md`](../../../AGENTS.md) §3.5 ist, entscheidet der
  Durchgang bzw. die ADR, die er auslöst.
- **Sie entscheidet die Form der Sensor-Dateien nicht.** Dass die Ziel-Fassung ihre Vorlage
  benennt, ist hier gemessen; welche Datei dieses Repos den Zeiger darauf trägt und für welches
  Ziel überhaupt eine Datei entsteht, ist Planungs- und Durchgangs-Arbeit.
- **Sie nennt keinen sha256.** Der des `v6.7.2`-Assets wird beim Vollzug am Asset gemessen; eine
  Zahl, die hier stünde, wäre nicht belegt.
- **Sie greift [`MR-054`](../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  nicht vor.**

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`. Sie wird `Accepted`, **wenn eine Reviewer-Runde in
frischem Kontext sie gegen [ADR-0018](0018-ziel-fassung-regiert-die-migration.md),
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) und die teilweise abgelöste
[ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) auf Konsistenz geprüft hat und ihr Report
ohne blockierenden Befund in `docs/reviews/` liegt** — die Aufteilung, die das Baseline-Regelwerk
`modul-08-agentenrollen.md` §Rollen-Regeln verbatim vorschreibt: *„ADR-Änderung: Architect
schreibt; Reviewer prüft auf Konsistenz; Implementer liest als Constraint"*. **Der Accept-Übergang
nennt diesen Report namentlich**, und eine Nachmessung durch denselben Kontext, der einen Befund
auflöste, ist kein Beleg
([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegungen 1 und 2).

**Der Prüfgegenstand der Runde ist eigens benannt, weil er neu ist:** ob die Teil-Ablösung den
richtigen Schnitt hat — ob abgelöst ist, was durch den bewegten Zielstand sein Objekt verloren
hat, und nichts darüber hinaus. Der Schnitt läuft am **Gegenstand**, nicht an der Überschrift, und
umfasst deshalb zwei Stücke in zwei verschiedenen Abschnitten jener Datei (§Was der Teil-Supersede
umfasst). Die Runde prüft beide Richtungen: **zu eng** wäre ein Schnitt, der einen Auftrag in
Kraft ließe, der weiter `v6.7.1` anordnet; **zu weit** einer, der Festlegung 2 oder die auf ihr
beruhende Durchgangs-Pflicht mitnähme.

Bis dahin ist sie ein Architect-Verdikt und das Übergabe-Artefakt, das der Schnitt des
Tausch-Slice und der des Durchgangs als Constraint lesen; sie ist nicht eingefroren
([`AGENTS.md`](../../../AGENTS.md) §3.4 bindet ab `Accepted`).

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts entscheiden, die Wahl fällt faktisch beim ersten Durchgang | kein Aufwand; der Abschnitt ist byte-gleich, also „egal" | *egal* ist gemessen falsch: die Prozedur delegiert, und einer der Delegate nimmt der `AGENTS.md` eine Pflicht weg, die heute als `authority: AGENTS.md` in der Gate-Config steht. [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 verlangt für diesen Fall ausdrücklich eine Begründung. Und die vorhandene Entscheidung nennt ein Ziel, das kein Pin je trägt — der Vollzug liefe ohne regierende Fassung |
| B — die gepinnte Fassung `v6.5.0` regiert | sie liegt im Baum und ist netzlos lesbar; sie ist bis zum Tausch ohnehin der Ist-Maßstab | ihre Pflichtgliederung für `harness/README.md` kennt weder die Ein-Index-Setzung noch die benannte Sensor-Vorlage; ein Form-Vergleich nach B liest `AGENTS.md` §4 grün und fordert den Nachzug nie. Der Ist-Maßstab bleibt unberührt — [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 2 trennt ihn von der Prozedur, und B verwechselt beide |
| C — [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) unangetastet lassen und den Vollzug auf `v6.7.2` mitlaufen lassen, weil der Bugfix drei Zeilen groß ist | billigste Antwort; das Delta zwischen den zwei Zielen ist kleiner als jede Messtoleranz, und die Dateimenge des Durchgangs ist identisch | die Größe des Deltas ist nicht das Kriterium, sondern die **Klammer**: [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) bindet Reproduzierbarkeit an den Tag, und fünf Pin-Stellen würden `v6.7.2` tragen, während die einzige Entscheidung darüber `v6.7.1` nennt. Genau so sieht der stille Auto-Bump eine Ebene höher aus, den **beide** Fassungen wortgleich verbieten — nur dass er sich diesmal auf ein `Accepted` beruft. Und die Setzung des Auftraggebers wäre nirgends gebucht |
| D — voller `Supersedes` auf [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) | ein Schnitt statt zweier; die Lage ist in **einer** Datei nachlesbar, niemand muss zwei Entscheidungen zusammenlesen | er nähme Festlegung 2 mit, und die ist richtig und gebraucht: der `v6.5.0`-Nachweis hängt allein an ihr. Und er zöge eine Kaskade über `matrix.status` in [`.d-check.yml`](../../../.d-check.yml) nach sich: verboten wären danach Verweise auf die dann `superseded` Datei aus den drei Klassen `spec-straten`, `adr` und `slice`, außerhalb der drei Abschnitte in `matrix.exclude-sections` — der ADR-Index und `harness/conventions.md` fallen aus jeder Klasse und blieben unberührt. Gemessen liegt die Mehrheit der lebenden Verweise in der Klasse `adr` (`git grep -oE '\]\([^)]*0043-ziel-fassung-regiert-den-sprung-v671\.md[^)]*\)' -- ':!docs/reviews' ':!docs/plan/planning/done' \| wc -l` gegen dieselbe Abfrage über `'docs/plan/adr/[0-9]*.md'`; beide wandern, [`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2). **Nicht** dagegen spricht die Statuszeile: Der volle Supersede-Übergang ist in diesem Repo ausdrücklich zugelassen (§Was der Teil-Supersede umfasst) |
| E — Teil-Supersede auf Festlegung 1, aber Delta-Basis neu auf `v6.5.0` gesetzt | trennt zwei Sprünge sauber; jeder Durchgang bleibt klein und einzeln prüfbar | er streicht 32 Dateien und +624/−153 Zeilen Prüffläche, ohne dass jemand sie gesehen hat, und das Nachweis-Feld der `v6.5.0`-Zeile bliebe dauerhaft leer. Er wäre außerdem eine **zweite Fassung** der Leseregel aus [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) Festlegung 2, die dann in zwei Dateien verschieden dastünde |
| **F — gewählt: Ziel-Fassung `v6.7.2` für diesen Sprung, Teil-Supersede auf Festlegung 1 und den Auftrag, der sie vollzieht, Delta-Basis `v6.0.0` durch Anwendung der fortbestehenden Leseregel** | entscheidet den anstehenden Fall auf Gründen, die hier gemessen sind — Achse, beide Stufen, Netto je Sektion, die Gate-Config als ablesbare Wirkung — und löst genau das ab, was sein Objekt verloren hat, ohne das mitzunehmen, was es behalten hat: keine zweite Fassung einer geltenden Regel, keine Kaskade über `matrix.status`, und die Vorgängerin bleibt als Ganzes zitierbar. Die Wahl steht auf diesen zwei Gründen und braucht keinen dritten — die Statuszeile ist keiner (Option D) | die Lage ist in **zwei** Dateien nachzulesen: wer die Delta-Basis wissen will, folgt dem Zeiger auf die Vorgängerin. Der Umfang der Ablösung ist nicht mehr an einer Abschnitts-Überschrift abzulesen, sondern an zwei benannten Stellen. Und der nächste Sprung erbt die Messpflicht ein sechstes Mal |

## Konsequenzen

- **Positiv:** Der Sprung auf den gesetzten Zielstand hat eine benannte, zitierte Quelle, bevor das
  erste Konformitäts-Urteil fällt — und der Tag, den die fünf Pin-Stellen tragen werden, ist
  derselbe, den die regierende Entscheidung nennt.
- **Positiv:** Die Leseregel für die Delta-Basis übersteht den Wechsel des Zielstands, ohne
  abgeschrieben zu werden. Der ausstehende `v6.5.0`-Nachweis bleibt eingeschlossen.
- **Positiv:** *Byte-gleich* ist zum fünften Mal entkräftet — nun an fünf Gegenbeispielen in drei
  verschiedenen Sektionen.
- **Positiv:** Der Zuwachs von `v6.7.1` auf `v6.7.2` ist beziffert und kostet den Durchgang keine
  zusätzliche Datei. Wer den Sprung für teurer hält, weil das Ziel sich bewegt hat, liest die
  Messung.
- **Negativ:** Diese Entscheidung trägt in Festlegung 1 auf **einem** Grund, wie ihre zwei
  Vorgänger. Fiele der Delegat-Delta-Befund weg, bliebe nichts.
- **Negativ:** Die Teil-Ablösung ist an der abgelösten Datei nicht sichtbar — sie steht in deren
  Index-Zeile. Wer [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) direkt öffnet, liest
  eine Festlegung 1, deren Sprung nicht mehr stattfindet, und darunter einen Baum-Tausch-Auftrag
  auf einen Tag, den kein Pin trägt — ohne dass die Datei es sagt. Das ist der Preis von
  [`AGENTS.md`](../../../AGENTS.md) §3.4 und wird hier nicht geheilt.
- **Negativ:** Drei weitere Stellen jener Datei sind durch den bewegten Zielstand falsch geworden,
  ohne abgelöst zu sein: das Kopffeld `Kopplung:` und der Punkt *„Folgepflicht (Architect), im
  selben Commit eingelöst"*, die beide §Baseline im Präsens die Setzung auf `v6.7.1` zuschreiben,
  und in §Kontext der Satz *„Der gesetzte Zielstand ist `v6.7.1`."* Sie ordnen nichts an und haben
  damit kein Objekt für eine Ablösung; diese Entscheidung benennt sie (§Was der Teil-Supersede
  umfasst) und korrigiert sie nicht. Der geltende Zustand steht in §Baseline von
  [`harness/conventions.md`](../../../harness/conventions.md).
- **Negativ:** Bis zum Tausch ist die regierende Fassung nicht im Arbeitsbaum, und auch die
  **gepinnte** Seite der Messung ist nur über den Klon exakt reproduzierbar (§Die Achse). Ein
  netzloser Lauf ist auf diese ADR angewiesen.
- **Negativ:** Die Kosten eines ausgefallenen Durchgangs werden sichtbar gehalten, nicht kleiner.
  Wer auch diesen ausfallen lässt, erbt eine noch größere Basis.
- **Negativ / [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6):**
  **Kein Sensor.** Kein Gate liest, nach welcher Fassung ein Durchgang lief, keines liest, ab
  welchem Stand er misst, und keines hält eine Zielstand-Buchung gegen die Entscheidung, auf die
  sie zeigt. Träger sind der Zeiger in §Baseline von `harness/conventions.md` und der Review des
  Durchgangs-Ergebnisses.
- **Folgepflicht (Architect), im selben Commit eingelöst:** §Baseline von `harness/conventions.md`
  trägt die Zielstand-**Setzung** auf `v6.7.2` und den Zeiger auf diese Entscheidung als regierende
  Fassung; der ADR-Index bekommt die Zeile dieser Datei. Den **Vollzug** bucht der Lauf, der ihn
  ausführt, in der Drei-Teil-Form von
  [ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2 (`Proposed`,
  siehe Bezug-Feld).
- **Folgepflicht (Architect), fällig nach dieser Entscheidung:** die Reviewer-Runde, die der
  Acceptance-Trigger verlangt, und der Accept-Übergang, der ihren Report namentlich nennt. **Mit
  ihm, nicht davor**, bekommt die Status-Zelle von
  [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) ihren Zusatz, und der Zeiger in
  §Baseline von `harness/conventions.md` nennt den neuen Statuswert.
- **Folgepflicht (Planner), fällig vor dem Vollzug:** zwei Slices sind zu schneiden — der
  **Baum-Tausch** samt Nachzug der fünf Pins auf `v6.7.2` und den am Asset gemessenen sha256
  (kanonisch ist das Makefile-Paar; die vier übrigen sind fail-closed daran gekoppelt), und der
  **Adaptions-Durchgang** mit Delta-Basis `v6.0.0`; weil er den `v6.5.0`-Nachweis einschließt, ist
  seine Kennung der Wert **beider** offenen Nachweis-Felder der Buchung — das der `v6.5.0`-Zeile
  und das der Zeile, die der Vollzug anlegt. **Die erste Hälfte tritt
  an die Stelle der ersten Hälfte des gleichnamigen Punktes in
  [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) §Konsequenzen, die mit dieser
  Entscheidung abgelöst ist** (§Was der Teil-Supersede umfasst); **die zweite gilt dort fort** und
  steht hier wiederholt, damit der Auftrag an einer Stelle als Ganzes lesbar bleibt — sie sagt
  dasselbe, und eine Abweichung zwischen beiden wäre ein Defekt dieser Datei, nicht jener.
  **Eingetragen wird er nicht in diesem Punkt:** §Baseline von `harness/conventions.md` ist
  Architect-Eigentum ([`AGENTS.md`](../../../AGENTS.md) §3.8), und die Buchung steht in der
  Architect-Folgepflicht darüber. Der Wortlaut beider Pläne ist Planner-Eigentum
  ([ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md)); diese Entscheidung ist das
  Übergabe-Artefakt, nicht der Text.
- **Vorgabe des Auftraggebers für den Durchgang — hier verbucht, nicht abgewogen:** Der
  Adaptions-Durchgang übernimmt die Ziel-Fassung **vollständig**; eine Abweichung wird nicht
  gesetzt. Das trifft genau **einen** der fünf Ausgänge der gewählten Prozedur — *widerspricht*,
  den einzigen, *„an dem das Delta die Antwort **nicht** vorgibt"*, weil dort *„das Repo eine
  Wahl"* hat: *„Entweder die Adaption gilt in ihrem Geltungsbereich weiter … oder das Repo
  **übernimmt** die neue Regel"* (`v6.5.0`, byte-gleich in `v6.7.2` — §Stufe (b) —,
  `modul-02-harness-bootstrap.md`, §Freshness-Audit der vendored Baseline (Schritt 2)). Diese Wahl
  ist damit für diesen Durchgang getroffen, bevor er läuft, und sie ist die des Auftraggebers: Der
  Architect schreibt den Norm-Text, er wägt den Ausgang nicht ab. **Unberührt bleibt alles
  andere** — der Befund je Eintrag mit eigenem Beleg
  ([ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 4), die vier Ausgänge, deren
  Antwort das Delta ohnehin vorgibt, und der Fall *übernehmen wollen und noch nicht können*, den
  dieselbe Stelle als **Carveout** mit Auflösungs-Trigger führt und nicht als Adaption. **Eine
  allgemeine Regel darüber, wer diese Wahl trifft, entsteht hier nicht.**
- **Folgepflicht (Architect), fällig im Durchgang, nicht hier:** die Entscheidung über
  `targets.authority` und die Gate-Tabelle in `AGENTS.md` §4 — beide Dateien sind
  Architect-Eigentum ([`AGENTS.md`](../../../AGENTS.md) §3.8). **Dass** übernommen wird, steht mit
  der Vorgabe oben fest; offen sind die **Form** des Nachzugs und die Frage, ob er eine Senkung
  nach §3.5 ist — beides gehört in jene Abwägung.
- **Folgepflicht (Architect), eigener Vorgang, nicht hier — und bis dahin eine benannte Lücke:**
  Die Sichtbarkeit dieser Teil-Ablösung hängt allein an der Status-Zelle des ADR-Index. Der
  Fundweg, den [`docs/plan/adr/README.md`](README.md) §Konventionen für angeordnete Zusätze
  dokumentiert, sucht nach der **älteren** der beiden Kopffeld-Formen und erreicht damit die
  neuere nicht, die diese Entscheidung führt (`**Supersedes (Teil):**`, Kopf dieser Datei).
  Zwei Formen leben nebeneinander, drei Dateien je Form:
  `git grep -lE '^\*\*(Revidiert \(Teil-Supersede\)|Supersedes \(Teil\)):\*\*' -- 'docs/plan/adr/0[0-9]*.md'`
  (**keine Erwartungswerte** — beide Mengen wachsen). §Konventionen nennt nur die ältere und zählt
  drei ADRs auf; die neuere führt [ADR-0032](0032-eingefrorene-referenz-folgt-ihrem-rumpf.md) ein,
  der Rückstand ist also älter als diese Datei. Geheilt wird er hier **nicht**: Die Korrektur
  schreibt neben dem Fundweg auch die Aufzählung darunter fort, und dafür ist je getragener Zelle
  die anordnende Stelle zu bestimmen — eine eigene Messung, die dieser Lauf nicht gefahren hat.
  Diese ADR behauptet dafür keine Deckung
  ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Folgepflicht (Architect), eigener Vorgang, nicht hier — die zweite benannte Lücke:** Diese
  Entscheidung zitiert [ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
  Festlegung 2 an drei Stellen als bindend — im Bezug-Feld, in `Kopplung:` und in der
  Architect-Folgepflicht oben —, und jene Datei steht auf `Proposed` und führt keinen
  Acceptance-Trigger:
  `grep -m1 '^\*\*Status:\*\*' docs/plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md`.
  Der Status ist an allen drei Stellen genannt. **Ob** eine nicht angenommene Entscheidung so
  zitiert werden darf, und was jene Datei braucht — einen nachgereichten Trigger, einen
  Accept-Übergang oder eine Folge-ADR —, ist hier **nicht** entschieden. Die Frage ist älter als
  diese Datei: Die bereits angenommene
  [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) trägt dieselbe Bezugnahme und ist
  eingefroren ([`AGENTS.md`](../../../AGENTS.md) §3.4). Diese ADR behauptet dafür keine Deckung
  ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Darüber hinaus ändert diese ADR keine Datei außer sich selbst, dem ADR-Index und §Baseline von
  `harness/conventions.md`.**

## Fitness Function (falls maschinell prüfbar)

**Gebaut: keine** — und das ist die Eigenschaft der Frage, nicht ein Versäumnis.

| Kandidat | Warum er die Regel nicht misst |
|---|---|
| `make baseline-verify` | belegt, **welcher Tag vendored** ist (genau einer, integer, vollständig). Nach welcher Fassung ein Durchgang **gelaufen** ist und ab welchem Stand er maß, sieht er nicht |
| `make docs-check` | prüft Auflösbarkeit von Zielen und Ankern, nicht die Herkunft eines Verfahrens; sein `matrix`-Modul verbietet Verweise auf `superseded`, kennt aber keine Teil-Ablösung, und sein `targets`-Modul prüft Deckung gegen **eine** `authority`-Datei, nicht, ob diese die richtige ist |
| `make comment-claims` | hat keine Markdown-Datei im Prüfbereich |
| `make adr-immutable` | hält den Kern einer `Accepted`-ADR über einer Range unverändert — er belegt, dass an [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) nichts geschrieben wurde, nicht, ob die Teil-Ablösung richtig geschnitten ist |
| `make regelwerk-check` | hält den gepinnten Tag gegen sein Release-Asset (Netz, nicht in `make gates`) — eine Aussage über **einen** Tag, keine über die Wahl zwischen zweien |
| `make baseline-freshness` | meldet einen neueren Upstream-Tag (Netz, nicht in `make gates`) — der Anlass einer Setzung, nicht ihre Buchung |

**Nicht mechanisierbar:** ob ein Durchgang der gewählten Prozedur *gefolgt* ist, ist ein Urteil
über einen Vorgang — dieselbe Grenze, die
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md),
[ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md),
[ADR-0036](0036-ziel-fassung-regiert-den-sprung-v600.md),
[ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) und
[ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) für sich benennen.

**Teilweise mechanisierbar, hier nicht gebaut:** Die Buchung in §Baseline nennt einen Ziel-Tag und
zeigt auf eine ADR; ein Sensor läse beide und verglich den Tag im Titel der ADR mit dem der
Buchung. Er fände den Fall, den Option C oben beschreibt — Buchung und regierende Entscheidung auf
verschiedene Tags —, und er setzte voraus, dass der Tag im ADR-Titel steht, was heute eine
Gewohnheit ist und keine Regel. Ihn hier als vorhanden auszugeben wäre
[`AGENTS.md`](../../../AGENTS.md) §3.1 eine Ebene tiefer.

## Re-Evaluierungs-Trigger

- **Wenn der nächste Sprung ansteht** *(feedforward — die Messung aus
  [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 läuft in jenem Sprung, kein
  Gate meldet sie)*: Festlegung 1 gilt **nur** für `v6.5.0` → `v6.7.2`. Der nächste Sprung misst
  neu — die Achse **zuerst**, dann beide Stufen und das Delegat-Delta netto je Sektion.
- **Wenn der Zielstand sich erneut bewegt, bevor dieser Sprung vollzogen ist** *(beobachtbar an
  §Baseline von `harness/conventions.md`)*: dann verliert Festlegung 1 ihr Objekt wie die ihrer
  Vorgängerin, und der Schnitt dieser Teil-Ablösung ist die Vorlage — nicht ihr Ergebnis. Ob eine
  weitere Teil-Ablösung oder eine andere Form richtig ist, entscheidet jener Lauf.
- **Wenn der vendored Baum wieder byte-gleich mit dem `lab/`-`git`-Baum wird oder seine
  Umschrift-Klasse wechselt** *(beobachtbar an `diff -rq -x SHA256SUMS .harness/baseline/<tag>`
  gegen ein `git archive` desselben Tags)*: dann ist die Achsen-Korrektur gegenstandslos oder
  anders zu ziehen, und der Rausch-Abzug ändert sich mit ihr.
- **Wenn ein Sprung sein Delegat-Delta ausschließlich in Sektionen trägt, in die der
  Freshness-Audit nicht delegiert** *(beobachtbar am Sektions-Netto-Diff der vier Zieldateien)*:
  dann trägt der einzige Grund von Festlegung 1 nicht, und der Fall braucht eine eigene
  Begründung — diese ADR liefert sie nicht.
- **Wenn ein Durchgang seine Basis erreicht, ohne dass eine Re-Baseline-Zeile ein leeres
  Nachweis-Feld trägt** *(beobachtbar an §Baseline von `harness/conventions.md`)*: dann fallen
  zuletzt-vendored und zuletzt-geprüft zusammen, und Festlegung 2 kostet nichts — die Leseregel in
  [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) Festlegung 2 bleibt davon unberührt.
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
| 2026-09-12 | **Proposed** | Architect-Lauf auf die Zielstand-Setzung des Auftraggebers vom selben Tag. Anlass sind der fünfte Eintritt des zweiten Falls aus [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 und der erste Re-Evaluierungs-Trigger von [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md), dessen Sprung-Ziel die Setzung überholt hat |
| 2026-09-12 | **Accepted** | **Angenommen auf Weisung des Auftraggebers vom 2026-09-12, vollzogen in der Architect-Rolle.** **Der Acceptance-Trigger ist eingelöst**, und der Beleg, den er verlangt, ist die **Reviewer-Bestätigungsrunde vom 2026-09-12 zu ADR-0044, Runde 2** — Kennung `2026-09-12-adr-0044-ziel-fassung-v672-r2` ([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1: Kennung, kein Pfad-Link) —, gefahren in frischem Kontext gegen [ADR-0018](0018-ziel-fassung-regiert-die-migration.md), [ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md), [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) und die teilweise abgelöste [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md); ihre Kategorie-Summary nennt **kein HIGH und kein MEDIUM**, ihr Report liegt damit ohne blockierenden Befund in `docs/reviews/`. Den eigens benannten Prüfgegenstand — den Schnitt der Teil-Ablösung — prüft sie in **beide** Richtungen und findet ihn in beiden richtig. Dass es die **zweite** Runde ist, fordert [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2: Runde 1 meldete einen blockierenden Befund, Beleg ist darum eine erneute Runde derselben prüfenden Rolle und nicht die Nachmessung des Kontexts, der ihn auflöste. **Die vier LOW dieser Runde sind vor diesem Umschlag behoben** — die Zählung der falsch gewordenen Präsens-Stellen, das verbatim nachgezogene Zitat der fortgeltenden Hälfte, die Ausgabe-Position der zwei Kommandos über §Baseline und der `Proposed`-Status der zitierten [ADR-0031](0031-regierende-fassung-und-ort-der-zielstand-setzung.md); Festlegung 2 deckt das, denn sie verlangt eine weitere Runde nur nach einem **blockierenden** Befund. **Mit diesem Übergang, nicht davor,** bekommt die Status-Zelle von [ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) im ADR-Index ihren Zusatz, und der Zeiger in §Baseline von `harness/conventions.md` nennt den neuen Statuswert. **Ab hier bindet [`AGENTS.md`](../../../AGENTS.md) §3.4:** Korrekturen entstehen als Folge-ADR mit `Supersedes`. |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0044` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
