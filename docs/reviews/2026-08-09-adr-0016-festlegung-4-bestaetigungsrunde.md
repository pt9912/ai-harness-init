# Review — ADR-0016 (Proposed), Bestätigungsrunde zur **Gate-Senkung in Festlegung 4**

## Kopf-Metadaten

| Feld | Wert |
|---|---|
| **Review-Art** | Design-Review (Modul 10 §Drei Review-Arten) — geprüft wird eine Entscheidung gegen Spec, aktive ADRs und Hard Rules, kein Code-Diff |
| **Rolle** | Reviewer (Modul 10), `.harness/skills/reviewer.md` v1.4.0 — Lauf unter dem Rollen-Typ `reviewer`, frischer Kontext |
| **Modell** | claude-opus-5[1m] |
| **Datum** | 2026-08-09 |
| **Diff/Commit-Range** | genau **ein** Commit: `0f24119` („ADR-0016 (Proposed): ein Verweis, der unveraenderlich wird, traegt sein Zitat"). Baum bei Beginn und Ende sauber (`git status --short` leer) |
| **Prüfgegenstand — eng** | `docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md` §Entscheidung **Festlegung 4** (`:148-174`) samt ihren zwei Grenzen und ihrem Preis-Absatz. Die übrigen drei Festlegungen nur dort, wo sie Festlegung 4 tragen oder untergraben. Mitgelesen: `docs/plan/adr/README.md:24` |
| **Gestellte Frage** | Hält *„nach oben geschlossen"* (`:160-162`)? |
| **`LH-*`** | `LH-QA-01` (kein halluzinierter Gate — die ADR zitiert es dreimal selbst), `LH-QA-02` (Reproduzierbarkeits-Klammer) |
| **Aktive ADRs** | ADR-0011, ADR-0012, ADR-0013, ADR-0014 — alle **Accepted** (`docs/plan/adr/README.md:19,20,21,22`); ADR-0015 und ADR-0016 **Proposed**. Keine superseded Referenz im Prüfgegenstand |
| **Hard Rules** | `AGENTS.md` §3.1, §3.4, §3.5, §3.6, §3.7 — Wortlaut selbst gelesen (`AGENTS.md:45-160`) |
| **Vorherige Findings am gleichen Modul** | `docs/reviews/2026-08-01-adr-0013-0014-review.md`, `…-bestaetigungsrunde.md` (ADR-Design-Reviews an ADR-0013/0014), `docs/reviews/2026-08-03-adr-0012-bestaetigungsrunde-runde-3.md`. Wiederkehrendes Muster dort wie hier: **Zahl korrekt, Nenner zu eng** |
| **Regelwerk on-demand** | `regelwerk/README.md` (Index), `modul-10-review-harness.md` (Ziel-Form Reviewer), `modul-08-agentenrollen.md` (Konflikt-Pfad) |
| **Gate-Lage** | `make gates` **selbst gefahren**, Exit 0: `baseline-verify: v3.5.2 OK — 42 Dateien` · `d-check: 308 Datei(en) geprüft, 0 Befund(e)` · bats/Go/lint/ci-lint/comment-claims/span-check grün. `make mutate` nicht gefahren — der Mutations-Treiber kennt keine `docs-check`-Fehlerform (ADR-0013 §Fitness Function sagt das selbst), für diese Frage ohne Aussage |

**Prüfmethode.** Jede Zahl der ADR selbst nachgefahren, jedes Kommando mit Ausgabe unten. Jede
Aussage über Abdeckung **rot gesehen**: acht Sonden im Arbeitsbaum, jede einzeln zurückgenommen,
`git status --short` nach jeder Rücknahme leer. Der Tag-Tausch wurde nicht simuliert *behauptet*,
sondern gefahren — `.harness/baseline/v3.5.2` umbenannt, `make docs-check`, zurückbenannt.

---

## Verdikt zur gestellten Frage

**„Nach oben geschlossen" hält nicht.** Nicht unter Bedingung, nicht knapp — es ist am **ersten
Anwendungsfall** falsifiziert, und zwar mit dem Werkzeug, das die ADR selbst führt.

Zwei getrennte Gründe:

1. **Empirisch.** Beim Tausch werden nicht *eine*, sondern **vier** unveränderliche Artefakte
   gate-rot: ADR-0013 (1 Link) **und drei Zeitdokumente** (4 Links, zwei davon anker-tragend).
   Der Ist-Bestand der ADR hat `docs/reviews` und `docs/plan/planning/done` aus dem **Nenner**
   genommen — der Gate teilt diesen Nenner nicht. Festlegung 4 nimmt *„genau die Accepted-ADRs"*
   auf; für die drei Zeitdokumente trägt **keine** der vier Festlegungen eine Antwort. Der Satz
   *„Heute ist das genau eine Datei"* stimmt für die Teilklasse „Accepted-ADR" und ist auf
   Repo-Ebene falsch.
2. **Strukturell.** Festlegung 4 definiert ihre Liste **intensional und offen** (*„genau die
   Accepted-ADRs, deren Markdown-Link … ein Tausch tatsächlich bricht"*). Kein Satz der ADR
   verbietet einen zweiten Eintrag; die Aufnahme-Regel **erlaubt** ihn ausdrücklich, sobald die
   Bedingung eintritt. Der Boden ist damit keine Schranke, sondern eine **Prognose** über die
   Wirksamkeit von Festlegung 2 — und deren einziger Träger (Festlegung 3, der Accept-Übergang)
   kann per Konstruktion **keinen Sensor** haben: zum Zeitpunkt des Accept ist der verbotene
   Verweis **grün** (gemessen, Sonde 7). Der Re-Evaluierungs-Trigger stellt hinterher fest, dass
   die Schranke gerissen ist; er hält sie nicht — und er ist auf ADRs verengt, also blind für
   genau die Bahn, die unter (1) real eintritt.

**Annahmefähig?** Nein, nicht in dieser Fassung. **H-1** und **H-2** blockieren. Die ADR ist im
Übrigen ungewöhnlich sauber gemessen — jede nachgefahrene Zahl stimmt aufs Stück (siehe I-2);
der Defekt sitzt nicht in der Messung, sondern in ihrem **Nenner** und in einem Satz, der eine
Prognose als Eigenschaft ausgibt.

---

## Die Messungen

### M-A — die Zahlen der ADR, nachgefahren (Stand `0f24119`)

```
$ git grep -o "\.harness/baseline/v3\.5\.2/[^ )]*" \
    -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' | wc -l
34
$ git grep -oE '\]\([^)]*\.harness/baseline/v3\.5\.2/[^)]*\)' \
    -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' | wc -l
17          # ADR-0013 1 · harness/conventions.md 4 · spec/spezifikation.md 12
$ git grep -h "\.harness/baseline/v3\.5\.2/" \
    -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' \
    | sed -E 's/\]\([^)]*\)//g' | grep -o "\.harness/baseline/v3\.5\.2/[^ )\`]*" | wc -l
17
```

Preis-Zahlen von Festlegung 4:

```
$ F=docs/plan/adr/0013-technik-stratum-als-zielort.md
$ grep -oE '\]\([^)]+\)' "$F" | wc -l
27
$ grep -oE '\]\([^)]+\)' "$F" | sed -E 's/^\]\(//; s/\)$//' | sort -u | wc -l
12
$ grep -oE '\]\([^)]+\)' "$F" | sed -E 's/^\]\(//; s/\)$//' | grep -c '#'
5           # davon 4 repo-intern: spezifikation.md ×2, lastenheft.md ×2
```

**Alle sechs Zahlen stimmen exakt.** Ebenso die Regelwerks-Zahlen (`git ls-tree -r --name-only`
gegen einen lokalen Kurs-Klon): 21 → 26 Dateien, `grundlagen-konventionen.md` weg, **sechs** neue
`grundlagen-*`-Dateien (3 → 8 bei zwei übernommenen). Und die Messung, die die Entscheidung dreht,
ebenfalls exakt:

```
$ diff <(sed -n '26,29p' .harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md) \
       <(git -C ../ai-harness-course show v5.3.0:lab/regelwerk/modul-07-carveouts.md | sed -n '26,29p')
            # leer -> byte-gleich
$ sed -n '129p' .harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md
- **Gegen "Wenn der Trigger eintritt, lösen wir den Carveout auf":** … Slice schlägt Memo.
$ git -C ../ai-harness-course show v5.3.0:lab/regelwerk/modul-07-carveouts.md | sed -n '129p'
  *Implementer* führt `git mv` und Config-Updates aus. Verteilung über
```

### M-B — Sonde 1/2: der Preis, rot gesehen (was `scan.ignore` wirklich abschaltet)

Vier Defekte in ADR-0013, je einer pro Modul, plus zwei nackte Kennungen. **Ohne** den
Ausnahme-Eintrag:

```
$ make docs-check
d-check: 308 Datei(en) geprüft, 5 Befund(e)
docs/plan/adr/0013-…:37   ../../../spec/spezifikation.md#SONDE-anker-gibt-es-nicht  anchor-missing
docs/plan/adr/0013-…:70   ../../../harness/SONDE-gibt-es-nicht.md                   target-missing
docs/plan/adr/0013-…:214  harness/SONDE-gibt-es-nicht.sh                            codepath-missing
docs/plan/adr/0013-…:216  LH-QA-01                                                  id-unlinked
docs/plan/adr/0013-…:216  MR-007                                                    id-unlinked
```

Dieselben Defekte **mit** `docs/plan/adr/0013-technik-stratum-als-zielort.md` in `scan.ignore`:

```
$ make docs-check
d-check: 307 Datei(en) geprüft, 0 Befund(e)     # exit 0
```

Und `matrix` als **Quelle** (Sonde 6c/6d, Link vor dem Abschnitt `## Geschichte`, weil
`exclude-sections` ihn sonst schluckt):

```
ohne ignore:  308 Datei(en), 1 Befund   docs/plan/adr/0013-…:205  0001-skelett-distribution.md  matrix-inactive
mit  ignore:  307 Datei(en), 0 Befund(e)
```

**Fünf Module** verlieren die Datei: `links`, `anchors`, `codepaths`, `ids`, `matrix`. Die
Datei-Zahl fällt 308 → 307 — sie wird nicht gefiltert, sie wird **nicht gelesen**. Die ADR nennt
diesen Mechanismus korrekt (*„wirkt datei-weit über alle Module"*), beziffert ihn aber nur für
`links` (→ **M-2**).

### M-C — Sonde 3/4: der Preis ist quellenseitig begrenzt (entlastend)

Eingehende Verweise auf die ignorierte Datei bleiben bewacht:

```
Sonde 3 (Probe-Datei unter docs/ mit drei eingehenden Links, ignore aktiv):
docs/SONDE-eingehend.md:4  plan/adr/0013-…#gibt-es-nicht  anchor-missing
                            -> echter Anker und Datei-Ziel: still, also aufgelöst
Sonde 4 (ADR-0013 auf Status „Superseded by ADR-0016" gesetzt):
mit ignore:  27 × matrix-inactive        ohne ignore:  27 × matrix-inactive  (identisch)
```

`scan.ignore` nimmt die Datei als **Quelle** aus, nicht als **Ziel** — Link, Anker und
`matrix.status` über eingehende Verweise überleben. Das ist ein tragendes Argument **für**
Festlegung 4, das die ADR für ihren eigenen Fall nicht ausspricht (→ **I-1**).

### M-D — Sonde 5: der Tausch, gefahren (`.harness/baseline/v3.5.2` → `v5.3.0` umbenannt)

```
$ make docs-check
d-check: 308 Datei(en) geprüft, 21 Befund(e)      # alle target-missing
```

Aufgeteilt nach **Änderbarkeit der Quelle** — der Linie, die die ADR selbst zieht (`:141`):

| Klasse | Zahl | Von der ADR gedeckt? |
|---|---|---|
| `spec/spezifikation.md` (12) + `harness/conventions.md` (4) | **16** | ja — Folgepflicht 1 zieht sie nach |
| `docs/plan/adr/0013-…md:48` | **1** | ja — Festlegung 4, `scan.ignore` |
| `docs/plan/planning/done/slice-076-mr-018-umzug-technik-stratum.md:558,561` | **2** | **nein** |
| `docs/reviews/2026-07-26-slice-050-impl-review-runde-5.md:10` | **1** | **nein** |
| `docs/reviews/2026-07-26-slice-050-verification.md:7` | **1** | **nein** |

### M-E — Sonde 8: was **nach** vollständiger Anwendung von Festlegung 4 rot bleibt

`scan.ignore`-Eintrag gesetzt **und** Tausch simuliert:

```
$ make docs-check
d-check: 307 Datei(en) geprüft, 20 Befund(e)
$ … | grep -cE '^(spec/spezifikation|harness/conventions)'
16                                            # Folgepflicht 1 zieht sie nach
$ … | grep -E '^docs/(reviews|plan/planning/done)'
docs/plan/planning/done/slice-076-…:558  …/modul-15-observability.md#span-audit-attribut-regeln  target-missing
docs/plan/planning/done/slice-076-…:561  …/modul-15-observability.md#kernidee-modul-15           target-missing
docs/reviews/2026-07-26-slice-050-impl-review-runde-5.md:10  …/modul-10-review-harness.md        target-missing
docs/reviews/2026-07-26-slice-050-verification.md:7          …/modul-11-verification.md          target-missing
```

**Vier Befunde in drei unveränderlichen Artefakten bleiben rot, und keine Festlegung sagt, was
mit ihnen geschieht.**

### M-F — Sonde 7: der Träger von Festlegung 2 kann keinen Sensor haben

Probe-Datei `docs/plan/adr/0017-sonde-traeger.md`, **Status Accepted**, mit genau der von
Festlegung 2 verbotenen Verweis-Form:

```
$ make docs-check
d-check: 309 Datei(en) geprüft, 0 Befund(e)       # exit 0 — der Accept-Zeitpunkt ist grün
$ mv .harness/baseline/v3.5.2 .harness/baseline/v5.3.0 && make docs-check
d-check: 309 Datei(en) geprüft, 22 Befund(e)
docs/plan/adr/0017-sonde-traeger.md:8  …/modul-08-agentenrollen.md#…  target-missing
```

Der Defekt wird **erst sichtbar, wenn §3.4 die Datei bereits eingefroren hat.** Festlegung 3 ist
damit ein rein menschlicher Träger — nicht aus Nachlässigkeit, sondern weil `links` zum
Prüfzeitpunkt nichts zu melden hat.

### M-G — der präzise Knopf fehlt wirklich (`d-check --print-config`, v0.51.1)

| Modul | referenz-weit | datei-weit |
|---|---|---|
| `codepaths` | `ignore-refs` | `exempt-paths` |
| `ids` | — | `exempt-paths` (nur bei `link-policy: always`) |
| `matrix` | — | `exempt-paths` |
| `versions` / `tracked` | — / `exempt-targets` | `exempt-paths` / — |
| **`links`** | **keines** | **keines** |
| **`anchors`** | **keines** | **keines** |

`--help` zeigt zudem keine Inline-Suppression für `links`. Die Einordnung der ADR
(*„stellvertretende Grobheit … ein fehlender Knopf, kein Wunsch"*) ist **belegt**.

---

## Findings

### H-1 — HIGH · `LH-QA-01`, `AGENTS.md` §3.5 · `docs/plan/adr/0016-…md:38-46,148-151,160-162`

Der Ist-Bestand der ADR nimmt `docs/reviews` und `docs/plan/planning/done` aus dem **Nenner**
(`:39-40`), das Doku-Gate scannt beide Bäume aber vollständig — `scan.ignore` führt sie nicht,
und `links`/`anchors` kennen kein `exempt-paths`. Gemessen (M-D/M-E) tragen drei Zeitdokumente
**vier** gate-sichtbare Markdown-Links in den vendored Baum, die beim Tausch `target-missing`
melden und die Festlegung 4 nicht aufnimmt (*„genau die Accepted-ADRs"*). Die Aussage *„Heute ist
das genau eine Datei"* und der Satz *„sie kann nicht wachsen"* sind damit schon zum Zeitpunkt der
Entscheidung falsch, nicht erst in einer künftigen Runde.

**Failure-Szenario, konkret:** slice-081 tauscht den Baum, setzt den `scan.ignore`-Eintrag aus
Festlegung 4 und fährt `make docs-check` — 20 Befunde. 16 löst Folgepflicht 1. Für die
verbleibenden 4 hat der Implementer drei Wege, und alle drei sind Regelbrüche oder
undokumentierte Entscheidungen: (a) drei Zeitdokumente umschreiben, gegen die eigene Begründung
der ADR (*„sie sind die richtige Aussage über ihren Stand und werden nicht nachgezogen"*);
(b) drei weitere Einträge in `scan.ignore`, die Festlegung 4 nicht autorisiert — also eine
Gate-Senkung ohne ADR (§3.5); (c) `docs/reviews/**` und `docs/plan/planning/done/**` pauschal
ausnehmen, gemessen **243 Dateien mit 3688 Link-Vorkommen** von 308 geprüften — eine Senkung um
Größenordnungen über dem Anlass, genau der Fehler, den die ADR bei Option B korrekt verwirft.

**verifizierbar:** ja — `make docs-check` nach dem Tausch; vorab reproduzierbar über
`mv .harness/baseline/v3.5.2 .harness/baseline/v5.3.0 && make docs-check` (Sonde 5/8 oben).

### H-2 — HIGH · `AGENTS.md` §3.5, §3.6 · `docs/plan/adr/0016-…md:148-162,278-280`

*„Nach oben geschlossen"* ist als Eigenschaft formuliert (*„per Konstruktion"*, `:217`), steht
aber auf einer **offenen intensionalen** Aufnahme-Regel: `:149-150` nimmt *„genau die
Accepted-ADRs, deren Markdown-Link … ein Tausch tatsächlich bricht"* auf. Kein Satz der ADR
verbietet einen zweiten oder dritten Eintrag; die Regel **erlaubt** ihn, sobald die Bedingung
eintritt — ein zweiter Eintrag wäre danach durch ADR-0016 selbst gedeckt und löste §3.5 **nicht**
erneut aus. Der Boden ist damit eine Prognose über Festlegung 2, deren einziger Träger
(Festlegung 3, `:143-146`) beim Accept **grün** ist (M-F: 309 Dateien, 0 Befunde) und dessen
Verletzung erst nach dem Einfrieren durch §3.4 sichtbar wird. Der Re-Evaluierungs-Trigger
`:278-280` **bemerkt** den Riss (*„dann hat Festlegung 2 nicht getragen"*) und ist zudem auf
Accepted-ADRs verengt — für die real eintretende Wachstums-Bahn aus H-1 (Zeitdokumente) feuert
er nie.

Nach §3.6 ist *„sie kann nicht wachsen"* eine **Zusage**; ihr Gegenbeispiel ist benannt, aber
nicht rot gesehen — und kann es mit `links` nicht werden.

**verifizierbar:** ja für die Sensor-Lücke (Sonde 7, oben mit Ausgabe). Für den fehlenden
Verbots-Satz: nein — ein Gate-Lauf kann keine fehlende Schranke messen; der Befund ist am Text
`:149-150` gegen `:160-162` ablesbar.

### M-1 — MEDIUM · `MR-001` · `harness/conventions.md:56-58`, `docs/plan/adr/0016-…md:228-232`

`MR-001` ist der einzige Ort im Repo, der die `scan.ignore`-Einträge **zählt und klassifiziert**:
*„`scan.ignore` führt heute vier Einträge, aus zwei Gründen — beide sind **Scoping**, keine
Gate-Lockerung nach §3.5, denn der Prüfumfang schrumpft nicht um Bestand, den dieses Repo
autoritativ schreibt."* Festlegung 4 legt den **ersten** Eintrag an, der genau das tut: ADR-0013
ist Bestand, den dieses Repo autoritativ schreibt. Folgepflicht 1 (`:228-232`) nennt die
Spec-Straten, den Adaptions-Block *für die Links*, die Inline-Nennungen und den
`scan.ignore`-Eintrag — **nicht** `MR-001` selbst. Nach dem Slice trägt `MR-001` eine falsche
Zahl und eine falsche Klassifikation, und kein Gate sieht es (Prosa-Zählung).

**verifizierbar:** nein durch Gate — lesbar an `harness/conventions.md:56-58` gegen die dann
fünf Einträge in `.d-check.yml`.

### M-2 — MEDIUM · `AGENTS.md` §3.5 · `docs/plan/adr/0016-…md:164-168,223-224`

Der Absatz *„Der Preis, gemessen und nicht kleingeredet"* nennt den Mechanismus richtig
(*„wirkt datei-weit über alle Module"*), beziffert ihn aber ausschließlich für `links`:
*„27 Link-Vorkommen über 12 Ziele, davon 5 anker-tragend"*, wiederholt in den Konsequenzen als
*„27 Link-Vorkommen über 12 Ziele verlieren ihren Wächter"*. Gemessen (M-B) verliert die Datei
**fünf** Module. Nicht beziffert bleiben: **17 Kennungs-Nennungen** (8 eindeutig, heute alle
verlinkt) unter der `ids`-Linkpflicht, **8 Inline-Code-Pfad-Kandidaten** unter `codepaths` samt
`check-lines`, und die `matrix`-Regeln über die Datei als Quelle. Unter einer Überschrift, die
Vollständigkeit der Messung behauptet, ist eine auf ein Modul verengte Zahl eine Abdeckungslücke.

**verifizierbar:** ja — Sonde 1/2 und 6c/6d oben, `make docs-check`.

### M-3 — MEDIUM · `AGENTS.md` §3.4 · `docs/plan/planning/open/slice-081-baum-tauschen-pin-ziehen.md:29-33,43-46`

Der ausführende Slice widerspricht Festlegung 1 und 4. Seine DoD verlangt: *„Alle **17**
gate-sichtbaren Verweise zeigen auf den neuen Baum, Datei und Anker aufgelöst"*, und `:32` zählt
ADR-0013 ausdrücklich als eine der drei Quelldateien. Wörtlich ausgeführt hieße das, eine
Accepted-ADR zu editieren (§3.4). ADR-0016 rechnet korrekt mit **16** und gibt den 17. an
`scan.ignore` — der Slice weiß davon nichts (er ist älter: `6bf9950` vor `0f24119`). Die
`scan.ignore`-Zeile taucht in slice-081 an keiner Stelle auf, auch nicht in der Plan-Tabelle
`:60-67`, die `.d-check.yml` nur für die `sources`-URL führt.

Der Befund liegt **außerhalb der ADR** — sie deckt ihn über Folgepflicht 1 ab. Er blockiert die
Annahme nicht, gehört aber vor dem Slice-Start geschlossen.

**verifizierbar:** nein durch Gate — Textabgleich `slice-081:43` gegen `ADR-0016:228-232`.

### L-1 — LOW · Maintainability · `.d-check.yml:6-17`, `docs/plan/adr/0016-…md:148-152`

Alle vier bestehenden `scan.ignore`-Einträge tragen im Config-Kommentar ihre Begründung
(`:6-16`). Festlegung 4 und Folgepflicht 1 verlangen für den fünften **keinen** Kommentar und
keinen ADR-0016-Zeiger. Der Eintrag stünde damit als einziger unbegründet in der Datei — und
zwar an genau der Stelle, an der die nächste Person einen sechsten hinzufügt.

**verifizierbar:** nein durch Gate (`.d-check.yml` ist kein Markdown; `make comment-claims`
lässt YAML außen vor — `AGENTS.md:100` nennt den Prüfbereich).

### L-2 — LOW · `LH-QA-01` · `docs/plan/adr/0016-…md:254-261`

Die Skizze des noch nicht gebauten Sensors (*„Ein lebendes Artefakt nennt nur den gepinnten
Tag"*) trägt denselben blinden Fleck wie der Ist-Bestand: ihr Prüfbereich ist *„alles außer
`docs/reviews`, `docs/plan/planning/done` und den nach Festlegung 4 ausgenommenen ADRs"*. Auch
gebaut sähe er die vier Links aus H-1 nicht.

**verifizierbar:** ja, sobald der Sensor existiert — sein Lauf über die drei Dateien bliebe still.

### I-1 — INFO · entlastende Messung, in der ADR nicht ausgesprochen

`scan.ignore` wirkt **quellenseitig**. Für die ausgenommene Datei bleiben eingehende Link-Ziele,
eingehende Anker und `matrix.status` über eingehende Verweise vollständig bewacht (M-C:
identisch 27 `matrix-inactive` mit und ohne Eintrag). Der Preis von Festlegung 4 ist damit auf
die 27 ausgehenden Verweise und die Modul-Fläche aus M-2 begrenzt und wächst nicht mit der Zahl
der Verweise **auf** ADR-0013 (16 aus 10 lebenden Dateien, Option F). Die ADR misst das für den
vendored Baum (`:77-78`) und überträgt es nicht auf ihren eigenen Fall.

### I-2 — INFO · Mess-Treue der ADR

Alle nachprüfbaren Zahlen der ADR stimmen **exakt**: 34 / 17 / 17 lebende Verweise, 27 / 12 / 5
für ADR-0013 (davon 4 repo-intern), 21 → 26 Regelwerks-Dateien, sechs neue `grundlagen-*`,
`modul-07-carveouts.md` Zeilen 26–29 byte-gleich bei `v5.3.0`, Zeile 129 divergent. Auch die
Knopf-Aussage über `links`/`anchors` ist am Tool belegt (M-G). Der Defekt dieser ADR ist kein
Mess-, sondern ein **Nenner**-Defekt.

### I-3 — INFO · Nebenbefund, klar außerhalb der Frage

Option F sagt: *„wie viele davon der Gate genau trifft, ist ungemessen — die Größenordnung trägt
die Verwerfung."* Sonde 4 misst es beiläufig mit: ein Supersede von ADR-0013 erzeugte **27**
`matrix-inactive`-Befunde. Die Größenordnung trägt, wie behauptet; die Verwerfung von Option F
wird durch die Messung bestätigt, nicht erschüttert.

---

## Was fehlt — so konkret, dass es einbaubar ist

Nicht *„die Schranke ist schwach"*, sondern vier Lücken mit Ort:

1. **Ein Satz, der die Liste extensional schließt** (zu H-2, Ort: Festlegung 4, zweiter
   Spiegelstrich). Heute steht dort eine Aufnahme-*Regel*. Was fehlt, ist eine
   Aufnahme-*Grenze*: die Liste enthält die namentlich genannten Dateien und keine weiteren;
   jeder zusätzliche Eintrag ist eine **neue** Senkung und löst §3.5 erneut aus, auch dann, wenn
   er die Aufnahme-Regel erfüllt. Erst das macht aus dem Re-Evaluierungs-Trigger einen Boden:
   der Trigger bemerkt, §3.5 verbietet.
2. **Eine Festlegung für die vier Zeitdokument-Links** (zu H-1). Sie sind namentlich bekannt
   (M-D). Die ADR muss *eine* der drei Antworten wählen und begründen — Aufnahme in die Liste
   (dann ist *„genau eine Datei"* zu streichen), Nachziehen entgegen der Nenner-Begründung
   (dann mit der ausdrücklichen Auflage, den **Anker** einzeln zu prüfen statt `sed` über den
   Tag-String — die Lehre aus Zeile 129 gilt hier genauso), oder ein dritter Weg. Was heute
   fehlt, ist nicht die richtige Antwort, sondern **irgendeine**; ohne sie erbt slice-081 eine
   §3.5-Entscheidung, die der Slice nicht treffen darf.
3. **Ein Träger von Festlegung 2 für Nicht-ADR-Artefakte** (zu H-1/H-2). Festlegung 3 nennt nur
   den Accept-Übergang. Die vier existierenden Links stammen aber aus den **Kopf-Metadaten von
   Rollen-Reports** (`| **Baseline** | … [modul-10-review-harness.md](…) |`,
   `| **Rolle** | Verifier (Modul 11, [modul-11-verification.md](…)) |`) und aus einer
   Beleg-Zeile in einem `done/`-Slice — einer **reproduzierenden** Konvention ohne jeden Träger.
   Entweder Festlegung 3 bekommt einen zweiten Übergang (Report-/Closure-Abschluss), oder
   Festlegung 2 erklärt ausdrücklich, dass sie Zeitdokumente **nicht** bindet — dann muss
   Festlegung 4 die Folge tragen.
4. **Der Zähl-Ort** (zu M-1). Folgepflicht 1 muss `harness/conventions.md` `MR-001` nennen. Dort
   steht die einzige Aufzählung der `scan.ignore`-Einträge im Repo samt ihrer Klassifikation als
   *Scoping, keine Gate-Lockerung* — beide Aussagen werden mit Festlegung 4 falsch. `MR-001` ist
   zugleich der natürliche Wohnort der Grenze aus Punkt 1: dort liest sie, wer den nächsten
   Eintrag anlegt.

---

## Negativbefunde (geprüft, ohne Befund)

- **N-1 — §3.5-Gefäß.** Die Senkung steht als benannte Festlegung im ADR, nicht in einem
  Nebensatz: Modul (`scan.ignore`), Datei, Aufnahme-Regel, zwei Grenzen und ein Preis-Absatz
  stehen zusammen in `:148-174`, die Konsequenzen wiederholen sie `:216-217,223-224`, die
  Fitness Function nennt die Folge `:249-250`. **Kein Verstoß** gegen die *Form*-Anforderung von
  §3.5 — der Befund H-2 betrifft den **Inhalt** der Grenze, nicht ihr Gefäß.
- **N-2 — Auslöser-Bindung.** Die Regel bindet an das Eintreten (*„wenn ein Tausch seinen Verweis
  bricht"*), nicht an die Klasse *„Accepted"*. Gegen den Ist-Bestand geprüft: von den vier
  Accepted-ADRs erfüllt genau ADR-0013 die Bedingung (M-D), die drei anderen tragen nur
  Inline-Nennungen. Die Bindung ist korrekt gezogen und nicht vorbeugend.
- **N-3 — Die Grobheit ist erzwungen, nicht gewählt.** `links` und `anchors` tragen weder
  `ignore-refs` noch `exempt-paths` noch eine Inline-Suppression (M-G, `--print-config` und
  `--help` am gepinnten Digest gefahren). Der von der ADR benannte präzise Knopf existiert
  wirklich nicht.
- **N-4 — Die 26 übrigen Verweise sind danach wirklich unbewacht.** Kein anderes Modul sieht sie:
  fünf Sonden-Befunde über vier Module gehen still, die Datei-Zahl fällt 308 → 307 (M-B). Die
  Aussage ist **rot gesehen**, nicht aus einer Trefferliste geschlossen.
- **N-5 — Kein halluzinierter Gate (`LH-QA-01`).** Die ADR gibt die stille Hälfte nirgends als
  bewacht aus, nennt `citations` ausdrücklich als *nie feuerndes Gate* und markiert
  Folgepflicht 3 als *nicht gebaut*. Nachgezählt: `git grep -n 'd-check:cite'` liefert außerhalb
  der Zeitdokumente vier Treffer, **alle vier Prosa über das Modul** (`.d-check.yml:55`,
  `harness/conventions.md:519`, `ADR-0016:263`, `slice-015-zitat-sensor.md:39,45,133`) — keine
  einzige `<!-- d-check:cite … -->`-Direktive an einem Link; `citations` steht ohnehin nicht in
  `modules:` (`.d-check.yml:18`). Die Fitness-Function-Tabelle nennt nur real
  laufende Targets (`make docs-check`, `make baseline-verify`) — beide selbst gefahren, beide
  existieren.
- **N-6 — §3.4.** Festlegung 4 fasst keine Accepted-ADR an; sie ändert Config statt Text. Der
  Weg ist gegenüber Option F (Supersede) korrekt gewählt und begründet.
- **N-7 — ADR-Index.** `docs/plan/adr/README.md:24` führt ADR-0016 mit Status *Proposed*, Bezug
  und Kurzfassung; `AGENTS.md` §5 erfüllt. Die Zeile trägt allerdings dieselbe Verkürzung
  *„der eine gate-sichtbare Konflikt in ADR-0013"* wie der Rumpf — mit H-1 fällt sie mit.
- **N-8 — Zusammenspiel Festlegung 1 ↔ 4.** Festlegung 1 (Bestand byte-gleich) und Festlegung 4
  (Config statt Text) widersprechen sich nicht; die Senkung ist der Preis dafür, dass Festlegung 1
  gilt. Der Ableitungsweg ist schlüssig.
- **N-9 — Baum-Hygiene.** Acht Sonden gefahren, jede einzeln zurückgenommen; `git status --short`
  nach jeder Rücknahme leer, `.harness/baseline/v3.5.2` wieder an Ort und Stelle
  (`baseline-verify: v3.5.2 OK — 42 Dateien`), `make gates` Exit 0 mit
  `d-check: 308 Datei(en) geprüft, 0 Befund(e)`.

---

## Kategorie-Summary

| Kategorie | Zahl | IDs |
|---|---|---|
| HIGH | **2** | H-1, H-2 |
| MEDIUM | **3** | M-1, M-2, M-3 |
| LOW | **2** | L-1, L-2 |
| INFO | **3** | I-1, I-2, I-3 |

**Blockiert eines davon die Annahme der ADR? Ja — H-1 und H-2.** Beide treffen genau die
Eigenschaft, mit der Festlegung 4 sich unter §3.5 rechtfertigt (*„sie hat einen Boden"*). H-1 ist
gemessen und nicht auslegbar; H-2 ist am Text ablesbar. M-1 und M-2 sind vor Annahme zu klären,
weil sie Preis und Registrierung der Senkung betreffen. M-3 blockiert die ADR **nicht** — er
blockiert slice-081. L-1/L-2 sind nachziehbar.

**Verdikt: NICHT ANNAHMEFÄHIG in dieser Fassung.** Der Reviewer entscheidet nicht über die
Annahme und setzt keinen Status (Modul 8 §Rollen-Regeln: *ADR-Änderung — Architect schreibt,
Reviewer prüft auf Konsistenz*). Übergabe an den Architect; bei Widerspruch gegen H-1 oder H-2
gilt der Konflikt-Pfad aus Modul 8 — H-1 ist über
`mv .harness/baseline/v3.5.2 .harness/baseline/v5.3.0 && make docs-check` in unter einer Minute
gegenzuprüfen.
