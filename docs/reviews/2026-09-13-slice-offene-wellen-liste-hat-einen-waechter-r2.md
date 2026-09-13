# Review — slice-offene-wellen-liste-hat-einen-waechter (Runde 2)

**Rolle:** Reviewer (`.harness/skills/reviewer.md` v1.7.0) · **Datum:** 2026-09-13 ·
**Lauf:** Runde 2

## Kopf-Metadaten

| Feld | Wert |
|---|---|
| **Gegenstand** | Commit `87557369` — *„… DoD (3), Sensor-Prosa zeigt auf ADR-0046 statt offene Norm-Frage zu behaupten"* (1 Datei, +4/−6) |
| **Mitgeprüft** | der **Schluss der ersten Runde**: Nacharbeit `ca135c49` zu HIGH-1, HIGH-3, MEDIUM-2 |
| **Diff/Range** | `git show 87557369`, `git show ca135c49` |
| **Slice-Plan** | [`docs/plan/planning/in-progress/slice-offene-wellen-liste-hat-einen-waechter.md`](../plan/planning/in-progress/slice-offene-wellen-liste-hat-einen-waechter.md) |
| **`LH-*`** | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| **Aktive ADRs im Bezug** | [ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) (`Accepted` seit `7cfd8283`, hier **nur als zitierte Quelle** geprüft), [ADR-0044](../plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) |
| **`MR-*`** | [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids), [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert), [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist), [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung) |
| **Hard Rules** | [`AGENTS.md`](../../AGENTS.md) §3.1/§3.4/§3.5/§3.6/§3.7/§3.8/§3.10/§3.11 |
| **Vorherige Findings am gleichen Modul** | [Runde 1](2026-09-13-slice-offene-wellen-liste-hat-einen-waechter.md) (HIGH-1…INFO-2) · [ADR-0046-Konsistenzrunde](2026-09-13-adr-0046-konsistenzrunde.md) (deren MEDIUM-2 ist die Nachbarklasse zu LOW-1 unten) |
| **Nicht erhalten / nicht Gegenstand** | DoD-Abhakung und Gate-Läufe (Verifier) · `ADR-0046` selbst (eigene Runde, `Accepted`, [`AGENTS.md`](../../AGENTS.md) §3.4) |

**Mess-Umgebung.** Diese Runde ist **statisch** gefahren: `git`, `grep`, `sed` über dem
Arbeitsbaum. **Kein Docker-Ziel, kein `make`-Lauf** — so beauftragt. Wo eine Aussage einen
Werkzeug-Lauf braucht, stützt sie sich ausdrücklich auf die **in Runde 1 unabhängig
reproduzierten** Messungen und sagt das dazu. Das Repo ist unverändert
(`git status --porcelain` leer, `HEAD` = `87557369`); einzige geschriebene Datei ist dieser
Report.

---

## Findings

### MEDIUM-1 — Die zusammenfassende Grenz-Aussage der HIGH-1-Nacharbeit ist breiter als die Tabelle, die sie zusammenfasst, und widerspricht dem eigenen Absatz 20 Zeilen darüber

- `kategorie`: **MEDIUM**
- `quelle`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [`AGENTS.md`](../../AGENTS.md) §3.6
- `pfad`: [`harness/sensors/docs-check.md:48-50`](../../harness/sensors/docs-check.md), gegen
  `:26-29` und Tabellenzeile `:46`
- `befund`: Der Satz lautet *„Nur die letzten beiden Lagen bleiben `waves` unsichtbar: … und ein
  toter Zeiger **ohne Datei** fällt **ausschließlich** über das Modul `links`
  (`target-missing`)."* Die Tabellenzeile, die er zusammenfasst, ist auf die Vorschau geschnitten
  — *„toter **Vorschau**-Zeiger `welle-88` ohne jede Datei"* (`:46`) —, der Satz lässt das Wort
  `Vorschau` fallen und wird damit zur Aussage über **jeden** toten Zeiger. Derselbe Absatz sagt
  20 Zeilen darüber das Gegenteil: `wave-drift` deckt *„**beide** Richtungen dieser Bijektion: ein
  flaches Wellendokument ohne Zeiger **und ein Zeiger ohne passendes flaches Dokument**"*
  (`:26-27`). Für einen Zeiger unter *Offene Wellen* ohne Datei ist `links` also gerade **nicht**
  der ausschließliche Träger. Dieselbe Verallgemeinerung ist in Runde 1 als INFO-2 schon einmal
  gemeldet worden — dort in DoD-Punkt (3) des Plans (*„Richtung B … fällt über das Modul `links`
  (`target-missing`), **nicht über `waves`**"*); die Nacharbeit hat die Prosa korrigiert und den
  Satz dabei in die Zusammenfassung verschoben, statt ihn fallen zu lassen. Der zweite
  Deckungs-Träger trägt die präzise Form: [`.d-check.yml:45-46`](../../.d-check.yml) schreibt
  *„einen toten **Vorschau**-Zeiger OHNE jede Datei — Letzterer faellt allein ueber `links`"*. Die
  zwei Träger sind an dieser Stelle nicht deckungsgleich, und der ungenauere ist der, auf den der
  genauere für die Details zeigt.
- `verifizierbar`: **ja** — die Messung liegt vor und ist nicht neu zu erheben: Runde 1, N-2
  (Zeiger `welle-88` unter *Offene Wellen* ohne flache Datei → mit `-disable links`
  **1 Befund `wave-drift`**). Ein Bestätigungslauf wäre derselbe Docker-Trockenlauf gegen eine
  Kopie außerhalb des Repos mit dem Digest aus [`d-check.mk`](../../d-check.mk).
- `klasse`: **Zusammenfassung stärker als ihre Quelle**
  ([`BEO-ALL/zusammenfassung-staerker-als-ihre-quelle`](../plan/planning/observations/BEO-ALL/zusammenfassung-staerker-als-ihre-quelle/observation.md),
  **6** Belege zum 2026-09-13 —
  `ls docs/plan/planning/observations/BEO-ALL/zusammenfassung-staerker-als-ihre-quelle/evidence/*.md | wc -l`,
  kein Erwartungswert; die Quelle ist hier die Messtabelle im selben Absatz statt einer
  referenzierten Entscheidung, die Fehlerrichtung ist dieselbe).
- **Failure-Szenario:** Ein Lauf, der entscheidet, ob `links` für einen Pfad enger gestellt werden
  darf (`ignore-refs`, `scan.ignore`), liest diesen Satz und schließt, dass Richtung B der
  Bijektion dann unbewacht ist — oder umgekehrt: dass `waves` sie nie trug. Beides ist falsch, und
  beides ist genau die Aussage, deren Widerlegung dieser Slice als seinen eigenen Messwert
  mitbringt.

### LOW-1 — „`waves` hält **genau das** durch" nimmt eine Festlegung ganz in Anspruch, von der die zitierte ADR ein Drittel ausdrücklich als unbewacht führt

- `kategorie`: **LOW**
- `quelle`: [ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Fitness
  Function · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- `pfad`: [`harness/sensors/docs-check.md:54-55`](../../harness/sensors/docs-check.md)
- `befund`: Der neue Satz schließt mit *„… dass die flache Datei mit der Eröffnung der Welle
  entsteht, nicht davor, und `waves` hält **genau das** mit `wave-drift`/`wave-preview-exists`
  durch."* Festlegung 1 der zitierten ADR hat drei Hälften; `waves` trägt zwei davon. Die ADR sagt
  das über sich selbst: Ihre §Fitness Function stellt die **Kopplung** *Datei ⟺ Zeiger ⟺ nicht in
  der Vorschau* als maschinell geprüft dar und benennt daneben *„Zwei Aussagen dieser Datei sind
  es nicht, und das gehört benannt (`LH-QA-01`): der **Commit-Zuschnitt** im zweiten
  Aufzählungspunkt von Festlegung 1 und Festlegung 2"*, dazu *„Zwei Grenzen des Wächters"*. Die
  dritte Hälfte — *„Ihre Kennung steht dort **unverlinkt**"* (Festlegung 1, erster Punkt) — fällt
  über `waves` gar nicht: Ein verlinkter Vorschau-Name ohne Datei ist Lage 5 der Tabelle und
  meldet dort `0 Befunde`; sichtbar wird er nur, solange das Linkziel **tot** ist und `links`
  greift. Zeigt die Vorschau-Zeile auf ein beliebiges existierendes Ziel, schweigen beide Module.
- `verifizierbar`: **nein** am Gate — es ist ein Abgleich zweier Texte:
  `sed -n '/^### 1\./,/^### 2\./p' docs/plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md`
  gegen `sed -n '48,55p' harness/sensors/docs-check.md`.
- `klasse`: **Zusage nennt zwei Kanten, der Sensor deckt eine**
  ([`BEO-ALL/zusage-nennt-zwei-kanten-der-sensor-deckt-eine`](../plan/planning/observations/BEO-ALL/zusage-nennt-zwei-kanten-der-sensor-deckt-eine/observation.md),
  **1** Beleg zum 2026-09-13 —
  `ls docs/plan/planning/observations/BEO-ALL/zusage-nennt-zwei-kanten-der-sensor-deckt-eine/evidence/*.md | wc -l`,
  kein Erwartungswert; dieser Vorgang wäre der zweite). Dieselbe Klasse hat die
  [ADR-0046-Konsistenzrunde](2026-09-13-adr-0046-konsistenzrunde.md) als ihr MEDIUM-2 **in der ADR
  selbst** gefunden; dort ist sie mit `7cfd8283` behoben und hier eine Datei weiter neu
  entstanden.
- **Warum LOW und nicht MEDIUM:** Die zwei Wächter-Grenzen stehen im selben Absatz **eine
  Satzgrenze früher** (`:48-50`), und der Vorbehalt zum Commit-Zuschnitt steht einen Klick
  entfernt in der verlinkten ADR. Wer den Absatz liest, hat die Information; falsch ist der Satz
  nur, wenn man ihn isoliert. Die Kontext-Eskalation *„im Gate-Pfad steigt eine Stufe" *greift
  hier bewusst nicht — sie ist für **wiederholte** Beobachtungen gedacht, und dieses Dokument ist
  vollständig Gate-Pfad; angewandt bliebe die Kategorie LOW hier dauerhaft leer.
- **Failure-Szenario:** Ein Planner-Lauf eröffnet eine Welle, hängt die Vorschau-Zeile aber als
  Link auf ein bestehendes Ziel (die Ergebnisnotiz, die Roadmap selbst) statt sie unverlinkt
  stehenzulassen — Festlegung 1, erster Punkt, verletzt. Weder `waves` noch `links` meldet. Er
  hatte gelesen, `waves` halte *genau das* durch.

### INFO-1 — Die vierte Folgepflicht von ADR-0046 ist erledigt, und nirgends steht, dass sie es ist

- `kategorie`: **INFO**
- `quelle`: [ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Konsequenzen,
  vierte Folgepflicht
- `pfad`: Commit-Message `87557369` · Slice-Plan §2 Liefer-Punkt (3)
- `befund`: Die ADR führt den Nachzug dieses Absatzes als *„Folgepflicht, fällig als **eigener
  Vorgang** — ohne Rollen-Adresse, weil keine Quelle eine benennt"*. Vollzogen hat ihn der
  laufende Slice, gebucht als *„DoD (3)"*. Beides ist vertretbar: *eigener Vorgang* grenzt
  erkennbar gegen den **ADR-Lauf** ab, nicht gegen jeden anderen, und dieselbe Datei steht im
  Plan-Abschnitt §3 als Änderungs-Ziel dieses Slice. Nicht vertretbar ist, dass die Zuordnung
  **nirgends dasteht**: Weder Commit-Message noch Slice-Plan sagen, dass diese Folgepflicht damit
  abgetragen ist, und die ADR ist ab `Accepted` unveränderlich — sie wird die Pflicht auf Dauer
  als fällig führen. Die drei übrigen Folgepflichten (`welle-13` §1, `roadmap.md` §Nächste Wellen,
  [`.claude/commands/plan-welle.md`](../../.claude/commands/plan-welle.md)) sind offen; der Satz
  *„Ein verlinkter Name hat eine flache Plan-Datei (geschnitten, Start-Trigger nicht
  eingetreten)"* steht in der Roadmap unverändert
  (`grep -c 'Ein verlinkter Name hat eine flache Plan-Datei' docs/plan/planning/in-progress/roadmap.md`
  → **1**, kein Erwartungswert).
- `verifizierbar`: **nein** — kein Modul der [`.d-check.yml`](../../.d-check.yml) liest, ob eine
  Folgepflicht abgetragen wurde; die ADR stellt dieselbe Lage für ihren eigenen Commit-Zuschnitt
  fest.
- `klasse`: **Folgepflicht ohne notierten Ausgang.** Eine bestehende Kennung erkenne ich nicht als
  passend; ob sie unter
  [`BEO-ALL/benannte-luecke-ohne-ausgang`](../plan/planning/observations/BEO-ALL/benannte-luecke-ohne-ausgang/observation.md)
  fällt oder eine eigene braucht, ist ein Urteil über eine Klasse und gehört in die Closure — hier
  steht die Beobachtung, nicht ihre Einordnung.
- **Failure-Szenario:** Der Planner schneidet aus §Konsequenzen die vier Folgepflichten in
  Vorgänge und findet für die vierte einen Absatz vor, der schon so aussieht, wie er ihn schreiben
  wollte — er schreibt ihn ein zweites Mal oder streicht den Vorgang ohne Beleg.

### INFO-2 — Runde-1-MEDIUM-1 ist als Übergabe getragen, in der Sache aber offen und inzwischen doppelt falsch

- `kategorie`: **INFO** (Fortschreibung, kein neuer Befund an diesem Diff)
- `quelle`: [`MR-054`](../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
- `pfad`: [`docs/plan/planning/open/slice-210-planning-modul-im-emittierten-doc-gate.md:100-101`](../plan/planning/open/slice-210-planning-modul-im-emittierten-doc-gate.md)
- `befund`: Der Ausschluss-Punkt dort lautet unverändert *„`waves` ist auch im Dogfood aus (**die
  dokumentierte Abweichung dieses Repos**)"*. Die erste Hälfte ist seit `ba8698fc` falsch, die
  zweite seit `7cfd8283`: [ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md)
  Festlegung 2 stellt fest, dass es diese Abweichung nicht gibt und nie gebucht war. Die
  **Übergabe-Pflicht** aus Runde 1 ist erfüllt — `ca135c49` nennt MEDIUM-1 namentlich und zeigt
  auf den Report; die Datei gehört dem Planner und wird zu Recht nicht vom Implementer angefasst.
  Der Eintrag steht hier, damit die Sache nicht mit der Übergabe als erledigt gilt.
- `verifizierbar`: **nein** am Gate —
  `git grep -n 'waves' -- docs/plan/planning/open/slice-210-*.md` gegen `grep -n 'waves:' .d-check.yml`.
- `klasse`: **Überholter offener Plan ohne genormten Ausgang**
  ([`BEO-ALL/ueberholter-offener-plan-ohne-genormten-ausgang`](../plan/planning/observations/BEO-ALL/ueberholter-offener-plan-ohne-genormten-ausgang/observation.md)).

---

## Negativbefunde (geprüft, ohne Befund)

### Zum Schluss der ersten Runde

- **N-1 — HIGH-1 ist in seinem Kern geschlossen.** Beide Deckungs-Träger nennen jetzt den vierten
  Grund-Code und die Spalten-Grenze: `grep -c 'wave-preview-exists' .d-check.yml` → **1**,
  `grep -c 'wave-preview-exists' harness/sensors/docs-check.md` → **5** (keine Erwartungswerte).
  Die als widerlegt gemeldete Behauptung *„der einzige gefahrene Reproduktionsversuch deckte den
  korrekt an beiden Stellen verlinkten Zustand ab und blieb grün"* ist ersatzlos entfernt
  (`git grep -c 'einzige gefahrene Reproduktionsversuch' -- ':!docs/reviews'` → keine Treffer,
  Exit 1). Die fünf Lagen stehen als Tabelle mit ihrer Mess-Umgebung. **Rest:** MEDIUM-1 oben —
  der zusammenfassende Satz darunter.
- **N-2 — HIGH-3 ist geschlossen, gelesen statt gefahren.** Der `# expect:`-Kopf von
  [`test/mutations/273`](../../test/mutations/273-planning-block-rumpf-entfernt.sh) nennt jetzt
  *„planning: heading zeigt auf den Abschnitt 'Offene Wellen', nicht auf den Modul-Default"*, und
  diese Zusicherung existiert wortgleich
  ([`test/planning-modul-wiring.bats:45`](../../test/planning-modul-wiring.bats)). Ihr Prädikat
  ist `[ "$(field heading)" = "## Offene Wellen" ]`; die Mutation löscht genau die Zeile
  `heading: "## Offene Wellen"` — die Zusicherung kann danach nur fallen. Damit trägt
  `run_case` Bedingung (4) (`grep -E -- "$form" | grep -qF -- "$expect"`,
  [`harness/tools/mutate.sh:698`](../../harness/tools/mutate.sh)) wieder. **Was ich nicht getan
  habe:** `make mutate` fahren — Docker ist für diese Runde ausgeschlossen; der Volllauf
  (*309 ok, 0 Befund(e)*) steht als Implementer-Beleg in `ca135c49` und ist Verifier-Sache.
- **N-3 — LOW-2 ist im selben Zug geschlossen und rechnet auf.** Der Rumpf-Kommentar von 273
  nennt jetzt drei Wiring-Dateien und **15** Zusicherungen; die Aufteilung *sieben fallen / acht
  bleiben grün* geht auf: `grep -c '@test' test/planning-modul-wiring.bats` → **5**,
  `test/closure-modul-wiring.bats` → **6**, `test/waves-modul-wiring.bats` → **4** (Summe 15,
  keine Erwartungswerte). Die namentlich genannten Sieben sind genau die, deren Prädikat die
  Mutation trifft; die genannten Acht lesen entweder `modules:` (nicht den Rumpf), sind über dem
  leeren `closure:`-Rumpf vakuos wahr, oder liegen im unberührten `waves:`-Block.
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  greift auf diese Zahlen nicht — sein Geltungsbereich sind die lebenden **Markdown**-Artefakte,
  eine `*.sh`-Datei ist keines.
- **N-4 — MEDIUM-2 ist geschlossen, und die zwei neuen Fälle treffen genau die zuvor unerreichten
  Prädikate.** [`322`](../../test/mutations/322-waves-block-vollstaendig-entfernt.sh) löscht
  `waves:`, `dir:` und `mode:` — `waves_block` liefert danach den leeren String, und die einzige
  Zusicherung mit Nichtleer-Prädikat (*„planning: waves ist ueber dir aktiviert"*) fällt; sie
  fiel unter 319/320/321 nachweislich nicht, weil dort immer eine Zeile des Blocks stehen blieb.
  [`323`](../../test/mutations/323-waves-dir-zeigt-auf-nichtexistierenden-pfad.sh) setzt `dir` auf
  `docs/plan/planning/nichtvorhanden-323` — nicht leer, also läuft die Leer-Vorprüfung durch und
  `[ -d "$REPO/$d" ]` wird erstmals erreicht und falsch. Beide `# expect:`-Zeichenketten sind
  wortgleiche Testnamen. Der Kopf von 323 benennt die Nebenwirkung auf die Literal-Zusicherung
  ausdrücklich, statt sie zu verschweigen.
- **N-5 — HIGH-2 ist durch die Architect-Runde abgetragen, nicht durch den Implementer.** Die als
  offen übergebene Norm-Frage ist mit `2f8ad619`/`7cfd8283` als
  [ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) entschieden. Der
  Implementer hat die Frage in `ca135c49` ausdrücklich **nicht** entschieden und in `87557369` nur
  noch auf die Entscheidung gezeigt — die Rollen-Grenze aus [`AGENTS.md`](../../AGENTS.md) §3.8
  ist über beide Commits eingehalten.
- **N-6 — Die Nacharbeit hat keine Aussage über den offenen Zustand hinterlassen.** Kein lebendes
  Artefakt behauptet mehr, die `waves`-Frage sei offen:
  `git grep -ln 'offene Norm-Frage' -- ':!docs/reviews' ':!docs/plan/planning/done' ':!docs/plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md'`
  liefert **zwei** Dateien (`docs/plan/adr/0041-…`, `test/mutations/310-…`, kein Erwartungswert);
  beide sprechen von der offenen Norm-Frage zum Verweis-Nachzug in eingefrorene Artefakte, nicht
  von dieser. Zu `waves` ist keine offen.

### Zum neuen Diff `87557369`

- **N-7 — Das Zitat trägt, und zwar wörtlich.** *„ADR-0046 legt fest, dass die flache Datei mit
  der Eröffnung der Welle entsteht, nicht davor"* ist die Überschrift von Festlegung 1
  (*„Die flache Welle-Datei entsteht mit der Eröffnung der Welle und nicht davor — der frühe
  Schnitt endet"*). Nichts ist hinzugedichtet, nichts abgeschwächt.
- **N-8 — REFUTED: „verbotene Abweichung" geht *nicht* über die Quelle hinaus.** Der Verdacht war
  naheliegend, denn Festlegung 2 und der Titel der ADR sagen, dass *„eine Abweichung damit nicht
  mehr besteht"*. Er trägt trotzdem nicht: Dieselbe ADR schreibt über **genau diesen Zustand**
  (Zeile 1 ihrer eigenen Lagen-Tabelle, identisch mit Lage 1 der Sensor-Tabelle):
  *„Die erste Zeile **ist** die Abweichung. Sie ist mit der Aktivierung gate-rot — nicht getragen,
  sondern **verboten**."* (§Kontext, *Was die Aktivierung tat*), und §Was diese Entscheidung nicht
  tut wiederholt *„**Verboten** ist der Entwurf als flache Datei unter `docs/plan/planning/` neben
  einer Vorschau-Zeile"*. Die Sensor-Prosa benutzt beide Wörter in derselben Bedeutung wie ihre
  Quelle. Die beiden Aussagen widersprechen sich auch nicht: Die *Praxis* dieses Repos weicht
  nicht mehr ab (darum kein Eintrag im Adaptions-Block), der *Zustand* bleibt verboten.
- **N-9 — Der Verweis löst auf.** `harness/sensors/docs-check.md` → `../../docs/plan/adr/0046-…`
  landet auf der Repo-Wurzel und trifft die Datei (`test -f`, Exit 0). Kein Anker im Link, also
  nichts, was das Modul `anchors` brechen könnte.
- **N-10 — Die Adressform ist die richtige, und [`AGENTS.md`](../../AGENTS.md) §3.11 verlangt hier
  keine Kennung.** Der schreibende Träger ist ein **lebendes** Artefakt, kein einfrierendes; für
  ihn bleibt der Pfad der richtige Zeiger. Der Prozess bewegt `docs/plan/adr/**` ohnehin nicht.
- **N-11 — Keine verbotene Referenz-Richtung.** Die `matrix`-Klassen der
  [`.d-check.yml`](../../.d-check.yml) führen `spec-straten`, `adr`, `slice`; die einzigen
  `allow: false`-Regeln laufen von `spec-straten` nach `adr`/`slice`. `harness/sensors/**` ist
  keiner Klasse zugeordnet, der neue Verweis ist damit uneingeschränkt zulässig. Und
  `status: {forbidden: [superseded, deprecated]}` greift nicht: ADR-0046 steht auf `Accepted`
  (`grep -m1 '^\*\*Status:\*\*' docs/plan/adr/0046-*.md`).
- **N-12 — [`AGENTS.md`](../../AGENTS.md) §3.7 hält, in Substanz und in Geltungsbereich.**
  Substanz: Der neue Text steht durchgehend im **Indikativ Präsens** über den Zustand
  (*„Das ist …", „legt fest", „hält … durch"*); kein Konjunktiv über die abgelöste Lesart, keine
  Befund-Kennung, keine Slice-Nummer, kein *„hier stand bis …"*. Der alte Satz ist **ersetzt**,
  nicht danebengestellt — der Diff ist −6/+4 in einem Hunk. Geltungsbereich: §3.7 bindet *„Code,
  Konfiguration, Skripte und die Zustandsfelder der lebenden Register"*; eine Sensor-Prosa-Datei
  ist keines davon, und der Pathspec, mit dem §3.7 seinen eigenen Bestand misst, führt kein
  `*.md`. Die Prüfung ist also strenger gelaufen, als die Regel verlangt, und bleibt grün.
- **N-13 — [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  ist nicht berührt.** Der neue Text enthält **keine** Zahl
  (`git show 87557369 -- harness/sensors/docs-check.md | grep '^+' | grep -cE '[0-9]'` → **1**,
  und dieser Treffer ist die Kennung `ADR-0046`, kein Messwert). Die Zahlen im unveränderten
  Umfeld (*„Fünf Lagen"*, *„zwei Befunde"*, *„vierter Grund-Code"*) zählen Zeilen der unmittelbar
  danebenstehenden Tabelle — die Tabelle ist ihr Beleg.
- **N-14 — [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  ist nicht berührt.** Der neue Text macht keine Aussage über die Baseline. Beide
  Baseline-Nennungen der Datei stehen unverändert mit Tag da
  (`grep -c '\.harness/baseline/v6\.7\.2/' harness/sensors/docs-check.md` → **2**, kein
  Erwartungswert).
- **N-15 — Die Grund-Codes existieren so, und die Modul-Zuordnung stimmt.**
  `wave-drift`, `wave-preview-exists`, `wave-unregistered`, `wave-results-missing` sind in Runde 1
  **und** unabhängig davon in [`slice-125`](../plan/planning/done/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md)
  als reale Ausgaben desselben gepinnten Digests belegt; `target-missing` als Code des Moduls
  `links` ebenso (Runde 1, N-2: mit `links` zwei Befunde, ohne `links` einer). Kein Code ist
  erfunden — [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  hält.
- **N-16 — Die Lagen-Tabelle ist nach dem Eingriff vollständig konsistent.** Fünf Zeilen, drei mit
  Befund, zwei ohne; der Satz *„Nur die letzten beiden Lagen bleiben `waves` unsichtbar"* trifft
  genau die zwei `0 Befunde`-Zeilen, und die neue Charakterisierung adressiert korrekt *„Lage 1 …
  zwei Befunde"*. Die Lagen 2 und 3 (Datei + Zeiger + Vorschau-Nennung) bleiben unkommentiert und
  widersprechen Festlegung 1 nicht — dort verlangt der zweite Aufzählungspunkt, dass die
  Vorschau-Zeile **mit** der Eröffnung entfällt, und genau das meldet `wave-preview-exists`. Der
  einzige Bruch in diesem Absatz ist MEDIUM-1.
- **N-17 — Commit-Zuschnitt: sauber, in beide Richtungen.** `git show --stat 87557369` führt
  **eine** Datei, `harness/sensors/docs-check.md`. Kein DoD-Häkchen, kein Closure-Feld, keine
  Risiko-Zeile, keine Register-Datei, kein Welle-Plan und keine Roadmap-Zelle ist angefasst —
  [`AGENTS.md`](../../AGENTS.md) §3.10 ist eingehalten, der Slice-Plan trägt seine `- [ ]`
  unverändert (`grep -c '^- \[ \]' …/slice-offene-wellen-liste-hat-einen-waechter.md` unverändert
  gegenüber `87557369^`). Auch §3.8 ist nicht berührt: weder `AGENTS.md` noch
  `harness/conventions*` liegen im Diff. Und die ADR selbst sagt, dass für `harness/sensors/**`
  **keine** Quelle eine schreibende Rolle benennt — der Implementer verletzt hier also keine
  Eigentums-Zuordnung, weil es keine gibt.
- **N-18 — Die Commit-Message trägt eine Traceability-Kennung.** Sie nennt `ADR-0046` als eigene
  Zeile; `make commit-msg-check` prüft über das d-check-Modul `commits` auf die Kennung, nicht auf
  eine Markup-Form.
- **N-19 — [`AGENTS.md`](../../AGENTS.md) §3.5 ist nicht berührt.** Der Diff ändert keine
  Gate-Konfiguration: `git show 87557369 -- .d-check.yml` ist leer. Weder Modul-Liste noch
  `scan.ignore` noch ein `ignore-refs`-Paar bewegt sich; es gibt keine Senkung, für die eine ADR
  fehlen könnte.
- **N-20 — [`AGENTS.md`](../../AGENTS.md) §3.4 ist nicht berührt.** Keine `Accepted`-ADR liegt im
  Diff; ADR-0046 wird ausschließlich gelesen und zitiert.
- **N-21 — [`AGENTS.md`](../../AGENTS.md) §3.6 hält für den neuen Satz.** Die Zusage, die er
  macht, ist eine **Werkzeug**-Aussage, und ihr Gegenbeispiel steht als Tabelle unmittelbar
  darüber: Jede der fünf Lagen ist real gefahren, Lage 1 ist zweimal unabhängig rot gesehen
  (Implementer in `ca135c49`, Reviewer in Runde 1). Der Satz stützt sich auf diese Messung und
  führt keine neue Behauptung ein, für die ein Gegenbeispiel fehlte — mit der einen, in LOW-1
  benannten Ausnahme des Wortes *genau*.

### Ausdrücklich **nicht** geprüft

- **Jeder Docker- und `make`-Lauf** (`gates`, `docs-check`, `test`, `mutate`) — für diese Runde
  ausgeschlossen; sie sind ohnehin Verifier-Gegenstand. Wo eine Aussage oben eine Messung braucht,
  nennt sie die Runde-1-Sonde, die sie liefert.
- **`ADR-0046` selbst** — eigene Runde, `Accepted`, immutabel. Geprüft ist ausschließlich, ob der
  neue Text sie richtig zitiert (N-7, N-8) und ob er ihr an einer Stelle mehr zuschreibt, als sie
  sagt (LOW-1).
- **Die DoD-Abhakung** und ob Liefer-Punkt (3) damit erfüllt ist — Verifier. Der von Runde 1 als
  widerlegt gemeldete Wortlaut des DoD-Punktes (INFO-2 dort) ist unverändert ein
  **Planner**-Nachzug; MEDIUM-1 oben zeigt, dass derselbe Satz inzwischen auch in der Prosa steht.
- **Die drei offenen Folgepflichten von ADR-0046** (`welle-13` §1, `roadmap.md` §Nächste Wellen,
  `.claude/commands/plan-welle.md`) — Planner-Artefakte, von diesem Diff nicht berührt; ihr
  Zustand ist in INFO-1 nur als Kontext festgehalten, nicht bewertet.
- **Die übrigen Abschnitte von `harness/sensors/docs-check.md`** (`closure`, `targets`) und der
  gesamte Mutations-Fall-Satz außer 273/319–323.

---

## Kategorie-Summary

| Kategorie | Anzahl | Kennungen |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 1 | MEDIUM-1 |
| LOW | 1 | LOW-1 |
| INFO | 2 | INFO-1, INFO-2 |

**Wiederkehrende Klassen für die Closure §7** (je eine Evidence-Datei pro Klasse für **diesen**
Vorgang, angelegt vom Planner bei der Closure):

- [`BEO-ALL/zusammenfassung-staerker-als-ihre-quelle`](../plan/planning/observations/BEO-ALL/zusammenfassung-staerker-als-ihre-quelle/observation.md) (MEDIUM-1)
- [`BEO-ALL/zusage-nennt-zwei-kanten-der-sensor-deckt-eine`](../plan/planning/observations/BEO-ALL/zusage-nennt-zwei-kanten-der-sensor-deckt-eine/observation.md) (LOW-1)
- [`BEO-ALL/ueberholter-offener-plan-ohne-genormten-ausgang`](../plan/planning/observations/BEO-ALL/ueberholter-offener-plan-ohne-genormten-ausgang/observation.md) (INFO-2)

INFO-1 hat keine passende vorhandene Kennung; ob es eine neue bekommt oder unter eine vorhandene
fällt, entscheidet die Closure — hier steht die Beobachtung, nicht ihre Einordnung.

---

## Verdikt

**BLOCKIERT — knapp, und an einer Satzgrenze.**

Die drei nachgearbeiteten Findings aus Runde 1 sind **wirklich** geschlossen, nicht nur in einer
Commit-Message genannt: HIGH-1 hat den vierten Grund-Code und die fünf gemessenen Lagen in beiden
Trägern (N-1), HIGH-3 zitiert wieder eine existierende Zusicherung, deren Prädikat die Mutation
trifft (N-2), MEDIUM-2 hat für die zwei zuvor unerreichten Prädikate je einen Fall, der sie
erstmals erreicht (N-4). Der neue Diff selbst tut genau das, was
[ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Konsequenzen für diesen
Absatz verlangt — Zeiger statt Norm-Frage, Rest unberührt —, zitiert die Entscheidung korrekt,
hält §3.7 auch dort, wo die Regel ihn gar nicht binden würde, und hat einen sauberen
Commit-Zuschnitt.

Was blockiert, ist **ein Satz, und er stammt aus der vorigen Nacharbeit**: Die Zusammenfassung der
Grenz-Aussage (`:48-50`) lässt das Wort *Vorschau* fallen und behauptet damit für **jeden** toten
Zeiger, was nur für den Vorschau-Zeiger gilt — gegen die Tabelle, die sie zusammenfasst, und gegen
den eigenen Absatz 20 Zeilen darüber. Genau diese Verallgemeinerung hat Runde 1 als INFO-2 schon
im DoD-Punkt gemeldet; sie ist aus dem Plan in die Prosa gewandert statt zu verschwinden. Solange
sie steht, sagt die Sensor-Prosa an ihrer sichtbarsten Stelle das Gegenteil ihrer eigenen Messung.

**Nicht blockierend, aber vor der Closure zu entscheiden:** LOW-1 (das Wort *genau*) und INFO-1
(die vierte Folgepflicht ist abgetragen und nirgends als abgetragen vermerkt).

**Kein Konflikt-Pfad (Modul 8).** Kein Finding dieser Runde widerspricht einer Rollen-Entscheidung
— MEDIUM-1 ist eine widerlegte Tatsachenbehauptung, LOW-1 eine Wortwahl, INFO-1 eine fehlende
Notiz. Der reguläre Weg Reviewer → Implementer genügt; INFO-2 bleibt beim Planner, wo Runde 1 sie
abgelegt hat.
