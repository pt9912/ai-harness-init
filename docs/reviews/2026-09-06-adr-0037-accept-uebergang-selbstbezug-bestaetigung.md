# Bestätigungsprüfung — ADR-0037, der `Accepted`-Übergang und die selbstbezüglichen Zahlen

**Rolle:** Reviewer · **Datum:** 2026-09-06 · **Skill:** `reviewer.md` 1.7.0
**Art:** Bestätigungsprüfung vor dem Status-Übergang, **keine** Runde 8 — der Prüfgegenstand ist
ein einzelner Nacharbeits-Commit und die Frage, ob der Übergang selbst eine Aussage der Datei
umstößt.

## Kopf-Metadaten

- **Prüfgegenstand:** `f5bcd08b` gegen `862d0a01` (`git diff 862d0a01 f5bcd08b`), Gegenstand
  `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md`, Status `Proposed`.
- **Anlass:** zweiter Posten der Accept-Vorprüfung des Architect — eine Falle, die erst mit dem
  Übergang zuschnappt: Die Datei trug Zahlen, deren Messgegenstand sie selbst ist, und die
  `Accepted`-Zeile ist die letzte Änderung vor dem Einfrieren.
- **Auftrag:** vier Punkte — (1) den Übergang simulieren und **jede** Aussage der Datei über sich
  selbst neu messen, (2) die **Fundmenge** prüfen, nicht nur ihr Ergebnis, (3) die
  Erschöpfungs-Aussage ohne Mächtigkeit, (4) selbst erzeugte Abdrücke. Dazu die Trage-Frage: hat
  der Commit etwas außerhalb dieser Klasse bewegt.
- **Eingangs-Kontext (Skill §Eingangs-Kontext):** Diff/Commit-Range ✓ · Hard Rules
  (`AGENTS.md` §3.4/§3.5/§3.6/§3.7/§3.9/§3.11) ✓ · referenzierte aktive ADRs (`ADR-0016`,
  `ADR-0024`, `ADR-0027`, `ADR-0030`, `ADR-0034`) ✓ · `LH-*` (`LH-FA-02`, `LH-QA-01`, `LH-QA-02`) ✓
  · `MR-*` (`MR-025`, `MR-045`, `MR-046`, `MR-051`) ✓ · vorherige Findings am gleichen Modul
  (Runden 1–7 und die verengte Nachprüfung) ✓. **Nicht erhalten und hier benannt:** der Slice-Plan
  `slice-190`; die Aussagen dieser Datei über ihn liegen außerhalb meines Auftrags.
- **Nicht mein Gegenstand:** die inhaltlichen Festlegungen 1–4 (acht Läufe ohne Befund gegen die
  Entscheidung) und die DoD-Abhakung (Verifier).
- **Umgebung:** Messungen mit `git`, `grep`, `sed`, `awk` über Kopien **außerhalb** des
  Arbeitsbaums; keine Host-Toolchain (`AGENTS.md` §3.9). Der Arbeitsbaum blieb während der Messung
  unangetastet.

## Der entscheidende Test — die Simulation des Übergangs

Aufbau: Kopie des Ist-Stands außerhalb des Arbeitsbaums, `**Status:** Proposed` → `Accepted`, und
je eine der zwei realen `Accepted`-Zeilen des Bestands (`ADR-0028` bzw. `ADR-0036`) als letzte
Zeile der Geschichte-Tabelle angehängt.

```sh
S=<scratch>; D=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
cp "$D" "$S/ist.md"
grep -h '^| .*\*\*Accepted\*\*' docs/plan/adr/0028-*.md > "$S/acc28.txt"
grep -h '^| .*\*\*Accepted\*\*' docs/plan/adr/0036-*.md > "$S/acc36.txt"
for v in 28 36; do
  awk -v acc="$(cat $S/acc$v.txt)" \
      'NR==3{print "**Status:** Accepted"; next} {print} NR==773{print acc}' \
      "$S/ist.md" > "$S/sim$v.md"
done
```

Alle sechs selbstbezüglichen Kommandos der Datei (Zeile 771), über die drei Stände gefahren — die
Ziel-Mengen als Mächtigkeit ausgeschrieben, damit die Bewegung sichtbar wird:

| Sonde | ist | + `Accepted` (0028) | + `Accepted` (0036) |
|---|---|---|---|
| Beleg-Form `grep -cE 'Baseline .v6\.0\.0.,'` | 11 | 11 | 11 |
| roher Link-Kopf `grep -oE '[]][(]' \| wc -l` | 117 | 121 | 121 |
| Ziel-Muster zeilenweise `grep -oE '\]\([^)]+\)' \| wc -l` | 117 | 121 | 121 |
| dasselbe umbruch-sicher über `tr '\n' ' '` | 117 | 121 | 121 |
| Ziel-Menge über den **Pfad** (`… \| sort -u`) | 14 | 15 | 16 |
| Ziel-Menge über die **Zeichenkette** (`… \| sort -u`) | 28 | 29 | 30 |
| tag-gepinnte Nennungen (`sed -E 's/\]\([^)]*\)//g' \| grep -oE …`) | 19 | 19 | 19 |

**Keine Erwartungswerte** (`MR-025` Setzung 2) — die Werte stehen hier als Beleg der **Bewegung**,
nicht als Zielwert.

**Ergebnis: keine Zahl der Datei wird durch den Übergang falsch.** Zu keiner der sieben Sonden
steht in der Datei noch ein eingefrorener Wert; es steht das Kommando. Fünf der sieben Werte
wandern nachweislich (die drei Link-Zählungen, beide Ziel-Mengen), zwei stehen still — gezogen sind
alle sieben. Die drei Zählungen, deren **Gleichheit** die Zeile als tragend ausweist, sind in jedem
der drei Stände gleich. Die Falle, um die es ging, ist entschärft.

**Die Sonde des Architect reproduziert exakt.** Seine Commit-Message misst über dem *Vor*-Stand
`862d0a01`; ich habe beides gefahren:

| Stand | Links | Ziel-Menge (Pfad) | Beleg-Form |
|---|---|---|---|
| `862d0a01` (seine `/tmp/p`) | 111 | 12 | 11 |
| `862d0a01` + `Accepted` (0028) | 115 | 13 | 11 |
| `862d0a01` + `Accepted` (0036) | 115 | 14 | 11 |

Das sind Zeichen für Zeichen die Werte seiner Commit-Message. **Und die Aussage der Datei spricht
über einen anderen Stand als seine Sonde** — sie sagt *„an eine Kopie **dieser** Datei"*, also den
Ist-Stand nach dem Commit. Ich habe deshalb nachgemessen (Tabelle oben): über dem Ist-Stand gilt
dieselbe Aussage. Sie ist damit nicht nur reproduziert, sondern für den Gegenstand belegt, über den
sie redet.

## Findings

### M-1 — die neue Erschöpfungs-Aussage klassifiziert 9 der 14 Ziele, und die erste bewegliche Klasse der Norm fehlt in ihrer Aufzählung

- **kategorie:** MEDIUM
- **quelle:** `AGENTS.md` §3.11 (die Linie hängt an der Eigenschaft *wandert auf Anweisung* und
  nicht an der Aufzählung der Bäume), `AGENTS.md` §3.6
- **pfad:** `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:771`
- **befund:** Der Commit ersetzt *„Über die **12** läuft die Einzelprüfung, und keines dieser Ziele
  bewegt der Prozess"* durch *„Über die **Pfad**-Menge läuft die Einzelprüfung, und **kein** Ziel
  darin bewegt der Prozess — erschöpfend ist die Aussage über die Ziel-**Klassen**, und dafür
  braucht sie deren Mächtigkeit nicht"*. Das ist eine **neue** Aussage: Vorher lief die
  Einzelprüfung über eine aufzählbare Menge und die vier Gründe standen als Zusammenfassung
  daneben; jetzt trägt die Klassen-Aufzählung die Erschöpfung allein. Sie trägt sie nicht. Von den
  14 Zielen des Ist-Stands fallen **fünf** unter keine der vier genannten Klassen —
  `../../../AGENTS.md`, `../../../harness/conventions.md`, `../../../spec/architecture.md`,
  `../../../spec/lastenheft.md`, `../../user/benutzerhandbuch.md`; positiv genannt sind nur die
  ADR-Geschwister (7 Ziele) und die Register-Ablage (2 Ziele), die zwei übrigen Klassen stehen als
  Nicht-Vorkommen. Und die Liste ist auch als Klassen-Liste unvollständig: `AGENTS.md` §3.11 nennt
  als **erste** der vier Entscheidungen, die sie verallgemeinert, `ADR-0027` Festlegung 3 — den
  **Carveout-Lifecycle**; der steht in der Aufzählung nicht. Ebenso wenig die Einträge des
  Adaptions-Blocks, die bei ihrer Auflösung per `git mv` nach `harness/conventions/done/` wandern
  (`MR-045`/`MR-046`), und die Welle-Pläne, die zur Closure nach `docs/plan/planning/done/`
  wandern.

  ```sh
  D=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
  # die Ziel-Menge, ueber die der Satz urteilt
  grep -oE '\]\([^)]+\)' "$D" | sed -E 's/^\]\(//; s/\)$//; s/#.*$//' | sort -u
  # davon unter einer der zwei positiv genannten Klassen / unter keiner
  grep -oE '\]\([^)]+\)' "$D" | sed -E 's/^\]\(//; s/\)$//; s/#.*$//' | sort -u \
    | grep -cE  '^0[0-9]{3}-|^\.\./planning/observations/'                       # 9
  grep -oE '\]\([^)]+\)' "$D" | sed -E 's/^\]\(//; s/\)$//; s/#.*$//' | sort -u \
    | grep -cvE '^0[0-9]{3}-|^\.\./planning/observations/'                       # 5
  # zwei der nicht genannten beweglichen Klassen, als Bestand belegt
  ls -d docs/plan/carveouts/done/ harness/conventions/done/
  ls docs/plan/planning/done/ | grep -c '^welle-'                                # 24
  ```

  **Keine Erwartungswerte.** Das **Ergebnis** des Satzes ist wahr — ich habe die 14 Ziele einzeln
  gegen die Wander-Frage gehalten, keines wandert; `AGENTS.md`, `harness/conventions.md`,
  `spec/*` und `docs/user/benutzerhandbuch.md` sind ortsfest. Bestritten ist die **Erschöpfung**,
  die der neue Halbsatz behauptet, nicht das Ergebnis.
- **verifizierbar:** nein — kein Modul der `.d-check.yml` liest die Reichweite einer Prosa-Aussage
  (`grep -n '^modules:' .d-check.yml`); reproduzierbar sind allein die Kommandos oben.
- **klasse:** das Kriterium verspricht eine Reichweite, die sein geschriebener Text nicht hat
- **warum blockierend:** Der Satz friert mit dem Übergang ein (`AGENTS.md` §3.4), und er ist die
  Antwort auf genau die Frage, für die `AGENTS.md` §3.11 den Baum-Katalog ausdrücklich verwirft.
  Nach der Annahme kostet dieselbe halbe Zeile eine Folge-ADR — der Kosten-Grund, mit dem
  `ADR-0016` Festlegung 3 (a) die Form vor den Übergang legt.

### M-2 — der Sweep ist über *Zahlen* definiert; die selbstbezügliche Aussage ohne Zahlwert fällt durch und reproduziert am eingefrorenen Stand nicht mehr

- **kategorie:** MEDIUM
- **quelle:** `MR-025` Setzung 2 (dem Sinn nach), `AGENTS.md` §3.4
- **pfad:** `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:773`
- **befund:** Die neue Zeile definiert ihren Prüfgegenstand als *„**selbstbezügliche** Messwerte —
  Zahlen, deren Gegenstand die Datei ist, in der sie stehen"* und zieht danach vier Gruppen von
  Werten. Dieselbe Zeile enthält eine selbstbezügliche Aussage, die **keine Zahl** ist und darum
  durch diese Definition fällt: *„hängt man je eine der `Accepted`-Zeilen von ADR-0028 und ADR-0036
  an eine Kopie dieser Datei, bewegen sich **alle drei** Link-Zählungen und **beide**
  Ziel-Mengen"*. Sie steht im generischen Präsens und ist damit ebenso re-fahrbar wie eine Zahl —
  und am eingefrorenen Stand fährt sie anders aus. Gemessen: nimmt der annehmende Lauf eine
  `Accepted`-Zeile, die `ADR-0030` verlinkt (die `Accepted`-Zeile von `ADR-0028` tut genau das),
  steht `ADR-0030` danach bereits in der Ziel-Menge, und dieselbe Probe bewegt **keine** der beiden
  Ziel-Mengen mehr:

  ```sh
  # Basis = Ist-Stand + Accepted-Zeile von ADR-0028; darauf die Probe des Satzes erneut
  z() { grep -oE '\]\([^)]+\)' "$1"; }
  for v in 28 36; do
    cp sim28.md r.md; cat "acc$v.txt" >> r.md
    printf '+acc%s Links %s->%s ZielPfad %s->%s ZielStr %s->%s\n' "$v" \
      "$(z sim28.md | wc -l)" "$(z r.md | wc -l)" \
      "$(z sim28.md | sed -E 's/^\]\(//; s/\)$//; s/#.*$//' | sort -u | wc -l)" \
      "$(z r.md     | sed -E 's/^\]\(//; s/\)$//; s/#.*$//' | sort -u | wc -l)" \
      "$(z sim28.md | sed -E 's/^\]\(//; s/\)$//'           | sort -u | wc -l)" \
      "$(z r.md     | sed -E 's/^\]\(//; s/\)$//'           | sort -u | wc -l)"
  done
  # +acc28 Links 121->125 ZielPfad 15->15 ZielStr 29->29   <- beide Mengen stehen still
  # +acc36 Links 121->125 ZielPfad 15->17 ZielStr 29->31
  ```

  **Keine Erwartungswerte.** Die Einrede *„das ist ein datiertes Protokoll, kein stehender Satz"*
  steht dem Verfasser nicht offen: Sie ist genau die Einrede, die dieselbe Zeile für die Zahlen
  derselben Tabelle verwirft. Die Trennlinie, die trägt, ist eine andere — eine Geschichte-Aussage,
  deren **Subjekt ein benannter abgeschlossener Vorgang** ist (*„Runde 4: alle 39 abgedruckten
  Kommandos reproduzieren"*), ist durch ihr Subjekt datiert; eine Aussage, deren Subjekt **die
  Datei** ist, ist es nicht. Nach dieser Linie gehört der Sonden-Satz zu den gezogenen, nicht zu
  den stehengebliebenen.
- **verifizierbar:** nein — kein Gate liest ihn; reproduzierbar mit dem Block oben.
- **klasse:** selbstbezügliche Aussage ohne Zahlwert übersteht den auf Zahlen definierten Sweep
- **warum blockierend:** dieselbe Begründung, die den Commit trägt — nach `AGENTS.md` §3.4 ist der
  Satz unerreichbar, und sein Wahrheitswert hängt dann an einer Bedingung an den Wortlaut der
  `Accepted`-Zeile, die niemand kennt und kein Wächter hält.

### L-1 — „`link-policy: always` macht **jede** Kennung … zum Link" ist weiter als die Konfiguration

- **kategorie:** LOW
- **quelle:** `LH-QA-01` (eine Deckung, die kein Lauf prüft, wird nicht als vorhanden verbucht)
- **pfad:** `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:773`
- **befund:** Die Zeile begründet, dass keine Quelle eine link-freie `Accepted`-Zeile verlangen
  kann, unter anderem damit, dass *„`link-policy: always` **jede Kennung**, die die Zeile nennt,
  zum Link"* mache. Die Konfiguration führt drei Muster — `ADR-\d{4}`, `LH-[A-Z]{2}-\d{2}`,
  `MR-\d{3}` —, und „Kennung" ist in diesem Repo weiter: `AGENTS.md` §3.11 nennt gerade die
  **Slice-Kennung** und die Report-Kennung als das, was an die Stelle einer Adresse tritt. Der
  Gegenbeleg steht in einer der beiden Zeilen, die die Sonde selbst benutzt: die `Accepted`-Zeile
  von `ADR-0028` nennt `slice-145` unverlinkt, und `make docs-check` ist grün.

  ```sh
  awk '/^ids:/,/^matrix:/' .d-check.yml | grep -cE 'link-policy: always'          # 3
  grep -h '^| .*\*\*Accepted\*\*' docs/plan/adr/0028-*.md | grep -oE '`slice-[0-9]+`'
  grep -h '^| .*\*\*Accepted\*\*' docs/plan/adr/0028-*.md \
    | grep -oE '\]\([^)]*slice[^)]*\)' | wc -l                                    # 0
  ```

  **Keine Erwartungswerte.** Die **Funktion** des Halbsatzes bleibt unter der engen Lesart
  bestehen; bestritten ist die Reichweite des geschriebenen Wortlauts, nicht die Folgerung.
- **verifizierbar:** ja für die Messung (die drei Kommandos oben); nein als Gate — kein Modul prüft
  die Reichweite einer Prosa-Aussage über eine Gate-Konfiguration.
- **klasse:** das Kriterium verspricht eine Reichweite, die sein geschriebener Text nicht hat
- **nicht blockierend:** Die Aussage stützt eine Nebenbegründung; ihre enge, wahre Lesart ist die,
  die das mitgelieferte Kommando ausgibt.

### INFO-1 — „Der erste [Weg] trägt nur, solange das Artefakt beschreibbar ist" steht unqualifiziert neben den eigenen Ausnahmen

- **kategorie:** INFO
- **quelle:** `MR-025` Setzung 2, `MR-051` Setzung 2
- **pfad:** `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:773`
- **befund:** Die Zeile zitiert `MR-025` Setzung 2 verbatim (beide Zitate geprüft) und folgert
  dann: *„Der erste trägt nur, solange das Artefakt beschreibbar ist; §3.4 nimmt ihn mit dem
  Übergang weg."* Grammatisch ist der Bezug der **selbstbezügliche** Fall — das ist die Lesart, die
  trägt. Sie steht aber nicht geschrieben, und die Datei benutzt eben diesen ersten Weg weiter:
  in der Geschichte-Tabelle an **fünf** Stellen (Evidence-Zahl des Beobachtungs-Registers, zwei
  Messungen an `slice-190`, Klassen-Zähler über die Review-Reports, Fundstellen-Null), im Rumpf
  in **elf** Blöcken.

  ```sh
  D=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
  grep -oE '→ \*\*[0-9]+\*\*, kein Erwartungswert' "$D" | wc -l                      # 4
  grep -oE '→ \*\*[0-9]+\*\* steht — \*\*kein Erwartungswert\*\*' "$D" | wc -l       # 1
  grep -cE '\*\*Keine Erwartungswerte' "$D"                                          # 11
  ```

  **Keine Erwartungswerte.** Alle fünf haben **fremde** Gegenstände, und keiner wird durch den
  Übergang bewegt — die Einschränkung trägt also. Ohne sie liest ein späterer Lauf den Satz als
  generelle Regel und muss entweder die fünf für defekt halten oder die Regel für falsch.
- **verifizierbar:** nein.
- **klasse:** unausgesprochene Einschränkung einer Begründung, die neben ihren eigenen Ausnahmen steht

## Negativbefunde

- **Fundmenge der selbstbezüglichen Kommandos — nachgesucht, nicht übernommen.** Der Architect
  meldet sechs; ich habe die Datei vollständig danach abgesucht und finde dieselben sechs, alle in
  Zeile 771. **Kein** Kommando in einem Code-Fence hat diese Datei als Operanden; außerhalb der
  Fences trägt allein die Geschichte-Tabelle Selbstbezug (`grep -n '0037' "$D"` → Titelzeile,
  Zeilen 765–772, `Supersedes`-Zeile 777).

  ````sh
  D=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
  awk '/^[[:space:]]*```/{f=!f; next} f' "$D" | grep -cE '0037|adr/\*|adr/\[0-9\]'   # 0
  ````

- **Gezogene Werte — geprüft.** Der Wort-Diff (`git diff --word-diff=plain 862d0a01 f5bcd08b`)
  zeigt genau die fünf Größen, die der Commit als vier Gruppen führt: **11** (Beleg-Form), **111**
  (Link-Zählungen, zweimal), **12** (Pfad-Ziele, zweimal), **26** (Zeichenketten-Ziele), **19**
  (tag-gepinnte Nennungen) — plus die ausgeschriebene Instanz *„zwölf Ziele"*. Kein weiterer Wert
  dieser Klasse steht noch.
- **Ausgeschriebene Zahlwörter über die Datei selbst — gemessen, ein Rest, und er ist gebunden.**
  Nach `elf`, `zwölf`, `dreizehn`, `vierzehn`, `neunzehn`, `sechsundzwanzig` und den übrigen
  Zahlwörtern durchsucht; es verbleibt allein *„alle **elf** abgedruckten Kommandos
  reproduzieren"* (Zeile 765) samt seinen Ziffern-Geschwistern *32* (Zeile 767) und *39*
  (Zeile 768). Alle drei haben als Subjekt eine **benannte Runde**, nicht die Datei; der Übergang
  bewegt sie nicht.
- **Selbst erzeugte Abdrücke — Instrument mit rotem Gegenbeispiel geprüft.** In Code-Fences **0**
  und in Inline-Code-Spans **0** Vorkommen der Sequenz, die die Link-Sonde sucht. Die Prüfung ist
  kalibriert: eine künstlich angehängte Zeile, die genau diese Sequenz in einem Code-Span führt,
  hebt den rohen Link-Kopf von 117 auf 118 und den Span-Treffer von 0 auf 1 — ohne sie bliebe der
  Negativbefund eine Behauptung über ein ungeprüftes Instrument (`AGENTS.md` §3.6).

  ````sh
  awk '/^[[:space:]]*```/{f=!f; next}  f' "$D" | grep -c   '\]\('                    # 0  (Fences)
  awk '/^[[:space:]]*```/{f=!f; next} !f' "$D" | grep -oE '`[^`]+`' | grep -c '\]\(' # 0  (Inline-Spans)
  ````

- **`ADR-0016` Festlegung 3 (a) — am Ist-Stand erfüllt.** Die Datei trägt **0** Markdown-Links in
  den vendored Baum, und **alle 19** tag-gepinnten Nennungen liegen **in** Code-Fences als
  Kommando-Operanden, keine in Prosa. Gemessen mit einer Fence-Erkennung, die **eingerückte**
  Fences mitnimmt; die naive Form ohne `[[:space:]]*` meldet hier 14 falsche „OUT" — auch dieses
  Instrument ist also erst nach seiner eigenen Kalibrierung eine Messung.

  ````sh
  grep -oE '\]\([^)]*\.harness/baseline[^)]*\)' "$D" | wc -l                         # 0
  awk '/^[[:space:]]*```/{f=!f; next} {print (f?"IN":"OUT")"\t"$0}' "$D" \
    | grep '\.harness/baseline/v[0-9]' | cut -f1 | sort | uniq -c                    # 19 IN
  ````

- **Umfang des Commits — ein Pfad, ein Hunk.** `git show --pretty=format: --name-only f5bcd08b`
  nennt allein die ADR; der Diff ist ein einziger Hunk (`@@ -768,8 +768,9 @@`, 3 Einfügungen,
  2 Löschungen) und berührt die Zeilen 771/772 sowie die neue 773. Außerhalb der Klasse ist kein
  Satz bewegt — die Entfernungen des Wort-Diffs enthalten ausschließlich Messwerte und ihre
  unmittelbaren Satzträger.
- **Status und Index — unverändert.** `**Status:** Proposed` steht in Zeile 3, und
  `docs/plan/adr/README.md` führt ADR-0037 mit `Proposed`.
- **Zitattreue.** Beide `MR-025`-Zitate der neuen Zeile sind verbatim gegen
  `harness/conventions/MR-025-eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert.md`
  geprüft; ebenso die Aussage über `ADR-0016` Festlegung 3 (a) — sie legt die **Beleg-Form** vor
  den Übergang und verlangt keine Link-Freiheit.
- **Zeile 772 nach der Nacharbeit.** Ihre Aussage *„die drei Zählungen dort stimmen weiterhin
  überein, und die Ziel-Menge blieb dieselbe"* ist über die Commit-Kette nachgemessen: `5fb156fa`
  12 Ziele / 107 Links, `862d0a01` 12 Ziele / 111 Links — die drei Zählungen stimmen in jedem Stand
  überein, die Ziel-Menge blieb gleich. Der Ersatz von *„die zwölf Ziele sind dieselben"* durch
  *„die Ziel-Menge blieb dieselbe"* ändert an der Wahrheit nichts.
- **Die 14 Ziele einzeln gegen die Wander-Frage** — keines wandert: sieben ADR-Geschwister (flach),
  zwei Beobachtungs-Verzeichnisse (ortsfest nach `ADR-0034` Festlegung 5), `AGENTS.md`,
  `harness/conventions.md` (der Index bleibt; bewegt werden seine Rumpf-Dateien),
  `spec/lastenheft.md`, `spec/architecture.md`, `docs/user/benutzerhandbuch.md`.
- **Nicht geprüft, weil außerhalb des Auftrags:** die Festlegungen 1–4 selbst, die Belegform der
  übrigen Baseline-Aussagen (Runde 7), die Aussagen der Datei über `slice-190` und die
  DoD-/Gate-Konformität (Verifier).

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 2 | *Kriterium verspricht eine Reichweite, die sein Text nicht hat* (M-1) · *selbstbezügliche Aussage ohne Zahlwert übersteht den Zahlen-Sweep* (M-2) |
| LOW | 1 | *Kriterium verspricht eine Reichweite, die sein Text nicht hat* (L-1) |
| INFO | 1 | *unausgesprochene Einschränkung einer Begründung* (INFO-1) |

**Steering-Loop-Gehalt:** Die Klasse *das Kriterium verspricht eine Reichweite, die sein
geschriebener Text nicht hat* trägt M-1 **und** L-1 — zwei Instanzen in einem Commit, der drei
Sätze ändert, und in dieser Reihe schon mehrfach gemeldet. Ihre Register-Zuordnung fällt bei der
Slice-Closure, nicht hier (`AGENTS.md` §3.10).

## Verdikt

**Die Falle, um deretwillen dieser Lauf angesetzt wurde, ist entschärft — der `Accepted`-Übergang
ist dennoch nicht frei.**

Der simulierte Übergang macht in **beiden** Varianten **keine** Zahl der Datei falsch, weil keine
Zahl dieser Klasse mehr dasteht; fünf der sieben Sonden-Werte wandern nachweislich, alle sieben
sind gezogen, und die Erschöpfungs-Aussage verliert ihr **Ergebnis** dabei nicht — ich habe die 14
Ziele einzeln gehalten, keines wandert. Das ist die Kernaussage dieses Laufs.

Blockierend bleiben zwei MEDIUM, beide in Sätzen, die dieser Commit neu geschrieben hat, beide nach
`AGENTS.md` §3.4 mit dem Übergang unerreichbar:

- **M-1** — die Erschöpfung ist neu als **Klassen**-Aussage behauptet und wird von der
  Klassen-Aufzählung nicht getragen (9 von 14 Zielen klassifiziert; der Carveout-Lifecycle, den
  `AGENTS.md` §3.11 als erste seiner vier Entscheidungen führt, fehlt).
- **M-2** — der Sweep ist über *Zahlen* definiert; die selbstbezügliche **Aussage** derselben Zeile
  fällt durch diese Definition und reproduziert am eingefrorenen Stand nicht mehr, sobald die
  `Accepted`-Zeile `ADR-0030` (bzw. `ADR-0018`/`ADR-0031`) verlinkt.

### Auflagen für den annehmenden Lauf

Gültig, sobald M-1 und M-2 erledigt sind. Die zwei des Architect bestätige ich, drei kommen dazu;
**keine** von ihnen hat einen Wächter — kein Modul der `.d-check.yml` liest sie
(`grep -n '^modules:' .d-check.yml`).

1. **Kein tag-gepinnter Baseline-Pfad als Markdown-Link** (`ADR-0016` Festlegung 3 a) — bestätigt.
   Eine Verletzung macht zusätzlich den Satz *„vorher genau 1 `target-missing`, nachher 0"*
   derselben Datei unwahr.
2. **Keine neue selbstbezügliche Zahl** — bestätigt.
3. **Kein Markdown-Link in den Planning-Lifecycle und keiner nach `docs/reviews`.** Sonst wird der
   Satz *„Links in den Planning-Lifecycle und nach `docs/reviews/**` trägt die Datei **keine**"* im
   Moment des Einfrierens falsch — und mit ihm die erste Hälfte der Erschöpfungs-Begründung. Die
   zwei geprüften Muster-Zeilen halten das ein (sie nennen ihre Reports als Inline-Code), aber aus
   Konvention; getragen wird die Regel von `AGENTS.md` §3.11, gemessen wird sie von niemandem.
4. **Kein Link-Ziel mit `)` darin und kein über einen Zeilenumbruch gesetzter Link.** Beides lässt
   die drei Zählungen auseinanderfallen und bricht den Satz *„drei Zählungen müssen
   übereinstimmen"* — die Datei nennt genau diese zwei Fälle selbst als die, die es könnten.
5. **Keine rohe Link-Kopf-Sequenz in einem Code-Span der `Accepted`-Zeile.** Genau dieser Abdruck
   war der selbst gemeldete Instrument-Fehler der Vorrunde; er verfälscht beide Sonden und ist
   gate-unsichtbar.

Dazu, außerhalb der Datei: **den ADR-Index nachziehen** (`docs/plan/adr/README.md` führt
`Proposed`; `AGENTS.md` §5) — nach `ADR-0024` gehört der derivative Index derselben Rolle, der
Nachzug darf also im selben Architect-Commit liegen.
