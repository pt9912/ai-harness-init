# Review-Report: slice-flache-welle-ist-eroeffnet-nicht-geplant (Runde 2) — 2026-09-14

**Review-Art:** Code-Review — geprüft wird der Diff gegen den **jetzigen** Slice-Plan und gegen
[`ADR-0046`](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) /
[`ADR-0048`](../plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) (Modul 10 §Drei
Review-Arten). Gegenstand ist Prosa in zwei lebenden Planungs-Artefakten; „Code" meint hier den
Diff, nicht Produkt-Code.

**Gegenstand:** ein Commit, `7a2079e6` (*Rolle Implementer: … Review-Findings F-2/F-3 behoben*) —
der Nachtrag auf den Report `2026-09-14-slice-flache-welle-ist-eroeffnet-nicht-geplant`.
**Geprüfter Stand:** `7a2079e6` (HEAD, `main`), `git status --porcelain` leer.
**Kein Self-Review:** dieser Lauf hat an dem Commit nicht geschrieben, ihn nicht geplant und die
Runde 1 nicht gefahren.

**Skill:** `.harness/skills/reviewer.md` @ `0565f274` (2.0.0) · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-09-14

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis; die `<Platzhalter>` darin sind Formbeispiele)*. Dieser
> Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link
> (`v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt>). Der vendored Baum trägt
> genau einen Tag; der Sprung löscht den alten, und ein Link darauf färbt beim
> nächsten Bump ein Artefakt rot, das niemand mehr anfassen darf. Ein `pfad`-Feld
> auf den **geprüften Gegenstand** ist davon nicht betroffen — es zitiert den
> Stand des Laufs und darf ihn festhalten (`v<X.Y.Z>` ·
> `regelwerk/grundlagen-harness-dateien.md` §harness/README.md als
> Einstiegspunkt — diese Zeile ist selbst ein Beispiel der Form).

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- Slice-Plan `slice-flache-welle-ist-eroeffnet-nicht-geplant` **in der Fassung nach `070f69e8`**
  (§1 mit dem neuen Absatz *Und jeder Träger hat seine eigene Ziel-Form*, DoD (1) und (2), §3, §6)
- [`ADR-0046`](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) Festlegung 1 ·
  [`ADR-0048`](../plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) Festlegung 1
  (Vier-Bedingungen-Probe), Festlegung 2 und §Was diese Entscheidung nicht tut — `Accepted`
- [`ADR-0015`](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules; tragend hier §3.3, §3.4, §3.7, §3.10, §3.11)
- [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) ·
  [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
- Ziel-Formen: `v6.8.0` · `templates/docs/plan/planning/README.template.md` §Slices vs. Wellen und
  `v6.8.0` · `templates/docs/plan/planning/welle.template.md` (Kopfnote) — Zuordnung Vorlage →
  Instanz aus dem Instanz-Register [`harness/migration.md`](../../harness/migration.md)
- Baseline `v6.8.0` · `regelwerk/modul-05-planning-harness.md` §Lifecycle als State Machine ·
  `regelwerk/modul-06-roadmap.md` §Roadmap-Struktur: fünf Abschnitte
- Vorheriger Report am selben Gegenstand: `2026-09-14-slice-flache-welle-ist-eroeffnet-nicht-geplant`
  (1 HIGH / 1 MEDIUM / 1 LOW / 2 INFO) — F-1 ist über
  [`ADR-0048`](../plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) aufgelöst und
  **nicht** Gegenstand dieser Runde; F-2 und F-3 sind es

---

## Eigene Messungen

Alle Kommandos dieses Abschnitts sind in diesem Lauf über `7a2079e6` selbst gefahren; keine Zahl
ist aus der Commit-Message, aus dem Plan oder aus dem Report der Runde 1 übernommen. Ein
Docker-Ziel ist gefahren (`make docs-check`), die übrigen nicht. **Keine Erwartungswerte**
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — alle Zahlen wandern mit dem Stand.

### F-2 — liegt der Absatz an *seiner* Ziel-Form? Wortweiser Vergleich

Nicht am Stichwort, sondern über den ganzen Abschnitt: Vorlage gegen Instanz, Zeilenumbruch
normalisiert.

```sh
diff <(sed -n '26,48p' .harness/baseline/v6.8.0/templates/docs/plan/planning/README.template.md \
        | tr -s ' \n' ' ') \
     <(sed -n '18,40p' docs/plan/planning/README.md | tr -s ' \n' ' ')
# keine Ausgabe — wortgleich
```

Roh, ohne Normalisierung, bleibt **eine** Differenz übrig, und sie ist ein Zeilenumbruch: Die
Vorlage bricht nach *„wandern **nicht** hierher,"*, die Instanz nach *„wandern **nicht**"*. Kein
Wort, kein Zeichen der Aussage unterscheidet sich.

Die Zuordnung Vorlage → Instanz, auf die sich das stützt, ist am Register nachgemessen und nicht
aus dem Plan übernommen:

```sh
grep -n 'planning/README' harness/migration.md
# 116: | …/templates/docs/plan/planning/README.template.md | docs/plan/planning/README.md | eine Instanz |
```

### F-2 — die Zuschreibung, die nur die eigene Ziel-Form trägt

```sh
grep -c 'Sequenzierungs-Autorität' docs/plan/planning/README.md                                      # 1
grep -c 'Sequenzierungs-Autorität bleibt' \
  .harness/baseline/v6.8.0/templates/docs/plan/planning/README.template.md                           # 1
grep -c 'Sequenzierungs-Autorität' \
  .harness/baseline/v6.8.0/templates/docs/plan/planning/welle.template.md                            # 0 (Exit 1)
```

Die dritte Zeile ist der Beleg, dass die Zuschreibung an der **Wahl** der Vorlage hing und nicht an
der Sorgfalt: Die Kopfnoten-Vorlage führt sie nicht und kann sie nicht führen.

### F-2 — die zwei Grenzen gegen einen Byte-Import

```sh
ls docs/plan/planning/reconciliation.md        # Exit 2 — die Datei existiert nicht
grep -c 'reconciliation' docs/plan/planning/README.md   # 0 (Exit 1)
grep -n '^## Beobachtungs-Register' docs/plan/planning/README.md   # 42
git show 7a2079e6 --unified=0 -- docs/plan/planning/README.md | grep -E '^@@'   # @@ -18,11 +18,23 @@
```

Der Brownfield-Absatz der Ziel-Form ist **nicht** mitgekommen; die repo-eigene Sektion
`## Beobachtungs-Register` steht unverändert daneben, und der einzige Hunk der Datei liegt in der
Sektion, die der Plan nennt.

### F-3 — Platzhalter gegen Kennung

```sh
grep -c 'welle-<Kennung>-results\.md' docs/plan/planning/welle-*.md | grep -cv ':0$'   # 0
sed -n '5p' docs/plan/planning/welle-13-regeln-bekommen-ihren-sensor.md
# `done/` (neben ihre `welle-13-results.md`). Der Zustand ist die
diff <(sed -n '10,15p' .harness/baseline/v6.8.0/templates/docs/plan/planning/welle.template.md) \
     <(sed -n '3,8p'  docs/plan/planning/welle-13-regeln-bekommen-ihren-sensor.md)
# einzige Differenz: `welle-<Kennung>-results.md` gegen `welle-13-results.md`
```

Dasselbe `diff` gegen `welle-09` liefert dieselbe eine Differenz mit `welle-09-results.md`; die drei
Kopfnoten sind damit untereinander und gegen die Vorlage deckungsgleich.

### Die drei §1-Mess-Kommandos, in diesem Lauf neu gefahren

```sh
git grep -l 'aktuell\* oder \*geplant\*' \
  -- ':!docs/plan/planning/done' ':!docs/reviews' ':!.harness/baseline' | wc -l   # 0
git grep -c 'Die aktive Welle liegt flach' -- 'docs/plan/planning/welle-*.md' | wc -l   # 0
grep -c 'die \*\*aktive\*\* Welle liegt \*\*flach\*\*' docs/plan/planning/README.md     # 0 (Exit 1)
```

### Regression — Chronik, Zahlen, Hunk-Lage

```sh
git show 7a2079e6 | grep '^+' | grep -v '^+++' \
  | grep -inE 'früher|bisher|bislang|seither|nicht mehr|wäre|hätte|Review-Befund|slice-[0-9]|vorher|zuvor|F-[0-9]'
# keine Ausgabe

for f in docs/plan/planning/README.md docs/plan/planning/welle-13-regeln-bekommen-ihren-sensor.md; do
  diff <(git show 7a2079e6^:$f | grep -oE '[0-9]+([.,][0-9]+)?' | sort) \
       <(git show 7a2079e6:$f  | grep -oE '[0-9]+([.,][0-9]+)?' | sort)
done
```

Der Zahlen-Diff ist **nicht** leer, und das ist hier der richtige Befund: In `README.md` fallen
`0`, `02`, `3.5` und `6` weg und `06`, `07` kommen hinzu — die Token des **ersetzten** Absatzes
(*„seit Regelwerk v3.5.0"*, das Beispiel `welle-02-…`, *„Modul 6"*) gegen die der neuen
Sektions-Regel-Zeile (`modul-06-roadmap.md`, `modul-07-carveouts.md`). In `welle-13` kommt genau
eine `13` hinzu — die Kennung aus F-3. Keine datierte Messung im Rumpf ist angefasst; die Hunk-Lage
bestätigt es (`@@ -18,11 +18,23 @@` bzw. `@@ -5 +5 @@`).

### Regression — hält jede übernommene Klausel für dieses Repo?

Der neue Absatz ist Fremdtext; jede seiner Aussagen ist einzeln gegen den Baum gehalten:

```sh
ls docs/plan/planning/welle-*.md | wc -l                                   # 3 (flach, wie behauptet)
grep -l '^\*\*Status:\*\*\|^Status:' docs/plan/planning/welle-*.md | wc -l # 0 (kein Status-Feld)
ls docs/plan/planning/done/welle-*-results.md | wc -l                      # 12 (Paar im done/)
ls docs/plan/carveouts/done/ | wc -l                                       # 4 (eigenes done/ existiert)
grep -n '^## ' docs/plan/planning/in-progress/roadmap.md                   # u. a. Offene Wellen,
                                                                           # Nächste Wellen, Meilensteine
for d in open next in-progress; do
  printf '%s: %s\n' "$d" "$(ls docs/plan/planning/$d/ | grep -cv '^slice-')"
done                                                                       # open: 0, next: 0,
                                                                           # in-progress: 1
ls docs/plan/planning/in-progress/ | grep -v '^slice-'                     # roadmap.md
git log --diff-filter=A --format='%ad' --date=short \
  -- docs/plan/planning/in-progress/roadmap.md | tail -1                   # 2026-06-13
git grep -l 'in-progress/roadmap\.md' \
  -- ':!.harness/baseline' ':!docs/plan/planning/done' ':!docs/reviews' | wc -l   # 38
```

Acht von neun Klauseln halten. Die neunte ist Finding R2-1.

### Regression — Rollen-Grenze nach [`ADR-0048`](../plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md)

Der Commit läuft als `Rolle Implementer` und ändert eine `Lifecycle:`-Kopfnote in
`welle-13-regeln-bekommen-ihren-sensor` — denselben Artefakt-Typ und dieselbe Sektion, an der
Runde 1 ihr HIGH fand. Die Vier-Bedingungen-Probe aus Festlegung 1 ist deshalb hier neu gefahren,
nicht als erledigt übernommen:

| Bedingung | Messung | Ergebnis |
|---|---|---|
| 1 — Original benannt | Slice-Plan §3 Zeile 1 der Tabelle (*„an `welle.template.md` angeglichen"*) und §1 (`v6.8.0` · `templates/docs/plan/planning/welle.template.md`); die Commit-Message nennt den *„Vorlagen-Platzhalter"* | erfüllt |
| 2 — Original wiedergegeben | `diff` Vorlage-Kopfnote gegen Instanz: byte-gleich bis auf `welle-<Kennung>` → `welle-13` — genau die Ausnahme, die Bedingung 2 wörtlich zulässt | erfüllt |
| 3 — ersetzter Text welle-neutral | ersetzt wurde der Platzhalter `welle-<Kennung>-results.md`; er sagt über die Sache dasselbe, welche Welle die Datei auch führt | erfüllt |
| 4 — neuer Text ohne Aussage über diese Welle | die Substitution nennt den Namen der Ergebnis-Notiz; nicht Ziel, nicht Abgrenzung, nicht Trigger, nicht Slices, nicht Zustand | erfüllt |

Alle vier zugleich — der Nachzug ist **vorlagengebunden** und läuft zulässig im
Implementations-Kontext. Für `docs/plan/planning/README.md` greift die Probe gar nicht:
[`ADR-0048`](../plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) §Was diese
Entscheidung nicht tut nennt diese Datei namentlich als nicht entschieden, und
[`ADR-0015`](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 lässt die Frage
offen, wo keine Quelle sie benennt.

### Gate-Lauf

```sh
make docs-check   # d-check: 1319 Datei(en) geprüft, 0 Befund(e)
```

Real gefahren, netzlos (`--network none`), gepinnter Digest.

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der
verbindlichen Single Source of Truth. Die Spalten unten sind nur
**gespiegelt** (Bequemlichkeit beim Ausfüllen), nicht neu definiert; bei
Abweichung gilt der Skill bzw. dessen Quelle
`v6.8.0` · `regelwerk/modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill.

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| R2-1 | LOW | Der neu geschriebene Absatz sagt *„Der aktive Durchlauf `open/` → `next/` → `in-progress/` nimmt ausschließlich **Slices** auf; `done/` archiviert **zusätzlich** abgeschlossene **Nicht-Slice-Records**"*. In diesem Repo liegt `roadmap.md` — ein Nicht-Slice-Record — seit dem 2026-06-13 dauerhaft in `in-progress/` und wird von 38 lebenden Dateien unter genau diesem Pfad adressiert. Die Aussage stammt aus der Ziel-Form und war im ersetzten Text nicht enthalten. | Slice-Plan §6 Risiko 1 und DoD (2) (*„Was die Ziel-Form nennt und dieses Repo nicht führt, kommt nicht mit"*) · `v6.8.0` · `regelwerk/modul-05-planning-harness.md` §Lifecycle als State Machine | `docs/plan/planning/README.md`:35–37 | nein — kein Modul hält eine Prosa-Aussage gegen den Verzeichnis-Bestand; `make docs-check` ist über beiden Fassungen grün (1319/0) | Vendored Vorlage nennt einen Pfad, den das adoptierende Repo nicht führt |
| R2-2 | INFO | Dieselbe Datei führt zwei Sektionen weiter oben in §Lifecycle-Bedeutungen für `in-progress/` die Bedeutung *„Branch / PR existiert."*, während ihre Ziel-Form dort *„Beansprucht: Der `git mv` hierher liegt auf dem **Hauptzweig, vor der Arbeit** — Branch/PR entsteht danach"* führt; die `next/`-Zeile verliert den Zeiger auf das `Verantwortlich:`-Feld. Bestand, von diesem Commit nicht erzeugt — festgehalten, weil der Plan für genau diese Datei gerade ihre Ziel-Form deklariert hat und der Slice selbst (§4) auf der Hauptzweig-Semantik aufsetzt. | `v6.8.0` · `templates/docs/plan/planning/README.template.md` §Lifecycle-Bedeutungen · `v6.8.0` · `regelwerk/modul-05-planning-harness.md` §Lifecycle als State Machine | `docs/plan/planning/README.md`:14–15 | nein — kein Modul hält eine Instanz-Sektion gegen ihre Vorlage | Instanz-Sektion weicht unbemerkt von ihrer Ziel-Form ab |

**Zu R2-1, und was dagegen spricht.** Man kann *„Durchlauf"* als die **Passage** lesen: `roadmap.md`
durchläuft nichts, es wohnt dort. Unter dieser Lesart ist der Satz wahr. Das ist der stärkste
Einwand, und er trägt nur die halbe Strecke — der Nachsatz stellt `done/` als den Ort gegenüber, der
Nicht-Slice-Records *zusätzlich* aufnimmt, und setzt damit voraus, dass die drei aktiven
Verzeichnisse keine tragen. Das Versagen ist konkret: Ein Folgelauf, der den Abschnitt als
Konvention liest, verschiebt entweder `roadmap.md` — und bricht Rang 5 der Source Precedence samt
38 lebender Adressen — oder schreibt einen Start-Trigger ohne den `^slice-`-Filter, den der
Slice-Plan §4 heute führt, und der liest dann nie `0`.

**Zur Kategorie von R2-1.** Sie bleibt LOW und steigt nicht: kein Gate-/Sicherheitspfad, und die
Klasse ist noch nicht zweimal als LOW aufgetreten — das Register führt
[`BEO-ALL/vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt`](../plan/planning/observations/BEO-ALL/vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt/observation.md)
bei `1`, gemessen in diesem Lauf mit
`ls docs/plan/planning/observations/BEO-ALL/vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt/evidence/*.md | wc -l`
(kein Erwartungswert).

**Was R2-1 für §6 Risiko 1 bedeutet.** Der Befund ist die gemessene Grundlage dafür, dass das
Risiko *„Die Angleichung nimmt aus der Vorlage eine Aussage mit, die dieses Repo nicht führt"*
nicht folgenlos blieb. Welchen der drei Ausgänge es bekommt, entscheidet die Closure und nicht
dieser Report ([`AGENTS.md`](../../AGENTS.md) §3.10).

**Zu R2-2, Umfang.** Der Befund wird **nicht** zum Arbeitsauftrag dieses Slice gemacht: §1 schneidet
ihn nicht ein, und ein Slice, der ihn mitnimmt, hat den Plan geändert statt ergänzt. Am Rande
derselben Beobachtung steht, dass die Zeile *„Regeln dieser Sektion: …"* nach diesem Commit in
einer von fünf `##`-Sektionen der Datei steht (`grep -c '^Regeln dieser Sektion' docs/plan/planning/README.md`
→ **1**, `grep -c '^## ' docs/plan/planning/README.md` → **5**, keine Erwartungswerte) — die
Ziel-Form führt sie in jeder.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| F-2 (Runde 1) — liegt §Slices vs. Wellen an `README.template.md` statt an der Kopfnoten-Vorlage? | **behoben** — Vorlage und Instanz sind über den ganzen Abschnitt wortgleich; die einzige Roh-Differenz ist ein Zeilenumbruch |
| F-2 (Runde 1) — Zuschreibung *Sequenzierungs-Autorität* | **behoben** — `grep -c` über `docs/plan/planning/README.md` → **1**, und der Satz nennt die Roadmap als deren Träger |
| F-2 — Grenze 1: `reconciliation.md` nicht blind mitkopiert | geprüft, ohne Befund — die Datei existiert nicht (Exit 2), und das Wort kommt im README nicht vor (0 Treffer) |
| F-2 — Grenze 2: eigene Sektion `## Beobachtungs-Register` | geprüft, ohne Befund — steht unverändert in Zeile 42 ff.; der Absatz der Ziel-Form ist nicht danebengestellt |
| F-3 (Runde 1) — Platzhalter in `welle-13` Zeile 5 | **behoben** — `welle-13-results.md`; das Platzhalter-Kommando über alle `welle-*.md` liefert **0**, die Kopfnote ist gegen die Vorlage byte-gleich bis auf die Kennung |
| Die drei §1-Mess-Kommandos | geprüft, ohne Befund — alle drei in diesem Lauf neu gefahren, alle `0` |
| Rollen-Grenze am Welle-Plan ([`ADR-0048`](../plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) Festlegung 1) | geprüft, ohne Befund — alle vier Bedingungen einzeln gemessen und erfüllt; der Fall ist der Lehrbuchfall der Festlegung (Byte-Gleichheit bis auf eine Kennung) |
| Rollen-Grenze an `docs/plan/planning/README.md` | geprüft, ohne Befund — [`ADR-0048`](../plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) §Was diese Entscheidung nicht tut nennt die Datei als nicht entschieden; keine Quelle weist sie einer anderen Rolle zu |
| [`AGENTS.md`](../../AGENTS.md) §3.7 — Chronik, Konjunktiv, Befund-Kennung, Slice-Nummer in den neuen Zeilen | geprüft, ohne Befund — 0 Treffer über alle hinzugefügten Zeilen; insbesondere steht kein *„war an … ausgerichtet"* im Artefakt, obwohl die Commit-Message es sagt |
| Ersetzt statt ergänzt | geprüft, ohne Befund — je Datei **ein** Hunk, die alte Fassung steht nirgends daneben |
| §6 Risiko 3 — Unversehrtheit datierter Messzahlen | geprüft, ohne Befund — der Zahlen-Diff bewegt ausschließlich Token des ersetzten Absatzes und die Kennung `13`; kein Rumpf, keine datierte Messung |
| Übernommene Klauseln gegen den Baum (acht von neun) | geprüft, ohne Befund — flache Welle-Dateien, kein `Status:`-Feld, `done/`-Paarung, eigenes `carveouts/done/`, Roadmap mit Meilensteinen/nächsten Wellen/Zeigern auf die offenen; die neunte ist R2-1 |
| Out-of-Scope — nur die zwei genannten Dateien | geprüft, ohne Befund — `git show --name-status` führt genau `M docs/plan/planning/README.md` und `M …/welle-13-regeln-bekommen-ihren-sensor.md`, keine weitere Datei, keine Umbenennung |
| Out-of-Scope — die fünf Ausschlüsse aus §1 | geprüft, ohne Befund — [`ADR-0046`](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) ([`AGENTS.md`](../../AGENTS.md) §3.4 gewahrt), die emittierte Vorlage (ihre Gleichsetzung steht unverändert in Zeile 91), `close-welle.md`, `internal/`, `cmd/`, `harness/tools/` — alle mit 0 Dateien im Diff |
| [`AGENTS.md`](../../AGENTS.md) §3.10 — Abschluss nicht im ausführenden Lauf | geprüft, ohne Befund — der Slice-Plan ist nicht im Diff: keine DoD-Häkchen, keine §6-Ausgänge, keine §7, kein `git mv` |
| [`AGENTS.md`](../../AGENTS.md) §3.3 — `git mv` und Inhaltsänderung getrennt | geprüft, ohne Befund — der Commit enthält keine Umbenennung |
| [`AGENTS.md`](../../AGENTS.md) §3.11 — bewegte Adresse in einem einfrierenden Artefakt | geprüft, ohne Befund — der Diff legt keine neue Adresse an; beide Träger sind änderbare Artefakte, in denen der Pfad der richtige Zeiger bleibt |
| Commit-Message — Traceability, Zahl-Beleg, Attribution | geprüft, ohne Befund — `Bezug: ADR-0046` ist gesetzt; die Zahlen der Message (`0046`, `09`, `11`, `13`, `5`) sind Kennungen und Zeilenangabe, kein Messwert, also keine offene Beleg-Pflicht nach [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung) Setzung 1; 0 Treffer für `co-authored-by\|generated with\|claude code\|anthropic` |
| Anker-Bruch durch die geänderte Überschrift | geprüft, ohne Befund — die Überschrift wechselt von *„— beide über die Verzeichnis-Position"* auf *„— zwei Ablagen, dieselbe Regel"*; kein lebendes Artefakt verweist auf den alten oder neuen Anker (`git grep 'planning/README\.md#'` leer) |
| Neue Gate-Zusage in der Prosa (die Klasse der zwei MEDIUM des Vorvorgängers) | geprüft, ohne Befund — der neue Absatz nennt keinen Sensor, keinen Grund-Code, keine Rot-Folge |
| F-5 (Runde 1, INFO) — *„seit Regelwerk v3.5.0"* ohne Mess-Tag | beiläufig **entfallen** — `grep -c 'v3\.5\.0' docs/plan/planning/README.md` → 0 (Exit 1); der Satz stand in der ersetzten Hälfte desselben Bullets |
| Links und Anker der geänderten Absätze | geprüft, ohne Befund — `make docs-check` real gefahren: 1319 Dateien, 0 Befunde |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** Vendored Vorlage nennt einen Pfad, den das adoptierende Repo
nicht führt · Instanz-Sektion weicht unbemerkt von ihrer Ziel-Form ab

## Verdikt

**Merge-blockierend:** nein — 0 HIGH, 0 MEDIUM.

**Beide Findings der Runde 1, die in dieser Runde standen, sind behoben, und zwar gemessen statt
geglaubt.** F-2: Der Abschnitt liegt an `README.template.md` §Slices vs. Wellen — über den ganzen
Abschnitt wortgleich, nicht nur im Stichwort —, die Zuschreibung *Sequenzierungs-Autorität* steht
wieder und nennt die Roadmap als ihren Träger, und beide Grenzen gegen einen Byte-Import sind
gehalten: `reconciliation.md` ist nicht mitgekommen, die repo-eigene Sektion
`## Beobachtungs-Register` steht unangetastet daneben. F-3: `welle-13` nennt seine Ergebnis-Notiz
beim Namen und ist damit gegen die Vorlage byte-gleich bis auf die Kennung, wie seine zwei
Geschwister. Die drei §1-Kommandos liefern `0`, der Zähl-Beleg für die Zuschreibung liefert `1`,
und `make docs-check` ist über dem Ergebnis real grün.

**Die Regression ist eng geblieben.** Zwei Dateien, je ein Hunk, keine Chronik in den neuen Zeilen,
keine datierte Messung im Rumpf angefasst, kein Ausschluss aus §1 berührt, kein Anker gebrochen.
Der Rollen-Verdacht, an dem Runde 1 blockierte, ist in diesem Lauf neu geprüft und nicht bestätigt:
Der Nachzug an `welle-13` erfüllt alle vier Bedingungen aus
[`ADR-0048`](../plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) Festlegung 1
einzeln, und für `docs/plan/planning/README.md` greift die Probe nach dem eigenen Wortlaut jener
Entscheidung gar nicht.

**Was offen bleibt, hält nichts auf.** R2-1 ist die eine Klausel des übernommenen Fremdtexts, die
für dieses Repo nicht gilt — sie ist LOW, weil sie kein Gate berührt und keine Zusage bricht, und
sie ist zugleich die gemessene Grundlage, die §6 Risiko 1 bei der Closure braucht. R2-2 ist
Bestand und ausdrücklich kein Arbeitsauftrag dieses Slice.

**Übergabe:** Findings gehen an den Implementer; die **Finding-Klassen** gehen zusätzlich in die
Slice-Closure §7 und von dort in den Zähler — für R2-1 existiert das Verzeichnis
[`BEO-ALL/vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt`](../plan/planning/observations/BEO-ALL/vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt/observation.md)
bereits; die Zuordnung trifft die Closure, nicht dieser Report. Dieser Report selbst ist ein
**Lauf-Beleg** (Audit: dieser Diff, dieser Skill, dieses Modell, dieses Verdikt) — er wird über
Läufe hinweg nicht wieder gelesen. Der Report ersetzt keine Verifikation — DoD-/Spec-Konformität
prüft der Verifier separat (Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
