# Review-Report: slice-wellen-schnitt-folgt-der-eroeffnungs-regel — 2026-09-14

**Review-Art:** Code-Review — geprüft wird der Diff gegen den Slice-Plan und gegen
[`ADR-0046`](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) (Modul 10 §Drei
Review-Arten). Gegenstand ist Prosa in drei lebenden Trägern; „Code" meint hier den Diff, nicht
Produkt-Code.

**Gegenstand:** drei Commits `a9138e86` (Träger 1, `welle-13`) · `fdb5465a` (Träger 2, Roadmap) ·
`bf5e5bca` (Träger 3, Anweisungssatz). **Geprüfter Stand:** `bf5e5bca` (HEAD, `main`),
`git status --porcelain` leer. **Kein Self-Review:** dieser Lauf hat an keinem der drei Commits
geschrieben.

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

- Slice-Plan `slice-wellen-schnitt-folgt-der-eroeffnungs-regel` (§1 Abgrenzung, §2 DoD, §3 Plan,
  §5 Closure-Trigger, §6 Risiken)
- [`ADR-0046`](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) — Festlegung 1,
  §Was diese Entscheidung nicht tut, §Konsequenzen, §Fitness Function
- [`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1
- [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) ·
  [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules; tragend hier §3.4, §3.6, §3.7, §3.8, §3.10)
- `.d-check.yml` §`planning` und `harness/sensors/docs-check.md` §Modul `planning` (für die
  Grund-Codes `wave-preview-exists` / `wave-drift`)
- Baseline `v6.8.0` · `regelwerk/modul-13-quality-gates.md` §Hard Rule (Doku-Disziplin)

---

## Eigene Messungen

Alle Kommandos dieses Abschnitts sind in diesem Lauf über `bf5e5bca` selbst gefahren; keine Zahl
ist aus einer Commit-Message übernommen. Kein Docker-Ziel gefahren (`make gates`, `make mutate`,
`make docs-check` liegen beim Auftraggeber).

### Die sieben §1-Kommandos — alle sieben neu gefahren

```sh
grep -c 'aktive bzw. geplante' .claude/commands/plan-welle.md                                       # 0
grep -c 'Ob eine flache Welle \*aktuell\* oder \*geplant\* ist' .claude/commands/plan-welle.md      # 0
grep -c 'aktiv/geplant' .claude/commands/plan-welle.md                                              # 0
grep -c 'geplant' .claude/commands/plan-welle.md                                                    # 1
grep -c 'Ein verlinkter Name hat eine flache Plan-Datei' docs/plan/planning/in-progress/roadmap.md  # 0
grep -c 'Ein Sensor nach \[slice-125\]' docs/plan/planning/welle-13-regeln-bekommen-ihren-sensor.md # 0
grep -c 'roadmap.md) unter \*Offene Wellen\*' docs/plan/planning/welle-13-regeln-bekommen-ihren-sensor.md  # 0
```

Sechs der sieben liefern `0`. Das siebte — `grep -c 'geplant'` — ist kein Muster für eine überholte
Formulierung, sondern der Fundmengen-Zähler; sein einziger Resttreffer ist inspiziert:

```sh
grep -n 'geplant' .claude/commands/plan-welle.md
# 6:Welle ist ein **Bündel von Slices**, das gemeinsam geplant und geschlossen wird. …
```

Er setzt nichts mit der flachen Datei gleich. **Damit trägt jedes der sieben** — sechs als Null,
das siebte über den gelesenen Resttreffer, so wie DoD (3) es formuliert. Keine der Zahlen ist ein
Erwartungswert
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

### Liefer-Punkt (1) — bleiben die Messzahlen unangetastet?

Nicht nach Augenschein, sondern als Zahlen-Diff über die **ganze** Datei:

```sh
diff <(git show a9138e86^:docs/plan/planning/welle-13-regeln-bekommen-ihren-sensor.md | grep -oE '[0-9]+') \
     <(git show a9138e86:docs/plan/planning/welle-13-regeln-bekommen-ihren-sensor.md  | grep -oE '[0-9]+')
# 91,93c91,93
# < 11 / 125 / 125        (aus "welle-11" und zwei "slice-125")
# > 0046 / 0046 / 1       (aus zwei Entscheidungs-Kennungen und einer Festlegungs-Nummer)
git show a9138e86 --format= -U0 | grep '^@@'   # @@ -79,7 +79,7 @@   (genau ein Hunk)
```

Keine Messzahl des Absatzes ist berührt — `23`, `21`, `2`, `1`, `0`, `4`, `133`, `20`, `157`, `12`,
`8` stehen unverändert. Die drei geänderten Zahl-Token stammen ausschließlich aus entfernter bzw.
neuer Prosa. Ein Hunk, 7/7 Zeilen, strikt innerhalb §1 Punkt 2. **Getragen**, wie
[`ADR-0046`](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Konsequenzen es verlangt.

### Liefer-Punkt (2) — der Grund-Code gegen seine zwei Quellen

```sh
grep -n 'ERSTE Spalte' .d-check.yml
# 41:# Ausserhalb dieser beiden Abschnitte liest `waves` zusaetzlich die ERSTE Spalte der
grep -n 'Eine Kennung in Spalte 1' harness/sensors/docs-check.md   # (Fünf-Lagen-Tabelle, Lage 1–3)
```

Beide Quellen sagen dasselbe und binden es an **Spalte 1**: `.d-check.yml` („die ERSTE Spalte der
Vorschau-Tabelle … verlinkt wie unverlinkt … Blind bleibt `waves` nur fuer eine Nennung in
Spalte 3"), `harness/sensors/docs-check.md` mit fünf gemessenen Lagen, deren vierte lautet
*„flache Datei + Zeiger unter „Offene Wellen" + Nennung nur in Spalte 3 (Wichtigste Slices) →
0 Befunde"*.
[`ADR-0046`](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Fitness Function führt
denselben Wortlaut („Eine Kennung in **Spalte 1** von *Nächste Wellen*"). Die Hälfte *verlinkt wie
unverlinkt* des neuen Roadmap-Satzes ist damit belegt; die Spalten-Hälfte fehlt — Finding F-1.

Der Ist-Bestand liefert das Gegenbeispiel selbst:

```sh
sed -n '/^## Nächste Wellen/,/^## /p' docs/plan/planning/in-progress/roadmap.md \
  | grep '^| ' | awk -F'|' '{print $4}' | grep -oE 'welle-[0-9]+' | sort | uniq -c
#   2 welle-09
#   4 welle-13
ls docs/plan/planning/welle-*.md   # welle-09…, welle-11…, welle-13…  (alle drei existieren)
```

### Liefer-Punkt (3) — vier Fundstellen, und die Suche nach einer fünften

Alle vier sind im Diff `bf5e5bca` nachgezogen und durch die Kommandos oben als `0` belegt: Kopf
`aktive bzw. geplante` (Zeile 7), Kopf `Ob eine flache Welle *aktuell* oder *geplant* ist`
(Zeilen 9–10), Schritt 9, Schritt 10 (`aktiv/geplant`). Dazu die fünfte, die der Commit selbst
zusätzlich nennt:

```sh
grep -c 'Aktuelle Welle' .claude/commands/plan-welle.md   # 0
```

**Nach einer neu entstandenen Gleichsetzung gesucht** — über alle Begriffe, die sie tragen könnten:

```sh
grep -nEi 'geplant|geschnitten|Kandidat|Vorschau|Nächste Wellen|aktuell|aktiv' .claude/commands/plan-welle.md
```

Sechs Treffer, alle gelesen: Zeile 6 (`gemeinsam geplant`, der legitime Rest), Zeilen 13/16
(Vorschau als Zustand *vor* der Eröffnung — die geltende Aussage), Zeile 47 (Lese-Frage in
Schritt 3, ohne Gleichsetzung), Zeilen 90/92 (die zwei Roadmap-Wirkungen der Eröffnung). **Keine
fünfte Stelle derselben Gleichsetzung ist entstanden.** Neu entstanden ist jedoch eine
Gate-Zusage, die weiter reicht als das Modul — Finding F-2.

### Die zwei rot gesehenen Gegenbeispiele (`fdb5465a`)

Dokumentiert, nicht behauptet: Die Message trägt je Lage das **Kommando** (`make docs-check`), den
**Grund-Code** (`wave-preview-exists`, `wave-drift`), die **Fundstelle mit Zeile** und die
**Zählzeile mit EXIT**. Gegengeprüft auf innere Stimmigkeit:

- Lage 1 (Vorschau-Zeile + Datei + Zeiger) → 1 Befund. Deckt sich mit Lage 2/3 der
  Fünf-Lagen-Tabelle in `harness/sensors/docs-check.md`.
- Lage 2 (Zeiger entfernt) → 2 Befunde, `wave-drift` **und** `wave-preview-exists`. Deckt sich mit
  Lage 1 derselben Tabelle.
- Die Zeilennummern sind arithmetisch konsistent und nicht trivial rekonstruierbar: Die
  Vorschau-Tabelle endet heute bei Zeile 43, die eingefügte Zeile liegt also bei **44** (Lage 1);
  entfernt man den Zeiger in Zeile 21, rückt sie auf **43** (Lage 2) — genau die zwei Werte der
  Message. `wave-drift` wird bei **11** gemeldet, der Zeile `## Offene Wellen`, die vor der
  Entfernung liegt und darum *nicht* mitwandert.

```sh
sed -n '11p;21p;43p' docs/plan/planning/in-progress/roadmap.md
# 11: ## Offene Wellen
# 21: - [welle-13 — Regeln bekommen ihren Sensor] …   <- der Zeiger auf welle-13
# 43: | Doku- und Sensor-Wartung | …
```

Das ist der Beleg eines realen Laufs, nicht einer Herleitung
([`AGENTS.md`](../../AGENTS.md) §3.6). **Getragen** — und über §5 Closure-Kriterium 2 hinaus, das
nur *ein* Gegenbeispiel verlangt.

### Out-of-Scope-Treue

```sh
git show --pretty=format: --name-status a9138e86 fdb5465a bf5e5bca | sort -u | grep -v '^$'
# M  .claude/commands/plan-welle.md
# M  docs/plan/planning/in-progress/roadmap.md
# M  docs/plan/planning/welle-13-regeln-bekommen-ihren-sensor.md
```

Genau die drei Träger, nur Modifikationen. Null Treffer für `docs/plan/adr/` (§3.4 gewahrt),
`AGENTS.md` und `harness/conventions` (§3.8 gewahrt), `internal/emit/` (die emittierte Vorlage
unberührt), `.claude/commands/close-welle.md`, `docs/plan/planning/done/`,
`docs/plan/planning/observations/`, `harness/sensors/`, `cmd/`, `internal/`, `harness/tools/`.
Der Slice-Plan selbst ist **nicht** angefasst — keine DoD-Häkchen, keine §6-Ausgänge, keine §7:
[`AGENTS.md`](../../AGENTS.md) §3.10 gewahrt, der Abschluss bleibt dem Planner in frischem Kontext.
Keine Attributions-Zeile in einer der drei Messages
(`git log --no-walk --format='%B' a9138e86 fdb5465a bf5e5bca | grep -icE 'co-authored-by|generated with|claude code|anthropic'`
→ **0**). Jede Message trägt eine Traceability-Kennung
([`ADR-0046`](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) in allen dreien).

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der
verbindlichen Single Source of Truth. Die Spalten unten sind nur
**gespiegelt** (Bequemlichkeit beim Ausfüllen), nicht neu definiert; bei
Abweichung gilt der Skill bzw. dessen Quelle
`v6.8.0` · `regelwerk/modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill.

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Der neue Gate-Satz sagt „Existiert zu **einer hier genannten Kennung** bereits eine flache Datei, meldet `make docs-check` `wave-preview-exists`" und lässt die Spalten-Grenze weg, die `.d-check.yml`, `harness/sensors/docs-check.md` und `ADR-0046` §Fitness Function alle drei führen. Das Gegenbeispiel steht in der Tabelle darunter: `welle-13` (4×) und `welle-09` (2×) sind in Spalte 3 genannt, beide haben eine flache Datei, und nach der gemessenen Lage 4 meldet das Modul dafür 0 Befunde. | [`ADR-0046`](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Fitness Function · `v6.8.0` · `regelwerk/modul-13-quality-gates.md` §Hard Rule (Doku-Disziplin), *„Ein Gate ohne seine Grenze behauptet ebenfalls zu viel"* | `docs/plan/planning/in-progress/roadmap.md`:34–36 | nein — kein Modul hält einen Prosa-Satz gegen den Prüfumfang eines anderen Moduls; `make docs-check` bleibt über diesem Satz grün | Gate-Zusage in einem lebenden Träger reicht weiter als der Prüfumfang des Moduls |
| F-2 | MEDIUM | Der neue Kopf-Absatz stellt die Trigger-Pflicht („die verlangt den eingetretenen Start-Trigger") und die Gate-Folge („Wer die Datei früher anlegt, färbt `make docs-check` rot") in denselben Absatz, ohne die Grenze zu nennen. Kein Modul liest den Start-Trigger: Geprüft ist allein die Kopplung *Datei ⟺ Zeiger ⟺ nicht in der Vorschau*, und eine **vollständig** vorgezogene Eröffnung (Datei + Zeiger + entfallende Vorschau-Zeile) ist grün. | [`ADR-0046`](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Was diese Entscheidung nicht tut (*„Sie entscheidet nicht, wann ein Start-Trigger eingetreten ist"*) und §Fitness Function (*„Träger … ist darum der Rollen-Wechsel und kein Sensor"*) · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) | `.claude/commands/plan-welle.md`:12–19 | nein — dieselbe Lage wie F-1; die Zusage liegt außerhalb jeder Modul-Reichweite | Gate-Zusage in einem lebenden Träger reicht weiter als der Prüfumfang des Moduls |
| F-3 | LOW | Der Kopf setzt bei nicht eingetretenem Trigger „Schritt 7 und Schritt 9" aus und schweigt zu Schritt 8, der die in Schritt 7 erzeugte Datei in-place füllt. Ein Lauf, der dem Anweisungssatz folgt, erreicht Schritt 8 ohne Datei; der nächstliegende Weg, ihn zu erfüllen, ist das Anlegen der Datei — genau der Zustand, den derselbe Absatz sechs Zeilen darüber ausschließt. | [`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1 · Maintainability | `.claude/commands/plan-welle.md`:17 | nein — kein Gate liest einen Anweisungssatz auf Ablauf-Vollständigkeit | Anweisungssatz zählt die ausgesetzten Schritte unvollständig auf |
| F-4 | INFO | §5 Closure-Kriterium 1 verlangt, dass „die sieben Mess-Kommandos aus §1 … `0`" liefern; §2 DoD (3) verlangt für dasselbe Kommando „nur noch Treffer, die mit der flachen Datei nichts gleichsetzen". Kommando 4 liefert plangemäß `1`. Zwei Abnahme-Formulierungen desselben Liefer-Punkts mit verschiedener Strenge — die Umsetzung folgt der DoD, wer §5 wörtlich liest, sieht einen Fehlschlag. | Maintainability (Plan-Defekt, Rückkante Review → Plan) | Slice-Plan `slice-wellen-schnitt-folgt-der-eroeffnungs-regel` §5 Kriterium 1 gegen §2 DoD (3) | nein — Plan-interne Spannung, kein Gate-Gegenstand | Zwei Abnahme-Formulierungen desselben Liefer-Punkts unterschiedlich streng |
| F-5 | INFO | `welle-13` trägt nach dem Nachzug beide Lesarten: §1 Punkt 2 die geltende, die `Lifecycle:`-Kopfnote in Zeile 6 weiter „Ob eine flache Welle *aktuell* oder *geplant* ist, sagt die Roadmap". Das ist **bewusst so** — DoD (1) nennt namentlich nur §1 Punkt 2 — und wird hier als Übergabe an den Folge-Slice festgehalten, nicht als Befund gegen diesen Slice. | Bewusste Won't-Fix-Designnotiz ([`AGENTS.md`](../../AGENTS.md) §3.10 — keine eigenmächtige Erweiterung des Abnahmekriteriums) | `docs/plan/planning/welle-13-regeln-bekommen-ihren-sensor.md`:6 | nein | Derselbe Träger führt die alte und die neue Aussage bis zum Folge-Slice |

**Zu F-1 und F-2, und warum sie nicht HIGH sind.** Beide Sätze sind unter der engen Lesart wahr:
F-1 bindet „hier genannt" an die unmittelbar davorstehende Spalte 1, F-2 meint mit „die Datei früher
anlegen" die Datei *ohne* die zwei anderen Wirkungen. Kein Wort ist falsch. Was fehlt, ist die
Grenze — und genau diese Klasse benennt `v6.8.0` · `regelwerk/modul-13-quality-gates.md` als
*„ein behauptetes Gate ohne Deckung — nur eines, bei dem jedes einzelne Wort stimmt"*. Der
Kontext-Eskalations-Schritt des Skills ist damit bereits eingerechnet (Basis wäre Doku-Drift/LOW),
nicht zweimal angewandt. Beide sind Ein-Satz-Korrekturen, kein Umschnitt.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Liefer-Punkt (1) — wörtliche Vollständigkeit der Ersetzung in `welle-13` §1 Punkt 2 | geprüft, ohne Befund — beide Mess-Kommandos `0`, ein Hunk, 7/7 Zeilen |
| Liefer-Punkt (1) — Unversehrtheit der danebenstehenden Messzahlen | geprüft, ohne Befund — Zahlen-Diff über die ganze Datei zeigt nur Prosa-Token |
| Liefer-Punkt (2) — Äquivalenz des neuen Satzes zu `ADR-0046` Festlegung 1 | geprüft, ohne Befund — *unverlinkt*, *keine Datei*, *Datei entsteht mit der Eröffnung*, *Zeile verlässt den Abschnitt* sind alle vier getragen |
| Liefer-Punkt (2) — bleibt der Satz hinter Festlegung 1 zurück? | geprüft, ohne Befund — die zwei nicht genannten Hälften sind gedeckt: „kein Zeiger unter *Offene Wellen*" folgt aus „keine Datei" (ein Zeiger darauf wäre ein toter Link), und die Ein-Commit-Kopplung trägt Träger 3 in Schritt 9 |
| Liefer-Punkt (3) — sind alle **vier** Fundstellen behoben? | geprüft, ohne Befund — Kopf 2×, Schritt 9, Schritt 10, dazu `Aktuelle Welle` → alle `0` |
| Liefer-Punkt (3) — ist eine **fünfte** Stelle derselben Gleichsetzung entstanden? | geprüft, ohne Befund — sechs Kandidaten-Treffer gelesen, keiner setzt die flache Datei mit *geplant*/*Vorschau* gleich |
| `AGENTS.md` §3.7 — Ersetzung statt Ergänzung, kein Konjunktiv, keine Chronik | geprüft, ohne Befund — kein „früher/bisher/wäre/hätte/nicht mehr/seither" in den hinzugefügten Zeilen; das einzige „früher" ist futurisch („Wer die Datei früher anlegt"), keine Aussage über die abgelöste Fassung |
| Die zwei rot gesehenen Gegenbeispiele in `fdb5465a` | geprüft, ohne Befund — Kommando, Grund-Code, Fundstelle, Zählzeile und EXIT je Lage; Zeilenarithmetik gegengerechnet und stimmig |
| Out-of-Scope-Treue — `ADR-0046`, Adaptions-Block, Wellen-Eröffnung/-Schließung, Aussage über die drei offenen Wellen | geprüft, ohne Befund — drei Dateien, nur Modifikationen, null Treffer in allen ausgeschlossenen Bäumen |
| `AGENTS.md` §3.10 — Abschluss nicht im ausführenden Lauf | geprüft, ohne Befund — Slice-Plan unberührt, DoD-Häkchen offen, §6-Ausgänge und §7 leer |
| Der bekannte, bewusst nicht behobene Rest (vier lebende Fundstellen) | geprüft, ohne Befund gegen diesen Slice — `docs/plan/planning/README.md`:26 und die Kopfnoten von `welle-09`/`welle-11`/`welle-13` tragen die Gleichsetzung; DoD (1)–(3) nennt namentlich `welle-13` **§1 Punkt 2**, `roadmap.md` §Nächste Wellen und `plan-welle.md` — DoD und Fund stimmen überein |
| Neue Markdown-Links der drei Diffs | geprüft, ohne Befund — alle drei `ADR-0046`-Ziele lösen von ihrem Schreibort auf, und jede `ADR-`-Kennung steht als Link (Link-Pflicht des Moduls `ids`) |
| Commit-Messages gegen `MR-051` Setzung 1 und `MR-025` | geprüft, ohne Befund — jede Zahl steht neben dem Kommando, das sie ausgibt; Erwartungswert-Klausel jeweils gesetzt |
| Hinterlassene Verweis-Reste der entfernten Sätze | geprüft, ohne Befund — die entfernten Formulierungen leben nur noch in `ADR-0046` (eingefroren, zitiert korrekt) und im Slice-Plan (die DoD selbst); `slice-125` bleibt 5× in `welle-13` referenziert, nichts verwaist |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 1 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** Gate-Zusage in einem lebenden Träger reicht weiter als der
Prüfumfang des Moduls · Anweisungssatz zählt die ausgesetzten Schritte unvollständig auf · Zwei
Abnahme-Formulierungen desselben Liefer-Punkts unterschiedlich streng · Derselbe Träger führt die
alte und die neue Aussage bis zum Folge-Slice

*F-1 und F-2 tragen **eine** Klasse und sind ein Vorgang, also **eine** Gelegenheit für den Zähler
(`v6.8.0` · `regelwerk/modul-06-roadmap.md` §Das Beobachtungs-Register: „Zwei Funde im selben
Vorgang sind eine Gelegenheit").*

## Verdikt

**Merge-blockierend:** ja — zwei MEDIUM.

Die drei Liefer-Punkte selbst sind **substanziell erbracht**: Alle sieben §1-Kommandos sind in
diesem Lauf neu gefahren und tragen, die Ersetzungen sind Ersetzungen und keine Ergänzungen, die
Messzahlen in `welle-13` sind nachweislich unangetastet, alle vier Fundstellen im Anweisungssatz
sind nachgezogen ohne dass eine fünfte entstanden wäre, und die zwei Gegenbeispiele sind real rot
gesehen statt behauptet. Die Out-of-Scope-Grenzen sind vollständig gehalten, einschließlich der
Rollen-Grenze aus [`AGENTS.md`](../../AGENTS.md) §3.10.

Was blockiert, ist nicht der Nachzug, sondern zwei **neu geschriebene** Gate-Zusagen, die weiter
reichen als das Modul, das sie nennen — dieselbe Klasse, gegen die dieser Slice antritt, nur in die
andere Richtung: Statt einer Anleitung in ein rotes Gate steht jetzt zweimal eine Gate-Zusage über
einem Ausschnitt, den das Gate nicht prüft
([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine Ebene
tiefer). Beide sind an je einem Satz zu beheben; ein Umschnitt des Slice folgt daraus nicht, und
keine der vier §1-Abgrenzungen wird dadurch berührt.

**Übergabe:** Findings gehen an den Implementer (F-4 nimmt die Rückkante Review → Plan); die
**Finding-Klassen** gehen zusätzlich in die Slice-Closure §7 und von dort in den Zähler. Dieser
Report ist ein **Lauf-Beleg** und wird über Läufe hinweg nicht wieder gelesen. Er ersetzt keine
Verifikation — DoD-Konformität, `make gates` und `make mutate` prüft der Verifier separat
(Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext). Dieser Lauf hat **kein** Docker-Ziel
gefahren; alle Sonden oben sind lesend.
