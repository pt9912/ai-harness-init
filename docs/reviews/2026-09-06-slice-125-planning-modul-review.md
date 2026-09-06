# Review-Report: slice-125 — 2026-09-06

**Review-Art:** Code — geprüft wird der Diff gegen **Slice-Plan + ADRs + Hard Rules**
(Modul 10 §Drei Review-Arten). **Nicht** geprüft: die DoD-Abhakung und die Closure-Notiz §7
— das ist Verifier- bzw. Planner-Arbeit in getrenntem Kontext
([`AGENTS.md`](../../AGENTS.md) §3.10, Modul 11). Ebenfalls nicht Gegenstand: ADR-0037 und
die Slice-Pläne 191/193 (fremde, teils laufende Arbeit).

**Gegenstand:** `slice-125` · Commit-Range `c63ef63^..abf05be` (drei Commits: `c63ef63`,
`b3e49d5`, `abf05be`) auf `main` · 6 Dateien, +119/−13

**Skill:** `.harness/skills/reviewer.md` @ 1.7.0 (`278248f`) · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-09-06

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne diese Liste ist der Lauf
nicht reproduzierbar):

- Slice-Plan
  [`slice-125`](../plan/planning/done/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md)
  (§1 Anlass und die zwei Vorfragen · §2 DoD (1)–(3) · §3 Plan-Tabelle inkl. der
  Übergabe-Zeile · §4 Rückführungen · §6 Risiken)
- Aktive ADRs:
  [`ADR-0024`](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)
  (derivatives Register folgt der Rolle seines Originals — trägt die Eigentumsfrage am
  Ruhe-Marker),
  [`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  (Verzeichnis-Form des Beobachtungs-Registers),
  [`ADR-0015`](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) (Norm-Artefakt-Eigentum),
  [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) (Docker-only)
- Berührte `LH-*`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- `MR`-Einträge: [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  (Gate-Anheben → Steering-Loop, kein ADR),
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  (Zahl neben ihrem Kommando),
  [`MR-020`](../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
  und [`MR-037`](../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
  (Lage von [`MR-016`](../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird),
  auf das der Plan seine Übergabe stützt),
  [`MR-052`](../../harness/conventions.md#mr-052--d-check-pin-v0741-zwei-module-verfügbar-vierte-ausgabe-spalte)
  (der gepinnte d-check-Stand und die vierte `planning`-Fähigkeit)
- [`AGENTS.md`](../../AGENTS.md) Hard Rules — namentlich §3.3, §3.5, §3.6, §3.7, §3.8, §3.9, §3.10
- **Vorherige Findings am gleichen Modul:** das Beobachtungs-Register
  [`BEO-ALL/`](../plan/planning/observations/README.md) — die Klassen
  [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../plan/planning/observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  und
  [`uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../plan/planning/observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/observation.md)
  sind hier je erneut getroffen; die Zähler stehen neben ihrem Kommando in §Summary.

## Prüfmittel und Sonden

Die Aussagen über das Verhalten des gepinnten `planning`-Moduls sind gemessen, nicht
angenommen — auf zwei Wegen.

**Quellstand des Werkzeugs:** Klon `/Development/d-check`, `git describe --tags` →
`v0.74.1-1-g6b09612` (ein Commit über dem in `d-check.mk` gepinnten Tag `v0.74.1`, und der
ändert nur Doku). Gelesen: `internal/hexagon/core/rules/planning.go`,
`internal/hexagon/core/rules/planning_waves.go`, `internal/hexagon/core/model/config.go`.

**Fünf Sonden**, je gegen eine Kopie außerhalb des Arbeitsbaums (`git archive HEAD | tar -x -C
<kopie>`), netzlos, Mount `:ro`, dasselbe Bild per Digest wie `make docs-check`. Der
Arbeitsbaum ist dabei unberührt geblieben.

| Sonde | Änderung an der Kopie | Ergebnis |
|---|---|---|
| A | keine (Kontrolle) | `864 Datei(en) geprüft, 0 Befund(e)`, Exit **0** |
| B | `marker:`-Zeile gelöscht (Modul-Default `Keine aktive Welle` greift) | `0 Befund(e)`, Exit **0** — **still grün** |
| C | `heading` auf `## Meilensteine` (existiert, trägt nie den Marker) | `0 Befund(e)`, Exit **0** — **still grün** |
| D | `heading` auf `## Aktuelle Welle` (Mutation `270`; Überschrift fehlt) | **1 Befund** `planning-drift` „*kanonische Überschrift … fehlt … (fail-closed)*", Exit **1** |
| E | Config unverändert, `Nichts in Arbeit.` in den Block gestellt | **1 Befund** `planning-drift` „*Slice(s) in … aber die Roadmap-Sektion … trägt den Ruhe-Marker*", Exit **1** |

Die Dateizahl ist kein Erwartungswert; tragend sind Befundzahl und Exit-Code. A und E zusammen
zeigen, dass die gewählte Sektion die Invariante wirklich trägt; B und C zeigen die zwei
Konfigurationsänderungen, die sie ohne ein Rot entwerten.

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der verbindlichen Single
Source of Truth. Die Felder unten sind nur **gespiegelt** (Bequemlichkeit beim Ausfüllen),
nicht neu definiert; bei Abweichung gilt der Skill bzw. dessen Quelle
Baseline-Regelwerk `modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill.

### F-1 — Die Mutations-Deckung trifft den lauten Pfad; über den zwei stillen steht eine Zusicherung ohne Zahn

- `kategorie`: HIGH
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 · Slice-Plan §6 (*„eine Sektion, die den Marker
  nie trägt, macht die Invariante trivial wahr … der Gate wäre dann grün, dauerhaft, und ohne
  Aussage"*)
- `pfad`: `test/planning-modul-wiring.bats:43-49` ·
  `test/mutations/270-planning-heading-auf-modul-default-zurueckgesetzt.sh:10`
- `befund`: Zwei Einzeländerungen an `.d-check.yml` entwerten die neue Invariante, **ohne** dass
  `make docs-check` rot wird — Sonde B (`marker:` gelöscht, der Modul-Default
  `"Keine aktive Welle"` greift und steht nicht im Block) und Sonde C (`heading` auf eine
  Sektion, die existiert, aber nie einen Marker trägt). Für beide ist die jeweilige
  bats-Zusicherung der **einzige** Sensor, und keine der beiden trägt einen
  `test/mutations/`-Fall — nach der eigenen Definition des Repos also *unbewacht*
  ([`harness/README.md`](../../harness/README.md): „*wer keinen Fall in `test/mutations/` hat,
  ist unbewacht*"). Der gelieferte Fall `270` mutiert `heading` stattdessen auf
  `"## Aktuelle Welle"`, eine Überschrift, die das Dokument nicht führt: dort fällt
  `docs-check` selbst fail-closed (Sonde D), der Zahn hält also eine bereits laute Stelle. Von
  den sechs Zusicherungen tragen zwei einen Fall, und der eine, der einen stillen Pfad wirklich
  deckt, ist `269` (Modul aus `modules:` entfernt).
- `verifizierbar`: ja — §Prüfmittel und Sonden, Zeilen B, C und D; gefahren gegen Kopien
  außerhalb des Arbeitsbaums mit demselben Digest wie `make docs-check`. Dass kein Fall die
  betroffenen Zusicherungen nennt:
  `grep -l "marker traegt den Ruhe-Marker\|heading existiert wortgleich" test/mutations/*.sh`
  → leer. Der Kontrast: `make mutate` über dem gelieferten Stand meldet **256 ok,
  0 Befund(e)** und deckt dabei zwei der sechs Zusicherungen.
- `klasse`: Mutations-Zahn deckt den lauten statt den stillen Pfad

### F-2 — Der Deckungs-Absatz nennt drei der Modul-Fähigkeiten und lässt die vierte aus

- `kategorie`: MEDIUM
- `quelle`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  · Slice-Plan §2 DoD (3) (*„der Grund steht in `harness/README.md` neben dem, was der Gate
  **nicht** prüft"*)
- `pfad`: `harness/README.md:59-73`
- `befund`: Der neue Absatz führt seine Überschrift als Vollständigkeits-Aussage („*Was das
  Modul `planning` in `docs-check` deckt, und was nicht*") und geht die Fähigkeiten des Moduls
  ordinal durch — Marker-Hälfte aktiv, `waves` aus mit Begründung, „*die zweite Fähigkeit
  desselben Moduls (`closure` …) ist **ebenfalls** nicht aktiviert*". Die Fähigkeit
  `planning.observations` kommt nicht vor, obwohl der gepinnte Stand sie führt
  (`internal/hexagon/core/model/config.go`: „*ObservationsConfig ist die VIERTE
  planning-Fähigkeit … und ihre additive FÜNFTE*") und obwohl **zwei** lebende Artefakte
  dieses Repos sie namentlich als *verfügbar, nicht aktiviert* führen: die Drift-Log-Zeile vom
  2026-09-06 in [`roadmap.md`](../plan/planning/in-progress/roadmap.md) und der
  Register-Eintrag
  [`BEO-ALL/register-paarung-ohne-gate-modul`](../plan/planning/observations/BEO-ALL/register-paarung-ohne-gate-modul/observation.md),
  dessen Stand allein an dieser Fähigkeit hängt. Wer den Absatz liest, entnimmt ihm, dass die
  nicht aktivierten Fähigkeiten genau `waves` und `closure` sind und dass letztere einen
  Träger hat.
- `verifizierbar`: nein — kein Modul aus `modules:` der `.d-check.yml` urteilt über die
  Vollständigkeit von Prosa, und `make comment-claims` nimmt jede Markdown-Datei dauerhaft aus
  ([`harness/README.md`](../../harness/README.md) §Sensors, Punkt 2). Nachprüfbar am
  Quellstand des gepinnten Werkzeugs und an den zwei genannten Repo-Artefakten.
- `klasse`: Deckungs-Absatz nennt nicht alle Fähigkeiten des aktivierten Moduls

### F-3 — Die Modul-Aufzählung im CI-Kopf ist durch diesen Diff falsch geworden; nachgezogen wurde nur die Zwillings-Stelle

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.7 (ein Kommentar in Konfiguration beschreibt,
  was da ist)
- `pfad`: `.github/workflows/ci.yml:23-25`
- `befund`: Der CHECKOUT-TIEFE-Block nennt weiterhin „*`.d-check.yml` aktiviert fuer
  `docs-check` nur `links, anchors, ids, matrix, codepaths, spans`*", während
  `grep -m1 '^modules:' .d-check.yml` seit `c63ef63` sieben Module führt. Der Diff hat die
  Aussage falsch gemacht, nicht vorgefunden — der Bestands-Cutoff von §3.7 („*wer sie stehen
  lässt, bricht nichts*") deckt sie also nicht. Der Implementations-Lauf hat die Klasse erkannt
  und die **parallele** Aufzählung in `harness/README.md:89` im selben Commit nachgezogen
  (`b3e49d5`, Message: „*Zieht dabei die Modul-Aufzaehlung im history-range-guard-Absatz
  nach*"); genau der dort nachgezogene Satz verweist für die Begründung auf
  `.github/workflows/ci.yml` als den autoritativen Ort, und der trägt den alten Stand. Der
  Schluss des CI-Kommentars („*keines davon liest `git`-Historie*") bleibt wahr — `planning`
  ist hermetisch —, seine Prämisse nicht.
- `verifizierbar`: ja, textuell —
  `grep -n 'links, anchors, ids, matrix, codepaths, spans' .github/workflows/ci.yml` gegen
  `grep -m1 '^modules:' .d-check.yml`. Kein Gate fängt es: `make ci-lint` (actionlint) prüft
  Workflow-Syntax und keine Kommentar-Aussage, `.github/` liegt dauerhaft außerhalb des
  `make comment-claims`-Prüfbereichs, und `make docs-check` ist über dem gelieferten Stand
  grün (`865 Datei(en) geprüft, 0 Befund(e)`).
- `klasse`: Zusage neben geänderter Ableitung bleibt stehen

### F-4 — Der Beleg-Satz eines offenen Register-Eintrags ist durch diesen Diff widerlegt

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.7 (*Dieselbe Regel für Zustandsfelder* — Zustand
  und Beleg als auflösbarer Anker) · Baseline-Regelwerk `modul-06-roadmap.md`
  §Das Beobachtungs-Register
- `pfad`: `docs/plan/planning/observations/BEO-ALL/register-paarung-ohne-gate-modul/state.md:6-7`
- `befund`: Der Stand *offen* wird dort mit dem Satz belegt „*Es ist **verfügbar, nicht
  aktiviert**: `grep -m1 '^modules:' .d-check.yml` führt es nicht*". Nach `c63ef63` gibt genau
  dieses Kommando eine Zeile aus, die `planning` enthält — der Beleg widerlegt jetzt den Satz,
  den er stützen soll, obwohl die beschriebene Lücke fortbesteht (die Fähigkeit
  `planning.observations` ist unkonfiguriert). Ein Sichtungs-Schritt nach Modul 5, der das
  genannte Kommando ausführt, liest daraus, die Beobachtung sei erledigt. Die Datei ist
  **nicht** Gegenstand dieses Diffs und gehört nach [`AGENTS.md`](../../AGENTS.md) §3.10 dem
  Planner — der Befund ist die fehlende Übergabe, nicht die unterlassene Änderung (siehe F-5).
- `verifizierbar`: ja — `grep -m1 '^modules:' .d-check.yml` gegen den zitierten Satz. Kein
  Modul liest die Wahrheit einer Zustandsaussage; `state.md` selbst hält das für seine eigene
  Klasse fest.
- `klasse`: Zusage neben geänderter Ableitung bleibt stehen

### F-5 — Drei Übergaben an andere Rollen liegen in keinem Repo-Artefakt

- `kategorie`: MEDIUM
- `quelle`: Baseline-Regelwerk `modul-08-agentenrollen.md` §Die neun Übergaben (*„Ohne jedes
  dieser Artefakte gibt es keinen Rollenwechsel — nur einen Kontext-Switch ohne Übergabe"*) ·
  [`AGENTS.md`](../../AGENTS.md) §3.8 und §3.10
- `pfad`: `docs/plan/planning/done/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md:146`
  (die einzige geführte Übergabe-Zeile) · sonst kein Artefakt
- `befund`: Der Diff erzeugt drei Verpflichtungen für andere Rollen, und keine davon steht in
  einer Datei dieses Repos — weder im Slice-Plan noch in einer der drei Commit-Messages.
  (a) **Architect:** [`AGENTS.md`](../../AGENTS.md) §3.8 zählt in seinem Wächter-Absatz die
  aktiven Module ohne `planning` auf (`AGENTS.md:324-325`) und ist damit aus demselben Grund
  falsch wie F-3, nur in einem Artefakt, das der Implementer nicht schreiben darf.
  (b) **Planner, terminiert:** wird `in-progress/` bei der Closure leer, muss der Ruhe-Marker
  `Nichts in Arbeit.` zurück in `## Offene Wellen`, sonst meldet `planning-drift` und
  `make gates` ist rot; `make slice-mv` zieht Pfade nach, keine Zustandssätze
  ([`harness/README.md`](../../harness/README.md), erste der drei gemessenen Grenzen des
  Werkzeugs). (c) **Planner:** die widerlegte Beleg-Zeile aus F-4. Die **eine** Übergabe-Zeile,
  die der Plan führt (`harness/conventions.md`/`MR-016` an den Architect), ist zugleich
  gegenstandslos geworden — siehe F-7.
- `verifizierbar`: nein — kein Modul aus `modules:` liest eine erklärte Übergabe gegen den
  Planning-Lifecycle; genau das hält
  [`BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../plan/planning/observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/observation.md)
  für seine Klasse fest. Beobachtbar ist (b): der nächste Lauf, der `in-progress/` leert und
  `make gates` fährt, sieht `planning-drift` auf `roadmap.md` — die Gegenrichtung von Sonde E.
- `klasse`: Übergabe an andere Rolle ohne Träger-Artefakt

### F-6 — Die Begründung der `waves`-Nichtaktivierung zitiert das Werkzeug ohne den Schalter, der sein Verhalten bestimmt

- `kategorie`: LOW
- `quelle`: Maintainability ·
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- `pfad`: `.d-check.yml:36-38` · `docs/plan/planning/in-progress/roadmap.md:36-38` ·
  `harness/README.md:66-70`
- `befund`: An drei Stellen steht wortgleich, die `waves`-Fähigkeit „*verlangt genau diese
  Bijektion*" zwischen Zeigern und flachen Welle-Dateien. Das gilt allein unter
  `waves.mode: many`; der Default ist `"one"` (`WavesConfig.EffectiveMode()`), und dort prüft
  `waveDrift` ein **Singleton**-Prädikat — genau *ein* flaches Welle-Dokument bei aktiver
  Sektion —, gegen das dieses Repo mit `ls docs/plan/planning/welle-*.md | wc -l` → **3**
  ebenfalls fällt, aber aus einem anderen Grund. Keine der drei Stellen nennt den Modus, unter
  dem die zitierte Messung entstand. Die Schlussfolgerung (`waves` bleibt aus) trägt in beiden
  Modi; die Begründung beschreibt nur einen davon.
- `verifizierbar`: nein am Gate — nachprüfbar an `internal/hexagon/core/rules/planning_waves.go`
  (`CheckPlanningWaves` verzweigt auf `EffectiveMode()`) und
  `internal/hexagon/core/model/config.go` (`EffectiveMode` Default `"one"`) des gepinnten
  Werkzeugs.
- `klasse`: Fremd-Werkzeug-Verhalten ohne den Schalter zitiert, der es bestimmt

### F-7 — Die einzige geführte Übergabe des Plans hat keinen Gegenstand mehr

- `kategorie`: INFO
- `quelle`: [`MR-020`](../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
  · [`MR-037`](../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
- `pfad`: `docs/plan/planning/done/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md:146`
- `befund`: Die Plan-Tabelle führt `harness/conventions.md` als *nicht durch diesen Slice* mit
  der Begründung, [`MR-016`](../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
  trage „*die Durchsetzungs-Aussage, die dieser Slice falsch macht*". `MR-016` ist seit
  `MR-037` vollständig aufgehoben; seine Datei unter `harness/conventions/done/` trägt nur noch
  Kopf und Zeiger, der Rumpf mit jener Aussage ist gefallen. Der Diff nimmt die Übergabe zu
  Recht nicht auf — der Plan sagt aber nicht, dass sie leerläuft, und die Restnennung der
  Aussage steht in `MR-037` selbst (`harness/conventions/MR-037-…md:37`), einem angenommenen
  und damit nicht nachträglich änderbaren Eintrag.
- `verifizierbar`: ja —
  `cat harness/conventions/done/MR-016-welle-oder-nicht-und-wo-wellenlose-arbeit-gefuehrt-wird.md`
  zeigt Kopf und Zeiger ohne Rumpf.
- `klasse`: Plan-Übergabe zeigt auf ein zurückgebautes Artefakt

### F-8 — Die `waves`-Zusicherung ist über der leeren Menge wahr

- `kategorie`: INFO
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6
- `pfad`: `test/planning-modul-wiring.bats:55-57`
- `befund`: `@test "planning: waves bleibt aus …"` prüft
  `! block | grep -qE '^[[:space:]]+waves:'`. Fällt der ganze `planning:`-Block aus
  `.d-check.yml`, gibt `block()` nichts aus, die Negation greift, und die Zusicherung ist grün,
  ohne etwas gemessen zu haben — dieselbe Quantifizierung über der leeren Menge, die
  `test/archiv-stub-vorlagen.bats` an anderer Stelle ausdrücklich mit einem zweiten Fall gegen
  ihre eigene Bezugsmenge abfängt. Die Zusicherungen 2–4 fangen den Wegfall laut ab, sodass die
  Suite als Ganzes nicht still grün wird.
- `verifizierbar`: ja — den `planning:`-Block entfernen und `make test-bats` fahren: die
  `waves`-Zusicherung bleibt grün, die drei Feld-Zusicherungen fallen.
- `klasse`: Zusicherung über der leeren Menge wahr

## Negativbefunde

- **geprüft, ohne Befund: die Entfernung von `Nichts in Arbeit.` aus der Roadmap.** Kein
  Eingriff in ein fremdes Rollen-Artefakt. Drei unabhängige Gründe: (1) Der Ruhe-Marker ist
  eine **derivative Aussage** — Baseline-Regelwerk `modul-06-roadmap.md`
  §Roadmap-Struktur: fünf Abschnitte führt ihn ausdrücklich als das, was „*dem Anspruch folgt*
  … genau dann, wenn `in-progress/` keinen Slice trägt"; sein Original ist die
  Verzeichnis-Position, und die schreibt beim Übergang `next→in-progress` der Implementer
  (`modul-05-planning-harness.md` §Trigger je Lifecycle-Übergang). Nach
  [`ADR-0024`](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)
  Festlegung 1 („*derivativ ist eine Eigenschaft der Aussage, nicht der Datei*") folgt die
  Aussage der Rolle ihres Originals. (2) Die Aussage war zum Zeitpunkt der Änderung
  **nachweislich falsch** — `ls docs/plan/planning/in-progress/` führte `slice-125` —, und die
  Korrektur geht in die richtige Richtung: die Roadmap folgt dem Verzeichnis, nicht umgekehrt
  (das Risiko, das Slice-Plan §6 als erstes benennt); Sonde E zeigt, dass die Zeile am
  gelieferten Stand real ein Rot erzeugt. (3) Der Plan autorisiert sie: §3 führt
  `roadmap.md | update` als geplanten Gegenstand, §6 verlangt ausdrücklich, den Gate „*in dem
  Zustand grün zu bekommen, in dem er selbst `in-progress/` besetzt*".
  [`AGENTS.md`](../../AGENTS.md) §3.10 zählt seine gebundenen Closure-Artefakte auf —
  Closure-Notiz, Risiko-Ausgänge, DoD-Häkchen, Beobachtungs-Register, Welle-Plan, `git mv` —;
  die Roadmap ist keines davon, und ein Abnahmekriterium verschiebt die Änderung nicht.
- **geprüft, ohne Befund: der mitgeschriebene Erklärungsabsatz der Roadmap.** Der Diff ersetzt
  dort genau den Satz, den er selbst falsch gemacht hat (*„Beide Aussagen dieses Blocks sind
  heute unbewacht"*), und stellt die neue Aussage neben das Kommando, das sie liefert. Er trägt
  keine Chronik: die alte Formulierung nannte `slice-125` als Träger, die neue nennt Zustand und
  Beleg — genau die Form, die [`AGENTS.md`](../../AGENTS.md) §3.7 für Zustandsaussagen verlangt.
- **geprüft, ohne Befund: die Einordnung der zwei `waves`-Befunde.** Die Abweichung ist real
  und in der Roadmap selbst dokumentiert: `ls docs/plan/planning/welle-*.md` führt `welle-09`,
  `welle-11`, `welle-13`, der Abschnitt *Offene Wellen* nennt zwei davon, `welle-11` steht mit
  Datei unter *Nächste Wellen*. Beide Befunde entstehen aus genau dieser Differenz —
  `waveBijection` meldet die Datei ohne Zeiger, `waveRegisters` die Vorschau-Zeile mit
  existierender Datei. Ein Ventil dafür gibt es nicht: `WavesConfig` führt die Felder
  `Dir, DoneDir, Glob, ResultsGlob, NextHeading, ClosedHeading, Mode` und keine Ausnahmeliste.
  Die Nichtaktivierung hält den Prüfbereich also nicht stillschweigend klein
  ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) — sie
  ist an zwei lebenden Orten benannt, mit Grund und mit der Bedingung fürs Zuschalten. Die
  Ungenauigkeit *in* dieser Begründung steht als F-6.
- **geprüft, ohne Befund: die neu geschriebenen Kommentare gegen
  [`AGENTS.md`](../../AGENTS.md) §3.7.** Vier Stellen liegen im Geltungsbereich (Konfiguration
  und Skripte): `.d-check.yml:30-39`, `test/planning-modul-wiring.bats:2-10` und die zwei
  Mutations-Köpfe. Alle vier stehen im Indikativ über den Zustand der Stelle, tragen die
  Klassen Zusage · Kopplung · Abgrenzung · Grenze und **keine** Herkunft — keine
  Befund-Kennung, keine Slice-Nummer, kein Lauf-Protokoll:

  ```sh
  sed -n '30,39p' .d-check.yml | grep -cE 'Review-Befund|slice-[0-9]'                       # 0
  grep -cE 'Review-Befund|slice-[0-9]' test/planning-modul-wiring.bats \
       test/mutations/269-planning-modul-aus-modules-entfernt.sh \
       test/mutations/270-planning-heading-auf-modul-default-zurueckgesetzt.sh              # je 0
  ```

  Der Konjunktiv-Satz im bats-Kopf („*eine Ueberschrift, die … die Invariante trivial machen
  wuerde, bleibt fuer `docs-check` unsichtbar*") beschreibt die **Grenze** des Wächters, nicht
  die verworfene Alternative, und fällt damit in eine der fünf zulässigen Klassen; Sonde C
  bestätigt ihn zudem als sachlich richtig. Die „(slice-125)"-Marke in `harness/README.md:59`
  liegt außerhalb — Markdown-Fließtext steht in keinem der vier Geltungsbereiche von §3.7.
- **geprüft, ohne Befund: die korrigierte fail-closed-Begründung.** Die in `270` und im
  bats-Kopf getragene Zusage „*`docs-check` selbst faellt darauf bereits fail-closed
  (planning-drift, kanonische Ueberschrift fehlt)*" ist wahr — Sonde D liefert exakt diese
  Meldung, und `planningActiveStatus` erzeugt sie bei `count == 0`, bevor `hasSlices` überhaupt
  bestimmt wird. Die Korrektur der eigenen Begründung war sachlich richtig und hat an dieser
  Stelle keine neue Ungenauigkeit erzeugt.
- **geprüft, ohne Befund: die Zähne treffen die Stelle, die der Aufrufer benutzt.** Beide
  Mutations-Fälle editieren die reale `.d-check.yml`, und die bats-Zusicherungen lesen dieselbe
  Datei über `$BATS_TEST_DIRNAME/..` — keine im Test nachgebaute Verdrahtung. Beide
  `# expect:`-Zeilen nennen einen wörtlich existierenden `@test`-Namen, und
  `harness/tools/mutate.sh:698-699` verlangt, dass **dieser** Test fällt („*rot, aber
  '\$expect' faellt nicht — falscher Grund*"), nicht nur die Stufe.
- **geprüft, ohne Befund: die Kopplungs-Zusicherung ist keine Abschrift der Config.**
  `@test "der konfigurierte heading existiert wortgleich als Abschnitt in der Roadmap"` hält
  zwei getrennte Artefakte gegeneinander (`grep -qxF` gegen `roadmap.md`) und ist damit die
  eine der sechs, die eine Kopplung statt eines Literals misst. Die Feld-Zusicherungen 1–4 sind
  Literal-Pins; das ist im Repo die etablierte Form für einen Konfigurations-Wert, den kein
  Gate von außen halten kann (`test/sources-pin.bats`, `test/ignore-refs-restbreite.bats`) —
  und für `marker` und `heading` sind sie, siehe F-1, sogar die einzigen Sensoren.
- **geprüft, ohne Befund: der gewählte Abschnitt trägt die Invariante nicht trivial.**
  `grep -cx '## Offene Wellen' docs/plan/planning/in-progress/roadmap.md` → **1** (Eindeutigkeit,
  sonst fail-closed nach `planningActiveStatus`, `count > 1`), und beide Richtungen färben
  wirklich rot — Sonde E für *Marker bei besetztem `in-progress/`*, die Baseline-Messung des
  Slice-Plans §1 für die Gegenrichtung. Der Block, in dem der Marker gesucht wird, endet an
  `## Nächste Wellen` (`SectionEnd`), sodass die Erwähnungen des Marker-Literals weiter unten im
  Drift-Log den Status nicht verfälschen.
- **geprüft, ohne Befund: die neue bats-Datei läuft wirklich in `make gates`.** Die Kopf-Zusage
  „*laeuft in `make gates` ueber `make test` -> `test-bats`*" trägt: das Rezept ist
  `docker run … $(BATS_IMAGE) test/` über dem ganzen Verzeichnis, ohne Dateiliste, die
  nachgezogen werden müsste.
- **geprüft, ohne Befund: die übrigen Fundorte der alten Modul-Aufzählung.** Neben der in F-3
  genannten tragen **13** lebende Fundorte die Sechser-Liste weiter:

  ```sh
  git grep -l 'links, anchors, ids, matrix, codepaths, spans' \
    -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' \
       ':!.d-check.yml' ':!harness/README.md' ':!test/mutations' | wc -l                    # 14
  ```

  Kein Erwartungswert; die Zahl schließt `.github/workflows/ci.yml` aus F-3 mit ein. Alle
  übrigen liegen außerhalb der Zuständigkeit dieses Laufs und wurden zu Recht nicht angefasst:
  [`ADR-0035`](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  ([`AGENTS.md`](../../AGENTS.md) §3.4), acht `MR`-Einträge (Architect nach §3.8, und ein
  angenommener Eintrag wird nicht nachträglich inhaltlich geändert),
  [`AGENTS.md`](../../AGENTS.md) selbst (Architect — als Übergabe (a) in F-5 geführt) und drei
  fremde Slice-Pläne in `open/`. Die fünf Fundorte in `docs/plan/planning/done/` sind
  Zeitdokumente und stehen ohnehin außerhalb.
- **geprüft, ohne Befund: Hard Rules ohne Treffer.** §3.3 (kein `git mv` im Bereich), §3.5
  (keine Lockerung — die Aktivierung eines Moduls ist ein *Anheben* und läuft nach
  [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  über den Steering-Loop, nicht über eine ADR; die vier `ignore-refs`-Paare und der
  `scan.ignore`-Zensus sind unberührt), §3.9 (keine Host-Toolchain in den neuen Rezepten oder
  Tests), §3.11 (die neue Adresse auf
  [`slice-129`](../plan/planning/open/slice-129-closure-notiz-hat-einen-sensor.md) steht in
  einem **änderbaren** Artefakt, wo der Pfad der richtige Zeiger ist, und
  `rewrite_incoming_in_file` in `harness/tools/slice-mv.sh` trifft ihre Präfix-Form beim
  nächsten Move, weil das Zeichen vor `open/` kein Wortzeichen ist).
- **geprüft, ohne Befund:
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert).**
  Der neue Roadmap-Absatz stellt seine Aussage neben das Kommando, das sie liefert
  (`grep -n '^modules:' .d-check.yml` führt es); der `harness/README.md`-Absatz und die
  `.d-check.yml`-Kommentare führen keine Zahl ein, die einen Beleg bräuchte.
- **geprüft, ohne Befund: die drei Commits nennen ihre Kennungen.** Jede Message trägt eine
  `Bezug:`-Zeile mit `LH-*`- bzw. Hard-Rule-Referenz und das Rollen-Präfix
  `Rolle Implementation:`.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 4 |
| LOW | 1 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** Mutations-Zahn deckt den lauten statt den stillen Pfad ·
Deckungs-Absatz nennt nicht alle Fähigkeiten des aktivierten Moduls · Zusage neben geänderter
Ableitung bleibt stehen (**2×** in diesem Lauf, F-3 und F-4) · Übergabe an andere Rolle ohne
Träger-Artefakt · Fremd-Werkzeug-Verhalten ohne den Schalter zitiert, der es bestimmt ·
Plan-Übergabe zeigt auf ein zurückgebautes Artefakt · Zusicherung über der leeren Menge wahr

Zwei dieser Klassen führt das Beobachtungs-Register bereits; ihr Stand am Tag dieses Laufs
steht neben seinem Kommando:

```sh
ls docs/plan/planning/observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/evidence/*.md | wc -l   # 15
ls docs/plan/planning/observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/evidence/*.md | wc -l    # 1
```

Keine Erwartungswerte — die Zähler wandern mit dem Register. **Zwei Funde im selben Vorgang
sind eine Gelegenheit, kein zweites Auftreten** (`modul-06-roadmap.md`
§Das Beobachtungs-Register): F-3 und F-4 tragen dieselbe Klasse und gehören bei der Closure in
**einen** Beleg, nicht in zwei.

## Verdikt

**Merge-blockierend:** ja — ein HIGH und vier MEDIUM.

Der Kern des Slice trägt, und das ist gemessen und nicht angenommen: Das Modul ist aktiviert
(Sonde A grün), auf einen Abschnitt gebunden, in dem die Invariante beide Zustände annehmen
kann (Sonde E rot), und die Nichtaktivierung von `waves` ist eine begründete Entscheidung statt
einer stillen Verengung. Die Findings liegen um diesen Kern herum — an der Haltbarkeit seiner
Wächter (F-1), an der Vollständigkeit der Aussage über den Prüfbereich (F-2) und an drei
lebenden Aussagen, die dieser Diff falsch gemacht oder ohne Zuständigen gelassen hat (F-3 bis
F-5).

**F-1 ist HIGH und nicht MEDIUM**, weil die betroffenen Zusicherungen nicht irgendwelche sind:
Sie sind die einzigen Sensoren über den zwei Konfigurationsänderungen, die `make docs-check` an
diesem Baum nachweislich grün lassen und die Invariante zugleich entwerten (Sonden B und C) —
also über genau dem stillen Grün, zu dessen Beseitigung dieser Slice angetreten ist. Der Skill
hebt eine Beobachtung im Gate-Pfad um eine Stufe; hier fällt beides zusammen.

**Übergabe:** Findings gehen an den Implementer. **F-4 und die Teile (a) und (c) von F-5 sind
für ihn nicht behebbar** — sie betreffen Artefakte des Architects
([`AGENTS.md`](../../AGENTS.md) §3.8) und des Planners ([`AGENTS.md`](../../AGENTS.md) §3.10);
für sie ist dieser Report das Übergabe-Artefakt, das Modul 8 für den Rollenwechsel verlangt.
Die **Finding-Klassen** gehen zusätzlich in die Slice-Closure §7 und von dort in den Zähler.
Dieser Report selbst ist ein **Lauf-Beleg** und wird über Läufe hinweg nicht wieder gelesen.
Er ersetzt keine Verifikation — DoD-/Spec-Konformität prüft der Verifier separat (Modul 11).
