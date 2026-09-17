# Architect-Verdikt zu F-1: `slice-stilllegungs-form-hat-einen-waechter`

**Rolle:** Architect (Modul 8, Konflikt-Pfad Reviewer → Architect → Implementer/Planner).
**Datum:** 2026-09-17. **Autor:** ai-harness-init-Team (pt9912). **Modell:** `claude-opus-5[1m]`.

**Gegenstand:** Befund F-1 (HIGH) aus dem Review-Report
[`2026-09-17-slice-stilllegungs-form-hat-einen-waechter.md`](2026-09-17-slice-stilllegungs-form-hat-einen-waechter.md)
gegen den Implementer-Stand `8366b374`. Die Frage lautet: Muss ein gelieferter Slice in diesem Repo
mit Wellen-Betrieb die letzte DoD-Zeile der Vorlage abhaken, bevor er in `done/` liegt? Diese Zeile
lautet: *„Die drei Paarungen … sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo
**mit** Wellen von der nächsten Welle-Closure …"*.

**Prüfgrundlage:** Baseline `v6.9.0`, und zwar `regelwerk/modul-05-planning-harness.md`,
`regelwerk/modul-06-roadmap.md`, `regelwerk/modul-11-verification.md` und
`templates/docs/plan/planning/slice.template.md` §2 und §7. Dazu
[ADR-0056](../plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md),
[`AGENTS.md`](../../AGENTS.md) §3.5 und `MR-000`.

Die Zahlen unten gelten für den Stand `90263a93` und sind **keine Erwartungswerte**.

---

## 1. Verdikt

**Verdikt 1: Die Lesart des Gates ist die der Baseline.** Es liegt keine Abweichung vor. Es braucht
keinen `MR`-Eintrag, keine ADR und keine Anforderung an d-check. Das Gate ist nicht schärfer als
seine Quelle.

Die Aussage ist richtig, aber ihre Artefakte nennen die Stelle nicht, die sie trägt.
[`.d-check.yml`](../../.d-check.yml) und
[`harness/sensors/docs-check.md`](../../harness/sensors/docs-check.md) §Modul `structure` stützen
sich nur auf den Satz *„DoD-Häkchen sind Bedingung für `done/`"*. Die Paarungen-Zeile erwähnen sie
nicht. Das holt der Implementer mit den Sätzen aus §3 nach. Die Closure-Seite liegt beim Planner
(§4).

## 2. Begründung

**Die Baseline benennt die Zeile ausdrücklich.** Der Reviewer vermisst eine Quelle, die festlegt,
dass die Zeile schon bei der Slice-Closure abgehakt wird. In `v6.9.0` ·
`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer übernimmt, steht:

> „Das ist die einzige Ausnahme davon, dass DoD-Häkchen Bedingung für `done/` sind — und sie gilt
> nur für die **Liefer-Punkte** der DoD … Die Closure-Pflichten darunter (Notiz, Register,
> Risiko-Ausgänge, Paarungen) werden abgehakt wie bei jeder Closure."

(`grep -n 'werden abgehakt wie bei jeder Closure' .harness/baseline/v6.9.0/regelwerk/modul-05-planning-harness.md`
→ Zeile **191**.) Die Paarungen stehen also namentlich unter den Pflichten, die bei **jeder**
Closure abgehakt werden. Das gilt für jede Closure, ob das Repo Wellen führt oder nicht. Die einzige
Ausnahme betrifft die Liefer-Punkte eines stillgelegten Slice. §Lifecycle als State Machine
derselben Datei sagt dasselbe: *„mit einer Ausnahme für die Liefer-Häkchen"*.

**Die Zeile ist mit dieser Lesart vereinbar.** Im Repo mit Wellen sagt sie, wer die Paarungen
prüft, nämlich die nächste Welle-Closure. Das trifft schon bei der Slice-Closure zu, denn laut
`v6.9.0` · `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht *„liest und prüft [die
Welle-Closure] alles, was seit der letzten Welle in `done/` liegt — auch Slices ohne
Wellen-Zugehörigkeit"*. Das Häkchen bestätigt diese Zuweisung. Es behauptet nicht, dass die
Prüfung schon stattgefunden hat.

**Die Stellen, auf die sich der Reviewer stützt, regeln den Zeitpunkt, nicht das Ob.**
- Die Zeile *„Alle drei Paarungen … **nach** dem `git mv`"* in `modul-06-roadmap.md` steht in der
  Tabelle mit der Kopfzeile *„Träger im Repo **ohne** Wellen"*
  (`grep -nE 'Träger im Repo \*\*ohne\*\* Wellen|Alle drei Paarungen\*\*' .harness/baseline/v6.9.0/regelwerk/modul-06-roadmap.md`
  → Zeilen **43** und **49**). Dort prüft die Slice-Closure die Paarungen selbst, und zwar erst
  nach dem Move.
- Der Hinweis in §7 der Vorlage, *„einzige Ausnahme ist das letzte DoD-Item in §2 (die Paarungen
  suchen in `done/`, also nach dem `git mv`)"*, legt fest, **wann** abgehakt wird. Für das Repo
  ohne Wellen nennt er dafür drei Commits: *„Inhalt, `git mv`, Haekchen"*. Dass das Kästchen offen
  bleibt, sagt er nicht. Er ist außerdem als *„keine Norm"* gekennzeichnet.

**Die Gegenlesart führt zu einem Kästchen, das nie jemand abhakt.** Nach dieser Lesart bleibt das
Kästchen offen, bis die Welle-Closure prüft. Aber kein Schritt der Welle-Closure hakt die DoD eines
Slice ab:
- `grep -ciE 'häkchen|abgehakt|abhaken' .harness/baseline/v6.9.0/regelwerk/modul-06-roadmap.md` → **0**
- dasselbe über `.claude/commands/close-welle.md` → **0**

Im Bestand ist das bereits zu sehen. `welle-emittierte-werkzeuge` ist geschlossen, und ihre
Ergebnis-Notiz führt die drei Paarungen. Trotzdem sind die Kästchen ihrer Mitglieder noch offen:

```sh
grep -lE '^\s*- \[ \] Die drei Paarungen' \
  $(grep -l '^\*\*Welle:\*\* \[welle-emittierte-werkzeuge\]' docs/plan/planning/done/slice-*.md) | wc -l   # 4
```

Das offene Kästchen wäre damit eine zweite, dauerhafte Ausnahme. Genau die schließt `modul-05` mit
*„einzige"* aus. Im Bestand stehen beide Lesarten nebeneinander:
`grep -lE '^\s*- \[ \] Die drei Paarungen' docs/plan/planning/done/slice-*.md | wc -l` → **7**
offen, mit `\[[xX]\]` → **69** abgehakt. Keiner dieser Pläne ist eine Quelle. Die sieben offenen
stehen alle in `exempt-paths`.

**Maßstab `v6.9.0` · `modul-11-verification.md` §Fitness Function ohne Standard-Tool.** Die Quelle
verlangt: Alle DoD-Punkte sind abgehakt, außer den Liefer-Punkten eines stillgelegten Slice. Das
Gate verlangt: Keine offenen Punkte in §2, außer §7 trägt eine `Gegenstand:`-Marke. Bei einem
gelieferten Slice sind beide Schwellen gleich. Beim stillgelegten Slice ist das Gate lockerer: Es
prüft weder, welche Punkte offen sind, noch was die Marke enthält. Diese Grenze ist in
`docs-check.md` bereits genannt. Schärfer als die Quelle ist das Gate nirgends.

**Was daraus nicht folgt.**
- **Kein `MR-066`.** Das Gate setzt eine Regel der adoptierten Baseline um, und
  [ADR-0056](../plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md) übernimmt `v6.9.0`
  vollständig. Eine Lesart, die von der Baseline nicht abweicht, bekommt keinen Eintrag im
  Adaptions-Block (`MR-000`).
- **Keine Anforderung an d-check.** `tasks-ignore-pattern` wirkt in d-check `v0.76.1` nur auf
  `max-tasks`. Ein Schalter, der die Paarungen-Zeile aus `max-open-tasks` nähme, würde das Gate
  unter seine Quelle senken. Das wäre eine Senkung nach `AGENTS.md` §3.5.

## 3. Übernahme für den Implementer

Die Sätze sind wörtlich zu übernehmen. Die Zeilenangaben gelten für `90263a93`.

**[`.d-check.yml`](../../.d-check.yml), Zeilen 73–76.** Der Block ersetzt diese vier Zeilen
vollständig, von *„Offene Items ausserhalb"* bis *„nennt beide Auswege."*. Er nutzt die
ASCII-Umschrift des übrigen Kommentars:

```text
# Offene Items ausserhalb von §2 zaehlen nicht, eine Marke ausserhalb von §7 auch nicht. Ein
# regulaer gelieferter Slice traegt in done/ keine offenen Items (v6.9.0 · modul-05 §Lifecycle als
# State Machine: die DoD-Haekchen sind Bedingung fuer done/; §Ein Slice, dessen Gegenstand ein
# anderer uebernimmt: einzige Ausnahme sind die Liefer-Punkte eines stillgelegten Slice). Das
# gilt auch fuer die letzte DoD-Zeile der Vorlage, "Die drei Paarungen ... sind getragen": dieselbe
# modul-05-Stelle zaehlt die Paarungen zu den Closure-Pflichten, die "wie bei jeder Closure"
# abgehakt werden. Im Repo mit Wellen-Betrieb sagt das Haekchen, dass die naechste Welle-Closure
# die Paarungen prueft (v6.9.0 · modul-06 §Wann Arbeit eine Welle braucht), nicht, dass sie schon
# geprueft sind. Traegt ein gelieferter Slice doch ein offenes Item, faerbt er dieselbe Regel rot,
# und `hint` nennt beide Auswege.
```

**[`harness/sensors/docs-check.md`](../../harness/sensors/docs-check.md) §Modul `structure`, Absatz
*Was es hält*.** Ersetzt die zwei Sätze ab *„Ein regulär gelieferter Slice trägt in `done/` keine
offenen Items"* bis *„nennt beide Auswege."*:

> Ein regulär gelieferter Slice trägt in `done/` keine offenen Items
> (`.harness/baseline/v6.9.0/regelwerk/modul-05-planning-harness.md` §Lifecycle als State Machine:
> die DoD-Häkchen sind Bedingung für `done/`; §Ein Slice, dessen Gegenstand ein anderer übernimmt:
> die einzige Ausnahme sind die Liefer-Punkte eines stillgelegten Slice). **Das gilt auch für die
> letzte DoD-Zeile der Vorlage**, *„Die drei Paarungen … sind getragen"*: Dieselbe Stelle zählt die
> Paarungen zu den Closure-Pflichten, die *„wie bei jeder Closure"* abgehakt werden. Im Repo mit
> Wellen-Betrieb sagt das Häkchen, dass die nächste Welle-Closure die Paarungen prüft. Sie liest
> auch Slices ohne Wellen-Zugehörigkeit (`v6.9.0` · `modul-06-roadmap.md` §Wann Arbeit eine Welle
> braucht). Das Häkchen sagt nicht, dass die Paarungen schon geprüft sind. Die Zeile *„**nach** dem
> `git mv`"* in `modul-06` steht in der Tabelle für das Repo **ohne** Wellen. Sie regelt, wann
> abgehakt wird, nicht ob. Trägt ein gelieferter Slice doch ein offenes Item, färbt er dieselbe
> Regel rot, und der `hint` nennt beide Auswege.

**Dieselbe Datei, Liste *Grenzen*, Punkt *Eine einzelne DoD-Zeile lässt sich nicht ausnehmen*.**
Der letzte Satz *„Ein künftiger regulärer Slice, der sie offen lässt, ist Lage V8."* wird ersetzt
durch:

> Ein künftiger regulärer Slice, der sie offen lässt, ist Lage V8. Das Rot folgt der Quelle
> (*Was es hält*): Die Baseline sieht für diese Zeile keine Ausnahme vor, das Werkzeug muss also
> keine bieten.

Der `hint` und die Regel bleiben unverändert.

## 4. Übergabe an den Planner

1. **Die Paarungen-Zeile wird bei jeder Slice-Closure abgehakt.** In diesem Repo bedeutet das
   Häkchen: Die nächste Welle-Closure prüft die Paarungen. Bei der Slice-Closure gibt es nichts zu
   prüfen. Das Häkchen kann deshalb schon im Inhalts-Commit vor `make slice-mv` stehen. Ein Zusatz
   wie *„bleibt offen"* entfällt. Die §7-Zeile *„Drei Paarungen:"* ist laut Vorlage nur im Repo
   ohne Wellen-Betrieb vorgesehen.
2. **`slice-stilllegungs-form-hat-einen-waechter` selbst:** Seine DoD führt die Zeile noch offen,
   und seine §7 trägt *„Drei Paarungen: offen bis zur Closure."*. Bleibt das Kästchen in `done/`
   offen, färbt das eigene Gate rot (Lage V8). Den Slice in `exempt-paths` aufzunehmen wäre eine
   Senkung nach `AGENTS.md` §3.5.
3. **Die sieben offenen Pläne bleiben, wie sie sind.** Sie sind Zeitdokumente und stehen in
   `exempt-paths`. Sie werden nicht nachgerüstet.
4. **Der Träger, den das Häkchen zusagt, fehlt im Anweisungssatz.**
   `.claude/commands/close-welle.md` erwähnt die drei Paarungen nicht
   (`grep -ci 'paarung' .claude/commands/close-welle.md` → **0**). `v6.9.0` ·
   `modul-06-roadmap.md` §Wellen-Closure-Prozedur, Schritt 3, verlangt sie, und die Ergebnis-Notiz
   von `welle-emittierte-werkzeuge` führt sie. Der Anweisungssatz gehört dem Planner (`ADR-0028`).
   Ob er ergänzt wird, entscheidet der Planner.
5. **Register:** Ob die Closure die Finding-Klasse *„Gate entscheidet eine Auslegung, die keine
   Quelle getroffen hat"* aufnimmt, entscheidet §7. Nach diesem Verdikt hat das Gate keine
   Auslegung getroffen. Nur seine Artefakte nannten die tragende Stelle nicht.

**An den Reviewer:** F-1 gilt als erledigt, wenn §3 übernommen ist. Das Finding wird damit nicht
herabgestuft. Die Aussage bleibt, die Begründung wird ergänzt. Der Satz aus §2 mit dem Zitat aus
`modul-05` kann in die Skill-Datei übernommen werden. Ob das geschieht, entscheidet ihr Eigentümer.
