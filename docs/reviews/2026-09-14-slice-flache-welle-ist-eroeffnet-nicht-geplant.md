# Review-Report: slice-flache-welle-ist-eroeffnet-nicht-geplant — 2026-09-14

**Review-Art:** Code-Review — geprüft wird der Diff gegen den Slice-Plan und gegen
[`ADR-0046`](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) (Modul 10 §Drei
Review-Arten). Gegenstand ist Prosa in vier lebenden Planungs-Artefakten; „Code" meint hier den
Diff, nicht Produkt-Code.

**Gegenstand:** ein Commit, `1d508203` (*Rolle Implementer: … vier Rest-Traeger der Wellen-Ablage
auf ADR-0046 Festlegung 1 angeglichen*). **Geprüfter Stand:** `1d508203` (HEAD, `main`),
`git status --porcelain` leer. **Kein Self-Review:** dieser Lauf hat an dem Commit nicht
geschrieben und ihn auch nicht geplant.

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

- Slice-Plan `slice-flache-welle-ist-eroeffnet-nicht-geplant` (§1 Ziel/Abgrenzung, §2 DoD, §3 Plan,
  §5 Closure-Trigger, §6 Risiken, §8 Sichtung)
- [`ADR-0046`](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) — Festlegung 1,
  §Was diese Entscheidung nicht tut, §Konsequenzen, §Fitness Function
- [`ADR-0015`](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 ·
  [`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules; tragend hier §3.3, §3.6, §3.7, §3.10, §3.11)
- [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) ·
  [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist) ·
  [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
- Ziel-Formen: `v6.8.0` · `templates/docs/plan/planning/welle.template.md` (Kopfnote) und
  `v6.8.0` · `templates/docs/plan/planning/README.template.md` (§Slices vs. Wellen) —
  Zuordnung Vorlage → Instanz aus dem Instanz-Register [`harness/migration.md`](../../harness/migration.md)
- Baseline `v6.8.0` · `regelwerk/modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle ·
  `regelwerk/modul-06-roadmap.md` §Roadmap-Struktur: fünf Abschnitte
- Vorheriger Report am selben Gegenstand: `2026-09-14-slice-wellen-schnitt-folgt-der-eroeffnungs-regel`
  (2 MEDIUM / 1 LOW / 2 INFO; sein F-5 übergibt genau die vier Rest-Träger an diesen Slice)

---

## Eigene Messungen

Alle Kommandos dieses Abschnitts sind in diesem Lauf über `1d508203` selbst gefahren; keine Zahl
ist aus der Commit-Message oder aus dem Plan übernommen. Ein Docker-Ziel ist gefahren
(`make docs-check`), die übrigen nicht.

### Die drei §1-Kommandos — alle drei neu gefahren, alle `0`

```sh
git grep -l 'aktuell\* oder \*geplant\*' \
  -- ':!docs/plan/planning/done' ':!docs/reviews' ':!.harness/baseline' | wc -l   # 0
git grep -c 'Die aktive Welle liegt flach' -- 'docs/plan/planning/welle-*.md' | wc -l   # 0
grep -c 'die \*\*aktive\*\* Welle liegt \*\*flach\*\*' docs/plan/planning/README.md     # 0
```

Die verbliebenen Treffer des ersten Kommandos ohne Ausschlüsse liegen ausschließlich in
Zeitdokumenten (`docs/plan/planning/done/welle-*.md`, `docs/reviews/**`) — eingefroren und
außerhalb der Fundmenge.

### Suche nach einem fünften lebenden Träger

Nicht am Wortmuster des Plans, sondern über den Gegenstand:

```sh
git grep -nE 'Welle-(Plan-)?Datei|welle-\*\.md|flache (Plan-)?Datei' \
  -- ':!docs/plan/planning/done' ':!docs/reviews' ':!.harness/baseline' ':!docs/plan/adr' \
     ':!docs/plan/planning/observations'
git grep -n 'flach' -- ':!docs/plan/planning/done' ':!docs/reviews' ':!.harness/baseline' \
     ':!docs/plan/adr' | grep -iE 'geplant|geschnitten|aktiv'
```

Alle Treffer gelesen. **Eine** lebende Stelle trägt die Gleichsetzung noch —
`internal/emit/templates/commands/plan-welle.md`:91 (*„die neue Welle entsteht flach =
aktiv/geplant"*); sie ist die emittierte Ebene und in §1 ausdrücklich ausgeschlossen. Der
Anweisungssatz des Dogfoods (`.claude/commands/plan-welle.md`) und die Roadmap §Nächste Wellen
sind vom Vorgänger-Slice bereits nachgezogen. **Keine fünfte Stelle im Geltungsbereich.**

### Risiko 3 — die datierten Messzahlen im Rumpf

Zahlen-Diff über die **ganze** Datei, je Träger, vor gegen nach dem Commit:

```sh
for f in docs/plan/planning/README.md docs/plan/planning/welle-09-modul-15-konformitaet.md \
         docs/plan/planning/welle-11-traeger-aussage.md \
         docs/plan/planning/welle-13-regeln-bekommen-ihren-sensor.md; do
  diff <(git show 1d508203^:$f | grep -oE '[0-9]+([.,][0-9]+)?' | sort) \
       <(git show 1d508203:$f  | grep -oE '[0-9]+([.,][0-9]+)?' | sort)
done   # keine Ausgabe — vier Dateien, null Differenzen
```

Dazu die Hunk-Lage: je Datei **ein** Hunk, und zwar der Kopf
(`git show 1d508203 --unified=0 | grep -E '^@@'` → `@@ -23,5 +23,6 @@`, `@@ -3,4 +3,6 @@` dreimal).
Kein Rumpf berührt.

### Ersetzt statt ergänzt, und keine Chronik

```sh
git show 1d508203 | grep -c '^+[^+]'   # 24
git show 1d508203 | grep -c '^-[^-]'   # 17
git show 1d508203 | grep '^+' | grep -v '^+++' \
  | grep -inE 'früher|bisher|bislang|seither|nicht mehr|wäre|hätte|Review-Befund|slice-[0-9]|vorher|zuvor'
# keine Ausgabe
```

Die alte Fassung steht in keiner der vier Dateien neben der neuen; kein Konjunktiv über die
abgelöste Fassung, keine Befund-Kennung, keine Slice-Nummer als Erzählung.

### Angleichung an die Ziel-Form — Byte-Vergleich

```sh
diff <(sed -n '10,15p' .harness/baseline/v6.8.0/templates/docs/plan/planning/welle.template.md) \
     <(sed -n '3,8p'  docs/plan/planning/welle-13-regeln-bekommen-ihren-sensor.md)   # identisch
diff <(sed -n '10,15p' .harness/baseline/v6.8.0/templates/docs/plan/planning/welle.template.md) \
     <(sed -n '3,8p'  docs/plan/planning/welle-09-modul-15-konformitaet.md)
# einzige Differenz: `welle-<Kennung>-results.md` gegen `welle-09-results.md`
```

`welle-11` verhält sich wie `welle-09`. `welle-13` ist **byte-gleich** zur Vorlage — einschließlich
ihres Platzhalters (Finding F-3).

### Rollen-Verteilung über denselben Artefakt-Typ

```sh
git log --format='%s' -- 'docs/plan/planning/welle-*.md' | grep -c '^Rolle Planner'      # 56
git log --format='%s' -- 'docs/plan/planning/welle-*.md' | grep -c '^Rolle Implement'    #  7
```

**Keine Erwartungswerte** ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Die sechs Implementer-Commits vor diesem sind durchweg **Adress-/Kennungs-Nachzüge**
(Tag-Pfade, Beobachtungs-Kennungen); drei von ihnen — `slice-177`, `slice-186`, `slice-193` —
liegen bereits als Evidence-Datei in
[`BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext`](../plan/planning/observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/observation.md).
Dieser Commit ändert kein Adress-Token, sondern die **Aussage** der Lifecycle-Kopfnote.

### Gate-Lauf

```sh
make docs-check   # d-check: 1313 Datei(en) geprüft, 0 Befund(e)
```

Real gefahren, netzlos, gepinnter Digest. Das Modul `planning` mit der Fähigkeit `waves` ist aktiv
und grün — die Verzeichnis-Lage der drei Wellen ist formkonform, die Kopfnoten liest kein Modul.

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der
verbindlichen Single Source of Truth. Die Spalten unten sind nur
**gespiegelt** (Bequemlichkeit beim Ausfüllen), nicht neu definiert; bei
Abweichung gilt der Skill bzw. dessen Quelle
`v6.8.0` · `regelwerk/modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill.

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | Der Commit ändert im **Implementer**-Kontext die `Lifecycle:`-Kopfnote von drei Welle-Plänen, und zwar deren normative Aussage über den Wellen-Lifecycle. [`ADR-0046`](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Was diese Entscheidung nicht tut weist denselben Artefakt-Typ namentlich einer anderen Rolle zu: *„Die ersten drei gehören dem **Planner** — für Welle-Plan und Roadmap …"*; dieselbe Aussage hat den Vorgänger-Nachzug an `welle-13` einen Commit zuvor als `Rolle Planner` laufen lassen. Keine Quelle trägt eine Ausnahme, und die auslösende Anweisung des Plans ist Quelle, kein Eigentums-Übergang. | [`ADR-0046`](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Was diese Entscheidung nicht tut · [`ADR-0015`](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 (*„Wo eine Quelle die schreibende Rolle benennt, gilt sie unverändert"*) · [`AGENTS.md`](../../AGENTS.md) §3.10 (führt *„ein berührter Welle-Plan"* als Planner-gebunden) | `docs/plan/planning/welle-09-modul-15-konformitaet.md`:3–8 · `docs/plan/planning/welle-11-traeger-aussage.md`:3–8 · `docs/plan/planning/welle-13-regeln-bekommen-ihren-sensor.md`:3–8 | nein — kein Modul der `.d-check.yml` liest Commits, und `make mutate` kennt für einen Commit-Zuschnitt keine Fehlschlag-Form; dieselbe Lücke benennt [`AGENTS.md`](../../AGENTS.md) §3.8 für sich selbst | Fremdes Rollen-Artefakt im Implementations-Kontext |
| F-2 | MEDIUM | Der README-Absatz ist an die Kopfnote von `welle.template.md` angeglichen, nicht an seine eigene Ziel-Form `README.template.md`, die das Instanz-Register `harness/migration.md` für genau diese Datei führt. Dabei entfällt die Zuschreibung *Sequenzierungs-Autorität* an die Roadmap, die beide — der Bestand vor dem Diff und die Ziel-Form — tragen (`grep -c 'Sequenzierungs-Autorität'` über `docs/plan/planning/README.md`: vorher **1**, nachher **0**). | [`ADR-0046`](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) Festlegung 1 · `v6.8.0` · `templates/docs/plan/planning/README.template.md` §Slices vs. Wellen · Instanz-Register [`harness/migration.md`](../../harness/migration.md) | `docs/plan/planning/README.md`:23–28 | nein — kein Modul hält eine Instanz gegen ihre Vorlage; `make docs-check` ist über beiden Fassungen grün | Nachzug an der Vorlage eines anderen Artefakts statt an der eigenen Ziel-Form |
| F-3 | LOW | Die neu geschriebene Kopfnote von `welle-13` nennt die Ergebnis-Notiz als `welle-<Kennung>-results.md` — den Platzhalter der Vorlage —, während dieselbe Datei den konkreten Namen zweimal führt (§3 Closure-Trigger Zeile 202, §7 Zeile 454) und die zwei Geschwister-Kopfnoten `welle-09-results.md` bzw. `welle-11-results.md` nennen. Der Platzhalter ist Bestand, steht aber in einer Zeile, die dieser Commit neu geschrieben hat. | §6 Risiko 1 des Slice-Plans (*„Angleichung der **Aussage**, nicht die Byte-Übernahme des Absatzes"*) · [`AGENTS.md`](../../AGENTS.md) §3.7 (*„Wer eine solche Zeile ohnehin anfasst, zieht sie nach"*) | `docs/plan/planning/welle-13-regeln-bekommen-ihren-sensor.md`:5 | nein — Inline-Code ohne Pfad-Charakter im Prüfbereich; `make docs-check` grün (1313/0) | Vendored Vorlage nennt einen Platzhalter, den das adoptierende Repo nicht führt |
| F-4 | INFO | Der übernommene Satz *„Sie stehen in der `in-progress/roadmap.md` unter *Nächste Wellen* und nirgends sonst"* ist absolut formuliert, während dieselbe Roadmap in §Abhängigkeitsgraph für eine Welle mit Abhängigkeit *„als gerichtete Kante hier"* verlangt (Zeile 65). Solange keine geplante Welle eine Kennung trägt, kollidiert nichts; der nächste Wellen-Schnitt liest beide Sätze. | `v6.8.0` · `regelwerk/modul-06-roadmap.md` §Roadmap-Struktur: fünf Abschnitte, Bullet *Nächste Wellen* · Maintainability | `docs/plan/planning/README.md`:27–28 gegen `docs/plan/planning/in-progress/roadmap.md`:65 | nein — kein Modul hält zwei Prosa-Sätze gegeneinander | Vendored Vorlage nennt einen Platzhalter, den das adoptierende Repo nicht führt |
| F-5 | INFO | Die **unveränderte** erste Hälfte desselben Bullets behauptet *„trägt ihren Status seit Regelwerk v3.5.0"*. Der vendored Baum führt genau einen Tag (`v6.8.0`); die Aussage ist netzlos an keiner Stelle nachzumessen, und der Absatz nennt keinen Stand, an dem nachgesehen wurde. Bestand, nicht von diesem Commit erzeugt — festgehalten, weil die zweite Hälfte desselben Bullets gerade neu geschrieben wurde. | [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist) Setzung 1 | `docs/plan/planning/README.md`:21 | nein — kein `versions`-Modul in der `.d-check.yml` (`grep -m1 '^modules:' .d-check.yml`) | Baseline-Aussage ohne Mess-Tag |

**Zu F-1, und was dagegen spricht.** Der zitierte Satz steht in §Was diese Entscheidung nicht tut
und nicht in §Entscheidung; die Quellen, auf die er sich stützt, decken wörtlich die **Eröffnung**
(`v6.8.0` · `regelwerk/modul-08-agentenrollen.md`: *„Die Eröffnung ist Planner-Arbeit"*) und den
**Abschluss** ([`AGENTS.md`](../../AGENTS.md) §3.10: *„ein berührter Welle-Plan"* als Teil der
Closure) — ein Text-Nachzug an einem laufenden Welle-Plan fällt zwischen beide. Das ist der
stärkste Einwand, und er ändert an der Beobachtung nichts: Eine aktive ADR benennt für diesen
Artefakt-Typ eine schreibende Rolle, der Commit ist unter einer anderen gelaufen, und
[`ADR-0015`](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 lässt die Frage
nur dort offen, **wo keine Quelle sie benennt**. Nicht herabgestuft wird sie deshalb hier — die
Auflösung ist ein Architect-Verdikt (§Verdikt), nicht die Kategorie.

**Zu F-3 und F-4.** Beide tragen dieselbe Klasse und stammen aus demselben Vorgang — für den
Zähler **eine** Gelegenheit (`v6.8.0` · `regelwerk/modul-06-roadmap.md` §Das Beobachtungs-Register:
*„Zwei Funde im selben Vorgang sind eine Gelegenheit"*). Sie sind zugleich die gemessene Grundlage
für den Ausgang, den §6 Risiko 1 bei der Closure braucht.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Liefer-Punkt (1) — trägt eine der drei Kopfnoten die Gleichsetzung noch? | geprüft, ohne Befund — beide §1-Kommandos `0`; weder *„Die aktive Welle liegt flach"* noch *„Ob eine flache Welle aktuell oder geplant ist"* steht in einer der drei Dateien |
| Liefer-Punkt (1) — Äquivalenz der neuen Kopfnote zu [`ADR-0046`](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) Festlegung 1 | geprüft, ohne Befund — *Datei entsteht mit der Eröffnung*, *geplante Wellen haben keine Datei*, *Zustand ist die Verzeichnis-Position* sind alle drei getragen |
| Liefer-Punkt (2) — beschreibt der README-Absatz die Sache nach Festlegung 1? | geprüft, ohne Befund an der **Aussage** — die drei Kernsätze stimmen; der Einwand betrifft die gewählte Vorlage (F-2), nicht die Sache |
| Liefer-Punkt (1)/(2) — ersetzt statt ergänzt | geprüft, ohne Befund — je Datei ein Hunk, 17 entfernte gegen 24 hinzugefügte Zeilen, keine zweite Fassung steht daneben |
| §6 Risiko 3 — Unversehrtheit der datierten Messzahlen | geprüft, ohne Befund — Zahlen-Diff über alle vier Dateien: null Differenzen; kein Hunk außerhalb des Kopfes |
| [`AGENTS.md`](../../AGENTS.md) §3.7 — Chronik, Konjunktiv, Befund-Kennung, Slice-Nummer in den neuen Zeilen | geprüft, ohne Befund — 0 Treffer über alle 24 hinzugefügten Zeilen |
| Gate-Zusage in der neuen Prosa (die Klasse der zwei MEDIUM des Vorgänger-Laufs) | geprüft, ohne Befund — keiner der vier neuen Absätze nennt einen Sensor, einen Grund-Code oder eine Rot-Folge; es entsteht keine Zusage über einen Prüfumfang |
| Out-of-Scope: [`ADR-0046`](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) selbst | geprüft, ohne Befund — `docs/plan/adr/` nicht im Diff; [`AGENTS.md`](../../AGENTS.md) §3.4 gewahrt |
| Out-of-Scope: emittierte Vorlage `internal/emit/templates/commands/plan-welle.md` | geprüft, ohne Befund — unberührt, ihre Gleichsetzung steht unverändert (Zeile 91); die Ebenen-Trennung des Plans ist gehalten |
| Out-of-Scope: Wellen-Eröffnung/-Schließung, Aussage über die Beginn-Bedingung der drei Wellen | geprüft, ohne Befund — kein `git mv`, keine Roadmap-Änderung, kein Satz über einen eingetretenen Trigger; die Kopfnote spricht über die Regel, nicht über die Beginn-Bedingung dieser drei Wellen |
| Out-of-Scope: `close-welle.md` (Dogfood und emittiert) | geprüft, ohne Befund — beide unberührt; die dort beschriebene *Beförderung* bleibt als benannte, andere Norm-Frage stehen |
| Out-of-Scope: Produkt-Code `internal/`, `cmd/`, `harness/tools/` | geprüft, ohne Befund — vier Dateien im Diff, alle unter `docs/plan/planning/`, nur Modifikationen |
| Vollständigkeit der Fundmenge (die Klasse, deren Ausgang dieser Slice sein soll) | geprüft, ohne Befund — zwei breite Suchen über Gegenstand statt Wortmuster; einziger verbleibender Treffer ist die ausgeschlossene emittierte Vorlage |
| [`AGENTS.md`](../../AGENTS.md) §3.10 — Abschluss nicht im ausführenden Lauf | geprüft, ohne Befund — der Slice-Plan ist nicht im Diff: keine DoD-Häkchen, keine §6-Ausgänge, keine §7 |
| [`AGENTS.md`](../../AGENTS.md) §3.3 — `git mv` und Inhaltsänderung getrennt | geprüft, ohne Befund — der Commit enthält keine Umbenennung |
| [`AGENTS.md`](../../AGENTS.md) §3.11 — bewegte Adresse in einem einfrierenden Artefakt | geprüft, ohne Befund — der Diff legt keine neue Adresse an; die vier Träger sind änderbare Artefakte, in denen der Pfad der richtige Zeiger bleibt |
| Commit-Message: Traceability, Zahl-Beleg, Attribution | geprüft, ohne Befund — `Bezug: ADR-0046`; keine Zahl in der Message (also keine offene Beleg-Pflicht nach [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung) Setzung 1); 0 Treffer für `co-authored-by\|generated with\|claude code\|anthropic` |
| Links und Anker der geänderten Absätze | geprüft, ohne Befund — `make docs-check` real gefahren: 1313 Dateien, 0 Befunde, Module `links`/`anchors`/`ids`/`matrix`/`codepaths`/`spans`/`planning`/`targets` |
| Rumpf von `welle-09` und `welle-11` auf weitere Gleichsetzungs-Reste | geprüft, ohne Befund — `geplant`-Treffer gelesen, einziger ist *„keine geplante Welle"* in der Abhängigkeits-Sektion von `welle-11` (gewöhnliche Sprache) |
| `welle-13` §1 Punkt 2 (die erste Folgepflicht aus [`ADR-0046`](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md)) | geprüft, ohne Befund gegen diesen Slice — vom Planner bereits nachgezogen und inhaltlich konsistent mit Festlegung 1 |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 1 |
| LOW | 1 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** Fremdes Rollen-Artefakt im Implementations-Kontext · Nachzug an
der Vorlage eines anderen Artefakts statt an der eigenen Ziel-Form · Vendored Vorlage nennt einen
Platzhalter, den das adoptierende Repo nicht führt · Baseline-Aussage ohne Mess-Tag

## Verdikt

**Merge-blockierend:** ja — ein HIGH und ein MEDIUM.

Die zwei Liefer-Punkte selbst sind **substanziell erbracht**: Die drei §1-Kommandos sind in diesem
Lauf neu gefahren und liefern `0`, die Ersetzungen sind Ersetzungen und keine Ergänzungen, die
datierten Messzahlen in den drei Welle-Plänen sind nachweislich unangetastet, keine fünfte lebende
Fundstelle ist übrig geblieben, und keine neue Gate-Zusage ist entstanden — die Klasse, an der der
Vorgänger-Lauf zwei MEDIUM einfing, wiederholt sich nicht. `make docs-check` ist über dem
Ergebnis real grün.

Was blockiert, ist erstens die **Rolle** und zweitens die **Wahl der Ziel-Form**. F-1 ist ein
HIGH mit Rollen-Widerspruch: Der Slice-Plan weist die Arbeit dem Implementer zu, eine aktive ADR
weist den Artefakt-Typ dem Planner zu. Nach `v6.8.0` · `regelwerk/modul-08-agentenrollen.md`
§Konflikt-Pfad als Rollen-Sequenz gehört das als Sequenz mit Übergabe-Artefakten zum **Architect**
— das Verdikt ist eines der drei dort genannten, und „herabstufen, weil der Implementer
widerspricht" ist keines davon. Dieser Report ist das Übergabe-Artefakt.

**Übergabe:** Findings gehen an den Implementer (Rückkante Review → Plan bei F-2, Rückkante
Review → Architect bei F-1); die **Finding-Klassen** gehen zusätzlich in die Slice-Closure §7 und
von dort in den Zähler — für F-1 und F-3/F-4 existieren die Verzeichnisse
`BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext` und
`BEO-ALL/vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt` bereits, für F-5
`BEO-ALL/baseline-aussage-ohne-mess-tag`; die Zuordnung trifft die Closure, nicht dieser Report.
Dieser Report selbst ist ein **Lauf-Beleg** (Audit: dieser Diff, dieser Skill, dieses Modell,
dieses Verdikt) — er wird über Läufe hinweg nicht wieder gelesen. Der Report ersetzt keine
Verifikation — DoD-/Spec-Konformität prüft der Verifier separat (Modul 11; anderes Prüf-Artefakt,
anderer Eingabe-Kontext).
