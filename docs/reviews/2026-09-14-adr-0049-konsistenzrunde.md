# Review-Report — ADR-0049, Konsistenzrunde

**Art:** ADR-Konsistenzrunde (kein Slice-Review). Gegenstand ist eine einzelne Entscheidung im
Status `Proposed`, geprüft gegen die Quellen, die ihr eigener Acceptance-Trigger nennt.

**Datum:** 2026-09-14 · **Rolle:** Reviewer · **Kontext:** frisch. Dieser Lauf hat **keinen**
Anteil an der Entstehung der geprüften Datei, an ihrer Index-Zeile, an
`docs/plan/planning/observations/README.md` und an keinem der Commits, die sie ausgelöst haben —
er hat nichts davon geschrieben, geplant oder abgehakt. Kein Self-Review.

**Gegenstand:** [`docs/plan/adr/0049-ausgang-traegt-die-benannte-luecke.md`](../plan/adr/0049-ausgang-traegt-die-benannte-luecke.md)
· **Status bei Prüfung:** `Proposed` · **Prüfstand:** Commit `7a2690a8` (die drei Dateien des
Commits); die eigenen Messungen sind über **HEAD `2d7ebb8e`** gefahren, `git status --porcelain`
leer. Zwischen beiden liegt ein Planner-Commit am Slice-Plan, der das Register nicht berührt.

**Skill:** `.harness/skills/reviewer.md` @ `0565f274` (2.0.0) · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Auftrag:** DoD (1) des Slice verlangt den Status `Accepted`; nach
[ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1 und 2
braucht der Accept-Übergang eine Runde der prüfenden Rolle in frischem Kontext **ohne
blockierenden Befund**. Diese Runde ist sie.

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein Ausfüll-Hinweis)*. Dieser
> Report friert ein; was er zitiert, bewegt sich weiter. Deshalb: **Kennung, nicht Adresse** —
> `slice-<Kennung>` statt seines Lifecycle-Pfads, `make <target>` statt eines Links auf die
> Sensor-Datei, eine Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link
> (`v6.8.0` · `regelwerk/<datei>.md` §<Abschnitt>). Der vendored Baum trägt genau einen Tag; der
> Sprung löscht den alten, und ein Link darauf färbt beim nächsten Bump ein Artefakt rot, das
> niemand mehr anfassen darf.

**Prüfgrundlage (Acceptance-Trigger der Datei, §Der Acceptance-Trigger):** die Ausgangs-Tabelle in
[`docs/plan/planning/observations/README.md`](../plan/planning/observations/README.md) ·
`v6.8.0` · `regelwerk/modul-06-roadmap.md` §Das Beobachtungs-Register und §Wellen-Closure-Prozedur ·
[ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md).

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne diese Liste ist der Lauf nicht
reproduzierbar):

- Der Diff `7a2690a8` (die neue ADR, die Index-Zeile, `observations/README.md`) und seine
  Commit-Message
- Der Slice-Plan
  [`slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke`](../plan/planning/in-progress/slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke.md)
  — §1 Abgrenzung, §2 DoD, §5 Closure-Trigger, §6 Risiken (und sein Nachtrag `2d7ebb8e`)
- Die weiteren in der `Bezug:`-Zeile aktiven ADRs, soweit sie eine Aussage tragen:
  [ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  Festlegung 1–5 ·
  [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1, 2, 3
  und §Der Acceptance-Trigger ·
  [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)
- [`AGENTS.md`](../../AGENTS.md) §3 (tragend hier §3.4, §3.5, §3.6, §3.7, §3.8, §3.9, §3.10, §3.11)
- [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage) ·
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) ·
  [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist) ·
  [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung) ·
  [`MR-055`](../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft) ·
  [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) ·
  [`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)
- Baseline `v6.8.0` · `regelwerk/modul-06-roadmap.md` §Das Beobachtungs-Register,
  §Wellen-Closure-Prozedur · `regelwerk/grundlagen-traceability.md` §Herkunfts-Anker ·
  `regelwerk/modul-05-planning-harness.md` §Offene Risiken werden bei Closure aufgelöst ·
  `regelwerk/modul-04-adrs.md` §Ziel-Form: ADR (MADR) · `templates/docs/plan/adr/NNNN-titel.template.md`
- Vorherige Findings am gleichen Gegenstand: `2026-09-14-adr-0048-konsistenzrunde` (dieselbe
  Runde für die Vorgänger-ADR dieses Vorgangs) und
  `2026-09-14-slice-wellen-schnitt-folgt-der-eroeffnungs-regel` (die zuletzt gemeldete Klasse
  *Zusammenfassung stärker als ihre Quelle*)

**Rollen-Grenze:** Diese Runde ändert an der geprüften Datei und an `observations/README.md`
nichts. Alle Sonden sind lesend; gefahren sind zwei Docker-Ziele (`make gates`, `make docs-check`).
**Nicht** geprüft wird die DoD-Konformität — Liefer-Punkt (1) verlangt `Accepted`, die Datei steht
auf `Proposed`: das ist Verifikation (Modul 11, anderes Prüf-Artefakt), und die Datei benennt den
ausstehenden Beleg selbst.

---

## Eigene Messungen

Alle Zahlen der ADR sind über `2d7ebb8e` **neu gefahren**, keine ist aus der ADR, aus der
Commit-Message oder aus dem Slice-Plan übernommen. Kein Register-Eintrag wurde zwischen
`7a2690a8` und `2d7ebb8e` angelegt oder verändert (`git show --stat` beider Commits: drei bzw.
eine Datei, keine unter `observations/BEO-*/`), die Zahlen gelten damit für beide Stände.

### Der Befund aus §Kontext — vier Kommandos, vier Treffer

```sh
ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l                                    # 114
for d in docs/plan/planning/observations/BEO-*/*/; do
  printf '%s\n' "$(ls "$d"evidence 2>/dev/null | wc -l)"
done | awk '$1 >= 3' | wc -l                                                                #  31
for d in docs/plan/planning/observations/BEO-*/*/; do
  n=$(ls "$d"evidence 2>/dev/null | wc -l)
  if [ "$n" -ge 3 ] && grep -q '^\*\*Stand:\*\* offen' "$d/state.md"; then echo "$n $d"; fi
done | sort -rn | wc -l                                                                     #  18
grep -h '^\*\*Stand:\*\*' docs/plan/planning/observations/BEO-ALL/*/state.md | sort | uniq -c
#       6 **Stand:** geplant
#     101 **Stand:** offen
#       7 **Stand:** verkörpert
```

Alle vier stimmen mit der ADR überein — die Stand-Verteilung liefert 6 · 101 · 7, und `0`
`gestrichen` ist die Abwesenheit der vierten Zeile.

### Die Klassen-Messung und die zwei Beispiele aus §Kontext

```sh
for d in docs/plan/planning/observations/BEO-*/*/; do
  n=$(ls "$d"evidence 2>/dev/null | wc -l)
  [ "$n" -ge 3 ] || continue
  grep -q '^\*\*Stand:\*\* offen' "$d/state.md" || continue
  printf 'Luecke=%s Kennung=%s\n' \
    "$(grep -cE 'Wächter (besteht|existiert|fehlt)|kein (Wächter|Sensor)|Träger (ist|bleibt)' "$d/state.md")" \
    "$(grep -cE 'slice-[a-z0-9-]+' "$d/state.md")"
done | awk '{t++} $1!="Luecke=0"{l++} $2!="Kennung=0"{k++} END{print t, l, k}'    # 18 10 3
# und die zweite Schleife der ADR:
for d in docs/plan/planning/observations/BEO-*/*/; do
  n=$(ls "$d"evidence 2>/dev/null | wc -l); [ "$n" -ge 3 ] || continue
  grep -q '^\*\*Stand:\*\* offen' "$d/state.md" || continue
  grep -c 'Träger ist der Lauf' "$d/state.md"
done | awk '{s+=$1} END{print s}'                                                #  5
# die zwei angenommenen Fälle:
for f in docs/plan/planning/observations/BEO-ALL/*/state.md; do
  grep -q '^\*\*Stand:\*\* verkörpert' "$f" || continue
  awk '/Grenze der Verkörperung/{g=1} g && /Lauf/{print FILENAME; exit}' "$f"
done
# …/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/state.md
# …/BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot/state.md
```

Beide Beispiel-Einträge sind gelesen. Der erste nennt als Zielort
`ADR-0042` und trägt in **derselben Datei** den Satz: *„Ein zweiter Herkunfts-Anker steht nicht:
Was aus einer ADR folgt, trägt bereits eine ID (Baseline-Regelwerk `grundlagen-traceability.md`
§Herkunfts-Anker, Geltungsbereich)."* — Festlegung 1 liest damit eine Form, die der Bestand nicht
nur führt, sondern **mit derselben Quelle begründet**.

### Die Messung an der `welle-15` — und ihre Methode

```sh
CUT=$(git log -1 --format=%ct 86349419)          # Sa 5. Sep 18:13:10 CEST 2026
for d in docs/plan/planning/observations/BEO-*/*/; do
  c=0
  for f in "$d"evidence/*.md; do
    [ -e "$f" ] || continue
    t=$(git log -1 --format=%ct -- "$f"); [ "$t" -le "$CUT" ] && c=$((c+1))
  done
  [ "$c" -ge 3 ] && echo "$c"
done | wc -l                                                                     #  10
```

**Die Methode ist gegengeprüft, nicht geglaubt.** `git log -1` liefert den **letzten** Commit je
Beleg-Datei; die Zahl wäre zu niedrig, wenn ein Beleg vor `CUT` angelegt und danach angefasst
worden wäre. Die Gegenrechnung über den **Anlage-Commit** (`git log --diff-filter=A … | tail -1`)
liefert dieselbe **10**, und die Zahl der Belege, die vor `CUT` entstanden und danach angefasst
wurden, ist **0** — der Fall tritt nicht auf. Der unabhängige zweite Beleg steht in
`done/welle-15-results.md`: *„**Zehn** Einträge des Registers stehen bei ≥ 3×"*, davon vier mit
Ausgang in dieser Closure und sechs, die ihn vorher trugen. Die ADR-Aussage *„dieselbe Zahl, die
der Lese-Schritt selbst nennt"* trägt.

### Die Nachbar-Repo-Treffer

```sh
grep -n 'Ausgängen\|Ausgänge' /Development/d-check/docs/plan/planning/observations/README.md \
  /Development/a-check/docs/plan/planning/observations/README.md
# d-check :10  "… einer von drei Ausgängen"      (eine Zeile)
# a-check :5   "welchen der drei Ausgänge ein Eintrag ab 3× trägt."
# a-check :9   "… `offen` oder einer der drei Ausgänge"
grep -n 'keinen der drei Ausgänge' /Development/a-check/.harness/skills/reviewer.md
# :45  `Stand:`-Zeile bei 3× keinen der drei Ausgänge trägt.
```

Die Sache stimmt (beide Repos führen die Menge der drei), die Anmerkung *„je eine Zeile"* neben dem
Kommando nicht — siehe LOW-4.

### Gate-Läufe

```sh
make gates        # EXIT 0, u. a. span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert
make docs-check   # d-check: 1361 Datei(en) geprüft, 0 Befund(e)      EXIT 0
```

`1361` deckt sich mit der Zahl der Commit-Message. **Kein Erwartungswert** — sie wandert mit jedem
neuen Dokument.

### Die §Bezug-Zitate der Datei — nachgezählt

```sh
grep -n 'Ein Wächter existiert nicht' AGENTS.md     # :294  :373  :454  :506
grep -n '^### 3\.' AGENTS.md                        # 3.7 :168 · 3.8 :303 · 3.9 :379 · 3.10 :405 · 3.11 :459
grep -c '^#### Herkunfts-Anker\|Geltungsbereich — eng' \
  .harness/baseline/$(grep -m1 '^BASELINE_TAG ?= ' Makefile | cut -d' ' -f3)/regelwerk/grundlagen-traceability.md
```

Der erste Treffer liegt **in §3.7** (Abschnittsgrenze `:168`–`:303`), nicht in §3.6 (`:97`–`:168`).
Die zweite Zeile ordnet die vier Fundstellen den Sektionen 3.7, 3.8, 3.10 und 3.11 zu — siehe
MEDIUM-1.

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der verbindlichen Single Source
of Truth (`v6.8.0` · `regelwerk/modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill).

### MEDIUM-1 — Der §Bezug verweist für „die fünf Absätze der Form *Ein Wächter existiert nicht*" auf §3.6, wo keiner steht

- `kategorie`: **MEDIUM** (Bezug-/Abdeckungslücke; der Abschnitt friert mit dem Accept ein und ist
  danach nach [`AGENTS.md`](../../AGENTS.md) §3.4 nur noch per Folge-ADR mit `Supersedes`
  korrigierbar — die Ein-Zeilen-Behebung ist **jetzt** möglich und nie wieder)
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.7, §3.8, §3.10, §3.11 (die Sektionen, die den Absatz
  führen) · [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 · [`MR-026`](../../harness/conventions.md#mr-026--die-hard-rule-nummer-ist-eine-adresse-keine-baseline-entsprechung)
  (die Nummer ist eine Adresse)
- `pfad`: `docs/plan/adr/0049-ausgang-traegt-die-benannte-luecke.md`:15–16
- `befund`: Die Zeile lautet *„`AGENTS.md` §3.6 (die fünf Absätze der Form *„Ein Wächter existiert
  nicht"*, an denen die Festlegung 1 ihre Form liest)"*. Die Wendung steht im Repo **viermal** — in
  §3.7 (`:294`), §3.8 (`:373`), §3.10 (`:454`) und §3.11 (`:506`) —, §3.6 führt keinen solchen
  Absatz; und die Zahl *fünf* steht ohne Kommando neben sich.
- `verifizierbar`: nein — kein Modul aus `modules:` der `.d-check.yml` hält eine Prosa-Adresse
  gegen ihren Zielabschnitt; die zwei `grep`-Kommandos stehen oben.
- `klasse`: Bezug nennt eine Adresse, die den Gegenstand nicht trägt

**Was daran nicht der Befund ist.** Die Form selbst trifft das Gemeinte: §3.7 bis §3.11 sind genau
die Sektionen, die eine Regel stehen lassen und ihre fehlende Bewachung daneben benennen; §3.9
schließt mit einem Grenzen-Absatz **ohne** die Wendung (*„Grenze des Feedback-Quadranten"*, `:379`ff),
und er ist der fünfte dieser Form. Falsch ist die Adresse, nicht die Beobachtung — und der Rumpf
der Festlegung 1 hängt nicht an ihr.

### MEDIUM-2 — Der Acceptance-Trigger zählt seine Quellen auf und lässt die tragende Hälfte der Festlegung 1 aus

- `kategorie`: **MEDIUM** (Bezug-/Abdeckungslücke einer Akzeptanzanforderung)
- `quelle`: [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
  Festlegung 1 und 3 · `v6.8.0` · `regelwerk/grundlagen-traceability.md` §Herkunfts-Anker
  (Geltungsbereich — eng) · `v6.8.0` · `regelwerk/modul-06-roadmap.md` §Das Beobachtungs-Register
- `pfad`: `docs/plan/adr/0049-ausgang-traegt-die-benannte-luecke.md`:302–312 gegen `:172`–`:196`
- `befund`: Der Trigger nennt als Prüfgegenstand die Ausgangs-Tabelle, `modul-06-roadmap.md`
  (§Das Beobachtungs-Register und §Wellen-Closure-Prozedur) und ADR-0034. Die Stelle, an der
  Festlegung 1 ihre **zweite** Hälfte liest — `grundlagen-traceability.md` §Herkunfts-Anker, nach
  §Kontext ausdrücklich *„statt die zweite zu überlesen"* —, steht nicht in der Aufzählung. Eine
  Runde, die nur der Trigger-Liste folgt, prüft Festlegung 1 genau an der Hälfte nicht, die der
  Architect selbst als Zweifel benannt hat (§Kontext, *Der Anker-Pflicht des Zielorts hat einen
  Geltungsbereich*).
- `verifizierbar`: nein — kein Modul liest einen Acceptance-Trigger.
- `klasse`: Acceptance-Trigger lässt eine tragende Quelle aus

**Behebbar ohne Folge-ADR, aber nur jetzt.** [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
Festlegung 3 gibt die Änderung, solange die Datei `Proposed` ist; danach friert §3.4 Statuszeile
und Trigger-Abschnitt gemeinsam ein.

### LOW-1 — Die zitierte Baseline-Klausel nennt drei Quellen, die gesetzte Regel vier

- `kategorie`: **LOW** (Doku-Drift an einer zitierten Liste)
- `quelle`: `v6.8.0` · `regelwerk/grundlagen-traceability.md` §Herkunfts-Anker (*„Was aus
  Lastenheft, Spezifikation oder ADR folgt"*) ·
  [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage) · [`AGENTS.md`](../../AGENTS.md) §3.8
- `pfad`: `docs/plan/planning/observations/README.md`:41 und
  `docs/plan/adr/0049-ausgang-traegt-die-benannte-luecke.md`:194–196
- `befund`: Das Zitat in §Kontext gibt die Baseline-Klausel wörtlich und mit drei Quellen wieder;
  die angewandte Regel führt **vier** (… *oder Baseline*) und leitet daraus ab, dass kein
  Adaptions-Eintrag entsteht. Der Zusatz ist sachlich richtig — eine Regel, die aus dem adoptierten
  Stand folgt, entstand nicht im Steering Loop, und ein Anker wäre erfunden —, aber er steht in
  keiner der zitierten Stellen; ein Leser, der Zitat und Anwendung nebeneinanderhält, sieht die
  Differenz und muss selbst entscheiden, ob sie eine Abweichung ist.
- `verifizierbar`: nein — kein Modul hält eine Liste gegen ihr Zitat.
- `klasse`: Zitat-Liste und Anwendungs-Liste verschieden lang

**Warum LOW und nicht MEDIUM.** Die Klausel *„braucht keinen zweiten Anker"* trägt ihren Grund
selbst (*„trägt bereits eine ID"*), und eine Regel aus dem adoptierten Stand erfüllt ihn: ihr
Träger nennt seine eigene Stelle. Der Satz ist damit eine **Auslegung** des Geltungsbereichs und
keine Senkung — der Nachweis, dass die Ableitung *„kein Adaptions-Eintrag"* hält, steht im Verdikt.

### LOW-2 — Die §Geschichte-Zelle trägt Anlass, Vorgehens-Anweisung und Zustand des Belegs statt des auflösbaren Ankers

- `kategorie`: **LOW** (Zustands-Zelle trägt Chronik; die Zelle friert mit dem Accept ein)
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.7 (*Dieselbe Regel für Zustandsfelder*) ·
  `v6.8.0` · `templates/docs/plan/adr/NNNN-titel.template.md` §Geschichte (die Zelle führt
  `Ereignis` und `Verweis`)
- `pfad`: `docs/plan/adr/0049-ausgang-traegt-die-benannte-luecke.md`:317–321
- `befund`: Die `Proposed`-Zeile trägt in der Verweis-Zelle den **Anlass** (achtzehn Einträge über
  der Schwelle), den **Zustand des Belegs** (*„steht aus — eine Reviewer-Runde zu dieser Datei liegt
  nicht in `docs/reviews/`"*) und eine **Vorgehens-Anweisung** (*„ein blockierender Befund wird vor
  dem Umschlag eingearbeitet"*). Der Anlass steht ausgeschrieben in §Kontext, das Ausbleiben des
  Belegs im §Acceptance-Trigger; die Zelle wiederholt beide und friert sie mit ein.
- `verifizierbar`: nein — kein Modul liest eine Geschichte-Zelle.
- `klasse`: Geschichte-Zelle trägt Chronik statt Anker

### LOW-3 — Die Vorgehens-Anweisung der Geschichte-Zelle beruft sich auf die Festlegung, die etwas anderes regelt

- `kategorie`: **LOW** (Zitat trägt die Folgerung nicht; die Zelle friert mit dem Accept ein)
- `quelle`: [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
  Festlegung 2 gegen Festlegung 3
- `pfad`: `docs/plan/adr/0049-ausgang-traegt-die-benannte-luecke.md`:321
- `befund`: *„ein blockierender Befund wird **vor** dem Umschlag eingearbeitet, wie
  [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 3 es
  für einen Trigger verlangt"* — Festlegung 3 erlaubt, den **Trigger** zu ändern, solange die Datei
  `Proposed` ist; sie verlangt nichts über Befunde. Die Pflicht, nach einem blockierenden Befund
  eine **erneute Runde derselben Rolle** als Beleg zu führen, steht in Festlegung 2.
- `verifizierbar`: nein — kein Modul liest eine Zitat-Zuordnung.
- `klasse`: Zitat trägt die Folgerung nicht

**Failure-Szenario.** Ein Lauf liest die Zelle, folgt dem Zeiger auf Festlegung 3 und findet dort
die Erlaubnis, den Trigger zu verschieben — das ist genau der Weg, den der Report
`2026-09-14-adr-0048-konsistenzrunde` als *Verdikt-Verschiebung* benennt (wer den Trigger ändert,
während eine Runde gegen seine frühere Fassung vorliegt, verschiebt deren Verdikt, statt es zu
erfüllen).

### LOW-4 — Die Anmerkung neben dem Nachbar-Repo-Kommando trifft dessen Ausgabe nicht mehr

- `kategorie`: **LOW** (Doku-Drift an einer Fremdquelle)
- `quelle`: [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 (*„trägt im selben Absatz das Kommando, das **genau sie** ausgibt"*)
- `pfad`: `docs/plan/adr/0049-ausgang-traegt-die-benannte-luecke.md`:160–166
- `befund`: Die Anmerkung lautet *„je eine Zeile"*; das abgedruckte Kommando gibt heute für
  `/Development/d-check` **eine** Zeile aus und für `/Development/a-check` **zwei** (dessen
  Register-README führt den Satz an zwei Stellen). Die getroffene Aussage — beide Repos führen die
  Menge der drei Ausgänge — bleibt richtig.
- `verifizierbar`: nein — die Nachbar-Repos liegen außerhalb des Prüfbereichs dieses Repos; das
  Kommando und seine Ausgabe stehen oben.
- `klasse`: Anmerkung neben dem Kommando trifft dessen Ausgabe nicht

### INFO-1 — Die Regel lebt danach in zwei Artefakten, und kein Re-Evaluierungs-Trigger beobachtet das bewegliche

- `kategorie`: **INFO** (dokumentationswürdige, aber undokumentierte Annahme)
- `quelle`: [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) ·
  [`AGENTS.md`](../../AGENTS.md) §3.8
- `pfad`: `docs/plan/adr/0049-ausgang-traegt-die-benannte-luecke.md`:257–262 (Folgepflicht 1) und
  `docs/plan/planning/observations/README.md`:41–59
- `befund`: Die **operative** Regel steht ab diesem Commit in `observations/README.md` (änderbar),
  die **Entscheidung** in der ADR (ab `Accepted` nach §3.4 eingefroren). Die fünf
  Re-Evaluierungs-Trigger der ADR beobachten die Baseline-Fassung, den Folge-Slice, das Target in
  `harness/README.md` §Sensors und die Nachbar-Repos — keiner die README. Wird die Regel dort
  geschärft (der Folge-Slice, der den Sensor baut, ist der nächste Anlass), altert die eingefrorene
  Fassung still, und keiner der fünf Trigger meldet es.
- `verifizierbar`: nein
- `klasse`: Regeltäger ohne Rück-Trigger

### INFO-2 — Der Commit-Zuschnitt beruft sich auf eine Hard Rule, die diese Datei nicht führt

- `kategorie`: **INFO**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.8 (dessen Geltungsbereich — *„Über andere
  Norm-Artefakte sagt diese Regel nichts … wo keine sie benennt, bleibt die Frage offen"*) ·
  [ADR-0048](../plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) (Eigentum hängt am
  Vorgang) · Slice-Plan §`Verantwortlich:`
- `pfad`: Commit-Message `7a2690a8` gegen [`AGENTS.md`](../../AGENTS.md):303–320
- `befund`: Die Message begründet den Zuschnitt mit *„Architect-Artefakte allein (AGENTS.md 3.8)"*;
  §3.8 führt als Artefakte dieser Rolle die ADRs, die Datei selbst und den Konventionsspeicher —
  `docs/plan/planning/observations/README.md` ist keines davon, und §3.8 erklärt für jedes andere
  Norm-Artefakt ausdrücklich, die Frage bleibe offen. Getragen ist der Zuschnitt von der Zuweisung
  des Plans (`Verantwortlich: Architect`, Begründung: normativer Liefergegenstand) — die ist die
  Quelle, nicht §3.8.
- `verifizierbar`: nein
- `klasse`: Zuschnitt beruft sich auf eine Regel, die die Datei nicht führt

---

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **Auftragsfrage 2 — Auslegung oder Senkung?** | geprüft, ohne Befund — **Auslegung.** Die zwei Stellen desselben Stands sind keine zwei Regeln: `grundlagen-traceability.md` §Herkunfts-Anker setzt den **Geltungsbereich seines eigenen Gegenstands** (*„Nur Regeln, die die 3×-Schwelle erreicht haben"*) und nimmt die Ableitungs-Fälle aus; `modul-06-roadmap.md` §Das Beobachtungs-Register schreibt für genau diese 3×-Regel *„(mit Herkunfts-Anker)"*. Festlegung 1 nimmt **keinen** Anker weg: Für eine Steering-Loop-Regel verlangt sie ihn unverändert, und wo er nicht entstehen kann, wäre ein gesetzter Anker eine Harness-Lüge (`v6.8.0` · `regelwerk/grundlagen-begriffe.md` §Kernbegriffe) — dieselbe Lage, die die Baseline mit *„Ab Einführung, kein Nachrüsten … der leere Zustand *ist* die ehrliche Information"* benennt. **Der Bestand führt die Form angenommen** (siehe §Eigene Messungen) — zwei `verkörpert`-Einträge nennen in derselben Datei einen Lauf als Träger und begründen, warum kein zweiter Anker danebensteht. Und die Entscheidung **verschärft** an ihrer Stelle (Zielort = Norm-Artefakt; die Lücken-Aussage am Zielort) — eine Verschärfung ist nach [`AGENTS.md`](../../AGENTS.md) §3.5 kein ADR-Grund, und dieser Vorgang hat trotzdem einen. **Kein Adaptions-Eintrag nötig**, die Ableitung *„Anwendung, keine Abweichung"* hält; die eine über die zitierte Liste hinausgehende Quelle steht als LOW-1 benannt und ist damit entschieden statt verschwiegen. |
| Festlegung 3 gegen `modul-06-roadmap.md` §Wellen-Closure-Prozedur, Schritt 3 | geprüft, ohne Befund — der Schritt fragt *„Welche Einträge haben **3×** erreicht?"*, im Präsens und ohne Einschränkung auf die Neuzugänge; *„ohne diesen Lese-Schritt ist das Register write-only"* steht unmittelbar daneben. Die ADR gibt die Stelle als Anwendung aus und **misst** sie zusätzlich an einem datierten Lauf. |
| Festlegung 2 gegen die `geplant`-Zeile | geprüft, ohne Befund — der Wohin-Eintrag lautet *„Kennung des Slice oder der Welle, die sie schreibt"*; die ADR verlangt genau das (der Lese-Schritt schneidet einen Träger **und nennt dessen Kennung**) und schließt einen vierten Ausgang aus. Der Bestand führt sechs `geplant`-Einträge, jeder mit Slice-Kennung. |
| Festlegung 1 gegen die `verkörpert`-Zeile | geprüft, ohne Befund — die Zeile verlangt *„die Regel steht"* und nennt Zielort und Anker; die ADR liest das als *„die Regel steht und wo"* und hält die Deckungs-Aussage ausdrücklich aus dem Ausgangswert heraus ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Der Wortlaut der Tabelle ist unverändert übernommen, nicht ersetzt. |
| Die geschlossene Menge der drei Ausgänge | geprüft, ohne Befund — `modul-06-roadmap.md` nennt sie *„eine geschlossene Menge, kein Freitext"*, `modul-05-planning-harness.md` §Offene Risiken werden bei Closure aufgelöst führt dieselbe Konstruktion für das Risiko; die ADR erfindet keinen vierten und widerlegt Option B ausdrücklich über §3.5. |
| §1 Abgrenzung des Slice — hält der Commit sie? | geprüft, ohne Befund — `git show --stat 7a2690a8`: **drei** Dateien. Kein Sensor, keine `d-check`-Änderung, keine Zeile in `harness/conventions.md`, **keine** der achtzehn `state.md`, kein Eintrag unter der Schwelle, keine Änderung an `welle-13`, kein Link und keine Kopie der vendored Baseline. Der Folge-Slice `slice-register-ueber-der-schwelle-bekommt-seinen-waechter` bleibt der Träger des Sensors. |
| [`AGENTS.md`](../../AGENTS.md) §3.5 — Senkung ohne ADR | geprüft, ohne Befund — keine Modul-Aktivierung, kein Target, keine Schwelle bewegt (`git show --stat`: `.d-check.yml` und `Makefile` unberührt); die zwei denkbaren Senkungen (vierter Ausgang · verengter Lese-Gegenstand) sind in §Verglichene Alternativen als Option B und D verworfen und je mit §3.5 begründet. |
| [`AGENTS.md`](../../AGENTS.md) §3.6 — Zusage ohne rot gesehenes Gegenbeispiel | geprüft, ohne Befund — der Commit macht keine test-gestützte Zusage; §Fitness Function sagt *„Gebaut: keine"*, benennt drei Kandidaten einzeln und trennt ausdrücklich, was ein Sensor könnte und was nicht. |
| [`AGENTS.md`](../../AGENTS.md) §3.7 — Chronik, Befund-Kennung, Runden-Verweis in neuem Text | geprüft, ohne Befund — über den ganzen Diff: kein `Review-Befund`, kein *„früher stand"*, kein *„Bis slice-"*, kein *„hier und heute rot gesehen"*. Die zwei neuen Absätze der README sind Regeln im Indikativ (*„Der Lese-Schritt liest alle Einträge über der Schwelle"*), keine Schilderung eines Laufs. Die Zustandsfeld-Hälfte trifft die §Geschichte-Zelle — als LOW-2 benannt, nicht als HIGH: die Zelle ist die Chronik-Tabelle der Vorlage, keine `Stand`-/`Status`-Zelle eines lebenden Registers. |
| [`AGENTS.md`](../../AGENTS.md) §3.4 / §3.8 — Statuswert und Rollen-Zuschnitt | geprüft, ohne Befund an der Substanz — die Datei steht auf `Proposed` (kein `Accepted` erfunden), der Vorgang ist im eigenen §Acceptance-Trigger begründet; die Rolle nennt die Commit-Message. Die Herkunft des Zuschnitts ist INFO-2. |
| [`AGENTS.md`](../../AGENTS.md) §3.9 — Docker-only | geprüft, ohne Befund — alle Sonden dieses Reports sind lesend (`git`, `grep`, `ls`, `awk`); die zwei schreibenden Ziel-Gruppen laufen über `make` und damit über die gepinnten Images: `make gates` und `make docs-check`. |
| [`AGENTS.md`](../../AGENTS.md) §3.11 — bewegte Adresse in einem einfrierenden Artefakt | geprüft, ohne Befund — **0** Markdown-Links in den vendored Baum über den Diff (`grep -cE '\]\([^)]*\.harness/baseline/'`); Baseline-Stellen stehen als Tag + Pfad in Inline-Code; der Slice und `ADR-0042` stehen als Kennung, nicht als Lifecycle-Pfad. Die zwei absoluten Pfade auf die Nachbar-Repos sind Fremdquellen in einem Kommandoblock — sie wandern nicht auf Anweisung dieses Prozesses. |
| [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 1 und 2 · [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung) Setzung 2 | geprüft, ohne Befund an den Beträgen — **jede** Zahl der ADR ist neu gefahren und stimmt: `114` · `31` · `18` · `6`/`101`/`7` · `18 10 3` · `5` · `10` · `1361`. Der Register-Zähler trägt sein Kommando und steht als *„Zu diesem Zeitpunkt"* datiert (`MR-051` Setzung 2). Die eine Zahl ohne Kommando ist die *fünf* aus MEDIUM-1. |
| [`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen) — bewegt der Commit seine eigene Bezugsmenge? | geprüft, ohne Befund — der Commit legt keinen Register-Eintrag an und fasst keine `state.md` an; die vier Kommandos aus §Kontext liefern an `7a2690a8` dieselben Werte wie davor und danach. Die Klasse, die im Vorgänger-Report HIGH-1 war (*Mess-Zusage trifft das eigene Zitat*), tritt hier nicht auf. |
| [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist) — Tag bei jeder Baseline-Aussage | geprüft, ohne Befund — beide Anwendungen stehen als *„im adoptierten Stand `v6.8.0`"*; die `Regeln:`-Zeile führt den Modul-Zeiger in der Form der Ziel-Form. |
| [`MR-055`](../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft) — Stellen-Messung gegen Eigenschafts-Folgerung | geprüft, ohne Befund — die Stelle liegt außerhalb ihres Geltungsbereichs (*„**Nicht** `docs/plan/adr/`"*), und die ADR hält die Grenze selbst: *„Die Form ist dort abschreibbar, das Ergebnis nicht"*, die zwei Antworten sind an diesem Repo gemessen. Der Nachbar-Treffer trägt allein die Beobachtung, dass die Menge dort geschlossen bleibt. |
| [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) — Kennungs-Form | geprüft, ohne Befund — der Anker lautet `· seit slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke`, die Kennungs-Form des Repos; keine Nummer, kein Glob. |
| Herkunfts-Anker — Form nach `grundlagen-traceability.md` §Herkunfts-Anker | geprüft, ohne Befund — der Anker steht als **ein** Feld am Ende des Satzes (`· seit slice-<Kennung>`), dieselbe Form, die `AGENTS.md` §3.10 und §3.11 führen und die die Reviewer-Skill-Ziel-Form als `(seit welle-…)` zeigt. **Dass er heute nicht auflöst, ist der normale Zwischenstand:** er löst über `done/slice-<Kennung>.md` §7 auf, der `git mv` ist der Closure-Schritt (ADR-0030 Festlegung 4, Wellen-Closure Schritt 3c) — und die Anker-Paarung läuft ausdrücklich **nach** dem Move. Kein Befund. |
| `observations/README.md` gegen die ADR — sagt sie dasselbe? | geprüft, ohne Befund an der Substanz — die drei Festlegungen stehen in der README vollständig (Tabellenzeile `verkörpert` + die zwei Absätze), im Wortlaut der Entscheidung und ohne zweite, abweichende Zahl. Die zwei verbleibenden Fragen — Träger ohne Rück-Trigger, Zitat-Liste mit vier statt drei Quellen — stehen als INFO-1 und LOW-1. |
| ADR-Index-Zeile (derivativ nach [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)) | geprüft, ohne Befund — vier Spalten wie der Bestand, `Titel` wörtlich aus der `# `-Überschrift, `Status` `Proposed` aus dem Kopffeld, `Bezug` mit allen ADR-/MR-/LH-Kennungen der `**Bezug:**`-Zeile (die `AGENTS.md`-Zeilen führt keine Index-Zeile), Pfad-Tiefe `../../../` wie die Nachbarzeilen. |
| MADR-Ziel-Form (`v6.8.0` · `regelwerk/modul-04-adrs.md` §Ziel-Form: ADR (MADR)) | geprüft, ohne Befund — Kopf (Status · Datum · Autor · Bezug · Schärft · Regeln), Kontext, **sechs** Verglichene Alternativen (A *nichts tun* · B vierter Ausgang · C Folge-Slice · D verengen · E streng · **F gewählt**), jede mit Trade-off, Entscheidung, Konsequenzen, Fitness Function, fünf Re-Evaluierungs-Trigger, Geschichte. `Schärft: —` ist die Template-Form für eine Prozess-ADR ohne Spec-Stratum; ein `Kopplung:`-Feld führt die Vorlage nicht (ADR-0040 führt es zusätzlich, der Bestand ist gemischt). |
| Referenz-Richtung: referenziert der Kontext aufwärts? | geprüft, ohne Befund — ADRs, `AGENTS.md`, Baseline, `MR`-Einträge, `LH-QA-01`; Slice und Nachbar-Repos erscheinen als Anlass und Fremdquelle, nicht als normative Stütze. |
| [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — behauptet die Datei einen Wächter? | geprüft, ohne Befund — §Fitness Function sagt für die Regel *„Gebaut: keine"*, benennt drei Kandidaten einzeln (Doku-Gate-Module · `make mutate` mit seinen zwei Fehlschlag-Formen · ein baubares Skript) und verweist den Sensor an den Folge-Slice. `grep -n '^modules:' .d-check.yml` bestätigt die Modul-Liste. |
| Links, Anker, IDs, Spans über den Diff | geprüft, ohne Befund — `make docs-check` real gefahren: **1361** Dateien, **0** Befunde, Module `links`/`anchors`/`ids`/`matrix`/`codepaths`/`spans`/`planning`/`targets`; `make gates` EXIT 0. |
| Out-of-Scope: Produkt-Code, Gate-Konfiguration, emittierte Ebene, Baseline | geprüft, ohne Befund — `internal/`, `cmd/`, `harness/tools/`, `.d-check.yml`, `internal/emit/templates/`, `.harness/baseline/` sind unberührt. |
| Out-of-Scope: DoD und Plan-vs-Code | geprüft und **nicht** bewertet — Liefer-Punkt (1) verlangt `Accepted`, die Datei steht auf `Proposed`; das ist Verifikation (Modul 11) und nicht Gegenstand dieser Rolle. Der Slice-Plan ist nach dem geprüften Commit noch einmal gezogen worden (`2d7ebb8e`, Planner); dieser Report bewertet ihn nicht. |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 4 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** Bezug nennt eine Adresse, die den Gegenstand nicht trägt ·
Acceptance-Trigger lässt eine tragende Quelle aus · Zitat-Liste und Anwendungs-Liste verschieden
lang · Geschichte-Zelle trägt Chronik statt Anker · Zitat trägt die Folgerung nicht · Anmerkung
neben dem Kommando trifft dessen Ausgabe nicht · Regeltäger ohne Rück-Trigger · Zuschnitt beruft
sich auf eine Regel, die die Datei nicht führt

*MEDIUM-1, LOW-2 und LOW-3 liegen alle drei im Kopf bzw. in der §Geschichte-Zelle derselben Datei
und stammen aus einem Vorgang — für den Zähler ist das die Zuordnung der Closure
(`v6.8.0` · `regelwerk/modul-06-roadmap.md` §Das Beobachtungs-Register: „Zwei Funde im selben
Vorgang sind eine Gelegenheit").*

## Verdikt

**Kein HIGH — der Beleg trägt, die zwei MEDIUM sind vor dem Umschlag einzuarbeiten.**

1. **Auftragsfrage 2 ist entschieden: Auslegung, keine Senkung.** Festlegung 1 setzt den
   Herkunfts-Anker dort, *„wo die Regel aus dem Steering Loop entstand"* — das ist keine Absenkung
   der `verkörpert`-Zeile, sondern ihre Zusammenschau mit dem Geltungsbereich, den dieselbe
   Baseline-Fassung an der Stelle des Ankers selbst setzt. Genommen wird **kein** Anker: für eine
   Regel aus dem Zyklus verlangt die Entscheidung ihn unverändert, und wo er nicht entstehen kann,
   wäre ein gesetzter Anker eine Harness-Lüge statt einer Pflicht. Der Bestand führt die Form
   angenommen — im selben `state.md`, das die Entscheidung als Beleg zitiert, mit derselben Quelle
   begründet (`BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt`). **Damit braucht der
   Commit weder einen Adaptions-Eintrag noch eine §3.5-ADR für die Anker-Hälfte** — und den
   Adaptions-Eintrag, den er ausdrücklich ablehnt, braucht er auch für die eine über die zitierte
   Liste hinausgehende Quelle nicht (LOW-1, entschieden statt offen).
2. **`Accepted` trägt damit.** Der Report liegt ohne blockierenden Befund vor. Die zwei MEDIUM
   treffen **nicht** die Substanz einer Festlegung: MEDIUM-1 ist eine falsche Abschnitts-Adresse im
   `Bezug:`, MEDIUM-2 eine fehlende Quelle im Acceptance-Trigger; beide sind Ein-Zeilen-Korrekturen,
   die nach dem Umschlag nach [`AGENTS.md`](../../AGENTS.md) §3.4 nur noch per Folge-ADR erreichbar
   wären. Für das Einarbeiten **vor** dem Umschlag braucht es keine zweite Runde — genau das führt
   [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) §Geschichte für
   sich selbst vor (*„Die nicht blockierenden Befunde sind vor diesem Umschlag behoben … Festlegung
   2 deckt das: Sie verlangt eine weitere Runde nur nach einem **blockierenden** Befund"*). Die vier
   LOW sind im selben Zug billig zu ziehen; die zwei INFO tragen keine Handlungspflicht.
   **Die Rest-Unschärfe steht daneben:** Der Trigger der Datei definiert `blockierend` nicht selbst;
   wer MEDIUM darunter liest, macht nach ADR-0040 Festlegung 2 die nächste Runde derselben Rolle zum
   Beleg. Dieser Report verdiktet nach der Kategorie des Skills — HIGH blockiert den Merge — und
   benennt die Auslegung, statt sie zu verschweigen.
3. **Was die Substanz bestätigt.** Die drei Festlegungen sind gegen `modul-06-roadmap.md`
   §Das Beobachtungs-Register, §Wellen-Closure-Prozedur, `grundlagen-traceability.md`
   §Herkunfts-Anker und `modul-05-planning-harness.md` §Offene Risiken werden bei Closure aufgelöst
   geprüft und tragen; jede Zahl der Datei ist über den heutigen Stand neu gefahren und stimmt
   (`114` · `31` · `18` · `6`/`101`/`7` · `18 10 3` · `5` · `10` · `1361`), die tragende Messung zu
   Festlegung 3 ist zusätzlich über eine **zweite** Methode und einen unabhängigen Beleg in
   `done/welle-15-results.md` gegengehalten, und die Abgrenzung des Slice (§1) ist eingehalten —
   drei Dateien, kein Sensor, kein Register-Nachzug.

**Übergabe:** Die Findings gehen an den **Architect**, der die Datei hält; sie steht auf
`Proposed`, und jede Behebung ist bis zum Umschlag ohne Folge-ADR möglich — danach entscheidet
ADR-0040 Festlegung 3 über die Reihenfolge, nicht ein Commit. Die **Finding-Klassen** gehen
zusätzlich in die Slice-Closure §7 und von dort in den Zähler; die Zuordnung zu einer vorhandenen
oder neuen Kennung trifft die Closure und gehört dem Planner
([`AGENTS.md`](../../AGENTS.md) §3.10), nicht dieser Report. Dieser Report selbst ist ein
**Lauf-Beleg** (Audit: dieser Stand, dieser Skill, dieses Verdikt) — er wird über Läufe hinweg nicht
wieder gelesen. Er ersetzt keine Verifikation: die DoD-Konformität einschließlich des von
Liefer-Punkt (1) verlangten Statuswechsels prüft der Verifier separat (Modul 11; anderes
Prüf-Artefakt, anderer Eingabe-Kontext).
