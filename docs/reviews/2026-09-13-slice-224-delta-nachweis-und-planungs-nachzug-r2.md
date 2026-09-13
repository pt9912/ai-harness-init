# Review slice-224 — Runde 2: löst die Nacharbeit die Befunde der ersten Runde auf?

**Rolle:** Reviewer · **Datum:** 2026-09-13 · **Commit:** `6803ed31` (1 Datei, +66/−13) ·
**Runde 1:** [`2026-09-12-slice-224-…`](2026-09-12-slice-224-delta-nachweis-und-planungs-nachzug.md)
(1 HIGH · 5 MEDIUM · 2 LOW · 1 INFO, Verdikt *blockierend*) ·
**Verifikation:** [`2026-09-13-…-verify`](2026-09-13-slice-224-delta-nachweis-und-planungs-nachzug-verify.md) ·
**Plan:** [`slice-224`](../plan/planning/done/slice-224-delta-nachweis-und-planungs-nachzug.md) ·
**Constraints:** [`ADR-0044`](../plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) ·
[`AGENTS.md`](../../AGENTS.md) §3.6 · §3.8 · §3.10 ·
[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)

**Schnitt dieses Laufs — eng, ausdrücklich.** Geprüft ist ausschließlich, ob die Nacharbeit die
sieben Befunde der ersten Runde auflöst, dazu der Posten des Verifiers. Kein zweiter Durchgang über
die 42 Posten. Alle Zahlen stehen neben dem Kommando, das sie liefert, gefahren über `6803ed31`
bzw. im Kurs-Klon `/Development/KI/ai-harness-course` (`v6.0.0`/`v6.7.2`) — **keine
Erwartungswerte**. Nur lesende Kommandos, nichts geändert.

---

## Urteil je Befund

### HIGH-1 — **aufgelöst in der Buchung, nicht in der Adresse**

Die **Sach-Hälfte trägt.** Die Zeile steht auf *übernommen*, zitiert wörtlich richtig, und der
lizenzierende Absatz aus `v6.0.0` ist tatsächlich gestrichen:

```sh
sed -n '360p' .harness/baseline/v6.7.2/regelwerk/grundlagen-source-precedence.md
# -> **Welle- und Slice-Kennungen sind Namen, nicht Nummern — unabhängig von der
grep -c 'dichte Nummern' .harness/baseline/v6.7.2/regelwerk/grundlagen-source-precedence.md   # 0
cd /Development/KI/ai-harness-course && git show v6.0.0:lab/regelwerk/grundlagen-source-precedence.md | grep -c 'dichte Nummern'   # 1
```

Damit ist der Kern von HIGH-1 weg: Die Feststellung ist durch eine Entscheidung ersetzt, die
Entscheidung hat einen Inhalt (Namen ab jetzt, kein Nachrüsten des Bestands) und einen Empfänger.

**Die Adresse nimmt die Sendung in ihrer heutigen Form nicht an.** Die Zelle benennt als Träger
*„eine Kopf-Marke auf einen **neuen Eintrag**, der diese Cutoff-Setzung trägt"* und schickt sie an
`slice-225`. Dessen §1 schließt genau das aus:

```sh
cd /Development/KI/ai-harness-init
grep -n 'Kein neuer `MR`-Eintrag' docs/plan/planning/open/slice-225-gate-index-steht-einmal.md
# -> 143:- **Kein neuer `MR`-Eintrag.** … *Bestand bleibt bewusst stehen* — die 52 aktiven Einträge werden geprüft, nicht vermehrt.
grep -n 'kein neuer `MR`-Eintrag' docs/plan/planning/open/slice-225-gate-index-steht-einmal.md
# -> 34:**kein neuer `MR`-Eintrag** — ein Eintrag bucht eine *gewollte* Abweichung   (Kopf)
```

Der Ausschluss steht zweimal — im Kopf und als eigener §1-Punkt — und seine Begründung ist
*„die Vorgabe des Auftraggebers schließt gewollte Abweichungen aus … ein Eintrag ohne Abweichung
wäre Buchführung über nichts"*. Genau diese Prämisse widerlegt die neue Zelle: Der Bestand behält
`slice-<NNN>`, während die Ziel-Fassung Namen verlangt, und die Baseline verlangt für die geltende
Form eine **Deklaration** in `harness/conventions.md` (§Vergabe, letzter Absatz). `MR-000` führt
die alte Form heute noch:

```sh
grep -n 'slice-NNN' harness/conventions/MR-000-baseline-aussage.md    # 23:  ID-Schema: … `CO-NNN`, `slice-NNN`,
```

**Failure-Szenario:** Der Architect-Lauf von slice-225 liest §1, überspringt den Eintrag, und die
Deklaration entsteht nie — die Sendung endet mit der Closure dieses Plans, wie bei den zwei
Sendungen aus MEDIUM-5. Die Gegenrichtung existiert (DoD-2 von slice-225: *„die Grenze ist §9 von
slice-224"*), und damit ist es dieselbe Naht, die Runde 1 als **LOW-2** geführt hat — jetzt mit dem
HIGH-Posten darauf.

`klasse` genannte Adresse nimmt die Sendung nicht an · `verifizierbar` nein (kein Gate liest
Plandateien gegeneinander) · **Rest-Kategorie: MEDIUM** — nach der Kalibrierung der ersten Runde,
die dieselbe Klasse zweimal unterhalb von HIGH einordnet (MEDIUM-4, LOW-2). Er liegt in
`slice-225` (`open/`, änderbar) und ist **Planner-Arbeit**, nicht Arbeit dieses Slice.

### MEDIUM-1 — **aufgelöst für 9 der 11 tragenden Zeilen, offen für eine**

Das neue Kommando ist **nicht blind** — selbst nachgefahren über alle Zeilen, die sich auf
Reformatierung/„keine Inhaltsänderung" stützen. Es filtert keine Zeilenklasse, sondern vergleicht
die whitespace-normalisierten Volltexte:

```sh
cd /Development/KI/ai-harness-course
for f in grundlagen-begriffe modul-08-agentenrollen modul-16-produktiver-betrieb \
         grundlagen-bootstrap grundlagen-klassifikation modul-04-adrs modul-11-verification \
         modul-12-replay-evaluierung modul-14-docker-harness grundlagen-durchsetzungsschicht \
         modul-02-harness-bootstrap grundlagen-referenz-richtung; do
  printf '%-34s %s\n' "$f" "$(diff <(git show v6.0.0:lab/regelwerk/$f.md | sed 's/[[:space:]]\+/ /g; s/ *| */|/g') \
                                   <(git show v6.7.2:lab/regelwerk/$f.md | sed 's/[[:space:]]\+/ /g; s/ *| */|/g') | grep -cE '^[<>]')"
done
# grundlagen-begriffe 3 · modul-08 4 · modul-16 2 · bootstrap/klassifikation/modul-04/modul-11/
# modul-12/modul-14/durchsetzungsschicht je 0 · modul-02-harness-bootstrap 6 · referenz-richtung 14
```

Die drei korrigierten Zellen stimmen exakt: `grundlagen-begriffe` = drei **neue Tabellenzeilen**
(`Plan (vor Code)`, `RTM`, `harness/sensors/<target>.md`), `modul-08` = zwei **Tabellenzellen** mit
Kennungs-Notation, `modul-16` = eine **Listenzeile**. Damit sind genau die zwei Blindstellen des
alten Kommandos positiv getroffen.

**Offen:** Zwei Zeilen, die dieselbe Behauptung tragen, sind **nicht** neu gefahren worden. Bei
einer davon fällt sie:

```sh
cd /Development/KI/ai-harness-course
diff <(git show v6.0.0:lab/regelwerk/modul-02-harness-bootstrap.md | sed 's/[[:space:]]\+/ /g; s/ *| */|/g') \
     <(git show v6.7.2:lab/regelwerk/modul-02-harness-bootstrap.md | sed 's/[[:space:]]\+/ /g; s/ *| */|/g') | head -12
# Zeile 148: Zelle erhält "`AGENTS.md` 1 → 2 (Source Precedence + Hard Rules)"
# Zeile 156: Zelle verliert "`AGENTS.md` §4 Sub-1 → Sub-2"
# Zeile 397: Anker-Umbenennung — das Einzige, was die Zelle im Plan nennt
```

Die Zelle im Plan sagt *„reine Anker-Umbenennung eines Querverweises, keine Inhaltsänderung"* und
deckt damit einen von drei Hunks. Der zweite Hunk ist inhaltlich die *Gate-Index-steht-einmal*-Folge
(`AGENTS.md` §4 trägt das Sensors-Roster nicht mehr) — derselbe Gegenstand, den andere Zeilen an
`slice-225` schicken. Die **Antwort** *schon erfüllt* bleibt damit plausibel (die Konsequenz ist
über `grundlagen-harness-dateien`/`modul-13`/`AGENTS.template.md` bereits gebucht), der **Beleg**
ist es nicht. `grundlagen-referenz-richtung` (14 Zeilen) trägt denselben Beleg-Defekt, aber die
Änderung ist eine **Streichung** duplizierter Norm — *„keine neue Pflicht"* hält dort.

`klasse` Beleg-Kommando misst nicht die behauptete Eigenschaft · **Rest-Kategorie: MEDIUM**
(unverändert die Kategorie aus Runde 1, dort nicht blockierend).

### MEDIUM-2 — **aufgelöst**

Die Zeile trägt jetzt die 62-Zeilen-Sektion mit Beleg und zieht den Schluss, die Setzungspflicht
binde nur ein Repo, das vom Default *„der Slice entlastet"* abweicht. Der Schluss **trägt**, und er
trägt aus einem stärkeren Grund, als die Zelle nennt: Dieses Repo konfiguriert die entlastende
Spalte nicht — es gibt keinen `trace:`-Block, und das `matrix`-Modul ist die Richtungs-Prüfung, die
`grundlagen-traceability.md` ausdrücklich von der RTM unterscheidet:

```sh
cd /Development/KI/ai-harness-init
grep -c '^trace:' .d-check.yml                 # 0
grep -n '^modules:' .d-check.yml               # links, anchors, ids, matrix, codepaths, spans, planning, targets
sed -n '/^matrix:/,/^codepaths:/p' .d-check.yml | grep -c 'from:.*to:'   # 2 — Referenz-Richtung, keine Anforderungs-Abdeckung
```

Dass die RTM dieses Repos im Übrigen einen Empfänger hat, ist ebenfalls gegeben und im Beleg nicht
genannt: `docs/plan/planning/open/slice-192-rtm-sieht-alle-anforderungen.md`. Nicht blockierend,
kein Rest.

### MEDIUM-4 — **aufgelöst**

Die drei Kennungen stehen noch im Satz, aber nicht mehr als Adresse: Der Text sagt jetzt, dass
**keiner** der drei den Gegenstand trägt, und nennt den Zustand beim Namen (*„sie bleiben hier
liegen, **ohne benannten Folge-Träger**"*). Das Failure-Szenario aus Runde 1 — ein Lauf öffnet die
drei und findet nichts — ist damit ausgeschaltet, und die Ausschluss-Klasse *Schicht-Abgrenzung*
braucht nach `modul-05-planning-harness.md` §Ziel-Form: Slice keine Adresse. Der Bestand bleibt
messbar und unverändert:

```sh
git grep -cE 'slice-<NNN>|welle-<NN>' -- internal/emit/templates
# close-welle.md:2 · implement-slice.md:4  -> 6
```

### MEDIUM-5 — **aufgelöst: Risiko, keine verdeckte Lieferung**

Das neue §6-Risiko benennt **beide** Fälle einzeln, nennt je den Mechanismus (Zeitdokument ohne
lesenden Knoten · §9 erzeugt für den Reviewer gar keine Zeile), verweist auf
[`AGENTS.md`](../../AGENTS.md) §3.10 für die Trägerschaft und endet auf `Ausgang: offen bis zur
Closure` — einer der drei zulässigen Zwischenstände für einen Slice in `in-progress/`. Keine
Scheinadresse, keine Selbst-Entlastung. Die Gegenprobe, dass der Wert `Reviewer` aus der
Ziel-Spalte verschwunden ist, statt nur aus der Legende:

```sh
F=docs/plan/planning/done/slice-224-delta-nachweis-und-planungs-nachzug.md
sed -n '/^| Posten (Datei im Kurs-Klon)/,$p' "$F" | grep -E '^\| `lab/' | sed -E 's/.*\| ([^|]*) \|$/\1/' | sort | uniq -c
#  1 Implementer (Übergabe) · 1 slice-213/slice-214 · 33 slice-224 · 7 slice-225   — kein `Reviewer`
```

Dass §3 (`:260`) die Übergabe-Artefakte weiterhin als *„an slice-225, Implementer, Reviewer"*
aufzählt, ist im §9-Intro ausdrücklich benannt und in §6 gebucht — offen gelegt, nicht verdeckt.

### MEDIUM-3 / LOW-2 — **Stehenlassen trägt**

Beides ist fremdes Rollen-Eigentum, und beides blieb unberührt:

```sh
git show --name-only --format= 6803ed31        # nur die Plandatei von slice-224
```

MEDIUM-3 ist der Wortlaut von **DoD-2** — [`AGENTS.md`](../../AGENTS.md) §3.10 verbietet der
ausführenden Rolle ausdrücklich, ihr eigenes Abnahmekriterium umzuschreiben; Runde 1 hat das selbst
so festgestellt. LOW-2 liegt in `slice-225` §1/DoD-2, also im Plan einer anderen Rolle in `open/`.
Der Implementer hat in beiden Fällen gemeldet statt geschrieben — das ist der richtige Zug. **Beide
Posten sind damit nicht erledigt, sondern übergeben**, und ihr Empfänger ist der Planner.

### LOW-1 — **aufgelöst, Zahlen stimmen**

Unabhängig nachgefahren, nicht mit dem Kommando des Plans:

```sh
F=docs/plan/planning/done/slice-224-delta-nachweis-und-planungs-nachzug.md
sed -n '/^| Posten (Datei im Kurs-Klon)/,$p' "$F" | grep -E '^\| `lab/' | awk -F'|' '{print $4}' | sed 's/^ *//;s/ *$//' | sort | uniq -c
#  29 schon erfüllt · 11 übernommen · 1 übernommen (teilweise) · 1 übernommen (Übergabe)   -> 29 / 13, Summe 42
sed -n '/^| Posten (Datei im Kurs-Klon)/,$p' "$F" | grep -E '^\| `lab/' | grep -vcE '\| slice-224 \|$'
#  9
```

29 + 13 = 42 und 9 Übergaben sind bestätigt; die Klammerzusätze sind im Kopf jetzt als Verfeinerung
von *übernommen* deklariert, nicht als dritte und vierte Antwort.

---

## Posten des Verifiers: Zähler `3×` gegen `4×`

**Die Zahl ist falsch — die Diagnose nicht.** Bestätigt ist der Defekt:

```sh
ls docs/plan/planning/observations/BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht/evidence/*.md | wc -l   # 4
grep -n '3×' docs/plan/planning/in-progress/slice-224-*.md   # 333 (§6) · 407 (§8-Tabelle) · 427 (§8-Prosa)
```

Drei Stellen (§6, §8-Tabelle, §8-Prosa) sagen `3×`, das im selben Absatz stehende Kommando liefert
`4` — ein Verstoß gegen
[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2. Die Folgerung *„über der Schwelle"* bleibt richtig.

**Widerlegt ist die Zusatz-Behauptung des Verifiers, die Zahl sei *„bei Entstehung schon falsch"*
gewesen:**

```sh
git log --format='%h %ad %s' --date=format:'%Y-%m-%d %H:%M:%S' -S'folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht` | 3×' -- 'docs/plan/planning/**/slice-224-*.md' | tail -1
# 3270d806 2026-09-12 20:08:16 Rolle Planner: slice-223/224/225 -- Vollzug der Umstellung auf v6.7.2 geschnitten
git ls-tree --name-only 3270d806 docs/plan/planning/observations/BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht/evidence/ | wc -l   # 3
git log --format='%h %ad' --date=format:'%Y-%m-%d %H:%M:%S' --diff-filter=A -1 -- docs/plan/planning/observations/BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht/evidence/slice-223.md
# 1e0f5b48 2026-09-12 22:01:57
```

Geschrieben hat die Zeile der **Planner** um 20:08:16, als das Verzeichnis drei Belege trug; der
vierte kam um 22:01:57 mit der Closure von slice-223 — 1 h 53 min später und sechs Minuten vor der
Beanspruchung von slice-224. Die Zahl war korrekt und ist **überholt worden**, nicht falsch
entstanden. Das verschiebt auch die Zuständigkeit: Die Zeile steht in §6/§8, ist Planner-Text, und
der Lese-Schritt, der dem Eintrag seinen Ausgang zuweist, gehört ohnehin in die Closure.

---

## Negativbefunde (geprüft, ohne Befund)

- **Rollen-Grenzen** — `git show --name-only --format= 6803ed31` zeigt **eine** Datei, die
  Plandatei dieses Slice. Kein `AGENTS.md`, kein `harness/conventions*`, keine ADR, kein
  Produkt-Code, keine emittierte Vorlage, kein Rollen-Anweisungssatz.
  [`AGENTS.md`](../../AGENTS.md) §3.4 / §3.8 / §3.10 eingehalten, Commit nennt die Rolle und die
  Traceability-Kennung.
- **Keine der neun korrigierten/ergänzten Zellen greift auf ein Artefakt einer anderen Rolle vor** —
  alle Sendungen bleiben benannt, keine wird im Lauf vollzogen.
- **Die „korrigiert (Review slice-224 …)"-Marken** in den Zellen und im §9-Intro sind **kein
  Befund**: [`AGENTS.md`](../../AGENTS.md) §3.7 bindet Code, Konfiguration, Skripte und die
  **Zustandsfelder lebender Register** — eine Beleg-Zelle im Fließtext eines Slice-Plans ist
  keines davon, und der Plan wird mit der Closure ohnehin Zeitdokument. Geprüft, nicht übersehen.
- **Die unverändert gebliebenen 33 Zeilen mit Ziel `slice-224`** habe ich in dieser Runde
  ausdrücklich **nicht** erneut geprüft (Schnitt der Runde).

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 2 | genannte Adresse nimmt die Sendung nicht an (Rest von HIGH-1, liegt in `slice-225`) · Beleg-Kommando misst nicht die behauptete Eigenschaft (Rest von MEDIUM-1, eine Zeile: `modul-02-harness-bootstrap.md`) |
| LOW | 1 | Zahl neben ihrem Kommando ist überholt (`3×` gegen `4×`, drei Stellen) |
| INFO | 0 | — |

**Aufgelöst:** HIGH-1 (Kern), MEDIUM-2, MEDIUM-4, MEDIUM-5, LOW-1 · **korrekt übergeben statt
erledigt:** MEDIUM-3, LOW-2 · **teilweise aufgelöst:** MEDIUM-1.

## Verdikt

**Nicht mehr blockierend.** Der eine blockierende Befund der ersten Runde ist in seiner Substanz
behoben: Die Zeile bucht eine Entscheidung statt einer Feststellung, ihr Zitat hält gegen den
vendored Baum, und sie nennt einen Empfänger. Von den übrigen sieben sind vier vollständig
aufgelöst, zwei korrekt an den Planner übergeben statt eigenmächtig geändert, einer zu neun
Elfteln.

**Drei Posten reisen mit, keiner davon in diesem Slice zu erledigen** — alle drei liegen beim
Planner, und der erste ist **Bedingung für den Start von slice-225**, nicht für die Closure von
slice-224:

1. `slice-225` §1 schließt *„keinen neuen `MR`-Eintrag"* aus und nimmt damit genau den Träger
   nicht an, den die HIGH-1-Zelle benennt. Ohne Auflösung dieser Naht — sie ist dieselbe, die
   Runde 1 als LOW-2 führte — entsteht die Deklaration nie, und HIGH-1 öffnet sich dort erneut.
2. Die Zeile zu `modul-02-harness-bootstrap.md` trägt weiter den Beleg *„keine Inhaltsänderung"*,
   den der robustere Vergleich mit sechs Zeilen widerlegt; die Antwort selbst bleibt vertretbar.
3. Der Zähler `3×` ist an drei Stellen von seinem eigenen Kommando überholt (`4`); der Lese-Schritt
   gehört ohnehin in die Closure.
